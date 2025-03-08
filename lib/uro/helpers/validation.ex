defmodule Uro.Helpers.Validation do
  @moduledoc """
  Helper module to check file magic numbers.
  """

require Logger

  @magic_numbers %{
    ".jpg" => <<0xFF, 0xD8, 0xFF>>,
    ".jpeg" => <<0xFF, 0xD8, 0xFF>>,
    ".gif" => <<0x47, 0x49, 0x46>>,
    ".png" => <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>,
    ".glb" => = <<0x67, 0x6C, 0x54, 0x46>>,
    ".vrm" => = <<0x67, 0x6C, 0x54, 0x46>>,
    ".scn" => = <<0x67, 0x6C, 0x54, 0x46>>
    }

@spec check_magic_number(%Plug.Upload{}) :: boolean
def check_magic_number(%Plug.Upload{file_name: file_name, path: path}) do
  file_extension = file_name |> Path.extname() |> String.downcase()
  magic_number = Map.get(@magic_numbers, file_extension)

  if magic_number == nil do
    Logger.warning("File extension not recognized: #{file_extension}")
    false
  else
    with {:ok, file_content} <- File.read(path),
         true <- byte_size(file_content) >= byte_size(magic_number),
         true <- String.starts_with?(file_content, magic_number) do
      true
    else
      _ -> false
    end
  end
end
