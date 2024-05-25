defmodule UploaderR.Core.Decrypter do
  @moduledoc """
  Provides Decryption Functionality
  """

  alias UploaderR.Core.Logger

  @gpg System.find_executable("gpg")

  @output_directory File.cwd!() <> "/decrypted/"

  def decrypt(input_path) do
    passphrase = System.get_env("ENCRYPTION_PASSPHRASE")

    output_path = compute_output_path(input_path)

    # Uses the GNU Privacy Guard (GPG) to decrypt the file
    System.cmd(
      @gpg,
      [
        "-o",
        output_path,
        "--batch",
        "--yes",
        "--passphrase",
        passphrase,
        "--decrypt",
        input_path
      ]
    )

    output_path
  end

  defp compute_output_path(original_path) do
    last_part = String.split(original_path, "/") |> Enum.take(-1) |> Enum.at(0) |> IO.inspect()
    @output_directory <> last_part
  end
end
