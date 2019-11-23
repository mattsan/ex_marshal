defmodule ExMarshal.Object do
  def parse(<<?:, seq::binary>>, state) do
    {class_name, count_and_source, state2} = ExMarshal.String.parse(seq, state)
    {count, source, state3} = ExMarshal.Fixnum.parse(count_and_source, state2)
    {hash, rest, state4} = ExMarshal.Hash.parse_pairs(count, [], source, state3)
    {put_in(hash, [:__struct__], Module.concat(Elixir, class_name)), rest, state4}
  end
end
