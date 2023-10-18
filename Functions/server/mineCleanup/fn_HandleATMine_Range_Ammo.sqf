params ["_entity"];

_minesDB = serverNamespace getVariable "BIS_WL2_mineLimits";
_mines = (serverNamespace getVariable "BIS_WL2_mineLimits") get "spawnedAT";

if (count _mines >= 25) then {
  private _t = _mines find objNull;
  if (_t != -1) then {_mines deleteAt _t;};
  if (count _mines >= 25) then {
    deleteVehicle _entity;
  } else {
    _mines pushBack _entity;
    _minesDB set ["spawnedAT", _mines];
  };
} else {
  _mines pushBack _entity;
  _minesDB set ["spawnedAT", _mines];
};