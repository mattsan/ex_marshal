defmodule ExMarshal.Fixnum do
  require Bitwise
  import Bitwise

  def parse(<<0, rest::binary>>) do
    {0, rest}
  end

  def parse(<<value::signed, rest::binary>>) when value > 5 do
    {value - 5, rest}
  end

  def parse(<<value::signed, rest::binary>>) when value < -5 do
    {value + 5, rest}
  end

  def parse(<<len::signed, rest::binary>>) when len > 0 do
    length = len * 8
    <<value::size(length)-little-unsigned, rest::binary>> = rest
    {value, rest}
  end

  def parse(<<len::signed, rest::binary>>) when len < 0 do
    length = - len * 8
    <<value::size(length)-little, rest::binary>> = rest
    {value - (1 <<< length), rest}
  end
end
