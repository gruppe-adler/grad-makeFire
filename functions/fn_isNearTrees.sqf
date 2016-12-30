params ["_pos"];

if (typeName _pos != "ARRAY") then {
    _pos = getPos _pos;
};

(((selectBestPlaces [_pos, GRAD_makeFire_treeRadius, "trees", 0.5, 1]) select 0) select 1) > 0.2
