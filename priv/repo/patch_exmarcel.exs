# Fix negative step warning (not required) https://github.com/chaskiq/ex-marcel/pull/2

MIX_ENV = Atom.to_string(Mix.env())
file_path = "_build/#{MIX_ENV}/lib/ex-marcel/lib/magic.ex"
content = File.read!(file_path)
patched_content = String.replace(content, "ext |> String.slice(1..-1)", "ext |> String.slice(1..-1//1)")
File.write!(file_path, patched_content)
IO.puts("Module 'ex-marcel' patched successfully!")
