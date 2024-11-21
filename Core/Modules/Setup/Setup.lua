local NUI = unpack(NaowhUI)
local SE = NUI:GetModule("Setup")

local ExRT = ...

local E
local Profile = "Naowh"
local AceDB = LibStub("AceDB-3.0")
local ReloadUI = ReloadUI
local type = type
local VMRT = VMRT
local pairs = pairs
local LibDeflate = LibStub("LibDeflate")
local LibSerialize = LibStub("AceSerializer-3.0")
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
	BigWigsAPI.RegisterProfile(NUI.title, NUI.BigWigsData, Profile, function(callback)
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
	local string_byte = string.byte
	local function StringToTable()
		local str = NUI.MRTData
			if not map and string_byte(str, 1) == 123 then
				str = str:sub(2,-2)	--Expect valid table here
			end
			local strlen = str:len()
			local i = 1
			local prev = 1
			map = map or {}
			offset = offset or 0
		
			local inTable, inString, inWideString
			local startTable, wideStringEqCount = 1, 0
		
			while i <= strlen do
				local b1 = string_byte(str, i)
				if not inString and not inTable and b1 == 123 then
					inTable = 0
					startTable = i
				elseif not inString and inTable and b1 == 123 then
					inTable = inTable + 1
				elseif not inString and inTable and b1 == 125 then
					if inTable == 0 then
						map[startTable+offset] = i + offset
						map[startTable+0.5+offset] = 1
						inTable = false
					else
						inTable = inTable - 1
					end
				elseif not inString and b1 == 34 then	--"
					if map[i+offset+0.5] == 2 then
						i = map[i+offset] - offset
					else
						inString = i
					end
				elseif inString and not inWideString and b1 == 92 then	--\
					i = i + 1
				elseif inString and not inWideString and b1 == 34 then	--"
					map[inString+offset] = i + offset
					map[inString+0.5+offset] = 2
					inString = false
				elseif not inString and b1 == 91 then	-- [ = [
					if map[i+offset+0.5] == 3 then
						i = map[i+offset] - offset
					else
						local k = i + 1
						local eqc = 0
						while k <= strlen do
							local c1 = string_byte(str, k)
							if c1 == 61 then
								eqc = eqc + 1
							elseif c1 == b1 then
								inString = i
								inWideString = i
								i = k
								wideStringEqCount = eqc
								break
							else
								break
							end
							k = k + 1
						end
					end
				elseif inString and inWideString and b1 == 93 then	-- ] = ]
					local k = i + 1
					local eqc = 0
					while k <= strlen do
						local c1 = string_byte(str, k)
						if c1 == 61 then
							eqc = eqc + 1
						elseif c1 == b1 then
							if eqc == wideStringEqCount then
								i = k
								map[inWideString+offset] = i + offset
								map[inWideString+0.5+offset] = 3
								inString = false
								inWideString = false
							end
							break
						else
							break
						end
						k = k + 1
					end
				end
				if not inString and not inTable and (b1 == 44 or i == strlen) then	--,
					map[-prev-offset] = i - (b1 == 44 and 1 or 0) + offset
					prev = i + 1
				end
				i = i + 1
			end
		
			local res = {}
			local numKey = 1
			i = 1
			while i <= strlen do
				if map[-i-offset] then
					local s, e = i, map[-i-offset] - offset
					local k = s
					local key, value
					local isError
					prev = k
					while k <= e do
						if map[k+offset] then
							if map[k+0.5+offset] == 1 then
								value = ExRT.F.TextToTable( str:sub(k+1,map[k+offset]-offset-1) ,map,k+offset)
							elseif map[k+0.5+offset] == 2 then
								value = str:sub(k + 1,map[k+offset]-offset-1):gsub("\\\"","\""):gsub("\\\\","\\")
							elseif map[k+0.5+offset] == 3 then
								value = str:sub(k,map[k+offset]-offset):gsub("^%[=*%[",""):gsub("%]=*%]$","")
							end
							k = map[k+offset] + 1 - offset
						else
							local b1 = string_byte(str, k)
							if b1 == 61 then	--=
								if value then
									key = value
									value = nil
								else
									key = str:sub(prev, k-1):trim()
									if key:find("^%[") and key:find("%]$") then
										key = key:gsub("^%[",""):gsub("%]$","")
										if tonumber(key) then
											key = tonumber(key)
										end
									elseif key == "true" then
										key = true
									elseif key == "false" then
										key = false
									elseif tonumber(key) then
										key = tonumber(key)
									else
										key = key:match("[A-Za-z_][A-Za-z_0-9]*")
									end
									if not key then
										isError = true
										break
									end
								end
								prev = k + 1
							elseif k == e and not value then
								value = str:sub(prev, k):trim()
								if value == "true" then
									value = true
								elseif value == "false" then
									value = false
								else
									value = tonumber(value)
								end
							end
							k = k + 1
						end
					end
					if not isError then
						if not key then
							key = numKey
							numKey = numKey + 1
						end
						res[key] = value
					end
					i = map[-i-offset] - offset
				end
				i = i + 1
			end
			return res
	end

	local headerLen = NUI.MRTData:sub(1,4) == "EXRT" and 6 or 5


	local decoded = LibDeflate:DecodeForPrint(NUI.MRTData:sub(headerLen+1))
	local decompressed = LibDeflate:DecompressDeflate(decoded)

	if not decompressed then
		print('error: import string is broken')
		return
	end

	local profileName,clientVersion,tableData = strsplit(",",decompressed,3)
	decompressed = nil
	local successful, res = pcall(StringToTable,tableData)
	print(res)

	VMRT.Profiles[Profile] = res

	local MAJOR_KEYS = {
		["Addon"]=true,
		["Profiles"]=true,
		["Profile"]=true,
		["ProfileKeys"]=true,
	}

	local function SaveCurrentProfiletoDB()
		local profileName = VMRT.Profile or "default"
		local saveDB = {}
		VMRT.Profiles[profileName] = saveDB
		
		for key,val in pairs(VMRT) do
			if not MAJOR_KEYS[key] then
				saveDB[key] = val
			end
		end
	end

	local function LoadProfileFromDB(profileName,isCopy)
		local loadDB = VMRT.Profiles[profileName]
		if not loadDB then
			print("Error")
			return
		end
		
		for key,val in pairs(VMRT) do
			if not MAJOR_KEYS[key] then
				VMRT[key] = nil
			end
		end
		print(loadDB)
		for key,val in pairs(loadDB) do
			if not MAJOR_KEYS[key] then
				VMRT[key] = val
			end
		end
		
		if not isCopy then
			VMRT.Profiles[profileName] = {}
		end
	end

	SaveCurrentProfiletoDB()
	VMRT.Profile = Profile
	VMRT.ProfileKeys[NUI.mynameRealm] = Profile
	LoadProfileFromDB(Profile)

	SetupComplete(addon)
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
		Details:EraseProfile(Profile)
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
		local LibSerialize = LibStub("LibSerialize")
		SetupComplete(addon)

		local decoded = LibDeflate:DecodeForPrint(NUI.NameplateAurasData)
		if (decoded == nil) then
			return
		end

		local decompressed = LibDeflate:DecompressDeflate(decoded);
		if (decompressed == nil) then
			return
		end

		local success, deserialized = LibSerialize:Deserialize(decompressed);
		if (not success) then
			return
		end

		if not NameplateAurasAceDB.profiles[Profile] then
			NameplateAurasAceDB.profiles[Profile] = {}
		end

		for k,v in pairs(deserialized) do
			NameplateAurasAceDB.profiles[Profile][k] = v
		end

		for key in pairs(NameplateAurasAceDB.profiles[Profile]) do
			if (deserialized[key] == nil) then
				NameplateAurasAceDB.profiles[Profile][key] = nil;
			end
		end
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
	local PS_VERSION = "OmniCD2"

	if import then
		local function Decode(encodedData)
			local compressedData = LibDeflate:DecodeForPrint(encodedData)
			if not compressedData then
				return
			end
		
			local serializedData = LibDeflate:DecompressDeflate(compressedData)
			if not serializedData then
				return
			end
		
			local appendage
			serializedData = gsub(serializedData, "%^%^(.+)", function(str)
				appendage = str
				return "^^"
			end)
		
			if not appendage or not strfind(appendage, PS_VERSION) then
				return
			end
		
			appendage = gsub(appendage, "^" .. PS_VERSION, "")
			local profileType, profileKey = strsplit(",", appendage, 2)
		
			local success, profileData = LibSerialize:Deserialize(serializedData)
			if not success then
				print("test")
				return
			end
		
			return profileType, profileKey, profileData
		end

		local profileType, profileKey, profileData = Decode(NUI.OmniCDData)
		if not profileData then
			return
		end

		if not OmniCDDB.profiles[Profile] then
			OmniCDDB.profiles[Profile] = {}
		end

		OmniCDDB.profiles[Profile] = profileData



		SetupComplete(addon)
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