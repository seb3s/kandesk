defmodule KandeskWeb.Page.Admin_users do
  use KandeskWeb, :live_view
  alias Kandesk.Schema.{User, Board, BoardUser, Column, Task, Comment, Tag}
  alias Kandesk.Repo
  import Ecto.Query
  import Kandesk.Util
  import KandeskWeb.Endpoint, only: [subscribe: 1, unsubscribe: 1, broadcast_from: 4]

  @access_error "Unauthorized access detected"

  def handle_event("show_page", _params, %{assigns: assigns} = socket) do
    unless assigns.user.role == "admin", do: raise(@access_error)

    rows = get_users()
    {:noreply, assign(socket, page: "admin_users", rows: rows, edit_row: nil)}
  end

  def handle_event("create_user", params, %{assigns: assigns} = socket) do
    unless assigns.user.role == "admin", do: raise(@access_error)

    user = %User{}
    changeset = User.changeset(user, %{})
    {:noreply, assign(socket, changeset: changeset, edit_row: user, edit_mode: :create)}
  end

  def handle_event("update_user", %{"id" => id}, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(assigns.rows, &(&1.id == id))
    unless (%User{} = row) && assigns.user.role == "admin", do: raise(@access_error)

    changeset = User.changeset(row, %{})
    {:noreply, assign(socket, changeset: changeset, edit_row: row, edit_mode: :update)}
  end

  def handle_event("save_user", %{"user" => form_data} = params, %{assigns: assigns} = socket) do
    row = assigns.edit_row
    unless (%User{} = row) && assigns.user.role == "admin", do: raise(@access_error)

    case edit_user(form_data, assigns, row) do
      {:ok, user} ->
        socket = assign(socket, edit_row: nil)
        current_user = assigns.user
        # we could be currently updating ourselves
        if current_user.id == user.id do
          socket = assign(socket, user: user)

          if current_user.language != user.language do
            set_locale(user)
            # force page reload to refresh all translations
            send(self(), {"show_page", %{"delegate_event" => "Page.Admin_users"}})
            {:noreply, assign(socket, page: "loading")}
          else
            {:noreply, assign(socket, rows: get_users())}
          end
        else
          {:noreply, assign(socket, rows: get_users())}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete_user", %{"id" => id}, %{assigns: assigns} = socket) do
    unless assigns.user.role == "admin", do: raise(@access_error)

    id = to_integer(id)
    Repo.delete!(%User{id: id})
    rows = for r <- assigns.rows, r.id != id, do: r
    # eventually clear edited user
    edit_row =
      case assigns.edit_row do
        %User{id: id} -> nil
        row -> row
      end

    {:noreply, assign(socket, rows: rows, edit_row: edit_row)}
  end

  def handle_event("cancel", %{"panel" => "admin_edit_user"}, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, edit_row: nil)}
  end

  def get_users() do
    rows = Repo.all(from u in User, order_by: [u.lastname, u.firstname, u.email])
  end

  def edit_user(form_data, %{edit_mode: :create} = assigns, edit_row) do
    edit_row |> User.admin_changeset(form_data) |> Repo.insert()
  end

  def edit_user(form_data, %{edit_mode: :update} = assigns, edit_row) do
    edit_row |> User.admin_changeset(form_data) |> Repo.update()
  end
end
