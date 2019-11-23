defmodule ExMarshal do
  @major 4
  @minor 8

  @moduledoc """
  Load marshaled Ruby objects.

  Supported version is only 4.8.

  See [Marshal フォーマット (Ruby 2.6.0)](https://docs.ruby-lang.org/ja/latest/doc/marshal_format.html)
  or [marshal - Documentation for Ruby 2.6.0](https://docs.ruby-lang.org/en/2.6.0/marshal_rdoc.html).

  This module can parse and load
  - `nil`
  - `true`
  - `false`
  - `Fixnum`
  - `Object` to structs
  - `Bignum`
  - `String`
  - `Regexp` to regexes
  - `Array` to lists
  - `Hash` to maps
  - `Struct` to structs
  - `Symbol` to atoms
  """

  @initial_state %{symbols: []}

  @doc """
  Parse and load marshaled Ruby objects.

  ## Example
      iex> ExMarshal.load(<<4, 8, ?i, 1, 123>>)
      123

      iex> ExMarshal.load(<<4, 8, "abc">>)
      {:error, {:unknown_flag, %{flag: ?a, sequence: "abc"}}, %{symbols: []}}
  """
  @spec load(binary()) :: any()
  def load(<<@major, @minor, rest::binary>>) do
    with {value, "", _state} <- parse(rest, @initial_state) do
      value
    end
  end

  @doc """
  Parse marshaled Ruby objects.
  """
  @spec parse(binary(), map()) :: any()
  def parse(sequence, state)

  def parse(<<>>, _), do: []

  def parse(<<flag, rest::binary>> = sequence, state) do
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
      ?; -> ExMarshal.Symbol.Link.parse(rest, state)
      ?I -> ExMarshal.InstanceVariable.parse(rest, state)
      _ -> {:error, {:unknown_flag, %{flag: flag, sequence: sequence}}, state}
    end
  end
end
