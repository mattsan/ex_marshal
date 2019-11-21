defmodule ExMarshal.InstanceVariable do
  def parse(seq, state) do
    {value, source, state2} = ExMarshal.parse(seq, state)
    {_vars, rest, state3} = parse_vars(source, state2)
    {value, rest, state3}
  end

  defp parse_vars(source, state) do
    {count, source, next_state} = ExMarshal.Fixnum.parse(source, state)
    parse_vars(count, [], source, next_state)
  end

  defp parse_vars(0, vars, rest, state) do
    {Enum.reverse(vars), rest, state}
  end

  defp parse_vars(count, vars, <<flag, source::binary>>, state) when flag in [?:, ?;] do
    {sym, value_and_rest, state2} =
      case flag do
        ?: -> ExMarshal.Symbol.parse(source, state)
        ?; -> ExMarshal.Symlink.parse(source, state)
      end
    {value, rest, state3} = ExMarshal.parse(value_and_rest, state2)
    parse_vars(count - 1, [{sym, value} | vars], rest, state3)
  end
end
