defmodule KandeskWeb.IndexLive do
  use Phoenix.LiveView
  alias Kandesk.Schema.{User, Board, BoardUser, Column, Task, Comment, Tag}
  alias Kandesk.Repo
  import Ecto.Query
  import Kandesk.Util
  import KandeskWeb.Endpoint, only: [subscribe: 1, unsubscribe: 1, broadcast_from: 4]
  #require Logger Logger.info "params: #{inspect params}"

  @boards_topic "boards"

  def mount(params, session, socket) do
    case connected?(socket) do
      true -> connected_mount(params, session, socket)
      false -> {:ok, assign(socket, page: "loading")}
    end
  end

  def connected_mount(_params, %{"page" => "dashboard" = page, "user_id" => user_id}, socket) do
    boards = get_user_boards(user_id)
    subscribe(@boards_topic)

    {:ok, assign(socket,
      page: page,
      user_id: user_id,
      changeset: nil,
      show_modal: nil,
      boards: boards,
      board: nil,
      columns: [],
      column_id: nil,
      edit_row: nil,
      top_bottom: nil
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


  # get_user_boards
  # ---------------
  def get_user_boards(user_id) do
    q1 = from b in Board,
      where: [creator_id: ^user_id],
      select: b.id
    q2 = from b in Board,
      join: bu in BoardUser, on: bu.board_id == b.id and bu.user_id == ^user_id,
      select: b.id
    ids = Repo.all(union_all(q1, ^q2))

    Repo.all(from(b in Board,
      left_join: bu in BoardUser, on: bu.board_id == b.id and bu.user_id == ^user_id,
      where: b.id in ^ids,
      select_merge: %{board_user: bu},
      order_by: :name))
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

  def handle_event("show_modal", %{"modal" => "create_task" = modal, "column_id" => column_id, "top_bottom" => top_bottom}, socket) do
    {:noreply, assign(socket, show_modal: modal, changeset: Task.changeset(%Task{}, %{}),
      column_id: to_integer(column_id), top_bottom: top_bottom)}
  end

  def handle_event("show_modal", %{"modal" => "admin_tags" = modal}, %{assigns: assigns} = socket) do
    {:noreply, assign(socket, show_modal: modal, changeset: Board.changeset(assigns.board, %{}))}
  end


  ## boards
  ## ------
  def handle_event("create_board", %{"board" => form_data} = params, %{assigns: assigns} = socket) do
    case create_board(form_data, assigns) do
      {:ok, board} ->
        boards = get_user_boards(assigns.user_id)
        broadcast_from(self(), @boards_topic, "create_board", %{board: board, boards: boards})
        {:noreply, assign(socket, show_modal: nil, boards: boards)}
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
      is_public: false,
      tags: [
        %{id: 0,  color: "#7c1a9c", name: "Version"},
        %{id: 1,  color: "#c14bfb"},
        %{id: 2,  color: "#ed207b", name: "Critical"},
        %{id: 3,  color: "#ff8318", name: "Warning"},
        %{id: 4,  color: "#edc30a", name: "In progress"},
        %{id: 5,  color: "#3ab54a", name: "Done"},
        %{id: 6,  color: "#93042d", name: "Bug"},
        %{id: 7,  color: "#c58994", name: "Enhancement"},
        %{id: 8,  color: "#9a7773", name: "New feature"},
        %{id: 9,  color: "#274c6d", name: "Rejected"},
        %{id: 10, color: "#22a2d8", name: "Needs feedback"},
        %{id: 11, color: "#53718b"}]
    }

    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def handle_event("edit_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(assigns.boards, & &1.id == id)
    if user_rights(row, :edit_board?) do
      changeset = Board.changeset(row, %{})
      {:noreply, assign(socket, changeset: changeset, show_modal: "edit_board", edit_row: row)}
    else {:noreply, socket} end
  end

  def handle_event("update_board", %{"board" => form_data} = params, %{assigns: assigns} = socket) do
    case assigns.edit_row do %Board{} = row -> # in case phx-submit is hacked
      case update_board(form_data, assigns) do
        {:ok, board} ->
          boards = get_user_boards(assigns.user_id)
          broadcast_from(self(), @boards_topic, "update_board", %{board: board})
          {:noreply, assign(socket, show_modal: nil, boards: boards)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    _ -> {:noreply, socket} end
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
    row = Enum.find(assigns.boards, & &1.id == id)
    if user_rights(row, :delete_board?) do
      {:ok, res} = Repo.query("select sp_delete_board($1);", [id])
      boards = for b <- assigns.boards, b.id != id, do: b
      broadcast_from(self(), @boards_topic, "delete_board", %{id: id})
      {:noreply, assign(socket, boards: boards)}
    else {:noreply, socket} end
  end

  def handle_event("view_board", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    assigns.board && unsubscribe(assigns.board.token) # eventually unsubscribe previous board
    board = Enum.find(assigns.boards, & &1.id == id)
    if board do
      columns = Repo.all(from(Column, where: [board_id: ^id], order_by: :position))
        |> Repo.preload([{:tasks, from(t in Task, order_by: t.position)}])
      subscribe(board.token)
      {:noreply, assign(socket, page: "board", board: board, columns: columns)}
    else {:noreply, socket} end
  end

  def handle_event("view_dashboard", _params, %{assigns: assigns} = socket) do
    unsubscribe(assigns.board.token)
    {:noreply, assign(socket, page: "dashboard")}
  end


  ## tags
  ## ----
  def handle_event("set_board_tags", %{"board" => %{"tags"=> tags}}, %{assigns: assigns} = socket) do
    if user_rights(assigns.board, :admin_tags?) do
      case update_tags(tags, assigns) do
        {:ok, board} ->
          bid = board.id
          boards = (for b <- assigns.boards, do: if b.id == bid, do: board, else: b)
          broadcast_from(self(), @boards_topic, "update_board", %{board: board})
          {:noreply, assign(socket, show_modal: nil, boards: boards, board: board)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else {:noreply, socket} end
  end

  def update_tags(tags, assigns) do
    #sort by integer instead of string due to form conversion (case when > 9 tags)
    sorted_tags = Enum.map(tags, fn({k, v}) -> {to_integer(k), v} end)
      |> Enum.sort(fn({k, v}, {k1, v1}) -> k < k1 end)
      |> Enum.map(fn({k, v}) -> v end)

    assigns.board
    |> Board.changeset(%{tags: sorted_tags})
    |> Repo.update
  end


  ## columns
  ## -------
  def handle_event("create_column", %{"column" => form_data} = params, %{assigns: assigns} = socket) do
    if user_rights(assigns.board, :create_column?) do
      case create_column(form_data, assigns) do
        {:ok, column} ->
          columns = assigns.columns ++ [%{column | tasks: []}]
          broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
          {:noreply, assign(socket, show_modal: nil, columns: columns)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else {:noreply, socket} end
  end

  def create_column(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      position: length(assigns.columns) + 1,
      visibility: form_data["visibility"],
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
    if row && user_rights(assigns.board, :edit_column?) do
      changeset = Column.changeset(row, %{})
      {:noreply, assign(socket, changeset: changeset, show_modal: "edit_column", edit_row: row)}
    else {:noreply, socket} end
  end

  def handle_event("update_column", %{"column" => form_data} = params, %{assigns: assigns} = socket) do
    case assigns.edit_row do %Column{} = row -> # in case phx-submit is hacked
      case update_column(form_data, assigns) do
        {:ok, column} ->
          cid = assigns.edit_row.id
          columns = for c <- assigns.columns, do: if c.id == cid, do: column, else: c
          broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
          {:noreply, assign(socket, show_modal: nil, columns: columns)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    _ -> {:noreply, socket} end
  end

  def update_column(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      visibility: form_data["visibility"]
    }

    assigns.edit_row
    |> Column.changeset(attrs)
    |> Repo.update
  end

  def handle_event("move_column", %{"board_id" => board_id, "old_pos" => old_pos, "new_pos" => new_pos} = params, %{assigns: assigns} = socket)
  do
    row = Enum.find(assigns.boards, & &1.id == board_id)
    if row && user_rights(assigns.board, :move_column?) do
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
    else {:noreply, socket} end
  end

  def handle_event("delete_column", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(assigns.columns, & &1.id == id)
    if row && user_rights(assigns.board, :delete_column?) do
      {:ok, res} = Repo.query("select sp_delete_column($1);", [id])
      columns = for c <- assigns.columns, c.id != id, do: c
      broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
      {:noreply, assign(socket, columns: columns)}
    else {:noreply, socket} end
  end


  ## tasks
  ## -----
  def handle_event("create_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    if user_rights(assigns.board, :create_task?) do
      case create_task(form_data, assigns) do
        {:ok, task} ->
          cid = assigns.column_id
          if assigns.top_bottom === "top" do
            send self(), {"move_task", %{"task_id" => task.id, "old_col" => cid, "new_col" => cid, "old_pos" => task.position, "new_pos" => 1}}
            # columns refresh is done only once by move_task
            {:noreply, assign(socket, show_modal: nil)}
          else
            columns = for c <- assigns.columns, do:
              if c.id == cid, do: %{c | tasks: c.tasks ++ [task]}, else: c
            broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
            {:noreply, assign(socket, show_modal: nil, columns: columns)}
          end
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else {:noreply, socket} end
  end

  def create_task(form_data, assigns) do
    cid = assigns.column_id
    [column] = for c <- assigns.columns, c.id == cid, do: c
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      tags: form_data["tags"] || [], # when none is selected
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
    if row && user_rights(assigns.board, :edit_task?) do
      changeset = Task.changeset(row, %{})
      {:noreply, assign(socket, changeset: changeset, show_modal: "edit_task", edit_row: row)}
    else {:noreply, socket} end
  end

  def handle_event("update_task", %{"task" => form_data} = params, %{assigns: assigns} = socket) do
    case assigns.edit_row do %Task{} = row -> # in case phx-submit is hacked
      case update_task(form_data, assigns) do
        {:ok, task} ->
          cid = row.column_id
          tid = row.id
          columns = for c <- assigns.columns, do: if c.id == cid, do:
            %{c | tasks: (for t <- c.tasks, do: if t.id == tid, do: task, else: t)},
            else: c
          broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
          {:noreply, assign(socket, show_modal: nil, columns: columns)}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
     _ -> {:noreply, socket} end
  end

  def update_task(form_data, assigns) do
    attrs = %{
      name: form_data["name"],
      descr: form_data["descr"],
      tags: form_data["tags"] || [] # when none is selected
    }

    assigns.edit_row
    |> Task.changeset(attrs)
    |> Repo.update
  end

  def handle_event("move_task", %{"task_id" => task_id, "old_col" => old_col, "new_col" => new_col, "old_pos" => old_pos, "new_pos" => new_pos} = params, %{assigns: assigns} = socket)
  do
    id = to_integer(task_id)
    row = Enum.find(Enum.flat_map(assigns.columns, & &1.tasks), & &1.id == id)
    col1 = Enum.find(assigns.columns, & &1.id == old_col)
    col2 = Enum.find(assigns.columns, & &1.id == new_col)
    if row && col1 && col2 && user_rights(assigns.board, :move_task?) do
      do_event("move_task", params, socket)
    else {:noreply, socket} end
  end

  def do_event("move_task", %{"task_id" => task_id, "old_col" => old_col, "new_col" => new_col, "old_pos" => old_pos, "new_pos" => new_pos} = params, %{assigns: assigns} = socket)
  do
    {:ok, res} = Repo.query("select sp_move_task($1, $2, $3, $4, $5);", [task_id, old_col, new_col, old_pos, new_pos])
    columns = Repo.all(from(Column, where: [board_id: ^assigns.board.id], order_by: :position))
      |> Repo.preload([{:tasks, from(t in Task, order_by: t.position)}])
    broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
    {:noreply, assign(socket, columns: columns)}
  end


  def handle_event("delete_task", %{"id" => id} = params, %{assigns: assigns} = socket) do
    id = to_integer(id)
    row = Enum.find(Enum.flat_map(assigns.columns, & &1.tasks), & &1.id == id)
    if row && user_rights(assigns.board, :delete_task?) do
      {:ok, res} = Repo.query("select sp_delete_task($1);", [id])
      columns = for c <- assigns.columns, do: %{c | tasks: (for t <- c.tasks, t.id != id, do: t)}
      broadcast_from(self(), assigns.board.token, "set_columns", %{columns: columns})
      {:noreply, assign(socket, columns: columns)}
    else {:noreply, socket} end
  end


  ## handle_event catch all when system is hacked via phx-xxx modifications
  ## ----------------------------------------------------------------------
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end


  ## handle_info from broadcast
  ## --------------------------
  def handle_info(%{event: "set_columns", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_info(%{event: "create_board", payload: %{board: board, boards: boards}},
    %{assigns: assigns} = socket)
  do
    if assigns.user_id == board.creator_id,
      do:   {:noreply, assign(socket, boards: boards)},
      else: {:noreply, socket}
  end

  def handle_info(%{event: "update_board", payload: %{board: %{id: id} = board}},
    %{assigns: assigns} = socket)
  do
    boards = for b <- assigns.boards, do: if b.id == id, do: board, else: b
    board1 = if assigns.page == "board" and assigns.board.id == id, do: board, else: assigns.board
    {:noreply, assign(socket, %{boards: boards, board: board1})}
  end

  def handle_info(%{event: "delete_board", payload: %{id: id}}, %{assigns: assigns} = socket) do
    boards = for b <- assigns.boards, b.id != id, do: b
    if assigns.page == "board" and assigns.board.id == id,
      do:   (unsubscribe(assigns.board.token)
            {:noreply, assign(socket, page: "dashboard", boards: boards)}),
      else: {:noreply, assign(socket, boards: boards)}
  end


  ## handle_info from handle_event self() cast
  ## -----------------------------------------
  def handle_info({"move_task" = event, params}, socket), do: do_event(event, params, socket)

end
