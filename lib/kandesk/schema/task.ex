defmodule Kandesk.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :descr, :string
    field :position, :integer
    field :is_active, :boolean
    belongs_to :creator, Kandesk.Schema.User
    belongs_to :column, Kandesk.Schema.Column
    field :due_date, :naive_datetime

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :descr, :position, :is_active, :creator_id, :column_id, :due_date])
    |> validate_required([:name, :position, :is_active, :creator_id, :column_id])
  end

end
