/*  Initializes GRAD fire making system
*
*   needs to be executed on both server and clients
*/


#define ISPUBLIC true
#define FILEPATH GRAD_makeFire_filePath

GRAD_core_getFileDirectory = {
    params ['_filePath', '_worldname'];

    _isMissionFileName = {
        _splitArray = _this splitString ".";
        (count _splitArray == 2) && (_worldname in _splitArray);
    };

    _filePathArray = _filePath splitString "\";
    _start = 0;
    {
        if (_x call _isMissionFileName) exitWith {
            _start = _forEachIndex + 1;
        };
    } forEach _filePathArray;

    _directoryCount = (count _filePathArray) - 1 - _start;
    _filePathArray = _filePathArray select [_start, _directoryCount];
    if (count _filePathArray > 0) then {_filePathArray pushBack ""};
    _filePathArray joinString "\";
};

FILEPATH = [__FILE__, worldname] call GRAD_core_getFileDirectory;



//CONFIG VALUES (YOU CAN CHANGE THESE!) ========================================
#ifndef MAKEFIRE_TREERADIUS
  #define MAKEFIRE_TREERADIUS 40                                                //distance player-->trees in order to be able to start fire (this is not exact)
  #define MAKEFIRE_CANBUILD true                                                //condition to be able to build fire
  #define MAKEFIRE_BUILDTIME 10                                                 //time it takes to make the fire
  #define MAKEFIRE_UPGRADETIME 10                                               //time it takes to upgrade fire
  #define MAKEFIRE_ADDLVSTIME 10                                                //time it takes to add leaves to the fire
  #define MAKEFIRE_PLAYERDIST 2                                                 //distance to player that the fire object will be spawned
  #define MAKEFIRE_CLASS_SMALL "FirePlace_burning_F"                            //small fire classname
  #define MAKEFIRE_CLASS_BIG "Campfire_burning_F"                               //big fire classname
  #define MAKEFIRE_ACTOFFSET [0,0,0.2]                                          //interaction point offset from model center
  #define MAKEFIRE_ACTDIST 2.5                                                  //distance from which interaction point can be accessed
  #define MAKEFIRE_BURNTIMESMALL 60                                             //time that a small fire will burn
  #define MAKEFIRE_BURNTIMEBIG 90                                               //time that a big fire will burn
  #define MAKEFIRE_BURNTIMELVS 20                                               //time that adding leaves will add to total burntime
#endif

#ifndef MAKEFIRE_ACTPIC_BUILD
  #define MAKEFIRE_ACTPIC_BUILD (FILEPATH + "pic\fire.paa")                     //"make fire" action picture path
  #define MAKEFIRE_ACTPIC_ADDLVS (FILEPATH + "pic\leaves.paa")                  //"add leaves to fire" action picture path
  #define MAKEFIRE_ACTPIC_ADDWD (FILEPATH + "pic\wood.paa")                     //"add firewood to fire" action picture path
  #define MAKEFIRE_ACTPIC_INSPECT (FILEPATH + "pic\inspect.paa")                //"inspect fire" action pictre path
#endif
//==============================================================================

//prevent executing this twice on non-dedicated
if (!isNil "GRAD_makeFire_initialized") exitWith {};
GRAD_makeFire_initialized = true;

[] spawn {
  if (!hasInterface) exitWith {};
  waitUntil {!isNull player};

  //add UI EH
  inGameUISetEventHandler ["Action", "_this call GRAD_makeFire_fnc_onUIEH"];

  if (MAKEFIRE_CANBUILD) then {
    //add ACE-Selfinteraction
    _action_makeFire = ["GRAD_makeFire", "Make Fire", MAKEFIRE_ACTPIC_BUILD, {[] spawn GRAD_makeFire_fnc_makeFire}, {true}] call ace_interact_menu_fnc_createAction;
    [ player, 1, ["ACE_SelfActions"], _action_makeFire] call ace_interact_menu_fnc_addActionToObject;
  };
};


//FUNCTIONS ================================================================================================================================================
//ON UI EH  ====================================================================
GRAD_makeFire_fnc_onUIEH = {
  params ["_fire", "_caller", "_actionID", "_actionName"];

  if (_actionName == "FirePutDown") then {
    if (typeOf _fire != MAKEFIRE_CLASS_SMALL && typeOf _fire != MAKEFIRE_CLASS_BIG) exitWith {};
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnedOut", 0, true];
    _fire setVariable ["burnedOutTime", serverTime, ISPUBLIC];
    false;
  };

  if (_actionName == "FireInFlame") then {
    if (typeOf _fire != MAKEFIRE_CLASS_SMALL && typeOf _fire != MAKEFIRE_CLASS_BIG) exitWith {};
    if (_fire getVariable ["burnedOut", false]) exitWith {hint "Es ist komplett heruntergebrannt."; true};

    [_fire] remoteExec ["GRAD_makeFire_fnc_initFireClient", 0, true];
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnOutTimer", 2, false];
    _fire setVariable ["burnedOutTime", -1, ISPUBLIC];
    false;
  };
};

