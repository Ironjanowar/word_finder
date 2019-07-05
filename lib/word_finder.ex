defmodule WordFinder do
  def split_word(word) do
    word
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_string/1)
  end

  def find_word() do
    File.stream!("words.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn word -> String.length(word) |> rem(2) == 0 end)
    |> Stream.map(&split_word/1)
    |> Enum.each(&WordCheck.check_word/1)
  end

  def main(_) do
    WordCheck.start_link()
    find_word()
    WordCheck.get_larger_word()
  end
end
