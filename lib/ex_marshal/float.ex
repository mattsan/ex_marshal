defmodule ExMarshal.Float do
  @moduledoc false

  defstruct [:int, :dec, :exp]

  @type t :: %__MODULE__{}

  @float_regex ~r/(?<int>-?\d+)(\.(?<dec>\d+))?(e(?<exp>-?\d+))?/

  @spec parse(binary(), map()) :: any()
  def parse(seq, state) do
    {len, source, next_state} = ExMarshal.Fixnum.parse(seq, state)

    case String.split_at(source, len) do
      {"nan", rest} ->
        {:nan, rest, state}

      {"inf", rest} ->
        {:inf, rest, state}

      {"-inf", rest} ->
        {:"-inf", rest, state}

      {effective, rest} ->
        %ExMarshal.Float{int: int, dec: dec, exp: exp} =
          Regex.named_captures(@float_regex, effective)
          |> Enum.reduce(%ExMarshal.Float{}, fn {key, value}, float ->
            %{float | String.to_existing_atom(key) => value}
          end)
          |> complement_dec()
          |> complement_exp()

        {String.to_float("#{int}.#{dec}e#{exp}"), rest, next_state}
    end
  end

  @spec complement_dec(map()) :: t()
  defp complement_dec(%{dec: ""} = float), do: %{float | dec: "0"}
  defp complement_dec(float), do: float

  @spec complement_exp(map()) :: t()
  defp complement_exp(%{exp: ""} = float), do: %{float | exp: "0"}
  defp complement_exp(float), do: float
end
