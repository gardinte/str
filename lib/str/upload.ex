defmodule Str.Upload do
  require Logger

  alias GoogleApi.Storage.V1, as: GoogleStorage

  import Str.Connection, only: [conn: 0]

  def upload(bucket, file, attempt \\ 0)

  def upload(bucket, file, attempt) when is_binary(file) do
    upload(bucket, %{file: file}, attempt)
  end

  def upload(bucket, %{file: file} = file_data, attempt) do
    wait(attempt)

    GoogleStorage.Api.Objects.storage_objects_insert_simple(
      conn(),
      bucket,
      "multipart",
      metadata(file_data),
      file
    )
  end

  def handle_upload_response(response, bucket, file, attempt \\ 0)

  def handle_upload_response({:ok, _object} = response, _bucket, _file, _attempt), do: response

  def handle_upload_response({:error, info} = response, bucket, file, 5) do
    Logger.error("Abort file #{inspect(file)} upload to bucket #{bucket}")
    Logger.error(inspect(info))

    response
  end

  def handle_upload_response({:error, info}, bucket, file, attempt) do
    Logger.error(
      "Error uploading file #{inspect(file)} to bucket #{bucket} on attempt #{attempt}"
    )

    Logger.error(inspect(info))

    attempt = attempt + 1

    bucket
    |> upload(file, attempt)
    |> handle_upload_response(bucket, file, attempt)
  end

  defp metadata(%{file: file} = file_data) do
    %{
      name: file_path(file_data),
      contentType: MIME.from_path(file)
    }
  end

  defp file_path(%{file: file, path: path, date: date}) do
    file_name = Path.basename(file)
    date = date |> Date.to_iso8601()

    [path, date, file_name]
    |> Enum.filter(& &1)
    |> Enum.join("/")
  end

  defp file_path(%{file: file, path: path}) do
    date = Date.utc_today()

    file_path(%{file: file, path: path, date: date})
  end

  defp file_path(%{file: file}) do
    date = Date.utc_today()

    file_path(%{file: file, path: nil, date: date})
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
