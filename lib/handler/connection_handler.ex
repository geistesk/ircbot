defmodule ConnectionHandler do
  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    {:ok, init_connection(state)}
  end

  def init_connection(state) do
    ExIrc.Client.add_handler state.client, self
    if state.ssl do
      ExIrc.Client.connect_ssl! state.client, state.host, state.port
    else
      ExIrc.Client.connect! state.client, state.host, state.port
    end
    state
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    debug "Connection to #{state.server} was closed. Reconnecting in 30 seconds"
    # IO.inspect state
    # :timer.sleep(30_000)
    {:ok, state}
  end

  # Thanks ZNC...
  def handle_info(
    {:received,
     "You are currently disconnected from IRC. Use 'connect' to reconnect.",
     "*status"},
    state) do
    debug "ZNC want's reconnection.."
    ExIrc.Client.msg(state.client, :privmsg, "*status", "connect")
    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    # IO.inspect msg
    {:noreply, state}
  end

  def terminate(_, state) do
    # Quit the channel and close the underlying client connection when the process is terminating
    # ExIrc.Client.quit state.client, "Goodbye, cruel world."
    # ExIrc.Client.stop! state.client
    IO.debug state
    :ok
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
