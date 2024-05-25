defmodule UploaderT.Core.Encrypter do
  @ssg System.find_executable("gpg")
  @input_directory "#{File.cwd!()}/compressed"
  @output_directory "#{File.cwd!()}/encrypted"

  def encrypt(input_path) do
    # Splits the absolute file path on "/"
    # Make a list with the last string on the previous list as its only element
    # Find such only element and assign it to the pattern "filename"
    # Therefore, obtains the filename
    filename = String.split(input_path, "/") |> Enum.at(-1)

    # Get the encryption password from the environment
    passphrase = System.get_env("ENCRYPTION_PASSPHRASE")

    System.cmd("gpg", [
      "-o",
      "#{@output_directory}/#{filename}.gpg",
      "--batch",
      "--yes",
      "--passphrase",
      passphrase,
      "--symmetric",
      "--cipher-algo",
      "AES256",
      "#{@input_directory}/#{filename}"
    ])

    "#{@output_directory}/#{filename}.gpg"
  end
end
