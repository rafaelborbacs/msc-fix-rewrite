defmodule UploaderR.Repo do
  use Ecto.Repo,
    otp_app: :uploader_r,
    adapter: Ecto.Adapters.Postgres
end
