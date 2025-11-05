defmodule JsonParser do
  @tokens [
    open_bracket: ~r/^{/,
    open_list: ~r/^\[/,
    key: ~r/"([^"]+)"\s*:/,
    string: ~r/"([^"]*)",?/,
    number: ~r/[0-9]+/,
    closed_list: ~r/\]/,
    closed_bracket: ~r/}/,
    comma: ~r/,/
  ]

  def tokenize(data) do
    tokenize(data, [])
  end

  def tokenize(data, total) do
    case tokenize_one(String.trim(data)) do
      nil ->
        Enum.reverse(total)

      {key, match, rest} ->
        tokenize(rest, [{key, match} | total])
    end
  end

  defp tokenize_one(data) do
    Enum.find_value(@tokens, fn {key, regex} ->
      case Regex.run(regex, data) do
        nil ->
          false

        [full | captures] ->
          result = List.first(captures) || full
          rest = String.trim_leading(String.slice(data, String.length(full)..-1//1))
          {key, result, rest}
      end
    end)
  end

  def parse(data) do
    parse(data, nil, nil)
  end

  def parse([], _, json) do
    json
  end

  def parse(data, key, json) do
    [current | rest] = data
    {token_type, value} = current

    case token_type do
      :open_bracket ->
        if key != nil do
          Map.put(json, key, parse(rest, key, Map.new()))
        else
          parse(rest, key, Map.new())
        end

      :closed_bracket ->
        parse(rest, nil, json)

      :key ->
        parse(rest, String.to_atom(value), json)

      :number ->
        parse(rest, nil, Map.put(json, key, String.to_integer(value)))

      nil ->
        json
    end
  end
end
