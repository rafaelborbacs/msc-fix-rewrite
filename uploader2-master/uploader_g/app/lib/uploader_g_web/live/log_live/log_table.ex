defmodule UploaderGWeb.LogLive.LogTable do
  use UploaderGWeb, :live_component

  alias UploaderG.Entities

  defp get_unit_by_key(nil) do
    "—"
  end

  defp get_unit_by_key(key) do
    unit = Entities.get_unit(key, :by_public_key)

    if unit do
      unit.location
    else
      "—"
    end
  end

  defp format_date(%DateTime{} = date) do
    Calendar.strftime(date, "%d/%m/%y às %H:%M:%S")
  end

  defp format_date(nil) do
    "—"
  end

  defp list_logs do
    Logging.list_logs()
  end

  defp list_logs(:error) do
    Logging.list_logs(:error)
  end

end
