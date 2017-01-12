require Logger

alias ExIrc.SenderInfo

defmodule HelpHandler do
  @moduledoc """
  This is an magic conch/random answere event handler for ranom advises
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self()
    {:ok, client}
  end

  def handle_info({:received, "!help", %SenderInfo{nick: from}, channel}, client) do
    Logger.info("[HelpHandler] #{from} queried help in #{channel}")
    Application.get_env(:ircbot, :helpMessage)
    |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
