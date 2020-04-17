defmodule Kandesk.Repo.Migrations.UpdateColumns1 do
  use Ecto.Migration

  def change do
    alter table(:columns) do
      remove :is_visible
      add :visibility, :text
    end
    execute ~s(update columns set visibility = 'all';)
  end
end
