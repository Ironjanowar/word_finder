defmodule WordFinder do
  def split_word(word) do
    word
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_string/1)
  end

  def declare_pool(n) do
    syllables = File.read!("syllables.txt") |> String.split("\n", trim: true) |> MapSet.new()
    1..n |> Enum.map(fn _ -> WordCheck.start_link(syllables) |> elem(1) end)
  end

  def find_word(pool_number \\ 1) do
    syllables = File.read!("syllables.txt") |> String.split("\n", trim: true) |> MapSet.new()
    # process_pool = declare_pool(pool_number)
    "words.txt"
    |> File.stream!(read_ahead: 1000 * pool_number)
    |> Flow.from_enumerable(stages: pool_number, max_demand: 1000)
    |> Flow.map(&String.trim/1)
    |> Flow.filter(fn word -> String.length(word) |> rem(2) == 0 end)
    |> Flow.map(&split_word/1)
    |> Flow.partition()
    |> Flow.reduce(fn -> [%{word: [], length: 0}] end, fn word, [acc] ->
      old_length = acc[:length]
      new_length = length(word)

      with true <- new_length > old_length,
           true <- WordCheck.are_syllables?(word, syllables) do
        [%{word: word, length: new_length}]
      else
        _ ->
          [acc]
      end
    end)
    |> Flow.take_sort(1, fn %{length: l1}, %{length: l2} ->
      l1 >= l2
    end)
    |> Enum.at(0)
    |> Enum.at(0)
    |> Map.get(:word)
    |> Enum.join("")
    |> IO.inspect()

    # |> Stream.map(&String.trim/1)
    # |> Stream.filter(fn word -> String.length(word) |> rem(2) == 0 end)
    # |> Stream.map(&split_word/1)
    # |> Enum.reduce(0, fn word, n ->
    #   i = Integer.mod(n, pool_number)
    #   pid = Enum.at(process_pool, i)
    #   WordCheck.check_word(pid, word)

    #   n + 1
    # end)

    # process_pool
    # |> Enum.map(&WordCheck.get_larger_word/1)
    # |> Enum.max_by(&String.length/1)
    # |> IO.inspect()
  end

  def main([]), do: main(["1"])

  def main([pool_size | _]) do
    pool_size |> String.to_integer() |> find_word()
  end
end
