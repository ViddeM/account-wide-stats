local _, core = ...;
core.DB = {};
local DB = core.DB;

-- Parse a statistic's displayed value into a number.
-- Money statistics (the Wealth category) are returned by GetStatistic as
-- coin-texture strings (gold/silver/copper icons). tonumber() on those returns
-- nil, and storing nil removes the table entry, so money stats aggregated to 0.
-- Detect and convert them to copper, and report isMoney so the UI can format
-- the value back into coins.
local function StatStringToNum(valString)
    if valString == nil then
        return 0, false;
    end

    if valString:find("|[Tt]") then
        local gold   = tonumber(valString:match("(%d+)%s*|[Tt][^|]-GoldIcon"))   or 0;
        local silver = tonumber(valString:match("(%d+)%s*|[Tt][^|]-SilverIcon")) or 0;
        local copper = tonumber(valString:match("(%d+)%s*|[Tt][^|]-CopperIcon")) or 0;
        return gold * 10000 + silver * 100 + copper, true;
    end

    return tonumber(valString) or 0, false;
end

local function SaveStatsForCategory(categoryID, characterName, categoryStats)
    local count = GetCategoryNumAchievements(categoryID);

    for offset = 1, count do
        local valString, _, id = GetStatistic(categoryID, offset);        
        local val = StatStringToNum(valString);
   
        if categoryStats[id] == nil then
            categoryStats[id] = {}
        end
        categoryStats[id][characterName] = val;

        if isMoney then
            AccountDB.moneyStats[id] = true;
        end
    end

    return categoryStats;
end

function DB:SaveStats()
    local name = UnitName("player");
    local realm = GetRealmName();
    print("Saving stats for " .. name .. "(" .. realm .. ")");

    if AccountDB == nil then
        AccountDB = {};
        AccountDB.stats = {};
        AccountDB.characters = {};
    end
    if AccountDB.moneyStats == nil then AccountDB.moneyStats = {}; end

    local stats = AccountDB.stats;
    local characters = AccountDB.characters;
    characters[name] = realm;

    local categories = core:GetStatCategories();
    for id, cat in pairs(categories) do
        if stats[id] == nil then
            stats[id] = {}
        end
        SaveStatsForCategory(cat.id, name, stats);

        for c, child in pairs(cat.children) do
            SaveStatsForCategory(child.id, name, stats);
        end
    end

    print("Done saving stats");
end

function DB:LoadDB()
    local characters = AccountDB.characters;
    local moneyStats = AccountDB.moneyStats or {};
    
    local stats = AccountDB.stats;
    local categories = {};
    for statId, chars in pairs(stats) do
        local statSum = 0;
        local statObj = {};
        statObj.chars = {};
        for name, val in pairs(chars) do
            statSum = statSum + val;
            statObj.chars[name] = val;
        end

        statObj.val = statSum;
        statObj.isMoney = moneyStats[statId] == true;
        categories[statId] = statObj;
    end

    return categories, characters;
end
