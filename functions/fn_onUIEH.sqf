params ["_fire", "_caller", "_actionID", "_actionName"];

if (_actionName == "FirePutDown") then {
    if (typeOf _fire != GRAD_makeFire_classSmall && typeOf _fire != GRAD_makeFire_classBig) exitWith {};
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnedOut", 0, true];
    _fire setVariable ["burnedOutTime", serverTime, ISPUBLIC];
    false;
};

if (_actionName == "FireInFlame") then {
    if (typeOf _fire != GRAD_makeFire_classSmall && typeOf _fire != GRAD_makeFire_classBig) exitWith {};
    if (_fire getVariable ["burnedOut", false]) exitWith {hint "Es ist komplett heruntergebrannt."; true};

    [_fire] remoteExec ["GRAD_makeFire_fnc_initFireClient", 0, true];
    [_fire] remoteExec ["GRAD_makeFire_fnc_burnOutTimer", 2, false];
    _fire setVariable ["burnedOutTime", -1, ISPUBLIC];
    false;
};
