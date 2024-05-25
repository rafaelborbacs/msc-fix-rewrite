defmodule UploaderT.Core.Compressor do
  @compressed_files_folder File.cwd!() <> "/compressed/"

  # input path is the absolute path to the file to be compressed
  def compress(input_path) do
    # Splits the absolute file path on "/"
    # Make a list with the last string on the previous list as its only element
    # Find such only element and assign it to the pattern "filename"
    # Therefore, obtains the filename
    filename = String.split(input_path, "/") |> Enum.at(-1)

    # The name of our compressed file will be the previous name with '.zip' appended to it
    zip_filename = "#{filename}.zip"

    # The first parameter is the name of the zip file to be generated.
    # The second parameter is the list of files to be zipped.
    {:ok, zipped_file_path} = :zip.create("#{zip_filename}", [String.to_charlist(input_path)])

    # Moves the file to the compressed folder
    File.rename(zipped_file_path, @compressed_files_folder <> zip_filename)

    @compressed_files_folder <> zip_filename
  end
end
