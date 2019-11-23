defmodule ExMarshal.Symbol do
  def parse(seq, state) do
    {size, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {value, rest} = String.split_at(source, size)
    symbol = String.to_atom(value)
    {symbol, rest, update_in(next_state, [:symbols], &[symbol | &1])}
  end
end
