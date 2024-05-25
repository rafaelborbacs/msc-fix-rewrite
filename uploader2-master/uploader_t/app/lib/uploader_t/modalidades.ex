defmodule UploaderT.Modalidades do
  @moduledoc """
  The Modalidades context.
  """

  import Ecto.Query, warn: false
  alias UploaderT.Repo

  alias UploaderT.Modalidades.Modalidade

  @doc """
  Returns the list of modalidades.

  ## Examples

      iex> list_modalidades()
      [%Modalidade{}, ...]

  """
  def list_modalidades do
    Repo.all(Modalidade)
  end

  @doc """
  Gets a single modalidade.

  Raises `Ecto.NoResultsError` if the Modalidade does not exist.

  ## Examples

      iex> get_modalidade!(123)
      %Modalidade{}

      iex> get_modalidade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_modalidade!(id), do: Repo.get!(Modalidade, id)

  @doc """
  Creates a modalidade.

  ## Examples

      iex> create_modalidade(%{field: value})
      {:ok, %Modalidade{}}

      iex> create_modalidade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_modalidade(attrs \\ %{}) do
    %Modalidade{}
    |> Modalidade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a modalidade.

  ## Examples

      iex> update_modalidade(modalidade, %{field: new_value})
      {:ok, %Modalidade{}}

      iex> update_modalidade(modalidade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_modalidade(%Modalidade{} = modalidade, attrs) do
    modalidade
    |> Modalidade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a modalidade.

  ## Examples

      iex> delete_modalidade(modalidade)
      {:ok, %Modalidade{}}

      iex> delete_modalidade(modalidade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_modalidade(%Modalidade{} = modalidade) do
    Repo.delete(modalidade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking modalidade changes.

  ## Examples

      iex> change_modalidade(modalidade)
      %Ecto.Changeset{data: %Modalidade{}}

  """
  def change_modalidade(%Modalidade{} = modalidade, attrs \\ %{}) do
    Modalidade.changeset(modalidade, attrs)
  end
end
