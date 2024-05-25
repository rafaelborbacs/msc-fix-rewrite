defmodule UploaderT.Core.Sync do
  @last_attempt 5
  @sucess_code 0

  def synchronize(a, b, limit \\ nil, attempt \\ 0)


  def synchronize(source_path, {user, ip, port, destination_path}, limit, attempt) when is_binary(source_path) do
      {output, code} =
      if limit == nil do
        System.shell(
        ~s(rsync -r -e "ssh -o LogLevel=ERROR -p #{port} -i /app/priv/keys/id_rsa" #{source_path} #{user}@#{ip}:#{destination_path})
        )
      else
        System.shell(
        ~s(rsync --bwlimit=#{limit} -r -e "ssh -o LogLevel=ERROR -p #{port} -i /app/priv/keys/id_rsa" #{source_path} #{user}@#{ip}:#{destination_path})
        )
      end

      if code != @sucess_code do
        if attempt < @last_attempt do
          synchronize(source_path, {user, ip, port, destination_path}, limit, attempt + 1)
        else
          {:error, :synchronize, code}
        end
      else
        {:ok, :synchronize}
      end

  end

  def synchronize(:folder, {user, ip, port, destination_path}, limit, attempt) do
      number_of_files = case File.ls("/app/encrypted") do
        {:ok, files} ->
          length(files)
          IO.inspect("number of files: #{length(files)}")
        {:error, _} ->
          0
          IO.inspect("Error")
      end

      if number_of_files > 0 do
        {output, code} =
          if limit == nil do
            System.shell(
            ~s(rsync --delete-excluded -r -e "ssh -p #{port} -i /app/priv/keys/id_rsa" "/app/encrypted" #{user}@#{ip}:#{destination_path})
            )
          else
            System.shell(
            ~s(rsync --delete-excluded --bwlimit=#{limit} -r -e "ssh -p #{port} -i /app/priv/keys/id_rsa" "/app/encrypted" #{user}@#{ip}:#{destination_path})
            )
          end

          if code != @sucess_code do
            if attempt < @last_attempt do
              synchronize(:folder, {user, ip, port, destination_path}, limit, attempt + 1)
            else
              {:error, :synchronize, code}
            end
          else
            {:ok, :synchronize}
          end
      else
        {:ok, :ignore}
      end



  end


end
