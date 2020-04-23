defmodule LoggerJSON.Formatters.BasicLogger do
  @moduledoc """
  Basic JSON log formatter with no vender specific formatting
  """

  import Jason.Helpers, only: [json_map: 1]

  alias LoggerJSON.FormatterUtils

  @behaviour LoggerJSON.Formatter

  @processed_metadata_keys ~w[pid file line function module application]a

  @impl true
  def format_event(level, msg, ts, md, md_keys) do
    json_map(
      time: FormatterUtils.format_timestamp(ts),
      severity: Atom.to_string(level),
      message: IO.iodata_to_binary(msg),
      metadata: format_metadata(md, md_keys)
    )
  end

  defp format_metadata(md, md_keys) do
    md
    |> LoggerJSON.take_metadata(md_keys, @processed_metadata_keys)
    |> format_data()
    |> FormatterUtils.maybe_put(:error, FormatterUtils.format_process_crash(md))
  end

  defp format_data(%_{} = data) do
    data
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce(data, fn key, acc ->
      Map.put(acc, key, format_data(Map.get(data, key)))
    end)
  end

  defp format_data(%{} = data) do
    data
    |> Map.keys()
    |> Enum.reduce(data, fn key, acc ->
      Map.put(acc, key, format_data(Map.get(data, key)))
    end)
  end

  defp format_data({key, data}) when is_binary(key) or is_atom(key) do
    %{key => format_data(data)}
  end

  defp format_data(data)
       when is_list(data) or is_tuple(data) or is_reference(data) or is_port(data) or is_pid(data) or
              (is_bitstring(data) and not is_binary(data)) or (is_binary(data) and not String.valid?(data)) do
    inspect(data, pretty: true, width: 70)
  end

  defp format_data(data), do: data
end
