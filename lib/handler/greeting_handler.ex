defmodule GreetingHandler do
  @moduledoc """
  This is an example event handler which does nothing :3
  """
  def start_link(client, chan_users) do
    GenServer.start_link(__MODULE__, [client, chan_users])
  end

  def init([client, chan_users]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, chan_users}}
  end

  def handle_info({:joined, channel}, {client, chan_users}) do
    debug "Storing current users from #{channel} in state"
    chan_users = Dict.put_new(
      chan_users,
      channel,
      ExIrc.Client.channel_users(client, channel))
    {:noreply, {client, chan_users}}
  end

  def handle_info({:joined, channel, user}, {client, chan_users}) do
    if user in chan_users[channel] do
      debug "#{user} returned to #{channel}"
      ExIrc.Client.msg(client, :privmsg, channel,
        "#{user}: " <> Application.get_env(:ircbot, :greetingOld))
        {:noreply, {client, chan_users}}
    else
      debug "#{user} is new to #{channel}"
      ExIrc.Client.msg(client, :privmsg, channel,
        "#{user}: " <> Application.get_env(:ircbot, :greetingNew))
      new_users = [user | chan_users[channel]]
      {:noreply, {client, %{chan_users | channel => new_users}}}
    end
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
