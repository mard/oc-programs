--[[

NAME
  frcs - Fusion Reactor Control System

SYNOPSIS
  frcs

DESCRIPTION
  frcs is an interactive GUI application that allows for controlling and monitoring Mekanism Fusion Reactor and its peripherials.

  frcs comes with following features:

  - Input, Output and Induction Matrix attached to Fusion Reactor
  - Laser Amplifier charge level, firing laser charge,
  - Automatic cutoff of Mekanism cable when Laser Amplifier is fully charged
  - Details of Reactor Chamber operation.

  frcs will try to read .frcs.conf file from home directory. If it doesn't exist, frcs will fall back to /etc/frcs.conf. Particular options and possible values are described in mentioned file. It is recommended to copy /etc/frcs.conf to home directory:

  `cp /etc/frcs.conf $HOME/.frcs.conf`

  ...and configure the program by editing /home/.frcs.conf file:

  `edit $HOME/.frcs.conf`

LICENSE
  
  
REPORTING BUGS
  Bugs, issues, suggestions should be reported at: <https://github.com>.

COPYRIGHT
  frcs is released into public domain by the copyright holders under WTFPL.


]]

-- FRCS: Fusion Reactor Control System

-- charge of laser amp
-- fire laser amp

-- turn off laser amp charging
-- induction cube


--[[

Induction Matrix:
GetInput
8758.9238372803 RF/t (potentially the same as get producing)

GetOutput
n/d
8489 RF/t

GetEnergy
25600000000 (25.59 GRF)

GetMaxEnergy
25600000000 (25.59 GRF)

Laser Amplifier:
getEnergy
79368000 RF

getMaxEnergy
2000000000 (2 GRF)






Reactor
Status: Ignited |  isIgnited

getEnergy / 2.5
400000000 RF

getInjectionRate
0, 2, 4 etc.

getProducing / 2.5
217886.92356348



]]


local class = require('ext/30log')
local component = require('component')
local computer = require('computer')
local colors = require('colors')
local term = require('term')
local event = require("event")

package.loaded.mgui = nil
local mtui = require('mgui')

local gpu = term.gpu()

local initial_bg = gpu.getBackground()
local initial_fg = gpu.getForeground()
local initial_depth = gpu.getDepth()

local name = 'Fusion Reactor Control System' --  1.0 by mard
local headerText = name
local footerText = computer.freeMemory() .. ' bytes free'

local root = Box(1,1,80,25, pal2hex(colors.blue))

local header = Box(1,1,80,1,pal2hex(colors.lightblue))
local headerLabel = Label(1,1, headerText, pal2hex(colors.white))

local buttonQuit = FlatButton(78, 1, 3, 1, 'x', pal2hex(colors.white), pal2hex(colors.gray))
buttonQuit.onTouch = function() terminate() end

local buttonAbout = FlatButton(74, 1, 3, 1, '?', pal2hex(colors.white), pal2hex(colors.gray))
buttonAbout.onTouch = function() about() end

--local buttonLog = FlatButton(68, 1, 5, 1, 'log', pal2hex(colors.white), pal2hex(colors.gray))
--buttonLog.onTouch = function() testDisable() end

--local buttonConfig = FlatButton(59, 1, 8, 1, 'config', pal2hex(colors.white), pal2hex(colors.gray))
--buttonConfig.onTouch = function() quit() end

local footer = Box(1,25,80,1,pal2hex(colors.lightblue))
local footerLabel = Label(1,1, footerText, pal2hex(colors.white))
local workspace = Box(1,2,80,23,pal2hex(colors.blue))

local imGroupBox = GroupBox(3,2,76,6,'Induction Matrix',pal2hex(colors.gray), pal2hex(colors.silver), pal2hex(colors.white), pal2hex(colors.gray))
local imInput = Label(4, 3, 'Input:')
local imOutput = Label(3, 5, 'Output:')
local imCharge = ProgressBar(25,3,50,3,29083740,0,25600000000, 'RF', '', pal2hex(colors.lime),pal2hex(colors.gray))

local laGroupBox = GroupBox(3,9,76,6,'Laser Amplifier',pal2hex(colors.gray), pal2hex(colors.silver), pal2hex(colors.white), pal2hex(colors.gray))
local laCharge = ProgressBar(3,3,62,3,2,0,2000000000, 'RF', '', pal2hex(colors.lime),pal2hex(colors.gray))

local rcGroupBox = GroupBox(3,16,76,6,'Reactor Chamber',pal2hex(colors.gray), pal2hex(colors.silver), pal2hex(colors.white), pal2hex(colors.gray))

