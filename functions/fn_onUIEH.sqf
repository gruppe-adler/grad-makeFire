params ["_fire", "_caller", "_actionID", "_actionName"];


if (_actionName == "FirePutDown") then {
    if (typeOf _fire != GRAD_makeFire_classSmall && typeOf _fire != GRAD_makeFire_classBig) exitWith {};

    _fire inflame false;

    _defaultBurntime = if (typeOf _fire == GRAD_makeFire_classSmall) then {GRAD_makeFire_burntimeSmall} else {GRAD_makeFire_burntimeBig};
    [_fire,_defaultBurntime] remoteExec ["GRAD_makeFire_fnc_burnOutTimer", 2, false];
    _fire setVariable ["burnedOutTime", serverTime, true];
    false;
};


if (_actionName == "FireInFlame") then {
    if (typeOf _fire != GRAD_makeFire_classSmall && typeOf _fire != GRAD_makeFire_classBig) exitWith {};
    if (_fire getVariable ["burnedOut", false]) exitWith {hint "It's completeley burned down."; true};

    _fire inflame true;

    _defaultBurntime = if (typeOf _fire == GRAD_makeFire_classSmall) then {GRAD_makeFire_burntimeSmall} else {GRAD_makeFire_burntimeBig};
    [_fire,_defaultBurntime] remoteExec ["GRAD_makeFire_fnc_burnOutTimer", 2, false];
    [_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
    _fire setVariable ["burnedOutTime", -1, true];
    false;
};
