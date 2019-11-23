defmodule ExMarshal.Fixnum do
  require Bitwise
  import Bitwise

  @bit_size_par_byte 8

  def parse(<<0, rest::binary>>, state) do
    {0, rest, state}
  end

  def parse(<<value::signed, rest::binary>>, state) when value > 5 do
    {value - 5, rest, state}
  end

  def parse(<<value::signed, rest::binary>>, state) when value < -5 do
    {value + 5, rest, state}
  end

  def parse(<<byte_size::signed, rest::binary>>, state) when byte_size > 0 do
    bit_size = byte_size * @bit_size_par_byte
    <<value::size(bit_size)-little-unsigned, rest::binary>> = rest
    {value, rest, state}
  end

  def parse(<<byte_size::signed, rest::binary>>, state) when byte_size < 0 do
    bit_size = -byte_size * @bit_size_par_byte
    <<value::size(bit_size)-little, rest::binary>> = rest
    {value - (1 <<< bit_size), rest, state}
  end
end
