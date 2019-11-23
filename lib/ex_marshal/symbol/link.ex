defmodule ExMarshal.Symbol.Link do
  @moduledoc false

  def parse(seq, state) do
    {index, rest, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {Enum.at(state.symbols, -1 - index), rest, next_state}
  end
end
