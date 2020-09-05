defmodule Kandesk.Repo.Migrations.UpdateUsers1 do
  use Ecto.Migration

  def change do
    alter table(:users) do
       add :timezone, :text
    end

    execute ~s(UPDATE users set timezone = 'Europe/Paris';)
  end
end
