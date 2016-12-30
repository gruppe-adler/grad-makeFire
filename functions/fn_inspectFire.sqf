private ["_reason", "_state"];
params ["_fire"];

if (inflamed _fire) exitWith {hint "The fire is burning."};

if (_fire getVariable ["burnedOut", false]) then {
    _reason = "The fire burned out.";
} else {
    _reason = "Somebody extinguished the fire.";
};


//randomize result
_randomFactor = ((random 120) - 60);

//big fire is hot longer
_fireSizeFactor = if (typeOf _fire == GRAD_makeFire_classBig) then {-60} else {0};

//get time when it was extinguished
_timeSince = serverTime - (_fire getVariable ["burnedOutTime", -360]);
_timeSince = _timeSince + _randomFactor + _fireSizeFactor;

_state = switch (true) do {
    case (_timeSince < 60): {"The embers are glowing brightly."};
    case (_timeSince < 120): {"The embers are glowing."};
    case (_timeSince < 180): {"The embers are still slightly glimming."};
    case (_timeSince < 240): {"There are still some embers in the charcoal."};
    case (_timeSince < 360): {"The stones are still warm to the touch."};
    case (_timeSince >= 360): {"It's completeley cold."};
};

hint composeText [_reason, parseText "<br />", _state];
