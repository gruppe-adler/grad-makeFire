//add leaves
_action = ["GRAD_makeFire_addLeaves", "Add leaves and grass", GRAD_makeFire_moduleRoot + "\data\leaves.paa", {[_this select 0] call GRAD_makeFire_fnc_addLeaves}, {inflamed (_this select 0)}] call ace_interact_menu_fnc_createAction;
[GRAD_makeFire_classSmall,0,["ACE_MainActions"],_action] call ace_interact_menu_fnc_addActionToClass;
[GRAD_makeFire_classBig,0,["ACE_MainActions"],_action] call ace_interact_menu_fnc_addActionToClass;

//inspect
_action = ["GRAD_makeFire_inspectFire", "Inspect fire", GRAD_makeFire_moduleRoot + "\data\inspect.paa", {[_this select 0] call GRAD_makeFire_fnc_inspectFire}, {!inflamed (_this select 0)}] call ace_interact_menu_fnc_createAction;
[GRAD_makeFire_classSmall,0,["ACE_MainActions"],_action] call ace_interact_menu_fnc_addActionToClass;
[GRAD_makeFire_classBig,0,["ACE_MainActions"],_action] call ace_interact_menu_fnc_addActionToClass;

//upgrade
_action = ["GRAD_makeFire_upgradeFire", "Add firewood", GRAD_makeFire_moduleRoot + "\data\wood.paa", {[_this select 0] call GRAD_makeFire_fnc_upgradeFire}, {inflamed (_this select 0)}] call ace_interact_menu_fnc_createAction;
[GRAD_makeFire_classSmall,0,["ACE_MainActions"],_action] call ace_interact_menu_fnc_addActionToClass;

//self
_action = ["GRAD_makeFire", "Make fire", GRAD_makeFire_moduleRoot + "\data\fire.paa", {[] call GRAD_makeFire_fnc_makeFire}, {player getVariable ["GRAD_makeFire_canBuild", GRAD_makeFire_canBuildDefault]}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions","ACE_Equipment"], _action] call ace_interact_menu_fnc_addActionToObject;
