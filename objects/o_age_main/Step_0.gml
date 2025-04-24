//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

var i,n,char,obj,th,result;

mx = mouse_x;
my = mouse_y;

// ================ process repeatedly execute ================
#region process repeatedly execute scripts
//keep repeatedly_execute running
if ((thread_room_repeatedly_execute != undefined) && (blocked == false))
{
	th = thread_room_repeatedly_execute;
		
	txr_thread_reset(th);
		
	//start the thread
	var result = undefined;
	switch (txr_thread_resume(th)) {
		//the thread runs completely to the end without any blocking commands
		//in that case it can be destroyed immediately - unless it is a rep_exec or rep_exec_always which get restarted every frame!
		case txr_thread_status.finished:
			txr_error = "";
			result = th[txr_thread.result];
			break;
		//the thread ran into an error while trying to execute it
		//the error message is shown and the thread destroyed
		case txr_thread_status.error:
			txr_error = th[txr_thread.result];
			show_debug_message(txr_error);
			txr_thread_destroy(th);
			thread_room_repeatedly_execute = undefined;
			break;
		//the other option is that the thread yields (because of a blocking AGE function).
		//in that case the thread is later resumed by TXR_Yield_Manager which also checks if it can be destroyed afterwards
	}
}

//keep repeatedly_execute_always running
if (thread_room_repeatedly_execute_always != undefined)
{
	th = thread_room_repeatedly_execute_always;
		
		txr_thread_reset(th);
		
		//start the thread
		var result = undefined;
		switch (txr_thread_resume(th)) {
			//the thread runs completely to the end without any blocking commands
			//in that case it can be destroyed immediately - unless it is a rep_exec or rep_exec_always which get restarted every frame!
			case txr_thread_status.finished:
				txr_error = "";
				result = th[txr_thread.result];
				break;
			//the thread ran into an error while trying to execute it
			//the error message is shown and the thread destroyed
			case txr_thread_status.error:
				txr_error = th[txr_thread.result];
				show_debug_message(txr_error);
				txr_thread_destroy(th);
				thread_room_repeatedly_execute_always = undefined;
				break;
			//the other option is that the thread yields (because of a blocking AGE function).
			//THIS IS NOT ALLOWED IN REP_EXEC_ALWAYS so the thread will be destroyed and a warning will be shown
			case txr_thread_status.yield:
				show_debug_message("AGE: repeatedly_execute_always script was stopped because it contains a blocking function which is not allowed.");
				txr_thread_destroy(th);
				thread_room_repeatedly_execute_always = undefined;
				break;
		}
}
#endregion


// ================ process global functions ================
with (global_manager) update_global_manager();

// ================ process characters ================
#region process characters
n = array_length(characters);
for (i=0; i<n; i++)
{
	char = characters[i];
	
	if ((char.current_room != room) || (char.enabled == false)) continue;
	//show_debug_message(char.name)
	
	//@TOOD: we're checking char.walking here but in update_character_move() there is another check. Only one is needed. Perhaps this one here is better.
	//same also with the other checks
	if (char.walking)
		with (char) update_character_move();
	
	if (char.animating)
		with (char) update_character_animation();
	
	if (char.talking)
		with (char) update_character_say();
}
#endregion


// ================ process objects ================
#region process objects
n = array_length(objects);
for (i=0; i<n; i++)
{
	obj = objects[i];
	
	if ((obj.in_room != room) || (obj.enabled == false)) continue;
	//show_debug_message(char.name)
	
	//@TOOD: we're checking obj.moving here but in update_object_move() there is another check. Only one is needed. Perhaps this one here is better.
	//same also with the other checks
	if (obj.moving)
		with (obj) update_object_move();
}
#endregion


// ================ process dialog options ================
if (dialog.options_are_displayed())
{
	if (keyboard_check_pressed(vk_anykey))
	{
		if (string_digits(keyboard_lastchar) != "")
		{
			//dialog.current_dialog.debug_show_txr_script_for_option(real(string_digits(keyboard_lastchar)));
			dialog.run_option(real(string_digits(keyboard_lastchar)));
		}
	}
}


// ================ calculate draw order ================
#region calculate draw order
//populate draw order array and sort it according to the y-coordinate
draw_order = [];

n = array_length(characters);
for (i=0; i<n; i++)
{
	char = characters[i];
	
	if ((char.current_room != room) || (char.enabled == false)) continue; //@TODO: manage a list with all chars that have to be drawn instead of always looping through all of them. Update the list when functions like change_room() or enable() are called
	array_push(draw_order,char);
}

n = array_length(objects);
for (i=0; i<n; i++)
{
	obj = objects[i];
	if ((obj.in_room != room) || (obj.enabled == false)) continue; //@TODO: manage a list with all chars that have to be drawn instead of always looping through all of them. Update the list when functions like change_room() or enable() are called
	
	array_push(draw_order,obj);
}

array_sort(draw_order, function(elm1, elm2) {
	return elm1.y - elm2.y;
});
#endregion


// ================ check whether game has to be saved or loaded ================
#region process game save/load
if ((saving_the_game_was_requested >= 0) && (blocked == false))
{
	save_game(saving_the_game_was_requested);	
	saving_the_game_was_requested = -1;
}
if ((loading_the_game_was_requested >= 0) && (blocked == false))
{
	load_game(loading_the_game_was_requested);
	loading_the_game_was_requested = -1;
}
#endregion