local NUI = unpack(NaowhUI)
local SE = NUI:GetModule("Setup")

local E
local Profile = "Naowh"
local AceDB = LibStub("AceDB-3.0")
local ReloadUI = ReloadUI
local type = type
local VMRT = VMRT
local pairs = pairs
local SetupTable = {}

do
	if NUI:IsAddOnEnabled("ElvUI") then
		E = unpack(ElvUI)
	end
end

local function SetupComplete(addon)
	local PluginInstallStepComplete = PluginInstallStepComplete

	if PluginInstallStepComplete then
		PluginInstallStepComplete:Hide()
		PluginInstallStepComplete.message = "Success"
		PluginInstallStepComplete:Show()
	end

	if not addon then
		return
	end

	if not NUI.db.global.profiles then
		NUI.db.global.profiles = {}
	end

	NUI.db.global.profiles[addon] = true
end

local function ImportBigWigs(addon)
	BigWigsAPI:ImportProfileString(NUI.title, NUI.BigWigsData, Profile, function(callback)
		if not callback then
			return
		end

		SetupComplete(addon)
	end)
end

local function IsProfileExisting(db)
	local Database = AceDB:New(db)
	local Profiles = Database:GetProfiles()

	for i = 1, #Profiles do
		if Profiles[i] == Profile then

			return true
		end
	end
end

local function ImportElvUI(addon, scale)
	local D = E.Distributor
	local SC = NUI:GetModule("Scaling")
	local ProfileType, _, ProfileData = D:Decode(NUI.ElvUIData)

	if NUI.ReloadRequired then
		NUI:Notification("A reload is required in order to select a different scale. Do you wish to reload your UI?", function() ReloadUI() end)

		return
	end

	if not ProfileData or type(ProfileData) ~= "table" then
		NUI:Notification("Something went wrong with the setup. Do you wish to reload your UI and try again?", function() ReloadUI() end)

		return
	end

	D:SetImportedProfile(ProfileType, Profile, ProfileData, true)
	SC:Scale(addon, scale)
	SetupComplete(addon)
	E:SetupCVars(true)
end

local function ImportMRT(addon)
	local MRTProfile = VMRT.Profile or "default"
	local IgnoredKeys = {
		["Addon"] = true,
		["Profile"] = true,
		["ProfileKeys"] = true,
		["Profiles"] = true,
	}

	VMRT.Profiles[MRTProfile] = {}

	for k, v in pairs(VMRT) do
		if not IgnoredKeys[k] then
			VMRT.Profiles[MRTProfile][k] = v
			VMRT[k] = nil
		end
	end

	for k, v in pairs(NUI.MRTData) do
		VMRT[k] = v
	end

	SetupComplete(addon)

	VMRT.Profile = Profile
end

local function ImportPlater(addon)
	local Plater = Plater
	local DecompressedData = Plater.DecompressData(NUI.PlaterData, "print")
	local HookableMethod = "OnProfileCreated"

	if not DecompressedData or type(DecompressedData) ~= "table" then
		NUI:Notification("Something went wrong with the setup. Do you wish to reload your UI and try again?", function() ReloadUI() end)

		return
	end

	if not SE:IsHooked(Plater, HookableMethod) then
		SE:RawHook(Plater, HookableMethod, function()
			C_Timer.After (.5, function()
				Plater.ImportScriptsFromLibrary()
				Plater.ApplyPatches()
				Plater.CompileAllScripts("script")
				Plater.CompileAllScripts("hook")

				Plater.db.profile.use_ui_parent = true
				Plater.db.profile.ui_parent_scale_tune = 1 / UIParent:GetEffectiveScale()
				
				Plater:RefreshConfig()
				Plater.UpdatePlateClickSpace()
			end)
		end)
	end

	Plater.ImportAndSwitchProfile(Profile, DecompressedData, false, false, true)
	SetupComplete(addon)
end

