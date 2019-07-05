defmodule WordCheck do
  use GenServer

  require Logger

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Receive a word
  def check_word(word) do
    GenServer.cast(__MODULE__, {:check_word, word})
  end

  def get_larger_word() do
    GenServer.call(__MODULE__, :get_larger_word)
  end

  # Server callbacks
  def init(:ok) do
    syllables = File.read!("syllables.txt") |> String.split("\n", trim: true)
    {:ok, %{syllables: syllables, larger_word: []}}
  end

  def handle_cast({:check_word, word}, state = %{syllables: syllables, larger_word: larger_word}) do
    word |> inspect |> Logger.debug()

    with true <- length(word) > length(larger_word),
         true <- are_syllables?(word, syllables) do
      new_state = Map.put(state, :larger_word, word)
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
    false not in Enum.map(word, fn syllable -> syllable in syllables end)
  end
end
