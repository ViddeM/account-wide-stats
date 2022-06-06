local _, core = ...;
core.Util = {};
local Util = core.Util;

function Util:CreateButton(point, relativeFrame, relativePoint, yOffset, text, width, height)
    local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
    btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
    btn:SetSize(width, height);
    btn:SetText(text);
    return btn;
end

function Util:CreateMainButton(...)
    local btn = Util:CreateButton(...);
    btn:SetNormalFontObject("GameFontNormal");
    btn:SetHighlightFontObject("GameFontHighlight");
    return btn;
end

function Util:CreateSubButton(...)
    local btn = Util:CreateButton(...)
    btn:SetNormalFontObject("GameFontHighlight");
    btn:SetHighlightFontObject("GameFontHighlight");
    return btn;
end