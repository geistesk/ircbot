defmodule MagicConchHandler do
  @moduledoc """
  This is an magic conch/random answere event handler for ranom advises
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, message, from, channel}, client) do
    if String.match?(message, ~r/!ask.*/) do
      debug "#{from} queried the magic conch in #{channel}"
      response = Application.get_env(:ircbot, :magicConchAnswers) |> Enum.random
      ExIrc.Client.msg(client, :privmsg, channel, "#{from}: #{response}.")
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
