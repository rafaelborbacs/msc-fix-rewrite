defmodule UploaderGWeb.TransmissionLive.FormComponent do
  use UploaderGWeb, :live_component

  alias UploaderG.Operation

  @impl true
  def update(%{transmission: transmission} = assigns, socket) do
    changeset = Operation.change_transmission(transmission)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"transmission" => transmission_params}, socket) do
    changeset =
      socket.assigns.transmission
      |> Operation.change_transmission(transmission_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"transmission" => transmission_params}, socket) do
    save_transmission(socket, socket.assigns.action, transmission_params)
  end

  defp save_transmission(socket, :edit, transmission_params) do
    case Operation.update_transmission(socket.assigns.transmission, transmission_params) do
      {:ok, _transmission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transmission updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_transmission(socket, :new, transmission_params) do
    case Operation.create_transmission(transmission_params) do
      {:ok, _transmission} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transmission created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def my_datetime_select(form, field, opts \\ []) do
    builder = fn b ->
      assigns = %{b: b}

      ~H"""
      <body class="font-semibold">Date:</body>
      <%= @b.(:day, class: "rounded-lg focus:ring-blue-500 focus:border-blue-500 ") %> /
      <%= @b.(:month, class: "rounded-lg focus:ring-blue-500 focus:border-blue-500 ") %> /
      <%= @b.(:year, class: "rounded-lg focus:ring-blue-500 focus:border-blue-500 ") %> Time:
      <%= @b.(:hour, class: "rounded-lg focus:ring-blue-500 focus:border-blue-500 ") %> :
      <%= @b.(:minute, class: "rounded-lg focus:ring-blue-500 focus:border-blue-500 ") %>
      """
    end

    datetime_select(form, field, [builder: builder] ++ opts)
  end
end
