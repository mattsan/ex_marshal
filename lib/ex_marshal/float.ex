defmodule ExMarshal.Float do
  @moduledoc false

  alias ExMarshal.Fixnum

  @float_regex ~r/(?<int>-?\d+)(\.(?<dec>\d+))?(e(?<exp>-?\d+))?/

  def parse(seq, state) do
    {len, source, next_state} = Fixnum.parse(seq, state)

    case String.split_at(source, len) do
      {"nan", rest} ->
        {:nan, rest, state}

      {"inf", rest} ->
        {:inf, rest, state}

      {"-inf", rest} ->
        {:"-inf", rest, state}

      {effective, rest} ->
        %{"int" => int, "dec" => dec, "exp" => exp} =
          Regex.named_captures(@float_regex, effective)
          |> complement_dec()
          |> complement_exp()

        {String.to_float("#{int}.#{dec}e#{exp}"), rest, next_state}
    end
  end

  defp complement_dec(%{"dec" => ""} = float), do: %{float | "dec" => "0"}
  defp complement_dec(float), do: float

  defp complement_exp(%{"exp" => ""} = float), do: %{float | "exp" => "0"}
  defp complement_exp(float), do: float
end
