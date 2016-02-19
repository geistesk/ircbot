defmodule State do
  defstruct host: Application.get_env(:ircbot, :ircHost),
            port: Application.get_env(:ircbot, :ircPort),
            pass: Application.get_env(:ircbot, :ircPass),
            nick: Application.get_env(:ircbot, :ircNick),
            user: Application.get_env(:ircbot, :ircUser),
            name: Application.get_env(:ircbot, :ircName),
            client: nil
end
