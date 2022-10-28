--the precompiler substitutes some pieces of the code with common code prior to compilation
--code is defined as $name{ part to replace further occurences of name with }
--this code can then be invoked with simply $name;

INFILE = arg[1] or "src.txt"
OUTFILE = arg[2] or "in.txt"

local inf = io.open(INFILE, "r")
local outf = io.open(OUTFILE, "w")

local symbols = {}

function replaceSymbols(str) --replace symbols of form $symbol; in str with symbols[symbol]
  local toRet = ''
  local i = 1
  local c = string.sub(str, 0, 1)
  local function nxt()
    i = i+1
    c = string.sub(str, i, i)
  end
  
  while c~=nil and c~='' do
    if c=='$' then
      local name = ''
      nxt()
      while c ~= ';' do
        name = name..c
        nxt()
      end
      toRet = toRet..symbols[name]
    else
      toRet = toRet..c
    end
    nxt()
  end
  return toRet
end

local inc = inf:read(1)
while inc do
  if inc == '#' then
    while inc ~= '\n' do
      inc = inf:read(1)
    end
  end
  if inc == '$' then
    local name = ''
    local go = true
    inc = inf:read(1)
    while go do
      if inc == ';' then --this is a reference to an already existing symbol
        go = false
        outf:write(symbols[name])
      elseif inc == '{' then
        go = false
        local code = ''
        inc = inf:read(1)
        while inc ~= '}' do
          code = code..inc
          inc = inf:read(1)
        end
        symbols[name] = replaceSymbols(code)
      else
        name = name..inc
        inc = inf:read(1)
      end
    end
  else
    outf:write(inc)
  end
  inc = inf:read(1)
end