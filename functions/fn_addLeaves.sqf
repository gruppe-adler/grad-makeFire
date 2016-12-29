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
