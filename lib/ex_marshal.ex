defmodule ExMarshal do
  @moduledoc """
  Documentation for ExMarshal.

  see https://docs.ruby-lang.org/ja/latest/doc/marshal_format.html
   or https://docs.ruby-lang.org/en/2.6.0/marshal_rdoc.html
  """

  @major 4
  @minor 8

  def load(<<@major, @minor, rest::binary>>) do
    {value, ""} = parse(rest)
    value
  end


  def parse(<<>>), do: []
  def parse(<<flag, rest::binary>>) do
    case flag do
      ?0 -> {nil, rest}
      ?T -> {true, rest}
      ?F -> {false, rest}
      ?i -> ExMarshal.Fixnum.parse(rest)
      ?f -> ExMarshal.Float.parse(rest)
      ?l -> ExMarshal.Bignum.parse(rest)
      ?" -> ExMarshal.String.parse(rest)
      ?/ -> ExMarshal.Regex.parse(rest)
      ?[ -> ExMarshal.Array.parse(rest)
      ?: -> ExMarshal.Symbol.parse(rest)
      ?I -> ExMarshal.InstanceVariable.parse(rest)
      _ -> {:error, {:unknown_flag, <<flag>>}}
    end
  end
end
