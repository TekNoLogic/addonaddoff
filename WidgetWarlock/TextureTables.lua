
local lib = LibStub("WidgetWarlock-Alpha1", true)
if not lib.upgrading or lib.upgrading >= 1 then return end



-- The standard tooltip border
lib.TooltipBorderBG = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}


-- Option group box background
lib.GroupBoxBG = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
}
