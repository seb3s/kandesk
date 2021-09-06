defmodule Kandesk.Util do
  import KandeskWeb.Gettext

  def to_integer(val) when is_integer(val), do: val
  def to_integer(val) when is_binary(val), do: String.to_integer(val)

  def temp_id(), do: "auto" <> :erlang.integer_to_binary(rem(:erlang.unique_integer(), 1_000_000))

  def user_rights(%Kandesk.Schema.Board{} = b, rights) do
    case b.board_user do
      nil -> true
      %Kandesk.Schema.BoardUser{} = bu -> Map.get(bu, rights)
    end
  end

  def user_rights(nil, _rights), do: false

  def is_creator(%Kandesk.Schema.Board{} = b, user), do: b.creator_id == user.id

  def tag_checked?(id, tags), do: Enum.any?(tags, &(&1.id == id)) and "checked"

  ## if_attrs overcomes heex limitation with dynamic attributes that returns nil
  ## by returning [] instead
  defmacro if_attrs(clause, do: expression) do
    quote do
      if unquote(clause), do: unquote(expression), else: []
    end
  end

  def limit_string(nil, _size), do: nil

  def limit_string(string, size) when size > 1 do
    case String.at(string, size) do
      nil -> string
      _ -> (String.slice(string, 0, size) |> String.trim_trailing()) <> "..."
    end
  end

  def column_visibility_options(), do: [{"all", gettext("All")}, {"creator", gettext("Creator")}]
  def column_visibility_default(), do: "all"

  def column_visible?(column, user) do
    column.visibility == "all" || (column.visibility == "creator" && column.creator_id == user.id)
  end

  def column_visibility_class(column) do
    case column.visibility do
      "creator" -> "is_creator"
      _ -> ""
    end
  end

  def user_date(date, user) do
    date
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.shift_zone!(user.timezone)
    |> KandeskWeb.Cldr.DateTime.to_string!(locale: user.language)
  end

  def set_locale(socket, user) do
    Gettext.put_locale(user.language)
    Phoenix.LiveView.push_event(socket, "set_locale", %{locale: user.language})
  end

  ## ------------------------------------
  ## avatar
  ## ------------------------------------
  @upload_dir "/srv/www/kandesk"

  def avatar_filename() do
    uuid = Ecto.UUID.generate()
    dir = :binary.part(uuid, 0, 2)
    :filename.join([<<"avatar">>, dir, <<uuid::binary, ".jpeg">>])
  end

  def avatar_replace_image(image, old_filename, filename) do
    <<"data:image/jpeg;base64,", img64::binary>> = image
    {:ok, img} = Base.decode64(img64)
    destination = :filename.join([@upload_dir, filename])
    :ok = :filelib.ensure_dir(destination)
    {:ok, iodevice} = :file.open(destination, [:write, :raw])
    :ok = :file.write(iodevice, img)
    :file.close(iodevice)
    :file.delete(:filename.join([@upload_dir, old_filename]))
  end
end
