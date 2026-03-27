local colors = {
    {name = "Red",          hex = "#FF0000"},
    {name = "Green",        hex = "#00FF00"},
    {name = "Blue",         hex = "#0000FF"},
    {name = "White",        hex = "#FFFFFF"},
    {name = "Black",        hex = "#000000"},
    {name = "Yellow",       hex = "#FFFF00"},
    {name = "Cyan",         hex = "#00FFFF"},
    {name = "Magenta",      hex = "#FF00FF"},
    {name = "Orange",       hex = "#FFA500"},
    {name = "Pink",         hex = "#FFC0CB"},
    {name = "Purple",       hex = "#800080"},
    {name = "Lime",         hex = "#00FF00"},
    {name = "Aqua",         hex = "#00FFFF"},
    {name = "Fuchsia",      hex = "#FF00FF"},
    {name = "Silver",       hex = "#C0C0C0"},
    {name = "Gray",         hex = "#808080"},
    {name = "Maroon",       hex = "#800000"},
    {name = "Olive",        hex = "#808000"},
    {name = "Teal",         hex = "#008080"},
    {name = "Navy",         hex = "#000080"},
    {name = "Crimson",      hex = "#DC143C"},
    {name = "HotPink",      hex = "#FF69B4"},
    {name = "DeepPink",     hex = "#FF1493"},
    {name = "Salmon",       hex = "#FA8072"},
    {name = "Coral",        hex = "#FF7F50"},
    {name = "Tomato",       hex = "#FF6347"},
    {name = "Gold",         hex = "#FFD700"},
    {name = "Goldenrod",    hex = "#DAA520"},
    {name = "Violet",       hex = "#EE82EE"},
    {name = "Orchid",       hex = "#DA70D6"},
    {name = "Plum",         hex = "#DDA0DD"},
    {name = "Indigo",       hex = "#4B0082"},
    {name = "SlateBlue",    hex = "#6A5ACD"},
    {name = "RoyalBlue",    hex = "#4169E1"},
    {name = "DodgerBlue",   hex = "#1E90FF"},
    {name = "SkyBlue",      hex = "#87CEEB"},
    {name = "Turquoise",    hex = "#40E0D0"},
    {name = "SpringGreen",  hex = "#00FF7F"},
    {name = "SeaGreen",     hex = "#2E8B57"},
    {name = "ForestGreen",  hex = "#228B22"},
    {name = "Chartreuse",   hex = "#7FFF00"},
    {name = "LawnGreen",    hex = "#7CFC00"},
    {name = "DarkCyan",     hex = "#008B8B"},
    {name = "LightBlue",    hex = "#ADD8E6"},
    {name = "PowderBlue",   hex = "#B0E0E6"},
    {name = "CornflowerBlue",hex = "#6495ED"},
    {name = "MediumPurple", hex = "#9370DB"},
    {name = "RebeccaPurple",hex = "#663399"},
    {name = "DarkViolet",   hex = "#9400D3"},
    {name = "DarkOrchid",   hex = "#9932CC"},
    {name = "MediumOrchid", hex = "#BA55D3"},
    {name = "LightPink",    hex = "#FFB6C1"},
    {name = "PaleVioletRed",hex = "#DB7093"},
    {name = "MediumVioletRed",hex = "#C71585"},
    {name = "Firebrick",    hex = "#B22222"},
    {name = "DarkRed",      hex = "#8B0000"},
    {name = "IndianRed",    hex = "#CD5C5C"},
    {name = "LightCoral",   hex = "#F08080"},
    {name = "DarkSalmon",   hex = "#E9967A"},
    {name = "PeachPuff",    hex = "#FFDAB9"},
    {name = "Bisque",       hex = "#FFE4C4"},
    {name = "Moccasin",     hex = "#FFE4B5"},
    {name = "Wheat",        hex = "#F5DEB3"},
    {name = "Beige",        hex = "#F5F5DC"},
    {name = "Lavender",     hex = "#E6E6FA"},
    {name = "Thistle",      hex = "#D8BFD8"},
    {name = "MistyRose",    hex = "#FFE4E1"},
    {name = "LemonChiffon", hex = "#FFFACD"},
    {name = "LightGoldenrodYellow", hex = "#FAFAD2"},
    {name = "PapayaWhip",   hex = "#FFEFD5"},
}

local menuOptions = {}
for i, col in ipairs(colors) do
    menuOptions[i] = string.format("%-15s %s", col.name, "")
end

local lib = "libil2cpp.so"
local info = gg.getTargetInfo()
local title = info.label

local bases, index, status = {}, 0, 0
local ranges = gg.getRangesList(lib)
if #ranges == 0 then status = 2 goto SPLIT end

for _, r in ipairs(ranges) do
    if r.state == "Xa" then
        index = index + 1
        bases[index] = r.start
        status = 1
    end
end

::SPLIT::
if status == 2 then
    local found, sizes, count = false, {}, 0
    ranges = gg.getRangesList()
    for _, r in ipairs(ranges) do
        if r.state == "Xa" and r.name:match("split_config") then found = true end
    end
    if not found then print("No split lib."); gg.setVisible(true); os.exit() end
    for _, r in ipairs(ranges) do
        if r.state == "Xa" then
            count = count + 1
            sizes[count] = r["end"] - r.start
        end
    end
    if count > 0 then
        local max = math.max(table.unpack(sizes))
        for _, r in ipairs(ranges) do
            if r.state == "Xa" and (r["end"] - r.start) == max then
                index = index + 1
                bases[index] = r.start
                status = 1
            end
        end
    end
end

if status ~= 1 then print("Lib not found."); gg.setVisible(true); os.exit() end

local orig = {}

function reset(off)
    if orig[off] then
        gg.setValues(orig[off])
        gg.sleep(1000)
    else
        gg.alert("ERR")
    end
end

function setHex(offset, hex)
    local base = bases[index]
    if not orig[offset] then
        local backup, patch, total = {}, {}, 0
        for h in string.gmatch(hex, "%S%S") do
            local addr = base + offset + total
            table.insert(backup, {address = addr, flags = gg.TYPE_BYTE})
            table.insert(patch, {address = addr, flags = gg.TYPE_BYTE, value = h .. "r"})
            total = total + 1
        end
        orig[offset] = gg.getValues(backup)
        gg.setValues(patch)
    else
        local patch, total = {}, 0
        for h in string.gmatch(hex, "%S%S") do
            table.insert(patch, {address = base + offset + total, flags = gg.TYPE_BYTE, value = h .. "r"})
            total = total + 1
        end
        gg.setValues(patch)
    end
end

function setValue(offset, flags, value)
    local base = bases[index]
    local addr = base + offset
    if not orig[offset] then
        orig[offset] = gg.getValues({{address = addr, flags = flags}})
    end
    gg.setValues({{address = addr, flags = flags, value = value}})
end

local edit, end_hook, aaaa, a, b
local xg = {}

local edi, ed = "0x", "-0x"

function ISAOffset()
    local xHEX = string.format("%X", aaaa)
    if #xHEX > 8 then xHEX = xHEX:sub(#xHEX - 7) end
    edit = "~A8 B [PC,#" .. edi .. xHEX .. "]"
end

function ISAOffsetNeg()
    local xHEX = string.format("%X", b - a)
    if #xHEX > 8 then xHEX = xHEX:sub(#xHEX - 7) end
    edit = "~A8 B [PC,#" .. ed .. xHEX .. "]"
end

function gets(g)
    gg.loadResults(end_hook)
    xg[g] = gg.getResults(gg.getResultsCount())
    gg.clearResults()
end

function endhook(cc, g)
    local eh = {}
    eh[1] = {address = bases[index] + cc, flags = gg.TYPE_DWORD, value = xg[g][1].value, freeze = true}
    gg.addListItems(eh)
    gg.clearList()
end

function call_void(cc, ref, g)
    local p = {}
    p[1] = {address = bases[index] + cc, flags = gg.TYPE_DWORD}
    gg.addListItems(p)
    gg.loadResults(p)
    end_hook = gg.getResults(1)
    gets(g)
    a = bases[index] + ref
    b = bases[index] + cc
    aaaa = a - b
    if tonumber(aaaa) < 0 then ISAOffsetNeg() else ISAOffset() end
    p[1] = {address = bases[index] + cc, flags = gg.TYPE_DWORD, value = edit, freeze = true}
    gg.addListItems(p)
    gg.clearList()
	end

function getXaSegment()
    local segments = {}
    for _, range in ipairs(gg.getRangesList("libil2cpp.so")) do
        if range.state == "Xa" then table.insert(segments, range) end
    end
    return segments[1]
end

