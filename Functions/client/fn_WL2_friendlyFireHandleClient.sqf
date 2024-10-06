params ["_penalty"];

if (isRemoteExecuted) then {
	private _REOwner = remoteExecutedOwner;
	if (_REOwner > 2) then {
		private _playerQuery = allPlayers select {owner _x == _REOwner};
		private _adminCheck = (getPlayerUID (_playerQuery # 0) in getArray (missionConfigFile >> "adminIDs"));
		if (_adminCheck) then {
			localNamespace setVariable ["penaltyEnd", serverTime];
		} else {
			[format ["WLAC: Name:%1 UID:%2 Attempted to execute 'BIS_fnc_WL2_friendlyFireHandleClient' on another player: %3", _playerQuery, getPlayerUID _playerQuery, name player]] remoteExec ["diag_log", 2];
		};
		return;
	};
};

private _penaltyCheck = profileNameSpace getVariable ["teamkill_penalty", createHashMap];
if ((count _penaltyCheck) == 0) then {
	private _sessionID = missionNamespace getVariable ["sessionID", -1];
	if (_sessionID > 0) then {
		private _penaltyHash = createHashMapFromArray [
			["sessionID", _sessionID],
			["penaltyEndTime", _penalty]
		];
		profileNameSpace setVariable ["teamkill_penalty", _penaltyHash];
		saveProfileNamespace;
	};
};

if !(isNull ((findDisplay 46) displayCtrl 994001) && isNull ((findDisplay 46) displayCtrl 994000)) exitWith {};
localNamespace setVariable ["penaltyEnd", _penalty];

0 spawn {
	private _penaltyEnd = localNamespace getVariable ["penaltyEnd", serverTime];
	
	BIS_WL_penalized = true;
	"RequestMenu_close" call BIS_fnc_WL2_setupUI;
	titleCut ["", "BLACK IN", 1];

	showCinemaBorder true;
	private _camera = "Camera" camCreate position player;
	_camera camSetPos [0, 0, 10];
	_camera camSetTarget [-1000, -1000, 10];
	_camera camCommit 0;
	_camera cameraEffect ["Internal", "Back"];
	waitUntil {!isNull (findDisplay 46)};
	(findDisplay 46) ctrlCreate ["RscStructuredText", 994001];
	((findDisplay 46) displayCtrl 994001) ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
	((findDisplay 46) displayCtrl 994001) ctrlSetBackgroundColor [0, 0, 0, 0.75];
	((findDisplay 46) displayCtrl 994001) ctrlCommit 0;
	(findDisplay 46) ctrlCreate ["RscStructuredText", 994000];
	((findDisplay 46) displayCtrl 994000) ctrlSetPosition [safeZoneX + 0.1, safeZoneY + (safeZoneH * 0.5), (safeZoneW * 0.8), safeZoneH];
	((findDisplay 46) displayCtrl 994000) ctrlCommit 0;
	((findDisplay 46) displayCtrl 994000) ctrlSetStructuredText parseText format [
		"<t shadow = '0'><t size = '%1' color = '#ff4b4b'>%2</t><br/><t size = '%3'>%4</t></t>",
		(2.5 call BIS_fnc_WL2_sub_purchaseMenuGetUIScale),
		([(_penaltyEnd - serverTime) max 0, "MM:SS"] call BIS_fnc_secondsToString),
		(1.3 call BIS_fnc_WL2_sub_purchaseMenuGetUIScale),
		localize "STR_A3_mission_failed_friendly_fire"
	];
	
	player setVariable ["BIS_WL_incomeBlocked", true, [clientOwner, 2]];
	while {_penaltyEnd > serverTime} do {
		_penaltyEnd = localNamespace getVariable ["penaltyEnd", serverTime];
		((findDisplay 46) displayCtrl 994000) ctrlSetStructuredText parseText format [
			"<t shadow = '0'><t size = '%1' color = '#ff4b4b'>%2</t><br/><t size = '%3'>%4</t></t>",
			(2.5 call BIS_fnc_WL2_sub_purchaseMenuGetUIScale),
			[(_penaltyEnd - serverTime) max 0, "MM:SS"] call BIS_fnc_secondsToString,
			(1.5 call BIS_fnc_WL2_sub_purchaseMenuGetUIScale),
			localize "STR_A3_mission_failed_friendly_fire"
		];
		sleep 1;
	};
	player setVariable ["BIS_WL_incomeBlocked", false, [clientOwner, 2]];
	
	forceRespawn player;
	waitUntil {sleep 0.1; alive player};
	while {!(isNull ((findDisplay 46) displayCtrl 994001) && isNull ((findDisplay 46) displayCtrl 994000))} do {
		ctrlDelete ((findDisplay 46) displayCtrl 994001);
		ctrlDelete ((findDisplay 46) displayCtrl 994000);
		sleep 0.1;
	};

	titleCut ["", "BLACK IN", 1];
	_camera cameraEffect ["Terminate", "Back"];
	camDestroy _camera;
	BIS_WL_penalized = false;
	player setVariable ["BIS_WL_friendlyKillTimestamps", [], [2, clientOwner]];
	profileNameSpace setVariable ["teamkill_penalty", nil];
	saveProfileNamespace;
};