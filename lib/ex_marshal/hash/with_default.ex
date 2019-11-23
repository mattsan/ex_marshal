defmodule ExMarshal.Hash.WithDefault do
  def parse(seq, state) do
    {count, source, state2} = ExMarshal.Fixnum.parse(seq, state)
    {hash, default_and_rest, state3} = ExMarshal.Hash.parse_pairs(count, [], source, state2)
    {_default_value, rest, state4} = ExMarshal.parse(default_and_rest, state3)
    {hash, rest, state4}
  end
end
