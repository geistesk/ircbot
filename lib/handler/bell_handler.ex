require Logger

alias ExIrc.SenderInfo

defmodule BellHandler do
  @moduledoc """
  A simple handler to notify some pre-registered users
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
    try do
      Logger.info("[BellHandler] Try to export config to #{filename}")
      {:ok, file} = File.open(filename, [:write])
      {:ok, json} = JSON.encode(bell)
      :ok = IO.binwrite(file, json)
      :ok = File.close(file)
    rescue
      _ -> Logger.warn("[BellHandler] Export failed!")
    end
  end

  # Returns a bell-state-map based on a given file
  def json_to_map(filename) do
    if File.exists?(filename) do
      Logger.info("[BellHandler] Try to read config from #{filename}")
      try do
        {:ok, bell} = File.read!(filename) |> JSON.decode
        bell
      rescue
        _ -> Logger.warn("[BellHandler] Failed to read config.")
      end
    else
      Logger.warn(
        "[BellHandler] #{filename} does not exists. Return empty config")
      %{}
    end
  end

  # init list for each joined channel
  def handle_info({:joined, channel}, {client, bell}) do
    if channel in Map.keys(bell) do
      {:noreply, {client, bell}}
    else
      Logger.info("[BellHandler] Adding #{channel} to state")
      new_bell = Dict.put(bell, channel, [])
      export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
      {:noreply, {client, new_bell}}
    end
  end

  # process a /add/-request
  def handle_info({:received, "!bell add", %SenderInfo{nick: from}, channel}, {client, bell}) do
    if from in bell[channel] do
      Logger.info("[BellHandler] #{from} is already registered for #{channel}")
      {:noreply, {client, bell}}
    else
      Logger.info("[BellHandler] #{from} is now registered for #{channel}")
      new_bell = %{bell | channel => [from | bell[channel]]}
      export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
      {:noreply, {client, new_bell}}
    end
  end

  # process a /rem/-request
  def handle_info({:received, "!bell rem", %SenderInfo{nick: from}, channel}, {client, bell}) do
    Logger.info("[BellHandler] #{from} was removed for #{channel}")
    new_bell = %{bell | channel => List.delete(bell[channel], from)}
    export_config(new_bell, Application.get_env(:ircbot, :bellConfigFile))
    {:noreply, {client, new_bell}}
  end

  def handle_info({:received, "!bell check", %SenderInfo{nick: from}, channel}, {client, bell}) do
    Logger.info("[BellHandler] #{from} checkd own status")
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

  def handle_info({:received, "!bell help", _from, channel}, {client, bell}) do
    ["!bell        Alle für #{channel} hinzugefügten Personen werden alamiert.",
     "!bell add    Fügt Dich für Benachrichtigungen aus #{channel} hinzu",
     "!bell rem    Entfernt Dich für #{channel} von Benachrichtigungen",
     "!bell check  Gibt Dir zurück, ob Du für #{channel} benachrichtigt wirst",
     "!bell help   Dieser Text…"]
    |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
    {:noreply, {client, bell}}
  end

  # fire the bell
  def handle_info({:received, "!bell", %SenderInfo{nick: from}, channel}, {client, bell}) do
    Logger.info("[BellHandler] #{from} rang the bell in #{channel}")

    # Intersect the current users with registred users and only alert those
    clients = ExIrc.Client.channel_users(client, channel)
              |> Enum.into(HashSet.new)
    bell_users = Enum.into(bell[channel], HashSet.new)
    users = HashSet.intersection(clients, bell_users)
            |> HashSet.to_list
            |> Enum.sort

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
end
