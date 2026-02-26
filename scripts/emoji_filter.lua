-- Pandoc Lua filter to wrap emojis in \emoji{CODE} for LaTeX
function Str(el)
  local result = {}
  local last_pos = 1
  for pos, code in utf8.codes(el.text) do
    if (code >= 0x2300 and code <= 0x27BF) or (code >= 0x1F000 and code <= 0x1FAFF) then
      -- Before the emoji
      if pos > last_pos then
        table.insert(result, pandoc.Str(el.text:sub(last_pos, pos - 1)))
      end
      -- The emoji code itself
      table.insert(result, pandoc.RawInline('latex', '\\emoji{' .. code .. '}'))
      last_pos = pos + #utf8.char(code)
    end
  end
  -- After the last emoji
  if last_pos <= #el.text then
    table.insert(result, pandoc.Str(el.text:sub(last_pos)))
  end
  
  if #result > 0 then
    return result
  else
    return el
  end
end
