﻿------------------------------
--      Are you local?      --
------------------------------

local dew = AceLibrary("Dewdrop-2.0")
local BigWigs = BigWigs

local hint = nil
local _G = getfenv(0)

local L = LibStub("AceLocale-3.0"):GetLocale("BigWigs")


----------------------------
--      FuBar Plugin      --
----------------------------

local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("BigWigs", {
	type = "launcher",
	text = "Big Wigs",
	icon = "Interface\\AddOns\\BigWigs\\Icons\\core-enabled",
})

BigWigsOptions = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0")
local BigWigsOptions = BigWigsOptions
local icon = LibStub("LibDBIcon-1.0", true)

-----------------------------
--      Menu Handling      --
-----------------------------

function BigWigsOptions:OnInitialize()
	hint = L["|cffeda55fClick|r to reset all running modules. |cffeda55fAlt-Click|r to disable them."]
	if icon then
		_G.BigWigsDB.minimap = _G.BigWigsDB.minimap or {}
		icon:Register("BigWigs", ldb, _G.BigWigsDB.minimap)
	end
end

--------------------------------------------------------------------------------
-- Tooltip additions from modules
--

local tooltipFunctions = {}
function BigWigsOptions:RegisterTooltipInfo(func)
	for i, v in ipairs(tooltipFunctions) do
		if v == func then
			error(("The function %q has already been registered."):format(func))
		end
	end
	table.insert(tooltipFunctions, func)
end

-----------------------------
--      Icon Handling      --
-----------------------------

function BigWigsOptions:OnEnable()
	self:RegisterEvent("BigWigs_CoreEnabled", "CoreState")
	self:RegisterEvent("BigWigs_CoreDisabled", "CoreState")

	self:CoreState()
end

function BigWigsOptions:CoreState()
	if BigWigs:IsActive() then
		ldb.icon = "Interface\\AddOns\\BigWigs\\Icons\\core-enabled"
	else
		ldb.icon = "Interface\\AddOns\\BigWigs\\Icons\\core-disabled"
	end
end

-----------------------------
--      FuBar Methods      --
-----------------------------

local function menu()
	--Don't create a new function every time we open the menu.
	dew:FeedAceOptionsTable(BigWigs.cmdtable)
end

function ldb.OnClick(self, button)
	if button == "RightButton" then
		dew:Open(self, "children", menu)
	else
		if BigWigs:IsActive() then
			if IsAltKeyDown() then
				if IsControlKeyDown() then
					BigWigs:ToggleActive(false)
				else
					for name, module in BigWigs:IterateModules() do
						if module:IsBossModule() and BigWigs:IsModuleActive(module) then
							BigWigs:ToggleModuleActive(module, false)
						end
					end
				end
			else
				for name, module in BigWigs:IterateModules() do
					if module:IsBossModule() and BigWigs:IsModuleActive(module) then
						BigWigs:BigWigs_RebootModule(module)
					end
				end
				BigWigs:Print(L["All running modules have been reset."])
			end
		else
			BigWigs:ToggleActive(true)
		end
	end
end

function ldb.OnTooltipShow(tt)
	tt:AddLine("Big Wigs")
	if BigWigs:IsActive() then
		local added = nil
		for name, module in BigWigs:IterateModules() do
			if module:IsBossModule() and BigWigs:IsModuleActive(module) then
				if not added then
					tt:AddLine(L["Active boss modules:"], 1, 1, 1)
					added = true
				end
				tt:AddLine(name)
			end
		end
	end
	for i, v in ipairs(tooltipFunctions) do
		v(tt)
	end
	tt:AddLine(hint, 0.2, 1, 0.2, 1)
end

