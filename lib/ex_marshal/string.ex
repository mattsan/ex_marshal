defmodule ExMarshal.String do
  def parse(seq) do
    {len, s} = ExMarshal.Fixnum.parse(seq)
    String.split_at(s, len)
  end
end
