defmodule WordFinder do
  def split_word(word) do
    word
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_string/1)
  end

  def declare_pool(n) do
    1..n |> Enum.map(fn _ -> WordCheck.start_link() |> elem(1) end)
  end

  def find_word(pool_number \\ 1) do
    process_pool = declare_pool(pool_number)

    File.stream!("words.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn word -> String.length(word) |> rem(2) == 0 end)
    |> Stream.map(&split_word/1)
    |> Enum.to_list()
    |> List.foldl(process_pool, fn word, [pid | pool] ->
      WordCheck.check_word(pid, word)
      pool ++ [pid]
    end)

    process_pool
    |> Enum.map(&WordCheck.get_larger_word/1)
    |> Enum.max_by(&String.length/1)
    |> IO.inspect()
  end

  def main([]), do: main(["1"])

  def main([pool_size | _]) do
    pool_size |> String.to_integer() |> find_word()
  end
end
