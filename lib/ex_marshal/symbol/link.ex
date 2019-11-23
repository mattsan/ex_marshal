defmodule ExMarshal.Symbol.Link do
  @moduledoc false

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {index, rest, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {Enum.at(state.symbols, -1 - index), rest, next_state}
  end
end
