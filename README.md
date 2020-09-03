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


## Features set

### Boards:

  * create / update / delete
  * sharable among users with fine grain access control (edit_board?, delete_board?, create_column?, edit_column?, delete_column?, move_column?, create_task?, edit_task?, delete_task?, move_task?, admin_tags?, assoc_tags?)
  * export board content to pseudo xml data

### Columns:

  * create / update / delete
  * visibility: a column can be made visible to its creator only
  * columns are sortable via drag & drop
  * duplicate column
  * ability to move a column to another board
  * export column content to pseudo xml data
  * realtime updating among users viewing the same board

### Cards:

  * create / update / delete
  * cards are sortable via drag & drop within and between columns
  * tags association
  * realtime updating among users viewing the same board

### Tags:

  * create / update
  * two display modes: large with text or small without
  * new tags can be added
  * tags are sortable to control the order in which they appear on cards
  * realtime updating among users viewing the same board

### Account page:

  * basic page to maintain your personal data (currently names & password)

### Admin area:

  * manage users : basic admin panel to be able to create / update / delete users


## Learn more about elixir, phoenix & liveview

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
