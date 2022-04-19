local class = require 'pl.class'
local netFieldLabel = class()

function netFieldLabel:_init(tLog)
  local vstruct = require 'vstruct'
  self.mhash = require 'mhash'
  self.pl = require 'pl.import_into'()
  self.template = require 'pl.template'

  self.tLog = tLog

  self.tTags = nil
  self.sizStandardLabel = 0x0c00

  self.tNetFieldLabelHeader = vstruct.compile([[
    abStartToken:s12
    usLabelSize:u2
    usContentSize:u2
  ]])
  self.sizNetFieldLabelHeader = 16

  self.tNetFieldLabelFooter = vstruct.compile([[
    ulChecksum:u4
    aucEndLabel:s12
  ]])
  self.sizNetFieldLabelFooter = 16

  self.tNetFieldLabelTagHeader = vstruct.compile([[
    usIdentifer:u2
    usLength:u2
  ]])
  self.sizNetFieldLabelTagHeader = 4


  self.NETFIELD_TAG_ID_NDIS_CHANNEL_MODE         = 0x0001
  self.NETFIELD_TAG_ID_BLUETOOTH_MODULE          = 0x0002
  self.NETFIELD_TAG_ID_HARDWARE_VARIANT_NUMBER   = 0x0003
  self.NETFIELD_TAG_ID_PRODUCTION_MODE           = 0x0004
  self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA    = 0x0005
  self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA_V2 = 0x0006
  self.NETFIELD_TAG_ID_WIRELESS_CONFIGURATION    = 0x0010
  self.NETFIELD_TAG_ID_WIRED_IDENTIFIER          = 0x0011

  self.atTags = {
    [self.NETFIELD_TAG_ID_NDIS_CHANNEL_MODE] = {
      id = self.NETFIELD_TAG_ID_NDIS_CHANNEL_MODE,
      name = 'NDIS_CHANNEL_MODE',
      tStruct = vstruct.compile([[
        bAvailable:u1
        abReserved:{
          3*u1
        }
      ]]),
      sizStruct = 4,
      strPretty = [[
        bAvailable: $(string.format("%d", data.bAvailable))
      ]]
    },
    [self.NETFIELD_TAG_ID_BLUETOOTH_MODULE] = {
      id = self.NETFIELD_TAG_ID_BLUETOOTH_MODULE,
      name = 'BLUETOOTH_MODULE',
      tStruct = vstruct.compile([[
        bAvailable:u1
        abReserved:{
          3*u1
        }
      ]]),
      sizStruct = 4,
      strPretty = [[
        bAvailable: $(string.format("%d", data.bAvailable))
      ]]
    },
    [self.NETFIELD_TAG_ID_HARDWARE_VARIANT_NUMBER] = {
      id = self.NETFIELD_TAG_ID_HARDWARE_VARIANT_NUMBER,
      name = 'HARDWARE_VARIANT_NUMBER',
      tStruct = vstruct.compile([[
        bHardwareVariantNumber:u1
        abReserved:{
          3*u1
        }
      ]]),
      sizStruct = 4,
      strPretty = [[
        bAvailable: $(string.format("%d", data.bHardwareVariantNumber))
      ]]
    },
    [self.NETFIELD_TAG_ID_PRODUCTION_MODE] = {
      id = self.NETFIELD_TAG_ID_PRODUCTION_MODE,
      name = 'PRODUCTION_MODE',
      tStruct = vstruct.compile([[
        bProductionMode:u1
        abReserved:{
          3*u1
        }
      ]]),
      sizStruct = 4,
      strPretty = [[
        bAvailable: $(string.format("%d", data.bProductionMode))
      ]]
    },
    [self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA] = {
      id = self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA,
      name = 'NETIOL_PRODUCTION_DATA',
      tStruct = vstruct.compile([[
        usAsicCtrlSystemCalibrationRegister0:u2
        usAsicCtrlSystemCalibrationRegister1:u2

        aulPinAssignment:{
          12*u4
        }

        atGateConfig:{
          12*{
            usTau:u2
            bTauShift:u1
            bTJDeltaMax:u1
            usTpInc:u2
            usSjIl:u2
            usILimMax:u2
            usInterval:u2
            usOCInc:u2
            sTpOff:i2
            sSjIlOff:i2
          }
        }

        tNetIolCalibration:{
          atPortCalibration:{
            4*{
              ulCqPinOffset:u4
              ulCqPinGain:u4
              ulDiPinOffset:u4
              ulDiPinGain:u4
              ulAiVoltagePinOffset:u4
              ulAiVoltagePinGain:u4
              ulCurrentGate0Offset:u4
              ulCurrentGate0Gain:u4
              ulCurrentGate1Offset:u4
              ulCurrentGate1Gain:u4
              ulCurrentGate2Offset:u4
              ulCurrentGate2Gain:u4
            }
          }
          ulDixPinOffset:u4
          ulDixPinGain:u4
        }

        ausGateMaxCurrentInfo:{
          12*u2
        }
      ]]),
      sizStruct = 492,
      strPretty = [[
        usAsicCtrlSystemCalibrationRegister0: $(string.format('0x%04x', data.usAsicCtrlSystemCalibrationRegister0))
        usAsicCtrlSystemCalibrationRegister1: $(string.format('0x%04x', data.usAsicCtrlSystemCalibrationRegister1))

        aulPinAssignment:
# for uiCnt, ulValue in ipairs(data.aulPinAssignment) do
          $(string.format('[%02d] = 0x%08x', uiCnt-1, ulValue))
# end

        atGateConfig:
# for uiCnt, tGateConfig in ipairs(data.atGateConfig) do
          $(string.format('[%02d] = [', uiCnt-1))
            usTau: $(string.format('%d', tGateConfig.usTau))
            bTauShift: $(string.format('%d', tGateConfig.bTauShift))
            bTJDeltaMax: $(string.format('%d', tGateConfig.bTJDeltaMax))
            usTpInc: $(string.format('%d', tGateConfig.usTpInc))
            usSjIl: $(string.format('%d', tGateConfig.usSjIl))
            usILimMax: $(string.format('%d', tGateConfig.usILimMax))
            usInterval: $(string.format('%d', tGateConfig.usInterval))
            usOCInc: $(string.format('%d', tGateConfig.usOCInc))
            sTpOff: $(string.format('%d', tGateConfig.sTpOff))
            sSjIlOff: $(string.format('%d', tGateConfig.sSjIlOff))
          ]
# end

        tNetIolCalibration:
          atPortCalibration:
# for uiCnt, tPortCalibration in ipairs(data.tNetIolCalibration.atPortCalibration) do
            $(string.format('[%02d] = [', uiCnt-1))
              ulCqPinOffset: $(string.format('%d', tPortCalibration.ulCqPinOffset))
              ulCqPinGain: $(string.format('%d', tPortCalibration.ulCqPinGain))
              ulDiPinOffset: $(string.format('%d', tPortCalibration.ulDiPinOffset))
              ulDiPinGain: $(string.format('%d', tPortCalibration.ulDiPinGain))
              ulAiVoltagePinOffset: $(string.format('%d', tPortCalibration.ulAiVoltagePinOffset))
              ulAiVoltagePinGain: $(string.format('%d', tPortCalibration.ulAiVoltagePinGain))
              ulCurrentGate0Offset: $(string.format('%d', tPortCalibration.ulCurrentGate0Offset))
              ulCurrentGate0Gain: $(string.format('%d', tPortCalibration.ulCurrentGate0Gain))
              ulCurrentGate1Offset: $(string.format('%d', tPortCalibration.ulCurrentGate1Offset))
              ulCurrentGate1Gain: $(string.format('%d', tPortCalibration.ulCurrentGate1Gain))
              ulCurrentGate2Offset: $(string.format('%d', tPortCalibration.ulCurrentGate2Offset))
              ulCurrentGate2Gain: $(string.format('%d', tPortCalibration.ulCurrentGate2Gain))
            }
# end
          ulDixPinOffset: $(string.format('%d', data.tNetIolCalibration.ulDixPinOffset))
          ulDixPinGain: $(string.format('%d', data.tNetIolCalibration.ulDixPinGain))

        ausGateMaxCurrentInfo:
# for uiCnt, usValue in ipairs(data.ausGateMaxCurrentInfo) do
          $(string.format('[%02d] = 0x%04x', uiCnt-1, usValue))
# end
      ]]
    },
    [self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA_V2] = {
      id = self.NETFIELD_TAG_ID_NETIOL_PRODUCTION_DATA_V2,
      name = 'NETIOL_PRODUCTION_DATA_V2',
      tStruct = vstruct.compile([[
        usAsicCtrlSystemCalibrationRegister0:u2
        usAsicCtrlSystemCalibrationRegister1:u2

        tNetIolCalibration:{
          atPortCalibration:{
            4*{
              ulCqPinOffset:u4
              ulCqPinGain:u4
              ulDiPinOffset:u4
              ulDiPinGain:u4
              ulAiVoltagePinOffset:u4
              ulAiVoltagePinGain:u4
              ulCurrentGate0Offset:u4
              ulCurrentGate0Gain:u4
              ulCurrentGate1Offset:u4
              ulCurrentGate1Gain:u4
              ulCurrentGate2Offset:u4
              ulCurrentGate2Gain:u4
            }
          }
          ulDixPinOffset:u4
          ulDixPinGain:u4
        }

        aulPinAssignment:{
          12*u4
        }

        abDefaultFunction:{
          12*u1
        }

        atGateConfig:{
          12*{
            usTau:u2
            bTauShift:u1
            bTJDeltaMax:u1
            usTpInc:u2
            usSjIl:u2
            usILimMax:u2
            usInterval:u2
            usOCInc:u2
            sTpOff:i2
            sSjIlOff:i2
            usPad:u2
          }
        }

        ausGateMaxCurrentInfo:{
          12*u2
        }

        bSupplyVoltageReferenceType:u1

        abCalibrationRoutineVersion:{
          8*u1
        }

        abReserved:{
          11*u1
        }
      ]]),
      sizStruct = 548,
      strPretty = [[
        usAsicCtrlSystemCalibrationRegister0: $(string.format('0x%04x', data.usAsicCtrlSystemCalibrationRegister0))
        usAsicCtrlSystemCalibrationRegister1: $(string.format('0x%04x', data.usAsicCtrlSystemCalibrationRegister1))

        tNetIolCalibration:
          atPortCalibration:
# for uiCnt, tPortCalibration in ipairs(data.tNetIolCalibration.atPortCalibration) do
            $(string.format('[%02d] = [', uiCnt-1))
              ulCqPinOffset: $(string.format('%d', tPortCalibration.ulCqPinOffset))
              ulCqPinGain: $(string.format('%d', tPortCalibration.ulCqPinGain))
              ulDiPinOffset: $(string.format('%d', tPortCalibration.ulDiPinOffset))
              ulDiPinGain: $(string.format('%d', tPortCalibration.ulDiPinGain))
              ulAiVoltagePinOffset: $(string.format('%d', tPortCalibration.ulAiVoltagePinOffset))
              ulAiVoltagePinGain: $(string.format('%d', tPortCalibration.ulAiVoltagePinGain))
              ulCurrentGate0Offset: $(string.format('%d', tPortCalibration.ulCurrentGate0Offset))
              ulCurrentGate0Gain: $(string.format('%d', tPortCalibration.ulCurrentGate0Gain))
              ulCurrentGate1Offset: $(string.format('%d', tPortCalibration.ulCurrentGate1Offset))
              ulCurrentGate1Gain: $(string.format('%d', tPortCalibration.ulCurrentGate1Gain))
              ulCurrentGate2Offset: $(string.format('%d', tPortCalibration.ulCurrentGate2Offset))
              ulCurrentGate2Gain: $(string.format('%d', tPortCalibration.ulCurrentGate2Gain))
            }
# end
          ulDixPinOffset: $(string.format('%d', data.tNetIolCalibration.ulDixPinOffset))
          ulDixPinGain: $(string.format('%d', data.tNetIolCalibration.ulDixPinGain))

        aulPinAssignment:
# for uiCnt, ulValue in ipairs(data.aulPinAssignment) do
          $(string.format('[%02d] = 0x%08x', uiCnt-1, ulValue))
# end

        abDefaultPinFunction:
# for uiCnt, ucValue in ipairs(data.abDefaultPinFunction) do
          $(string.format('[%02d] = 0x%02x', uiCnt-1, ulValue))
# end

        atGateConfig:
# for uiCnt, tGateConfig in ipairs(data.atGateConfig) do
          $(string.format('[%02d] = [', uiCnt-1))
            usTau: $(string.format('%d', tGateConfig.usTau))
            bTauShift: $(string.format('%d', tGateConfig.bTauShift))
            bTJDeltaMax: $(string.format('%d', tGateConfig.bTJDeltaMax))
            usTpInc: $(string.format('%d', tGateConfig.usTpInc))
            usSjIl: $(string.format('%d', tGateConfig.usSjIl))
            usILimMax: $(string.format('%d', tGateConfig.usILimMax))
            usInterval: $(string.format('%d', tGateConfig.usInterval))
            usOCInc: $(string.format('%d', tGateConfig.usOCInc))
            sTpOff: $(string.format('%d', tGateConfig.sTpOff))
            sSjIlOff: $(string.format('%d', tGateConfig.sSjIlOff))
          ]
# end

        ausGateMaxCurrentInfo:
# for uiCnt, usValue in ipairs(data.ausGateMaxCurrentInfo) do
          $(string.format('[%02d] = 0x%04x', uiCnt-1, usValue))
# end

        bSupplyVoltageReferenceType: $(string.format('0x%04x', data.bSupplyVoltageReferenceType))

        abCalibrationRoutineVersion:
# for uiCnt, ucValue in ipairs(data.abCalibrationRoutineVersion) do
          $(string.format('[%02d] = 0x%02x', uiCnt-1, ucValue))
# end
      ]]
    },
    [self.NETFIELD_TAG_ID_WIRELESS_CONFIGURATION] = {
      id = self.NETFIELD_TAG_ID_WIRELESS_CONFIGURATION,
      name = 'WIRELESS_CONFIGURATION',
      tStruct = vstruct.compile([[
        bNumberOfTracks:u1
        bNumberOfPorts:u1
        abReserved:{
          30*u1
        }
      ]]),
      sizStruct = 32,
      strPretty = [[
        bNumberOfTracks: $(string.format("%d", data.bNumberOfTracks))
        bNumberOfPorts: $(string.format("%d", data.bNumberOfPorts))
      ]]
    },
    [self.NETFIELD_TAG_ID_WIRED_IDENTIFIER] = {
      id = self.NETFIELD_TAG_ID_WIRED_IDENTIFIER,
      name = 'WIRED_IDENTIFIER',
      tStruct = vstruct.compile([[
        ulIolmProductId:u4
        usIolmVendorId:u2
        abReserved:{
          10*u1
        }
      ]]),
      sizStruct = 16,
      strPretty = [[
        ulIolmProductId: $(string.format("0x%08x", data.ulIolmProductId))
        usIolmVendorId: $(string.format("0x%04x", data.usIolmVendorId))
      ]]
    }
  }
