-- Namespace
local ADDON_NAME, core = ...;

local vals = {
    scrollWidth = 200,
    windowWidth = 800,
    scrollHeight = 500,
    windowHeight = 360,
    buttonTopOffset = 10,
    buttonSpacing = 3,
    buttonHeight = 20
}

local function printCategory(prefix, id, name)
    local numStats = GetCategoryNumAchievements(id);
    print(prefix .. " - " .. name .. " (id: " .. id .. ") => " .. numStats .. " stats)");
end

local function GetStatCategories()
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

local function PrintStatCategories()
    local topLevelCategories, categories = GetStatCategories();
    print("Found " .. #categories .. " statistics categories");

    print("They are:");

    for key, val in pairs(topLevelCategories) do
        printCategory("\t", val.id, val.name);
        for c, child in pairs(val.children) do
            printCategory("\t\t", child.id, child.name);
        end
    end
end

local function printCategoryStats(id)
    local total = GetCategoryNumAchievements(id);
    for offset = 1, total do
        local achievementID, name = GetAchievementInfo(id, offset);
        local value = GetStatistic(achievementID);
        print(name .. " (id: " .. achievementID .. ") => " .. value);
    end
end

function CreateButton(point, relativeFrame, relativePoint, yOffset, text, width, height)
    local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
    btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
    btn:SetSize(width, height);
    btn:SetText(text);
    return btn;
end

function CreateMainButton(...)
    local btn = CreateButton(...);
    btn:SetNormalFontObject("GameFontNormal");
    btn:SetHighlightFontObject("GameFontHighlight");
    return btn;
end

function CreateSubButton(...)
    local btn = CreateButton(...)
    btn:SetNormalFontObject("GameFontHighlight");
    btn:SetHighlightFontObject("GameFontHighlight");
    return btn;
end

local function ToggleStatCategory(buttons, buttonCount, buttonsFrame, toggleID, scrollBar) 
    local count = 0;
    for i = 1, buttonCount, 1 do
        count = count + 1;
        local btn = buttons[i];
        
        local buttonOffset = vals.buttonTopOffset + (count - 1) * (vals.buttonHeight + vals.buttonSpacing);
        buttonOffset = buttonOffset * -1; -- Y decreases downwards 

        btn:ClearAllPoints();
        btn:SetPoint("CENTER", buttonsFrame, "TOP", 0, buttonOffset);

        btn.open = btn.id == toggleID and btn.open == false;

        for childIndex = 1, btn.childCount, 1 do
            local child = btn.children[childIndex];
            child:Show();

            if btn.open then
                count = count + 1;
                
                local childButtonOffset = vals.buttonTopOffset + (count - 1) * (vals.buttonHeight + vals.buttonSpacing);
                childButtonOffset = childButtonOffset * -1;
                
                child:ClearAllPoints();
                child:SetPoint("CENTER", buttonsFrame, "TOP", 0, childButtonOffset);
                child:Show();
            else
                child:Hide();
            end
        end
    end

    local totalChildHeight = vals.buttonTopOffset + count * (vals.buttonHeight + vals.buttonSpacing);
    if totalChildHeight <= vals.windowHeight then
        buttonsFrame:SetSize(vals.scrollWidth, totalChildHeight);
        scrollBar:Hide();
    end
end

local function ShowStatsForCategory(categoryID, categoryName, statsTexts, statsFrame, statsFrameWidth, scrollBar)
    local statCount = GetCategoryNumAchievements(categoryID);
    print("Category: " .. categoryName .. " -- " .. statCount);

    -- Fill it with the stats
    for offset = 1, statCount do
        local id, statName = GetAchievementInfo(categoryID, offset);
        local statVal, skip =  GetStatistic(id);
        print(statName .. " -- " .. statVal)

        if offset > statsTexts.count then 
            local obj = {
                name = statsFrame:CreateFontString(nil, "ARTWORK"),
                value = statsFrame:CreateFontString(nil, "ARTWORK")
            }

            local yOffset = -4 - (offset - 1) * (vals.buttonHeight + vals.buttonSpacing);

            obj.name:SetFontObject("GameFontHighlight");
            obj.name:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 0, yOffset);
            obj.name:SetText(statName);

            obj.value:SetFontObject("GameFontHighlight");
            obj.value:SetPoint("TOPRIGHT", statsFrame, "TOPRIGHT", -20, yOffset);
            obj.value:SetText(statVal);

            statsTexts[offset] = obj;
            statsTexts.count = statsTexts.count + 1;
        else
            statsTexts[offset].name:SetText(statName);
            statsTexts[offset].value:SetText(statVal);
        end

        statsTexts[offset].name:Show();
        statsTexts[offset].value:Show();
    end

    if statCount < statsTexts.count then
        for extra = statCount + 1, statsTexts.count do
            statsTexts[extra].name:Hide();
            statsTexts[extra].value:Hide();
            -- statsTexts[extra].name:SetText("");
            -- statsTexts[extra].value:SetText("");
        end
    end

    local totalStatsHeight = 4 + (statCount) * (vals.buttonHeight + vals.buttonSpacing);
    if totalStatsHeight <= vals.windowHeight then
        statsFrame:SetSize(statsFrameWidth, totalStatsHeight);
        scrollBar:Hide();
    end
end

