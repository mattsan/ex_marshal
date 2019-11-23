defmodule ExMarshal.String do
  def parse(seq, state) do
    {size, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {value, rest} = String.split_at(source, size)
    {value, rest, next_state}
  end
end
