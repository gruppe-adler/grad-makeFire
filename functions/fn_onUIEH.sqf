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
