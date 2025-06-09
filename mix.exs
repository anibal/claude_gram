defmodule ClaudeGram.MixProject do
  use Mix.Project

  def project do
    [
      app: :claude_gram,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ClaudeGram.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:file_system, "~> 1.0"}
    ]
  end
end
