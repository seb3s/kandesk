defmodule Kandesk.Schema.BoardUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  @rights [
    :edit_board?,
    :delete_board?,
    :create_column?,
    :edit_column?,
    :delete_column?,
    :move_column?,
    :create_task?,
    :edit_task?,
    :delete_task?,
    :move_task?,
    :admin_tags?,
    :assoc_tags?,
    :all_comments?,
    :own_comments?
  ]

  schema "boards_users" do
    belongs_to :board, Kandesk.Schema.Board, primary_key: true
    belongs_to :user, Kandesk.Schema.User, primary_key: true
    quote do: (unquote_splicing(for right <- @rights, do: field right, :boolean))

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, quote do: [:board_id, :user_id, unquote_splicing(@rights)])
    |> validate_required([:board_id, :user_id])
  end

  def rights(), do: @rights

end
