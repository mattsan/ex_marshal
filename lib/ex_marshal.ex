defmodule ExMarshal do
  @moduledoc """
  Documentation for ExMarshal.

  see https://docs.ruby-lang.org/ja/latest/doc/marshal_format.html
   or https://docs.ruby-lang.org/en/2.6.0/marshal_rdoc.html
  """

  alias ExMarshal.{Fixnum}

  @major 4
  @minor 8

  def load(<<@major, @minor, rest::binary>>) do
    {value, ""} = parse(rest)
    value
  end


  def parse(<<>>), do: []
  def parse(<<"0", rest::binary>>), do: {nil, rest}
  def parse(<<"T", rest::binary>>), do: {true, rest}
  def parse(<<"F", rest::binary>>), do: {false, rest}
  def parse(<<"i", rest::binary>>), do: Fixnum.parse(rest)
end
