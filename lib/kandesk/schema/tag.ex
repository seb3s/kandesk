defmodule Kandesk.Schema.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :color, :string
    belongs_to :board, Kandesk.Schema.Board
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :color, :board_id])
    |> validate_required([:color, :board_id])
  end

end
