defmodule ExMarshal.Array do
  @moduledoc false

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {count, rest, next_state} = ExMarshal.Fixnum.parse(seq, state)
    parse_values(count, [], rest, next_state)
  end

  @spec parse_values(non_neg_integer(), [any()], binary(), map()) :: any()
  defp parse_values(count, values, source, state)

  defp parse_values(0, values, rest, state) do
    {Enum.reverse(values), rest, state}
  end

  defp parse_values(count, values, source, state) do
    {value, rest, next_state} = ExMarshal.parse(source, state)
    parse_values(count - 1, [value | values], rest, next_state)
  end
end
