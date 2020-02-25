defmodule Kandesk.Repo do
  use Ecto.Repo,
    otp_app: :kandesk,
    adapter: Ecto.Adapters.Postgres
end
