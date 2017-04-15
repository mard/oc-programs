local colors = require('colors')
local component = require('component')
local computer = require('computer')
local event = require('event')
local filesystem = require('filesystem')
local sides = require('sides')
local term = require('term')
local gpu = term.gpu()

version = '0.1'

genericSharedLibraryError = 'Unable to find shared library.'
genericInstallError = ' ' .. 
'It appears that installation is invalid - have you run ' ..
'"setup" command for this program?'

package.loaded.mgui = nil
assert(filesystem.exists('/lib/mgui.lua'),
  genericSharedLibraryError .. genericInstallError )
local mgui = require('mgui')

package.loaded.mutil = nil
assert(filesystem.exists('/lib/mutil.lua'),
  genericSharedLibraryError .. genericInstallError )
local mutil = require('mutil')

assert(filesystem.exists('/lib/inifile.lua'),
  'Unable to find inifile library.' .. genericInstallError
)

local inifile = require('inifile')

local iniPath = '/etc/frcs.conf'

assert(filesystem.exists(iniPath),
  'Unable to find ' .. iniPath .. ' config file.' .. genericInstallError
)

settings = inifile.parse('/etc/frcs.conf')

if settings.redstone.address_redstone_amplifier then
  laControl = component.proxy(component.get(settings.redstone.address_redstone_amplifier))
end

if settings.redstone.address_redstone_amplifier_power then
  laControlPower = component.proxy(component.get(settings.redstone.address_redstone_amplifier_power))
end

local name = 'Fusion Reactor Control System' --  1.0 by mard
local headerText = name
local footerText = computer.freeMemory() .. ' bytes free'

local root = Box(1,1,80,25, mutil.pal2hex(colors.blue))

local header = Box(1,1,80,1,mutil.pal2hex(colors.lightblue))
local headerLabel = Label(1,1, headerText, mutil.pal2hex(colors.white))

