defmodule Str do
  alias Str.Upload

  defdelegate upload(bucket, file, attempt \\ 0), to: Upload
  defdelegate handle_upload_response(response, bucket, file, attempt \\ 0), to: Upload
end
