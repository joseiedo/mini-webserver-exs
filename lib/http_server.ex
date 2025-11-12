defmodule HttpServer do
  require Logger

  def start do
    case :gen_tcp.listen(4040, [:binary, reuseaddr: true, active: false]) do
      {:ok, socket} ->
        handle_client(socket)

      {:error, reason} ->
        IO.puts("Deu ruim meu fi: #{reason}")
    end
  end

  defp handle_client(listenSocket) do
    case :gen_tcp.accept(listenSocket) do
      {:ok, socket} ->
        handle_request(socket)

      {:error, reason} ->
        IO.puts("Deu ruim meu fi: #{reason}")
    end
  end

  defp handle_request(client) do
    case :gen_tcp.recv(client, 0) do
      {:ok, data} -> 
        {_, body} = parse_data(data)
        json = JsonParser.read(body)
        Logger.debug("Request chegou: \n #{inspect(json)}")
      {:error, reason} -> IO.puts("Deu ruim meu fi: #{reason}")
    end

    :gen_tcp.send(client, "HTTP/1.1 200 OK\r\n")
  end

  def parse_data(data) when is_binary(data) do
      String.split(data, "\r\n\r\n", parts: 2, trim: false)
      |> case do
        [header] -> {header, ""}
        [header, body] -> {header, body}
      end
  end
end
