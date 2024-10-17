local NUI = unpack(NaowhUI)
local SC = NUI:GetModule("Scaling")

local ScalingTable = {}

function ScalingTable.ElvUI(scale)
	local E = unpack(ElvUI)
	local UIScale = scale or E.data.global.general.UIScale
	local DefaultScale = 0.7111111111111111
	local UIParent = UIParent
	local xResNew
	local yResNew
	local Profile = "Naowh"
	local UnscaledMovers = {
		["AlertFrameMover"] = true,
		["AltPowerBarMover"] = true,
		["BossButton"] = true,
		["BossHeaderMover"] = true,
		["ElvAB_2"] = true,
		["ElvAB_3"] = true,
		["ElvAB_4"] = true,
		["ElvAB_5"] = true,
		["ElvAB_6"] = true,
		["ElvUF_FocusMover"] = true,
		["ElvUF_PartyMover"] = true,
		["ElvUF_PetMover"] = true,
		["ElvUF_PlayerMover"] = true,
		["ElvUF_Raid1Mover"] = true,
		["ElvUF_Raid2Mover"] = true,
		["ElvUF_Raid3Mover"] = true,
		["ElvUF_TargetMover"] = true,
		["ElvUF_TargetTargetMover"] = true,
		["LossControlMover"] = true,
		["LootFrameMover"] = true,
		["ObjectiveFrameMover"] = true,
		["TargetPowerBarMover"] = true,
		["VehicleLeaveButton"] = true,
		["ZoneAbility"] = true
	}
	local anchorMods = {
		["BOTTOM"] = {
			["anchorModX"] = 0,
			["anchorModY"] = 1 / 2
		},
		["BOTTOMLEFT"] = {
			["anchorModX"] = 1 / 2,
			["anchorModY"] = 1 / 2
		},
		["BOTTOMRIGHT"] = {
			["anchorModX"] = -1 / 2,
			["anchorModY"] = 1 / 2
		},
		["TOP"] = {
			["anchorModX"] = 0,
			["anchorModY"] = -1 / 2
		},
		["TOPLEFT"] = {
			["anchorModX"] = 1 / 2,
			["anchorModY"] = -1 / 2
		},
		["TOPRIGHT"] = {
			["anchorModX"] = -1 / 2,
			["anchorModY"] = -1 / 2
		}
	}
	local xResOld = 768 / DefaultScale / 9 * 16
	local yResOld = 768 / DefaultScale
	local tostring = tostring
	local ScaledMovers = {}

	if UIScale == DefaultScale then
		UIParent:SetScale(UIScale)

		E.data.global.general.UIScale = UIScale

		return
	end

	UIParent:SetScale(UIScale)

	xResNew, yResNew = UIParent:GetSize()

	for k, v in pairs(E.data.profiles[Profile].movers) do
		local Strings = {}

		for e in string.gmatch(v, "[^,]+") do
			tinsert(Strings, e)
		end

		if UnscaledMovers[k] then
			local anchorModX = anchorMods[Strings[1]].anchorModX
			local NewX = Strings[4] - (xResOld * anchorModX) + (xResNew * anchorModX)
			local anchorModY = anchorMods[Strings[1]].anchorModY
			local NewY = Strings[5] - (yResOld * anchorModY) + (yResNew * anchorModY)

			ScaledMovers[k] = Strings[1] .. "," .. Strings[2] .. "," .. Strings[3] .. "," .. tostring(NewX) .. "," .. tostring(NewY)
		else
			ScaledMovers[k] = v
		end
	end

	E.data.global.general.UIScale = UIScale
	E.data.profiles[Profile].movers = ScaledMovers
	NUI.ReloadRequired = true
end

function SC:Scale(addon, scale)
	local ScalingFunction = ScalingTable[addon]

	ScalingFunction(scale)
end