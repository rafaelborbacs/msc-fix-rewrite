defmodule UploaderR.Core.Deleter do
  # input path is the absolute path to the file to be deleted
  def delete(input_path) do
    File.rm(input_path)
  end

  def delete_all(input_path) do
    if is_list(input_path) do
      Enum.each(input_path, fn x -> File.rm_rf!(x) end)
    else
      File.rm_rf(input_path)
    end
  end
end
