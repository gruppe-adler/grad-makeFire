params ["_fire"];
private ["_reason", "_state"];
if (inflamed _fire) exitWith {hint "Das Feuer brennt."};
if (_fire getVariable ["burnedOut", false]) then {
    _reason = "Das Feuer ist heruntergebrannt.";
} else {
    _reason = "Jemand hat das Feuer gelöscht.";
};

//randomize result
_randomFactor = ((random 120) - 60);
//big fire is hot longer
_fireSizeFactor = if (typeOf _fire == GRAD_makeFire_classBig) then {-60} else {0};
//get time when it was extinguished
_timeSince = serverTime - (_fire getVariable ["burnedOutTime", 0]);
_timeSince = _timeSince + _randomFactor + _fireSizeFactor;
switch (true) do {
    case (_timeSince < 60): {_state = "Die Kohlen glühen noch hell. Die Luft flimmert."};
    case (_timeSince < 120): {_state = "Die Kohlen glühen noch."};
    case (_timeSince < 180): {_state = "Die Kohlen glimmen noch."};
    case (_timeSince < 240): {_state = "An einigen Stellen glimmt es noch."};
    case (_timeSince < 360): {_state = "Die Steine sind noch warm."};
    case (_timeSince >= 360): {_state = "Die Feuerstelle ist kalt."};
};

hint composeText [_reason, parseText "<br />", _state];
