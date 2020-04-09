defmodule Kandesk.Util do

  def to_integer(val) when is_integer(val), do: val
  def to_integer(val) when is_binary(val), do: String.to_integer(val)

  def temp_id(), do: "auto" <> :erlang.integer_to_binary(rem :erlang.unique_integer(), 1000000)

  def user_rights(%Kandesk.Schema.Board{} = b, rights), do: user_rights(b.board_user, rights)
  def user_rights(%Kandesk.Schema.BoardUser{} = bu, rights), do: Map.get(bu, rights)
  def user_rights(nil, _rights), do: true

  def tag_checked?(id, tags), do: Enum.any?(tags, & &1.id == id) and "checked"
  def tag_color(tag, tags), do: Enum.find(tags, & &1.id == tag.id).color
  def tag_name(tag, tags), do: Enum.find(tags, & &1.id == tag.id).name

  def limit_string(string, size) when size > 1 do
    case String.at(string, size) do
      nil -> string
      _ -> (String.slice(string, 0, size) |> String.trim_trailing) <> "..."
    end
  end

end
