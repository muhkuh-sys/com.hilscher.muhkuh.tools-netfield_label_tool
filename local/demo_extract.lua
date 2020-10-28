local __APPLICATION__ = 'demo_extract'
local __VERSION__ = '1.0.0'

require 'muhkuh_cli_init'
local argparse = require 'argparse'
local cNetfieldLabel = require 'netfield_label'
local json = require 'dkjson'
local pl = require'pl.import_into'()


local function hexdump(aucData)
  local atHex = {}
  for _, ucData in ipairs(aucData) do
    table.insert(atHex, string.format('%02x', ucData))
  end
  return table.concat(atHex)
end


local atLogLevels = {
  ['debug'] = 'debug',
  ['info'] = 'info',
  ['warning'] = 'warning',
  ['error'] = 'error',
  ['fatal'] = 'fatal'
}
local atFileTypes = {
  ['BIN'] = 'BIN',
  ['JSON'] = 'JSON'
}

local tParser = argparse(__APPLICATION__, 'Extract a set of fields from a label.')

-- "--version" is special. It behaves like a command and is processed immediately during parsing.
tParser:flag('--version')
  :description('Show the version and exit.')
  :action(function()
    print(string.format('%s %s', __APPLICATION__, __VERSION__))
    print('Copyright (C) 2019 by Christoph Thelen (doc_bacardi@users.sourceforge.net)')
    os.exit(0)
  end)

tParser:argument('input')
  :argname('<IN_FILE>')
  :description('Read the input data from IN_FILE.')
  :target('strInputFile')
tParser:option('--input-type')
  :description(string.format('Do not guess the type of the input file but set it to IN_TYPE. Possible values for IN_TYPE are %s.', table.concat(pl.tablex.keys(atFileTypes), ', ')))
  :argname('<IN_TYPE>')
  :convert(atFileTypes)
  :default(nil)
  :target('strInputType')
tParser:option('-s --skip-input')
  :description('Skip the first SKIP bytes when reading a binary input. The default is to skip no bytes.')
  :argname('<SKIP>')
  :convert(tonumber)
  :default(0)
  :target('ulSkip')
tParser:option('-v --verbose')
  :description(string.format('Set the verbosity level to LEVEL. Possible values for LEVEL are %s.', table.concat(pl.tablex.keys(atLogLevels), ', ')))
  :argname('<LEVEL>')
  :convert(atLogLevels)
  :default('info')
  :target('strLogLevel')
local tArgs = tParser:parse()

local tLogWriter = require 'log.writer.console.color'.new()
local tLog = require "log".new(
  tArgs.strLogLevel,
  tLogWriter,
  require "log.formatter.format".new()
)

-- Guess the input type if it is not fixed.
-- This is rather simple: if the file suffix is ".json" then the type is "JSON". Otherwise it is "BIN".
local strInputType = tArgs.strInputType
if strInputType==nil then
  tLog.debug('Guessing the type of the input file based on the file name "%s".', tArgs.strInputFile)
  local strSuffix = pl.path.extension(tArgs.strInputFile)
  if strSuffix=='.json' then
    strInputType = 'JSON'
  else
    strInputType = 'BIN'
  end
  tLog.debug('  Guessed file type "%s".', strInputType)
end


-- Create a new empty label.
local tNetfieldLabel = cNetfieldLabel(tLog)

-- Read the input file.
tLog.info('Reading "%s".', tArgs.strInputFile)
if strInputType=='BIN' then
  local tFile, strError = io.open(tArgs.strInputFile, 'rb')
  if tFile==nil then
    tLog.error('Failed to read the input file from "%s": %s', tArgs.strInputFile, strError)
    error('Failed to read the input file.')
  end
  if tArgs.ulSkip>0 then
    local tResult, strError = tFile:seek('set', tArgs.ulSkip)
    if tResult==nil then
      tLog.error('Failed to seek the input file "%s" to offset %d: %s', tArgs.strInputFile, tArgs.ulSkip, strError)
      error('Failed to seek the input file.')
    end
  end
  local strInputData = tFile:read(0x0c00)
  if strInputData==nil then
    tLog.error('Failed to read the input file "%s".', tArgs.strInputFile)
    error('Failed to read the input file.')
  end
  tFile:close()

  -- Parse the input.
  tNetfieldLabel:readBinary(strInputData)

else
  -- Read the complete file.
  local strInputData, strError = pl.utils.readfile(tArgs.strInputFile, false)
  if strInputData==nil then
    tLog.error('Failed to read the input file "%s": %s.', tArgs.strInputFile, strError)
    error('Failed to read the input file.')
  end

  -- Parse the input.
  tNetfieldLabel:readJson(strInputData)
end


-- Get the label data as a LUA table.
local tLabelData = tNetfieldLabel:totable()
-- Loop over all elements in the taglist.
for _, tEntry in ipairs(tLabelData) do
  -- Only process "NETIOL_PRODUCTION_DATA_V2" tags.
  local strTagType = tEntry.id
  if strTagType=='NETIOL_PRODUCTION_DATA_V2' then
    tLog.debug('Processing tag "%s".', strTagType)
    -- Get the field "abCalibrationRoutineVersion".
    local atData = tEntry.data
    local aucCalibrationRoutineVersion = atData.abCalibrationRoutineVersion
    -- Make a hexdump from the field.
    tLog.info('Calibration routine version: %s', hexdump(aucCalibrationRoutineVersion))
  else
    tLog.debug('Skipping tag "%s".', strTagType)
  end
end