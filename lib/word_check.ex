defmodule WordCheck do
  use GenServer

  # Client API
  def start_link(syllables) do
    GenServer.start_link(__MODULE__, {:ok, syllables})
  end

  # Receive a word
  def check_word(pid, word) do
    GenServer.cast(pid, {:check_word, word})
  end

  def get_larger_word(pid) do
    GenServer.call(pid, :get_larger_word)
  end

  # Server callbacks
  def init({:ok, syllables}) do
    {:ok, %{syllables: syllables, larger_word: [], length: 0}}
  end

  def handle_cast({:check_word, word}, state = %{syllables: syllables, length: old_length}) do
    new_length = length(word)

    with true <- new_length > old_length,
         true <- are_syllables?(word, syllables) do
      new_state = state |> Map.put(:larger_word, word) |> Map.put(:length, new_length)
      {:noreply, new_state}
    else
      _ -> {:noreply, state}
    end
  end

  def handle_call(:get_larger_word, _from, state = %{larger_word: larger_word}) do
    word = larger_word |> Enum.join("")
    {:reply, word, state}
  end

  # Utils
  def are_syllables?(word, syllables) do
    # Check if all syllables of the word are in syllables.txt
    Enum.all?(word, &MapSet.member?(syllables, &1))
  end
end
