Name = "wallpapers"
NamePretty = "Wallpapers"

function GetEntries()
  local entries = {}

  local wallpaper_dir = "/home/abhijeet/Wallpapers"

  local handle = io.popen(
    "find -L '" .. wallpaper_dir ..
    "' -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null"
  )

  if not handle then
    return entries
  end

  for path in handle:lines() do
    local filename = path:match(".*/(.+)$")

    if filename then
      -- Strip extension
      local name = filename:gsub("%.%w+$", "")
      -- Make it human-readable
      name = name:gsub("_", " "):gsub("%-", " ")
      name = name:gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest:lower()
      end)

      table.insert(entries, {
        Text = name,
        Preview = path,
        PreviewType = "file",
        Actions = {
          activate = "${HOME}/.config/bin/apply_wallpaper.sh \"" .. path .. "\"",
        },
      })
    end
  end

  handle:close()
  return entries
end
