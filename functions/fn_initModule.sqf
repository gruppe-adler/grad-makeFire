GRAD_makeFire_moduleRoot = [] call GRAD_makeFire_fnc_getModuleRoot;

GRAD_makeFire_treeRadius = [missionConfigFile >> "GRAD_makeFire" >> "treeRadius", "number", 40] call CBA_fnc_getConfigEntry;
GRAD_makeFire_buildTime = [missionConfigFile >> "GRAD_makeFire" >> "buildTime", "number", 15] call CBA_fnc_getConfigEntry;
GRAD_makeFire_upgradeTime = [missionConfigFile >> "GRAD_makeFire" >> "upgradeTime", "number", 15] call CBA_fnc_getConfigEntry;
GRAD_makeFire_addLeavesTime = [missionConfigFile >> "GRAD_makeFire" >> "addLeavesTime", "number", 10] call CBA_fnc_getConfigEntry;
GRAD_makeFire_burntimeSmall = [missionConfigFile >> "GRAD_makeFire" >> "burntimeSmall", "number", 180] call CBA_fnc_getConfigEntry;
GRAD_makeFire_burntimeBig = [missionConfigFile >> "GRAD_makeFire" >> "burntimeBig", "number", 300] call CBA_fnc_getConfigEntry;
GRAD_makeFire_burntimeLeaves = [missionConfigFile >> "GRAD_makeFire" >> "burntimeLeaves", "number", 30] call CBA_fnc_getConfigEntry;
GRAD_makeFire_canBuildDefault = ([missionConfigFile >> "GRAD_makeFire" >> "canBuildDefault", "number", 1] call CBA_fnc_getConfigEntry) == 1;

GRAD_makeFire_playerDist = [missionConfigFile >> "GRAD_makeFire" >> "playerDist", "number", 2] call CBA_fnc_getConfigEntry;
GRAD_makeFire_classSmall = [missionConfigFile >> "GRAD_makeFire" >> "classSmall", "text", "FirePlace_burning_F"] call CBA_fnc_getConfigEntry;
GRAD_makeFire_classBig = [missionConfigFile >> "GRAD_makeFire" >> "classBig", "text", "Campfire_burning_F"] call CBA_fnc_getConfigEntry;
GRAD_makeFire_actOffset = [missionConfigFile >> "GRAD_makeFire" >> "actOffset", "array", [0,0,0.2]] call CBA_fnc_getConfigEntry;
GRAD_makeFire_actDist = [missionConfigFile >> "GRAD_makeFire" >> "actDist", "number", 2.5] call CBA_fnc_getConfigEntry;


if (!hasInterface) exitWith {};

[{!isNull player}, {

    inGameUISetEventHandler ["Action", "_this call GRAD_makeFire_fnc_onUIEH"];
    [] call GRAD_makeFire_fnc_addInteractions;

}, []] call CBA_fnc_waitUntilAndExecute;
