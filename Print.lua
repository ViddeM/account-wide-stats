local _, core = ...;
core.Print = {};

function core.Print:PrintCategory(prefix, id, name)
    local numStats = GetCategoryNumAchievements(id);
    print(prefix .. " - " .. name .. " (id: " .. id .. ") => " .. numStats .. " stats)");
end

function core.Print:PrintCategoryStats(id)
    local total = GetCategoryNumAchievements(id);
    for offset = 1, total do
        local achievementID, name = GetAchievementInfo(id, offset);
        local value = GetStatistic(achievementID);
        print(name .. " (id: " .. achievementID .. ") => " .. value);
    end
end

function core.Print:PrintStatCategories()
    local topLevelCategories, categories = core:GetStatCategories();
    print("Found " .. #categories .. " statistics categories");

    print("They are:");

    for _, val in pairs(topLevelCategories) do
        core.Print:PrintCategory("\t", val.id, val.name);
        for _, child in pairs(val.children) do
            core.Print:PrintCategory("\t\t", child.id, child.name);
        end
    end
end
