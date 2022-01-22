defmodule KandeskWeb.Component do
  use Phoenix.Component
  use Phoenix.HTML

  def modal(assigns) do
    ~H"""
    <div class="modal is-open" id="hook_modal" phx-hook="show_modal">
      <div class="modal-background" data-micromodal-close></div>
      <div class="modal-card">
        <header class="modal-card-head has-cursor-grab">
          <h2 class="modal-card-title">
            <%= render_slot(@title) %>
          </h2>
        </header>
        <section class="modal-card-body thin_scroll">
          <%= render_slot(@body) %>
        </section>
        <footer class="modal-card-foot level">
          <%= render_slot(@footer) %>
        </footer>
      </div>
    </div>

    """
  end
end
