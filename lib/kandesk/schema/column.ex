defmodule Kandesk.Schema.Column do
  use Ecto.Schema
  import Ecto.Changeset

  schema "columns" do
    field :name, :string
    field :descr, :string
    field :position, :integer
    field :visibility, :string
    belongs_to :creator, Kandesk.Schema.User
    belongs_to :board, Kandesk.Schema.Board
    has_many :tasks, Kandesk.Schema.Task

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :descr, :position, :visibility, :creator_id, :board_id])
    |> validate_required([:name, :position, :visibility, :creator_id, :board_id])
  end
end