end


function netFieldLabel:__build_contents_crc(strContents)
  local mh = self.mhash.mhash_state()
  mh:init(self.mhash.MHASH_CRC32B)
  mh:hash(strContents)
  local tHash = mh:hash_end()
  local ulCrc32 = string.byte(tHash,1) + 0x00000100*string.byte(tHash,2) + 0x00010000*string.byte(tHash,3) + 0x01000000*string.byte(tHash,4)
  return ulCrc32
end



function netFieldLabel:__binary2Tags(strTags)
  -- Be optimistic.
  local tResult = true
  local tLog = self.tLog

  local tTags = {}

  -- Loop over all tags.
  local uiTagCnt = 1
  local ulOffsetCnt = 1
  local ulOffsetEnd = string.len(strTags)
  while ulOffsetCnt<=ulOffsetEnd do
    -- Is enough data for a header left?
    local ulDataLeft = 1 + ulOffsetEnd - ulOffsetCnt
    if ulDataLeft<self.sizNetFieldLabelTagHeader then
      -- No space for a complete header left.
      tLog.warning('Not enough data for a complete header left.')
    else
      local strHeader = string.sub(strTags, ulOffsetCnt, ulOffsetCnt+self.sizNetFieldLabelTagHeader)
      local tHeader = self.tNetFieldLabelTagHeader:read(strHeader)

      local usIdentifer = tHeader.usIdentifer
      local tTagAttr = self.atTags[usIdentifer]
      if tTagAttr==nil then
        tLog.error('Tag ID %d is unknown.', usIdentifer)
        tResult = false
        break
      else
        local sizTag = tHeader.usLength
        tLog.debug('Found Tag "%s" (%d) with %d bytes data.', tTagAttr.name, usIdentifer, sizTag)
        if sizTag~=tTagAttr.sizStruct then
          tLog.error('Tag %d (ID %d) has an invalid amount of data. %d bytes were expected, %d were found.', uiTagCnt, tTagAttr.id, tTagAttr.sizStruct, sizTag)
          tResult = false
          break
        else
           ulOffsetCnt = ulOffsetCnt + self.sizNetFieldLabelTagHeader
           ulDataLeft = 1 + ulOffsetEnd - ulOffsetCnt
           if ulDataLeft<sizTag then
             tLog.error('Tag %d requests %d bytes of data, but only %d bytes are left.', uiTagCnt, sizTag, ulDataLeft)
             tResult = false
             break
           else
             -- Try to parse the tag.
             local strData = string.sub(strTags, ulOffsetCnt, ulOffsetCnt+sizTag)
             local tTag = tTagAttr.tStruct:read(strData)

             table.insert(tTags, {
               id = usIdentifer,
               data = tTag,
               attr = tTagAttr
             })

             ulOffsetCnt = ulOffsetCnt + sizTag
           end
        end
      end
    end
  end

  if tResult==true then
    self.tTags = tTags
  end

  return tResult
