defmodule Kandesk.Util do

  def to_integer(val) when is_integer(val), do: val
  def to_integer(val) when is_binary(val), do: String.to_integer(val)

  def temp_id(), do: "auto" <> :erlang.integer_to_binary(rem :erlang.unique_integer(), 1000000)

  def user_rights(%Kandesk.Schema.Board{} = b, rights), do: user_rights(b.board_user, rights)
  def user_rights(%Kandesk.Schema.BoardUser{} = bu, rights), do: Map.get(bu, rights)
  def user_rights(nil, _rights), do: true

end
