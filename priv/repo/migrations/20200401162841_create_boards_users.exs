defmodule Kandesk.Repo.Migrations.CreateBoardsUsers do
  use Ecto.Migration

  def change do
    create table(:boards_users, primary_key: false) do
      add :board_id , references(:boards), primary_key: true
      add :user_id, references(:users), primary_key: true
      add :edit_board?, :boolean
      add :delete_board?, :boolean
      add :create_column?, :boolean
      add :edit_column?, :boolean
      add :delete_column?, :boolean
      add :move_column?, :boolean
      add :create_task?, :boolean
      add :edit_task?, :boolean
      add :delete_task?, :boolean
      add :move_task?, :boolean
      add :admin_tags?, :boolean
      add :assoc_tags?, :boolean
      add :all_comments?, :boolean
      add :own_comments?, :boolean

      timestamps()
    end
  end
end