end



function netFieldLabel:__tags2binary(tTags)
  local tLog = self.tLog
  local atBinTags = {}

  for uiCnt, tAttr in ipairs(tTags) do
    local strData, strError = tAttr.attr.tStruct:write(tAttr.data)
    if strData==nil then
      tLog.error('Failed to encode tag %d: %s', uiCnt, strError)
      atBinTags = nil
      break
    else
      local sizData = string.len(strData)
      if sizData~=tAttr.attr.sizStruct then
        tLog.error('The encoded data of tag %d has an unexpected size of %d. Expected %d bytes.', uiCnt, sizData, tAttr.attr.sizStruct)
        atBinTags = nil
        break
      else
        tLog.debug('Dump tag %d: "%s" (%d) with %d bytes.', uiCnt, tAttr.attr.name, tAttr.id, sizData)

        -- Create a header for the tag.
        local strHeader = self.tNetFieldLabelTagHeader:write({
          usIdentifer = tAttr.id,
          usLength = sizData
        })

        table.insert(atBinTags, strHeader .. strData)
      end
    end
  end

  local tResult
  if atBinTags~=nil then
    tResult = table.concat(atBinTags)
  end

  return tResult
end



function netFieldLabel:dump()
  local pl = self.pl
  local template = self.template
  local tLog = self.tLog
  local tTags = self.tTags
  if tTags==nil then
    tLog.info('No tags found.')
  else
    for uiCnt, tAttr in ipairs(tTags) do
      tLog.info('Tag %d: "%s" (%d)', uiCnt, tAttr.attr.name, tAttr.id)

      -- Decode the data.
      local tTemplateEnv = {
        ipairs = ipairs,
        string = string,
        data = tAttr.data
      }
      local strPretty, strError = template.substitute(tAttr.attr.strPretty, tTemplateEnv)
      if strPretty==nil then
        tLog.error('Failed to parse the tag data: %s', strError)
      else
        for strLine in pl.stringx.lines(strPretty) do
          tLog.info('  %s', strLine)
        end
      end
    end
  end
