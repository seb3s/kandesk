defmodule KandeskWeb.TaskComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(KandeskWeb.LiveView, "component_task.html", assigns)
  end

end
