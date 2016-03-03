require Logger

defmodule TelegramPlugin do
  @moduledoc """
  A plugin which checks every 20 seconds for Telegram-messages and posts them.
  """
  @delay 20_000

  def getUpdates(token, since \\ 0) do
    case HTTPoison.get("https://api.telegram.org/bot#{token}/getUpdates?offset=#{since}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        message_list = parseUpdates(body)
        {:ok, message_list}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      _ ->
        {:error, :unknown}
    end
  end

  defp parseUpdates(text) do
    case JSON.decode(text) do
      {:ok, %{"result" => result}} -> result
      _                            -> []
    end
  end

  def init_cycle(token, client_pid) do
    last_update_id = case getUpdates(token, 0) do
      {:ok, []} ->
        0
      {:ok, msgs} ->
        last_message = List.last(msgs)
        last_message["update_id"] + 1
      _ ->
        0
    end
    Logger.info("[TelegramPlugin] Start first cycle with offset #{last_update_id}")
    cycle(token, last_update_id, client_pid)
  end

  defp cycle(token, since, client_pid) do
    :timer.sleep(@delay)
    Logger.debug("[TelegramPlugin] Get into cycle with offset #{since}")
    case getUpdates(token, since) do
      {:ok, []} ->
        Logger.debug("[TelegramPlugin] Got an empty update..")
        cycle(token, since, client_pid)
      {:ok, msgs} ->
        Logger.info("[TelegramPlugin] Got some updates! Posting them now..")
        Enum.each(msgs,
          fn %{"message" => message} -> send_message(client_pid, message) end)
        last_message = List.last(msgs)
        cycle(token, last_message["update_id"] + 1, client_pid)
      _ ->
        Logger.warn("[TelegramPlugin] Couldn't get updates!")
        cycle(token, since, client_pid)
    end
  end

  defp send_message(client_pid, message) do
    try do
      chat = message["chat"]
      from = message["from"]

      sender = cond do
        from["first_name"] != nil and from["last_name"] != nil and from["username"] != nil ->
          from["first_name"] <> " " <> from["last_name"] <> " (" <> from["username"] <> ")"
        from["first_name"] != nil and from["username"] != nil ->
          from["first_name"] <> " (" <> from["username"] <> ")"
        from["first_name"] != nil ->
          from["first_name"]
        from["username"] != nil ->
          from["username"]
      end

      irc_messages = cond do
        message["sticker"] != nil ->
          ["#{sender} sent a smug sticker…"]

        message["text"] != nil ->
          [txt_head | txt_lines] = String.split(message["text"], "\n", trim: true)

          res_head  = sender <> ": " <> <<3>> <> "3" <> txt_head <> <<15>>
          res_lines = Enum.map(txt_lines, fn line ->
            String.duplicate(" ", String.length(sender) + 2) <>
            <<3>> <> "3" <> line <> <<15>>
          end)
          [res_head | res_lines]
      end

      if !(chat["id"] in Application.get_env(:ircbot, :telegramChatIds)), do:
        raise "Message from not allowed chat-id"

      Enum.each(Application.get_env(:ircbot, :telegramChannels),
        fn channel ->
          Enum.each(irc_messages,
            &ExIrc.Client.msg(client_pid, :notice, channel,
                              <<2>> <> "[Telegram] " <> <<15>> <> &1))
        end)
    rescue
      e -> Logger.warn("[TelegramPlugin] Exception while posting: #{e.message}")
    end
  end
end