end



function netFieldLabel:readBinary(strLabel)
  local tLog = self.tLog
  local sizNetFieldLabelHeader = self.sizNetFieldLabelHeader
  local sizNetFieldLabelFooter = self.sizNetFieldLabelFooter
  local tResult

  -- Clear any old tags.
  self.tTags = nil

  -- A minimal FDL must be at least header, 1 data byte and the footer.
  if string.len(strLabel)>(sizNetFieldLabelHeader+sizNetFieldLabelFooter) then
    -- Extract the header data.
    local tLabelHeader = self.tNetFieldLabelHeader:read(strLabel)
    if tLabelHeader.abStartToken~='netFIELDtag>' then
      -- Missing start token.
      tLog.error('Missing start token.')

    elseif tLabelHeader.usLabelSize~=(tLabelHeader.usContentSize+sizNetFieldLabelHeader+sizNetFieldLabelFooter) then
      -- Label and header size do not match.
      tLog.error('Label and header size do not match.')

    elseif string.len(strLabel)<tLabelHeader.usLabelSize then
      -- The label is smaller than the header requests.
      tLog.error('The label is smaller than the header requests.')

    else
      -- Extract the contents.
      local strLabelContents = string.sub(strLabel, 1+sizNetFieldLabelHeader, sizNetFieldLabelHeader+tLabelHeader.usContentSize)

      -- Extract the footer.
      local strLabelFooter = string.sub(strLabel, 1+sizNetFieldLabelHeader+tLabelHeader.usContentSize)
      local tLabelFooter = self.tNetFieldLabelFooter:read(strLabelFooter)
      if tLabelFooter.aucEndLabel~='<netFIELDtag' then
        tLog.error('Missing end token.')
      else
        local ulCrc32 = self:__build_contents_crc(strLabelContents)
        if ulCrc32~=tLabelFooter.ulChecksum then
          tLog.error('Input checksum mismatch. File=0x%08x Calculated=0x%08x', tLabelFooter.ulChecksum, ulCrc32)
        else
          self:__binary2Tags(strLabelContents)
          tResult = true
        end
      end
    end
  end

  return tResult
