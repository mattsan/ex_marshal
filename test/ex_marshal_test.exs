defmodule ExMarshalTest do
  use ExUnit.Case
  doctest ExMarshal

  defp marshal_dump(value) do
    port =
      case value do
        {:ruby, ruby_value} ->
          Port.open(
            {:spawn, ~s[ruby -e 'print(Marshal.dump(#{ruby_value}))']},
            [:binary]
          )

        _ ->
          Port.open(
            {:spawn, ~s[ruby -e 'print(Marshal.dump(#{Macro.to_string(value)}))']},
            [:binary]
          )
      end

    receive do
      {^port, {:data, data}} ->
        data
    after
      1_000 ->
        :timeout
    end
  end

  setup context do
    [marshaled: marshal_dump(context.source)]
  end

  describe "nil, true and false" do
    @tag source: nil
    test "nil", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == nil
    end

    @tag source: true
    test "true", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == true
    end

    @tag source: false
    test "false", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == false
    end
  end

  describe "Fixnum / positive / a byte" do
    @tag source: 0
    test "0", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 0
    end

    @tag source: 1
    test "1", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 1
    end

    @tag source: 10
    test "10", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 10
    end

    @tag source: 122
    test "122", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 122
    end
  end

  describe "Fixnum / negative / a byte" do
    @tag source: -1
    test "-1", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -1
    end

    @tag source: -10
    test "-10", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -10
    end

    @tag source: -123
    test "-123", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -123
    end
  end

  describe "Fixnum / positive / multibyte" do
    @tag source: 123
    test "123", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 123
    end

    @tag source: 255
    test "255", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 255
    end

    @tag source: 256
    test "256", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 256
    end

    @tag source: 65535
    test "65535", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 65535
    end

    @tag source: 65536
    test "65536", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 65536
    end

    @tag source: 16_777_215
    test "16777215", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 16_777_215
    end

    @tag source: 16_777_216
    test "16777216", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 16_777_216
    end

    @tag source: 4_294_967_295
    test "4294967295", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 4_294_967_295
    end
  end

  describe "Fixnum / negative / multibyte" do
    @tag source: -124
    test "-124", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -124
    end

    @tag source: -256
    test "-256", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -256
    end

    @tag source: -257
    test "-257", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -257
    end

    @tag source: -65536
    test "-65536", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -65536
    end

    @tag source: -65537
    test "-65537", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -65537
    end

    @tag source: -16_777_216
    test "-16777216", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -16_777_216
    end
  end

  describe "Object" do
  end

  describe "Float" do
    @tag source: 0.1
    test "0.1", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 0.1
    end

    @tag source: -0.1
    test "-0.1", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -0.1
    end

    @tag source: {:ruby, "1e100"}
    test "1e100", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 1.0e+100
    end

    @tag source: {:ruby, "-1e100"}
    test "-1e100", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -1.0e100
    end

    @tag source: {:ruby, "1.1e-100"}
    test "1.1e-100", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 1.1e-100
    end

    @tag source: {:ruby, "-1.1e100"}
    test "-1.1e100", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -1.1e+100
    end

    @tag source: 0.0
    test "0.0", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 0.0
    end

    @tag source: {:ruby, "Float::NAN"}
    test "NaN", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == :nan
    end

    @tag source: {:ruby, "Float::INFINITY"}
    test "inf", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == :inf
    end

    @tag source: {:ruby, "-Float::INFINITY"}
    test "-inf", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == :"-inf"
    end
  end

  describe "Bignum" do
    @tag source: 10_000_000_000
    test "10_000_000_000", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == 10_000_000_000
    end

    @tag source: -10_000_000_000
    test "-10_000_000_000", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == -10_000_000_000
    end
  end

  describe "String" do
    @tag source: ""
    test "\"\"", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ""
    end
  end

  describe "Regexp" do
    @tag source: {:ruby, "%r/^abc$/"}
    test "%r/^abc$/", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/^abc$/
    end

    @tag source: {:ruby, "%r/abc/i"}
    test "%r/abc/i", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/i
    end

    @tag source: {:ruby, "%r/abc/x"}
    test "%r/abc/x", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/x
    end

    @tag source: {:ruby, "%r/abc/m"}
    test "%r/abc/m", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/m
    end

    @tag source: {:ruby, "%r/abc/ix"}
    test "%r/abc/ix", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/ix
    end

    @tag source: {:ruby, "%r/abc/xm"}
    test "%r/abc/xm", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/xm
    end

    @tag source: {:ruby, "%r/abc/im"}
    test "%r/abc/im", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/im
    end

    @tag source: {:ruby, "%r/abc/ixm"}
    test "%r/abc/ixm", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == ~r/abc/ixm
    end
  end

  describe "Array" do
    @tag source: [1, 2, 3]
    test "[1, 2, 3]", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == [1, 2, 3]
    end

    @tag source: [123, "abc", :def]
    test "[123, \"abc\", :def]", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == [123, "abc", :def]
    end
  end

  describe "Hash" do
    @tag source: {:ruby, ~S'{a: 1, "b" => "2", ["c"] => [3]}'}
    test ~S"{a: 1, 'b' => '2', ['c'] => [3]}", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == %{:a => 1, "b" => "2", ["c"] => [3]}
    end
  end

  describe "Hash with default value" do
    @tag source: {:ruby, "Hash.new(0)"}
    test "Hash.new(0)", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == %{}
    end

    @tag source: {:ruby, "Hash.new(0).tap {|h| h.store(:a, 1) }"}
    test "Hash.new(0).tap {|h| h.store(:a, 1) }", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == %{a: 1}
    end
  end

  describe "Struct" do
  end

  describe "Symbol" do
    @tag source: :foo
    test ":foo", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == :foo
    end
  end

  describe "Symbol (link)" do
    @tag source: [:foo, :foo]
    test "[:foo, :foo]", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == [:foo, :foo]
    end

    @tag source: [:foo, :foo, :bar, :foo, :bar, :baz]
    test "[:foo, :foo, :bar, :foo, :bar, :baz]", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == [:foo, :foo, :bar, :foo, :bar, :baz]
    end

    @tag source: {:ruby, "[{a: :c}, {b: :b}, {c: :a}]"}
    test "[{a: :c}, {b: :b}, {c: :a}]", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == [%{a: :c}, %{b: :b}, %{c: :a}]
    end
  end

  describe "instance variable" do
    @tag source: "foo"
    test "\"foo\"", %{marshaled: marshaled} do
      assert ExMarshal.load(marshaled) == "foo"
    end
  end

  describe "link" do
  end
end
