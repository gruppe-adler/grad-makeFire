if (!isServer) exitWith {};

[{
    params ["_args", "_handle"];
    _args params ["_fire", ["_defaultBurnTime",0]];

    _fire setVariable ["burnTimeLeft", (_fire getVariable ["burnTimeLeft",_defaultBurnTime]) - 1];
    if (!inflamed _fire) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        [_fire, false] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
    };

    if (_fire getVariable "burnTimeLeft" < 1) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;

        _fire inflame false;
        _fire setVariable ["burnedOut", true, true];
        _fire setVariable ["burnedOutTime", serverTime, true];

        [_fire, false] remoteExec ["GRAD_makeFire_fnc_createSmoke", 0, true];
    };
} , 1, _this] call CBA_fnc_addPerFrameHandler;
