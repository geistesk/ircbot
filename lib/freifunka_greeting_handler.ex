defmodule FreifunkaGreetingHandler do
  @moduledoc """
  This is an example event handler does nothing :3
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:joined, _channel, user}, client) do
    # Asking who the new user is…
    # Response will be consumed in the next function

    ExIrc.Client.cmd(client, "who #{user}")
    {:noreply, client}
  end

  def handle_info({:unrecognized, "352", %IrcMessage{:cmd => "352", :args => resp}}, client) do
    # 352 is the magic number for an /who-Response which data
    # The {5th,3rd,1st} element in the resulting string is the {nick,host,channel}name

    {nick, host, channel} = {
      Enum.at(resp, 5, ""), Enum.at(resp, 3, ""), Enum.at(resp, 1) }

    # If the user from the webchat than let's grett :3
    if nick != "" and host == "2001:4dd0:fc15:cafe:208:54ff:fe55:1498" do
      ["Hej #{nick}!",
       "Es freut uns, dass du es über den Webchat zu uns geschafft hast.",
       "Falls du Fragen hast, stelle sie einfach. Bitte bedenke, dass es aber etwas dauer kann, bis wer antwortet…"]
      |> Enum.each(fn txt -> ExIrc.Client.msg(client, :privmsg, channel, txt) end)
    end

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, client) do
    # IO.inspect msg
    {:noreply, client}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
