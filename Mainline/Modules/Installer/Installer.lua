local NUI = unpack(NaowhUI)
local I = NUI:GetModule("Installer")
local SE = NUI:GetModule("Setup")

I.Installer = {
	Title = format("%s %s", NUI.title, "Installation"),
	Name = NUI.title,
	tutorialImage = "Interface\\AddOns\\NaowhUI\\Core\\Media\\Textures\\NaowhUILogo.tga",
	Pages = {
		[1] = function()
			if not NUI.db.global.profiles then
				PluginInstallFrame.SubTitle:SetFormattedText("Welcome to %s", NUI.title)
				PluginInstallFrame.Desc1:SetText("To get started with the installation process, click on 'Continue'.\nTo skip the installation process and hide this frame, click on 'Skip Process'.")
				PluginInstallFrame.Desc2:SetText("You can skip the setup of profiles you do not want by clicking on 'Continue' without setting them up.")
				PluginInstallFrame.Option1:Show()
				PluginInstallFrame.Option1:SetScript("OnClick", function() NUI:InstallComplete(true) end)
				PluginInstallFrame.Option1:SetText("Skip Process")

				return
			end

			PluginInstallFrame.SubTitle:SetFormattedText("Welcome to %s", NUI.title)
			PluginInstallFrame.Desc1:SetText("To load your selected NaowhUI profiles onto this character, click on 'Load Profiles'.")
			PluginInstallFrame.Desc2:SetText("To run the installation process again, click on 'Continue'.\nTo skip the installation process and hide this frame, click on 'Skip Process'.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NUI:LoadProfiles() end)
			PluginInstallFrame.Option1:SetText("Load Profiles")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() NUI:InstallComplete(true) end)
			PluginInstallFrame.Option2:SetText("Skip Process")
		end,
		[2] = function()
			PluginInstallFrame.SubTitle:SetText("ElvUI")
			PluginInstallFrame.Desc1:SetText("Click on the button below representing the ElvUI scale of your choice.")
			PluginInstallFrame.Desc2:SetText("Recommendation: 0.71 for 1080p, 0.62 for 1440p and 2160p.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("ElvUI", true, 0.5333333333333333) end)
			PluginInstallFrame.Option1:SetText("0.53")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() SE:Setup("ElvUI", true, 0.6222222222222222) end)
			PluginInstallFrame.Option2:SetText("0.62")
			PluginInstallFrame.Option3:Show()
			PluginInstallFrame.Option3:SetScript("OnClick", function() SE:Setup("ElvUI", true, 0.7111111111111111) end)
			PluginInstallFrame.Option3:SetText("0.71")
		end,
		[3] = function()
			if not NUI:IsAddOnEnabled("BigWigs") then
				PluginInstallFrame.SubTitle:SetText("BigWigs is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("BigWigs")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's BigWigs profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("BigWigs", true) end)
			PluginInstallFrame.Option1:SetText("Setup BigWigs")
		end,
		[4] = function()
			if not NUI:IsAddOnEnabled("Details") then
				PluginInstallFrame.SubTitle:SetText("Details is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("Details")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's Details profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("Details", true) end)
			PluginInstallFrame.Option1:SetText("Setup Details")
		end,
		[5] = function()
			if not NUI:IsAddOnEnabled("HidingBar") then
				PluginInstallFrame.SubTitle:SetText("HidingBar is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("HidingBar")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's HidingBar profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("HidingBar") end)
			PluginInstallFrame.Option1:SetText("Setup HidingBar")
		end,
		[6] = function()
			if not NUI:IsAddOnEnabled("MRT") then
				PluginInstallFrame.SubTitle:SetText("MRT is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("MRT")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's MRT profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("MRT", true) end)
			PluginInstallFrame.Option1:SetText("Setup MRT")
		end,
		[7] = function()
			if not NUI:IsAddOnEnabled("NameplateAuras") then
				PluginInstallFrame.SubTitle:SetText("NameplateAuras is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("NameplateAuras")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's NameplateAuras profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("NameplateAuras", true) end )
			PluginInstallFrame.Option1:SetText("Setup NameplateAuras")
		end,
		[8] = function()
			if not NUI:IsAddOnEnabled("OmniCD") then
				PluginInstallFrame.SubTitle:SetText("OmniCD is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("OmniCD")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's OmniCD profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("OmniCD", true) end)
			PluginInstallFrame.Option1:SetText("Setup OmniCD")
		end,
		[9] = function()
			if not NUI:IsAddOnEnabled("Plater") then
				PluginInstallFrame.SubTitle:SetText("Plater is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("Plater")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's Plater profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("Plater", true) end)
			PluginInstallFrame.Option1:SetText("Setup Plater")
		end,
		[10] = function()
			if not NUI:IsAddOnEnabled("WarpDeplete") then
				PluginInstallFrame.SubTitle:SetText("WarpDeplete is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("WarpDeplete")
			PluginInstallFrame.Desc1:SetText("Click on the button below to setup Naowh's WarpDeplete profile.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SE:Setup("WarpDeplete", true) end)
			PluginInstallFrame.Option1:SetText("Setup WarpDeplete")
		end,
		[11] = function()
			if not NUI:IsAddOnEnabled("WeakAuras") then
				PluginInstallFrame.SubTitle:SetText("WeakAuras is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("General WeakAuras")
			PluginInstallFrame.Desc1:SetText("Click on the buttons below representing the WeakAuras of your choice.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function()
				NUI:LoadData()
				NUI:ImportWeakAura(PluginInstallFrame, "HIGH", NUI.CoreData)
			end)
			PluginInstallFrame.Option1:SetText("Core")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function()
				NUI:LoadData()
				NUI:ImportWeakAura(PluginInstallFrame, "HIGH", NUI.RaidData)
			end)
			PluginInstallFrame.Option2:SetText("Raid")
			PluginInstallFrame.Option3:Show()
			PluginInstallFrame.Option3:SetScript("OnClick", function()
				NUI:LoadData()
				NUI:ImportWeakAura(PluginInstallFrame, "HIGH", NUI.Season1Data)
			end)
			PluginInstallFrame.Option3:SetText("Season 1")
		end,
		[12] = function()
			if not NUI:IsAddOnEnabled("WeakAuras") then
				PluginInstallFrame.SubTitle:SetText("WeakAuras is not enabled, enable it to unlock this step.")

				return
			end

			PluginInstallFrame.SubTitle:SetText("Class WeakAuras")
			PluginInstallFrame.Desc1:SetText("Click on the button below to select your Class WeakAuras.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NUI:OpenToCategory() end)
			PluginInstallFrame.Option1:SetText("Open Settings")
		end,
		[13] = function()
			PluginInstallFrame.SubTitle:SetText("Installation Complete")
			PluginInstallFrame.Desc1:SetText("You have completed the installation process.")
			PluginInstallFrame.Desc2:SetText("Please click on the button below to reload your UI.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() NUI:InstallComplete(true) end)
			PluginInstallFrame.Option1:SetText("Finished")
		end,
	},
	StepTitles = {
		[1] = "Welcome",
		[2] = "ElvUI",
		[3] = "BigWigs",
		[4] = "Details",
		[5] = "HidingBar",
		[6] = "MRT",
		[7] = "NameplateAuras",
		[8] = "OmniCD",
		[9] = "Plater",
		[10] = "WarpDeplete",
		[11] = "General WeakAuras",
		[12] = "Class WeakAuras",
		[13] = "Installation Complete",
	},
	StepTitlesColor = {1, 1, 1},
	StepTitlesColorSelected = {0, 179/255, 1},
	StepTitleWidth = 200,
	StepTitleButtonWidth = 180,
	StepTitleTextJustification = "RIGHT",
}