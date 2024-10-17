local NUI = unpack(NaowhUI)

local tonumber, ipairs, unpack = tonumber, ipairs, unpack
local format = format

local C_AddOns = C_AddOns
local CommandTable = {}

NUI.title = format("|cff0091edNaowh|r|cffffa300UI|r")
NUI.version = tonumber(C_AddOns.GetAddOnMetadata("NaowhUI", "Version"))
NUI.myname = UnitName("player")
NUI.myrealm = GetRealmName()
NUI.mynameRealm = format("%s - %s", NUI.myname, NUI.myrealm)

NUI.ReloadRequired = false

local function InitializeDetails()
	local Details = Details

	if Details.is_first_run and #Details.custom == 0 then
		Details:AddDefaultCustomDisplays()
	end

	Details.character_first_run = false
	Details.is_first_run = false
	Details.is_version_first_run = false
end

local function InitializeElvUI()
	local E = unpack(ElvUI)

	if E.InstallFrame and E.InstallFrame:IsShown() then
		E.InstallFrame:Hide()

		E.private.install_complete = E.version
	end

	E:AddTag("health:percent-naowh", "UNIT_HEALTH UNIT_MAXHEALTH", function(unit)
		local CurrentHealth, MaxHealth = UnitHealth(unit), UnitHealthMax(unit)
		local HealthPercent = CurrentHealth / MaxHealth * 100

		return E:GetFormattedText("PERCENT", CurrentHealth, MaxHealth, HealthPercent == 100 and 0 or HealthPercent < 10 and 2 or 1, nil)
	end)

	E.global.ignoreIncompatible = true
end

function CommandTable.install()
	NUI:RunInstaller()
end

function NUI:Initialize()
	local IncompatibleAddOns = {
		"NaowhUI_Installer",
		"SharedMedia_Naowh"
	}

	if self:IsAddOnEnabled("Details") then
		InitializeDetails()
	end

	if self:IsAddOnEnabled("ElvUI") then
		InitializeElvUI()
	end

	if self.db.global.profiles and not self.db.char.installed then
		self:Notification("Do you wish to load your selected NaowhUI profiles onto this character?", function() self:LoadProfiles() end, function() self.db.char.installed = true end)
	end

	for _, v in ipairs(IncompatibleAddOns) do
		if self:IsAddOnEnabled(v) then
			C_AddOns.DisableAddOn(v)
		end
	end
end

function NUI:HandleChatCommand(input)
	local CommandFunction = CommandTable[input]

	if not CommandFunction then
		self:Print("The command" .. " " .. "'" .. input .. "'" .. " " .. "does not exist.")

		return
	end

	CommandFunction()
end