//CREATE SMOKE (local) =========================================================
if (isNil "C9J_fnc_createSmokeColumn") then {
  C9J_fnc_createSmokeColumn = compile preprocessFileLineNumbers (GRAD_makeFire_filePath + "fn_createSmokeColumn.sqf");
};

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
  _treesNearby = (((selectBestPlaces [getpos player, MAKEFIRE_TREERADIUS, "trees", 0.5, 1]) select 0) select 1) > 0.2;
  if (!_treesNearby) exitWith {hint "Es ist kein Feuerholz in der Nähe."};

  //progressbar
  _onComplete = {
    _params = _this select 0;
    _firePos = player getRelPos [MAKEFIRE_PLAYERDIST, 0];

    player playAction "medicStop";

    [_firePos] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
  };

  player playAction "medicStart";
  [MAKEFIRE_BUILDTIME, [], _onComplete, {player playAction "medicStop";}, "Feuer machen"] call ace_common_fnc_progressBar;
};

//UPGRADE FIRE =================================================================
GRAD_makeFire_fnc_upgradeFire = {
  params ["_fire"];

  //progressbar
  _onComplete = {
    _params = _this select 0;
    _fire = _params select 0;

    player playAction "medicStop";

    if (isNil "_fire") exitWith {};
    if (isNull _fire) exitWith {};
    [_fire] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
  };

  player playAction "medicStart";
  [MAKEFIRE_UPGRADETIME, [_fire], _onComplete, {player playAction "medicStop";}, "Feuerholz sammeln"] call ace_common_fnc_progressBar;
};

//ADD LEAVES ===================================================================
GRAD_makeFire_fnc_addLeaves = {
params ["_fire"];
_leavesAmount = _fire getVariable ["leavesAmount", 100];
if (_leavesAmount >= 2) exitWith {hint "Das Feuer geht aus, wenn ich noch mehr Blätter drauflege."};

 _onComplete = {
    _params = _this select 0;
    _fire = _params select 0;

    player playAction "medicStop";

    if (!inflamed _fire) exitWith {hint "Das Feuer ist erloschen."};

    _leavesAmount = _fire getVariable ["leavesAmount", 100];
    if (_leavesAmount >= 2) exitWith {hint "Jemand war schneller als ich."};

    _fire setVariable ["leavesAmount", (_fire getVariable ["leavesAmount", 0]) + 1, ISPUBLIC];
    [_fire, MAKEFIRE_BURNTIMELVS] remoteExec ["GRAD_makeFire_fnc_addBurnTime", 2, false];
    [_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
  };

  player playAction "medicStart";
  [MAKEFIRE_ADDLVSTIME, [_fire], _onComplete, {player playAction "medicStop";}, "Blätter und Gras sammeln"] call ace_common_fnc_progressBar;
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
  if (typeOf _fire == MAKEFIRE_CLASS_BIG) then {
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

  //randomize result
  _randomFactor = ((random 120) - 60);
  //big fire is hot longer
  _fireSizeFactor = if (typeOf _fire == MAKEFIRE_CLASS_BIG) then {-60} else {0};
  //get time when it was extinguished
  _timeSince = serverTime - (_fire getVariable ["burnedOutTime", 0]);
  _timeSince = _timeSince + _randomFactor + _fireSizeFactor;
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
  [_fire,0,["GRAD_makeFire_mainAction","GRAD_makeFire_inspectFire"]] call ace_interact_menu_fnc_removeActionFromObject;

  _action = ["GRAD_makeFire_mainAction", "Interactions", "", {}, {true}, {}, [], MAKEFIRE_ACTOFFSET, MAKEFIRE_ACTDIST] call ace_interact_menu_fnc_createAction;
  [_fire, 0, [], _action] call ace_interact_menu_fnc_addActionToObject;

  _action = ["GRAD_makeFire_addLeaves", "Add Leaves and Grass", MAKEFIRE_ACTPIC_ADDLVS, {[_this select 0] spawn GRAD_makeFire_fnc_addLeaves}, {true}] call ace_interact_menu_fnc_createAction;
  [_fire, 0, ["GRAD_makeFire_mainAction"], _action] call ace_interact_menu_fnc_addActionToObject;

  if (typeOf _fire == MAKEFIRE_CLASS_SMALL) then {
    _action = ["GRAD_makeFire_upgradeFire", "Add Firewood", MAKEFIRE_ACTPIC_ADDWD, {[_this select 0] spawn GRAD_makeFire_fnc_upgradeFire}, {true}] call ace_interact_menu_fnc_createAction;
    [_fire, 0, ["GRAD_makeFire_mainAction"], _action] call ace_interact_menu_fnc_addActionToObject;
  };

};

//FIRE BURNED OUT ==============================================================
GRAD_makeFire_fnc_burnedOut = {
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
};


//SPAWN FIRE (server) ==========================================================
GRAD_makeFire_fnc_spawnFire = {
  private ["_requestedPos", "_fire", "_burnTime", "_class", "_previousLeaves"];

  //is upgrade
  if (typeName (_this select 0) == "OBJECT") then {
    _fire = _this select 0;
    _requestedPos = getPos _fire;
    _burnTime = MAKEFIRE_BURNTIMEBIG;
    _class = MAKEFIRE_CLASS_BIG;
    _previousLeaves = _fire getVariable ["leavesAmount", 0];
    deleteVehicle _fire;
  } else {
    _requestedPos = _this select 0;
    _burnTime = MAKEFIRE_BURNTIMESMALL;
    _class = MAKEFIRE_CLASS_SMALL;
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
