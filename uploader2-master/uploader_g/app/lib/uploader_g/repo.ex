defmodule UploaderG.Repo do
  use Ecto.Repo,
    otp_app: :uploader_g,
    adapter: Ecto.Adapters.Postgres
end
