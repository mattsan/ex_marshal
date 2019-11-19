defmodule ExMarshal.InstanceVariable do
  def parse(seq) do
    {value, vars_str} = ExMarshal.parse(seq)

    vars =
      Stream.unfold(ExMarshal.Fixnum.parse(vars_str), fn
        nil ->
          nil

        {0, rest} ->
          {rest, nil}

        {n, <<?:, s::binary>>} ->
          {sym, r} = ExMarshal.Symbol.parse(s)
          {val, rr} = ExMarshal.parse(r)
          {{sym, val}, {n - 1, rr}}
      end)
      |> Enum.to_list()

    {value, List.last(vars)}
  end
end
