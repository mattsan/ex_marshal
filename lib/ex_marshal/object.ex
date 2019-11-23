defmodule ExMarshal.Object do
  def parse(<<flag, seq::binary>>, state) when flag in [?:, ?;] do
    {class_name, count_and_source, state2} =
      case flag do
        ?: -> ExMarshal.Symbol.parse(seq, state)
        ?; -> ExMarshal.Symbol.Link.parse(seq, state)
      end
    {count, source, state3} = ExMarshal.Fixnum.parse(count_and_source, state2)
    {hash, rest, state4} = ExMarshal.Hash.parse_pairs(count, [], source, state3)
    {put_in(hash, [:__struct__], Module.concat(Elixir, class_name)), rest, state4}
  end
end
