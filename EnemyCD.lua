local anchor = "CENTER"
local x, y = -70, -70
local size = 26
local spacing = 3

local spells = {
	[1766] = 10, -- kick
	[6554] = 10, -- pummel
	[2139] = 24, -- counterspell
	[19647] = 24, -- spell lock
	[10890] = 27, -- fear priest
	[47476] = 120, -- strangulate
	[47528] = 10, -- mindfreeze
	[29166] = 180, -- innervate
	[49039] = 120, -- Lichborne
	[54428] = 60, -- Divine Plea
	[10278] = 180, -- Hand of Protection
	[16190] = 300, -- Mana Tide Totem
	[51514] = 45, -- Hex
	[15487] = 45, -- Silence
	[2094] = 120, -- Blind
}

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local icons = {}
local id = 1

local UpdatePositions = function()
	for i = 1, id-1 do
		icons[i]:ClearAllPoints()
		if (i == 1) then
			icons[i]:SetPoint(anchor, UIParent, anchor, x, y)
		else
			icons[i]:SetPoint("BOTTOMLEFT", icons[i-1], "TOPLEFT", 0, spacing)
		end
		icons[i].id = i
	end
end

local StopTimer = function(icon)
	icon:SetScript("OnUpdate", nil)
	icon:Hide()
	tremove(icons, icon.id)
	id = id - 1
	UpdatePositions()
end

local IconUpdate = function(self, elapsed)
	if (self.endTime < GetTime()) then
		StopTimer(self)
	end
end

local CreateIcon = function()
	local icon = CreateFrame("frame")
	icon:SetParent(UIParent)
	icon.id = id
	icon:SetWidth(size)
	icon:SetHeight(size)
	icon:SetBackdrop(backdrop)
	icon:SetBackdropColor(0, 0, 0)
	icon.Cooldown = CreateFrame("Cooldown", nil, icon)
	icon.Cooldown:SetAllPoints(icon)
	icon.Texture = icon:CreateTexture(nil, "BORDER")
	icon.Texture:SetAllPoints(icon)
	icon:SetScript("OnUpdate", IconUpdate)
	return icon
end

local StartTimer = function(sID)
	local _,_,texture = GetSpellInfo(sID)
	if (not icons[id]) then
		icons[id] = CreateIcon()
	end
	if (id == 1) then
		icons[id]:SetPoint(anchor, UIParent, anchor, x, y)
	else
		icons[id]:SetPoint("BOTTOMLEFT", icons[id-1], "TOPLEFT", 0, spacing)
	end
	icons[id].Texture:SetTexture(texture)
	icons[id].Texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icons[id].endTime = GetTime() + spells[sID]
	icons[id]:Show()
	CooldownFrame_SetTimer(icons[id].Cooldown, GetTime(), spells[sID], 1)
	id = id + 1
end

local OnEvent = function(self, event, ...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = ...
		if (eventType == "SPELL_CAST_SUCCESS" and (bit.band(sourceFlags,COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)) then			
			if (sourceName ~= UnitName("player")) then
				if (spells[spellID]) then
					StartTimer(spellID)
				end
			end
		end 
	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		for k, v in pairs(icons) do
			StopTimer(v)
		end
	end
end

local addon = CreateFrame("frame")
addon:SetScript('OnEvent', OnEvent)
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")

SlashCmdList["EnemyCD"] = function(msg) 
	StartTimer(47528)
	StartTimer(19647)
	StartTimer(47476)
	StartTimer(51514)
end
SLASH_EnemyCD1 = "/enemycd"