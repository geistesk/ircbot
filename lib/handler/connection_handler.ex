require Logger

defmodule ConnectionHandler do
  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    {:ok, init_connection(state)}
  end

  def init_connection(state) do
    ExIrc.Client.add_handler state.client, self()
    if state.ssl do
      ExIrc.Client.connect_ssl! state.client, state.host, state.port
    else
      ExIrc.Client.connect! state.client, state.host, state.port
    end
    state
  end

  def handle_info({:connected, server, port}, state) do
    Logger.info("[ConnectionHandler] Connected to #{server}:#{port}")
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  # Thanks ZNC...
  def handle_info(
    {:received,
     "You are currently disconnected from IRC. Use 'connect' to reconnect.",
     "*status"},
    state) do
    Logger.warn("[ConnectionHandler] ZNC wants a reconnection!")
    ExIrc.Client.msg(state.client, :privmsg, "*status", "connect")
    {:noreply, state}
  end

  # Just stop the bot in case of a disconnection
  # The init-System or a simple bash-loop should just bring it up after n secs
  def handle_info(:disconnected, _state) do
    Logger.warn("[ConnectionHandler] Disconnected from server!")
    Logger.warn("[ConnectionHandler] Everything is lost ;_;")
    Logger.warn("[ConnectionHandler] Shutting down ircbot")
    System.halt(0)
    {:noreply, nil}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    # IO.inspect msg
    {:noreply, state}
  end
end
