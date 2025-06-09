defmodule ClaudeGram do
  @moduledoc """
  A minimal Telegram bot using webhooks and the Req HTTP client.
  
  ## Setup
  
  1. Replace the bot token in `ClaudeGram.WebhookServer` and `ClaudeGram.Bot`
  2. Replace the webhook URL in `ClaudeGram.Bot` with your ngrok or domain
  3. Run `mix deps.get` to install dependencies
  4. Start the app with `mix run --no-halt`
  5. Set up the webhook with `ClaudeGram.setup_webhook()`
  
  ## Usage
  
  The bot will echo any text message sent to it.
  """

  defdelegate setup_webhook(), to: ClaudeGram.Bot
  defdelegate delete_webhook(), to: ClaudeGram.Bot
  defdelegate get_webhook_info(), to: ClaudeGram.Bot
end
