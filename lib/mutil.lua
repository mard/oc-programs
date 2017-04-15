local component = require('component')
local gpu = component.gpu

local initialForeground = gpu.getForeground()
local initialBackground = gpu.getBackground()

local mutil =
{
	_VERSION = "mutil test",
	_DESCRIPTION = "General Utility library for OpenComputers",
	_URL = "",
	_LICENSE = [[]]
}

function mutil.round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

local siPrefixes =
{
  {"m", 0.001},
  {"k", 1000},
  {"M", 1000000},
  {"G", 1e+9},
  {"T", 1e+12},
  {"P", 1e+15},
  {"E", 1e+18},
  {"Z", 1e+21},
  {"Y", 1e+24}
}

function mutil.prefixize(number, threshold)
  if not threshold then return number, '', 1 end
  if number >= threshold or number <= -threshold then
    for k, v in pairs(siPrefixes) do
      newnum = (number / v[2])
      if newnum < threshold then
        return newnum, v[1], v[2]
      end
    end
  end
  return number, '', 1
end

function mutil.setColor(color, f)
  if not color then
    return
  end
  local palette = false
  if gpu.getDepth() == 1 then
    return
  else
    if color > 0 and color <= 16 then
      palette = true
      color = pal2hex(color)
    end
  end
  f(color, palette)
end

local palette =
{
  0xFFFFFF, 0xFFCC33, 0xCC66CC, 0x6699FF,
  0xFFFF33, 0x33CC33, 0xFF6699, 0x333333,
  0xCCCCCC, 0x336699, 0x9933CC, 0x333399,
  0x663300, 0x336600, 0xFF3333, 0x000000
}

function mutil.pal2hex(paletteColor)
  if paletteColor and paletteColor <= 16 then
    return palette[paletteColor+1]
  end
end

function mutil.setForeground(fg, palette)
  gpu.setForeground(fg, palette)
end

function mutil.setBackground(bg, palette)
  gpu.setBackground(bg, palette)
end

function mutil.resetForeground()
  gpu.setForeground(initialForeground)
end

function mutil.resetBackground()
  gpu.setBackground(initialBackground)
end

return mutil

