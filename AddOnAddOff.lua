
local OptionHouse = LibStub("OptionHouse-1.1"))
local ww = LibStub("WidgetWarlock-Alpha1")


------------------------------
--      Initialization      --
------------------------------

AddOnAddOff = DongleStub("Dongle-1.0"):New("AddOnAddOff")
if tekDebug then AddOnAddOff:EnableDebug(1, tekDebug:GetFrame("AddOnAddOff")) end


function AddOnAddOff:Initialize()
	self.db = self:InitializeDB("AddOnAddOffDB")
end


function AddOnAddOff:Enable()
	local _, title = GetAddOnInfo("AddOnAddOff")
	local author, version = GetAddOnMetadata("AddOnAddOff", "Author"), GetAddOnMetadata("AddOnAddOff", "Version")
	local oh = OptionHouse:RegisterAddOn("AddOn AddOff", title, author, version)
	oh:RegisterCategory("Main", self, "CreateOHFrame")
end


---------------------------
--      OptionHouse      --
---------------------------


function AddOnAddOff:CreateOHFrame()
	frame = CreateFrame("Frame", nil, UIParent)

	local currentgroup = ww:SummonGroupBox(frame, 310, 105, "TOPLEFT", 5, -20)
	local currentlabel = ww:SummonFontString(currentgroup, "OVERLAY", "GameFontNormal", "Current profile:", "TOPLEFT", 10, 15)
	local current = ww:SummonFontString(frame, "OVERLAY", "GameFontHighlight", self.db:GetCurrentProfile(), "LEFT", currentlabel, "RIGHT", 10, 0)

--~ 	local resetbutton = ww:SummonButton(frame, "RESET", nil, nil, "TOPLEFT", currentlabel, "BOTTOMLEFT", 0, -10)

	local enabled = ww:SummonFontString(frame, "OVERLAY", "GameFontNormal", nil, "TOPRIGHT", -10, -5)
	local UpdateEnabled = function()
		local c = 0
		for i,v in pairs(self.db.profile) do if v then c = c + 1 end end
		enabled:SetText(string.format("Addon profile: %d of %d addons enabled", c, GetNumAddOns()))
	end
	UpdateEnabled()

	local profiles = self.db:GetProfiles()

	local selected = CreateFrame("Frame", "AddOnAddOffProfileMenu", currentgroup, "UIDropDownMenuTemplate")
	local loadbutton = ww:SummonButton(currentgroup, "Load", nil, nil, "TOPLEFT", selected, "BOTTOMLEFT", 15, -5)
	local copybutton = ww:SummonButton(currentgroup, "Copy", nil, nil, "LEFT", loadbutton, "RIGHT", 10, 0)
	local deletebutton = ww:SummonButton(currentgroup, "Delete", nil, nil, "LEFT", copybutton, "RIGHT", 10, 0)

	selected:SetPoint("TOPLEFT", -5, -10)
	AddOnAddOffProfileMenuMiddle:SetWidth(250)

	local function ToggleButtons(value)
		if value == self.db:GetCurrentProfile() then
			loadbutton:Disable()
			copybutton:Disable()
			deletebutton:Disable()
		else
			loadbutton:Enable()
			copybutton:Enable()
			deletebutton:Enable()
		end
	end

	local function DropdownClick()
		UIDropDownMenu_SetSelectedValue(AddOnAddOffProfileMenu, this.value)
		ToggleButtons(this.value)
	end

	local ddt = {func = DropdownClick}
	local function DropdownInit()
		local current = self.db:GetCurrentProfile()
		for i,v in ipairs(profiles) do
			ddt.checked = false
			ddt.text = v
			ddt.value = v
			ddt.disabled = v == current
			UIDropDownMenu_AddButton(ddt)
		end
	end

	selected:SetScript("OnShow", function(self)
		UIDropDownMenu_Initialize(self, DropdownInit)
		UIDropDownMenu_SetSelectedValue(selected, profiles[1])
		ToggleButtons(profiles[1])
	end)

	loadbutton:SetScript("OnClick", function()
		local profile = UIDropDownMenu_GetSelectedValue(selected)
		self.db:SetProfile(profile)
		current:SetText(profile)
		ToggleButtons(profile)
		UpdateEnabled()
	end)
	copybutton:SetScript("OnClick", function()
		self.db:ResetProfile()
		self.db:CopyProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = self.db:GetProfiles()
		UpdateEnabled()
	end)
	deletebutton:SetScript("OnClick", function()
		self.db:DeleteProfile(UIDropDownMenu_GetSelectedValue(selected))
		profiles = self.db:GetProfiles()
		UIDropDownMenu_SetSelectedValue(selected, profiles[1])
		ToggleButtons(profiles[1])
	end)

	local createname = ww:SummonEditBox(currentgroup, 187, "TOPLEFT", loadbutton, "BOTTOMLEFT", 8, 1)
	local createbutton = ww:SummonButton(currentgroup, "Create", nil, nil, "LEFT", createname, "RIGHT", 5, -1)
	createbutton:Disable()
	createname:SetScript("OnTextChanged", function(frame) if frame:GetText() ~= "" then createbutton:Enable() else createbutton:Disable() end end)
	createbutton:SetScript("OnClick", function()
		local profile = createname:GetText()
		if profile ~= "" then
			self.db:SetProfile(profile)
			current:SetText(profile)
			profiles = self.db:GetProfiles()
			createname:SetText("")
			createname:ClearFocus()
			createbutton:Disable()
			ToggleButtons("")
			UpdateEnabled()
		end
	end)



	local savebutton = ww:SummonButton(frame, "Store", nil, nil, "BOTTOMLEFT", 10, 15)
	savebutton:SetScript("OnClick", function()
		self.db:ResetProfile()

		for i=1,GetNumAddOns() do
			local name, _, _, enabled = GetAddOnInfo(i)
			self.db.profile[name] = not not enabled -- Look silly, but it ensures I have a true/false and no nils
			self:Debug(1, name, enabled)
		end

		UpdateEnabled()
	end)

	local loadbutton = ww:SummonButton(frame, "Apply", nil, nil, "LEFT", savebutton, "RIGHT", 10, 0)
	loadbutton:SetScript("OnClick", function()
		for i=1,GetNumAddOns() do
			if not self.db.profile[GetAddOnInfo(i)] then DisableAddOn(i) else EnableAddOn(i) end
		end
	end)

	ww:EnslaveTooltip(copybutton, "Copy the selected profile into your current profile.")
	ww:EnslaveTooltip(savebutton, "Stores your current addon configuration.\nThis does not automatically happen when addons are enabled or disabled!")
	ww:EnslaveTooltip(loadbutton, "Apply the current addon profile.\nThis does not automatically happen when a new profile is loaded!")

	frame:SetScript("OnShow", function(frame)
		ww.FadeIn(frame, 0.5)
		profiles = self.db:GetProfiles()
	end)

	return frame
end

