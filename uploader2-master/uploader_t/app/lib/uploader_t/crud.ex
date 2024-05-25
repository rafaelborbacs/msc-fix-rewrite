defmodule UploaderT.CRUD do
  @moduledoc """
  The CRUD context.
  """

  import Ecto.Query, warn: false
  alias UploaderT.Repo

  alias UploaderT.CRUD.Modality

  @doc """
  Returns the list of modalities.

  ## Examples

      iex> list_modalities()
      [%Modality{}, ...]

  """
  def list_modalities do
    Repo.all(Modality)
  end

  @doc """
  Gets a single modality.

  Raises `Ecto.NoResultsError` if the Modality does not exist.

  ## Examples

      iex> get_modality!(123)
      %Modality{}

      iex> get_modality!(456)
      ** (Ecto.NoResultsError)

  """
  def get_modality!(id), do: Repo.get!(Modality, id)

  def get_modality!(ae_title, :ae_title), do: Repo.get_by(Modality, ae_title: ae_title)

  @doc """
  Creates a modality.

  ## Examples

      iex> create_modality(%{field: value})
      {:ok, %Modality{}}

      iex> create_modality(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_modality(attrs \\ %{}) do
    %Modality{}
    |> Modality.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a modality.

  ## Examples

      iex> update_modality(modality, %{field: new_value})
      {:ok, %Modality{}}

      iex> update_modality(modality, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_modality(%Modality{} = modality, attrs) do
    modality
    |> Modality.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a modality.

  ## Examples

      iex> delete_modality(modality)
      {:ok, %Modality{}}

      iex> delete_modality(modality)
      {:error, %Ecto.Changeset{}}

  """
  def delete_modality(%Modality{} = modality) do
    Repo.delete(modality)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking modality changes.

  ## Examples

      iex> change_modality(modality)
      %Ecto.Changeset{data: %Modality{}}

  """
  def change_modality(%Modality{} = modality, attrs \\ %{}) do
    Modality.changeset(modality, attrs)
  end
end
