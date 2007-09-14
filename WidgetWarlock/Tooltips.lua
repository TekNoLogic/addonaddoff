
local lib = LibStub("WidgetWarlock-Alpha1", true)
if not lib.upgrading then return end



local tipvalues, tipanchors = {}, {}
local GameTooltip = GameTooltip

local function HideTooltip() GameTooltip:Hide() end


local function ShowTooltip(self)
	local text = type(tipvalues[self]) == "function" and tipvalues[self]() or tipvalues[self]
	GameTooltip:SetOwner(self, tipanchors[self])
	GameTooltip:SetText(text)
end


function lib:EnslaveTooltip(frame, text, anchor)
	assert(frame, "Must pass a frame")

	if not text then
		frame:SetScript("OnEnter", nil)
		frame:SetScript("OnLeave", nil)
	else
		frame:SetScript("OnEnter", ShowTooltip)
		frame:SetScript("OnLeave", HideTooltip)
		tipvalues[frame] = text
		tipanchors[frame] = anchor or "ANCHOR_RIGHT"
	end
end
