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
