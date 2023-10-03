defmodule NpmDeps do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias NpmDeps.Downloader

  def get(deps, opts \\ []) do
    IO.puts("Downloading NPM packages...")

    deps
    |> Task.async_stream(
      fn {namespace, version} -> Downloader.get(namespace, version, opts) end,
      timeout: 60_000
    )
    |> Enum.each(fn {:ok, {:ok, {action, namespace, version}}} ->
      case action do
        :download -> IO.puts("Downloaded #{namespace} #{version}")
        :keep -> IO.puts("Keep #{namespace} #{version}")
      end
    end)
  end

  def json_library do
    Application.get_env(:npm_deps, :json_library, Jason)
  end
end
