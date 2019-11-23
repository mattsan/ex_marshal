defmodule ExMarshal.Bignum do
  @moduledoc false

  @bit_size_par_short_int 16

  def parse(<<sign, seq::binary>>, state) do
    {short_int_size, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    bit_size = short_int_size * @bit_size_par_short_int
    <<effective::size(bit_size)-little, rest::binary>> = source

    value =
      case sign do
        ?+ -> effective
        ?- -> -effective
      end

    {value, rest, next_state}
  end
end
