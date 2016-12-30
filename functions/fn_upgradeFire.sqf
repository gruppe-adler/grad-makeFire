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
[GRAD_makeFire_upgradeTime, [_fire], _onComplete, {player playAction "medicStop";}, "Gathering wood..."] call ace_common_fnc_progressBar;
