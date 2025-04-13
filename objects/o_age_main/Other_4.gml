////load repeatedly execute scripts for this room
//var script_name,script_asset,th;

//thread_room_repeatedly_execute = undefined;
//thread_room_repeatedly_execute_always = undefined;

//#region REPEATEDLY_EXECUTE
//script_name = room_get_name(room);

//script_name = string_delete(script_name,1,3); //remove rm_ prefix

//script_name = "repeatedly_execute_"+script_name;

//script_asset = asset_get_index(script_name);

//if (script_exists(script_asset))
//{
//	//create the repeatedly_execute thread
//	//this thread re-runs every frame until the room is left (at which point it is destroyed)
//	th = txr_run(script_asset(), txr_thread_type.rep_exec);
//	if (th != -1) thread_room_repeatedly_execute = th;
//}
//#endregion

//#region REPEATEDLY_EXECUTE_ALWAYS
//script_name = room_get_name(room);

//script_name = string_delete(script_name,1,3); //remove rm_ prefix

//script_name = "repeatedly_execute_always_"+script_name;

//script_asset = asset_get_index(script_name);

//if (script_exists(script_asset))
//{
//	//create the repeatedly_execute thread
//	//this thread re-runs every frame until the room is left (at which point it is destroyed)
	
//	//additionaly also mark this thread as rep_exec_always so that the callees of this thread
//	//know that they may perform code even when the game is blocked
//	th = txr_run(script_asset(), txr_thread_type.rep_exec_always);
//	if (th != -1) thread_room_repeatedly_execute_always = th;
//}
//#endregion