# ClaudeGram - Telegram Webhook Bot with Log Monitoring

A monitor for Claude Code sessions based on starting `claude` in the terminal using the `script` command, that sends the output to a log file and monitors it for calls like "Do you want to proceed?", sending Telegram alerts with the context of the following lines.

This is pure vibe coding, the code works, it is not production ready, but it is fun to use in a local sandbox to leave Claude Code with a big task,  walk away to stretch your legs or get a cup of coffee, and receive alerts when it is waiting for your input.

It is extremly unlikely that this code will be further developed, because for me it is very obvious thta every single vendor of Agentic Coding systems is going to build this kind of feature into their products, or are already doing it; also a proper solution requires a deeper integration.

It should be extremely easy for you to build a clone of this if your favorite stack, this was pretty much a couple hours of work over the weekend with Claude using the Sonnet 4 model

## Quick Setup

1. **Get your bot token** from @BotFather on Telegram after setting up a bot, it is extremely simple and should on;y take a minute or two.

2. **Set environment variables**:
   ```bash
   export TELEGRAM_TOKEN="your_bot_token_here"
   export TELEGRAM_WEBHOOK_DOMAIN="https://your-domain.ngrok.io"
   export TELEGRAM_WEBHOOK_PATH="/webhook"              # Optional, defaults to /webhook
   export LOG_FILE_PATH="./CLAUDE_GRAM.log"            # Optional, defaults to ./CLAUDE_GRAM.log
   export TELEGRAM_ALERT_CHAT_ID="your_chat_id_here"   # Optional, for log pattern alerts
   ```

   **Finding your chat ID for alerts:**
   - Start a conversation with your bot on Telegram
   - Send any message to the bot
   - Check the application logs - the chat ID will be displayed when processing the message
   - Use this chat ID for `TELEGRAM_ALERT_CHAT_ID` to receive log monitoring alerts

   This could be easier if you assume that any message is always from the same person, but wathever.

3. **Install dependencies**:
   ```bash
   mix deps.get
   ```

4. **Expose your local server** (use ngrok or similar):
   ```bash
   # In another terminal
   ngrok http 4000
   ```
   Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`) and set it as `TELEGRAM_WEBHOOK_DOMAIN`

5. **Start the bot**:
   ```bash
   mix run --no-halt
   ```

6. **Startd Clude Code with `script` command**: 
   ```bash
   script -Fq /path/to/the/log/file/CLAUDE_GRAM.log claude
   ```
   The ` -F` option immediately flush output after each write, so you are messaged as soon as possible. You can pass options to `claude` as you would do in the terminal at the end of the line, but again feel free to experiment.

## Structure

- `WebhookServer`: Receives POST requests from Telegram and handles messages
- `Bot`: Helper module for webhook management and alert sending
- `LogTailer`: GenServer that monitors log files for specific patterns with ANSI control character stripping
- `Application`: OTP app that starts the Bandit web server and LogTailer

The bot listens on port 4000 and includes automatic webhook setup on startup.

