//check position
_canBuild = switch (true) do {
    case (isOnRoad player): {
        hint "I can't make a fire on the road.";
        false
    };

    case (surfaceIsWater getPos player): {
        hint "It's too wet. I can't make a fire here.";
        false
    };

    case ([player] call KK_fnc_inHouse): {
        hint "I can't make a fire inside a building.";
        false
    };

    case (!([player] call GRAD_makeFire_fnc_isNearTrees)): {
        hint "I can't find any wood here.";
        false
    };

    default {
        true
    };
};

//build fire
if (_canBuild) then {
    player playAction "medicStart";

    _onComplete = {
        player playAction "medicStop";
        [player getRelPos [GRAD_makeFire_playerDist, 0]] remoteExec ["GRAD_makeFire_fnc_spawnFire", 2, false];
    };
    [GRAD_makeFire_buildTime, [], _onComplete, {player playAction "medicStop";}, "Building fire..."] call ace_common_fnc_progressBar;
};
