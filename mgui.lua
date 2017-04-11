-- opencomputers terminal user interface
-- mard

local mgui =
{
	_VERSION = "mardgui alpha",
	_DESCRIPTION = "Graphical User Interface library for OpenComputers",
	_URL = "",
	_LICENSE = [[]]
}

local class = require('ext/30log')
local component = require('component')
local gpu = component.gpu

local initialForeground = gpu.getForeground()
local initialBackground = gpu.getBackground()
local initialDepth = gpu.getDepth()

function setColor(color, f)
  if not color then
    return
  end
  local palette = false
  if gpu.getDepth() == 1 then
    return
  elseif gpu.getDepth() == 4 then
    if color > 15 then
      --return
    end
    --palette = true
  end
  f(color, palette)
end

local palette = { 0xFFFFFF, 0xFFCC33, 0xCC66CC, 0x6699FF,
      0xFFFF33, 0x33CC33, 0xFF6699, 0x333333,
      0xCCCCCC, 0x336699, 0x9933CC, 0x333399,
      0x663300, 0x336600, 0xFF3333, 0x000000 }

function pal2hex(paletteColor)
  if paletteColor and paletteColor <= 16 then
    return palette[paletteColor+1]
  end
end

function setForeground(fg, palette)
  gpu.setForeground(fg, palette)
end

function setBackground(bg, palette)
  gpu.setBackground(bg, palette)
end

function resetForeground()
  gpu.setForeground(initialForeground)
end

function resetBackground()
  gpu.setBackground(initialBackground)
end

local TuiElement = class('TuiElement',
  {
    parent = nil,
    items = {},
    visible = true,
    disabled = false
  }
)

