-- Lua filter to add vertical lines to tables

-- Process the entire document after conversion to add vertical lines
function Pandoc(doc)
  -- Convert to LaTeX string
  local latex = pandoc.write(doc, 'latex')
  
  -- Add vertical lines to longtable environments
  -- Replace @{} with | and add | between column specifications
  latex = latex:gsub('(\\begin{longtable}%[[^%]]*%]{)@{}([^@]-)@{}(})', function(prefix, cols, suffix)
    -- Add vertical line at start
    local newcols = '|' .. cols
    -- Add vertical line between each column (after each })
    newcols = newcols:gsub('}%s*\n?%s*(>)', '}|%1')
    -- Add vertical line at end
    newcols = newcols .. '|'
    return prefix .. newcols .. suffix
  end)
  
  -- Return as raw LaTeX
  return pandoc.Pandoc({pandoc.RawBlock('latex', latex)})
end
