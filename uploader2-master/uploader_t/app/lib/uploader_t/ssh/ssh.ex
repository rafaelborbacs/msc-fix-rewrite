defmodule UploaderT.SSH do
  alias UploaderT.SSH.Logger
  alias UploaderT.Config

  @moduledoc """
  Provides functions to manage SSH keys used for MyApplication
  """

  @ssh_keygen System.find_executable("ssh-keygen")
  @path Application.app_dir(:uploader_t, "priv/keys") <> "/"
  @key @path <> "id_rsa"

  @doc """
  Generates a new private/public key if they don't exist.
  """
  def generate_keys do
    if not keys_exist?() do
      create_keys()
    end

    keys_exist?()
  end

  @doc """
  Checks to see if the ssh keys exist
  """
  def keys_exist? do
    File.exists?(@key) && File.exists?(@key <> ".pub")
  end

  @doc """
  Returns the content of the SSH public key
  """
  def public_key do
    key =
      File.open!(@key <> ".pub", [:read])
      |> IO.read(:line)
      |> String.replace("\n", "")

    File.close(@key <> ".pub")
    key
  end

  def identifier(:self) do
    :crypto.hash(:md5, public_key()) |> Base.encode16() |> String.slice(0..10)
  end

  def verify_ssh_auth({user, host}) do
    System.cmd("ssh", ["-q", "-o", "BatchMode=yes", "#{user}@#{host}", "echo", "", "2>&1"])
  end

  defp create_keys do
    args = ["-t", "rsa", "-b", "4096", "-f", @key, "-C", "MyApplication", "-q", "-N", ""]
    Task.start_link(fn -> System.cmd(@ssh_keygen, args) end)
  end

  defp remove_old_keys do
    @path
    |> File.ls!()
    |> Enum.each(&File.rm!(@path <> &1))
  end
end
