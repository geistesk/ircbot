require Logger

defmodule LoginHandler do
  @moduledoc """
  This is an example event handler that listens for login events and then
  joins the appropriate channels. We actually need this because we can't
  join channels until we've waited for login to complete. We could just
  attempt to sleep until login is complete, but that's just hacky. This
  as an event handler is a far more elegant solution.
  """
  def start_link(client, channels) do
    GenServer.start_link(__MODULE__, [client, channels])
  end

  def init([client, channels]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, channels}}
  end

  def handle_info(:logged_in, state = {client, channels}) do
    Logger.info("[LoginHandler] Logged in to server")
    channels |> Enum.map(&ExIrc.Client.join client, &1)
    {:noreply, state}
  end

  def handle_info({:joined, channel}, client) do
    Logger.info("[LoginHandler] Joined #{channel}")
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
