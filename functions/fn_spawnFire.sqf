private ["_requestedPos", "_fire", "_burnTime", "_class", "_previousLeaves"];
params ["_fire"];


//is upgrade
if (typeName _fire == "OBJECT") then {
    _requestedPos = (getPos _fire) vectorAdd [0,0,0.1];
    _burnTime = GRAD_makeFire_burntimeBig;
    _class = GRAD_makeFire_classBig;
    _previousLeaves = _fire getVariable ["leavesAmount", 0];

    //is primary-like object
    if (getObjectType _fire < 8) then {
        hideObjectGlobal _fire;

    //is placed object
    } else {
        deleteVehicle _fire;
    };


//is new
} else {
    _requestedPos = _fire;
    _burnTime = GRAD_makeFire_burntimeSmall;
    _class = GRAD_makeFire_classSmall;
    _previousLeaves = 0;
};


//spawn fire
_fire = createVehicle [_class, _requestedPos, [], 0, "CAN_COLLIDE"];
_fire setPos _requestedPos;
_fire setVectorUp surfaceNormal _requestedPos;

//set variables
_fire setVariable ["burnTimeLeft", _burnTime];
_fire setVariable ["burnedOut", false, true];
_fire setVariable ["burnedOutTime", -1, true];
_fire setVariable ["leavesAmount", _previousLeaves, true];

//init on client
[_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
[_fire] call GRAD_makeFire_fnc_burnOutTimer;
