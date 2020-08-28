defmodule KandeskWeb.Component.Column do
  use Phoenix.LiveComponent

  def render(assigns) do
    Phoenix.View.render(KandeskWeb.LiveView, "component_column.html", assigns)
  end

end
