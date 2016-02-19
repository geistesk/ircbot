# defmodule DummyHandler do
#   @moduledoc """
#   This is an example event handler which does nothing :3
#   """
#   def start_link(client) do
#     GenServer.start_link(__MODULE__, [client])
#   end
#
#   def init([client]) do
#     ExIrc.Client.add_handler client, self
#     {:ok, client}
#   end
#
#   # Catch-all for messages you don't care about
#   def handle_info(_msg, state) do
#     {:noreply, state}
#   end
#
#   defp debug(msg) do
#     IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
#   end
# end
