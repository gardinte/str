defmodule Str.Upload do
  require Logger

  alias GoogleApi.Storage.V1, as: GoogleStorage

  import Str.Connection, only: [conn: 0]

  def upload(bucket, file, attempt \\ 0) do
    wait(attempt)

    GoogleStorage.Api.Objects.storage_objects_insert_simple(
      conn(),
      bucket,
      "multipart",
      metadata(file),
      file
    )
  end

  def handle_upload_response(response, bucket, file, attempt \\ 0)

  def handle_upload_response({:ok, _object} = response, _bucket, _file, _attempt), do: response

  def handle_upload_response({:error, info} = response, bucket, file, 5) do
    Logger.error("Abort file #{file} upload to bucket #{bucket}")
    Logger.error(inspect(info))

    response
  end

  def handle_upload_response({:error, info}, bucket, file, attempt) do
    Logger.error("Error uploading file #{file} to bucket #{bucket} on attempt #{attempt}")
    Logger.error(inspect(info))

    attempt = attempt + 1

    bucket
    |> upload(file, attempt)
    |> handle_upload_response(bucket, file, attempt)
  end

  defp metadata(file) do
    %{
      name: file_path(file),
      contentType: MIME.from_path(file)
    }
  end

  defp file_path(file) do
    file_name = Path.basename(file)
    date = Date.utc_today() |> Date.to_iso8601()

    "#{date}/#{file_name}"
  end

  defp wait(0), do: nil

  defp wait(attempt) do
    base = Application.get_env(:str, :wait_base)

    base
    |> :math.pow(attempt)
    |> round()
    |> :timer.seconds()
    |> :timer.sleep()
  end
end
