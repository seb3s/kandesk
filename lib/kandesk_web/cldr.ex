defmodule KandeskWeb.Cldr do
  @moduledoc """
    Define a backend module that will host our
    Cldr configuration and public API.

    Most function calls in Cldr will be calls
    to functions on this module.
  """

  use Cldr,
    locales: ["en", "fr"],
    default_locale: "en",
    gettext: KandeskWeb.Gettext,
    precompile_number_formats: ["¤¤#,##0.##", "#,##0"],
    data_dir: "./priv/cldr",
    precompile_transliterations: [],
    providers: [Cldr.Number],
    otp_app: :kandesk

  @doc "Returns the currently set locale for a connection"
  @spec locale(Plug.Conn.t()) :: String.t()
  def locale(conn) do
    Cldr.Plug.AcceptLanguage.get_cldr_locale(conn)
  end

  @doc "Returns a number as an ordinal string"
  @spec to_ordinal(number) :: String.t()
  def to_ordinal(number) do
    __MODULE__.Number.to_string!(number, format: :ordinal)
  end

  @doc "Returns a number as an ordinal string using the set locale"
  @spec to_ordinal(number, Plug.Conn.t()) :: String.t()
  def to_ordinal(number, conn) do
    __MODULE__.Number.to_string!(number, format: :ordinal, locale: locale(conn))
  end

  @doc "Returns a number as a string with no decimals"
  @spec to_int_string(number) :: String.t()
  def to_int_string(number) do
    __MODULE__.Number.to_string!(number, precision: 0)
  end

  @doc "Returns a number as a string with no decimals using the set locale"
  @spec to_int_string(number, Plug.Conn.t()) :: String.t()
  def to_int_string(number, conn) do
    __MODULE__.Number.to_string!(number, precision: 0, locale: locale(conn))
  end
end
