require Logger

alias ExIrc.SenderInfo

defmodule DoorHandler do
  @moduledoc """
  This is an event handler which does door-things™
  !base, !door use the Space API
  !flti calculates the next FLTI*-times
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self()
    {:ok, client}
  end

  def handle_info({:received, "!flti", %SenderInfo{nick: from}, channel}, client) do
    Logger.info("[DoorHandler] #{from} asked for FLTI* in #{channel}")

    #{_, week}   = :calendar.iso_week_number
    #{date, _}   = :calendar.local_time
    #day_of_week = :calendar.day_of_the_week(date)
    #weekday     = 7 - rem(week, 2) # Sonntag, falls gerade | Samstag, sonst
    #
    #message = "#{from}: Die FTLI*-Zeiten sind " <> case {day_of_week, weekday} do
    #  {x, x} ->                 "heute"
    #  {x, y} when y - x == 1 -> "morgen"
    #  {7, 6} ->                 "nächste Woche Sonntag"
    #  {_, 6} ->                 "diesen Samstag"
    #  {_, 7} ->                 "diesen Sonntag"
    #end <> " von 16:00 bis 20:00 Uhr."
    message = "#{from}: Die FTLI*-Zeiten sind zurzeit ausgesetzt, https://hsmr.cc/Main/FLTI"
    ExIrc.Client.msg(client, :privmsg, channel, message)

    {:noreply, client}
  end

  def handle_info({:received, "!base", %SenderInfo{nick: from}, channel}, client) do
    Logger.info("[DoorHandler] #{from} asked for basestate in #{channel}")

    case HTTPoison.get(Application.get_env(:ircbot, :doorSpaceApi)) do
      {:ok, resp} ->
        space = SpaceApi.from_string(resp.body)
        doors = space.raw_json["sensors"]["door_locked"]

        message = Enum.map(doors,
          fn door ->
            name  = door["location"]
            state = if door["value"], do: "closed", else: "open"
            "#{name} is #{state}"
          end)
        |> Enum.join(", ")

        ExIrc.Client.msg(client, :privmsg, channel, "#{from}: #{message}")

        #case space.state do
        #  {false, _, _} ->
        #    ["Aktuell ist wohl niemand da."]
        #  {true, _, ""} ->
        #    ["Der Space ist gerade besetzt!"]
        #  {true, _, msg} ->
        #    ["Der Space ist gerade besetzt.", msg]
        #end
        #|> Enum.each(
        #  &ExIrc.Client.msg(client, :privmsg, channel, from <> ": " <> &1))
      {:error, err} ->
        Logger.warn("[DoorHandler] Could not fetch Space API: #{err.reason}")
    end
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
