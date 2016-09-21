require Logger

alias ExIrc.SenderInfo

defmodule ReplaceHandler do
  @moduledoc """
  Minimal regex replacement parser for messages like s/FOO/BAR/
  """
  def start_link(client, last_msgs) do
    GenServer.start_link(__MODULE__, [client, last_msgs])
  end

  def init([client, last_msgs]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, last_msgs}}
  end

  def handle_info({:joined, channel}, {client, last_msgs}) do
    Logger.info("[ReplaceHandler] Joined #{channel} and init state")
    new_last_msgs = Dict.put(last_msgs, channel, %{})
    {:noreply, {client, new_last_msgs}}
  end

  def handle_info({:received, message, %SenderInfo{nick: from}, channel}, {client, last_msgs}) do
    last_msg = last_msgs[channel][from]
    if String.starts_with?(message, "s/") and last_msg != nil do
      handle_regex(from, last_msg, message, channel, client)
      {:noreply, {client, last_msgs}}
    else
      cond do
        last_msgs[channel] == nil ->
          # strange case which should not occur… but occured just on the Pi
          Logger.warn("[ReplaceHandler] #{channel} wasn't init yet!")
          Logger.warn("[ReplaceHandler] Init #{channel} and added #{from}s message")
          new_last_msgs = Dict.put(last_msgs, channel, %{from => message})
          {:noreply, {client, new_last_msgs}}

        last_msg == nil ->
          Logger.debug("[ReplaceHandler] #{from} wrote first message in #{channel}")
          chan_msgs = Dict.put(last_msgs[channel], from, message)
          {:noreply, {client, %{last_msgs | channel => chan_msgs}}}

        true ->
          Logger.debug("[ReplaceHandler] #{from} wrote new message in #{channel}")
          chan_msgs = %{last_msgs[channel] | from => message}
          {:noreply, {client, %{last_msgs | channel => chan_msgs}}}
      end
    end
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def handle_regex(from, last_message, message, channel, client) do
    try do
      Logger.debug("[ReplaceHandler] Try to parse #{from}s replacement..")
      [_, old, new, _] = Regex.run(~r/s\/(.+?)\/([^\/]*)(\/?)/, message)
      old_regex = Regex.compile!(old)
      Logger.debug("[ReplaceHandler] Replace-pattern are #{old}")

      if Regex.match?(old_regex, last_message) do
        Logger.debug("[ReplaceHandler] Last message fits to RegEx")
        new_message = String.replace(last_message, old_regex, new)
        ExIrc.Client.msg(client, :privmsg, channel, "#{from}: #{new_message}")
      end
    rescue
      _ -> Logger.debug("[ReplaceHandler] RegEx for #{from} failed")
    end
  end
end
