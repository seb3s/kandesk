defmodule Kandesk.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    ## boards
    ## ------
    create table(:boards) do
      add :name, :text
      add :descr, :text
      add :token, :text
      add :is_active, :boolean
      add :is_public, :boolean
      add :creator_id, references(:users)

      timestamps()
    end

    create index(:boards, [:creator_id])


    ## columns
    ## -------
    create table(:columns) do
      add :name, :text
      add :descr, :text
      add :position, :integer
      add :is_visible, :boolean
      add :creator_id, references(:users)
      add :board_id , references(:boards)

      timestamps()
    end

    create index(:columns, [:board_id])


    ## tasks
    ## -----
    create table(:tasks) do
      add :name, :text
      add :descr, :text
      add :position, :integer
      add :is_active, :boolean
      add :creator_id, references(:users)
      add :column_id, references(:columns)
      add :due_date, :naive_datetime

      timestamps()
    end

    create index(:tasks, [:column_id])


    ## comments
    ## --------
    create table(:comments) do
      add :comment, :text
      add :task_id, references(:tasks)
      add :creator_id, references(:users)

      timestamps()
    end

    create index(:comments, [:task_id])


    ## tags
    ## ----
    create table(:tags) do
      add :name, :text, null: false
      add :color, :text, null: false
      add :board_id, references(:boards)
    end

    create index(:tags, [:board_id])
  end
end
