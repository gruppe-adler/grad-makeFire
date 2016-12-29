params ["_fire"];
if (!hasInterface) exitWith {};
if (isNil "_fire") exitWith {};
if (isNull _fire) exitWith {};

[_fire, false] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];

[_fire,0,["GRAD_makeFire_mainAction","GRAD_makeFire_upgradeFire"]] call ace_interact_menu_fnc_removeActionFromObject;
[_fire,0,["GRAD_makeFire_mainAction","GRAD_makeFire_addLeaves"]] call ace_interact_menu_fnc_removeActionFromObject;

_action = ["GRAD_makeFire_mainAction", "Interactions", "", {}, {true}, {}, [], MAKEFIRE_ACTOFFSET, MAKEFIRE_ACTDIST] call ace_interact_menu_fnc_createAction;
[_fire, 0, [], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["GRAD_makeFire_inspectFire", "Inspect Fire", MAKEFIRE_ACTPIC_INSPECT, {[_this select 0] spawn GRAD_makeFire_fnc_inspectFire}, {true}] call ace_interact_menu_fnc_createAction;
[_fire, 0, ["GRAD_makeFire_mainAction"], _action] call ace_interact_menu_fnc_addActionToObject;
