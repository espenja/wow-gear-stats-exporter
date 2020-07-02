local Addon = LibStub("AceAddon-3.0"):GetAddon("GearStatsExporter")
local Module = Addon:NewModule("EventHandler")
local Scanner

local frame, events = CreateFrame("Frame"), {};

-- Called when INSPECT_READY event is fired
function events:INSPECT_READY(...)
    local guid = ...
    Scanner:ScanPlayerGear()
 end

function Module:OnInitialize()

    Scanner = Addon:GetModule("Scanner")
        -- Setup event catching
    frame:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...);
    end);

    for k, v in pairs(events) do
        frame:RegisterEvent(k);
    end
end

function Module:NotifyScan()
    NotifyInspect("player")
end

SLASH_GEAR_STATS_EXPORTER1 = '/gse'
function SlashCmdList.GEAR_STATS_EXPORTER(msg, editbox)
    Module:NotifyScan()
end
