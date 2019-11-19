defmodule ExMarshal.Symbol do
  def parse(seq) do
    {len, s} = ExMarshal.Fixnum.parse(seq)
    {value, rest} = String.split_at(s, len)
    {String.to_atom(value), rest}
  end
end
