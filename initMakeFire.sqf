/*  Initiates GRAD fire making system
*
*   needs to be executed on both server and clients
*/

#define TREERADIUS 15                                 //distance player-->trees in order to be able to start fire
#define MAKEFIRETIME 5                               //time it takes to make the fire
#define UPGRADEFIRETIME 5                            //time it takes to upgrade fire
#define ADDLEAVESTIME 5                              //time it takes to add leaves to the fire
#define FIREDISTANCETOPLAYER 2                        //distance to player that the fire object will be spawned
#define CLASS_SMALLFIRE "FirePlace_burning_F"         //small fire classname
#define CLASS_BIGFIRE "Campfire_burning_F"            //big fire classname
#define ACTION_PIC_MAKEFIRE "pic\fire.paa"            //"make fire" action picture path
#define ACTION_PIC_ADDLEAVES "pic\leaves.paa"         //"add leaves to fire" action picture path
#define ACTION_PIC_ADDFIREWOOD "pic\wood.paa"         //"add firewood to fire" action picture path
#define ACTION_PIC_INSPECTFIRE "pic\inspect.paa"      //"inspect fire" action pictre path
#define ACTION_OFFSET [0,0,2.0]                       //interaction point offset from model center
#define ACTION_DISTANCE 2.5                           //distance from which interaction point can be accessed
#define BURNTIME_SMALLFIRE 60                        //time that a small fire will burn
#define BURNTIME_BIGFIRE 90                          //time that a big fire will burn
#define BURNTIME_LEAVES 20                           //time that adding leaves will add to total burntime



#define ISPUBLIC true
//ADD UI EH ====================================================================
if (hasInterface) then {
  inGameUISetEventHandler ["Action", "_this call GRAD_makeFire_fnc_onUIEH"];
};

//ADD ACE-SELFACTION ===========================================================
_action_makeFire = ["GRAD_makeFire", "Make fire", ACTION_PIC_MAKEFIRE, {[] spawn GRAD_makeFire_fnc_makeFire}, {true}] call ace_interact_menu_fnc_createAction;
[ player, 1, ["ACE_SelfActions"], _action_makeFire] call ace_interact_menu_fnc_addActionToObject;


//ON UI EH  ====================================================================
//[8249c100# 1675113: fireplace_f.p3d,B Alpha 1-1:1 (McDiod),5,"FirePutDown","Put out fire",0.99,true,true,"",true,"Action"]
GRAD_makeFire_fnc_onUIEH = {
  params ["_fire", "_caller", "_actionID", "_actionName"];

  if (_actionName == "FirePutDown") then {
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnedOut", 0, true];
    _fire setVariable ["burnedOutTime", serverTime, ISPUBLIC];
  };

  if (_actionName == "FireInFlame") then {
    if (_fire getVariable ["burnedOut", false]) exitWith {hint "Es ist komplett heruntergebrannt."; [_fire] spawn {_fire = _this select 0; waitUntil {inflamed (_fire)}; _fire inflame false}};

    [_fire] remoteExec ["GRAD_makeFire_fnc_initFireClient", 0, true];
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnOutTimer", 2, false];
    _fire setVariable ["burnedOutTime", -1, ISPUBLIC];
  };
};

//FUNCTIONS ================================================================================================================================================
//CREATE SMOKE (local) =========================================================
C9J_fnc_createSmokeColumn = compile preprocessFileLineNumbers "player\fn_createSmokeColumn.sqf";

//Killzone Kid's CHECK UNIT IN HOUSE ===========================================
KK_fnc_inHouse = {
  params ["_unit"];
    lineIntersectsSurfaces [
        getPosWorld _unit,
        getPosWorld _unit vectorAdd [0, 0, 50],
        _unit, objNull, true, 1, "GEOM", "NONE"
    ] select 0 params ["","","","_house"];
    if (isNil "_house") exitWith {false};
    if (_house isKindOf "House") exitWith {true};
    false
};

//MAKE FIRE ====================================================================
GRAD_makeFire_fnc_makeFire = {
  //check position
  if (isOnRoad player) exitWith {hint "Ich kann auf der Straße kein Feuer machen."};
  if (surfaceIsWater getPos player) exitWith {hint "Ich kann im Wasser kein Feuer machen."};
  if ([player] call KK_fnc_inHouse) exitWith {hint "Ich kann in einem Gebäude kein Feuer machen."};

  //check if trees nearby
  _treesNearby = (((selectBestPlaces [getpos player, TREERADIUS, "trees", 0.5, 1]) select 0) select 1) > 0.2;
  if (!_treesNearby) exitWith {hint "Es ist kein Feuerholz in der Nähe."};

  //progressbar
  _onComplete = {
    _params = _this select 0;
    _firePos = player getRelPos [FIREDISTANCETOPLAYER, 0];
    [_firePos] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
  };
  [MAKEFIRETIME, [], _onComplete, {hint "abgebrochen"}, "Feuer machen"] call ace_common_fnc_progressBar;
};

