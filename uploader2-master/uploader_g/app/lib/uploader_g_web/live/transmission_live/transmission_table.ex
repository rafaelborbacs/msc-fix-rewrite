defmodule UploaderGWeb.TransmissionLive.TransmissionTable do
  use UploaderGWeb, :live_component

  alias UploaderG.Entities

  defp get_unit_by_key(key) do
    unit = Entities.get_unit(key, :by_public_key_identifier)

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

  defp td_status(assigns) do
    case assigns.status do
      "T - OK" ->
        ~H"""
        <td class="px-6 py-4 text-blue-800"><%= @status %></td>
        """

      "T - ERROR" ->
        ~H"""
        <td class="px-6 py-4 text-red-600"><%= @status %></td>
        """

      "T - PROCESSING" ->
        ~H"""
        <td class="px-6 py-4 text-blue-800"><%= @status %></td>
        """

      "T - SYNC" ->
        ~H"""
        <td class="px-6 py-4 text-yellow-500"><%= @status %></td>
        """

      "R - PROCESSING" ->
        ~H"""
        <td class="px-6 py-4 text-blue-800"><%= @status %></td>
        """

      "R - STORE" ->
        ~H"""
        <td class="px-6 py-4 text-yellow-500"><%= @status %></td>
        """

      "R - OK" ->
        ~H"""
        <td class="px-6 py-4 text-green-800 font-bold"><%= @status %></td>
        """

      "R - ERROR" ->
        ~H"""
        <td class="px-6 py-4 text-red-600"><%= @status %></td>
        """

      _ ->
        ~H"""
        <td class="px-6 py-4">—</td>
        """
    end
  end

  defp retry_button(assigns) do
    if assigns.transmission.status == "T - ERROR" or assigns.transmission.status == "R - ERROR" do
      ~H"""
      <span>
        <%= link("Retransmitir",
          to: "#",
          phx_click: "retry",
          phx_value_id: assigns.transmission.id,
          data: [confirm: "Você tem certeza?"],
          class: ["font-medium text-green-700 hover:underline"]
        ) %>
      </span>
      """
    else
      ~H""
    end
  end
end
