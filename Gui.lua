local _, core = ...;
core.GUI = {};
local GUI = core.GUI;

local vals = {
    scrollWidth = 200,
    windowWidth = 800,
    scrollHeight = 500,
    windowHeight = 360,
    buttonTopOffset = 10,
    buttonSpacing = 3,
    buttonHeight = 20
}

-- Displays the actual stats for the given category
function GUI:ShowStatsForCategory(categoryID, categoryName, statsTexts, statsFrame, statsFrameWidth, scrollBar, categories)
    local statCount = GetCategoryNumAchievements(categoryID);
    
    for offset = 1, statCount do
        local id, statName = GetAchievementInfo(categoryID, offset);
    
        if offset > statsTexts.count then
            -- We haven't yet created this many rows, create a new one
            local yOffset = - (offset - 1) * (vals.buttonHeight + vals.buttonSpacing);

            local row = CreateFrame("Frame", nil, statsFrame);
            row:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 0, yOffset);
            row:SetPoint("BOTTOMRIGHT", statsFrame, "TOPRIGHT", -20, yOffset - vals.buttonHeight);


            local obj = {
                name = statsFrame:CreateFontString(nil, "ARTWORK"),
                value = statsFrame:CreateFontString(nil, "ARTWORK"),
                row = row
            }
              

            obj.name:SetFontObject("GameFontHighlight");
            obj.name:SetPoint("LEFT", row, "LEFT");

            obj.value:SetFontObject("GameFontHighlight");
            obj.value:SetPoint("RIGHT", row, "RIGHT");
              
            obj.row:SetScript("OnLeave", function(self)
                GameTooltip:Hide();
            end)

            statsTexts[offset] = obj;
            statsTexts.count = statsTexts.count + 1;
        end

        -- Fill the row with texts
        statsTexts[offset].name:SetText(statName);
        statsTexts[offset].value:SetText(categories[id].val);

        -- Handle tooltip
        statsTexts[offset].row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddLine(statName .. ":");

            local chars = categories[id].chars;
            local sortedKeys = core.Util:getKeysSortedByValue(chars, function(a, b) return a > b; end);
           
            for _, name in ipairs(sortedKeys) do
                local val = chars[name];
                GameTooltip:AddLine(val .. " -- " .. name);         
            end

            GameTooltip:Show();
        end)

        statsTexts[offset].row:Show();
        statsTexts[offset].name:Show();
        statsTexts[offset].value:Show();    
    end

    if statCount < statsTexts.count then
        -- Hide any rows that we haven't updated
        for extra = statCount + 1, statsTexts.count do
            statsTexts[extra].row:Hide();
            statsTexts[extra].value:Hide();
            statsTexts[extra].name:Hide();
        end
    end

    -- Ensure that the scroll area isn't too big & hide scrollbar if necessary.
    local totalStatsHeight = 4 + (statCount) * (vals.buttonHeight + vals.buttonSpacing);
    if totalStatsHeight <= vals.windowHeight then
        statsFrame:SetSize(statsFrameWidth, totalStatsHeight);
        scrollBar:Hide();
    end
end

-- Loads and displays the stats categories that exist
function GUI:ShowStatCategories(categories)
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

    local topLevelCategories = core:GetStatCategories();

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

        buttons[count] = core.Util:CreateMainButton("CENTER", buttonsFrame, "TOP", buttonOffset, val.name, vals.scrollWidth, vals.buttonHeight);
        buttons[count].id = buttonId;
        buttons[count].catID = val.id;
        buttons[count].catName = val.name;
        buttons[count].open = false;

        buttons[count].children = {}

        local childCount = 0;
        for c, child in pairs(val.children) do
            childCount = childCount + 1;
            local child_button_id = buttonNamePrefix .. child.id;

            local childButton = core.Util:CreateSubButton("CENTER", buttonsFrame, "TOP", buttonOffset, child.name, vals.scrollWidth - 40, vals.buttonHeight);
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
                GUI:ShowStatsForCategory(btn.catID, btn.catName, statsTexts, statsFrame, statsFrameWidth, UIConfig.StatsScrollFrame.ScrollBar, categories);
            end)
        else
            -- Toggle open subcategories
            btn:SetScript("OnClick", function(...)
                GUI:ToggleStatCategory(buttons, count, buttonsFrame, btn.id, UIConfig.ScrollFrame.ScrollBar);
            end)

            -- Register button to show stats for the children.
            for n, child in pairs(btn.children) do
                child:SetScript("OnClick", function(...)
                    GUI:ShowStatsForCategory(child.catID, child.catName, statsTexts, statsFrame, statsFrameWidth, UIConfig.StatsScrollFrame.ScrollBar, categories);                        
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

-- Toggle a stat category open or closed (dropdown)
function GUI:ToggleStatCategory(buttons, buttonCount, buttonsFrame, toggleID, scrollBar) 
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