end



function netFieldLabel:readJson(tJson)
  local tResult = true
  local tTags = {}

  -- The input must be a table.
  if type(tJson)~='table' then
    tLog.error('The function "readJson" must have a table as a parameter.')
    tResult = false
  else

    -- Loop over all entries in the table.
    for uiCnt, tJson in ipairs(tJson) do
      -- Each entry must have an "id" and a "data" entry.
      local strId = tJson.id
      local tData = tJson.data
      if strId==nil then
        tLog.error('Entry %d has no "id" entry.', uiCnt)
        tResult = false
      elseif type(strId)~='string' then
        tLog.error('The attribute "id" of entry %d is no string.', uiCnt)
        tResult = false
      end
      if tData==nil then
        tLog.error('Entry %d has no "data" entry.', uiCnt)
        tResult = false
      elseif type(tData)~='table' then
        tLog.error('The attribute "data" of entry %d is no table.', uiCnt)
        tResult = false
      end
      if tResult~=true then
        break
      end

      -- Find the tag definition for the ID.
      local tTag
      for _, tTagCnt in pairs(self.atTags) do
        if tTagCnt.name==strId then
          tTag = tTagCnt
          break
        end
      end
      if tTag==nil then
        tLog.error('Entry %d has an invalid tag name: "%s"', uiCnt, strId)
        tResult = false
        break
      end

      -- Try to decode the data.
      local tTest = tTag.tStruct:write(tData)
      if tTest==nil then
        tLog.error('The data of entry %d can not be parsed.', uiCnt)
        tResult = false
        break
      end

      -- Append the new entry to the list of tags.
      table.insert(tTags, {
        id = tTag.id,
        data = tData,
        attr = tTag
      })
    end
  end

  if tResult==true then
    self.tTags = tTags
  end

  return tResult
