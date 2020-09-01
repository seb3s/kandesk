# Kandesk

![Kandesk board](https://raw.githubusercontent.com/seb3s/kandesk/master/assets/static/images/kandesk.board.png)

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

## Create a first admin user

To be able to connect to the application, a first admin user must be created.
This is done by running:

    mix run priv/repo/seeds.exs

Then you can connect with "admin@admin.com" as Email and "admin" as Password. Then you will be able to change everything from within the application, password included ;-)


## Access the application

Now you can visit [`localhost:4001`](http://localhost:4001) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
