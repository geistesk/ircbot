defmodule ShitpostingHandler do
  @moduledoc """
  This is an stupid event handler for high quality shitposting :^)
  """
  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    ExIrc.Client.add_handler client, self
    {:ok, client}
  end

  defp handle_hurrdurr(message, from, channel, client) do
    pattern = :binary.compile_pattern(["hurr", "durr"])
    if String.contains?(String.downcase(message), pattern) do
      debug "#{from} requested a \"hurr durr\" in #{channel}"
      ExIrc.Client.msg(client, :privmsg, channel, "hurr durr~")
    end
  end

  defp handle_cyber(message, from, channel, client) do
    if String.contains?(String.downcase(message), "cyber") do
      debug "#{from} is fully C Y B E R"
      ExIrc.Client.msg(client, :privmsg, channel, "﻿Ｃ Ｙ Ｂ Ｅ Ｒ")
    end
  end

  defp handle_gnu_rms(message, _from, channel, client) do
    if String.contains?(String.downcase(message), "linux") and
      !String.match?(String.downcase(message), ~r/(gnu.{,4}linux)+/i) and
      :random.uniform < 0.2 do
      [ " .= .-_-. =.",
        "((_/)o o(\\_))   I'd just like to interject for a moment. What you’re referring to as",
        " `-'(. .)`-'    GNU plus Linux. Linux is not an operating system unto itself, but rather",
        "  /| \\_/ |\\     another free component of a fully functioning GNU system made useful by",
        " ( | GNU | )    the GNU corelibs, shell utilities and vital system components comprising",
        " /\"\\_____/\"\\    a full OS as defined by POSIX.",
        " \\__)   (__/      t. RMS" ]
        |> Enum.each(&ExIrc.Client.msg(client, :privmsg, channel, &1))
    end
  end

  def handle_info({:received, message, from, channel}, client) do
    handle_hurrdurr message, from, channel, client
    handle_cyber    message, from, channel, client
    handle_gnu_rms  message, from, channel, client

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