local function ShowStatCategories()
    -- Main UI window
    local UIConfig = CreateFrame("Frame", "AccountWideStats", UIParent, "UIPanelDialogTemplate");
    UIConfig:SetSize(vals.windowWidth, vals.windowHeight);
    UIConfig:SetPoint("CENTER");

    -- Window title
    UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY");
    UIConfig.title:SetFontObject("GameFontHighlight");
    UIConfig.title:SetPoint("LEFT", AccountWideStatsTitleBG, "LEFT", 5, 0);
    UIConfig.title:SetText("Account Wide Stats");

    -- Setup scrollframe
    UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate");
    UIConfig.ScrollFrame:SetPoint("TOPLEFT", AccountWideStatsDialogBG, "TOPLEFT", 4, -8);
    UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", AccountWideStatsDialogBG, "BOTTOMLEFT", vals.scrollWidth + 25, 4);

    UIConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIConfig.ScrollFrame, "TOPLEFT", vals.scrollWidth + 10, -18);
    UIConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIConfig.ScrollFrame, "BOTTOMLEFT", vals.scrollWidth + 10, 18);

    -- Setup ChildFrame (scroll-window)
    local buttonsFrame = CreateFrame("Frame", nil, UIConfig.ScrollFrame);
    buttonsFrame:SetSize(vals.scrollWidth, vals.scrollHeight);
    UIConfig.ScrollFrame:SetScrollChild(buttonsFrame);

    local topLevelCategories = GetStatCategories();

    local count = 0;
    local buttonNamePrefix = "stat_button_";

    local buttons = {};


    -- Setup stats container
    local categoryWidthOffset = vals.scrollWidth + 25;
 
    -- Setup scrollframe
    UIConfig.StatsScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate");
    UIConfig.StatsScrollFrame:SetPoint("TOPLEFT", AccountWideStatsDialogBG, "TOPLEFT", vals.scrollWidth + 25, -8);
    UIConfig.StatsScrollFrame:SetPoint("BOTTOMRIGHT", AccountWideStatsDialogBG, "BOTTOMRIGHT", 0, 4);

    UIConfig.StatsScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIConfig.StatsScrollFrame, "TOPRIGHT", -14, -18);
    UIConfig.StatsScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIConfig.StatsScrollFrame, "BOTTOMRIGHT", -4, 18);

    -- Setup ChildFrame (scroll-window)
    local statsFrame = CreateFrame("Frame", nil, UIConfig.StatsScrollFrame);
    local statsFrameWidth = vals.windowWidth - categoryWidthOffset - 20;
    statsFrame:SetSize(statsFrameWidth, 100);
    UIConfig.StatsScrollFrame:SetScrollChild(statsFrame);
    UIConfig.StatsScrollFrame.ScrollBar:Hide();
    
    statsTexts = {
        count = 0
    };

    for key, val in pairs(topLevelCategories) do
        count = count + 1;

        topLevelCategories[key].open = false;

        -- Big category button
        local buttonId = buttonNamePrefix .. val.id;
        local buttonOffset = vals.buttonTopOffset + (count - 1) * (vals.buttonHeight + vals.buttonSpacing);
        buttonOffset = buttonOffset * -1; -- Y decreases downwards 

        buttons[count] = CreateMainButton("CENTER", buttonsFrame, "TOP", buttonOffset, val.name, vals.scrollWidth, vals.buttonHeight);
        buttons[count].id = buttonId;
        buttons[count].catID = val.id;
        buttons[count].catName = val.name;
        buttons[count].open = false;

        buttons[count].children = {}

        local childCount = 0;
        for c, child in pairs(val.children) do
            childCount = childCount + 1;
            local child_button_id = buttonNamePrefix .. child.id;

            local childButton = CreateSubButton("CENTER", buttonsFrame, "TOP", buttonOffset, child.name, vals.scrollWidth - 40, vals.buttonHeight);
            childButton.catID = child.id;
            childButton.catName = child.name;
            
            childButton:Hide();
            buttons[count].children[childCount] = childButton;
        end
        buttons[count].childCount = childCount;
    end

    -- Register button clicks
    for key, btn in pairs(buttons) do
        if btn.childCount == 0 then
            -- Register button to show stats for the category
            btn:SetScript("OnClick", function(...)
                ShowStatsForCategory(btn.catID, btn.catName, statsTexts, statsFrame, statsFrameWidth, UIConfig.StatsScrollFrame.ScrollBar);
            end)
        else
            -- Toggle open subcategories
            btn:SetScript("OnClick", function(...)
                ToggleStatCategory(buttons, count, buttonsFrame, btn.id, UIConfig.ScrollFrame.ScrollBar);
            end)

            -- Register button to show stats for the children.
            for n, child in pairs(btn.children) do
                child:SetScript("OnClick", function(...)
                    ShowStatsForCategory(child.catID, child.catName, statsTexts, statsFrame, statsFrameWidth, UIConfig.StatsScrollFrame.ScrollBar);                        
                end)
            end
        end
    end

    local totalChildHeight = vals.buttonTopOffset + count * (vals.buttonHeight + vals.buttonSpacing);
    if totalChildHeight <= vals.windowHeight then
        buttonsFrame:SetSize(vals.scrollWidth, totalChildHeight);
        UIConfig.ScrollFrame.ScrollBar:Hide();
    end
end

local function PrintStats(stat)
    if stat == nil or stat == "" then
        -- PrintStatCategories()
        ShowStatCategories()
    else
        -- printCategoryStats(tonumber(stat))
    end
end

-- Register slash event
SLASH_STATS1 = "/stats"
SlashCmdList["STATS"] = PrintStats;

-- Init
function core:init(evenName, addonName, ...)
    if addonName ~= ADDON_NAME then
        return
    end
    print ("AccountWideStats -- Loaded");
end

-- Register init
local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);