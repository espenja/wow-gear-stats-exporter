local Addon = LibStub("AceAddon-3.0"):GetAddon("GearStatsExporter")
local Module = Addon:NewModule("Scanner")

local itemTable = {
    ["Head"] = nil,
    ["Neck"] = nil,
    ["Shoulder"] = nil,
    ["Back"] = nil,
    ["Chest"] = nil,
    ["Wrist"] = nil,
    ["Hands"] = nil,
    ["Waist"] = nil,
    ["Legs"] = nil,
    ["Feet"] = nil,
    ["Finger 1"] = nil,
    ["Finger 2"] = nil,
    ["Trinket 1"] = nil,
    ["Trinket 2"] = nil,
    ["Main Hand"] = nil,
    ["Off Hand"] = nil
}

local DB, EventHandler

function Module:OnInitialize()
    DB = Addon:GetModule("DB")
    EventHandler = Addon:GetModule("EventHandler")
end

function printTable(t, tab)
    tab = tab .. "   "
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(tab, k .. ":")
            printTable(v, tab)
        else
            print(tab, k .. ": " .. tostring(v))
        end
    end
end

function printTable2(t)
    for i, v in ipairs(DB:GetSlots()) do
        print(i, v)
    end
end

function appendToString(str1, str2)
    return str1 .. "," .. str2
end

function Module:ScanPlayerGear()
    local slots = DB:GetSlots()

    for equipmentSlotIndex, equipmentSlotName in ipairs(slots) do
        -- print(equipmentSlotIndex, equipmentSlotName)
        local itemLocation = ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex)
        local item = Item:CreateFromItemLocation(itemLocation)

        if itemLocation:IsValid() and item:IsItemEmpty() == false then
            local inventoryItemLink = GetInventoryItemLink("player", equipmentSlotIndex)

            self:HandleItem(item, inventoryItemLink, equipmentSlotName)
        end
    end

    self:MakeCsv()
end

function Module:MakeCsv()
    local slots = DB:GetSlots()

    local playerName, realm = UnitName("player")
    local header = self:MakeHeader()

    -- print(header)

    for _, equipmentSlotName in ipairs(slots) do
        local item = itemTable[equipmentSlotName]

        if item ~= nil then
            local line = ""
            line = line .. "," .. equipmentSlotName
            line = line .. "," .. item.name
            line = line .. "," .. item.itemLevel

            for _, modifier in ipairs(DB:GetModifiers()) do
                if item.itemStats[modifier] then
                    line = line .. "," .. item.itemStats[modifier]
                end
            end

        -- for _, modifier in ipairs(DB:GetExtraModifiers()) do
        --     if item.itemStats[modifier] then
        --         line = line .. "," .. item.itemStats[modifier]
        --     end
        -- end
        end
    end
end

function Module:MakeHeader()
    local slots = DB:GetSlots()
    local hasCorruption = false
    local socketModifiers = {}
    local modifiersOnGear = {
        ["Armor"] = false,
        ["Stamina"] = false,
        ["Agility"] = false,
        ["Strength"] = false,
        ["Intellect"] = false,
        ["Corruption"] = false,
        ["Critical Strike"] = false,
        ["Haste"] = false,
        ["Mastery"] = false,
        ["Versatility"] = false,
        ["Socket"] = false,
        ["Speed"] = false,
        ["Leech"] = false,
        ["Avoidance"] = false,
        ["Indestructible"] = false
    }

    for _, equipmentSlotName in ipairs(slots) do
        local item = itemTable[equipmentSlotName]

        if item ~= nil then
            for modifier, _ in pairs(item.itemStats) do
                modifiersOnGear[modifier] = true

                if modifier == "Socket" then
                    local socket = item.itemStats[modifier]
                    socketModifiers[socket.stat] = true
                end
            end
        end
    end

    local header = "Slot,Name,iLvl"

    for _, modifier in ipairs(DB:GetModifiers()) do
        if modifiersOnGear[modifier] then
            if modifier == "Socket" then
                for _, socketModifier in ipairs(DB:GetSocketModifiers()) do
                    if socketModifiers[socketModifier] then
                        header = header .. ", Socket " .. socketModifier
                    end
                end
            elseif modifier == "Corruption" and hasCorruption then
                header = header .. ",Corruption,Corruption Value"
            else
                header = header .. "," .. modifier
            end
        end
    end

    return header
end

-- Process item and create a table with all relevant stats
function Module:HandleItem(item, inventoryItemLink, equipmentSlotName)
    local itemName,
        itemLink,
        itemRarity,
        itemLevel,
        itemMinLevel,
        itemType,
        itemSubType,
        itemStackCount,
        itemEquipLoc,
        itemTexture,
        itemSellPrice = GetItemInfo(inventoryItemLink)

    -- print(itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)

    itemTable[equipmentSlotName] = {
        name = itemName,
        itemLevel = itemLevel,
        itemStats = self:CreateItemStats(inventoryItemLink)
    }

    -- printTable(itemTable[equipmentSlotName], "")
end

-- Create custom item stats
function Module:CreateItemStats(itemLink)
    local customItemStats = {}
    local itemStats = GetItemStats(itemLink)
    local corruption = self:GetCorruptionByItemLink(itemLink)
    local corruptionValue = nil

    for key, value in pairs(itemStats) do
        local modName = DB:GetItemModifierName(key)

        print(key)

        if key == "EMPTY_SOCKET_PRISMATIC" then
            customItemStats["Socket"] = self:GetGemStats(itemStats, itemLink)
        elseif key == "ITEM_MOD_CORRUPTION" then
            corruptionValue = value
        else
            -- print(modName)
            customItemStats[modName] = value
        end
    end

    if corruption ~= nil then
        corruption.value = corruptionValue
        customItemStats["Corruption"] = corruption
    end

    return customItemStats
end

-- Create custom gem stats
function Module:GetGemStats(itemStats, itemLink)
    local gemName, gemItemLink = GetItemGem(itemLink, 1)

    if gemName == nil then
        return DB:GetGemStats("empty")
    end

    local gemItem = Item:CreateFromItemLink(gemItemLink)
    local gemItemID = gemItem:GetItemID()

    if DB:GetGemStats(gemItemID) == nil then
        return DB:GetGemStats("empty")
    end

    return DB:GetGemStats(gemItemID)
end

function Module:GetCorruptionByID(bonusID)
    local corruption = DB:GetBonus(bonusID)

    if corruption ~= nil then
        return {
            name = corruption[1],
            rank = corruption[2]
        }
    end
end

function Module:GetItemSplit(itemLink)
    local itemString = string.match(itemLink, "item:([%-?%d:]+)")
    local itemSplit = {}

    if itemString ~= nil then
        -- Split data into a table
        for _, v in ipairs({strsplit(":", itemString)}) do
            if v == "" then
                itemSplit[#itemSplit + 1] = 0
            else
                itemSplit[#itemSplit + 1] = tonumber(v)
            end
        end
    end

    return itemSplit
end

function Module:GetCorruptionByItemLink(itemLink)
    local itemSplit = self:GetItemSplit(itemLink)
    local bonuses = {}

    if IsCorruptedItem(itemLink) then
        for index = 1, itemSplit[13] do
            bonuses[#bonuses + 1] = itemSplit[13 + index]
        end
    end

    if #bonuses > 0 then
        for _, bonusID in pairs(bonuses) do
            local corruption = self:GetCorruptionByID(bonusID)
            if corruption ~= nil then
                return corruption
            end
        end
    end
end