function SetupTable.BigWigs(import, addon)
	local BigWigs3DB = BigWigs3DB
	local Database

	if import then
		ImportBigWigs(addon)

		return
	end

	if not IsProfileExisting(BigWigs3DB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	Database = AceDB:New(BigWigs3DB)

	Database:SetProfile(Profile)
end

function SetupTable.Details(import, addon)
	local Details = Details

	if import then
		Details:ImportProfile(NUI.DetailsData, Profile, false, false, true)

		for i, v in Details:ListInstances() do
			DetailsFramework.table.copy(v.hide_on_context, NUI.DetailsAutomationData[i].hide_on_context)
		end

		SetupComplete(addon)

		return
	end

	if not Details:GetProfile(Profile) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	Details:ApplyProfile(Profile)
end

function SetupTable.ElvUI(import, addon, scale)
	if import then
		ImportElvUI(addon, scale)
	end

	if not IsProfileExisting(ElvDB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	if not import then
		E.data:SetProfile(Profile)
	end

	E.private.general.chatBubbleFont = Profile
	E.private.general.chatBubbleFontOutline = "OUTLINE"
	E.private.general.chatBubbleFontSize = 11
	E.private.general.dmgfont = "GothamNarrowUltra"
	E.private.general.namefont = Profile
	E.private.nameplates.enable = false
end

function SetupTable.HidingBar()
	local HidingBarDB = HidingBarDB
	local tinsert = tinsert
	local Database = {}

	for _, v in ipairs(HidingBarDB.profiles) do
		if v.name ~= Profile then
			v.isDefault = nil

			tinsert(Database, v)
		end
	end

	tinsert(Database, NUI.HidingBarData)

	HidingBarDB.profiles = Database
	HidingBarDBChar = nil

	SetupComplete()
end

function SetupTable.MRT(import, addon)
	local Character = NUI.mynameRealm:gsub(" ","")

	if import then
		ImportMRT(addon)
	end

	if not (VMRT.Profile == Profile or VMRT.Profiles[Profile]) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	VMRT.ProfileKeys[Character] = Profile
end

function SetupTable.NameplateAuras(import, addon)
	local NameplateAurasAceDB = NameplateAurasAceDB
	local Database = AceDB:New(NameplateAurasAceDB)

	if import then
		SetupComplete(addon)

		NameplateAurasAceDB.profiles[Profile] = NUI.NameplateAurasData
	end

	if not IsProfileExisting(NameplateAurasAceDB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	Database:SetProfile(Profile)
end

function SetupTable.OmniCD(import, addon)
	local OmniCDDB = OmniCDDB
	local Database = AceDB:New(OmniCDDB)

	if import then
		SetupComplete(addon)

		OmniCDDB.profiles[Profile] = NUI.OmniCDData
	end

	if not IsProfileExisting(OmniCDDB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	Database:SetProfile(Profile)
end

function SetupTable.Plater(import, addon)
	local Plater = Plater
	local HookableMethod = "RefreshConfigProfileChanged"

	if not SE:IsHooked(Plater, HookableMethod) then
		SE:RawHook(Plater, HookableMethod, function() Plater:RefreshConfig() end)
	end

	if import then
		ImportPlater(addon)
	end

	if not IsProfileExisting(PlaterDB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	if not import then
		Plater.db:SetProfile(Profile)
	end
end

function SetupTable.WarpDeplete(import, addon)
	local WarpDepleteDB = WarpDepleteDB

	if import then
		SetupComplete(addon)

		WarpDepleteDB.profiles[Profile] = NUI.WarpDepleteData
	end

	if not IsProfileExisting(WarpDepleteDB) then
		NUI.db.global.profiles[addon] = nil

		return
	end

	WarpDeplete.db:SetProfile(Profile)
end

function SE:Setup(addon, import, scale)
	local SetupFunction = SetupTable[addon]

	NUI:LoadData()
	SetupFunction(import, addon, scale)
end