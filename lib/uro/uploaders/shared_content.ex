defmodule Uro.Uploaders.SharedContentData do
  use Waffle.Definition
  use Waffle.Ecto.Definition
  alias Uro.Helpers.Validation

  @versions [:original]
  #TODO: Define allowed formats for upload
  @extension_whitelist ~w(.zip .scn .glb .vrm)

  # Whitelist file extensions:
  def validate({file, _}) do
    IO.puts("Debug validate user content data")
    IO.inspect(file)
    IO.puts("End debug")
    file_extension = file.file_name |> Path.extname() |> String.downcase()
    with true <- Enum.member?(@extension_whitelist, file_extension),
         true <- Validation.check_magic_number(file), do: true, else: (_ -> false)
  end

  # Override the persisted filenames:
  def filename(version, {_file, scope}) do
    "#{scope.id}_#{version}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _scope}) do
    "uploads/"
  end
end
