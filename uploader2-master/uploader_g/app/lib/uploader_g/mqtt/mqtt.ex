defmodule UploaderG.MQTT do
  use GenServer
  alias UploaderG.SSH
  alias UploaderG.Logging
  alias UploaderG.Operation
  alias UploaderG.Operation.Transmission

  alias UploaderG.Entities
  alias UploaderG.Entities.Unit

  alias UploaderG.SSH

  alias Phoenix.PubSub

  @topic_regexes [
    # System logs
    # Corresponding MQTT Topic: "logs"
    {~r|^logs|, :logs},

    # Transmissions
    # Corresponding MQTT Topic: "transmission"
    {~r|^transmission|, :transmission},

    # Receiver Started
    # Corresponding MQTT Topic: "R/+/start"
    {~r|^R/\w+/start|, :unit_start},

    # Receiver Config Update
    # Corresponding MQTT Topic: "R/+/config"
    {~r|^R/\w+/config|, :r_config},

    # Transmissor Unit Start
    # "T/+/start",
    {~r|^T/\w+/start|, :unit_start},

    # Transmissor Config Update
    # Corresponding MQTT Topic: "T/+/config/source"
    {~r|^T/\w+/config/source|, :t_source_config},

    # Receiver Config Update
    # Corresponding MQTT Topic: "T/+/config/destination"
    {~r|^T/\w+/config/destination|, :t_destination_config},

    # Response for the request of a Connection between Transmissor and Receiver
    # Corresponding MQTT Topic: "+/connection_response"
    {~r|^\w+/connection_response|, :connection_response},

    # Request for a Connection between Transmissor and Receiver
    # Corresponding MQTT Topic: "+/connection_request"
    {~r|^\w+/connection_request|, :connection_request},

    # Logs of a certain Transmission coming from a certain Receiver
    {~r|^R/\w+/transmission/\w+/logs|, :transmission_logs},

    # Logs of a certain Transmission coming from a certain Transsmissor
    {~r|^T/\w+/transmission/\w+/logs|, :transmission_logs},

    # Logs of a certain Transmissor
    {~r|^T/\w+/logs|, :transmitter_logs},

    # Logs of a certain Receiver
    {~r|^R/\w+/logs|, :receiver_logs}
  ]

  @moduledoc """
  This module implements a MQTT Client Abstraction for Elixir Apps.
  """

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: TxMQTT)
  end

  def init(args) do
    # Spawn a MQTT client process

    {:ok, client_pid} = :emqtt.start_link(args)
    # POSSIBLY asks for the MQTT client to send messages to the UploaderT.MQTT process
    {:ok, _} = :emqtt.connect(client_pid)

    # Sets the inital state of the UploaderT.MQTT process
    # Task.start(fn -> Enum.each(args[:initial_topics], fn topic -> subscribe(topic) end) end)
    Task.start(fn -> Enum.each(args[:initial_topics], fn topic -> subscribe(topic) end) end)

    {
      :ok,
      %{client_pid: client_pid}
    }
  end

  def handle_info(
        {:publish, %{payload: payload, topic: topic}},
        %{client_pid: client_pid} = state
      )
      when is_binary(payload) and is_binary(topic) do
    IO.inspect("————————————————————————————————————————————————————————")
    IO.inspect("MQTT Message:")
    IO.inspect(topic)
    IO.inspect(payload)
    IO.inspect("————————————————————————————————————————————————————————")

    topic
    |> parse_topic()
    |> do_handle(payload)
    |> IO.inspect()

    {:noreply, state}
  end

  def handle_info(unknown_message, state) do
    IO.inspect("An unknown message was caught by an all-catch clause on #{__MODULE__}")
    IO.inspect("The unkwon_message was:")
    IO.inspect(unknown_message)
    IO.inspect("The state of this process at such moment was:")
    IO.inspect(state)

    {:noreply, state}
  end

  def do_handle({:logs, _}, payload) do
    # Decodes the payload string into a JSON object map and then
    # persiss the log message into the database
    {:ok, struct} =
      payload
      |> Jason.decode!()
      |> Logging.create_log()

    PubSub.broadcast(UploaderG.PubSub, "log:arrived", {:log_arrived, struct})

    {:ok, :logs}
  end

  def do_handle({:transmission_logs, literal}, payload) do
    # get the unit transmission identifier from literal
    # Keep in mind the literal is on the form:
    # T/:public_key_identifier/transmission/:transmission_identifier/logs
    # Split the literal on the "/" character
    transmission_identifier =
      String.split(literal, "/")
      # Get the second element of the array
      # (Corresponding to the public key identifier)
      |> Enum.fetch!(3)

    transmission = Operation.get_transmission!(:by_uuid, transmission_identifier)

    unit = Entities.get_unit(transmission.origin, :by_public_key_identifier)

    # Decodes the payload string into a JSON object map and then
    # persiss the log message into the database
    {:ok, struct} =
      payload
      |> Jason.decode!()
      |> Map.put("transmission_id", transmission.id)
      |> Map.put("unit_id", unit.id)
      |> Map.put("origin", unit.public_key_identifier)
      |> Logging.create_log()

    PubSub.broadcast(UploaderG.PubSub, "log:arrived", {:log_arrived, struct})

    {:ok, :transmission_logs}
  end

  def do_handle({:transmission, _}, payload) do
    # Decodes the payload string into a JSON object map and then
    # persists the transmission message into the database

    payload
    |> Jason.decode!()
    |> handle_transmission()

    {:ok, :transmission}
  end

  def do_handle({:unit_start, _}, payload) do
    # Decodes the payload string into a JSON object map
    # Get the public key in the payload
    decoded_payload = payload |> Jason.decode!()

    IO.inspect("Unit starting")
    IO.inspect(payload)

    t_public_key = Map.fetch!(decoded_payload, "public_key")

    t_public_key_identifier = SSH.identifier(:public_key, t_public_key)

    # Search for a unit with the same public key
    if Entities.get_unit(t_public_key, :by_public_key) == nil do
      # In case the unit is not found, create a new unit
      decoded_payload
      |> Map.put("public_key_identifier", t_public_key_identifier)
      |> Entities.create_unit()
      |> case do
        {:ok, struct} ->
          PubSub.broadcast(
            UploaderG.PubSub,
            "unit:created",
            {:unit_created, struct}
          )

        Logging.create_log(
          %{
            event: "Nova Unidade",
            logged_at: DateTime.utc_now(),
            message: "UUID: #{t_public_key_identifier}",
            origin: t_public_key_identifier,
          }
        )

        {:error, changeset} ->
          IO.inspect("An error occurred while creating the unit")
          IO.inspect(changeset)
      end
    end

    {:ok, :unit_start}
  end

  def do_handle({:t_source_config, literal}, payload) do
    # Decode the payload string into a key-value map
    decoded_payload = payload |> Jason.decode!()
    # get the unit identifier from literal
    # Keep in mind the literal is on the form:
    # T/:public_key_identifier/config/source
    # Split the literal on the "/" character
    {:ok, struct} =
      String.split(literal, "/")
      # Get the second element of the array
      # (Corresponding to the public key identifier)
      |> Enum.fetch!(1)
      # Search for the unit with the same public key identifier
      |> Entities.get_unit(:by_public_key_identifier)
      # Update the unit with the new source configuration
      |> Entities.update_unit(decoded_payload)

    PubSub.broadcast(
      UploaderG.PubSub,
      "unit:updated",
      {:unit_updated, struct}
    )

    {:ok, :t_source_config}
  end

  def do_handle({:t_destination_config, literal}, payload) do
    # Decode the payload string into a key-value map
    decoded_payload = payload |> Jason.decode!()

    # get the target unit identifier from literal
    target_unit_identifier = Map.fetch!(decoded_payload, "target_public_key_identifier")

    # get the origin unit, for doing so
    # get the origin unit origin identifier from literal
    # Keep in mind the literal is on the form:
    # T/:public_key_identifier/config/destination
    # Split the literal on the "/" character
    {:ok, struct} =
      String.split(literal, "/")
      # Get the second element of the array
      # (Corresponding to the public key identifier)
      |> Enum.fetch!(1)
      # Search for the unit with the same public key identifier
      |> Entities.get_unit(:by_public_key_identifier)
      |> Entities.update_unit(%{transmits_to: target_unit_identifier})

    # If the unit is authorized, trigger key exchange
    if struct.authorized do
      # Get the unit target_unit_identifier from the struct
      target_unit_identifier = struct.transmits_to

      # Get the origin unit identifier from the struct
      origin_unit_identifier = struct.public_key_identifier

      # Get the public key from the struct
      public_key = struct.public_key

      # Use MQTT to send the connect command to the target unit
      Task.start_link(fn ->
        publish(
          "G/connect/T/#{origin_unit_identifier}/R/#{target_unit_identifier}",
          public_key
        )
      end)
    end

    # get the destination unit identifier from the payload

    # Update the unit with the new destination configuration
    PubSub.broadcast(
      UploaderG.PubSub,
      "unit:updated",
      {:unit_updated, struct}
    )

    {:ok, :t_destination_config}
  end

  def do_handle({:r_config, literal}, payload) do
    # Decode the payload string into a key-value map
    decoded_payload = payload |> IO.inspect() |> Jason.decode!()

    # get the unit identifier from literal
    # Keep in mind the literal is on the form:
    # R/:public_key_identifier/config
    # Split the literal on the "/" character
    {:ok, struct} =
      String.split(literal, "/")
      # Get the second element of the array
      # (Corresponding to the public key identifier)
      |> Enum.fetch!(1)
      # Search for the unit with the same public key identifier
      |> Entities.get_unit(:by_public_key_identifier)
      |> Entities.update_unit(decoded_payload)

    PubSub.broadcast(
      UploaderG.PubSub,
      "unit:updated",
      {:unit_updated, struct}
    )

    {:ok, :r_config}
  end

  def do_handle({type, literal}, payload) do
    IO.inspect("#{literal} matched #{type}")
    {:error, :unknown_type}
  end

  def handle_call(
        {:subscribe, properties, subscriptions},
        _from,
        %{client_pid: client_pid} = state
      )
      when is_map(properties) and is_list(subscriptions) do
    {:ok, _, _} = :emqtt.subscribe(client_pid, properties, subscriptions)
    {:reply, :ok, state}
  end

  def handle_call(
        {:publish, topic, properties, payload, pubopts},
        _from,
        %{client_pid: client_pid} = state
      )
      when is_binary(topic) and is_map(properties) and is_binary(payload) and is_list(pubopts) do
    :emqtt.publish(client_pid, topic, properties, payload, pubopts)
    {:reply, :ok, state}
  end

  @doc """
  Subscribes to a specific MQTT Topic

  ## Examples

    iex> UploaderT.MQTT.subscribe("test") \n
    :ok
  """
  def subscribe(topic, subopts \\ [rh: 0, rap: 0, nl: 0, qos: 2])
      when is_binary(topic) and is_list(subopts) do
    GenServer.call(TxMQTT, {:subscribe, %{}, [{topic, subopts}]})
  end

  @doc """
  Publishes a message to a specific MQTT Topic

  ## Examples

    iex> UploaderT.MQTT.publish("test", "Hello World") \n
    :ok
  """
  def publish(topic, payload, pubopts \\ [qos: 2, retain: false])
      when is_binary(topic) and is_binary(payload) do
    GenServer.call(TxMQTT, {:publish, topic, %{}, payload, pubopts})
  end

  defp handle_transmission(
         %{
           "checksum" => _checksum,
           "destination" => _destination,
           "origin" => origin,
           "size" => _size,
           "start" => _start,
           "status" => status,
           "uuid" => uuid,
           "study_instance_uid" => study_instance_uid,
           "study_description" => study_description
         } = transmission
       )
       when status == "T - PROCESSING" do
    # Get the unit with the same public key identifier as the origin
    unit =
      origin
      |> Entities.get_unit(:by_public_key_identifier)

    # If the unit existis and it is authorized
    if unit != nil and unit.authorized == true do
      IO.inspect("Unit authorized")

      case Operation.create_transmission(transmission) do
        {:ok, struct} ->
          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:created",
            {:transmission_created, struct}
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    else
      IO.inspect("Unit not authorized")
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status
         } = future_transmission
       )
       when status == "R - PROCESSING" do
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission do
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status
         } = future_transmission
       )
       when status == "R - STORE" do
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status,
           "end" => _end
         } = future_transmission
       )
       when status == "T - OK" do
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status,
           "end" => _end
         } = future_transmission
       )
       when status == "R - OK" do
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      origin = Entities.get_unit(past_transmission.origin, :by_public_key_identifier)

      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

          Task.start_link(fn ->
            publish(
              "G/delete/T/#{origin.public_key_identifier}/transmission/#{uuid}",
              Jason.encode!(%{
                uuid: uuid
              })
            )
          end)

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status,
           "end" => _end
         } = future_transmission
       )
       when status == "T - ERROR" do
    # Get the previous state of the Transmission
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      # Try to update with the current state
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          # Notify the subscribed processes
          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

          Logging.create_log(
            %{
              event: "Erro no Transmissor",
              logged_at: DateTime.utc_now(),
              message: "Transmissor #{past_transmission.destination}",
              origin: past_transmission.destination,
            }
          )



        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status,
           "end" => _end
         } = future_transmission
       )
       when status == "R - ERROR" do
    # Get the previous state of the Transmission
    IO.inspect("TESTE")
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      # Try to update with the current state
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          # Notify the subscribed processes
          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

          Logging.create_log(
            %{
              event: "Erro no Receptor",
              logged_at: DateTime.utc_now(),
              message: "Receptor #{past_transmission.destination}",
              origin: past_transmission.destination,
            }
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(
         %{
           "uuid" => uuid,
           "status" => status,
           "end" => _end
         } = future_transmission
       )
       when status == "T - SYNC" do
    # Get the previous state of the Transmission
    past_transmission = Operation.get_transmission!(:by_uuid, uuid)

    if past_transmission != nil do
      # Try to update with the current state
      case Operation.update_transmission(past_transmission, future_transmission) do
        {:ok, struct} ->
          Operation.update_transmission(past_transmission, future_transmission)

          # Notify the subscribed processes
          PubSub.broadcast(
            UploaderG.PubSub,
            "transmission:updated",
            {:transmission_updated, struct}
          )

        {:error, changeset} ->
          IO.inspect(changeset)
      end
    end
  end

  defp handle_transmission(transmission) do
    IO.inspect("Invalid Transmission Update: ")
    IO.inspect(transmission)
  end

  defp hash(long) do
    # :crypto.hash(:md5, long) |> Base.encode16() |> String.slice(0..10)
    long
  end

  defp parse_unit_map(map) do
    # Map.replace!(map, "public_key", hash(map["public_key"]))
    map
  end

  defp parse_topic(topic) do
    {_, type} =
      Enum.find(
        @topic_regexes,
        {nil, :unknown},
        fn {reg, type} -> String.match?(topic, reg) end
      )

    {type, topic}
  end
end
