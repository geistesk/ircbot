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

  def handle_info({:joined, channel, user}, client) do
    # Asking who the new user is…
    # Response will be consumed in the next function

    ExIrc.Client.cmd(client, "who #{user}")
    {:noreply, client}
  end

  def handle_info({:unrecognized, "352", %IrcMessage{:cmd => "352", :args => resp}}, client) do
    # 352 is the magic number for an /who-Response which data
    # The {fifth,third} element in the resulting string is the {nick,host}name

    {nick, host} = { Enum.at(resp, 5, ""), Enum.at(resp, 3, "") }
    debug "#{nick} @ #{host}"
    # TODO

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
