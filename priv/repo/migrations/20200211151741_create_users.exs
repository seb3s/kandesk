defmodule Kandesk.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :text, null: false
      add :password_hash, :text

      add :firstname, :text
      add :lastname, :text
      add :avatar, :text
      add :language, :text
      add :active, :boolean
      add :role, :text

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
