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

    embeds_many :tags, Tag, primary_key: false, on_replace: :delete do
      field :id, :integer
    end

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:name, :descr, :position, :is_active, :creator_id, :column_id, :due_date])
    |> validate_required([:name, :position, :is_active, :creator_id, :column_id])
    |> cast_embed(:tags, with: &tag_changeset/2)
  end

  def tag_changeset(schema, params) do
    schema
    |> cast(params, [:id])
  end
end
