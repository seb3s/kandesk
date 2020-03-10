defmodule Kandesk.Schema.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :comment, :string
    belongs_to :task, Kandesk.Schema.Task
    belongs_to :creator, Kandesk.Schema.User

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:comment, :task_id, :creator_id])
    |> validate_required([:comment, :task_id, :creator_id])
  end

end
