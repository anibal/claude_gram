defmodule ClaudeGram.WebhookServer do
  @moduledoc """
  Simple webhook server to receive Telegram updates and echo messages back.
  """
  
  use Plug.Router
  require Logger
  
  def bot_token, do: Application.get_env(:claude_gram, :telegram_token)
  def telegram_api_url, do: "https://api.telegram.org/bot#{bot_token()}"
  
  plug Plug.Logger
  plug :match
  plug Plug.Parsers, parsers: [:json], json_decoder: Jason
  plug :dispatch
  
  # Webhook endpoint - Telegram will POST updates here
  post "/webhook" do
    Logger.info("Received webhook request from #{:inet.ntoa(conn.remote_ip)}")
    Logger.debug("Webhook body: #{inspect(conn.body_params)}")
    handle_telegram_update(conn.body_params)
    send_resp(conn, 200, "OK")
  end
  
  # Health check
  get "/health" do
    send_resp(conn, 200, "Bot is running!")
  end
  
  # Catch all
  match _ do
    send_resp(conn, 404, "Not found")
  end
  
  defp handle_telegram_update(%{"message" => message} = _update) do
    Logger.info("Processing message update")
    
    case message do
      %{"chat" => %{"id" => chat_id}, "text" => text} when is_binary(text) ->
        Logger.info("Received text message: '#{text}' from chat: #{chat_id}")
        echo_message = "Echo: #{text}"
        send_message(chat_id, echo_message)
        
      %{"chat" => %{"id" => chat_id}} ->
        Logger.info("Received non-text message from chat: #{chat_id}")
        send_message(chat_id, "I can only echo text messages!")
        
      _ ->
        Logger.warning("Received malformed message: #{inspect(message)}")
    end
  end
  
  defp handle_telegram_update(%{} = update) when map_size(update) == 0 do
    Logger.warning("Received empty update")
  end
  
  defp handle_telegram_update(update) do
    Logger.info("Received non-message update: #{Map.keys(update)}")
    Logger.debug("Full update: #{inspect(update)}")
  end
  
  defp send_message(chat_id, text) do
    url = "#{telegram_api_url()}/sendMessage"
    
    body = %{
      chat_id: chat_id,
      text: text
    }
    
    case Req.post(url, json: body) do
      {:ok, %{status: 200}} ->
        Logger.info("Message sent successfully to chat #{chat_id}")
        
      {:ok, response} ->
        Logger.error("Failed to send message: #{inspect(response)}")
        
      {:error, reason} ->
        Logger.error("Error sending message: #{inspect(reason)}")
    end
  end
end