defmodule UploaderG.Operation do
  @moduledoc """
  The Operation context.
  """

  import Ecto.Query, warn: false
  alias UploaderG.Repo

  alias UploaderG.Operation.Transmission

  @doc """
  Returns the list of transmissions.

  ## Examples

      iex> list_transmissions()
      [%Transmission{}, ...]

  """
  def list_transmissions do
    Repo.all(Transmission |> order_by(asc: :study_instance_uid))
  end

  def list_trasnmissions() do
  end

  def list_transmissions(:by_origin, origin) do
    Repo.all(from(t in Transmission, where: t.origin == ^origin))
  end

  def list_transmissions(:stale_is_error) do
    ### Get all units
    units = UploaderG.Entities.list_units()
    ### For each unit
    Enum.each(
      units,
      fn unit ->
        from(t in Transmission,
          join: u in UploaderG.Entities.Unit,
          on: u.public_key_identifier == t.origin,
          where:
            t.status == "T - PROCESSING" and
              t.updated_at < fragment("NOW() - INTERVAL '1 MINUTE' * ?", u.processing_timeout)
        )
        |> Repo.update_all(set: [status: "T - ERROR"])
      end
    )

    # from(t in Transmission,
    #   where:
    #     t.status == "T - PROCESSING"
    #     and t.updated_at < fragment("now() - interval '5 minute'"))
    # |> Repo.update_all(set: [status: "T - ERROR"])

    Enum.each(
      units,
      fn unit ->
        from(t in Transmission,
          join: u in UploaderG.Entities.Unit,
          on: u.public_key_identifier == t.origin,
          where:
            t.status == "T - SYNC" and
              t.updated_at < fragment("NOW() - INTERVAL '1 MINUTE' * ?", u.sync_timeout)
        )
        |> Repo.update_all(set: [status: "T - ERROR"])
      end
    )

    # from(t in Transmission,
    # where: t.status == "T - SYNC" and t.updated_at < fragment("now() - interval '5 minute'")
    # )
    # |> Repo.update_all(set: [status: "T - ERROR"])

    Enum.each(
      units,
      fn unit ->
        from(t in Transmission,
          join: u in UploaderG.Entities.Unit,
          on: u.public_key_identifier == t.destination,
          where:
            t.status == "R - PROCESSING" and
              t.updated_at < fragment("NOW() - INTERVAL '1 MINUTE' * ?", u.processing_timeout)
        )
        |> Repo.update_all(set: [status: "R - ERROR"])
      end
    )

    # from(t in Transmission,
    #   where:
    #     t.status == "R - PROCESSING" and t.updated_at < fragment("now() - interval '5 minute'")
    # )
    # |> Repo.update_all(set: [status: "R - ERROR"])

    Enum.each(
      units,
      fn unit ->
        from(t in Transmission,
          join: u in UploaderG.Entities.Unit,
          on: u.public_key_identifier == t.destination,
          where:
            t.status == "R - STORE" and
              t.updated_at < fragment("NOW() - INTERVAL '1 MINUTE' * ?", u.store_timeout)
        )
        |> Repo.update_all(set: [status: "R - ERROR"])
      end
    )

    # from(t in Transmission,
    # where: t.status == "R - STORE" and t.updated_at < fragment("now() - interval '5 minute'")
    # )
    # |> Repo.update_all(set: [status: "R - ERROR"])

    Repo.all(Transmission |> order_by(asc: :study_instance_uid))
  end

  @doc """
  Gets a single transmission.

  Raises `Ecto.NoResultsError` if the Transmission does not exist.

  ## Examples

      iex> get_transmission!(123)
      %Transmission{}

      iex> get_transmission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transmission!(id), do: Repo.get!(Transmission, id)

  def get_transmission!(:by_uuid, uuid), do: Repo.get_by(Transmission, uuid: uuid)

  @doc """
  Creates a transmission.

  ## Examples

      iex> create_transmission(%{field: value})
      {:ok, %Transmission{}}

      iex> create_transmission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transmission(attrs \\ %{}) do
    %Transmission{}
    |> Transmission.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transmission.

  ## Examples

      iex> update_transmission(transmission, %{field: new_value})
      {:ok, %Transmission{}}

      iex> update_transmission(transmission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transmission(%Transmission{} = transmission, attrs) do
    transmission
    |> Transmission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transmission.

  ## Examples

      iex> delete_transmission(transmission)
      {:ok, %Transmission{}}

      iex> delete_transmission(transmission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transmission(%Transmission{} = transmission) do
    Repo.delete(transmission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transmission changes.

  ## Examples

      iex> change_transmission(transmission)
      %Ecto.Changeset{data: %Transmission{}}

  """
  def change_transmission(%Transmission{} = transmission, attrs \\ %{}) do
    Transmission.changeset(transmission, attrs)
  end
end
