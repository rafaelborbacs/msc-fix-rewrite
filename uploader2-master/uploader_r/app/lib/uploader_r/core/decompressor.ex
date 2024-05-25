defmodule UploaderR.Core.Decompressor do
  alias UploaderR.Core.Logger

  @decompressed_files_folder File.cwd!() <> "/decompressed/"

  def decompress(input_path) do
    unzip_output = :zip.unzip(to_charlist(input_path))


    case unzip_output do
      {:ok, file_list_charlist} ->
        # Logger.log("Decompression successful")
        file_list_string = Enum.map(file_list_charlist, fn file_name -> to_string(file_name) end)
        # For each file in the list, move to the decompressed folder
        Enum.each(
          file_list_string,
          fn file_name -> File.rename(file_name, get_decompressed_path(file_name)) end
        )

        {:ok, Enum.map(file_list_string, fn file_name -> get_decompressed_path(file_name) end)}
      {:error, _} ->
        # Logger.log("Decompression failed")
        {:ok, []}
    end




  end

  defp get_decompressed_path(original_path) do
    last_part = String.split(original_path, "/") |> Enum.take(-1) |> Enum.at(0)
    (@decompressed_files_folder <> last_part)
  end
end
