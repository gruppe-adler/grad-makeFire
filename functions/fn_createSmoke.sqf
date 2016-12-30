params ["_fire", "_isBurning"];
if (!hasInterface) exitWith {};
if (isNil "_fire") exitWith {};
if (isNull _fire) exitWith {};

_particleSources = [];
_oldParticleSources = _fire getVariable ["particleSources", []];
{
    deleteVehicle _x;
} forEach _oldParticleSources;

//dont create new sources if fire is out
if (!_isBurning) exitWith {};

_leavesAmount = _fire getVariable ["leavesAmount", 0];
//big fire
if (typeOf _fire == GRAD_makeFire_classBig) then {
    switch (_leavesAmount) do {
        case 0: {};
        case 1: {_particleSources = [_fire, "wood", "large"] call C9J_fnc_createSmokeColumn};
        case 2: {_particleSources = [_fire, "wood", "superlarge"] call C9J_fnc_createSmokeColumn};
        default {_particleSources = [_fire, "wood", "superlarge"] call C9J_fnc_createSmokeColumn};
    };

//small fire
} else {
    switch (_leavesAmount) do {
        case 0: {};
        case 1: {_particleSources = [_fire, "wood", "small"] call C9J_fnc_createSmokeColumn};
        case 2: {_particleSources = [_fire, "wood", "medium"] call C9J_fnc_createSmokeColumn};
        default {_particleSources = [_fire, "wood", "medium"] call C9J_fnc_createSmokeColumn};
    };
};

_fire setVariable ["particleSources", _particleSources];
