/*  By Killzone Kid
*
*/

params ["_unit"];
lineIntersectsSurfaces [
    getPosWorld _unit,
    getPosWorld _unit vectorAdd [0, 0, 50],
    _unit, objNull, true, 1, "GEOM", "NONE"
] select 0 params ["","","","_house"];
if (isNil "_house") exitWith {false};
if (_house isKindOf "House") exitWith {true};
false
