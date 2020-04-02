defmodule Kandesk.Schema.BoardUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "boards_users" do
    belongs_to :board, Kandesk.Schema.Board, primary_key: true
    belongs_to :user, Kandesk.Schema.User, primary_key: true
    field :edit_board?, :boolean
    field :delete_board?, :boolean
    field :create_column?, :boolean
    field :edit_column?, :boolean
    field :delete_column?, :boolean
    field :move_column?, :boolean
    field :create_task?, :boolean
    field :edit_task?, :boolean
    field :delete_task?, :boolean
    field :move_task?, :boolean
    field :admin_tags?, :boolean
    field :assoc_tags?, :boolean
    field :all_comments?, :boolean
    field :own_comments?, :boolean

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:board_id, :user_id, :edit_board?, :delete_board?, :create_column?, :edit_column?, :delete_column?, :move_column?, :create_task?, :edit_task?, :delete_task?, :move_task?, :admin_tags?, :assoc_tags?, :all_comments?, :own_comments?])
    |> validate_required([:board_id, :user_id])
  end

end
