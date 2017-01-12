require Logger

alias ExIrc.SenderInfo

defmodule UrlHandler do
  @moduledoc """
  This is an event handler which checks messages for URLs and tries to get
  the title of it in case of an HTML-page.
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self()
    {:ok, client}
  end

  def handle_info({:received, message, %SenderInfo{nick: from}, channel}, client) do
    try do
      case Regex.run(~r/(http[s]?:\/\/\S+)/, message) do
        [url, url] ->
          Logger.debug("[UrlHandler] Parsed an URL from #{from}: #{url}")
          resp = HTTPoison.get!(url)
          content_type = Enum.filter(
            resp.headers, fn {k, _v} -> k == "Content-Type" end)
          [{"Content-Type", val}] = content_type
          if String.contains?(val, "text/html") do
            [_, title] = Regex.run(~r/<title[ \S]*>(.+)<\/title>/im, resp.body)
            ExIrc.Client.msg(
              client, :notice, channel, "[URL-Title] " <> <<2>> <> title)
          end
        nil -> nil
        _   -> nil
      end
    rescue
      _ -> Logger.debug("[UrlHandler] Something failed ¯\\_(ツ)_/¯")
    end
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
