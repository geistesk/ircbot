defmodule ShitpostingHandler do
  @moduledoc """
  This is an stupid event handler for high quality shitposting :^)
  """
  def start_link(client, last_shitpost) do
    GenServer.start_link(__MODULE__, [client, last_shitpost])
  end

  def init([client, last_shitpost]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, last_shitpost}}
  end

  defp handle_hurrdurr(message, from, channel, client) do
    pattern = :binary.compile_pattern(["hurr", "durr"])
    if String.contains?(String.downcase(message), pattern) do
      debug "#{from} requested a \"hurr durr\" in #{channel}"
      ExIrc.Client.msg(client, :privmsg, channel, "hurr durr~")
      1
    else
      0
    end
  end

  defp handle_cyber(message, from, channel, client) do
    if String.contains?(String.downcase(message), "cyber") do
      debug "#{from} is fully C Y B E R"
      ExIrc.Client.msg(client, :privmsg, channel, "﻿Ｃ Ｙ Ｂ Ｅ Ｒ")
      1
    else
      0
    end
  end

  defp handle_gnu_rms(message, _from, channel, client) do
    if String.contains?(String.downcase(message), "linux") and
      !String.match?(String.downcase(message), ~r/(gnu.{,6}linux)+/i) do
      [ " .= .-_-. =.    I'd just like to interject for a moment. What you’re referring to as",
        "((_/)o o(\\_))   Linux, is in fact, GNU/Linux, or as I’ve recently taken to calling it,",
        " `-'(. .)`-'    GNU plus Linux. Linux is not an operating system unto itself, but rather",
        "  /| \\_/ |\\     another free component of a fully functioning GNU system made useful by",
        " ( | GNU | )    the GNU corelibs, shell utilities and vital system components comprising",
        " /\"\\_____/\"\\    a full OS as defined by POSIX.",
        " \\__)   (__/      t. RMS" ]
        |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
      1
    else
      0
    end
  end

  # There are some words where I want to have a stupid reaction.
  # This goes here..
  def handle_info({:received, message, from, channel}, {client, last_shitpost}) do
    if :os.system_time > last_shitpost + 30 * 1_000_000_000 and
       :random.uniform < 0.33 and
       (handle_hurrdurr(message, from, channel, client) +
        handle_cyber(   message, from, channel, client) +
        handle_gnu_rms( message, from, channel, client) > 0) do
       {:noreply, {client, :os.system_time}}
     else
       {:noreply, {client, last_shitpost + 2_500_000_000}}
    end
  end

  # Let's greet Tobi-Senpai. Uguu~
  def handle_info({:joined, channel, "towb"}, {client, last_shitpost}) do
    debug "Tobi-Senpai has joined us in #{channel}. Uguu, uguu~~"
    ExIrc.Client.msg(client, :privmsg, channel, "Ohai Tobi-Senpai~")
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
