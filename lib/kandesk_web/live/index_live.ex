defmodule KandeskWeb.IndexLive do
  use Phoenix.LiveView
  alias Kandesk.Schema.{User, Board, Column, Task, Comment, Tag}
  alias Kandesk.Repo
  import Ecto.Query
  require Logger


  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false -> {:ok, assign(socket, page: "loading")}
    end
  end

  def connected_mount(_params, %{"page" => "dashboard" = page, "user_id" => user_id}, socket) do
    boards = Repo.all(from(Board, where: [creator_id: ^user_id]))

    {:ok, assign(socket,
      page: page,
      user_id: user_id,
      changeset: nil,
      show_modal: nil,
      boards: boards,
      board: nil,
      columns: [],
      column_id: nil,
      edit_row: nil
    )}

  end

  def connected_mount(_params, _session, socket) do
    {:ok, assign(socket, page: "error")}
  end


  def render(%{page: "loading"} = assigns) do
    ~L"<div>La page est en cours de chargement, veuillez patienter...</div>"
  end

  def render(%{page: "error"} = assigns) do
    ~L"<div>Une erreur s'est produite</div>"
  end

  def render(%{page: page} = assigns) do
    Phoenix.View.render(KandeskWeb.LiveView, "page_" <> page <> ".html", assigns)
  end


  ## handle_event
  ## ------------
  def handle_event("close_modal", params, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, show_modal: nil)}
  end

  def handle_event("show_modal", %{"modal" => "create_board" = modal}, socket) do
    {:noreply, assign(socket, show_modal: modal, changeset: Board.changeset(%Board{}, %{}))}
  end

  def handle_event("show_modal", %{"modal" => "create_column" = modal}, socket) do
    {:noreply, assign(socket, show_modal: modal, changeset: Column.changeset(%Column{}, %{}))}
  end

  def handle_event("show_modal", %{"modal" => "create_task" = modal, "column_id" => column_id}, socket) do
    {:noreply, assign(socket, show_modal: modal, changeset: Task.changeset(%Task{}, %{}),
      column_id: Kandesk.Convert.to_integer(column_id))}
  end

  def handle_event("create_board", %{"board" => form_data} = params, %{assigns: assigns} = socket) do
    case create_board(form_data, assigns) do
      {:ok, board} ->
        {:noreply, assign(socket,
          boards: assigns.boards ++ [board],
          show_modal: nil)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def create_board(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      creator_id: assigns.user_id,
      token: Ecto.UUID.generate,
      is_active: true,
      is_public: true
    }

    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("delete_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = Kandesk.Convert.to_integer(id)
    %Board{id: id}
    |> Repo.delete()

    boards = Enum.filter(assigns.boards, fn el -> el.id !== id end)
    {:noreply, assign(socket, boards: boards)}
  end

  def handle_event("view_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = Kandesk.Convert.to_integer(id)
    board = Repo.get(Board, id)
    columns = Repo.all(from(Column, where: [board_id: ^id])) |> Repo.preload(:tasks)
    {:noreply, assign(socket, page: "board", board: board, columns: columns)}
  end

  def handle_event("view_dashboard", _params, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, page: "dashboard")}
  end

  def handle_event("create_column", %{"column" => form_data} = params, %{assigns: assigns} = socket) do
    case create_column(form_data, assigns) do
      {:ok, column} ->
        {:noreply, assign(socket,
          columns: assigns.columns ++ [column],
          show_modal: nil)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def create_column(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      position: length(assigns.columns) + 1,
      is_visible: true,
      creator_id: assigns.user_id,
      board_id: assigns.board.id
    }

    %Column{}
    |> Column.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("create_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    case create_task(form_data, assigns) do
      {:ok, task} ->
        column_id = assigns.column_id
        columns = Enum.map(assigns.columns, fn column->
          if column.id == column_id do
            %{column | tasks: column.tasks ++ [task]}
          else
            column
          end
        end)
        {:noreply, assign(socket,
          columns: columns,
          show_modal: nil)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def create_task(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      position: 1,
      is_active: true,
      creator_id: assigns.user_id,
      column_id: assigns.column_id
    }

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("edit_task", %{"id" => id} = params, %{assigns: assigns} = socket) do
    row = Repo.get(Task, id)
    changeset = Task.changeset(row, %{})
    {:noreply, assign(socket, changeset: changeset, show_modal: "edit_task", edit_row: row)}
  end

  def handle_event("update_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    case update_task(form_data, assigns) do
      {:ok, up_task} ->
        cid = assigns.edit_row.column_id
        tid = assigns.edit_row.id
        columns = Enum.map(assigns.columns, fn column->
          if column.id == cid do
            %{column | tasks: Enum.map(column.tasks, fn task ->
              if task.id == tid do up_task else task end
            end)}
          else
            column
          end
        end)
        {:noreply, assign(socket,
          columns: columns,
          show_modal: nil)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def update_task(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
    }

    assigns.edit_row
    |> Task.changeset(attrs)
    |> Repo.update
  end

end
