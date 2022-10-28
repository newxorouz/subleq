local INFILE = arg[1] or "in.txt"
local OUTFILE = arg[2] or "a.out"

local symbols = {}
local vals = {}
local strings = {}

local inf = io.open(INFILE, "r")
local outf = io.open(OUTFILE, "w")

local WORDBYTES = 2

if not inf or not outf then
  print("cannot find infile")
  return
end

local inc = inf:read(1)
local builtstr = ""
local semicoloncount = 0
while inc do
  if inc == '#' then
    while inc ~= '\n' do
      inc = inf:read(1)
    end
  end
  if inc == ';' then
    if builtstr ~= '' then
      strings[#strings+1] = builtstr
      builtstr = ''
      semicoloncount = semicoloncount + 1
    end
    if semicoloncount == 2 then
      strings[#strings+1] = "?+1"
    elseif semicoloncount == 1 then
      local last = strings[#strings]
      strings[#strings] = 0
      strings[#strings+1] = 0
      strings[#strings+1] = last
    end
    semicoloncount = 0
  elseif inc == ':' then
    symbols[builtstr] = #strings
    builtstr = ''
  elseif inc == ' ' or inc =='\n' then
    if builtstr ~= '' then
      strings[#strings+1] = builtstr
      builtstr = ''
      semicoloncount = semicoloncount + 1
    end
    if inc=='\n' then
      semicoloncount = 0
    end
  else
    builtstr = builtstr..inc
  end
  inc = inf:read(1)
end
if builtstr ~= '' then
  strings[#strings+1] = builtstr
end


for k, v in pairs(strings) do
  --print(k.." : "..v)
  if symbols[v] then
    vals[k-1] = symbols[v]
  elseif string.sub(v, 0, 1) == '?' then
    vals[k-1] = k-1 + tonumber(string.sub(v, 2))
  else
    vals[k-1] = (v%256^WORDBYTES)
  end
end

--print("\n\n")

outf:write(string.char(WORDBYTES))
for i = 0, #vals do
  --print(i.." : "..vals[i])
  local v = vals[i]
  for j = WORDBYTES, 1, -1 do
    outf:write(string.char((v//256^(j-1))%256))
  end
end

inf:close()
outf:close()