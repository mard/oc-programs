local filesystem = require('filesystem')
local shell = require('shell')
local term = require('term')

local online = true
local args, ops = shell.parse(...)

if ops['o'] or ops['offline'] then
  online = false
end

local files =
{
  { 'bin/frcs.lua', '/bin/frcs.lua' },
  { 'etc/frcs.conf', '/etc/frcs.conf' },
  { '../lib/mgui.lua', '/lib/mgui.lua' },
  { '../lib/mutil.lua', '/lib/mutil.lua' },
  { '../lib/ext/30log.lua', '/lib/30log.lua' },
  { '../lib/ext/inifile.lua', '/lib/inifile.lua' }
}

if online then
else
  print('Starting offline installation...')
  local pwd = shell.getWorkingDirectory()
  for k,v in pairs(files) do
    src = pwd .. v[1]
    dest = v[2]

    term.write('Copying ' .. v[1] .. ' to ' .. dest .. '... ')
    result, details = filesystem.copy(pwd .. '/bin/frcs.lua', '/bin/frcs.lua')
    if result then
      term.write('OK\n')
    else
      term.write('Fail: ' .. details)
    end
  end
end
