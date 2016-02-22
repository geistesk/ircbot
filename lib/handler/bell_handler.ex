defmodule BellHandler do
  @moduledoc """
  TODO
  """
  def start_link(client, bell) do
    GenServer.start_link(__MODULE__, [client, bell])
  end

  def init([client, bell]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, bell}}
  end

  # init list for each joined channel
  def handle_info({:joined, channel}, {client, bell}) do
    # TODO restore values from config
    {:noreply, {client, Dict.put(bell, channel, [])}}
  end

  # process a /add/-request
  def handle_info({:received, "!bell add", from, channel}, {client, bell}) do
    if from in bell[channel] do
      debug "#{from} is already registered for #{channel}"
      {:noreply, {client, bell}}
    else
      # TODO add in config, too
      debug "#{from} is now registered for #{channel}"
      new_users = [from | bell[channel]]
      {:noreply, {client, %{bell | channel => new_users}}}
    end
  end

  # process a /rem/-request
  def handle_info({:received, "!bell rem", from, channel}, {client, bell}) do
    # TODO remove in config too
    debug "#{from} was removed for #{channel}"
    new_users = List.delete(bell[channel], from)
    {:noreply, {client, %{bell | channel => new_users}}}
  end

  # fire the bell
  def handle_info({:received, "!bell", from, channel}, {client, bell}) do
    debug "#{from} rang the bell in #{channel}"

    # Intersect the current users with registred users and only alert those
    clients = ExIrc.Client.channel_users(client, channel)
              |> Enum.into(HashSet.new)
    bell_users = Enum.into(bell[channel], HashSet.new)
    users = HashSet.intersection(clients, bell_users) |> HashSet.to_list

    person_txt = List.foldl(
      users, "", fn user, txt -> "#{txt} #{user}," end)
      |> String.rstrip(?,)
    ExIrc.Client.msg(
      client, :privmsg, channel,
      "Die folgenden Personen mögen sich bitte einfinden:#{person_txt}!")
    {:noreply, {client, bell}}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> "[BellHandler] " <> msg <> IO.ANSI.reset()
  end
end
