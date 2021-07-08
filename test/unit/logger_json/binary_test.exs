defmodule LoggerJSON.BinaryTest do
  use Logger.Case, async: false
  require Logger
  alias LoggerJSON.Formatters.BasicLogger

  @bin <<70, 97, 105, 108, 101, 100, 32, 116, 111, 32, 99, 97, 110, 99, 101, 108, 32, 101, 120, 116, 101, 114, 110, 97,
         108, 32, 112, 97, 121, 109, 101, 110, 116, 32, 136, 240, 245, 140, 248, 137, 69, 139, 154, 51, 175, 160, 39,
         253, 116, 236>>

  @str_bin inspect(@bin)

  setup do
    :ok =
      Logger.configure_backend(
        LoggerJSON,
        device: :user,
        level: nil,
        metadata: [],
        json_encoder: Jason,
        on_init: :disabled,
        formatter: BasicLogger
      )
  end

  test "binary" do
    Logger.configure_backend(LoggerJSON, metadata: [:some_bin])
    Logger.metadata(some_bin: @bin)

    log =
      fn -> Logger.debug(@bin) end
      |> capture_log()
      |> Jason.decode!()

    assert log["message"] == @str_bin
    assert log["metadata"]["some_bin"] == @str_bin
  end
end
