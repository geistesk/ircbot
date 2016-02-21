defmodule ShitpostingHandler do
  @moduledoc """
  This is an stupid event handler for high quality shitposting :^)
  """

  defmodule Shitpost do
    defstruct [:name, :condition, :execution]
  end

  def start_link(client, last_shitpost) do
    GenServer.start_link(__MODULE__, [client, last_shitpost])
  end

  def init([client, last_shitpost]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, last_shitpost}}
  end

  def lets_shitpost(message, from, channel, client) do
    shitpostings = [
     %Shitpost{
      name: "Hurr Durr",
      condition:
        fn message, _from, _channel, _client ->
          String.match?(message, ~r/(h|d)urr/i) end,
      execution:
        fn _message, _from, channel, client ->
          ExIrc.Client.msg(client, :privmsg, channel, "hurr durr~~") end},
     %Shitpost{
      name: "Cyber",
      condition:
        fn message, _from, _channel, _client ->
          String.match?(message, ~r/cyber/i) end,
      execution:
        fn _message, _from, channel, client ->
          ExIrc.Client.msg(client, :privmsg, channel, "﻿Ｃ Ｙ Ｂ Ｅ Ｒ") end},
     %Shitpost{
      name: "GNU plus Linux",
      condition:
        fn message, _from, _channel, _client ->
          String.contains?(String.downcase(message), "linux") and
          !String.match?(String.downcase(message), ~r/(gnu.{,6}linux)+/i) end,
      execution:
        fn _message, _from, channel, client ->
          [ " .= .-_-. =.    I'd just like to interject for a moment. What you’re referring to as",
            "((_/)o o(\\_))   Linux, is in fact, GNU/Linux, or as I’ve recently taken to calling it,",
            " `-'(. .)`-'    GNU plus Linux. Linux is not an operating system unto itself, but rather",
            "  /| \\_/ |\\     another free component of a fully functioning GNU system made useful by",
            " ( | GNU | )    the GNU corelibs, shell utilities and vital system components comprising",
            " /\"\\_____/\"\\    a full OS as defined by POSIX.",
            " \\__)   (__/      t. RMS" ]
            |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1)) end},
     %Shitpost{
      name: "Otaku",
      condition:
        fn message, _from, _channel, _client ->
          otaku_dict = [
            "baka", "uguu", "バカ","ばか", "senpai", "anime", "manga", "kawaii",
            "moe", "tsundere", "yandere", "otaku", "weaboo"]
          pattern = :binary.compile_pattern(otaku_dict)
          String.contains?(String.downcase(message), pattern) end,
      execution:
        fn _message, from, channel, client ->
          ExIrc.Client.msg(client, :privmsg, channel,
          "#{from} ist ein ganz schlimmer Weaboo… °Д°") end},
     %Shitpost{
      name: "Kaffee",
      condition:
        fn message, _from, _channel, _client ->
          String.match?(message, ~r/m\S{0,2}de|kaffee|espresso/ui) end,
      execution:
        fn _message, from, channel, client ->
          ExIrc.Client.msg(client, :privmsg, channel,
            "Du musst Kaffee trinken, #{from}") end}
    ]

    case Enum.filter(shitpostings,
    fn post -> post.condition.(message, from, channel, client) end) do
      [] ->
        false
      postings = _ ->
        post = Enum.random(postings)
        debug "Invoking #{post.name} based on #{from}s message in #{channel}"
        post.execution.(message, from, channel, client)
        true
    end
  end

  # There are some words where I want to have a stupid reaction.
  # This goes here..
  def handle_info({:received, message, from, channel}, {client, last_shitpost}) do
    if :os.system_time > last_shitpost + 30_000_000_000 and
       :random.uniform < 0.4 and
       lets_shitpost(message, from, channel, client) do
      {:noreply, {client, :os.system_time}}
    else
      {:noreply, {client, last_shitpost + 1_500_000_000}}
    end
  end

  # Let's greet Tobi-Senpai. Uguu~
  def handle_info({:joined, channel, "towb"}, {client, last_shitpost}) do
    debug "Tobi-Senpai has joined us in #{channel}. Uguu, uguu~~"
    ExIrc.Client.msg(client, :privmsg, channel, "Ohaaiii Tobi-senpai~")
    {:noreply, {client, last_shitpost}}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end
