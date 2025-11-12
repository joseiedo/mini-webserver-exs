defmodule JsonParserTest do
  use ExUnit.Case

  test "should map booleans correctly" do
    input = ~s({
      "foo": true,
      "bar": false
    })
    expected = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      boolean: true,
      comma: nil,
      string: "bar",
      colon: nil,
      boolean: false,
      closed_bracket: nil,
    ]

    result = JsonParser.tokenize(input)

    assert expected == result
  end

  test "should map tokens correctly when simple json" do
    input = ~s({
      "foo": 1
    })
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      number: 1,
      closed_bracket: nil
    ]

    assert expected == result
  end

  test "should map tokens correctly when json with nested json" do
    input = ~s({
      "foo": { 
        "tuga": 2,
        "fuga": 2
      }
    })
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      open_bracket: nil,
      string: "tuga",
      colon: nil,
      number: 2,
      comma: nil,
      string: "fuga",
      colon: nil,
      number: 2,
      closed_bracket: nil,
      closed_bracket: nil
    ]

    assert expected == result
  end

  test "should map tokens correctly when json with list" do
    input = ~s({
      "foo": [ "tuga", 2 ]
    })
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      open_list: nil,
      string: "tuga",
      comma: nil,
      number: 2,
      closed_list: nil,
      closed_bracket: nil
    ]

    assert expected == result
  end

  test "should map tokens correctly when json with nested lists" do
    input = ~s({
      "foo": [1, [2, 3]]
    })
    result = JsonParser.tokenize(input)

    expected = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      open_list: nil,
      number: 1,
      comma: nil,
      open_list: nil,
      number: 2,
      comma: nil,
      number: 3,
      closed_list: nil,
      closed_list: nil,
      closed_bracket: nil
    ]

    assert expected == result
  end

  test "should parse list of tokens correctly to 1 level map" do
    input = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      number: 1,
      closed_bracket: nil
    ]

    result = JsonParser.parse(input)
    expected = %{foo: 1}

    assert expected == result
  end

  test "should parse deeply nested json with 5 levels correctly" do
    input = [
      open_bracket: nil,
      string: "a",
      colon: nil,
      open_bracket: nil,
      string: "a1",
      colon: nil,
      number: 1,
      string: "b",
      colon: nil,
      open_bracket: nil,
      string: "c",
      colon: nil,
      open_bracket: nil,
      string: "d",
      colon: nil,
      open_bracket: nil,
      string: "e",
      colon: nil,
      number: 42,
      closed_bracket: nil,
      closed_bracket: nil,
      closed_bracket: nil,
      closed_bracket: nil,
      closed_bracket: nil
    ]

    result = JsonParser.parse(input)

    expected = %{
      a: %{
        a1: 1,
        b: %{
          c: %{
            d: %{
              e: 42
            }
          }
        }
      }
    }

    assert expected == result
  end

  test "should parse list of tokens correctly when json list with 1 level of depth" do
    input = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      open_list: nil,
      string: "bar",
      comma: nil,
      number: 2,
      closed_list: nil,
      closed_bracket: nil
    ]

    result = JsonParser.parse(input)

    expected = %{
      foo: ["bar", 2]
    }

    assert expected == result
  end

  test "should parse list of tokens correctly when json has nested lists" do
    input = [
      open_bracket: nil,
      string: "foo",
      colon: nil,
      open_list: nil,
      open_list: nil,
      number: 1,
      comma: nil,
      number: 2,
      closed_list: nil,
      comma: nil,
      number: 3,
      closed_list: nil,
      closed_bracket: nil
    ]

    result = JsonParser.parse(input)

    expected = %{
      foo: [
        [1, 2],
        3
      ]
    }

    assert expected == result
  end

  test "should parse list of tokens correctly when json list contains objects" do
    input = [
      open_list: nil,
      open_bracket: nil,
      string: "foo",
      colon: nil,
      number: 1,
      closed_bracket: nil,
      comma: nil,
      open_bracket: nil,
      string: "bar",
      colon: nil,
      number: 2,
      closed_bracket: nil,
      closed_list: nil
    ]

    result = JsonParser.parse(input)

    expected = [
      %{foo: 1},
      %{bar: 2}
    ]

    assert expected == result
  end

  test "should tokenize numbers with more than one digit" do
    json = ~s({
      "a": 123,
      "b": 999
    })

    expected = [
      open_bracket: nil,
      string: "a",
      colon: nil,
      number: 123,
      comma: nil,
      string: "b",
      colon: nil,
      number: 999,
      closed_bracket: nil
    ]

    result = JsonParser.tokenize(json)

    assert expected == result
  end

  test "should work even with invalid comma because I don't know how to throw an error" do
    json = ~s({
      "user": {
        "email": "email@test.com",
        "id": 1,
        "potato": [ {} ],
        "foo": [1, 2, 3, 4],
      }
    })
    tokens = JsonParser.tokenize(json)
    map = JsonParser.parse(tokens)

    expected = %{
      user: %{
        email: "email@test.com",
        id: 1,
        potato: [%{}],
        foo: [1, 2, 3, 4]
      }
    }

    assert expected == map

    IO.inspect(map)
  end
end
