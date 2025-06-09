import Config

# Runtime configuration for environment variables
telegram_token = System.get_env("TELEGRAM_TOKEN")
telegram_webhook_domain = System.get_env("TELEGRAM_WEBHOOK_DOMAIN") || System.get_env("TELEGRAM_WEBHOOK")
telegram_webhook_path = System.get_env("TELEGRAM_WEBHOOK_PATH")

unless telegram_token do
  IO.puts(:stderr, "Error: TELEGRAM_TOKEN environment variable is not set")
  System.halt(1)
end

unless telegram_webhook_domain do
  IO.puts(:stderr, "Error: TELEGRAM_WEBHOOK_DOMAIN environment variable is not set")
  System.halt(1)
end

telegram_webhook_path =
  if telegram_webhook_path do
    telegram_webhook_path
  else
    IO.puts("Warning: TELEGRAM_WEBHOOK_PATH not set, defaulting to /webhook")
    "/webhook"
  end

log_file_path = System.get_env("LOG_FILE_PATH")
log_file_path =
  if log_file_path do
    log_file_path
  else
    IO.puts("Warning: LOG_FILE_PATH not set, defaulting to ./CLAUDE_GRAM.log")
    "./CLAUDE_GRAM.log"
  end

alert_chat_id = System.get_env("TELEGRAM_ALERT_CHAT_ID")

if alert_chat_id do
  IO.puts("Alert notifications will be sent to chat ID: #{alert_chat_id}")
else
  IO.puts("Warning: TELEGRAM_ALERT_CHAT_ID not set, alerts will be logged only")
end

config :claude_gram,
  telegram_token: telegram_token,
  telegram_webhook_domain: telegram_webhook_domain,
  telegram_webhook_path: telegram_webhook_path,
  log_file_path: log_file_path,
  alert_chat_id: alert_chat_id