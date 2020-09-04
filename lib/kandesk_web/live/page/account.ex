defmodule KandeskWeb.Page.Account do
  use Phoenix.LiveView
  alias Kandesk.Schema.{User, Board, BoardUser, Column, Task, Comment, Tag}
  alias Kandesk.Repo
  import Ecto.Query
  import Kandesk.Util
  import KandeskWeb.Endpoint, only: [subscribe: 1, unsubscribe: 1, broadcast_from: 4]

  @access_error "Unauthorized access detected"

  def handle_event("show_page", _params, %{assigns: assigns} = socket) do
    user = assigns.user
    changeset = User.changeset(user, %{})
    {:noreply, assign(socket, page: "account", changeset: changeset, edit_row: user)}
  end

  def handle_event("update_password", params, %{assigns: assigns} = socket) do
    %{"user" => form_data} = params
    row = assigns.edit_row
    unless %User{} = row, do: raise(@access_error)

    case row |> User.changeset(form_data) |> Repo.update() do
      {:ok, user} -> handle_event("view_dashboard", nil, assign(socket, user: user))
      {:error, %Ecto.Changeset{} = changeset} -> {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("update_personal_data", params, %{assigns: assigns} = socket) do
    %{"user" => form_data} = params
    row = assigns.edit_row
    unless %User{} = row, do: raise(@access_error)

    case row |> User.admin_changeset(form_data) |> Repo.update() do
      {:ok, user} ->
        Gettext.put_locale(user.language)
        handle_event("view_dashboard", nil, assign(socket, user: user))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event(event, params, socket),
    do: KandeskWeb.IndexLive.handle_event(event, params, socket)
end
