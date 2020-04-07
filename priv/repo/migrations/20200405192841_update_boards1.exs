defmodule Kandesk.Repo.Migrations.UpdateBoards1 do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :tags, :map
    end
  end
end
