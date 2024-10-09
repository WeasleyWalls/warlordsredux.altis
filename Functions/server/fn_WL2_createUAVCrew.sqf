params ["_pos", "_class", "_direction", "_sender"];

_asset = [_class, _pos, _direction] call BIS_fnc_WL2_createVehicleCorrectly;

private _side = side group _sender;
private _assetGrp = createGroup _side;

private _aiUnit = if (_side == west) then {
	"B_UAV_AI"
} else {
	"O_UAV_AI"
};

waitUntil {sleep 0.1; !(isNull _asset)};
{
	private _personTurret = _x # 4;
	private _passenger = ["PASSENGER", _x # 6] call BIS_fnc_inString;
	if !(_personTurret && _passenger) then {
		private _seat = toLower (_x # 1);
        private _unit = _assetGrp createUnit [_aiUnit, _pos, [], 0, "NONE"];
		waitUntil {sleep 0.1; !(isNull _unit)};
		switch (_seat) do {
			case "driver": {
				_unit assignAsDriver _asset;
				while {(vehicle _unit) isKindOf "Man"} do {
					_unit moveInAny _asset;
					sleep 0.1;
				};
			};
			case "gunner": {
				_unit assignAsGunner _asset;
				while {(vehicle _unit) isKindOf "Man"} do {
					_unit moveInGunner _asset;
					sleep 0.1;
				};
			};
		};
		_unit setVariable ["BIS_WL_ownerAsset", getPlayerUID _sender, [2, clientOwner]];
	};
} forEach fullCrew [_asset, "", true];

_assetGrp deleteGroupWhenEmpty true;

_asset;