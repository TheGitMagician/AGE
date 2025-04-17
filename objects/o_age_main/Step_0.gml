var i,n,char;

mx = mouse_x;
my = mouse_y;

// ================ process repeatedly execute ================
//keep repeatedly_execute running
if (thread_room_repeatedly_execute != undefined)
{
	if (blocked == false)
	{
		txr_thread_reset(thread_room_repeatedly_execute);
		
		if (txr_thread_resume(thread_room_repeatedly_execute) == txr_thread_status.error)
		{
			show_debug_message(thread_room_repeatedly_execute[txr_thread.result]);
		}
	}
}

//keep repeatedly_execute_always running
if (thread_room_repeatedly_execute_always != undefined)
{
	txr_thread_reset(thread_room_repeatedly_execute_always);
	
	if (txr_thread_resume(thread_room_repeatedly_execute_always) == txr_thread_status.error)
	{
		show_debug_message(thread_room_repeatedly_execute_always[txr_thread.result]);
	}
}

// ================ process characters ================
n = array_length(characters);
for (i=0; i<n; i++)
{
	char = characters[i];
	
	//if ((char.room_current != room) || (char.enabled == false)) continue;
	//show_debug_message(char.name)
	
	//@TOOD: we're checking char.walking here but in update_character_move() there is another check. Only one is needed. Perhaps this one here is better.
	if (char.walking)
	{
		with (char) update_character_move();
	}
	
	if (char.animating)
	{
		with (char) update_character_animation();
	}
}

// ================ process dialog options ================
if (dialog.are_options_displayed())
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