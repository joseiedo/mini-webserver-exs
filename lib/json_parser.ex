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
          nil

        [full | captures] ->
          result = List.first(captures) || full
          rest = String.trim_leading(String.slice(data, String.length(full)..-1//1))
          {key, result, rest}
      end
    end)
  end
end
