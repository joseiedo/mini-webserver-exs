defmodule JsonParser do
  def tokenize(<<>>, tokens), do: Enum.reverse(tokens)

  def tokenize(<<char, rest::binary>> = data, tokens) do
    case char do
      ?" ->
        {string, remaining} = parse_string(rest)
        tokenize(remaining, [{:string, string} | tokens])

      c when c in ?0..?9 ->
        tokenize(rest, [{:number, String.to_integer(<<c>>)} | tokens])

      c when c in [?{, ?}, ?[, ?], ?:, ?,] ->
        type =
          case c do
            ?{ -> :open_bracket
            ?} -> :closed_bracket
            ?[ -> :open_list
            ?] -> :closed_list
            ?: -> :colon
            ?, -> :comma
          end

        tokenize(rest, [{type, nil} | tokens])

      c when c in [?\s, ?\n, ?\t, ?\r] ->
        tokenize(rest, tokens)

      _ ->
        raise ArgumentError, "Unexpected character: #{inspect(<<char>>)} in #{inspect(data)}"
    end
  end

  def tokenize(<<json::binary>>), do: tokenize(json, [])

  def parse_string(data) do
    case :binary.match(data, "\"") do
      {pos, _len} ->
        result = :binary.part(data, 0, pos)
        remaining = :binary.part(data, pos + 1, byte_size(data) - pos - 1)
        {result, remaining}

      :nomatch ->
        {data, <<>>}
    end
  end

  def parse(tokens), do: parse(tokens, nil, %{}) |> elem(1)

  defp parse([], _, json), do: {[], json}

  defp parse([{token_type, value} | rest], key, json) do
    case token_type do
      :open_bracket ->
        {remaining, inner} = parse(rest, nil, %{})
        updated = if key, do: Map.put(json, key, inner), else: inner
        parse(remaining, nil, updated)

      :closed_bracket ->
        {rest, json}

      :open_list ->
        {remaining, value} = parse_list(rest, [])

        # If this was a real parser, probably I would need to change things.
        # I'm happy this is not the case :)
        if key do
          parse(remaining, nil, Map.put(json, key, value))
        else
          {[], value}
        end

      :comma ->
        {rest, json}

      :number ->
        parse(rest, nil, Map.put(json, key, value))

      :string ->
        [next_token | remaining] = rest

        case next_token do
          {:colon, nil} -> parse(remaining, String.to_atom(value), json)
          _ -> parse(rest, nil, Map.put(json, key, value))
        end

      _ ->
        raise("Unnexpected token #{token_type} when parsing json")
    end
  end

  defp parse_list([], list), do: {[], list}

  defp parse_list([{token_type, value} | rest], list) do
    case token_type do
      :open_bracket ->
        {rest, object} = parse(rest, nil, %{})
        parse_list(rest, [object | list])

      :open_list ->
        {remaining, inner_list} = parse_list(rest, [])
        parse_list(remaining, [inner_list | list])

      :closed_list ->
        {rest, Enum.reverse(list)}

      :comma ->
        parse_list(rest, list)

      type when type in [:string, :number] ->
        parse_list(rest, [value | list])

      _ ->
        raise("Unnexpected token #{token_type} when parsing list")
    end
  end
end
