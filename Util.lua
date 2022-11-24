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

function Util:getKeysSortedByValue(tbl, sortFunction)
    local keys = {};
    for key in pairs(tbl) do
        table.insert(keys, key);
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b]);
    end);

    return keys;
end

function Util:findLongestValue(tbl)
    local len = 0;
    for _, val in pairs(tbl) do
        local curr = string.len(tostring(val));
        print("Len: " .. len .. " curr: " .. curr .. " val? " .. val);
        if curr > len then
            len = curr;
        end
    end
    return len;
end

string.lpad = function(str, len)
    return str .. string.rep(' ', len - #str);
end