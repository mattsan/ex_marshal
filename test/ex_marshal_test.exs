defmodule ExMarshalTest do
  use ExUnit.Case
  doctest ExMarshal

  test "greets the world" do
    assert ExMarshal.hello() == :world
  end
end
