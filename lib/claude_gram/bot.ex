defmodule ClaudeGram.Bot do
  @moduledoc """
  Simple Telegram bot client for setting up webhooks and basic API operations.
  """
  
  require Logger
  
  def bot_token, do: Application.get_env(:claude_gram, :telegram_token)
  def webhook_domain, do: Application.get_env(:claude_gram, :telegram_webhook_domain)
  def webhook_path, do: Application.get_env(:claude_gram, :telegram_webhook_path)
  def webhook_url, do: "#{webhook_domain()}#{webhook_path()}"
  def telegram_api_url, do: "https://api.telegram.org/bot#{bot_token()}"
  def alert_chat_id, do: Application.get_env(:claude_gram, :alert_chat_id)
  
  @doc """
  Set up the webhook with Telegram.
  Call this once to register your webhook URL.
  """
  def setup_webhook do
    url = "#{telegram_api_url()}/setWebhook"
    
    body = %{
      url: webhook_url(),
      allowed_updates: ["message"]
    }
    
    case Req.post(url, json: body) do
      {:ok, %{status: 200, body: %{"ok" => true}}} ->
        Logger.info("Webhook set successfully to #{webhook_url()}")
        :ok
        
      {:ok, response} ->
        Logger.error("Failed to set webhook: #{inspect(response)}")
        {:error, response}
        
      {:error, reason} ->
        Logger.error("Error setting webhook: #{inspect(reason)}")
        {:error, reason}
    end
  end
  
  @doc """
  Delete the webhook (useful for testing or switching back to polling).
  """
  def delete_webhook do
    url = "#{telegram_api_url()}/deleteWebhook"
    
    case Req.post(url) do
      {:ok, %{status: 200, body: %{"ok" => true}}} ->
        Logger.info("Webhook deleted successfully")
        :ok
        
      {:ok, response} ->
        Logger.error("Failed to delete webhook: #{inspect(response)}")
        {:error, response}
        
      {:error, reason} ->
        Logger.error("Error deleting webhook: #{inspect(reason)}")
        {:error, reason}
    end
  end
  
  @doc """
  Get webhook info for debugging.
  """
  def get_webhook_info do
    url = "#{telegram_api_url()}/getWebhookInfo"
    
    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        Logger.info("Webhook info: #{inspect(body)}")
        {:ok, body}
        
      {:ok, response} ->
        Logger.error("Failed to get webhook info: #{inspect(response)}")
        {:error, response}
        
      {:error, reason} ->
        Logger.error("Error getting webhook info: #{inspect(reason)}")
        {:error, reason}
    end
  end
  
  @doc """
  Send an alert message to the configured alert chat.
  """
  def send_alert(message) do
    case alert_chat_id() do
      nil ->
        Logger.warning("No alert chat ID configured, logging alert: #{message}")
        :ok
        
      chat_id ->
        url = "#{telegram_api_url()}/sendMessage"
        
        body = %{
          chat_id: chat_id,
          text: message,
          parse_mode: "Markdown"
        }
        
        case Req.post(url, json: body) do
          {:ok, %{status: 200}} ->
            Logger.info("Alert sent successfully to chat #{chat_id}")
            :ok
            
          {:ok, response} ->
            Logger.error("Failed to send alert: #{inspect(response)}")
            {:error, response}
            
          {:error, reason} ->
            Logger.error("Error sending alert: #{inspect(reason)}")
            {:error, reason}
        end
    end
  end
end