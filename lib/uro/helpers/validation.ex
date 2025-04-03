defmodule Uro.Helpers.Validation do
  @moduledoc """
  Helper module to validate files.
  """

require Logger

  @magic_numbers %{
    ".glb" => <<0x67, 0x6C, 0x54, 0x46>>,
    ".vrm" => <<0x67, 0x6C, 0x54, 0x46>>,
    ".scn" => <<0x52, 0x53, 0x43, 0x43>>
    }

# Ensure mime matches extension
@spec check_magic_exmarcel(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_exmarcel(%{file_name: file_name, path: path}) do
  file_extension = file_name |> Path.extname() |> String.downcase()
  {:ok, file_handle} = File.open(path)
  magic_mime = ExMarcel.Magic.by_magic(file_handle)
  File.close(file_handle)
  ext_mime = ExMarcel.MimeType.for(nil, extension: file_extension)
  IO.puts(magic_mime)
  IO.puts(ext_mime)
  if not magic_mime do # exmarcel fallback value when not in magic list
      Logger.warning("File magic number not recognized: #{file_extension} in #{file_name}. Skipping magic number validation...")
      true
  else
    cond do
      magic_mime == ext_mime ->
        IO.puts("Good file")
        true
      #nil ->
      #magic_mime == "application/octet-stream" -> # exmarcel fallback value when not in magic list
        #Logger.warning("File magic number not recognized: #{file_extension} in #{file_name}. Skipping magic number validation...")
       # true
      true ->
        IO.puts("Wrong file")
        false
    end
  end
end

@spec check_magic_custom(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_custom(%{file_name: file_name, path: path}) do
  file_extension = file_name |> Path.extname() |> String.downcase()
  magic_number = Map.get(@magic_numbers, file_extension)

  if magic_number != nil do
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
    else # Skip check if ext not in custom magic numbers
      true
    end
  end

@spec check_magic_number(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_number(%{file_name: file_name, path: path} = file) do
  check_magic_custom(file) and check_magic_exmarcel(file)
end

  #defp generate_checksum1(file_path) do
  #  :crypto.hash(:sha256, File.read!(file_path))
  #  |> Base.encode16(case: :lower)
  #end

  def generate_file_sha256(file_path) do
    file_stream = File.stream!(file_path, [], 4096) # 4KB chunks
    hash = Enum.reduce(file_stream, :crypto.hash_init(:sha256), fn chunk, acc ->
      :crypto.hash_update(acc, chunk)
    end)
    :crypto.hash_final(hash)
    |> Base.encode16(case: :lower)
  end
end
