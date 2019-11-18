defmodule ExMarshal.Float do
  alias ExMarshal.Fixnum

  def parse(seq) do
    {len, s} = Fixnum.parse(seq)

    case String.split_at(s, len) do
      {"nan", rest} ->
        {:nan, rest}

      {"inf", rest} ->
        {:inf, rest}

      {"-inf", rest} ->
        {:"-inf", rest}

      {effective, rest} ->
        %{"int" => int, "dec" => dec, "exp" => exp} =
          Regex.named_captures(~r/(?<int>-?\d+)(\.(?<dec>\d+))?(e(?<exp>-?\d+))?/, effective)
          |> complement_dec()
          |> complement_exp()

        {String.to_float("#{int}.#{dec}e#{exp}"), rest}
    end
  end

  defp complement_dec(%{"dec" => ""} = float), do: %{float | "dec" => "0"}
  defp complement_dec(float), do: float

  defp complement_exp(%{"exp" => ""} = float), do: %{float | "exp" => "0"}
  defp complement_exp(float), do: float
end
