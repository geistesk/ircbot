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

  # Write config to file. Will be triggered after changes (join, add, rem)
  def export_config(bell, filename) do
    {:ok, file} = File.open(filename, [:write])
    {:ok, json} = JSON.encode(bell)
    :ok = IO.binwrite(file, json)
    :ok = File.close(file)
  end

  # Returns a bell-state-map based on a given file
  def json_to_map(filename) do
    if File.exists?(filename) do
      {:ok, bell} = File.read!(filename) |> JSON.decode
      bell
    else
      %{}
    end
  end

  # init list for each joined channel
  def handle_info({:joined, channel}, {client, bell}) do
    if channel in Map.keys(bell) do
      {:noreply, {client, bell}}
    else
      new_bell = Dict.put(bell, channel, [])
      export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
      {:noreply, {client, new_bell}}
    end
  end

  # process a /add/-request
  def handle_info({:received, "!bell add", from, channel}, {client, bell}) do
    if from in bell[channel] do
      debug "#{from} is already registered for #{channel}"
      {:noreply, {client, bell}}
    else
      debug "#{from} is now registered for #{channel}"
      new_bell = %{bell | channel => [from | bell[channel]]}
      export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
      {:noreply, {client, new_bell}}
    end
  end

  # process a /rem/-request
  def handle_info({:received, "!bell rem", from, channel}, {client, bell}) do
    debug "#{from} was removed for #{channel}"
    new_bell = %{bell | channel => List.delete(bell[channel], from)}
    export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
    {:noreply, {client, new_bell}}
  end

  def handle_info({:received, "!bell check", from, channel}, {client, bell}) do
    ExIrc.Client.msg(client, :privmsg, channel,
      "#{from}: Du bist " <>
      if from in bell[channel] do
        "aktuell"
      else
        "nicht"
      end <>
      " im Bell für #{channel} registriert.")
    {:noreply, {client, bell}}
  end

  # fire the bell
  def handle_info({:received, "!bell", from, channel}, {client, bell}) do
    debug "#{from} rang the bell in #{channel}"

    # Intersect the current users with registred users and only alert those
    clients = ExIrc.Client.channel_users(client, channel)
              |> Enum.into(HashSet.new)
    bell_users = Enum.into(bell[channel], HashSet.new)
    users = HashSet.intersection(clients, bell_users) |> HashSet.to_list

    person_txt = List.foldl(users, "", fn user, txt -> "#{txt} #{user}," end)
                 |> String.rstrip(?,)
    ExIrc.Client.msg(
      client, :privmsg, channel,
      if Enum.count(users) > 0 do
        "Die folgenden Personen mögen sich bitte einfinden:#{person_txt}!"
      else
        "Leider ist niemand da, der sich angesprochen fühlt…"
      end
    )
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
