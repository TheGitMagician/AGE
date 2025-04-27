//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit

var i,n,char,obj,result;

mx = mouse_x;
my = mouse_y;

// ================ process repeatedly execute ================
#region process repeatedly execute scripts
//keep repeatedly_execute running
if ((thread_room_repeatedly_execute != undefined) && (blocked == false))
{
	txr_thread_reset(thread_room_repeatedly_execute);	
	txr_age_thread_resume(thread_room_repeatedly_execute);
}

//keep repeatedly_execute_always running
if (thread_room_repeatedly_execute_always != undefined)
{
	txr_thread_reset(thread_room_repeatedly_execute_always);
	txr_age_thread_resume(thread_room_repeatedly_execute_always);
}
#endregion


// ================ update game managers ================
global_manager.__step();
character.__step();
object.__step();


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