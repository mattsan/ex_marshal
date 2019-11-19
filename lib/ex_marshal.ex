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
  def parse(<<?0, rest::binary>>), do: {nil, rest}
  def parse(<<?T, rest::binary>>), do: {true, rest}
  def parse(<<?F, rest::binary>>), do: {false, rest}
  def parse(<<?i, rest::binary>>), do: ExMarshal.Fixnum.parse(rest)
  def parse(<<?f, rest::binary>>), do: ExMarshal.Float.parse(rest)
  def parse(<<?l, rest::binary>>), do: ExMarshal.Bignum.parse(rest)
  def parse(<<?", rest::binary>>), do: ExMarshal.String.parse(rest)
  def parse(<<?/, rest::binary>>), do: ExMarshal.Regex.parse(rest)
  def parse(<<?[, rest::binary>>), do: ExMarshal.Array.parse(rest)
  def parse(<<?:, rest::binary>>), do: ExMarshal.Symbol.parse(rest)
  def parse(<<?I, rest::binary>>), do: ExMarshal.InstanceVariable.parse(rest)
end
