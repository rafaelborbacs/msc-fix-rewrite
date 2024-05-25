defmodule UploaderG.Entities do
  @moduledoc """
  The Entities context.
  """

  import Ecto.Query, warn: false
  alias UploaderG.Repo

  alias UploaderG.Entities.Unit

  @doc """
  Returns the list of units.

  ## Examples

      iex> list_units()
      [%Unit{}, ...]

  """
  def list_units do
    Repo.all(Unit)
  end

  def list_units(:requested_connection, :unit, unit_id) do
    requested_unit = get_unit!(unit_id)

    Repo.all(
      from requesting_unit in Unit,
        where:
          ^requested_unit.public_key_identifier == requesting_unit.transmits_to and
            requesting_unit.receiver_accepted == false
    )
  end

  def list_units(:connected, :unit, unit_id) do
    requested_unit = get_unit!(unit_id)

    Repo.all(
      from requesting_unit in Unit,
        where:
          ^requested_unit.public_key_identifier == requesting_unit.transmits_to and
            requesting_unit.receiver_accepted == true
    )
  end

  @doc """
  Gets a single unit.

  Raises `Ecto.NoResultsError` if the Unit does not exist.

  ## Examples

      iex> get_unit!(123)
      %Unit{}

      iex> get_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_unit!(id), do: Repo.get!(Unit, id)

  def get_unit(public_key, :by_public_key),
    do: Repo.get_by(Unit, public_key_identifier: public_key)

  def get_unit(public_key_identifier, :by_public_key_identifier),
    do: Repo.get_by(Unit, public_key_identifier: public_key_identifier)

  @doc """
  Creates a unit.

  ## Examples

      iex> create_unit(%{field: value})
      {:ok, %Unit{}}

      iex> create_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_unit(attrs \\ %{}) do
    %Unit{}
    |> Unit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a unit.

  ## Examples

      iex> update_unit(unit, %{field: new_value})
      {:ok, %Unit{}}

      iex> update_unit(unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_unit(%Unit{} = unit, attrs) do
    unit
    |> Unit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a unit.

  ## Examples

      iex> delete_unit(unit)
      {:ok, %Unit{}}

      iex> delete_unit(unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_unit(%Unit{} = unit) do
    Repo.delete(unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking unit changes.

  ## Examples

      iex> change_unit(unit)
      %Ecto.Changeset{data: %Unit{}}

  """
  def change_unit(%Unit{} = unit, attrs \\ %{}) do
    Unit.changeset(unit, attrs)
  end
end
