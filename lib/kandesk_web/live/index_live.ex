defmodule KandeskWeb.IndexLive do
  use Phoenix.LiveView
  alias Kandesk.Schema.{User, Board, Column, Task, Comment, Tag}
  alias Kandesk.Repo
  import Ecto.Query
  import Kandesk.Util
  import KandeskWeb.Endpoint, only: [subscribe: 1, unsubscribe: 1, broadcast_from: 4]
  #require Logger Logger.info "params: #{inspect params}"


  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false -> {:ok, assign(socket, page: "loading")}
    end
  end

  def connected_mount(_params, %{"page" => "dashboard" = page, "user_id" => user_id}, socket) do
    boards = Repo.all(from(Board, where: [creator_id: ^user_id], order_by: :name))

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
      column_id: to_integer(column_id))}
  end


  ## boards
  ## ------
  def handle_event("create_board", %{"board" => form_data} = params, %{assigns: assigns} = socket) do
    case create_board(form_data, assigns) do
      {:ok, board} ->
        {:noreply, assign(socket, show_modal: nil,
          boards: Enum.sort(assigns.boards ++ [board], & &1.name < &2.name))}
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
      is_public: false
    }

    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("edit_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(assigns.boards, & &1.id == id)
    changeset = Board.changeset(row, %{})
    {:noreply, assign(socket, changeset: changeset, show_modal: "edit_board", edit_row: row)}
  end

  def handle_event("update_board", %{"board" => form_data} = params, %{assigns: assigns} = socket) do
    case update_board(form_data, assigns) do
      {:ok, board} ->
        bid = assigns.edit_row.id
        boards = (for b <- assigns.boards, do: if b.id == bid, do: board, else: b)
          |> Enum.sort(& &1.name < &2.name)
        {:noreply, assign(socket, show_modal: nil, boards: boards)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def update_board(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"]
    }

    assigns.edit_row
    |> Board.changeset(attrs)
    |> Repo.update
  end

  def handle_event("delete_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    {:ok, res} = Repo.query("select sp_delete_board($1);", [id])
    boards = for b <- assigns.boards, b.id != id, do: b
    {:noreply, assign(socket, boards: boards)}
  end

  def handle_event("view_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    board = Enum.find(assigns.boards, & &1.id == id)
    columns = Repo.all(from(Column, where: [board_id: ^id], order_by: :position))
      |> Repo.preload([{:tasks, from(t in Task, order_by: t.position)}])
    subscribe(board.token)
    {:noreply, assign(socket, page: "board", board: board, columns: columns)}
  end

  def handle_event("view_dashboard", _params, %{assigns: assigns} = socket) do
    unsubscribe(assigns.board.token)
    {:noreply, assign(socket, page: "dashboard")}
  end


  ## columns
  ## -------
  def handle_event("create_column", %{"column" => form_data} = params, %{assigns: assigns} = socket) do
    case create_column(form_data, assigns) do
      {:ok, column} ->
        columns = assigns.columns ++ [%{column | tasks: []}]
        broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
        {:noreply, assign(socket, show_modal: nil, columns: columns)}
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

  def handle_event("edit_column", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(assigns.columns, & &1.id == id)
    changeset = Column.changeset(row, %{})
    {:noreply, assign(socket, changeset: changeset, show_modal: "edit_column", edit_row: row)}
  end

  def handle_event("update_column", %{"column" => form_data} = params, %{assigns: assigns} = socket) do
    case update_column(form_data, assigns) do
      {:ok, column} ->
        cid = assigns.edit_row.id
        columns = for c <- assigns.columns, do: if c.id == cid, do: column, else: c
        broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
        {:noreply, assign(socket, show_modal: nil, columns: columns)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def update_column(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"]
    }

    assigns.edit_row
    |> Column.changeset(attrs)
    |> Repo.update
  end

  def handle_event("move_column", %{"board_id" => board_id, "old_pos" => old_pos, "new_pos" => new_pos} = params, %{assigns: assigns} = socket)
  do
    {:ok, res} = Repo.query("select sp_move_column($1, $2, $3);", [board_id, old_pos, new_pos])
    columns =
    if new_pos > old_pos do
      {l1, lres} = Enum.split(assigns.columns, old_pos - 1)
      {moved_column, lres} = List.pop_at(lres, 0)
      {l2, l3} = Enum.split(lres, new_pos - old_pos)
      l1 ++ l2 ++ [moved_column] ++ l3
    else
      {l1, lres} = Enum.split(assigns.columns, new_pos - 1)
      {l2, lres} = Enum.split(lres, old_pos - new_pos)
      {moved_column, l3} = List.pop_at(lres, 0)
      l1 ++ [moved_column] ++ l2  ++ l3
    end
    broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
    {:noreply, assign(socket, columns: columns)}
  end

  def handle_event("delete_column", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    {:ok, res} = Repo.query("select sp_delete_column($1);", [id])
    columns = for c <- assigns.columns, c.id != id, do: c
    broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
    {:noreply, assign(socket, columns: columns)}
  end


  ## tasks
  ## -----
  def handle_event("create_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    case create_task(form_data, assigns) do
      {:ok, task} ->
        cid = assigns.column_id
        columns = for c <- assigns.columns, do:
          if c.id == cid, do: %{c | tasks: c.tasks ++ [task]}, else: c
        broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
        {:noreply, assign(socket, show_modal: nil, columns: columns)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def create_task(form_data, assigns) do
    cid = assigns.column_id
    [column] = for c <- assigns.columns, c.id == cid, do: c
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      position: length(column.tasks) + 1,
      is_active: true,
      creator_id: assigns.user_id,
      column_id: assigns.column_id
    }

    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("edit_task", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(Enum.flat_map(assigns.columns, & &1.tasks), & &1.id == id)
    changeset = Task.changeset(row, %{})
    {:noreply, assign(socket, changeset: changeset, show_modal: "edit_task", edit_row: row)}
  end

  def handle_event("update_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    case update_task(form_data, assigns) do
      {:ok, task} ->
        cid = assigns.edit_row.column_id
        tid = assigns.edit_row.id
        columns = for c <- assigns.columns, do: if c.id == cid, do:
          %{c | tasks: (for t <- c.tasks, do: if t.id == tid, do: task, else: t)},
          else: c
        broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
        {:noreply, assign(socket, show_modal: nil, columns: columns)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def update_task(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"]
    }

    assigns.edit_row
    |> Task.changeset(attrs)
    |> Repo.update
  end

  def handle_event("move_task", %{"task_id" => task_id, "old_col" => old_col, "new_col" => new_col, "old_pos" => old_pos, "new_pos" => new_pos} = params, %{assigns: assigns} = socket)
  do
    {:ok, res} = Repo.query("select sp_move_task($1, $2, $3, $4, $5);", [task_id, old_col, new_col, old_pos, new_pos])
    columns = Repo.all(from(Column, where: [board_id: ^assigns.board.id], order_by: :position))
      |> Repo.preload([{:tasks, from(t in Task, order_by: t.position)}])
    broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
    {:noreply, assign(socket, columns: columns)}
  end

  def handle_event("delete_task", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    {:ok, res} = Repo.query("select sp_delete_task($1);", [id])
    columns = for c <- assigns.columns, do: %{c | tasks: (for t <- c.tasks, t.id != id, do: t)}
    broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
    {:noreply, assign(socket, columns: columns)}
  end


  ## handle_info
  ## -----------
  ## for columns & tasks
  def handle_info(%{event: "set_columns", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

end
