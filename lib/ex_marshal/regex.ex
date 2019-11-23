defmodule ExMarshal.Regex do
  @moduledoc false

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {size, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {value, <<option, rest::binary>>} = String.split_at(source, size)
    {:ok, regex} = Regex.compile(value, options(option))
    {regex, rest, next_state}
  end

  @spec options(0..7) :: binary()
  defp options(n) do
    case n do
      0 -> ""
      1 -> "i"
      2 -> "x"
      3 -> "ix"
      4 -> "m"
      5 -> "im"
      6 -> "xm"
      7 -> "ixm"
    end
  end
end
