defmodule UploaderT.MQTT do
  use GenServer
  @moduledoc """
  This module implements a MQTT Client Abstraction for Elixir Apps.
  """

  alias UploaderT.SSH

  alias UploaderT.Operation

  alias Phoenix.PubSub

  @topic_regexes [
    # Retry transmission commands from the Manager Unit(G)
    # G/retry/T/#{origin.public_key_identifier}/transmission/#{transmission.uuid}
    {~r|G/retry/T/\w+/transmission/\w+|, :retry},
    {~r|G/delete/T/\w+/transmission/\w+|, :delete}
  ]

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
    # Sets the inital state of the UploaderT.MQTT process
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
    topic
    |> parse_topic()
    |> do_handle(payload)

    {:noreply, state}
  end

  def handle_info(
        {:publish, %{payload: payload, topic: topic}},
        %{client_pid: client_pid} = state
      )
      when is_binary(payload) and is_binary(topic) do
    IO.inspect("OTHER CASES..............")

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

  def do_handle({:retry, literal}, payload) do
    # get the target unit(T) identifier from literal
    # Keep in mind the literal is on the form:
    # "G/retry/T/:target_unit_identifier/transmission/:target_transmission_identifier"
    # Split the literal on the "/" character
    target_unit_identifier = String.split(literal, "/")
    # Get the fourth element of the array
    # (Corresponding to the unit identifier)
    |> Enum.fetch!(3)

    # get the target unit(T) identifier from literal
    # Keep in mind the literal is on the form:
    # "G/retry/T/:target_unit_identifier/transmission/:target_transmission_identifier"
    # Split the literal on the "/" character
    target_transmission_identifier = String.split(literal, "/")
    # Get the sixth element of the array
    # (Corresponding to the unit identifier)
    |> Enum.fetch!(5)

    # If the target unit is this unit(R)
    if target_unit_identifier == SSH.identifier(:self) do

      # Get the target unit by it's identifier/UUID
      target_transmission = Operation.get_transmission!(:by_uuid, target_transmission_identifier)

      # Retry the transmission
      PubSub.broadcast(
        UploaderT.PubSub,
        "retry:transmission",
        {:retry_transmission, target_transmission}
      )
    end

  end

  def do_handle({:delete, literal}, payload) do
      # get the target unit(T) identifier from literal
    # Keep in mind the literal is on the form:
    # "G/delete/T/:target_unit_identifier/transmission/:target_transmission_identifier"
    # Split the literal on the "/" character
    target_unit_identifier = String.split(literal, "/")
    # Get the fourth element of the array
    # (Corresponding to the unit identifier)
    |> Enum.fetch!(3)

    # get the target unit(T) identifier from literal
    # Keep in mind the literal is on the form:
    # "G/delete/T/:target_unit_identifier/transmission/:target_transmission_identifier"
    # Split the literal on the "/" character
    target_transmission_identifier = String.split(literal, "/")
    # Get the sixth element of the array
    # (Corresponding to the unit identifier)
    |> Enum.fetch!(5)

    # If the target unit is this unit(R)
    if target_unit_identifier == SSH.identifier(:self) do

      # Get the target unit by it's identifier/UUID
      target_transmission = Operation.get_transmission!(:by_uuid, target_transmission_identifier)

      if target_transmission != nil do
        # Delete the transmission
        PubSub.broadcast(
          UploaderT.PubSub,
          "delete:transmission",
          {:delete_transmission, target_transmission}
        )
      end

    end
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
