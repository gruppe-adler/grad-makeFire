private ["_requestedPos", "_fire", "_burnTime", "_class", "_previousLeaves"];

//is upgrade
if (typeName (_this select 0) == "OBJECT") then {
    _fire = _this select 0;
    _requestedPos = getPos _fire;
    _burnTime = GRAD_makeFire_burntimeBig;
    _class = GRAD_makeFire_classBig;
    _previousLeaves = _fire getVariable ["leavesAmount", 0];
    deleteVehicle _fire;
} else {
    _requestedPos = _this select 0;
    _burnTime = GRAD_makeFire_burntimeSmall;
    _class = GRAD_makeFire_classSmall;
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
