params ["_fire"];

_leavesAmount = _fire getVariable ["leavesAmount", 0];
if (_leavesAmount > 1) exitWith {hint "I'll smother it if I add any more leaves."};

_onComplete = {
    params ["_args"];
    _args params ["_fire"];

    player playAction "medicStop";
    if (!inflamed _fire) exitWith {hint "The fire went out."};

    _leavesAmount = _fire getVariable ["leavesAmount", 0];
    if (_leavesAmount > 1) exitWith {hint "Someone beat me to it."};

    _fire setVariable ["leavesAmount", (_fire getVariable ["leavesAmount", 0]) + 1, true];
    [_fire, GRAD_makeFire_burntimeLeaves] remoteExec ["GRAD_makeFire_fnc_addBurnTime", 2, false];
    [_fire, true] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
};

player playAction "medicStart";
[GRAD_makeFire_addLeavesTime, [_fire], _onComplete, {player playAction "medicStop";}, "Gathering leaves and grass..."] call ace_common_fnc_progressBar;
