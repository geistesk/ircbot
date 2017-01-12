require Logger

alias ExIrc.SenderInfo

defmodule FreifunkaGreetingHandler do
  @moduledoc """
  This is an event handler which is greeting Users from the hsmr-webirc
  (based on hostname) specially.
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self()
    {:ok, client}
  end

  def handle_info({:joined, channel, %SenderInfo{nick: nick, host: host, user: user}}, client) do
    # Check if a new joining user seems to use the webchat
    ff_host = Application.get_env(:ircbot, :freifunkaHost)
    ff_user = Application.get_env(:ircbot, :freifunkaUser)
    ff_ignr = Application.get_env(:ircbot, :freifunkaNameIgnore)
    cond do
      Regex.match?(ff_ignr, nick) ->
        Logger.info(
          "[FreifunkaGreetingHandler] #{nick} matches ignore-RegEx and won't be greeted.")
        {:noreply, client}

      ff_host == host and ff_user == user ->
        Logger.info(
          "[FreifunkaGreetingHandler] #{nick} joined from the webchat.")

        ["Hej #{nick}!" | Application.get_env(:ircbot, :freifunkaGreet)]
        |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
        {:noreply, client}

      true ->
        {:noreply, client}
    end
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, client) do
    {:noreply, client}
  end
end
