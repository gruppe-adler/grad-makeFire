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
