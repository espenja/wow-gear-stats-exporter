----------
-- Corruption database shamelessly stolen from CorruptionTooltips - https://www.curseforge.com/wow/addons/corruption-tooltips
-- Credits: suspectz (Anayanka - Defias Brotherhood - EU)
----------

local Addon = LibStub("AceAddon-3.0"):GetAddon("GearStatsExporter")
local Module = Addon:NewModule("DB")

local bonuses = {
   ["6483"] = {"Avoidant", "I", 315607},
   ["6484"] = {"Avoidant", "II", 315608},
   ["6485"] = {"Avoidant", "III", 315609},
   ["6474"] = {"Expedient", "I", 315544},
   ["6475"] = {"Expedient", "II", 315545},
   ["6476"] = {"Expedient", "III", 315546},
   ["6471"] = {"Masterful", "I", 315529},
   ["6472"] = {"Masterful", "II", 315530},
   ["6473"] = {"Masterful", "III", 315531},
   ["6480"] = {"Severe", "I", 315554},
   ["6481"] = {"Severe", "II", 315557},
   ["6482"] = {"Severe", "III", 315558},
   ["6477"] = {"Versatile", "I", 315549},
   ["6478"] = {"Versatile", "II", 315552},
   ["6479"] = {"Versatile", "III", 315553},
   ["6493"] = {"Siphoner", "I", 315590},
   ["6494"] = {"Siphoner", "II", 315591},
   ["6495"] = {"Siphoner", "III", 315592},
   ["6437"] = {"Strikethrough", "I", 315277},
   ["6438"] = {"Strikethrough", "II", 315281},
   ["6439"] = {"Strikethrough", "III", 315282},
   ["6555"] = {"Racing Pulse", "I", 318266},
   ["6559"] = {"Racing Pulse", "II", 318492},
   ["6560"] = {"Racing Pulse", "III", 318496},
   ["6556"] = {"Deadly Momentum", "I", 318268},
   ["6561"] = {"Deadly Momentum", "II", 318493},
   ["6562"] = {"Deadly Momentum", "III", 318497},
   ["6558"] = {"Surging Vitality", "I", 318270},
   ["6565"] = {"Surging Vitality", "II", 318495},
   ["6566"] = {"Surging Vitality", "III", 318499},
   ["6557"] = {"Honed Mind", "I", 318269},
   ["6563"] = {"Honed Mind", "II", 318494},
   ["6564"] = {"Honed Mind", "III", 318498},
   ["6549"] = {"Echoing Void", "I", 318280},
   ["6550"] = {"Echoing Void", "II", 318485},
   ["6551"] = {"Echoing Void", "III", 318486},
   ["6552"] = {"Infinite Stars", "I", 318274},
   ["6553"] = {"Infinite Stars", "II", 318487},
   ["6554"] = {"Infinite Stars", "III", 318488},
   ["6547"] = {"Ineffable Truth", "I", 318303},
   ["6548"] = {"Ineffable Truth", "II", 318484},
   ["6537"] = {"Twilight Devastation", "I", 318276},
   ["6538"] = {"Twilight Devastation", "II", 318477},
   ["6539"] = {"Twilight Devastation", "III", 318478},
   ["6543"] = {"Twisted Appendage", "I", 318481},
   ["6544"] = {"Twisted Appendage", "II", 318482},
   ["6545"] = {"Twisted Appendage", "III", 318483},
   ["6540"] = {"Void Ritual", "I", 318286},
   ["6541"] = {"Void Ritual", "II", 318479},
   ["6542"] = {"Void Ritual", "III", 318480},
   ["6573"] = {"Gushing Wound", "", 318272},
   ["6546"] = {"Glimpse of Clarity", "", 318239},
   ["6571"] = {"Searing Flames", "", 318293},
   ["6572"] = {"Obsidian Skin", "", 316651},
   ["6567"] = {"Devour Vitality", "", 318294},
   ["6568"] = {"Whispered Truths", "", 316780},
   ["6570"] = {"Flash of Insight", "", 318299},
   ["6569"] = {"Lash of the Void", "", 317290}
}

local gemStats = {
   ["empty"] = {
      empty = true
   },
   ["168642"] = {
      name = "Versatile Dark Opal",
      stat = "Versatility",
      value = 50
   },
   ["168640"] = {
      name = "Masterful Sea Currant",
      stat = "Mastery",
      value = 50
   },
   ["168639"] = {
      name = "Deadly Lava Lazuli",
      stat = "Critical Strike",
      value = 50
   },
   ["168641"] = {
      name = "Quick Sand Spinel",
      stat = "Haste",
      value = 50
   },
   ["168637"] = {
      name = "Leviathan's Eye of Agility",
      stat = "Agility",
      value = 120
   },
   ["168638"] = {
      name = "Leviathan's Eye of Intellect",
      stat = "Intellect",
      value = 120
   },
   ["168636"] = {
      name = "Leviathan's Eye of Strength",
      stat = "Strength",
      value = 120
   }
}

local slotNames = {
   [1] = "Head",
   [2] = "Neck",
   [3] = "Shoulder",
   [4] = "Shirt",
   [5] = "Chest",
   [6] = "Waist",
   [7] = "Legs",
   [8] = "Feet",
   [9] = "Wrist",
   [10] = "Hands",
   [11] = "Finger 1",
   [12] = "Finger 2",
   [13] = "Trinket 1",
   [14] = "Trinket 2",
   [15] = "Back",
   [16] = "Main Hand",
   [17] = "Off Hand",
   [18] = "Tabard",
   [19] = "Ammo"
}

local modifiers = {
   [1] = "Armor",
   [2] = "Stamina",
   [3] = "Agility",
   [4] = "Strength",
   [5] = "Intellect",
   [6] = "Corruption",
   [7] = "Critical Strike",
   [8] = "Haste",
   [9] = "Mastery",
   [10] = "Versatility",
   [11] = "Socket",
   [12] = "Speed",
   [13] = "Leech",
   [14] = "Avoidance",
   [15] = "Indestructible"
}

local extraModifiers = {
   [1] = "Speed",
   [2] = "Leech",
   [3] = "Avoidance",
   [4] = "Indestructible"
}

local socketModifiers = {
   [1] = "Agility",
   [2] = "Strength",
   [3] = "Intelligence",
   [4] = "Critical Strike",
   [5] = "Haste",
   [6] = "Mastery",
   [7] = "Versatility"
}

local headerOrder = {
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

function Module:GetBonus(bonusID)
   return bonuses[tostring(bonusID)]
end

function Module:GetGemStats(gemID)
   return gemStats[tostring(gemID)]
end

function Module:GetSlotName(slotId)
   return slotNames[slotId]
end

function Module:GetSlots()
   return slotNames
end

function Module:GetModifiers()
   return modifiers
end

function Module:GetExtraModifiers()
   return extraModifiers
end

function Module:GetSocketModifiers()
   return socketModifiers
end

function Module:GetHeaderOrder()
   return headerOrder
end

-- Get item modifier name from global constants
function Module:GetItemModifierName(constant)
   return _G[constant]
end

-- Get equipment slot name from global constants
function Module:GetItemEquipLocationName(itemEquipLoc)
   return slotNames[itemEquipLoc]
end
