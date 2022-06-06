local _, core = ...;
core.Print = {};
local Printing = core.Print;

function Print:PrintCategory(prefix, id, name)
    local numStats = GetCategoryNumAchievements(id);
    print(prefix .. " - " .. name .. " (id: " .. id .. ") => " .. numStats .. " stats)");
end

function Print:PrintCategoryStats(id)
    local total = GetCategoryNumAchievements(id);
    for offset = 1, total do
        local achievementID, name = GetAchievementInfo(id, offset);
        local value = GetStatistic(achievementID);
        print(name .. " (id: " .. achievementID .. ") => " .. value);
    end
end

function Print:PrintStatCategories()
    local topLevelCategories, categories = GetStatCategories();
    print("Found " .. #categories .. " statistics categories");

    print("They are:");

    for key, val in pairs(topLevelCategories) do
        Print:PrintCategory("\t", val.id, val.name);
        for c, child in pairs(val.children) do
            Print:PrintCategory("\t\t", child.id, child.name);
        end
    end
end
