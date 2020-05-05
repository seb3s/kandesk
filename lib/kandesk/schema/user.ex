defmodule Kandesk.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset
  use Pow.Ecto.Schema,
    password_hash_methods: {&Argon2.hash_pwd_salt/1, &Argon2.verify_pass/2},
    password_min_length: 10
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowPersistentSession]

  schema "users" do
    pow_user_fields() #id, email, password_hash

    field :firstname, :string
    field :lastname, :string
    field :avatar, :string
    field :language, :string
    field :active, :boolean
    field :role, :string

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  def name_changeset(struct, attrs) do
    struct
    |> cast(attrs, [:firstname, :lastname])
    |> validate_required([:firstname, :lastname])
  end

end
