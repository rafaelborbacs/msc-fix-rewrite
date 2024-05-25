defmodule UploaderT.Repo do
  use Ecto.Repo,
    otp_app: :uploader_t,
    adapter: Ecto.Adapters.Postgres
end
