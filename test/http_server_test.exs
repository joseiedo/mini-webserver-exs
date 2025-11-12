defmodule HttpServerTest do
  use ExUnit.Case

  test "server receives and responds to HTTP message" do
    task = Task.async(fn -> HttpServer.start() end)
    :timer.sleep(100)
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 4040, [:binary, active: false])

    json = ~s({"message": "Hello World"})

    request =
      "POST / HTTP/1.1\r\n" <>
        "Host: localhost\r\n" <>
        "Content-Type: application/json\r\n" <>
        "Content-Length: #{byte_size(json)}\r\n" <>
        "\r\n" <>
        json

    :ok = :gen_tcp.send(socket, request)
    {:ok, response} = :gen_tcp.recv(socket, 0)

    assert response == "HTTP/1.1 200 OK\r\n"

    # Cleanup
    :gen_tcp.close(socket)
    Task.shutdown(task, :brutal_kill)
  end
end
