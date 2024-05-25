defmodule UploaderR.SSH do
  alias UploaderR.SSH.Logger

  @moduledoc """
  Provides functions to manage SSH keys used for MyApplication
  """

  @ssh_keygen System.find_executable("ssh-keygen")
  @path Application.app_dir(:uploader_r, "priv/keys") <> "/"
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

  @doc """
  Receive the public key from the Uploader T
  """
  def save_public_key(key) do
    IO.inspect("Started save_public_key")

    # Verify if the key is already registered
    {:ok, contents} = File.read("/home/uploader_t_1/.ssh/authorized_keys")

    key_already_on_file =
      contents
      |> String.split("\n", trim: true)
      |> Enum.find(fn line -> line == key end)
      |> Kernel.!==(nil)

    if key_already_on_file do
      # Logger.log("Key already on file")
      {:info, "Key already on file"}
    else
      # Add the key to the authorized_keys file
      File.write("/home/uploader_t_1/.ssh/authorized_keys", "#{key}\n", [:append])
      # Reading the file to make sure it is written
      {:ok, file} = File.open("/home/uploader_t_1/.ssh/authorized_keys")
    end
  end

  def delete_public_key(key) do
    IO.inspect("Started delete_public_key")

    {:ok, contents} = File.read("/home/uploader_t_1/.ssh/authorized_keys")

    key_already_on_file =
      contents
      |> String.split("\n", trim: true)
      |> Enum.find(fn line -> line == key end)
      |> Kernel.!==(nil)

    if key_already_on_file do
      new_contents = String.replace(contents, "#{key}\n", "")
      File.write("/home/uploader_t_1/.ssh/authorized_keys", new_contents, [:write])
      # Reading the file to make sure it is written
      {:ok, file} = File.open("/home/uploader_t_1/.ssh/authorized_keys")
    else
      Logger.log("Key not on file")
      {:info, "Key not on file"}
    end
  end

  defp create_keys do
    # Verify folder /priv/keys exist
    if not File.exists?(@path) do
      File.mkdir(@path)
    end

    args_ssh = ["-m", "pem", "-b", "4096", "-f", @key, "-C", "MyApplication", "-q", "-N", ""]
    System.cmd(@ssh_keygen, args_ssh)
  end

  defp remove_old_keys do
    @path
    |> File.ls!()
    |> Enum.each(&File.rm!(@path <> &1))
  end
end
