defmodule Uro.Helpers.Validation do
  @moduledoc """
  Helper module to validate files.
  """

require Logger

  @magic_numbers %{
    ".jpg" => <<0xFF, 0xD8, 0xFF>>,
    ".jpeg" => <<0xFF, 0xD8, 0xFF>>,
    ".gif" => <<0x47, 0x49, 0x46>>,
    ".png" => <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>,
    ".glb" => <<0x67, 0x6C, 0x54, 0x46>>,
    ".vrm" => <<0x67, 0x6C, 0x54, 0x46>>,
    ".scn" => <<0x52, 0x53, 0x43, 0x43>>
    }

@spec check_magic_number(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_number(%{file_name: file_name, path: path}) do
  file_extension = file_name |> Path.extname() |> String.downcase()
  magic_number = Map.get(@magic_numbers, file_extension)

  if magic_number == nil do
    Logger.warning("File extension not recognized: #{file_extension} in #{file_name}. Skipping magic number check...")
    true
  else
      expected_length = byte_size(magic_number)
      case :file.open(path, [:read, :binary]) do
        {:ok, file_handle} ->
          result = with {:ok, file_content} <- :file.read(file_handle, expected_length),
                       true <- byte_size(file_content) >= expected_length,
                       true <- :binary.part(file_content, 0, expected_length) == magic_number, do: true, else: (_ -> false)
          :file.close(file_handle)
          result

        {:error, reason} ->
          Logger.error("Error opening file: #{reason}")
          false
      end
    end
  end
end
