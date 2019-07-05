defmodule WordFinder.Application do
  use Application

  def start(_type, _args) do
    WordFinder.find_word()
    WordCheck.get_larger_word()
  end
end
