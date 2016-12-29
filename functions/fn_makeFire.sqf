//check position
if (isOnRoad player) exitWith {hint "Ich kann auf der Straße kein Feuer machen."};
if (surfaceIsWater getPos player) exitWith {hint "Ich kann im Wasser kein Feuer machen."};
if ([player] call KK_fnc_inHouse) exitWith {hint "Ich kann in einem Gebäude kein Feuer machen."};

//check if trees nearby
_treesNearby = (((selectBestPlaces [getpos player, MAKEFIRE_TREERADIUS, "trees", 0.5, 1]) select 0) select 1) > 0.2;
if (!_treesNearby) exitWith {hint "Es ist kein Feuerholz in der Nähe."};

//progressbar
_onComplete = {
    _params = _this select 0;
    _firePos = player getRelPos [MAKEFIRE_PLAYERDIST, 0];

    player playAction "medicStop";

    [_firePos] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
};

player playAction "medicStart";
[MAKEFIRE_BUILDTIME, [], _onComplete, {player playAction "medicStop";}, "Feuer machen"] call ace_common_fnc_progressBar;
