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
    new_last_msgs = Dict.put(last_msgs, channel, %{})
    {:noreply, {client, new_last_msgs}}
  end

  def handle_info({:received, message, from, channel}, {client, last_msgs}) do
    last_msg = last_msgs[channel][from]
    if String.starts_with?(message, "s/") and last_msg != nil do
      handle_regex(from, last_msg, message, channel, client)
      {:noreply, {client, last_msgs}}
    else
      new_last_msgs = if last_msg == nil do
        chan_msgs = Dict.put(last_msgs[channel], from, message)
        {:noreply, {client, %{last_msgs | channel => chan_msgs}}}
      else
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
      [_, old, new, _] = Regex.run(~r/s\/(.+?)\/([^\/]*)(\/?)/, message)
      old_regex = Regex.compile!(old)

      new_message = String.replace(last_message, old_regex, new)
      ExIrc.Client.msg(client, :privmsg, channel, "#{from}: #{new_message}")
    catch
      _ -> nil
    end
  end
end
