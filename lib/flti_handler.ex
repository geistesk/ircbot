import Integer, only: [is_even: 1]

defmodule FltiHandler do
  @moduledoc """
  This event handler says when there are the next FTLI*-times
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  def handle_info({:received, "!flti", from, channel}, client) do
    debug "#{from} asked in #{channel} for FLTI*"

    {_, week} = :calendar.iso_week_number
    weekday = case is_even(week) do
      true -> "Sonntag"
      false -> "Samstag"
    end

    ExIrc.Client.msg(
      client, :privmsg, channel,
      "#{from}: Die FTLI*-Zeiten in dieser Woche sind an einem #{weekday}.")

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
