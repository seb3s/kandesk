defmodule Kandesk.Repo.Migrations.UpdateTasks1 do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :tags, :map
    end
  end
end
