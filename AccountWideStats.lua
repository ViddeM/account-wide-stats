-- Namespace
local ADDON_NAME, core = ...;

function core:GetStatCategories()
    local categories = GetStatisticsCategoryList()
    topLevelCategories = {};
    remainder = {};
    rest = 0;
    for i = 1, #categories do 
        local categoryID = categories[i];
        local key, parent = GetCategoryInfo(categoryID);
        if parent < 0 then
            topLevelCategories[categoryID] = {
                id = categoryID,
                name = key,
                children = {},
            }
        else
            remainder[rest] = {
                id = categoryID,
                name = key,
                parent = parent
            }
            rest = rest + 1;
        end
    end

    for key, val in pairs(remainder) do
        topLevelCategories[val.parent].children[val.id] = {
            id = val.id,
            name = val.name
        }
    end

    return topLevelCategories, categories
end

local function ShowStats()
    local categories = core.DB:LoadStats();
    core.GUI:ShowStatCategories(categories);
end

-- Register slash event
SLASH_STATS1 = "/stats"
SlashCmdList["STATS"] = ShowStats;

-- Init
function core:init(eventName, addonName, ...)
    if addonName ~= ADDON_NAME then
        return
    end
    -- Save stats to accountDB
    core.DB:SaveStats();
end

-- Register init
local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);
