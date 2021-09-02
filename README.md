# Kandesk

Kandesk is a simple trello-like app that I created for my own needs and for learning elixir & liveview. It has a simple set of features. I use it every day (hosting it on a small raspberry pi3) and it is suitable for individuals or small teams.

![Kandesk board](https://raw.githubusercontent.com/seb3s/kandesk/master/assets/static/images/kandesk.board.png)

## Installation & requirements

[Elixir 1.12+](https://elixir-lang.org/install.html) is required to run Kandesk.

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

## Avatars

Avatars are currently saved to disk at "/srv/www/kandesk". You need to create this directory with the required rights to be able to save & use avatars with your installation.


## Access the application

Now you can visit [`localhost:4001`](http://localhost:4001) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Features set

Kandesk is a fully multilingual application. Please feel free to contribute to the project by submitting a new translation.

### Boards:

  * create / update / delete
  * sharable among users with fine grain access control (edit_board?, delete_board?, create_column?, edit_column?, delete_column?, move_column?, create_task?, edit_task?, delete_task?, move_task?, admin_tags?, assoc_tags?)
  * export board content to pseudo xml data

### Columns:

  * create / update / delete
  * visibility: a column can be made visible to its creator only
  * columns are sortable via drag & drop
  * duplicate a column
  * move a column to another board
  * export column content to pseudo xml data
  * realtime updates among users viewing the same board
  * cards counter in header

### Cards:

  * create / update / delete
  * cards are sortable via drag & drop within and between columns
  * tags association
  * realtime updates among users viewing the same board

### Tags:

  * create / update
  * two display modes: large with text or small without
  * new tags can be added
  * tags are sortable to control the order in which they appear on cards
  * realtime updates among users viewing the same board

### Account page:

  * page to maintain your personal data: names, avatar, language, timezone, password

### Admin area:

  * manage users : simple admin panel to be able to create / update / delete users


## Learn more about elixir, phoenix & liveview

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
