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
        Logger.info("[TelegramPlugin] Got some possible updates! Processing…")
        # only care about "messages" atm
        Enum.filter(msgs, fn x -> x["message"] != nil end)
        |> Enum.each(
            fn %{"message" => message} ->
              send_message(token, client_pid, message) end)
        last_message = List.last(msgs)
        cycle(token, last_message["update_id"] + 1, client_pid)
      _ ->
        Logger.warn("[TelegramPlugin] Couldn't get updates!")
        cycle(token, since, client_pid)
    end
  end

  def getFile(token, file_id) do
    %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(
      "https://api.telegram.org/bot#{token}/getFile?file_id=#{file_id}")
    %{"ok" => true, "result" => %{"file_path" => path}} = JSON.decode!(body)
    "https://api.telegram.org/file/bot#{token}/#{path}"
  end

  def fetch_file(telegram_url) do
    %HTTPoison.Response{status_code: 200, body: resp} = HTTPoison.get!(telegram_url)
    {:ok, file, file_name} = Temp.open
    IO.binwrite(file, resp)
    File.close(file)
    {file_name, "tlgrm" <> Path.extname(telegram_url)}
  end

  # for stickers only
  def dwebp_invoke({file_name, "tlgrm.webp"}) do
    jpg_file = Temp.path!(%{suffix: ".jpg"})
    System.cmd("dwebp", [file_name, "-o", jpg_file], stderr_to_stdout: true)
    File.rm!(file_name)
    {jpg_file, "tlgrm.jpg"}
  end

  def upload_uguu({file_name, upld_file_name}) do
    post_resp = HTTPoison.post!("https://uguu.se/api.php?d=upload-tool",
      {:multipart, [{"name", upld_file_name}, {:file, file_name}]})
    %HTTPoison.Response{status_code: 200, body: uguu_url} = post_resp

    File.rm!(file_name)
    uguu_url
  end

  # converts a list of words into a list of multiple words
  # this function is used to split long sentences into multiple lines
  defp make_text_line([], data), do: data
  defp make_text_line([ih | it], []), do: make_text_line(it, [ih])
  defp make_text_line([ih | it], [dh | dt]) do
    if String.length(dh <> " " <> ih) <= 80 do
      make_text_line(it, [dh <> " " <> ih | dt])
    else
      make_text_line(it, [ih, dh | dt])
    end
  end

  defp send_message(token, client_pid, message) do
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
          %{"file_id" => file_id} = message["sticker"]
          url = getFile(token, file_id) |> fetch_file |> dwebp_invoke |> upload_uguu
          ["#{sender} sent a sticker: #{url}"]

        message["photo"] != nil ->
          file_id = Enum.max_by(message["photo"], fn %{"file_size" => x} -> x end)
                    |> Map.fetch!("file_id")
          url = getFile(token, file_id) |> fetch_file |> upload_uguu
          ["#{sender} sent a picture: #{url}"]

        message["video"] != nil ->
          %{"file_id" => file_id} = message["video"]
          url = getFile(token, file_id) |> fetch_file |> upload_uguu
          ["#{sender} sent a video: #{url}"]

        message["document"] != nil ->
          %{"file_id" => file_id} = message["document"]
          url = getFile(token, file_id) |> fetch_file |> upload_uguu
          ["#{sender} sent a file: #{url}"]

        message["text"] != nil ->
          txt_lines =
            String.split(message["text"], "\n", trim: true)
            |> Enum.reduce([], fn line, list ->
              line_list = String.split(line, ~r{\s}, trim: true) |> make_text_line([]) |> Enum.reverse
              list ++ line_list end)
          res_lines = Enum.map(txt_lines, fn line ->
            "<" <> sender <> ">" <> <<3>> <> "3" <> " " <> line <> <<15>>
          end)
          res_lines

        true ->
          raise "Won't handle unsupported message type"
      end

      if !(chat["id"] in Application.get_env(:ircbot, :telegramChatIds)), do:
        raise "Message from not allowed chat-id"

      Enum.each(Application.get_env(:ircbot, :telegramChannels),
        fn channel ->
          Enum.each(irc_messages,
            &ExIrc.Client.msg(client_pid, :notice, channel,
                              <<2>> <> "TLGRM| " <> <<15>> <> &1))
        end)
    rescue
      e in RuntimeError -> Logger.warn("[TelegramPlugin] #{e.message}")
      _ -> Logger.warn("[TelegramPlugin] Something went wrong :>")
    end
  end
end