end



function netFieldLabel:tobinary(fAddPadding)
  -- Get the contents of the label.
  local strLabelContents = self:__tags2binary(self.tTags)
  local sizLabelContents = string.len(strLabelContents)

  -- Build the CRC for the tags.
  local ulCrc32 = self:__build_contents_crc(strLabelContents)

  -- Build a header and footer.
  local tHeader = {
    abStartToken = 'netFIELDtag>',
    usLabelSize = self.sizNetFieldLabelHeader + sizLabelContents + self.sizNetFieldLabelFooter,
    usContentSize = sizLabelContents
  }
  local strHeader = self.tNetFieldLabelHeader:write(tHeader)
  local tFooter = {
    aucEndLabel = '<netFIELDtag',
    ulChecksum = ulCrc32
  }
  local strFooter = self.tNetFieldLabelFooter:write(tFooter)

  local strLabel = strHeader .. strLabelContents .. strFooter
  local strPadding = ''
  if fAddPadding==true then
    local sizLabel = string.len(strLabel)
    if sizLabel<self.sizStandardLabel then
      strPadding = string.rep(string.char(0xff), self.sizStandardLabel-sizLabel)
    end
  end

  return strLabel .. strPadding
end



function netFieldLabel:totable()
  local atTags = {}

  for _, tAttr in ipairs(self.tTags) do
    local tTag = {
      id = tAttr.attr.name,
      data = tAttr.data
    }
    table.insert(atTags, tTag)
  end

  return atTags
