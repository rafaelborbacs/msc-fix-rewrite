defmodule UploaderG.Logging do
  @moduledoc """
  The Logging context.
  """

  import Ecto.Query, warn: false
  alias UploaderG.Repo

  alias UploaderG.Logging.Log
  alias UploaderG.Entities.Unit

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs()
      [%Log{}, ...]

  """
  def list_logs do
    Repo.all(Log |> order_by(desc: :logged_at))
  end

  def list_logs(:accepted_connections) do
    Repo.all(
      from(l in Log,
        join: u in Unit,
        on: u.public_key == l.origin,
        where: u.authorized == true
      )
    )
  end

  def list_logs(unit_id, :by_unit) do
    Repo.all(
      from(l in Log,
        where: l.unit_id == ^unit_id
      )
      |> order_by(desc: :logged_at)
    )
  end

  def list_logs(transmission_id, :by_transmission) do
    Repo.all(
      from(l in Log,
        where: l.transmission_id == ^transmission_id
      )
      |> order_by(desc: :logged_at)
    )
  end

  def list_logs(:error) do
    Repo.all(
      from(l in Log,
        where: like(l.event, "Erro%")
      )
      |> order_by(desc: :logged_at)
    )
  end

  def list_logs(:info) do
    Repo.all(
      from(l in Log,
        where: not like(l.event, "Erro%")
      )
      |> order_by(desc: :logged_at)
    )
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResult  # def list_logs(:accepted_connections) do
  #   query = from l in Log, join: u in Unit, on l.
  #   Repo.all(query)
  # endsError` if the Log does not exist.

  ## Examples

      iex> get_log!(123)
      %Log{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_log!(id), do: Repo.get!(Log, id)

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %Log{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_log(attrs \\ %{}) do
    %Log{}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs) do
    log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a log.

  ## Examples

      iex> delete_log(log)
      {:ok, %Log{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log(%Log{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{data: %Log{}}

  """
  def change_log(%Log{} = log, attrs \\ %{}) do
    Log.changeset(log, attrs)
  end
end
