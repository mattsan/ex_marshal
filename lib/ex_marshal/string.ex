defmodule ExMarshal.String do
  @moduledoc false

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {size, source, next_state} = ExMarshal.Fixnum.parse(seq, state)
    {value, rest} = String.split_at(source, size)
    {value, rest, next_state}
  end
end
