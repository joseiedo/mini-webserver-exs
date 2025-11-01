defmodule JsonParserTest do
  use ExUnit.Case

  test "should map tokens correctly when simple json" do
    input = "{\n \"foo\": 1\n}"
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: "{",
      key: "foo",
      number: "1",
      closed_bracket: "}"
    ]

    assert expected == result
  end

  test "should map tokens correcly when json with nested json" do
    input = "{\n \"foo\": { \"tuga\": 2 }\n}"
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: "{",
      key: "foo",
      open_bracket: "{",
      key: "tuga",
      number: "2",
      closed_bracket: "}",
      closed_bracket: "}"
    ]

    assert expected == result
  end

  test "should map tokens correcly when json with list" do
    input = "{\n \"foo\": [ \"tuga\", 2 ]\n}"
    result = JsonParser.tokenize(input)

    IO.inspect(result)

    expected = [
      open_bracket: "{",
      key: "foo",
      open_list: "[",
      string: "tuga",
      number: "2",
      closed_list: "]",
      closed_bracket: "}"
    ]

    assert expected == result
  end
end
