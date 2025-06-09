defmodule ClaudeGramTest do
  use ExUnit.Case
  doctest ClaudeGram

  test "greets the world" do
    assert ClaudeGram.hello() == :world
  end
end
