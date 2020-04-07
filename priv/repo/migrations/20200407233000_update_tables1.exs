defmodule Kandesk.Repo.Migrations.UpdateTables1 do
  use Ecto.Migration

  def change do
    drop table(:tags)
    execute ~s(UPDATE boards set tags = '[{"id": 0, "name": "Version", "color": "#7c1a9c"}, {"id": 1, "name": null, "color": "#c14bfb"}, {"id": 2, "name": "Critical", "color": "#ed207b"}, {"id": 3, "name": "Warning", "color": "#ff8318"}, {"id": 4, "name": "In progress", "color": "#edc30a"}, {"id": 5, "name": "Done", "color": "#3ab54a"}, {"id": 6, "name": "Bug", "color": "#93042d"}, {"id": 7, "name": "Enhancement", "color": "#c58994"}, {"id": 8, "name": "New feature", "color": "#9a7773"}, {"id": 9, "name": "Rejected", "color": "#274c6d"}, {"id": 10, "name": "Needs feedback", "color": "#22a2d8"}, {"id": 11, "name": null, "color": "#53718b"}]';)
  end
end
