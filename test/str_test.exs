defmodule StrTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  describe "upload" do
    setup [:test_data]

    test "upload", %{"bucket" => bucket, "file" => file} do
      date = Date.utc_today() |> Date.to_iso8601()

      assert {:ok, object} = Str.upload(bucket, file)
      assert "#{date}/file.txt" == object.name
    end

    test "upload with path", %{"bucket" => bucket, "file" => file} do
      date = Date.utc_today() |> Date.to_iso8601()

      assert {:ok, object} = Str.upload(bucket, %{file: file, path: "test"})
      assert "test/#{date}/file.txt" == object.name
    end
  end

  describe "handle upload response" do
    setup [:test_data]

    test "handle upload :ok response", %{"bucket" => bucket, "file" => file} do
      assert {:ok, %{}} = Str.handle_upload_response({:ok, %{}}, bucket, file)
    end

    test "handle upload :error response", %{"bucket" => bucket, "file" => file} do
      assert capture_log(fn ->
               assert {:ok, %{}} = Str.handle_upload_response({:error, %{}}, bucket, file)
             end) =~ "Error uploading file #{inspect(file)} to bucket #{bucket} on attempt 0"
    end

    test "handle upload :error response on last attempt", %{"bucket" => bucket, "file" => file} do
      assert capture_log(fn ->
               assert {:error, %{}} = Str.handle_upload_response({:error, %{}}, bucket, file, 5)
             end) =~ "Abort file #{inspect(file)} upload to bucket #{bucket}"
    end
  end

  defp test_data(_) do
    {:ok,
     %{
       "bucket" => Application.get_env(:str, :default_bucket),
       "file" => "test/data/file.txt"
     }}
  end
end