local buttonFire = Button(67,3,8,3,'FIRE', pal2hex(colors.white), pal2hex(colors.red))
buttonFire.onTouch = function() test() end

root:add(header)
header:add(headerLabel)
headerLabel:alignCenter()
header:add(buttonQuit)
header:add(buttonAbout)

root:add(workspace)

workspace:add(imGroupBox)
imGroupBox:add(imInput)
imGroupBox:add(imOutput)
imGroupBox:add(imCharge)

workspace:add(laGroupBox)
laGroupBox:add(laCharge)
laGroupBox:add(buttonFire)
workspace:add(rcGroupBox)

root:add(footer)
footer:add(footerLabel)

term.clear()
root:draw()

local inifile = require('ext/inifile')
settings = inifile.parse('frcs.conf')

local running = true
function quit()
  print("elo")
end

function test()
  imCharge.value = math.random() + math.random(25600000000)
  imCharge:refresh()
  --imCharge:draw()

  imInput.text = 'Input: ' .. round(math.random(),2) + math.random(217886) .. ' RF/t'
  imOutput.text = 'Output: ' .. round(math.random(),2) + math.random(0,999) .. ' RF/t'

  laCharge.value = math.random() + math.random(0,2000000000)
  laCharge:refresh()
  laCharge:draw()

  --imInput:draw()
  --imOutput:draw()

  imGroupBox:draw()

  --print(settings.redstone.address_redstone_amplifier)
end

function terminate()
  running = false
  resetBackground()
  resetForeground()
  term.clear()
  print("soft interrupt, closing")
end

function about()
  local aboutGroupBox = GroupBox(20,6,40,15,'About',pal2hex(colors.gray), pal2hex(colors.silver), pal2hex(colors.white), pal2hex(colors.gray))
  --local aboutCloseWindowButton = FlatButton(38, 1, 3, 1, 'x', pal2hex(colors.white), pal2hex(colors.gray))
  local aboutCloseButton = Button(29,14,10,1,'OK', pal2hex(colors.white), pal2hex(colors.lightblue))

  local aLabel1 = Label(3, 3, 'Fusion Reactor Control System')
  local aLabel2 = Label(3, 5, 'version 1.0')
  local aLabel3 = Label(3, 7, 'github.com/mard/oc-programs', pal2hex(colors.lightblue))
  local aLabel4 = Label(3, 9, 'For detailed user\'s manual')
  local aLabel5 = Label(3, 10, 'run "man frcs" in system console.')

  --aboutCloseWindowButton.onTouch = function() aboutClose(aboutGroupBox) end
  aboutCloseButton.onTouch = function() aboutClose(aboutGroupBox) end

  root:add(aboutGroupBox)
  aboutGroupBox:add(aboutCloseButton)
  --aboutGroupBox:add(aboutCloseWindowButton)
  aboutCloseButton:alignCenter()
  aboutGroupBox:add(aLabel1)
  aboutGroupBox:add(aLabel2)
  aboutGroupBox:add(aLabel3)
  aboutGroupBox:add(aLabel4)
  aboutGroupBox:add(aLabel5)
  aLabel1:alignCenter()
  aLabel2:alignCenter()
  aLabel3:alignCenter()
  aLabel4:alignCenter()
  aLabel5:alignCenter()

  workspace.visible = false
  buttonAbout.disabled = true
  root:draw()
end

function aboutClose(aboutGroupBox)
  root:remove(root, aboutGroupBox)
  workspace.visible = true
  buttonAbout.disabled = false
  root:draw()
end

function testDisable()
  if buttonFire.disabled then
    buttonFire:enable()
  else
    buttonFire:disable()
  end
  buttonFire:refresh()
end

while running do
  local id, _, x, y = event.pullMultiple("touch", "drag", "interrupted", "error")
  if id == "interrupted" then
    terminate()
    break
  elseif id == "touch" then
    local touched = root:getTouchedAt(x, y)
    if touched.onTouch then
      touched:doTouch()
    end
    --component.gpu.set(x, y, 'x')
  elseif id == "drag" then
    --component.gpu.set(x, y, '.')
  end
end

-- glowny proces przechwytuje lokalizacje wcisniec...
-- biblioteka zwraca ktory obiekt zostal wcisniety...
-- 

--drawBorder(1,2,80,24,borderSingle, 0xFFFF00, 0x0049FF, true)
--drawBorder(3,2,80-4,3,borderHeavy, 0xFFFF00, 0x006DFF, true)
--drawBorder(3,5,80-4,3)
--drawButton(20,10,15,3, 'meme button', 0xFFFF00, 0x0000FF, 0xFF0000)