function TuiElement:add(self, tuiElement)
  tuiElement.parent = self
  table.insert(self.items, #self.items+1, tuiElement)
end

function TuiElement:remove(self, tuiElement)
  for k,v in pairs(tuiElement.items) do tuiElement.items[k] = nil end
  for i = 1, #self.items do
    if self.items[i] == tuiElement then
      table.remove(self.items, i)
      return
    end
  end
end

function TuiElement:refresh()
  for k,v in pairs(self.items) do self.items[k] = nil end
  self:addChilds()
  self:draw()
end

function TuiElement:anyParentInvisible()
  if not self.visible then return true end
  if self.parent then return self.parent:anyParentInvisible() end
  return false
end

function TuiElement:anyParentDisabled()
  if self.disabled then return true end
  if self.parent then return self.parent:anyParentDisabled() end
  return false
end

local Locatable = TuiElement:extend('Locatable',
  {
    positionAbsolute = false,
    --x = self.parent == nil and x or self.parent.x,
    --y = self.parent == nil and y or self.parent.y
    x = 0,
    y = 0
  }
)

function Locatable:add(locatable)
  --if not class.isInstance(self) then
  --  return
  --end

  TuiElement:add(self, locatable)

  locatable.x = locatable.x + self.x-1
  locatable.y = locatable.y + self.y-1

  if locatable.addChilds then
    locatable.addChilds(locatable)
  end
end

local Measurable = Locatable:extend('Measurable',
  {
    w = 0,
    h = 0,
  }
)

function Measurable:isInside(x, y)
  if x >= self.x and y >= self.y and
     x <= self.x + self.w - 1 and y <= self.y + self.h - 1 then
    return true
  end
end

local Colorable = class('Colorable',
  {
    fg = initialForeground,
    bg = initialBackground
  }
)

function Colorable.setColors(self)
  setColor(self.fg, setForeground)
  setColor(self.bg, setBackground)
end

function Colorable.resetColors(self)
  if self.parent then
    setColor(self.parent.fg, setForeground)
    setColor(self.parent.bg, setBackground)
  else
    resetForeground()
    resetBackground()
  end
end

local Touchable = class('Touchable',
  {
    onTouch = nil,
    touchTransparent = false
  }
)

function Touchable:doTouch()
  local pfg, pbg = self.bg, self.fg
  self.bg = pbg
  self.fg = pfg
  self:draw()
  os.sleep(0.1)
  self.bg = pfg
  self.fg = pbg
  self:draw()
  self.onTouch()
end

function Touchable:getTouchedAt(x, y)
  local found = nil

  for k, v in pairs(self.items) do
    found = v:getTouchedAt(x, y)
    if found
      and not found.touchTransparent
      and not found:anyParentInvisible()
      and not found:anyParentDisabled() then
        return found
      end
    end

  if self:isInside(x, y) then
    return self
  end
end

local Alignable = Measurable:extend('Alignable')

function Alignable:alignLeft()
  self:align(2)
end

function Alignable:alignCenter()
  self:align(((self.parent.w - self.w)/2))
end

function Alignable:alignRight()
  self:align(((self.parent.w - self.w)-2))
end

function Alignable:align(f)
  if not self.parent then
    return
  end
  self.x = self.parent.x + f
  for k, v in pairs(self.items) do
    v:alignCenter()
  end
end

local Shaded = class('Shaded',
  {
    s = 0x000000
  }
)

function Shaded.drawShade(self)
  local pfg, pbg = self.fg, self.bg
  setColor(0x000000, setForeground)
  setColor(self.parent.bg, setBackground)
  gpu.fill(self.x + 1, self.y + self.h, self.w, 1, '▀')
  gpu.set(self.x + self.w, self.y, '▄')
  gpu.fill(self.x + self.w, self.y + 1, 1, self.h - 1, '█')
  setColor(pfg, setForeground)
  setColor(pbg, setBackground)
end

Box = Alignable:extend('Box'):with(Colorable, Touchable)

function Box:init(x, y, w, h, bg)
  self.x, self.y, self.w, self.h, self.bg = x, y, w, h, bg
end

function Box:draw()
  if not self.visible then
    return
  end

  if self.class:includes(Colorable) then
    self.setColors(self)
    gpu.fill(self.x, self.y, self.w, self.h, ' ')
  end

  if self.class:includes(Shaded) then
    self:drawShade(self)
  end

  for k, v in pairs(self.items) do
    v:draw()
  end

  if self.class:includes(Colorable) then
    self.resetColors(self)
  end
end

Label = Box:extend('Label',
  {
    text = '',
    transparent = false,
    touchTransparent = true
  }
)

function Label:init(x, y, text, fg, bg)
  self.x, self.y, self.text, self.fg, self.bg = x, y, text, fg, bg
  if not fg and self.parent then self.fg = self.parent.fg end
  if not bg and self.parent then self.bg = self.parent.bg end
  self.w, self.h = #text, 1
end

function Label:draw()
  if self.class:includes(Colorable) then
    self.setColors(self)
  end
  if not self.transparent then
    gpu.set(self.x, self.y, self.text)
  else
    --draw characters one by one, preserving background underneath.
    if self.class:includes(Colorable) then
    setColor(self.fg, setForeground)
    end
    for i = 1, #self.text do
      local c = self.text:sub(i,i)
      local _, _, _, _, ubg = gpu.get(self.x + i - 1, self.y)
      setColor(pal2hex(ubg) ,setBackground)
      gpu.set(self.x + i - 1, self.y, c)
    end
  end
  if self.class:includes(Colorable) then
    self.resetColors(self)
  end
end

local SubItems = class('SubItems',
  {
    addChilds = nil
  }
)

FlatButton = Box:extend('FlatButton',
  {
    dfg = 0xCCCCCC,
    dbg = 0x333333,
    tempfg = fg,
    tempbg = bg
  }
)
Button = FlatButton:extend('Button'):with(Shaded)

function FlatButton:init(x, y, w, h, text, fg, bg)
  self.x, self.y, self.w, self.h, self.text, self.fg, self.bg = x, y, w, h, text, fg, bg
end

function FlatButton.addChilds(self)
  local label = Label(1, math.ceil(self.h/2), self.text, pal2hex(self.fg))
  self:add(label)
  label:alignCenter()
end

function FlatButton:disable()
  self.disabled = true
  self.tempfg, self.tempbg = self.fg, self.bg
  self.fg, self.bg = self.dfg, self.dbg
end

function FlatButton:enable()
  self.disabled = false
  self.fg, self.bg = self.tempfg, self.tempbg
end

function Button:init(...)
  Button.super.init(self, ...)
end

function Button.addChilds(self)
  Button.super.addChilds(self)
end

GroupBox = Box:extend('GroupBox'):with(Shaded, SubItems)

function GroupBox:init(x, y, w, h, title, fg, bg, hfg, hbg)
  self.x, self.y, self.w, self.h, self.text, self.fg, self.bg, self.hfg, self.hbg = x, y, w, h, title, fg, bg, hfg, hbg
end

function GroupBox.addChilds(self)
  local header = Box(1, 1, self.w, 1, self.hbg)
  local headerText = Label(1, 1, self.text, self.hfg, self.hbg)
  self:add(header)
  header:add(headerText)
  headerText:alignCenter()
end

ProgressBar = Box:extend('ProgressBar',
  {
    value = 0,
    min = 0,
    max = 100
  }
):with(Shaded, SubItems)

function ProgressBar:init(x, y, w, h, value, min, max, unit, name, fg, bg)
  self.x, self.y, self.w, self.h, self.value, self.min, self.max, self.unit, self.name, self.fg, self.bg = x, y, w, h, value, min, max, unit, name, fg, bg
end

function ProgressBar.addChilds(self)
  --width is 20.
  --from 100 to 200 - if value is 175,  then
  --100-100, 200-100, 175-100 = 0, 100, 75 - checks out.
  --so min = 0, max - min, value - min.
  --then
  --new value/max = 0.75
  -- then 0.75 * self.width.
  local bar = Box(1, 1, self:calculateRealValue(), self.h, self.fg)
  --print(self:calculatePercentage())
  local percent = Label(2, 2, tostring(self:calculatePercentage()) .. '%', 0xFFFFFF)
  local name = Label(2, 2, self.name, 0xFFFFFF)
  local progress = Label(2, 2, tostring(round(self.value, 3)) .. "/" .. tostring(self.max) .. " " .. self.unit, 0xFFFFFF)

  percent.transparent = true
  name.transparent = true
  progress.transparent = true

  self:add(bar)

  self:add(percent)
  percent:alignLeft()

  self:add(name)
  name:alignCenter()

  self:add(progress)
  progress:alignRight()
end

function ProgressBar:calculateRealValue()
  return self:calculateRatio() * self.w
end

function ProgressBar:calculateRatio()
  local amax, avalue = self.max - self.min, self.value - self.min
  return avalue / amax
end

function ProgressBar:calculatePercentage()
  return round(self:calculateRatio() * 100, 1)
end

function round(num, numDecimalPlaces)
  if numDecimalPlaces and numDecimalPlaces>0 then
    local mult = 10^numDecimalPlaces
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

