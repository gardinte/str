defmodule Str do
  alias Str.Upload

  def upload(bucket, file, attempt \\ 0) do
    Upload.upload(bucket, file, attempt)
  end

  def handle_upload_response(response, bucket, file, attempt \\ 0) do
    Upload.handle_upload_response(response, bucket, file, attempt)
  end
end
