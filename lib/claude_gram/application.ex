defmodule ClaudeGram.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    children = [
      # Start the webhook server
      {Bandit, plug: ClaudeGram.WebhookServer, port: Application.get_env(:claude_gram, :webhook_port, 4000)},
      # Start the log tailer
      ClaudeGram.LogTailer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClaudeGram.Supervisor]
    
    # Start the supervisor
    result = Supervisor.start_link(children, opts)
    
    # Log startup information
    webhook_domain = Application.get_env(:claude_gram, :telegram_webhook_domain)
    webhook_path = Application.get_env(:claude_gram, :telegram_webhook_path)
    webhook_port = Application.get_env(:claude_gram, :webhook_port)
    log_file_path = Application.get_env(:claude_gram, :log_file_path)
    
    Logger.info("ClaudeGram started successfully!")
    Logger.info("Webhook URL: #{webhook_domain}#{webhook_path}")
    Logger.info("Server listening on port: #{webhook_port}")
    Logger.info("Monitoring log file: #{log_file_path}")
    Logger.info("Setting up webhook automatically...")
    
    # Set up webhook on startup
    ClaudeGram.Bot.setup_webhook()
    
    result
  end
end