end



function netFieldLabel:__getTagAttributes(strTagId)
  local tTagHit

  for _, tTagAttributes in pairs(self.atTags) do
    if tTagAttributes.name==strTagId then
      tTagHit = tTagAttributes
      break
    end
  end

  return tTagHit
end



function netFieldLabel:__merge_tables(tPath, atMainTable, atPatchTable)
  local tLog = self.tLog

  -- Iterate over all elements of the patch table.
  for tPatchKey, tPatchValue in pairs(atPatchTable) do
    local strPatchKey
    if #tPath==0 then
      strPatchKey = tostring(tPatchKey)
    else
      strPatchKey = '.' .. tostring(tPatchKey)
    end
    -- Try string and number keys.
    if atMainTable[tPatchKey]==nil and tonumber(tPatchKey)~=nil and atMainTable[tonumber(tPatchKey)] then
      tPatchKey = tonumber(tPatchKey)
      strPatchKey = string.format('[%d]', tPatchKey)
    end
    -- The value must exist in the main table and the type must be the same.
    local tMainValue = atMainTable[tPatchKey]
    local strTypeMainValue = type(tMainValue)
    local strTypePatchValue = type(tPatchValue)
    local strElementPath = table.concat(tPath) .. strPatchKey
    if tMainValue==nil then
      tLog.error('The patch contains the non-existing element "%s".', strElementPath)
      error('Invalid patch.')
    elseif strTypeMainValue~=strTypePatchValue then
      tLog.error('The type of the patch value is %s, which differs from the type of the data value %s.', strTypePatchValue, strTypeMainValue)
      error('Invalid patch.')
    else
      -- Is the value a table?
      if strTypeMainValue=='table' then
        table.insert(tPath, strPatchKey)
        self:__merge_tables(tPath, tMainValue, tPatchValue)
        table.remove(tPath)
      else
        tLog.debug('Patching "%s" from %s to %s.', strElementPath, tostring(tMainValue), tostring(tPatchValue))
        atMainTable[tPatchKey] = tPatchValue
      end
    end
  end
end



function netFieldLabel:patchWithData(tPatchData)
  local tLog = self.tLog

  -- Iterate over all tags.
  for strTagCnt, tPatchTag in pairs(tPatchData) do
    local uiTagCnt = tonumber(strTagCnt)

    local strPatchTagId = tPatchTag.id
    local tPatchTagAttr = self:__getTagAttributes(strPatchTagId)
    if tPatchTagAttr==nil then
      tLog.error('Patching tag %d failed: Unknown type "%s".', uiTagCnt, strPatchTagId)
      error('Unknown tag name.')
    else
      local tTargetTag = self.tTags[uiTagCnt]
      -- Does this tag exist?
      if tTargetTag==nil then
        -- The tag does not exist. Create a new one.
        error('nono')

        -- Try to parse the tag data.
        self.pl.pretty.dump(tPatchTag.data)
        local strTestData, strError = tPatchTagAttr.tStruct:write(tPatchTag.data)
        if strTestData==nil then
          tLog.error('Failed to parse the data for patch tag %d: %s', uiTagCnt, strError)
          error('Failed to parse the patch data.')
        else
          table.insert(self.tTags, {
            id = tPatchTagAttr.id,
            data = tPatchTag.data,
            attr = tPatchTagAttr
          })
        end
      else
        -- The tag exists. The types must be the same.
        if tTargetTag.id~=tPatchTagAttr.id then
          tLog.error('Failed to apply patch %d: The patch expected tag ID "%s", but found tag ID "%s".', tTargetTag.name, tPatchTagAttr.name)
          error('Failed to apply patch: different tag types.')
        else
          -- Merge the data tables recursively.
          self:__merge_tables({}, tTargetTag.data, tPatchTag.data)
        end
      end
    end
  end
end



return netFieldLabel