local buttonQuit = FlatButton(78, 1, 3, 1, 'x', mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
buttonQuit.onTouch = function() terminate() end

local buttonAbout = FlatButton(74, 1, 3, 1, '?', mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
buttonAbout.onTouch = function() about() end

--local buttonLog = FlatButton(68, 1, 5, 1, 'log', mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
--buttonLog.onTouch = function() testDisable() end

--local buttonConfig = FlatButton(59, 1, 8, 1, 'config', mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
--buttonConfig.onTouch = function() quit() end

local footer = Box(1,25,80,1,mutil.pal2hex(colors.lightblue))
local footerLabel = Label(1,1, footerText, mutil.pal2hex(colors.white))
local workspace = Box(1,2,80,23,mutil.pal2hex(colors.blue))

local imGroupBox = GroupBox(3,2,76,6,'Induction Matrix',mutil.pal2hex(colors.gray), mutil.pal2hex(colors.silver), mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
local imInput = Label(4, 3, 'Input:')
local imOutput = Label(3, 5, 'Output:')
local imCharge = ProgressBar(25,3,50,3,0,0,25600000000, 'RF', '', 20000, mutil.pal2hex(colors.lime),mutil.pal2hex(colors.gray))

local laGroupBox = GroupBox(3,9,76,6,'Laser Amplifier',mutil.pal2hex(colors.gray), mutil.pal2hex(colors.silver), mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
local laCharge = ProgressBar(3,3,62,3,0,0,2000000000, 'RF', 'Powered', 20000, mutil.pal2hex(colors.lime),mutil.pal2hex(colors.gray))

local rcGroupBox = GroupBox(3,16,76,6,'Reactor Chamber',mutil.pal2hex(colors.gray), mutil.pal2hex(colors.silver), mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
local rcStatusLabel = Label(4,3,'Ignited:')
local rcStatus = Label(13,3,'Ignited')
local rcRateLabel = Label(3,4,'Inj Rate:')
local rcRate = Label(13,4,'2')
local rcOutputLabel = Label(5,5,'Output:')
local rcOutput = Label(13,5,'12345')

local rcCharge = ProgressBar(25,3,50,1,0,0,400000000, 'RF', 'Internal Buffer', 20000, mutil.pal2hex(colors.lime),mutil.pal2hex(colors.gray))
local rcPlasma = ProgressBar(25,4,50,1,118145963,0,400000000, 'K', 'Plasma Temp.', 20000, mutil.pal2hex(colors.pink),mutil.pal2hex(colors.gray))
local rcCase = ProgressBar(25,5,50,1,218645463,0,400000000, 'K', 'Case Temp.', 20000, mutil.pal2hex(colors.pink),mutil.pal2hex(colors.gray))

local laFire = Button(67,3,8,3,'FIRE', mutil.pal2hex(colors.white), mutil.pal2hex(colors.red))
laFire.onTouch = function() fire() end

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
laGroupBox:add(laFire)

workspace:add(rcGroupBox)
rcGroupBox:add(rcStatusLabel)
rcGroupBox:add(rcStatus)
rcGroupBox:add(rcRateLabel)
rcGroupBox:add(rcRate)
rcGroupBox:add(rcOutputLabel)
rcGroupBox:add(rcOutput)
rcGroupBox:add(rcCharge)
rcGroupBox:add(rcPlasma)
rcGroupBox:add(rcCase)

root:add(footer)
footer:add(footerLabel)

term.clear()
root:draw()

local running = true
function quit()
  print("elo")
end

dummy = {}
dummy.induction_matrix = {}
function dummy.induction_matrix.getInput()
  return math.random() + math.random(217886*2.5)
end

function dummy.induction_matrix.getOutput()
  return math.random() + math.random(217886*2.5)
end

function dummy.induction_matrix.getEnergy()
  return math.random() + math.random(25600000000*2.5)
end

function dummy.induction_matrix.getMaxEnergy()
  return 25600000000*2.5
end

dummy.laser_amplifier = {}
function dummy.laser_amplifier.getEnergy()
  --return math.random() + math.random(2000000000*2.5)
  return math.random(dummy.laser_amplifier.getMaxEnergy()-1, dummy.laser_amplifier.getMaxEnergy())
end

function dummy.laser_amplifier.getMaxEnergy()
  return 2000000000 * 2.5
end

dummy.reactor_logic_adapter = {}
function dummy.reactor_logic_adapter.isIgnited()
  return math.random(0,1) == 1
end

function dummy.reactor_logic_adapter.getInjectionRate()
  return math.random(0,2) * 2
end

function dummy.reactor_logic_adapter.getProducing()
  return math.random() + math.random(217886*2.5)
end

function dummy.reactor_logic_adapter.getEnergy()
  return math.random() + math.random(400000000*2.5)
end

function dummy.reactor_logic_adapter.getMaxEnergy()
  return 400000000 * 2.5
end

function dummy.reactor_logic_adapter.getPlasmaHeat()
  return math.random() + math.random(100)
end

function dummy.reactor_logic_adapter.getMaxPlasmaHeat()
  return 100
end

function dummy.reactor_logic_adapter.getCaseHeat()
  return math.random() + math.random(100)
end

function dummy.reactor_logic_adapter.getMaxCaseHeat()
  return 100
end

local provider = component

function imDataRefresh()
  if not provider.induction_matrix then
    return
  else
    imDataInput = provider.induction_matrix.getInput() * settings.general.energy_rate
    imDataOutput = provider.induction_matrix.getOutput() * settings.general.energy_rate
    imDataEnergy = provider.induction_matrix.getEnergy() * settings.general.energy_rate
    imDataMaxEnergy = provider.induction_matrix.getMaxEnergy() * settings.general.energy_rate
  end
end

function laDataRefresh()
  if not provider.laser_amplifier then
    return
  else
    laDataEnergy = provider.laser_amplifier.getEnergy() * settings.general.energy_rate
    laDataMaxEnergy = provider.laser_amplifier.getMaxEnergy() * settings.general.energy_rate
  end
end

function rcDataRefresh()
  if not provider.reactor_logic_adapter then
    return
  else
    rcDataIgnited = provider.reactor_logic_adapter.isIgnited() 
    rcDataRate = provider.reactor_logic_adapter.getInjectionRate()
    rcDataOutput = provider.reactor_logic_adapter.getProducing() * settings.general.energy_rate
    rcDataEnergy = provider.reactor_logic_adapter.getEnergy() * settings.general.energy_rate
    rcDataMaxEnergy = provider.reactor_logic_adapter.getMaxEnergy() * settings.general.energy_rate
    rcDataPlasmaHeat = provider.reactor_logic_adapter.getPlasmaHeat()
    rcDataMaxPlasmaHeat = provider.reactor_logic_adapter.getMaxPlasmaHeat()
    rcDataCaseHeat = provider.reactor_logic_adapter.getCaseHeat()
    rcDataMaxCaseHeat = provider.reactor_logic_adapter.getMaxCaseHeat()
  end
end

function imUiRefresh()
  local input, iunit, _ = mutil.prefixize(imDataInput, 5000)
  imInput.text = 'Input: ' .. mutil.round(input, 2) .. ' ' .. iunit .. 'RF/t'

  local output, ounit, _ = mutil.prefixize(imDataOutput, 5000)
  imOutput.text = 'Output: ' .. mutil.round(output, 2) .. ' ' .. ounit .. 'RF/t'

  imCharge.max = imDataMaxEnergy
  imCharge.value = imDataEnergy

  imCharge:refresh()
  imGroupBox:draw()
end

function laUiRefresh()
  laCharge.value = laDataEnergy

  laCharge:refresh()
  laCharge:draw()
end

function rcUiRefresh()
  rcStatus.text = tostring(rcDataIgnited)
  rcRate.text = tostring(rcDataRate)

  local output, ounit, _ = mutil.prefixize(rcDataOutput, 1000)
  --output, ounit = 2, ''
  rcOutput.text = mutil.round(output, 2) .. ' ' .. ounit .. 'RF/t'

  rcCharge.max = rcDataMaxEnergy
  rcCharge.value = rcDataEnergy
  rcCharge:refresh()

  rcPlasma.max = rcDataMaxPlasmaHeat
  rcPlasma.value = rcDataPlasmaHeat
  rcPlasma:refresh()

  rcCase.max = rcDataMaxCaseHeat
  rcCase.value = rcDataCaseHeat
  rcCase:refresh()

  rcGroupBox:draw()
end

function handleFire()
  if not settings.amplifier.injection_rate_safety then
    return
  end
  if rcDataRate == 0 then laFire:disable() else laFire:enable() end
  laFire:refresh()
  laFire:draw()
end

function handleLaPower()
  local laCutPower = laDataEnergy == laDataMaxEnergy
  laCharge.name = laCutPower and 'Not Powered' or 'Powered'
  sendLaPowered(laCutPower)
end

function sendLaPowered(cut)
  if not laControlPower or not settings.amplifier.automatic_power_cutoff then
    return
  end
  for k,v in ipairs(sides) do
    laControlPower.setOutput(k-1, cut and 255 or 0)
  end
end

function check()
  imDataRefresh()
  laDataRefresh()
  rcDataRefresh()

  handleLaPower()
  handleFire()

  imUiRefresh()
  laUiRefresh()
  rcUiRefresh()
end

function fire()
  if not laControl then
    return
  end
  for k,v in ipairs(sides) do
    laControl.setOutput(k-1, 255)
  end
  os.sleep(0.1)
  for k,v in ipairs(sides) do
    laControl.setOutput(k-1, 0)
  end
  check()
end

function startTimer()
  timerCheck = event.timer(settings.general.refresh_interval, check, math.huge)
end

function stopTimer()
  if timerCheck then
    event.cancel(timerCheck)
  end
end

startTimer()
check()

function terminate()
  running = false
  stopTimer()
  mutil.resetBackground()
  mutil.resetForeground()
  term.clear()
  print("soft interrupt, closing")
end

function about()
  stopTimer()

  local aboutGroupBox = GroupBox(20,6,40,15,'About',mutil.pal2hex(colors.gray), mutil.pal2hex(colors.silver), mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
  --local aboutCloseWindowButton = FlatButton(38, 1, 3, 1, 'x', mutil.pal2hex(colors.white), mutil.pal2hex(colors.gray))
  local aboutCloseButton = Button(29,14,10,1,'OK', mutil.pal2hex(colors.white), mutil.pal2hex(colors.lightblue))

  local aLabel1 = Label(3, 3, 'Fusion Reactor Control System')
  local aLabel2 = Label(3, 5, 'version ' .. version)
  local aLabel3 = Label(3, 7, 'github.com/mard/oc-programs', mutil.pal2hex(colors.lightblue))
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

  startTimer()
  check()
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
  end
end

-- glowny proces przechwytuje lokalizacje wcisniec...
-- biblioteka zwraca ktory obiekt zostal wcisniety...
-- 

--drawBorder(1,2,80,24,borderSingle, 0xFFFF00, 0x0049FF, true)
--drawBorder(3,2,80-4,3,borderHeavy, 0xFFFF00, 0x006DFF, true)
--drawBorder(3,5,80-4,3)
--drawButton(20,10,15,3, 'meme button', 0xFFFF00, 0x0000FF, 0xFF0000)

