MYSQL_HOST	= "192.168.122.110"
MYSQL_PORT	= 3306
MYSQL_USER	= "exo_test_ingame"
MYSQL_PW	= "kmd1581adf%%f"
MYSQL_DB	= "vRP"
MYSQL_UNIX_SOCKET = "/var/run/mysqld/mysqld.sock"

API_URL = "http://v-roleplay.net/forum/wcf/lib/data/vrp/api/api.php?"
IS_TESTSERVER = getServerName():find("Script") ~= nil

SPAWN_LOCATION_DEFAULT = 0
SPAWN_LOCATION_JAIL = 1
SPAWN_LOCATION_GARAGE = 2

CheatSeverity = {Low = 1, Middle = 2, High = 3, Brutal = 4}

-- TODO: Change before release
MAX_JOB_LEVEL = 10
MAX_WEAPON_LEVEL = 10
MAX_VEHICLE_LEVEL = 10
MAX_SKIN_LEVEL = 10

Interiors = {
    -- Name -- Dimension ("Allocate" a block of dimensions)
    AmmuNation1 = 50000,
    AmmuNation2 = 50001,

}

SkillTreeKey = {
    EVIL_MAFIA = 1,
    EVIL_STREETGANG = 2,
    EVIL_BIKER = 3,
    EVIL_TURFING_MAFIA = 4,
    EVIL_TURFING_STREETGANG = 5,
    EVIL_TURFING_BIKER = 6,
    EVIL_WEAPON_TRADE_MAFIA = 7,
    EVIL_WEAPON_TRADE_STREETGANG = 8,
    EVIL_WEAPON_TRADE_BIKER = 9,
    EVIL_BLACKLIST_MAFIA = 10,
    EVIL_BLACKLIST_STREETGANG = 11,
    EVIL_BLACKLIST_BIKER = 12,
    EVIL_JAILBREAK_MAFIA = 13,
    EVIL_JAILBREAK_STREETGANG = 14,
    EVIL_JAILBREAK_BIKER = 15,
    EVIL_VEHICLE1_MAFIA = 16,
    EVIL_VEHICLE2_MAFIA = 17,
    EVIL_VEHICLE1_STREETGANG = 18,
    EVIL_VEHICLE2_STREETGANG = 19,
    EVIL_VEHICLE1_BIKER = 20,
    EVIL_VEHICLE2_BIKER = 21,
}
