defmodule FreifunkaGreetingHandler do
  @moduledoc """
  This is an event handler which is greeting Users from the hsmr-webirc
  (based on hostname) specially.
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:joined, channel, user}, client) do
    # Asking who the new user is…
    # Response will be consumed in the next function
    debug "#{user} has joined #{channel}. Queryin /who #{user}"

    ExIrc.Client.cmd(client, "who #{user}")
    {:noreply, client}
  end

  def handle_info({:unrecognized, "352", %IrcMessage{:cmd => "352", :args => resp}}, client) do
    # 352 is the magic number for an /who-Response which data
    # The {5th,3rd,1st} element in the resulting string is the {nick,host,channel}name

    who = Enum.map(0..7, &"e" <> Integer.to_string(&1) |> String.to_atom)
          |> Enum.zip(resp)
    {channel, host, nick, name} = {who[:e1], who[:e3], who[:e5], who[:e7]}

    # If the user from the webchat than let's grett :3
    if nick != "" and host == Application.get_env(:ircbot, :freifunkaHost) and
       String.match?(name, Application.get_env(:ircbot, :freifunkaName)) do
      debug "Received who-response for #{nick} with matching hostname."
      ["Hej #{nick}!" | Application.get_env(:ircbot, :freifunkaGreet)]
      |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
    end

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
