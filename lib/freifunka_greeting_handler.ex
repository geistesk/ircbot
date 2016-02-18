defmodule FreifunkaGreetingHandler do
  @moduledoc """
  This is an example event handler does nothing :3
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:joined, channel, user}, client) do
    debug "#{user} joined #{channel}"

    # case ExIrc.Client.cmd(client, "who phi") do
    #   :ok ->
    #     debug "okay for me ._."
    #   {:error, atm} ->
    #     IO.inspect atm
    # end
    # TODO: get userinfo "somehow"

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, client) do
    {:noreply, client}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
