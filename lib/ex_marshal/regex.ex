defmodule ExMarshal.Regex do
  def parse(seq) do
    {len, s} = ExMarshal.Fixnum.parse(seq)
    {value, <<option, rest::binary>>} = String.split_at(s, len)
    {:ok, regex} = Regex.compile(value, options(option))
    {regex, rest}
  end

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
