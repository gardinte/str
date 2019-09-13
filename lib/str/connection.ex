defmodule Str.Connection do
  alias GoogleApi.Storage.V1, as: GoogleStorage

  def conn do
    {:ok, token} =
      "https://www.googleapis.com/auth/cloud-platform"
      |> Goth.Token.for_scope()

    GoogleStorage.Connection.new(token.token)
  end
end
