defmodule ExMarshal.Bignum do
  def parse(<<sign, seq::binary>>) do
    {len, s} = ExMarshal.Fixnum.parse(seq)
    bit_len = len * 16
    <<effective::size(bit_len)-little, rest::binary>> = s

    value =
      case sign do
        ?+ -> effective
        ?- -> -effective
      end

    {value, rest}
  end
end
