require Logger

defmodule TelegramPlugin do
  @delay 20_000

  def getUpdates(token, since \\ 0) do
    case HTTPoison.get("https://api.telegram.org/bot#{token}/getUpdates") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        message_list = parseUpdates(body)
        |> Enum.filter(fn %{"update_id" => update_id} -> update_id > since end)
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
        last_message["update_id"]
      _ ->
        0
    end
    Logger.info("[TelegramPlugin] Start first cycle with id #{last_update_id}")
    cycle(token, last_update_id, client_pid)
  end

  defp cycle(token, since, client_pid) do
    :timer.sleep(@delay)
    Logger.debug("[TelegramPlugin] Get into cycle with id #{since}")
    case getUpdates(token, since) do
      {:ok, []} ->
        Logger.debug("[TelegramPlugin] Got an empty update..")
        cycle(token, since, client_pid)
      {:ok, msgs} ->
        Logger.info("[TelegramPlugin] Got some updates! Posting them now..")
        Enum.each(msgs,
          fn %{"message" => message} -> send_message(client_pid, message) end)
        last_message = List.last(msgs)
        cycle(token, last_message["update_id"], client_pid)
      _ ->
        Logger.warn("[TelegramPlugin] Couldn't get updates!")
        cycle(token, since, client_pid)
    end
  end

  defp send_message(client_pid, message) do
    Enum.each(Application.get_env(:ircbot, :telegramChannels), fn channel ->
      try do
        chat = message["chat"]
        from = message["from"]
        text = message["text"]

        sender = cond do
          from == nil ->
            "Someone"
          from["first_name"] != nil and from["last_name"] != nil and from["username"] != nil ->
            from["first_name"] <> " " <> from["last_name"] <> " (" <> from["username"] <> ")"
          from["first_name"] != nil and from["username"] != nil ->
            from["first_name"] <> " (" <> from["username"] <> ")"
          from["first_name"] != nil ->
            from["first_name"]
          from["username"] != nil ->
            from["username"]
          true ->
            "Someone"
        end
        chat_name = cond do
          chat == nil ->
            " somewhere"
          chat["title"] != nil ->
            " in " <> chat["title"]
          true ->
            ""
        end

        if !(chat["id"] in Application.get_env(:ircbot, :telegramChatIds)), do:
          raise "Message from not allowed chat-id"

        ExIrc.Client.msg(client_pid, :notice, channel,
          "Telegram: " <> <<2>> <> sender <> <<15>> <> " wrote" <>
          <<2>> <> chat_name <> <<15>> <> ": " <> text)
      rescue
        e -> Logger.warn("[TelegramPlugin] Exception while posting: #{e.message}")
      end
    end)
  end
end
