require Logger

defmodule GrafanaRouter do
  import Plug.Conn

  # Initial opts should be the ExIrc-reference
  def init(opts), do: opts

  def call(conn, opts) do
    {code, msg} = {conn, opts}
      |> filter_request
      |> extract_body
      |> body_parse_json
      |> json_to_messages
      |> post_in_irc

    conn = put_resp_content_type(conn, "application/json", "utf-8")

    case code do
      :ok ->
        Logger.info("[GrafanaRouter] " <> msg)
        send_resp(conn, 200, "{ \"state\": \"(ﾟヮﾟ)\" }")
      :error ->
        Logger.warn("[GrafanaRouter] " <> msg)
        send_resp(conn, 500, "{ \"state\": \"o(╥﹏╥)o\" }")
    end
  end

  # {conn, opts} -> {:ok, {conn, opts}} | {:error, msg}
  defp filter_request({conn, opts}) do
    check_method = conn.method == "POST"
    check_path   = conn.request_path == Application.get_env(
      :ircbot, :grafanaRouterUrl, "/web-hook/")

    if check_method && check_path do
      {:ok, {conn, opts}}
    else
      {:error, "Wrong HTTP-method or wrong request-path"}
    end
  end

  # {:ok, {conn, opts}} -> {:ok, {body, opts}} | {:error, msg}
  # {:error, msg}       -> {:error, msg}
  defp extract_body({:error, msg}), do: {:error, msg}
  defp extract_body({:ok, {conn, opts}}) do
    case read_body(conn) do
      {:ok, body, _} -> {:ok, {body, opts}}
      {:error, msg}  -> {:error, msg}
      _              -> {:error, "Failed to extract body"}
    end
  end

  # {:ok, {body, opts}} -> {:ok, {json_data, opts}} | {:error, msg}
  # {:error, msg}       -> {:error, msg}
  defp body_parse_json({:error, msg}), do: {:error, msg}
  defp body_parse_json({:ok, {body, opts}}) do
    case JSON.decode(body) do
      {:ok, json_data} when is_map(json_data) ->
         # http://docs.grafana.org/alerting/notifications/
         # Check if all (imho) relevant fields are existing
         is_grafana? = MapSet.subset?(
            MapSet.new(["title", "message", "state"]),
            MapSet.new(Map.keys(json_data)))

          if is_grafana? do
            {:ok, {json_data, opts}}
          else
            {:error, "Required fields in JSON-map are missing"}
          end

      {:error, msg} -> {:error, msg}
      _             -> {:error, "Failed to decode JSON"}
    end
  end

  # {:ok, {json_data, opts}} -> {:ok, {irc_msgs, opts}}
  # {:error, msg}            -> {:error, msg}
  defp json_to_messages({:error, msg}), do: {:error, msg}
  defp json_to_messages({:ok, {json_data, opts}}) do
    title   = json_data["title"]
    message = json_data["message"]
    state   = json_data["state"]
    
    irc_msgs = ["[Grafana] " <> title <> " [State: " <> state <> "]",
                "[Grafana] " <> message]

    {:ok, {irc_msgs, opts}}
  end

  # {:ok, {irc_msgs, opts}} -> {:ok, msg} | {:error, msg}
  # {:error, msg}           -> {:error, msg}
  defp post_in_irc({:error, msg}), do: {:error, msg}
  defp post_in_irc({:ok, {irc_msgs, opts}}) do
    try do
      Enum.each(Application.get_env(:ircbot, :grafanaRouterChannels),
        fn channel ->
          Enum.each(irc_msgs, &ExIrc.Client.msg(opts, :notice, channel, &1))
        end)
      {:ok, "Message sent to IRC"}
    catch
      _ -> {:error, "Failed to send message to the IRC"}
    end
  end
end
