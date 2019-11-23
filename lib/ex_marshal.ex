defmodule ExMarshal do
  @moduledoc """
  Documentation for ExMarshal.

  see https://docs.ruby-lang.org/ja/latest/doc/marshal_format.html
   or https://docs.ruby-lang.org/en/2.6.0/marshal_rdoc.html
  """

  @major 4
  @minor 8
  @initial_state %{symbols: []}

  def load(<<@major, @minor, rest::binary>>) do
    {value, "", _state} = parse(rest, @initial_state)
    value
  end

  def parse(<<>>, _), do: []

  def parse(<<flag, rest::binary>>, state) do
    case flag do
      ?0 -> {nil, rest, state}
      ?T -> {true, rest, state}
      ?F -> {false, rest, state}
      ?i -> ExMarshal.Fixnum.parse(rest, state)
      ?o -> ExMarshal.Object.parse(rest, state)
      ?f -> ExMarshal.Float.parse(rest, state)
      ?l -> ExMarshal.Bignum.parse(rest, state)
      ?" -> ExMarshal.String.parse(rest, state)
      ?/ -> ExMarshal.Regex.parse(rest, state)
      ?[ -> ExMarshal.Array.parse(rest, state)
      ?{ -> ExMarshal.Hash.parse(rest, state)
      ?} -> ExMarshal.Hash.WithDefault.parse(rest, state)
      ?S -> ExMarshal.Struct.parse(rest, state)
      ?: -> ExMarshal.Symbol.parse(rest, state)
      ?; -> ExMarshal.Symlink.parse(rest, state)
      ?I -> ExMarshal.InstanceVariable.parse(rest, state)
      _ -> {:error, {:unknown_flag, <<flag>>}, state}
    end
  end
end
