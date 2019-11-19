defmodule ExMarshalTest do
  use ExUnit.Case
  doctest ExMarshal

  describe "nil, true and false" do
    test "nil" do
      assert ExMarshal.load("\x04\b0") == nil
    end

    test "true" do
      assert ExMarshal.load("\x04\bT") == true
    end

    test "false" do
      assert ExMarshal.load("\x04\bF") == false
    end
  end

  describe "Fixnum / positive / a byte" do
    test "0" do
      assert ExMarshal.load("\x04\bi\x00") == 0
    end

    test "1" do
      assert ExMarshal.load("\x04\bi\x06") == 1
    end

    test "10" do
      assert ExMarshal.load("\x04\bi\x0f") == 10
    end

    test "122" do
      assert ExMarshal.load("\x04\bi\x7f") == 122
    end
  end

  describe "Fixnum / negative / a byte" do
    test "-1" do
      assert ExMarshal.load("\x04\bi\xfa") == -1
    end

    test "-10" do
      assert ExMarshal.load("\x04\bi\xf1") == -10
    end

    test "-123" do
      assert ExMarshal.load("\x04\bi\x80") == -123
    end
  end

  describe "Fixnum / positive / multibyte" do
    test "123" do
      assert ExMarshal.load("\x04\bi\x01\x7b") == 123
    end

    test "255" do
      assert ExMarshal.load("\x04\bi\x01\xff") == 255
    end

    test "256" do
      assert ExMarshal.load("\x04\bi\x02\x00\x01") == 256
    end

    test "65565" do
      assert ExMarshal.load("\x04\bi\x02\xff\xff") == 65535
    end

    test "65566" do
      assert ExMarshal.load("\x04\bi\x03\x00\x00\x01") == 65536
    end

    test "16777215" do
      assert ExMarshal.load("\x04\bi\x03\xff\xff\xff") == 16_777_215
    end

    test "16777216" do
      assert ExMarshal.load("\x04\bi\x04\x00\x00\x00\x01") == 16_777_216
    end

    test "4294967295" do
      assert ExMarshal.load("\x04\bi\x04\xff\xff\xff\xff") == 4_294_967_295
    end
  end

  describe "Fixnum / negative / multibyte" do
    test "-124" do
      assert ExMarshal.load("\x04\bi\xff\x84") == -124
    end

    test "-256" do
      assert ExMarshal.load("\x04\bi\xff\x00") == -256
    end

    test "-257" do
      assert ExMarshal.load("\x04\bi\xfe\xff\xfe") == -257
    end

    test "-65536" do
      assert ExMarshal.load("\x04\bi\xfe\x00\x00") == -65536
    end

    test "-65537" do
      assert ExMarshal.load("\x04\bi\xfd\xff\xff\xfe") == -65537
    end

    test "-16777216" do
      assert ExMarshal.load("\x04\bi\xfd\x00\x00\x00") == -16_777_216
    end
  end

  describe "Object" do
  end

  describe "Float" do
    test "0.1" do
      assert ExMarshal.load("\x04\bf\b0.1") == 0.1
    end

    test "-0.1" do
      assert ExMarshal.load("\x04\bf\t-0.1") == -0.1
    end

    test "1e100" do
      assert ExMarshal.load("\x04\bf\n1e100") == 1.0e+100
    end

    test "-1e100" do
      assert ExMarshal.load("\x04\bf\f-1e-100") == -1.0e-100
    end

    test "1.1e-100" do
      assert ExMarshal.load("\x04\bf\r1.1e-100") == 1.1e-100
    end

    test "-1.1e100" do
      assert ExMarshal.load("\x04\bf\r-1.1e100") == -1.1e+100
    end

    test "0.0" do
      assert ExMarshal.load("\x04\bf\x060") == 0.0
    end

    test "NaN" do
      assert ExMarshal.load("\x04\bf\bnan") == :nan
    end

    test "inf" do
      assert ExMarshal.load("\x04\bf\binf") == :inf
    end

    test "-inf" do
      assert ExMarshal.load("\x04\bf\t-inf") == :"-inf"
    end
  end

  describe "Bignum" do
    test "10_000_000_000" do
      assert ExMarshal.load("\x04\bl+\b\x00\xE4\vT\x02\x00") == 10_000_000_000
    end

    test "-10_000_000_000" do
      assert ExMarshal.load("\x04\bl-\b\x00\xE4\vT\x02\x00") == -10_000_000_000
    end
  end

  describe "String" do
    test "\"\"" do
      assert ExMarshal.load("\x04\b\"\x00") == ""
    end
  end

  describe "Regexp" do
    test "%r/^abc$/" do
      assert ExMarshal.load("\x04\bI/\n^abc$\x00\x06:\x06EF") == ~r/^abc$/
    end

    test "%r/abc/i" do
      assert ExMarshal.load("\x04\bI/\babc\x01\x06:\x06EF") == ~r/abc/i
    end

    test "%r/abc/x" do
      assert ExMarshal.load("\x04\bI/\babc\x02\x06:\x06EF") == ~r/abc/x
    end

    test "%r/abc/m" do
      assert ExMarshal.load("\x04\bI/\babc\x04\x06:\x06EF") == ~r/abc/m
    end

    test "%r/abc/ix" do
      assert ExMarshal.load("\x04\bI/\babc\x03\x06:\x06EF") == ~r/abc/ix
    end

    test "%r/abc/xm" do
      assert ExMarshal.load("\x04\bI/\babc\x06\x06:\x06EF") == ~r/abc/xm
    end

    test "%r/abc/im" do
      assert ExMarshal.load("\x04\bI/\babc\x05\x06:\x06EF") == ~r/abc/im
    end

    test "%r/abc/ixm" do
      assert ExMarshal.load("\x04\bI/\babc\a\x06:\x06EF") == ~r/abc/ixm
    end
  end

  describe "Array" do
    test "[1, 2, 3]" do
      assert ExMarshal.load("\x04\b[\bi\x06i\ai\b") == [1, 2, 3]
    end

    test "[123, \"abc\", :def]" do
      assert ExMarshal.load("\x04\b[\bi\x01{I\"\babc\x06:\x06ET:\bdef") == [123, "abc", :def]
    end
  end

  describe "Hash" do
  end

  describe "Hash with default value" do
  end

  describe "Struct" do
  end

  describe "Symbol" do
    test ":foo" do
      assert ExMarshal.load("\x04\b:\bfoo") == :foo
    end
  end

  describe "Symbol (link)" do
  end

  describe "instance variable" do
    test "\"foo\"" do
      assert ExMarshal.load("\x04\bI\"\bfoo\x06:\x06ET") == "foo"
    end
  end

  describe "link" do
  end
end
