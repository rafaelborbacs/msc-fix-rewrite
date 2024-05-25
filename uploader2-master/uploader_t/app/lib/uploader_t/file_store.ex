defmodule UploaderT.FileStore do
  def get(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Jason.decode(body), do: json
  end

  def set(filename, uploader_r) do
    with {:ok, json} <- Jason.encode(uploader_r), do: File.write(filename, json)
  end
end