function getCdSegment()
    local segments = {}
    for _, range in ipairs(gg.getRangesList("libil2cpp.so")) do
        if range.state == "Cd" then table.insert(segments, range) end
    end
    return segments[2] or segments[1]
end

function gg.edits(addr, tbl, name)
    local t1, t2 = {}, {}
    for _, v in ipairs(tbl) do
        local val = {address=addr+v[3], value=v[1], flags=v[2], freeze=v[4]}
        if v[4] then t2[#t2+1]=val else t1[#t1+1]=val end
    end
    gg.addListItems(t2)
    gg.setValues(t1)
    gg.toast(name or "")
end

gg.clearResults()
gg.toast("Azeus Destroyer Diobaxy")

local gg = gg
local info = gg.getTargetInfo()
local pointerType = info.x64 == true and gg.TYPE_QWORD or gg.TYPE_DWORD
local pointerOffset = info.x64 == true and 24 or 12
local metadata = gg.getRangesList("libil2cpp.so")
local VOID = info.x64 == true and "h C0 03 5F D6" or "h 1E FF 2F E1"
local TRUE = info.x64 == true and "h 20 00 80 D2 C0 03 5F D6" or "h 01 00 A0 E3 1E FF 2F E1"
local FALSE = info.x64 == true and "h 00 00 80 D2 C0 03 5F D6" or "h 00 00 A0 E3 1E FF 2F E1"
local SAVE = info.x64 == true and "h C0 03 5F D6 EF 3B 09 6D ED 33 0A 6D EB 2B 0B 6D E9 23 0C 6D FC 6B 00 F9 F7 5B 0E A9 F5 53 0F A9 F3 7B 10 A9 B6 53 01 90 C8 52 61 39"
local INF = info.x64 == true and "h FA 04 44 E3 1E FF 2F E1"
local PLAY = info.x64 == true and "h 37 00 A0 E3 1E FF 2F E1"
local INT = info.x64 == true and "FA 04 44 E3 1E FF 2F E1"
local GetUnityMethod = function(method, flag)
  local results = {}
  gg.clearResults()
  gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER | gg.REGION_C_HEAP)
  gg.searchNumber(":" .. method, gg.TYPE_BYTE, false, gg.SIGH_EQUAL, metadata[1].start, metadata[#metadata]["end"], 0)
  local count = gg.getResultsCount()
  if count ~= 0 then
    gg.refineNumber(tonumber(gg.getResults(1)[1].value) .. "", gg.TYPE_BYTE)
    local t = gg.getResults(count)
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS)
    gg.loadResults(t)
    gg.searchPointer(0)
    t = gg.getResults(count)
    do
      do
        for SRD1_8_, SRD1_9_ in ipairs(t) do
          SRD1_9_.address = SRD1_9_.address - pointerOffset
          SRD1_9_.flags = pointerType
        end
      end
    end
    t = gg.getValues(t)
    do
      do
        for SRD1_8_, SRD1_9_ in ipairs(t) do
          table.insert(results, {
            address = SRD1_9_.value,
            flags = flag
          })
        end
      end
    end
    gg.loadResults(results)
  end
end

local GetUnityClass = function(className, offset, flag)
  local results = {}
  gg.clearResults()
  gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_OTHER | gg.REGION_C_HEAP)
  gg.searchNumber(":" .. className, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, metadata[1].start, metadata[#metadata]["end"], 0)
  local count = gg.getResultsCount()
  if count ~= 0 then
    gg.refineNumber(tonumber(gg.getResults(1)[1].value) .. "", gg.TYPE_BYTE)
    local t = gg.getResults(count)
    gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS)
    gg.loadResults(t)
    gg.searchPointer(0)
    t = gg.getResults(count)
    do
      do
        for _FORV_9_, _FORV_10_ in ipairs(t) do
          _FORV_10_.address = _FORV_10_.address - pointerOffset
          _FORV_10_.flags = pointerType
        end
      end
    end
    t = gg.getValues(t)
    do
      do
        for _FORV_9_, _FORV_10_ in ipairs(t) do
          table.insert(results, {
            address = _FORV_10_.value + offset,
            flags = flag
          })
        end
      end
    end
    gg.loadResults(results)
    end
end

v = gg.getTargetInfo()
L = v and v.label
V = v and v.versionName
function isProcess64Bit()
    local regions = gg.getRangesList()
    local lastAddress = regions[#regions]["end"]
    return (lastAddress >> 32) ~= 0
end
local ISA = isProcess64Bit()
function ISAOffsets()
    if (ISA == false) then
        edi = "+0x"
        ed = "-0x"
    elseif (ISA == true) then
        edi = "0x"
        ed = "-0x"
    end
end
ISAOffsets()
function ISAOffsetss()
    if (ISA == false) then
        edit = "~A B " .. edits
    elseif (ISA == true) then
        edit = "~A8 B\t [PC,#" .. edits .. "]"
    end
end
liby = 1
libf = 0
libzz = "libil2cpp.so"
libx = gg.getRangesList("libil2cpp.so")
for i, v in ipairs(libx) do
    if (libx[i].state == "Xa") then
        libz = "libil2cpp.so[" .. liby .. "].start"
        xand = gg.getRangesList("libil2cpp.so")[liby].start
        libf = 1
        break
    end
    liby = liby + 1
end
if (libf == 0) then
    liby = 1
    libzz = "libUE4.so"
    libx = gg.getRangesList("libUE4.so")
    for i, v in ipairs(libx) do
        if (libx[i].state == "Xa") then
            libz = "libUE4.so[" .. liby .. "].start"
            xand = gg.getRangesList("libUE4.so")[liby].start
            libf = 1
            break
        end
        liby = liby + 1
    end
end
lib = xand
local sf = string.format
function tohex(Data)
    if (type(Data) == "number") then
        return sf("0x%08X", Data)
    end
    return Data:gsub(".", function(a)
        return string.format("%02X", (string.byte(a)))
    end):gsub(" ", "")
end
function __()
    xHEX = string.format("%X", aaaa)
    if (#xHEX > 8) then
        act = (#xHEX - 8) + 1
        xHEX = string.sub(xHEX, act)
    end
    edits = edi .. xHEX
    ISAOffsetss()
end
function _()
    aaa = b - a
    xHEX = string.format("%X", aaa)
    if (#xHEX > 8) then
        act = (#xHEX - 8) + 1
        xHEX = string.sub(xHEX, act)
    end
    edits = ed .. xHEX
    ISAOffsetss()
end
function hook_void(cc, bb)
    LibStart = lib
    local m = {}
    m[1] = {address=(LibStart + bb),flags=gg.TYPE_DWORD}
    gg.addListItems(m)
    a = m[1].address
    gg.clearList()
    local p = {}
    p[1] = {address=(LibStart + cc),flags=gg.TYPE_DWORD}
    gg.addListItems(p)
    gg.loadResults(p)
    endhook = gg.getResults(1)
    local n = {}
    n[1] = {address=(LibStart + cc),flags=gg.TYPE_DWORD}
    gg.addListItems(n)
    b = n[1].address
    gg.clearResults()
    gg.clearList()
    aaaa = a - b
    if (tonumber(aaaa) < 0) then
        _()
    end
    if (tonumber(aaaa) > 0) then
        __()
    end
    local n = {}
    n[1] = {address=(LibStart + cc),flags=gg.TYPE_DWORD,value=edit,freeze=true}
    gg.addListItems(n)
    gg.clearList()
end


function editString(oldName, newName)
    local stringTag = ';'
    local addressJump = 2
    
    gg.setVisible(false)
    
    if not _G.GG then _G.GG = {} end
    if not _G.GG.stringBackups then _G.GG.stringBackups = {} end
    
    gg.searchNumber(stringTag..oldName)
    local results = gg.getResults(gg.getResultsCount())
    
    if #results == 0 then
        gg.clearResults()
        local searchPattern = table.concat({string.byte(oldName, 1, -1)}, ';')
        gg.searchNumber(searchPattern, gg.TYPE_WORD)
        results = gg.getResults(gg.getResultsCount())
        
        if #results == 0 then
            return false
        end
    end

    local filteredResults = {}
    for i = 1, #results do
        if i <= #results - #oldName + 1 then
            local match = true
            for j = 0, #oldName - 1 do
                local charCode = string.byte(oldName, j + 1)
                if results[i + j].value ~= charCode then
                    match = false
                    break
                end
            end
            if match then
                filteredResults[#filteredResults + 1] = results[i]
            end
        end
    end

    if #filteredResults == 0 then
        return false
    end

    local replaceString = {}
    local stringSize = {}
    
    for i = 1, #filteredResults do
        stringSize[#stringSize + 1] = {address = filteredResults[i].address - 0x4, flags = gg.TYPE_WORD}
    end
    stringSize = gg.getValues(stringSize)
    
    for i = 1, #filteredResults do
        if stringSize[i].value >= #oldName then
            local originalSize = stringSize[i].value
            local originalChars = {}
            
            for j = 1, originalSize do
                local charAddr = filteredResults[i].address + ((j-1) * addressJump)
                local charValue = gg.getValues({{address = charAddr, flags = gg.TYPE_WORD}})[1].value
                table.insert(originalChars, {
                    address = charAddr,
                    value = charValue
                })
            end
            
            table.insert(_G.GG.stringBackups, {
                baseAddress = filteredResults[i].address,
                oldName = oldName,
                newName = newName,
                originalSize = originalSize,
                originalChars = originalChars,
                sizeAddress = filteredResults[i].address - 0x4
            })
            
            gg.setValues({{address = filteredResults[i].address - 0x4, flags = gg.TYPE_WORD, value = #newName}})
            
            for j = 1, #newName do
                local charValue = string.byte(string.sub(newName, j, j))
                replaceString[#replaceString + 1] = {
                    address = filteredResults[i].address + ((j-1) * addressJump), 
                    flags = gg.TYPE_WORD, 
                    value = charValue
                }
            end
            
            for j = #newName + 1, stringSize[i].value do
                replaceString[#replaceString + 1] = {
                    address = filteredResults[i].address + ((j-1) * addressJump), 
                    flags = gg.TYPE_WORD, 
                    value = 0
                }
            end
        end
    end
    
    if #replaceString > 0 then
        gg.setValues(replaceString)
        return true
    end
    
    return false
end

function endString(oldName, newName)
    if not _G.GG or not _G.GG.stringBackups or #_G.GG.stringBackups == 0 then
        return false
    end
    
    local foundBackup = false
    
    for i = #_G.GG.stringBackups, 1, -1 do
        local backup = _G.GG.stringBackups[i]
        if backup.oldName == oldName and backup.newName == newName then
            foundBackup = true
            
            gg.setValues({{
                address = backup.sizeAddress,
                flags = gg.TYPE_WORD,
                value = backup.originalSize
            }})
            
            local restoreData = {}
            for j, charData in ipairs(backup.originalChars) do
                table.insert(restoreData, {
                    address = charData.address,
                    flags = gg.TYPE_WORD,
                    value = charData.value
                })
            end
            
            gg.setValues(restoreData)
            
            table.remove(_G.GG.stringBackups, i)
            break
        end
    end
    
    if not foundBackup then
        return false
    end
    
    return true
end



_G.OffsetBackups = _G.OffsetBackups or {}

function editOffset(baseOffset, patchValues, backupKey)
    if not _G.OffsetBackups[backupKey] then
        _G.OffsetBackups[backupKey] = {}
    end
    
    local base = gg.getRangesList('libil2cpp.so')[3].start
    local mainAddress = base + baseOffset
    
    local originalValues = {}
    for i, patch in ipairs(patchValues) do
        local address = mainAddress + patch.offset
        local original = gg.getValues({{address = address, flags = patch.flags}})[1]
        table.insert(originalValues, {
            address = address,
            flags = patch.flags,
            value = original.value
        })
    end
    
    _G.OffsetBackups[backupKey].original = originalValues
    
    local patchData = {}
    for i, patch in ipairs(patchValues) do
        table.insert(patchData, {
            address = mainAddress + patch.offset,
            flags = patch.flags,
            value = patch.value
        })
    end
    
    gg.setValues(patchData)
    return true
end

function endOffset(backupKey)
    if not _G.OffsetBackups[backupKey] or not _G.OffsetBackups[backupKey].original then
        return false
    end
    
    local originalValues = _G.OffsetBackups[backupKey].original
    gg.setValues(originalValues)
    _G.OffsetBackups[backupKey] = nil
    return true
end

if gg.isVisible(true) then
  gg.setVisible(false)
end

Azeus = 1


function home()
Azeus = 0
home1 = gg.choice({
 '⛨ Run Script', 
 '⛨ About the creator'}, nil,'Home')
 if home1 == 1 then
 password()
 end
 if home1 == 2 then
 info()
 end
 if home1 == nil then else end
 end
 
 function info()
 info = gg.multiChoice({
 "My YouTube",
 "My Telegram channel"}, nil,' Я сделал этот скрипт ради забавы, я не призываю вас жульничать/модифицировать игры pigs\nI madd this script for fun i dont encourage you to cheat/modify games pigs') 
 if info == nil then return gg.toast("Menu Cancelled") end
 if info[1] == true then
 yt()
 end
 if info[2] == true then
 tg()
 end
 end
 
 function yt()
 gg.copyText("@diocheats")
 end
 
 function tg()
 gg.copyText("t.me/ArceusOnTop")
 end
function password()
gg.alert("🔐 Скрипт защищен паролем\n У тебя всего 3 желания", "Continue")

local pw = "1 120 403 456"       
local attempts = 3

for i = 1, attempts do
    local input = gg.prompt(
        {"Введите мой пароль (attempt "..i.."/"..attempts..")"},
        {""}, {"text"}
    )
    
    if not input then os.exit() end
    
    if input[1] == pw then
while true do
if gg.isVisible(true) then
azeus = 1
gg.setVisible(false)
end
if azeus == 1 then menu() end
end
  
    break
    else
        gg.alert(" Неверно... \n"..(attempts-i).." осталось попыток")
        gg.sleep(800)
    end
    
    if i == attempts then
        gg.alert("Initiating Self destruct mode")
        os.exit()
    end
end
end

 off = ": off"
 on = ": on"

AzeusS = off
AzeusS1 = off
AzeusS2 = off
AzeusS3 = off
AzeusS4 = off
AzeusS5 = off
AzeusS6 = off
AzeusS7 = off
AzeusS8 = off
AzeusS9 = off
AzeusS10 = off
AzeusS11 = off
AzeusS12 = off
AzeusS13 = off
AzeusS14 = off
AzeusS15 = off
AzeusS16 = off
AzeusS17 = off
AzeusS18 = off
AzeusS19 = off
AzeusS20 = off
AzeusS21 = off
AzeusS22 = off
AzeusS23 = off
AzeusS24 = off
AzeusS25 = off
AzeusS26 = off
AzeusS27 = off
AzeusS28 = off
AzeusS29 = off
AzeusS30 = off
AzeusS31 = off
AzeusS32 = off
AzeusS33 = off
AzeusS34 = off
AzeusS35 = off
AzeusS36 = off
AzeusS37 = off
AzeusS38 = off
AzeusS39 = off
AzeusS40 = off
AzeusS41 = off
AzeusS42 = off
AzeusS43 = off
AzeusS44 = off
AzeusS45 = off
AzeusS46 = off
AzeusS47 = off
AzeusS48 = off
AzeusS49 = off
AzeusS50 = off
AzeusS51 = off
AzeusS52 = off
AzeusS53 = off
AzeusS54 = off
AzeusS55 = off
AzeusS56 = off
AzeusS57 = off
AzeusS58 = off
AzeusS59 = off
AzeusS60 = off
AzeusS61 = off
AzeusS62 = off
AzeusS63 = off
AzeusS64 = off
AzeusS65 = off
AzeusS66 = off
AzeusS67 = off
AzeusS68 = off
AzeusS69 = off
AzeusS70 = off
AzeusS71 = off
AzeusS72 = off
AzeusS73 = off
AzeusS74 = off
AzeusS75 = off
AzeusS76 = off
AzeusS77 = off
AzeusS78 = off
AzeusS79 = off
AzeusS80 = off
AzeusS81 = off
AzeusS82 = off
AzeusS83 = off
AzeusS84 = off
AzeusS85 = off
AzeusS86 = off
AzeusS87 = off
AzeusS88 = off
AzeusS89 = off
AzeusS90 = off
AzeusS91 = off
SSDI26 = off
SSDI77 = off
SSDI97 = off
SSDI98 = off
SSDI99 = off
alpha = off
beta = off
phi = off
Diofex1 = off
Diofex2 = off
Diofex3 = off
pogger = off

azeus = 1

 function menu()
 azeus = 0
choice1 = gg.multiChoice({
 'Option : Account', 
 'Option : Server', 
 'Option : Visual', 
 'Option : Player', 
 'Option : Vehicle', 
 'Option : Weapon', 
 'Option : Exclusive', 
 'Option : New',
 'Option : Colors',
 'Function : Exit'},nil,'Azeus Destroyer v2\nXon Client version\nSelect Option :') 
 if choice1 == nil then return gg.toast("Menu Cancelled") end
 if choice1[1] == true then
 accfunc() 
 end
 if choice1[2] == true then
 servfunc() 
 end
 if choice1[3] == true then
 visualfunc() 
 end
 if choice1[4] == true then
 playerfunc() 
 end
 if choice1[5] == true then
 vehicfunc() 
 end
 if choice1[6] == true then
 weaponfunc() 
 end
 if choice1[7] == true then
 excluvfunc() 
 end
 if choice1[8] == true then
 secretf()
 end
 if choice1[9] == true then
 colorf()
 end
 if choice1[10] == true then
 os.exit()
 end
 end

function colorf()
    local selected = gg.multiChoice(menuOptions, nil, "Select color(s)")

    if selected == nil then
        gg.toast("Menu cancelled")
        return
    end

    local anyActivated = false

    for index, isChecked in pairs(selected) do
        if isChecked then
            local col = colors[index]
            gg.copyText(col.hex)
            gg.toast(col.name .. " activated")
            anyActivated = true
        end
    end

    if not anyActivated then
        gg.toast("No color selected")
    end
end

function accfunc()
choice2 = gg.multiChoice({
"Correct Symbol",
"Get Custom Skin"},nil,'Account')
if choice2 == nil then return gg.toast("Menu Cancelled") end
if choice2[1] == true then symbol() end
if choice2[2] == true then sckin() end
end

function symbol()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("257698037761Q;60D:20", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000, nil, nil, nil, "60", "60", nil, nil, nil)
gg.editAll("0", gg.TYPE_DWORD)
gg.clearResults()
gg.toast("Activated ") 
end
            
function sckin()
gg.alert("Оснастить hero")
  skin = gg.prompt({
    "Старая кожа",
    "Новая кожа"
  }, {"Hero", nil}, {"text", "text"})
  if skin == nil then
    gg.alert("Вы ничего не выбрали..")
  else
        gg.setVisible(false)
        if editString(skin[1],skin[2]) then
            gg.clearResults()
            gg.toast("Activated") 
end
end
end
                

function servfunc()
  choice3 = gg.multiChoice({
    "SpaceShip",
    "Remove gay passwords",
    "Enable Spawn Object" ..AzeusS,
    "Free Mode" ..AzeusS1,
    "Fly And Noclip",
    "Antikick" ..AzeusS2, 
    "Antikick V2", 
  }, nil, "Server")
  if choice3 == nil then return gg.toast("Menu Cancelled") end
  if choice3[1] == true then space() end
  if choice3[2] == true then nopass() end
  if choice3[3] == true then spawnobject() end
  if choice3[4] == true then nopriv() end
  if choice3[5] == true then flynoclip() end
  if choice3[6] == true then antikick() end
  if choice3[7] == true then antikickv2() end
end

  
function space()
gg.searchNumber(";bouncy_ball", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(";SpaceShip", gg.TYPE_WORD)
gg.clearResults()
gg.toast("Activated")
end

function nopass()
  gg.clearResults()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber(";Password", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll(";", gg.TYPE_WORD)
  gg.clearResults()
  gg.toast("Activated")
end

function spawnobject()
if AzeusS == off then
      AzeusS = on
gg.searchNumber(";DisableSpawnObject", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(";subscribetodiofex", gg.TYPE_WORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS == on then
      AzeusS = off
	  gg.searchNumber(";subscribetodiofex", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(";DisablespawnObject", gg.TYPE_WORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function nopriv()
 if AzeusS1 == off then
 AzeusS1 = on
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.clearResults()
  gg.searchNumber(";GameMode", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll(";AaAaAaAa", gg.TYPE_WORD)
  gg.clearResults()
  gg.toast("Activated")
  else if AzeusS1 == on then
  AzeusS1 = off
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.clearResults()
  gg.searchNumber(";AaAaAaAa", gg.TYPE_WORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll(";GameMode", gg.TYPE_WORD)
  gg.clearResults()
  gg.toast("Deactivated")
end
end
end

function flynoclip()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.processPause()
gg.clearResults()
gg.searchNumber("281 479 271 678 208", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("16 777 472", gg.TYPE_QWORD)

gg.clearResults()
gg.searchNumber("3 239 900 611", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0", gg.TYPE_QWORD)
gg.processResume() 
gg.freeze = true
gg.toast("Activated")
gg.setRanges(gg.REGION_ANONYMOUS)
gg.processPause()
gg.clearResults()
gg.searchNumber("281 479 271 678 208", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("16 777 472", gg.TYPE_QWORD)
gg.clearResults()
gg.searchNumber("3 239 900 611", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0", gg.TYPE_QWORD)
gg.freeze = true
gg.clearResults()
gg.searchNumber("-10", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("999", gg.TYPE_FLOAT)
gg.processResume() 
gg.clearResults()
gg.searchNumber("0.2", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(200000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("100009", gg.TYPE_FLOAT)
gg.processResume() 
gg.clearResults()
gg.searchNumber("0.2", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(200000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("100009", gg.TYPE_FLOAT)
gg.processResume() 
gg.clearResults()
gg.toast("Activated")
end

function antikick()
 if AzeusS2 == off then
 AzeusS2 = on
  gg.setRanges(gg.REGION_CODE_APP)
  gg.searchNumber("h 25 E1 AD 97 FF 03 01 D1 FE 57 02 A9 F4 4F 03 A9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(99999, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("h C0 03 5F D6 C0 03 5F D6 C0 03 5F D6 C0 03 5F D6", gg.TYPE_BYTE)
  gg.processResume()
  gg.clearResults()
  else if AzeusS2 == on then
  AzeusS2 = off
    gg.setRanges(gg.REGION_CODE_APP)
  gg.searchNumber("h C0 03 5F D6 C0 03 5F D6 C0 03 5F D6 C0 03 5F D6", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(99999, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("h 25 E1 AD 97 FF 03 01 D1 FE 57 02 A9 F4 4F 03 A9", gg.TYPE_BYTE)
  gg.processResume()
  gg.clearResults()
end
end
end

function antikickv2() 
GetUnityMethod("LeaveRoom", 4)
gg.getResults(gg.getResultsCount())
gg.editAll(VOID, 4)
gg.toast("Activated")
gg.clearResults()
end


function visualfunc()
filsst4 = gg.multiChoice({
    "Rainbow Chams (V1)" ..AzeusS3,
    "Rainbow Chams (V2)",
    "Red Chams" ..AzeusS5,
    "Green Chams" ..AzeusS6,
    "Blue Chams" ..AzeusS7,
    "Neon Blue Chams" ..AzeusS8,
    "Neon Green Chams" ..AzeusS9,
    "Grend and Violet Chams" ..AzeusS10,
    "Neon Green and Neon Violet Chams" ..AzeusS11,
    "Green and Violet Chams (V2)" ..AzeusS12,
    "A Bit Blue Chams" ..AzeusS13,
    "Underwater chams" ..AzeusS91,
    "Camera ", 
}, nil, "Visual")

if filsst4 == nil then return gg.toast("Menu Cancelled") end
    if filsst4[1] == true then RainbowChamsV1() end
    if filsst4[2] == true then RainbowChamsV2() end
    if filsst4[3] == true then RedChams() end
    if filsst4[4] == true then GrendChams() end
    if filsst4[5] == true then BlueChams() end
    if filsst4[6] == true then BlueNeon() end
    if filsst4[7] == true then GrendNeon() end
    if filsst4[8] == true then GrendViolet() end
    if filsst4[9] == true then GrendVioletNeon() end
    if filsst4[10] == true then GrendVioletFast() end
    if filsst4[11] == true then PartiallyBlue() end
    if filsst4[12] == true then under() end
    if filsst4[13] == true then Camera() end
end

function under()
if AzeusS13 == off then
      AzeusS3 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741929", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS3 == on then
      AzeusS3 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741929", gg.TYPE_DWORD)
gg.refineNumber("1073741929", gg.TYPE_DWORD)
gg.refineNumber("1073741929", gg.TYPE_DWORD)
gg.refineNumber("1073741929", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741895", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function PartiallyBlue()
if AzeusS13 == off then
      AzeusS3 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741897", gg.TYPE_DWORD)
gg.refineNumber("1073741897", gg.TYPE_DWORD)
gg.refineNumber("1073741897", gg.TYPE_DWORD)
gg.refineNumber("1073741897", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741899", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS3 == on then
      AzeusS3 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741897", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end



function GrendVioletFast()
if AzeusS12 == off then
      AzeusS12 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741903', gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS49 == on then
      AzeusS49 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741893', gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end



function GrendVioletNeon()
if AzeusS11 == off then
      AzeusS11 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741903", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS11 == on then
      AzeusS11 = off
	 gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.refineNumber("1073741903", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741896", gg.TYPE_DWORD)
gg.clearResults() 
      gg.toast("Deactivated")
      end
end
end



function GrendViolet()
if AzeusS10 == off then
      AzeusS10 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741902", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS10 == on then
      AzeusS10 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741902", gg.TYPE_DWORD)
gg.refineNumber("1073741902", gg.TYPE_DWORD)
gg.refineNumber("1073741902", gg.TYPE_DWORD)
gg.refineNumber("1073741902", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741893" , gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end


function GrendNeon()
if AzeusS9 == off then
      AzeusS9 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.refineNumber("1073741896", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741899", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS9 == on then
      AzeusS9 = off
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.refineNumber("1073741899", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741896", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end


function BlueNeon()
if AzeusS8 == off then
      AzeusS8 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1 073 741 862", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS8 == on then
      AzeusS8 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1 073 741 862", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1 073 741 862", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1 073 741 862", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1 073 741 862", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1 073 741 862", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1073741898", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end


function BlueChams()
if AzeusS7 == off then
      AzeusS7 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.refineNumber("1073741894", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741900", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS7 == on then
      AzeusS7 = off
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741894", gg.TYPE_DWORD)
gg.clearResults()  
      gg.toast("Deactivated")
      end
end
end

function GrendChams()
if AzeusS6 == off then
      AzeusS6 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.refineNumber("1073741893", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741904', gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS6 == on then
      AzeusS6 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741904", gg.TYPE_DWORD)
gg.refineNumber("1073741904", gg.TYPE_DWORD)
gg.refineNumber("1073741904", gg.TYPE_DWORD)
gg.refineNumber("1073741904", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll('1073741893', gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end


function RedChams()
if AzeusS5 == off then
      AzeusS5 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.refineNumber("1073741895", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741900", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS5 == on then
      AzeusS5 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.refineNumber("1073741900", gg.TYPE_DWORD)
gg.getResults(5000)
gg.editAll("1073741895", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function RainbowChamsV2()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1073741903", gg.TYPE_DWORD)
gg.clearResults()
gg.toast("Activated")
end

function RainbowChamsV1()
if AzeusS3 == off then
      AzeusS3 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741898", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1073741901", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS3 == on then
      AzeusS3 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1073741901", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1073741901", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1073741898", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function Camera() 
choice4 = gg.multiChoice({
"Tall Camera position" ..AzeusS13,
"Short Camera Position" ..AzeusS14,
"Floor Camera Position" ..AzeusS15,
"Drunk Jump" ..AzeusS16,
"Sky Jump (Player must be in the sky)" ..AzeusS17,
"Wall Glitch Camera" ..AzeusS18,
"Set Fov", 
})
if choice4 == nil then return gg.toast("Menu Cancelled") 
end
if choice4[1] == true then gg500() end
if choice4[2] == true then gg700() end
if choice4[3] == true then gg900() end
if choice4[4] == true then gg1200() end
if choice4[5] == true then gg1400() end
if choice4[6] == true then gg1600() end
if choice4[7] == true then fovset() end
end

function gg500() 
if AzeusS13 == off then
AzeusS13 = on
gg.searchNumber("0.72000002861", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "1"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
else if AzeusS13 == on then
AzeusS13 = off
gg.searchNumber("1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.72000002861"
		v.freeze = false
	end
end
gg.addListItems(t)
t = nil
end
end
end

function gg700() 
if AzeusS14 == off then
AzeusS14 = on
gg.searchNumber("0.72000002861", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.2"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
else if AzeusS14 == on then
AzeusS14 = off
gg.searchNumber("0.2", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.72000002861"
		v.freeze = false
	end
end
gg.addListItems(t)
t = nil
end
end
end

function gg900() 
if AzeusS15 == off then
AzeusS15 = on
gg.searchNumber("0.72000002861", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "-5"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
else if AzeusS15 == on then
AzeusS15 = off
gg.searchNumber("-5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.72000002861"
		v.freeze = false
	end
end
gg.addListItems(t)
t = nil
end
end
end

function gg1200() 
if AzeusS16 == off then
AzeusS16 = on
gg.copyText("0.72000002861")
gg.toast("sosi hui")
gg.clearResults()
gg.searchNumber("0.72000002861", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000)
while true do
    gg.setValues(revert)
    gg.editAll("1", gg.TYPE_FLOAT)
    gg.sleep(1)
    gg.setValues(revert)
    gg.editAll("2", gg.TYPE_FLOAT)
    gg.sleep(1)
    end
    else if AzeusS16 == on then
    AzeusS16 = off
gg.toast("not yet chump") 
end
end
end

function gg1400() 
if AzeusS17 == off then
Azeuss17 = on
gg.searchNumber("0.72000002861", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "460"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
else if AzeusS17 == on then
AzeusS17 = off
gg.searchNumber("460", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.72000002861"
		v.freeze = false
	end
end
gg.addListItems(t)
t = nil
end
end
end

function gg1600() 
if AzeusS18 == off then
Azeuss18 = on
gg.searchNumber("0.56999999285", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "-2"
		v.freeze = true
	end
end
gg.addListItems(t)
t = nil
else if AzeusS18 == on then
AzeusS18 = off
gg.searchNumber("-2", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
local t = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
for i, v in ipairs(t) do
	if v.flags == gg.TYPE_FLOAT then
		v.value = "0.56999999285"
		v.freeze = false
	end
end
gg.addListItems(t)
t = nil
end
end
end

function fovset() 
  fov = gg.prompt({
    "Ваш Fov (не двигайтесь) ",
    "Установите поле зрения"
  }, {"60", nil}, {"number", "number"})
  if fov == nil then
    gg.alert("Вы ничего не выбрали..")
  else
  gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber(fov[1], gg.TYPE_FLOAT)
    gg.getResults(100000)
    gg.editAll(fov[2], gg.TYPE_FLOAT)
    gg.toast("👓FOV Activated")
    gg.clearResults()
  end
end

function playerfunc() 
playfunc = gg.multiChoice({
"SpeedHack", 
"JumpHack", 
"GravityHack", 
"GodMode", 
"Infinite Emotes" ..AzeusS22,
"Invisibility" ..Diofex1
}) 
if playfunc == nil then return gg.toast("Menu Cancelled")
end 
if playfunc[1] == true then 
spedhack() 
end
if playfunc[2] == true then 
jumphack() 
end
if playfunc[3] == true then 
gravyhack() 
end
if playfunc[4] == true then 
godmodc() 
end
if playfunc[5] == true then 
infinitemote()
end
if playfunc[6] == true then
invisibility()
end
end

function invisibility()
if Diofex1 == off then
Diofex1 = on
setValue(23435196, 4, "~A8 RET")
else if Diofex1 == on then
Diofex1 = off
reset(23435196)
end
end
end

function spedhack() 
filst9 = gg.multiChoice({
    "Off SPEED",
    "X2 SPEED",
    "X3 SPEED",
    "X4 SPEED",
    "Walk Speed" ..AzeusS19,
  }, nil, "Player ⧽ Speedhack")
  if filst9 == nil then return gg.toast("Menu Cancelled") 
  end
    if filst9[1] == true then
      speedoff2()
    end
    if filst9[2] == true then
      speed22()
    end
    if filst9[3] == true then
      speed32()
    end
    if filst9[4] == true then
      spedd42()
    end
    if filst9[5] == true then
      runmode2()
    end
  end

function gravyhack() 
 gravity = gg.prompt({
    "Set the gravity you want]"
      }, {nil}, {'number'})
  if gravity == nil then
    gg.alert("Вы ничего не выбрали..")
  else
  gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber(-9.81000041962, gg.TYPE_FLOAT)
    gg.getResults(100000)
    gg.editAll(gravity[1], gg.TYPE_FLOAT)
    gg.toast("Activated")
    gg.clearResults()
  end
end

function runmode2() 
AzeusS19 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("999888", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(200000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1.1", gg.TYPE_FLOAT)
gg.clearResults()
gg.searchNumber("6;5;-9.81;1.1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("6", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(200000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("85.505", gg.TYPE_FLOAT) 
gg.clearResults()
gg.searchNumber("1;1.1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(2000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("9999999999", gg.TYPE_FLOAT)
gg.clearResults()
end

function spedd42()
  gg.clearResults()
  gg.searchNumber("4 515 609 228 873 826 304", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 892 700 672", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 882 214 912", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 892 700 672", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 886 409 216", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 892 700 672", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 890 603 520", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 892 700 672", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 892 700 672", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 892 700 672", gg.TYPE_QWORD)
  gg.processResume()
end

function speed32()
  gg.clearResults()
  gg.searchNumber("4 515 609 228 873 826 304", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 890 603 520", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 882 214 912", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 890 603 520", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 886 409 216", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 890 603 520", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 890 603 520", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 890 603 520", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 892 700 672", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 890 603 520", gg.TYPE_QWORD)
  gg.processResume()
end

function speed22()
  gg.clearResults()
  gg.searchNumber("4 515 609 228 873 826 304", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 886 409 216", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 882 214 912", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 886 409 216", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 886 409 216", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 886 409 216", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 890 603 520", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 886 409 216", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 892 700 672", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 886 409 216", gg.TYPE_QWORD)
  gg.processResume()
end

function speedoff2()
  gg.clearResults()
  gg.searchNumber("4 515 609 228 873 826 304", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(5000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 873 826 304", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 882 214 912", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(4000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 873 826 304", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 886 409 216", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 873 826 304", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 890 603 520", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 873 826 304", gg.TYPE_QWORD)
  gg.clearResults()
  gg.searchNumber("4 515 609 228 892 700 672", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(20000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("4 515 609 228 873 826 304", gg.TYPE_QWORD)
  gg.processResume()
end

function jumphack() 
  choice5 = gg.multiChoice({
    "Low Jump Height",
    "Jump Height 120",
    "Infinite Jump", 
    "Set Jump Height",
  }, nil, "Player ⧽ JumpHack")
    if choice5 == nil then return gg.toast("Menu Cancelled") 
  end
  if choice5[1] == true then
    jumplow()
  end
  if choice5[2] == true then
    jumppower()
  end
  if choice5[3] == true then
    jumphck()
  end
  if choice5[4] == true then
  setjump()
  end
end

function jumplow()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("40", gg.TYPE_FLOAT)
  gg.getResults(500000)
  gg.editAll("20", gg.TYPE_FLOAT)
  gg.clearResults()
  gg.toast("Activated")
end

function jumppower()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("40", gg.TYPE_FLOAT)
  gg.getResults(500000)
  gg.editAll("120", gg.TYPE_FLOAT)
  gg.clearResults()
  gg.toast("Activated")
end

function jumphck()
  gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("1.1", gg.TYPE_FLOAT)
  gg.getResults(100)
  gg.editAll("1000", gg.TYPE_FLOAT)
  gg.clearResults()
  gg.toast("Activated")
end

function setjump()
jun = gg.prompt({
    "Jump Power [1;1000000]",
  }, {nil}, {"number"})
  if jun == nil then
    gg.alert("Вы ничего не выбрали..")
  else
        gg.setVisible(false)
           gg.setRanges(gg.REGION_ANONYMOUS)
  gg.searchNumber("40", gg.TYPE_FLOAT)
  gg.getResults(500000)
  gg.editAll(jun[1], gg.TYPE_FLOAT)
  gg.clearResults()
  gg.toast("Activated")
end
end

function godmodc()
  god = gg.multiChoice({
    "GodMode (V1) broken" ..AzeusS20,
    "NanHp" ..AzeusS21,
    "Rocket Jump",
    "God Mode (V2)",
    "God Mode (V3)", 
  }, nil, "Player ⧽ GodMode")
  if god == nil then return gg.toast("Menu Cancelled") 
 end
  if god[1] == true then
    GodMode()
  end
  if god[2] == true then
    GodModev()
  end
  if god[3] == true then
  GodModerpg()
  end
  if god[4] == true then
  GodModeV2()
  end
  if god[5] == true then
  GodModeV3()
end
end

function GodMode() 
if AzeusS20 == off then
AzeusS20 = on

local ranges = gg.getRangesList("libil2cpp.so")

if #ranges == 0 then
  gg.alert("libil2cpp.so NOT FOUND in memory ranges!\n\nPossible reasons:\n• Game not fully loaded\n• Split APK (lib in split_config.*.apk)\n• Protected/renamed lib\n• Not Unity-IL2CPP game\n\nTry again after game loads fully.", "OK")
  return  -- or os.exit() if you want to fully stop
end

local base = 0
local maxSize = 0
for i, r in ipairs(ranges) do
  local sz = r["end"] - r["start"]
  if sz > maxSize then
    maxSize = sz
    base = r["start"]
  end
end

if base == 0 then
  gg.alert("No valid base found (all regions size 0?)", "OK")
  return
end

local APEX = {}
APEX[1] = {}
APEX[1].address = base + 3781268
APEX[1].flags = 4                
APEX[1].value = "~A8 RET"
gg.setValues(APEX)
gg.toast("Patched")
else if AzeusS20 == on then
  AzeusS20 = off
local ranges = gg.getRangesList("libil2cpp.so")
if #ranges == 0 then
    gg.alert("libil2cpp.so not found.", "OK")
    os.exit()
end

local base = 0
local maxSize = 0
for i, r in ipairs(ranges) do
    local sz = r["end"] - r["start"]
    if sz > maxSize then
        maxSize = sz
        base = r["start"]
    end
end


local APEX = {}
APEX[1] = {}
APEX[1].address = base + 3781268
APEX[1].flags = 4
APEX[1].value = 0xD10383FF       -- better as number (no "h")
-- or APEX[1].value = "D10383FFh" if you prefer string format
gg.setValues(APEX)
gg.toast("Reverted")
end
end
end

function GodModev()
if AzeusS21 == off then
AzeusS21 = on
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1117782016D;600.0F", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1117782016", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-999999999", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("70.0F;600.0F", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("70", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-10", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("Activated")
else if AzeusS21 == on then
AzeusS21 = off
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("-999999999D;600.0F", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("-999999999", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1117782016", gg.TYPE_DWORD)
gg.clearResults()
gg.searchNumber("-10.0F;600.0F", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("-10", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("70", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("Deactivated")
end
end
end
 
function GodModerpg() 
ACKA01 = gg.getRangesList("libil2cpp.so")[3].start
  APEX = nil
  APEX = {}
  APEX[1] = {}
  APEX[1].address = ACKA01 + 3977036 + 0
  APEX[1].value = "D65F03C0h"
  APEX[1].flags = 4
  gg.setValues(APEX)
  gg.clearResults()
  gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(10000, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll(":RPG", gg.TYPE_BYTE)
  gg.clearResults()
  gg.toast("SOSI HUI") 
end

function GodModeV2() 
  GetUnityMethod("TakeDamage", 4)
  gg.getResults(gg.getResultsCount())
  gg.editAll(VOID, 4)
  gg.clearResults()
end

function GodModeV3()
gg.setVisible(false)
local void1=0x374CC0
local void2=0x374640
hook_void(void1,void2)
gg.toast("Activated")
end


 
function infinitemote()
if AzeusS22 == off then
AzeusS22 = on
gg.searchNumber("0.25", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(400000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("200000000", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("Activated") 
else if AzeusS22 == on then
AzeusS22 = off
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("200000000", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(400000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0.25", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("Deactivated") 
end
end
end                 

function vehicfunc()
vehic = gg.multiChoice({
"Nitro Moto" ..AzeusS23, 
"Godmode vehicle",
"nitro vehicle", 
},nil,"Vehicle")

if vehic == nil then return gg.toast("Menu Cancelled") 
end
if vehic[1] == true then
cool() 
end
if vehic[2] == true then
godcar() 
end
if vehic[3] == true then
flycar() 
end
end

function cool()
if AzeusS23 == off then
AzeusS23 = on
gg.searchNumber("0.03", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0.36", gg.TYPE_FLOAT)
else if AzeusS23 == on then
AzeusS23 = off
gg.searchNumber("0.36", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0.03", gg.TYPE_FLOAT)
end
end
end

function godcar() 
gg.searchNumber("400", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("2000000000", gg.TYPE_FLOAT)
gg.clearResults()
end

function flycar()
gg["setRanges"](gg["REGION_ANONYMOUS"])
           gg["searchNumber"]('h9D74CDCC4C3D0000003F', gg["TYPE_BYTE"])
           gg["refineNumber"]('h9D74CDCC4C3D0000003F', gg["TYPE_BYTE"])
           gg["getResults"](500000)
           gg["editAll"]('h9D74000020C10000003F', gg["TYPE_BYTE"])
           gg["processResume"]()
           gg["clearResults"]()
      gg.toast("Activated")
end

function weaponfunc()
  choice67 = gg.multiChoice({
    "GunModes",
    "Give Gun",
    "Rapid All Guns",
    "No reload delay" ..AzeusS28,
    "Infinite ammo" ..AzeusS29,
    "Anti Rocket + Anti Arrow" ..pogger,
  }, nil, "Weapon")
  if choice67 == nil then return gg.toast("Menu Cancelled") 
  end
    if choice67[1] == true then
    GGGG10()
  end
   if choice67[2] == true then
    GGGG20()
  end
  if choice67[3] == true then
    rapidall()
  end
  if choice67[4] == true then
    noreload()
  end
  if choice67[5] == true then
    InfinityAmmo()
  end
  if choice67[6] == true then
    antime()
  end
  end
  
  function antime()
  if pogger == off then
  pogger = on
  setValue(3874680, 4, "~A8 RET")
  setValue(3875000, 4, "~A8 RET")
  else if pogger == on then
  pogger = off
  reset(3874680)
  reset(3875000)
  end
  end
  end
  
  
function GGGG10()
filsst12 = gg.multiChoice({
"Rocket Smg. Pistol" ..AzeusS24,
"Crossbow Smg. Pistol" ..AzeusS25,
"Shotgun smg pistol" ..AzeusS26,
"Give nan pistol" ..AzeusS27,
"Auto shoot",
},nil,
"Режимы стрельбы")
if filsst12 == nil then return gg.toast("Menu Cancelled") end
if filsst12[1] == true then smgrpg() end
if filsst12[2] == true then smgbowl() end
if filsst12[3] == true then smgshot() end
if filsst12[4] == true then nanpisun() end
if filsst12[5] == true then autoshoot() end
end

function smgrpg()
if AzeusS24 == off then
      AzeusS24 = on
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;1D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("1", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("3", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS24 == on then
      AzeusS24 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;3D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("3", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function smgbowl()
if AzeusS25 == off then
      AzeusS25 = on
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;1D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("1", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("4", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS25 == on then
      AzeusS25 = off
  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;4D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("4", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function smgshot()
if AzeusS26 == off then
      AzeusS26 = on
  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;1D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("1", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("8", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS26 == on then
      AzeusS26 = off
  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2147483647D;8D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
gg.refineNumber("8", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function nanpisun()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("10D;1097859072D;1137180672D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1097859072", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-1", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
end

function autoshoot()
gg.alert(" Удерживайте кнопку спуска в течение 5 секунд","Continue")
gg.toast("1")
gg.sleep(1500)
gg.toast("2")
gg.sleep(1500)
gg.toast("3")
gg.sleep(1050)
gg.toast("4")
gg.sleep(1500)
gg.toast("5")
gg.sleep(1500)
gg.alert("AutoShoot Activated")
end

function GGGG20()
filsst13 = gg.multiChoice({
"Give Toolbaton",
"Give Rpg",
"Give Smg", 
"Give Akm", 
"Give bat", 
"Give Sniper", 
"Give Pistol", 
"Give PhysicsGun", 
},nil,
"Дать оружие")
if filsst13 == nil then return gg.toast("Menu Cancelled") end
if filsst13[1] == true then giveToolbaton() end
if filsst13[2] == true then giveRPG() end
if filsst13[3] == true then giveSMG() end
if filsst13[4] == true then giveAKM() end
if filsst13[5] == true then giveBat() end
if filsst13[6] == true then giveSniper() end
if filsst13[7] == true then givePistol() end
if filsst13[8] == true then givePhysicsGun() end
end

function givePhysicsGun()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":PhysicsGun", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function givePistol()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Pistol", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveSniper()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Sniper", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveBat()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Bat", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveRPG()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":RPG", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveSMG()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Smg", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveAKM()
gg.searchNumber(":Hands", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Akm", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function giveToolbaton()
gg.searchNumber(":ToolBaton", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":Hands", gg.TYPE_BYTE)
gg.clearResults()
gg.toast("Activated")
end

function rapidall()
   gg.setRanges(gg.REGION_CODE_APP)
  gg.searchNumber("QFE'O'BFA913\";\"D0'`fE'F9", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(99999, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("Q\"@\"001CC003'_'D60000'A'", gg.TYPE_BYTE)
  gg.setRanges(gg.REGION_CODE_APP)
  gg.refineNumber("0", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
  revert = gg.getResults(1, nil, nil, nil, nil, nil, nil, nil, nil)
  gg.editAll("79", gg.TYPE_BYTE)
end

function noreload() 
if AzeusS28 == off then
AzeusS28 = on
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("hFE0F1EF8F44F01A9B40401F0", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(99999, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("hC0035FD6F44F01A9B40401F0", gg.TYPE_BYTE)
gg.processResume()
gg.clearResults()
else if AzeusS28 == on then
AzeusS28 = off
gg.setRanges(gg.REGION_CODE_APP)
gg.searchNumber("hC0035FD6F44F01A9B40401F0", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(99999, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("hFE0F1EF8F44F01A9B40401F0", gg.TYPE_BYTE)
gg.processResume()
gg.clearResults()
end
end
end

function InfinityAmmo()
if AzeusS29 == off then
AzeusS29 = on
  ACKA01 = gg.getRangesList("libil2cpp.so")[3].start
  APEX = nil
  APEX = {}
  APEX[1] = {}
  APEX[1].address = ACKA01 + 4044732 + 0
  APEX[1].value = "D65F03C0h"
  APEX[1].flags = 4
  gg.setValues(APEX)
  gg.toast("Activated")
  else if AzeusS29 == on then
  AzeusS29 = off
  ACKA01 = gg.getRangesList("libil2cpp.so")[3].start
  APEX = nil
  APEX = {}
  APEX[1] = {}
  APEX[1].address = ACKA01 + 4044732 + 0
  APEX[1].value = "-132247554"
  APEX[1].flags = 4
  gg.setValues(APEX)
  gg.toast("Deactivated")
end
end
end

function excluvfunc()
gg.toast("Pig not unlocked")
end

function secretf()
filsst31 = gg.multiChoice({
    "Multigun" ..AzeusS69,
    "NaN Mine" ..AzeusS73,
    "FPS Boost" ..AzeusS74,
    "Gun no Animation" ..AzeusS78,
    "1.228 - NaN" ..AzeusS79,
    "1.454 - Infinity" ..AzeusS80,
    "Freeze Rocket" ..AzeusS83,
    "Freeze Arrow" ..AzeusS84,
    "Crash RPG" ..AzeusS85,
    "All Password Panel - 0000" ..AzeusS88,
    "Nextbot Allow" ..AzeusS89,
    "Admin Mode",
    "Set Animation speed",
}, nil, "Giga")
if filsst31 == nil then return gg.toast("Menu Cancelled") end
    if filsst31[1] == true then multigun() end
    if filsst31[2] == true then nanMine() end
    if filsst31[3] == true then fpsBoost() end
    if filsst31[4] == true then gunNoAnim() end
    if filsst31[5] == true then PIZDAAANaN() end
    if filsst31[6] == true then HYESOSInfinity() end
    if filsst31[7] == true then freezeRocket() end
    if filsst31[8] == true then freezeArrow() end
    if filsst31[9] == true then crashRPG() end
    if filsst31[10] == true then allPassword0000() end
    if filsst31[11] == true then giga() end
    if filsst31[12] == true then admin() end
    if filsst31[13] == true then setanm() end
end

function setanm()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1", gg.TYPE_DOUBLE)
gg.getResults(1000)
local results = gg.getResults(1000)
if #results == 0 then
    gg.alert("pig")
    os.exit()
end

local input = gg.prompt({"Select value"}, {0}, {"number"})

if input == nil then
    gg.alert("Отмена")
    os.exit()
end

local selectedValue = input[1]
gg.editAll(selectedValue, gg.TYPE_DWORD)
gg.clearResults()

gg.alert("animation speed is now: " .. selectedValue)
end


function admin()
gg.setRanges(gg.REGION_OTHER) 
gg.clearResults()
gg.searchNumber("1", gg.TYPE_DOUBLE, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.processResume()
revert = gg.getResults(10000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("0", gg.TYPE_DOUBLE)
end

function nextbotAllow()
if AzeusS89 == off then
      AzeusS89 = on
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";Nextbot", gg.TYPE_WORD)
gg.getResults(1000)
gg.editAll(";abcdefg", gg.TYPE_WORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS89 == on then
      AzeusS89 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";abcdefg", gg.TYPE_WORD)
gg.getResults(1000)
gg.editAll(";Nextbot", gg.TYPE_WORD)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end

function allPassword0000()
if AzeusS88 == off then
      AzeusS88 = on
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";Password", gg.TYPE_WORD)
gg.getResults(1000)
gg.editAll(";qwertyui", gg.TYPE_WORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS88 == on then
      AzeusS88 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";qwertyui", gg.TYPE_WORD)
gg.getResults(1000)
gg.editAll(";Password", gg.TYPE_WORD)
gg.clearResults()

      gg.toast("Deactivated")
      end
end
end


function crashRPG()
if AzeusS85 == off then
      AzeusS85 = on
	  gg.setVisible(false)
gg.toast("Стрельните под себя РПГ когда включили")
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber('4979925657851396096', gg.TYPE_QWORD)
gg.refineNumber('4979925657851396096', gg.TYPE_QWORD)
gg.getResults(500000)
gg.editAll('4979925661004070911', gg.TYPE_QWORD)
gg.clearResults()
gg.sleep(500)

      gg.toast("Activated")
else if AzeusS85 == on then
      AzeusS85 = off
	  gg.setVisible(false)
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber('4979925661004070911', gg.TYPE_QWORD)
gg.refineNumber('4979925661004070911', gg.TYPE_QWORD)
gg.getResults(500000)
gg.editAll('4979925657851396096', gg.TYPE_QWORD)
gg.processResume()
gg.clearResults()

      gg.toast("Deactivated")
      end
end
end


function freezeArrow()
if AzeusS84 == off then
      AzeusS84 = on
	  gg["setVisible"](false)

             gg["setRanges"](gg["REGION_ANONYMOUS"])

           gg["searchNumber"]('1117782016D;70F;80,0F', gg["TYPE_FLOAT"])

           gg["refineNumber"]('70', gg["TYPE_FLOAT"])
           gg["getResults"](500000)
           gg["editAll"]('0', gg["TYPE_FLOAT"])
           gg["processResume"]()
           gg["clearResults"]()
           gg.sleep(500)
      gg.toast("Activated")
else if AzeusS84 == on then
      AzeusS84 = off
	   gg["setVisible"](false)
           gg["setRanges"](gg["REGION_ANONYMOUS"])
           gg["searchNumber"]('1117782016D;0F;80,0F;600F', gg["TYPE_FLOAT"])
           gg["refineNumber"]('0', gg["TYPE_FLOAT"])
           gg["getResults"](500000)
           gg["editAll"]('70', gg["TYPE_FLOAT"])
           gg["processResume"]()
           gg["clearResults"]()
      gg.toast("Deactivated")
      end
end
end


function freezeRocket()
if AzeusS83 == off then
      AzeusS83 = on
	               gg["setVisible"](false)
             gg["setRanges"](gg["REGION_ANONYMOUS"])
           gg["searchNumber"]('30F;2500.0F', gg["TYPE_FLOAT"])
           gg["refineNumber"]('30', gg["TYPE_FLOAT"])
           gg["getResults"](500000)
           gg["editAll"]('0', gg["TYPE_FLOAT"])
           gg["processResume"]()
           gg["clearResults"]()
           gg.sleep(500)
      gg.toast("Activated")
else if AzeusS83 == on then
      AzeusS83 = off
	  gg["setVisible"](false)
           gg["setRanges"](gg["REGION_ANONYMOUS"])
           gg["searchNumber"]('0F;600F;2500.0F', gg["TYPE_FLOAT"])
           gg["refineNumber"]('0', gg["TYPE_FLOAT"])
           gg["getResults"](500000)
           gg["editAll"]('30', gg["TYPE_FLOAT"])
           gg["processResume"]()
           gg["clearResults"]()
      gg.toast("Deactivated")
      end
end
end


function HYESOSInfinity()
if AzeusS80 == off then
      AzeusS80 = on
	  gg.alert("впиши 1.454 в моторе, репульсоре, триггере и тд, затем вруби и поставь. Будет Infinity")
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1069161644", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(1000)
gg.editAll("2139095040", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS80 == on then
      AzeusS80 = off
      gg.toast("После перезахода офнется")
      end
end
end

function PIZDAAANaN()
if AzeusS79 == off then
      AzeusS79 = on
	  gg.alert("впиши 1.228 в моторе, репульсоре, триггере и тд, затем вруби и поставь. Будет NaN")
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1067265819", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(1000)
gg.editAll("-1", gg.TYPE_DWORD)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS79 == on then
      AzeusS79 = off
      gg.toast("После перезахода офнется")
      end
end
end

function gunNoAnim()
if AzeusS78 == off then
      AzeusS78 = on
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("30", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("150.7", gg.TYPE_FLOAT)
gg.clearResults()
      gg.toast("Activated")
else if AzeusS78 == on then
      AzeusS78 = off
	  gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("150.7", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(2500, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("30", gg.TYPE_FLOAT)
gg.clearResults()
      gg.toast("Deactivated")
      end
end
end


function fpsBoost()
if AzeusS74 == off then
      AzeusS74 = on
	  gg.searchNumber(":4 515 609 228 873 826 304", gg.TYPE_QWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(100000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll(":4 515 609 228 871 570 691", gg.TYPE_QWORD)
gg.processResume()
gg.clearResults()
      gg.toast("Activated")
else if AzeusS74 == on then
      AzeusS74 = off
      gg.toast("После перезахода офается само")
      end
end
end


function multigun()
      AzeusS69 = on
gg.clearResults()
gg.searchNumber("30D;10F;200F;1D", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.refineNumber("1", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
revert = gg.getResults(10000)

while true do
    gg.setValues(revert)
    gg.editAll("3", gg.TYPE_DWORD)
    gg.sleep(1500)
    gg.setValues(revert)
    gg.editAll("4", gg.TYPE_DWORD)
    gg.sleep(1500)
    gg.setValues(revert)
    gg.editAll("8", gg.TYPE_DWORD)
    gg.sleep(1500)
    gg.setValues(revert)
    gg.editAll("1", gg.TYPE_DWORD)
    gg.sleep(1500)
end
end

function set()
filsst3 = gg.multiChoice({
    "Player Set" ..SSDI97,
    "Props Set" ..SSDI98,
    "Vehicles Set" ..SSDI99,
"Back"
}, nil, "aaaaaaaaaaaaa")

if filsst3 == nil then return gg.toast("Menu Cancelled") end
    if filsst3[1] == true then Player() end
    if filsst3[2] == true then Props() end
    if filsst3[3] == true then Vehicles() end
    if filsst3[4] == true then menu() end
end

function Vehicles()
SSDI99 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1000", gg.TYPE_DWORD)
gg.getResults(40)
gg.alert("Изначально должно стоять 40 транспорта, затем поменяйте значение в игре на 4. У вас есть 5 секунд. После чего вам даст панель с выбором игроков (от -1000 до 2 147 483 647)")
gg.sleep(5000)
gg.refineNumber("4", gg.TYPE_DWORD)
local results = gg.getResults(1000)
if #results == 0 then
    gg.alert("схахахах тормозная свинья")
    os.exit()
end

local input = gg.prompt({"Select value :[-1000;2 147 483 647]"}, {0}, {"number"})

if input == nil then
    gg.alert("Отмена")
    os.exit()
end

local selectedValue = input[1]
gg.editAll(selectedValue, gg.TYPE_DWORD)
gg.clearResults()

gg.alert("лимит пропов: " .. selectedValue)
end

function Props()
SSDI98 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("1000", gg.TYPE_DWORD)
gg.getResults(1000)
gg.alert("Изначально должно стоять 1000 пропов, затем поменяйте значение в игре на 100. У вас есть 5 секунд. После чего вам даст панель с выбором игроков (от -1000 до 2 147 483 647)")
gg.sleep(5000)
gg.refineNumber("100", gg.TYPE_DWORD)
local results = gg.getResults(1000)
if #results == 0 then
    gg.alert("pig")
    os.exit()
end

local input = gg.prompt({"Select value :[-1000;2 147 483 647]"}, {0}, {"number"})

if input == nil then
    gg.alert("Отмена")
    os.exit()
end

local selectedValue = input[1]
gg.editAll(selectedValue, gg.TYPE_DWORD)
gg.clearResults()

gg.alert("лимит пропов: " .. selectedValue)
end

function Player()
SSDI97 = on
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("6", gg.TYPE_DWORD)
gg.getResults(1000)
gg.alert("Изначально должно стоять 6 игроков, затем поменяйте значение в игре на 10. У вас есть 5 секунд. После чего вам даст панель с выбором игроков (от 0 до 10)")
gg.sleep(5000)
gg.refineNumber("10", gg.TYPE_DWORD)
local results = gg.getResults(1000)
if #results == 0 then
    gg.alert("pig detected")
    os.exit()
end

local input = gg.prompt({"Select value :[0;10]"}, {0}, {"number"})

if input == nil then
    gg.alert("Отмена")
    os.exit()
end

local selectedValue = input[1]
gg.editAll(selectedValue, gg.TYPE_DWORD)
gg.clearResults()

gg.alert("лимит игроков: " .. selectedValue)
end




while true do
if gg.isVisible(true) then
Azeus = 1
gg.setVisible(false)
end
if Azeus == 1 then home() end
end