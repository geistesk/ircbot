defmodule DoorHandler do
  @moduledoc """
  This is an event handler which checks the doorstate for you by !door or !base
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, "!door", from, channel}, client), do:
    handle_info({:received, "!base", from, channel}, client)

  def handle_info({:received, "!base", from, channel}, client) do
    case HTTPoison.get(Application.get_env(:ircbot, :doorSpaceApi)) do
      {:ok, resp} ->
        space = SpaceApi.from_string(resp.body)
        case space.state do
          {false, _, _} ->
            ["Aktuell ist wohl niemand da."]
          {true, _, ""} ->
            ["Der Space ist gerade besetzt!"]
          {true, _, Nil} ->
            ["Der Space ist gerade besetzt!"]
          {true, _, msg} ->
            ["Der Space ist gerade besetzt.", msg]
        end
        |> Enum.each(
          &ExIrc.Client.msg(client, :privmsg, channel, from <> ": " <> &1))
      {:error, err} ->
        debug "Could not fetch Space API: #{err.reason}"
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
