params ["_fire", "_addTime"];
_fire setVariable ["burnTimeLeft", (_fire getVariable ["burnTimeLeft", 0]) + _addTime];