//UPGRADE FIRE =================================================================
GRAD_makeFire_fnc_upgradeFire = {
  params ["_fire"];

  _onComplete = {
    _params = _this select 0;
    _fire = _params select 0;
    [_fire] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
  };
  [UPGRADEFIRETIME, [_fire], _onComplete, {hint "abgebrochen"}, "Feuerholz sammeln"] call ace_common_fnc_progressBar;
};

//ADD LEAVES ===================================================================
GRAD_makeFire_fnc_addLeaves = {
params ["_fire"];
_leavesAmount = _fire getVariable ["leavesAmount", 100];
if (_leavesAmount >= 2) exitWith {hint "Das Feuer geht aus, wenn ich noch mehr Blätter drauflege."};

 _onComplete = {
    _params = _this select 0;
    _fire = _params select 0;

    _leavesAmount = _fire getVariable ["leavesAmount", 100];
    if (_leavesAmount >= 2) exitWith {hint "Jemand war schneller als ich."};

    _fire setVariable ["leavesAmount", (_fire getVariable ["leavesAmount", 0]) + 1, ISPUBLIC];
    [_fire, BURNTIME_LEAVES] remoteExec ["GRAD_makeFire_fnc_addBurnTime", 2, false];
    [_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
  };
  [ADDLEAVESTIME, [_fire], _onComplete, {hint "abgebrochen"}, "Blätter und Gras sammeln"] call ace_common_fnc_progressBar;
};

//CREATE SMOKE =================================================================
GRAD_makeFire_fnc_createSmoke = {
  params ["_fire", "_isBurning"];
  if (!hasInterface) exitWith {};
  if (isNil "_fire") exitWith {};
  if (isNull _fire) exitWith {};

  _particleSources = [];
  _oldParticleSources = _fire getVariable ["particleSources", []];
  {
    deleteVehicle _x;
  } forEach _oldParticleSources;

  //dont create new sources if fire is out
  if (!_isBurning) exitWith {};

  _leavesAmount = _fire getVariable ["leavesAmount", 0];
  //big fire
  if (typeOf _fire == CLASS_BIGFIRE) then {
    switch (_leavesAmount) do {
      case 0: {};
      case 1: {_particleSources = [_fire, "wood", "large"] call C9J_fnc_createSmokeColumn};
      case 2: {_particleSources = [_fire, "wood", "superlarge"] call C9J_fnc_createSmokeColumn};
      default {_particleSources = [_fire, "wood", "superlarge"] call C9J_fnc_createSmokeColumn};
    };

  //small fire
  } else {
    switch (_leavesAmount) do {
      case 0: {};
      case 1: {_particleSources = [_fire, "wood", "small"] call C9J_fnc_createSmokeColumn};
      case 2: {_particleSources = [_fire, "wood", "medium"] call C9J_fnc_createSmokeColumn};
      default {_particleSources = [_fire, "wood", "medium"] call C9J_fnc_createSmokeColumn};
    };
  };

  _fire setVariable ["particleSources", _particleSources];
};

//INSPECT FIRE =================================================================
GRAD_makeFire_fnc_inspectFire = {
  params ["_fire"];
  private ["_reason", "_state"];
  if (inflamed _fire) exitWith {hint "Das Feuer brennt."};
  if (_fire getVariable ["burnedOut", false]) then {
    _reason = "Das Feuer ist heruntergebrannt.";
  } else {
    _reason = "Jemand hat das Feuer gelöscht.";
  };

  _timeSince = serverTime - (_fire getVariable ["burnedOutTime", 0]);
  _timeSince = _timeSince + ((random 120) - 60);
  switch (true) do {
    case (_timeSince < 60): {_state = "Die Kohlen glühen noch hell. Die Luft flimmert."};
    case (_timeSince < 120): {_state = "Die Kohlen glühen noch."};
    case (_timeSince < 180): {_state = "Die Kohlen glimmen noch."};
    case (_timeSince < 240): {_state = "An einigen Stellen glimmt es noch."};
    case (_timeSince < 360): {_state = "Die Steine sind noch warm."};
    case (_timeSince >= 360): {_state = "Die Feuerstelle ist kalt."};
  };

  hint composeText [_reason, parseText "<br />", _state];
};

//INITIALIZE FIRE ==============================================================
GRAD_makeFire_fnc_initFireClient = {
  params ["_fire"];
  if (!hasInterface) exitWith {};
  if (isNil "_fire") exitWith {};
  if (isNull _fire) exitWith {};

  //create smoke
  [_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];

  //add ACE-actions
  [_fire,0,["ACE_MainActions","GRAD_inspectFire"]] call ace_interact_menu_fnc_removeActionFromObject;

  _action = ["GRAD_addLeaves", "Add leaves and grass", ACTION_PIC_ADDLEAVES, {[_this select 0] spawn GRAD_makeFire_fnc_addLeaves}, {true}, {}, [], (getpos _fire) vectorAdd ACTION_OFFSET, ACTION_DISTANCE] call ace_interact_menu_fnc_createAction;
  [_fire, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;

  if (typeOf _fire == CLASS_SMALLFIRE) then {
    _action = ["GRAD_upgradeFire", "Add firewood", ACTION_PIC_ADDFIREWOOD, {[_this select 0] spawn GRAD_makeFire_fnc_upgradeFire}, {true}, {}, [], (getpos _fire) vectorAdd ACTION_OFFSET, ACTION_DISTANCE] call ace_interact_menu_fnc_createAction;
    [_fire, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
  };

};

//FIRE BURNED OUT ==============================================================
GRAD_makeFire_fnc_burnedOut = {
  params ["_fire"];
  if (!hasInterface) exitWith {};
  if (isNil "_fire") exitWith {};
  if (isNull _fire) exitWith {};

  [_fire, false] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];

  [_fire,0,["ACE_MainActions","GRAD_upgradeFire"]] call ace_interact_menu_fnc_removeActionFromObject;
  [_fire,0,["ACE_MainActions","GRAD_addLeaves"]] call ace_interact_menu_fnc_removeActionFromObject;

  _action = ["GRAD_inspectFire", "Inspect fire", ACTION_PIC_INSPECTFIRE, {[_this select 0] spawn GRAD_makeFire_fnc_inspectFire}, {true}, {}, [], (getpos _fire) vectorAdd ACTION_OFFSET, ACTION_DISTANCE] call ace_interact_menu_fnc_createAction;
  [_fire, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
};


//SPAWN FIRE (server) ==========================================================
GRAD_makeFire_fnc_spawnFire = {
  private ["_requestedPos", "_fire", "_burnTime", "_class", "_previousLeaves"];

  //is upgrade
  if (typeName (_this select 0) == "OBJECT") then {
    _fire = _this select 0;
    _requestedPos = getPos _fire;
    _burnTime = BURNTIME_BIGFIRE;
    _class = CLASS_BIGFIRE;
    _previousLeaves = _fire getVariable ["leavesAmount", 0];
    deleteVehicle _fire;
  } else {
    _requestedPos = _this select 0;
    _burnTime = BURNTIME_SMALLFIRE;
    _class = CLASS_SMALLFIRE;
    _previousLeaves = 0;
  };

  //spawn fire
  _fire = createVehicle [_class, _requestedPos, [], 0, "CAN_COLLIDE"];
  _fire setPos _requestedPos;
  _fire setVectorUp surfaceNormal _requestedPos;

  _fire setVariable ["burnTimeLeft", _burnTime];
  _fire setVariable ["burnedOut", false, ISPUBLIC];
  _fire setVariable ["burnedOutTime", -1, ISPUBLIC];
  _fire setVariable ["leavesAmount", _previousLeaves, ISPUBLIC];
  sleep 1;
  [_fire] remoteExec ["GRAD_makeFire_fnc_initFireClient", 0, true];
  [_fire] spawn GRAD_makeFire_fnc_burnOutTimer;
};

//BURN OUT (server) ============================================================
GRAD_makeFire_fnc_burnOutTimer = {
  params ["_fire"];

  while {_fire getVariable ["burnTimeLeft", 0] > 0} do {
    _fire setVariable ["burnTimeLeft", (_fire getVariable "burnTimeLeft") - 1];
    sleep 1;
    if !(inflamed _fire) exitWith {};
  };

  if !(inflamed _fire) exitWith {};

  _fire setVariable ["burnedOut", true, ISPUBLIC];
  _fire setVariable ["burnedOutTime", serverTime, ISPUBLIC];
  _fire inflame false;

  [_fire] remoteExec ["GRAD_makeFire_fnc_burnedOut", 0, true];
};

//ADD BURN TIME (server) =======================================================
GRAD_makeFire_fnc_addBurnTime = {
  params ["_fire", "_addTime"];
  _fire setVariable ["burnTimeLeft", (_fire getVariable ["burnTimeLeft", 0]) + _addTime];
};
