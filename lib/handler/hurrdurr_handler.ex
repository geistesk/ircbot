defmodule HurrDurrHandler do
  @moduledoc """
  This is an stupid event handler which waits for 'hurr' to reply with 'durr'
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, message, from, channel}, client) do
    pattern = :binary.compile_pattern(["hurr", "durr"])
    if String.contains?(message, pattern) do
      debug "#{from} requested a \"hurr durr\" in #{channel}"
      ExIrc.Client.msg(client, :privmsg, channel, "hurr durr~")
    end
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
