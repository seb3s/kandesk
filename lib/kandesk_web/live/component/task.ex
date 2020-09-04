defmodule KandeskWeb.Component.Task do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(KandeskWeb.LiveView, "component_task.html", assigns)
  end
end
