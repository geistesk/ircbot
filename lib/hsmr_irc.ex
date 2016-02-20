defmodule HsmrIrc do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, client} = ExIrc.start_client!

    children = [
      # Define workers and child supervisors to be supervised
      worker(ConnectionHandler, [client]),
      worker(LoginHandler, [client, Application.get_env(:ircbot, :ircChan)]),
      worker(GreetingHandler, [client, %{}]),
      worker(FreifunkaGreetingHandler, [client]),
      worker(ShitpostingHandler, [client]),
      # cmd: !base, !door, !flti
      worker(DoorHandler, [client])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HsmrIrc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
