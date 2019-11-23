defmodule ExMarshal.Array do
  def parse(seq, state) do
    {count, rest, next_state} = ExMarshal.Fixnum.parse(seq, state)
    parse_values(count, [], rest, next_state)
  end

  defp parse_values(0, values, rest, state) do
    {Enum.reverse(values), rest, state}
  end

  defp parse_values(count, values, source, state) do
    {value, rest, next_state} = ExMarshal.parse(source, state)
    parse_values(count - 1, [value | values], rest, next_state)
  end
end
