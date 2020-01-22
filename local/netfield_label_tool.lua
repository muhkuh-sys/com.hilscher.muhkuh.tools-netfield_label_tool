local __APPLICATION__ = 'netfieldlabel'
local __VERSION__ = '1.0.0'

require 'muhkuh_cli_init'
local argparse = require 'argparse'
local json = require 'dkjson'
local cNetfieldLabel = require 'netfield_label'
local pl = require'pl.import_into'()
local template = require 'pl.template'


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

local tParser = argparse(__APPLICATION__, 'Make funny stuff with boring labels.')

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
tParser:argument('output')
  :argname('<OUT_FILE>')
  :description('Write the output data to OUT_FILE.')
  :target('strOutputFile')
tParser:option('-p --patch')
  :description('Patch the input data with values from the JSON file PATCH_FILE.')
  :argname('<PATCH_FILE>')
  :default(nil)
  :target('strPatchFile')
tParser:flag('-t --template-mode')
  :description('Run the patch file through the template processor.')
  :target('fTemplateMode')
tParser:option('--input-type')
  :description(string.format('Do not guess the type of the input file but set it to IN_TYPE. Possible values for IN_TYPE are %s.', table.concat(pl.tablex.keys(atFileTypes), ', ')))
  :argname('<IN_TYPE>')
  :convert(atFileTypes)
  :default(nil)
  :target('strInputType')
tParser:option('--output-type')
  :description(string.format('Do not guess the type of the output file but set it to OUT_TYPE. Possible values for OUT_TYPE are %s.', table.concat(pl.tablex.keys(atFileTypes), ', ')))
  :argname('<OUT_TYPE>')
  :convert(atFileTypes)
  :default(nil)
  :target('strOutputType')
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

-- Guess the input and output types if they are not fixed.
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
local strOutputType = tArgs.strOutputType
if strOutputType==nil then
  tLog.debug('Guessing the type of the output file based on the file name "%s".', tArgs.strOutputFile)
  local strSuffix = pl.path.extension(tArgs.strOutputFile)
  if strSuffix=='.json' then
    strOutputType = 'JSON'
  else
    strOutputType = 'BIN'
  end
  tLog.debug('  Guessed file type "%s".', strOutputType)
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


-- Do something with the data...
if tArgs.strPatchFile~=nil then
  tLog.info('Patching with "%s"...', tArgs.strPatchFile)

  -- Read the complete file.
  local strPatchData, strError = pl.utils.readfile(tArgs.strPatchFile, false)
  if strPatchData==nil then
    tLog.error('Failed to read the patch file "%s": %s.', tArgs.strPatchFile, tostring(strError))
    error('Failed to read the patch file.')
  end

  if tArgs.fTemplateMode==true then
    tLog.debug('Processing the patch as a template.')
    -- Use the file as a template.
    local tEnv = {
      string = string,
      table = table
    }
    local strTemplateResult, strError = template.substitute(strPatchData, tEnv)
    if strTemplateResult==nil then
      tLog.error('Failed to process the patch file as a template: %s', strError)
      error('Template error')
    end
    tLog.debug('Result:')
    tLog.debug(strTemplateResult)
    strPatchData = strTemplateResult
  end

  -- Convert the JSON data to a table.
  local tPatchData, strError = json.decode(strPatchData)
  if tPatchData==nil then
    tLog.error('Failed to parse the JSON data: %s', strError)
    error('Patch file is no valid JSON.')
  end

  tNetfieldLabel:patchWithData(tPatchData)
end


tLog.info('Writing "%s".', tArgs.strOutputFile)
if strOutputType=='BIN' then
  local strOutputData = tNetfieldLabel:tobinary(true)
  local tFile = io.open(tArgs.strOutputFile, 'wb')
  tFile:write(strOutputData)
  tFile:close()

else
  local tOutputData = tNetfieldLabel:totable()
  local strJson = json.encode(tOutputData, { indent=true })

  local tFile = io.open(tArgs.strOutputFile, 'w')
  tFile:write(strJson)
  tFile:close()
end

