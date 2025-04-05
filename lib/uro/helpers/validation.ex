defmodule Uro.Helpers.Validation do
  @moduledoc """
  Helper module to validate files.
  """

require Logger

def init_extra_extensions() do
  ExMarcel.Magic.add("application/vnd.godot.scn", [extensions: ["scn"], magic: [[0, "\x52\x53\x43\x43"]], parents: []])
  ExMarcel.Magic.add("model/gltf-binary", [extensions: ["glb", "vrm"], magic: [[0, "\x67\x6C\x54\x46"]], parents: []])
end

# Ensure magic matches extension mime. Weak check, don't rely for security
@spec check_magic_exmarcel(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_exmarcel(%{file_name: file_name, path: path}) do
  file_extension = file_name |> Path.extname() |> String.downcase()
  {:ok, file_handle} = File.open(path)
  magic_mime = ExMarcel.Magic.by_magic(file_handle)
  File.close(file_handle)
  ext_mime = ExMarcel.Magic.by_extension(file_extension)
  #if (ext_mime && !magic_mime) do
    # Files without magic number but known extension will fail validation 
    # File formats like '.txt' don't have magic number, so they must always pass
    #if Enum.member?(["txt", "csv", "tsv", "json", "ini", "log"], ext_mime) do
   #   IO.puts("String found in the list!")
   # else
    #  IO.puts("String not found in the list!")
   # end
  if !(magic_mime && ext_mime) do # warning if one return value is falsy
      Logger.warning("File magic number or extension not recognized: #{file_extension} in #{file_name}. Skipping magic/extension cross-check validation...")
      true
  else
    magic_mime = magic_mime.type |> String.downcase()
    ext_mime = ext_mime.type |> String.downcase()
    cond do
      magic_mime == ext_mime ->
        IO.puts("Good file")
        true
      true ->
        IO.puts("Wrong file")
        false
    end
  end
end

@spec check_magic_number(%{file_name: String.t(), path: String.t()}) :: boolean
def check_magic_number(%{file_name: _file_name, path: _path} = file) do
  check_magic_exmarcel(file)
end

  def generate_file_sha256(file_path) do
    file_stream = File.stream!(file_path, [], 4096) # 4KB chunks
    hash = Enum.reduce(file_stream, :crypto.hash_init(:sha256), fn chunk, acc ->
      :crypto.hash_update(acc, chunk)
    end)
    :crypto.hash_final(hash)
    |> Base.encode16(case: :lower)
  end
end
