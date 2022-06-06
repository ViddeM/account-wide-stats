local _, core = ...;
core.DB = {};
local DB = core.DB;

local function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function StatStringToNum(valString)
    if valString == "--" then
        return 0;
    end

    splitVal = Split(valString, " ");
    return tonumber(splitVal[1]);
end

local function SaveStatsForCategory(categoryID, characterName, categoryStats)
    local count = GetCategoryNumAchievements(categoryID);

    for offset = 1, count do
        local id = GetAchievementInfo(categoryID, offset);
        local valString = GetStatistic(id);
        local val = StatStringToNum(valString);
   
        if categoryStats[id] == nil then
            categoryStats[id] = {}
        end
        categoryStats[id][characterName] = val;
    end

    return categoryStats;
end

function DB:SaveStats()
    local name = UnitName("player");
    print("Saving stats for " .. name);

    if AccountDB == nil then
        AccountDB = {};
        AccountDB.stats = {};
    end

    local stats = AccountDB.stats;

    local categories = core:GetStatCategories();
    for id, cat in pairs(categories) do
        if stats[id] == nil then
            stats[id] = {}
        end
        categories[cat.id] = SaveStatsForCategory(cat.id, name, stats);

        for c, child in pairs(cat.children) do
            categories[child.id] = SaveStatsForCategory(child.id, name, stats);
        end
    end

    print("Done saving stats");
end

function DB:LoadStats()
    local stats = AccountDB.stats;
    local categories = {};
    for statId, chars in pairs(stats) do
        local statSum = 0;
        local statObj = {};
        for name, val in pairs(chars) do
            statSum = statSum + val;
            statObj[name] = val;
        end

        statObj.val = statSum;
        categories[statId] = statObj;
    end
    return categories;
end