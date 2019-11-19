defmodule ExMarshal.Array do
  def parse(seq) do
    {values, [rest]} =
      Stream.unfold(ExMarshal.Fixnum.parse(seq), fn
        nil ->
          nil

        {0, rest} ->
          {rest, nil}

        {n, s} ->
          {value, rest} = ExMarshal.parse(s)
          {value, {n - 1, rest}}
      end)
      |> Enum.to_list()
      |> Enum.split(-1)

    {values, rest}
  end
end
