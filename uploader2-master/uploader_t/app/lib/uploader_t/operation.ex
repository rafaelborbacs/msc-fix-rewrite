defmodule UploaderT.Operation do
  @moduledoc """
  The Operation context.
  """

  import Ecto.Query, warn: false
  alias UploaderT.Repo

  alias UploaderT.Operation.Transmission

  @doc """
  Returns the list of transmissions.

  ## Examples

      iex> list_transmissions()
      [%Transmission{}, ...]

  """
  def list_transmissions do
    Repo.all(Transmission)
  end

  def count_transmissions do
    Repo.aggregate(Transmission, :count, :id)
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


  def retain_transmissions(paths) do
    Repo.delete_all(from t in Transmission, where: t.file_path not in ^paths)
  end
end
