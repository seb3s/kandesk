# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kandesk.Repo.insert!(%Kandesk.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Kandesk.Repo.insert!(%Kandesk.Schema.User{
  email: "admin@admin.com",
  password_hash:
    "$argon2id$v=19$m=131072,t=8,p=4$dpwcC7pR+VFv5UKNpd9bgQ$mc9rWpZqILOpxkEsAhKP0WG3kA6Jjn3C0kBWGU+ctuw",
  firstname: "Firstname",
  lastname: "Lastname",
  language: "en",
  timezone: "Europe/Paris",
  role: "admin"
})
