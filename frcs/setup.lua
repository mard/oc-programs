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
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/frcs/bin/frcs.lua',
    'bin/frcs.lua',
    '/bin/frcs.lua'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/frcs/etc/frcs.conf',
    'etc/frcs.conf',
    '/etc/frcs.conf'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/lib/mgui.lua',
    '../lib/mgui.lua',
    '/lib/mgui.lua'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/lib/mutil.lua',
    '../lib/mutil.lua',
    '/lib/mutil.lua'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/lib/ext/30log.lua',
    '../lib/ext/30log.lua',
    '/lib/30log.lua'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/lib/ext/inifile.lua',
    '../lib/ext/inifile.lua',
    '/lib/inifile.lua'
  },
  {
    'https://raw.githubusercontent.com/mard/oc-programs/master/frcs/usr/man/frcs',
    'usr/man/frcs',
    '/usr/man/frcs'
  },
}

print('Starting installation...')
local pwd = shell.getWorkingDirectory()
for k,v in pairs(files) do
  src = online and v[1] or pwd .. '/' .. v[2]
  dest = v[3]
  term.write('Copying ' .. src .. ' to ' .. dest .. '... ')
  if online then
    result, details = shell.execute('wget -f ' .. src .. ' ' .. dest), ''
  else
    result, details = filesystem.copy(src, dest)
  end
  if result then
    term.write('OK\n')
  else
    term.write('Fail: ' .. details)
  end
end
