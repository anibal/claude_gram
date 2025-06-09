defmodule ClaudeGram.LogTailer do
  @moduledoc """
  GenServer that monitors a log file for specific patterns and sends Telegram alerts.
  """

  use GenServer
  require Logger

  # Pattern to detect "Do you want to proceed?" in UI boxes
  @pattern ~r/Do you want to proceed\?/i

  # ANSI control sequences pattern for stripping
  @ansi_pattern ~r/\e\[[0-9;]*[a-zA-Z]/


  defstruct [:log_file_path, :file_size, :watcher_pid]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    log_file_path = Application.get_env(:claude_gram, :log_file_path)

    Logger.info("Starting LogTailer for file: #{log_file_path}")

    # Create the log file if it doesn't exist
    unless File.exists?(log_file_path) do
      Logger.info("Creating log file: #{log_file_path}")
      File.touch!(log_file_path)
    end

    # Get initial file size
    initial_size = File.stat!(log_file_path).size

    # Start file system watcher
    log_dir = Path.dirname(log_file_path)
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [log_dir])
    FileSystem.subscribe(watcher_pid)

    state = %__MODULE__{
      log_file_path: log_file_path,
      file_size: initial_size,
      watcher_pid: watcher_pid
    }

    Logger.info("LogTailer initialized successfully")
    {:ok, state}
  end

  @impl true
  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    if Path.basename(path) == Path.basename(state.log_file_path) and :modified in events do
      Logger.debug("File modification detected: #{path}")
      check_for_new_content(state)
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    Logger.warning("File watcher stopped")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.debug("Unhandled message: #{inspect(msg)}")
    {:noreply, state}
  end

  defp check_for_new_content(state) do
    case File.stat(state.log_file_path) do
      {:ok, %{size: current_size}} when current_size > state.file_size ->
        # File has grown, read new content
        case File.open(state.log_file_path, [:read]) do
          {:ok, file} ->
            :file.position(file, state.file_size)
            new_content = IO.read(file, :eof)
            File.close(file)

            if new_content && String.length(new_content) > 0 do
              Logger.debug("New content detected (#{String.length(new_content)} bytes)")
              process_content(new_content)
              {:noreply, %{state | file_size: current_size}}
            else
              {:noreply, %{state | file_size: current_size}}
            end

          {:error, reason} ->
            Logger.error("Failed to read log file: #{inspect(reason)}")
            {:noreply, state}
        end

      {:ok, %{size: current_size}} when current_size < state.file_size ->
        # File was truncated or rotated
        Logger.info("Log file appears to have been truncated or rotated")
        {:noreply, %{state | file_size: current_size}}

      {:ok, _} ->
        # No size change
        {:noreply, state}

      {:error, reason} ->
        Logger.error("Failed to stat log file: #{inspect(reason)}")
        {:noreply, state}
    end
  end

  defp process_content(content) do
    lines = String.split(content, ["\n", "\r\n"])

    Enum.each(lines, fn line ->
      # Strip control characters and check for pattern
      cleaned_line = strip_control_characters(line)

      if Regex.match?(@pattern, cleaned_line) do
        Logger.info("Pattern detected: #{String.trim(cleaned_line)}")
        send_alert(cleaned_line)
      end
    end)
  end

  defp strip_control_characters(text) do
    text
    |> String.replace(@ansi_pattern, "")
    |> String.replace(~r/\[\d+[A-Z]/, "")  # Additional control sequences like [2K, [1A
    |> String.replace(~r/\[\d*[a-zA-Z]/, "")  # More control sequences
    |> String.replace(~r/[\x00-\x08\x0E-\x1F\x7F]/, "")  # Other control characters
    |> String.trim()
  end


  defp send_alert(content) do
    alert_message = "Do you want to proceed?\n#{String.trim(content)}"

    case ClaudeGram.Bot.send_alert(alert_message) do
      :ok ->
        Logger.info("Alert sent successfully: #{String.slice(String.trim(content), 0, 50)}...")
      {:error, reason} ->
        Logger.error("Failed to send alert: #{inspect(reason)}")
    end
  end
end
