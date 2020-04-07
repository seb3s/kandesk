defmodule Kandesk.Schema.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :id, :integer
    field :color,  :string
    field :name, :string
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:id, :color, :name])
    |> validate_required([:id, :color])
  end

end
