   -- Config start
local anchor = "CENTER"
local x, y = -390, -70
local size = 26
local spacing = 10
local show = {
	["none"] = false, 
	["pvp"] = false, 
	["arena"] = true,
}
local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/GetCVar("uiScale")
local function scale(x) return mult*math.floor(x+.5) end
local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		tile = false, tileSize = 0, edgeSize = scale(2), 
		insets = { left = -scale(2), right = -scale(2), top = -scale(2), bottom = -scale(2)}
    }
-- Config end

local spells = {
	[1766] = 10,	-- Kick
	[6552] = 10,	-- Pummel
	[2139] = 24,	-- Counterspell
	[19647] = 24,	-- Spell Lock
	[8122] = 30,	-- Psychic Scream
	[47476] = 120,	-- Strangulate
	[47528] = 10,	-- Mind Freeze
	[29166] = 180,	-- Innervate
	[49039] = 120,	-- Lichborne
	[54428] = 120,	-- Divine Plea
	[1022] = 300,	-- Hand of Protection
	[16190] = 180,	-- Mana Tide Totem
	[51514] = 45,	-- Hex
	[15487] = 45,	-- Silence
	[2094] = 180,	-- Blind
	[5246] = 120, -- Warr Fear
	[85285] = 10, -- Rebuke
	[33206] = 180, -- Pain Suppression
	[1856] = 180, -- Vanish
	[408] = 20, -- Kidney shot
	[57994] = 6, -- Wind Shear
	[20252] = 30, -- Intercept
	[100] = 15, -- Charge
	[44572] = 30, -- Deep Freeze
	[85388] = 45, -- Throwdown
	[853] = 40, -- Hammer of Justice
	[47481] = 60, -- Gnaw
	[19577] = 60, -- Intimidation
	[19574] = 100, -- Bestial Wrath
	[642] = 300, -- Divine Shield
	[871] = 300, -- Shield Wall
	[48792] = 180, -- Icebound Fortitude
	[22812] = 60, -- Barkskin
	[47476] = 120, -- Strangulate
	[17116] = 180, -- Nature's Swiftness
	[16188] = 120, -- Nature's Swiftness (Shaman)
	[47585] = 75, -- Dispersion
	[64843] = 480, -- Divine Hymn
	[64901] = 360, -- Hymn of Hope
	[45438] = 240, -- Ice Block
	[6940] = 120, -- Hand of Sacrifice
	[498] = 60, -- Divine Protection
	[1719] = 240, -- Recklesness
	[31884] = 120, -- Avenging Wrath
	[50334] = 180, -- Berserk
	[14185] = 300, -- Preparation
	[86150] = 300, -- Guardian of the Ancient Kings
	[49206] = 180, -- Summon Gargoyle
	[19574] = 70, -- Bestial Wrath
	[19263] = 110, --Deterrence
}

local icons = {}
local band = bit.band

local UpdatePositions = function()
	for i = 1, #icons do
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
	UpdatePositions()
end

local IconUpdate = function(self, elapsed)
	if (self.endTime < GetTime()) then
		StopTimer(self)
	end
end

local CreateIcon = function()
	local icon = CreateFrame("frame", nil, UIParent)
	icon:SetWidth(size)
	icon:SetHeight(size)
	icon:SetFrameLevel(30)
	local bg = CreateFrame("Frame", nil, icon)
	bg:SetPoint("TOPLEFT",-scale(1),scale(1))
	bg:SetPoint("BOTTOMRIGHT",scale(1),-scale(1))
	bg:SetBackdrop(backdrop)
	bg:SetBackdropColor(.1,.1,.1,1)
    bg:SetBackdropBorderColor(.3,.3,.3,1)
	bg:SetFrameLevel(5)
	icon.Cooldown = CreateFrame("Cooldown", nil, icon)
	icon.Cooldown:SetAllPoints(icon)
	icon.Texture = icon:CreateTexture(nil, "BORDER")
	icon.Texture:SetAllPoints(icon)
	return icon
end

local StartTimer = function(sID)
	local _,_,texture = GetSpellInfo(sID)
	local icon = CreateIcon()
	icon.Texture:SetTexture(texture)
	icon.Texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icon.endTime = GetTime() + spells[sID]
	icon:Show()
	icon:SetScript("OnUpdate", IconUpdate)
	CooldownFrame_SetTimer(icon.Cooldown, GetTime(), spells[sID], 1)
	tinsert(icons, icon)
	UpdatePositions()
end

local OnEvent = function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = ...
		if eventType == "SPELL_CAST_SUCCESS" and band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE then			
			if sourceName ~= UnitName("player") then
				if spells[spellID] and show[select(2, IsInInstance())] then
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