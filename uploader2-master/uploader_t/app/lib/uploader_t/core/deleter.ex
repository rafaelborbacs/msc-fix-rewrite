defmodule UploaderT.Core.Deleter do
  # input path is the absolute path to the file to be deleted
  def delete(input_path) do
    File.rm(input_path)
  end
end
