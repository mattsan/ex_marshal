defmodule ExMarshal.Hash do
  @moduledoc false

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {count, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    parse_pairs(count, [], source, next_state)
  end

  @spec parse_pairs(integer(), [{any(), any()}], binary(), map()) :: {map(), binary(), map()}
  def parse_pairs(count, pairs, source, state)

  def parse_pairs(0, pairs, rest, state) do
    {Map.new(pairs), rest, state}
  end

  def parse_pairs(count, pairs, source, state) do
    {key, value_and_rest, state2} = ExMarshal.parse(source, state)
    {value, rest, state3} = ExMarshal.parse(value_and_rest, state2)
    parse_pairs(count - 1, [{key, value} | pairs], rest, state3)
  end
end
