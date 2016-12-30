params ["_fire"];
if (!hasInterface) exitWith {};
if (isNil "_fire") exitWith {};
if (isNull _fire) exitWith {};

//create smoke
[_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];

//add ACE-actions
[_fire,0,["GRAD_makeFire_mainAction","GRAD_makeFire_inspectFire"]] call ace_interact_menu_fnc_removeActionFromObject;

_action = ["GRAD_makeFire_mainAction", "Interactions", "", {}, {true}, {}, [], GRAD_makeFire_actOffset, GRAD_makeFire_actDist] call ace_interact_menu_fnc_createAction;
[_fire, 0, [], _action] call ace_interact_menu_fnc_addActionToObject;

_action = ["GRAD_makeFire_addLeaves", "Add Leaves and Grass", MAKEFIRE_ACTPIC_ADDLVS, {[_this select 0] spawn GRAD_makeFire_fnc_addLeaves}, {true}] call ace_interact_menu_fnc_createAction;
[_fire, 0, ["GRAD_makeFire_mainAction"], _action] call ace_interact_menu_fnc_addActionToObject;

if (typeOf _fire == GRAD_makeFire_classSmall) then {
    _action = ["GRAD_makeFire_upgradeFire", "Add Firewood", MAKEFIRE_ACTPIC_ADDWD, {[_this select 0] spawn GRAD_makeFire_fnc_upgradeFire}, {true}] call ace_interact_menu_fnc_createAction;
    [_fire, 0, ["GRAD_makeFire_mainAction"], _action] call ace_interact_menu_fnc_addActionToObject;
};
