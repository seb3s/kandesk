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
    field :active, :boolean, default: true
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

  def admin_changeset(struct, attrs) do
    struct
    |> pow_user_id_field_changeset(attrs)
    |> pow_password_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> cast(attrs, [:firstname, :lastname, :email, :language, :active, :role])
    |> validate_required([:firstname, :lastname, :email, :language, :active, :role])
  end

  def roles(), do: ["admin", "user"]
  def select_roles(), do: for item <- roles(), do: {role(item), item}
  def role("admin"), do: "Administrator"
  def role("user"), do: "User"
  def role(_), do: ""

  def languages(), do: ["fr", "en"]
  def select_languages(), do: for item <- languages(), do: {language(item), item}
  def language("fr"), do: "French"
  def language("en"), do: "English"
  def language(_), do: ""

end
