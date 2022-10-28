local INFILE = arg[1] or "a.out"

local mem = {}
local ip = 0

local HALT = false

--load file
local inf = io.open(INFILE, "r")
local WORDBYTES = string.byte(inf:read(2))
local REGMEM = 256^WORDBYTES-1 --the index of -1
local str = inf:read()
local num = 0
local loc = 0
for i = 1, #str+1 do
  local inb = string.byte(string.sub(str, i-1, i))
  --print(i..","..inb)
  num = num*256 + inb
  if i%WORDBYTES == 0 then
    mem[loc] = num
    --print(loc..": "..mem[loc])
    loc = loc + 1
    num = 0
  end
end

function subleq(i)
  local a = mem[i]
  local b = mem[i+1]
  local c = mem[i+2]
  if a == REGMEM then
    mem[a] = 256^WORDBYTES-string.byte(io.read(1))
  end
  if not mem[a] then mem[a] = 0 end
  if not mem[b] then mem[b] = 0 end
  local result = mem[b]-mem[a]
  mem[b] = result%256^WORDBYTES
  if b == REGMEM then
    io.write(string.char(mem[a]%256))
  end
  if result <= 0 then
    if c == REGMEM then HALT = true else
    ip = c end
  else
    ip = ip + 3
  end
end


while not HALT do
  --print(ip..": "..(mem[ip] or 0)..", "..(mem[ip+1] or 0)..", "..(mem[ip+2] or 0))
  subleq(ip)
end