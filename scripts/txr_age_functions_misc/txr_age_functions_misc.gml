//function txr_wait(frames)
//{
//	//stop the current thread
//	var th = txr_thread_yield();
	
//	//hand the thread pointer over into the dummy object so that
//	//it can be restarted from there
//	if (th != undefined)
//	{
//		with (o_txr.dummy)
//		{
//			thread = th;
//			alarm[0] = frames;
//		}
//	}
	
//	//block the game
//	o_age_main.blocked = true;
//}

function txr_wait(_steps)
{
	o_age_main.global_manager.wait(_steps);
}

function txr_set_timer(_timer,_steps)
{
	o_age_main.global_manager.set_timer(_timer,_steps);
}

function txr_is_timer_expired(_timer)
{
	return o_age_main.global_manager.is_timer_expired(_timer);
}

function txr_stop_timer(_timer)
{
	o_age_main.global_manager.stop_timer(_timer);
}

function txr_get_timer_pos(_timer)
{
	return o_age_main.global_manager.get_timer_pos(_timer);
}

function txr_claim_event()
{
	o_age_main.global_manager.claim_event();
}

function txr_start_cutscene()
{
	if (o_age_main.in_cutscene)
	{ show_debug_message("AGE: start_cutscene(): Can't start a cutscene. Game is already in a cutscene.");
		return; }
	
	o_age_main.in_cutscene = true;
}

function txr_end_cutscene()
{
	if (!o_age_main.in_cutscene)
	{ show_debug_message("AGE: end_cutscene(): Can't end cutscene. Game is not in a cutscene.");
		return; }
	
	o_gui.delete_all_textblocks();
	
	o_age_main.in_cutscene = false;
	o_age_main.skipping_cutscene = false;	
}

function txr_skip_cutscene()
{
	if (!o_age_main.in_cutscene)
	{ show_debug_message("AGE: skip_cutscene(): Can't skip. Game is not in a cutscene.");
		return; }
	
	if (o_age_main.skipping_cutscene)
	{ show_debug_message("AGE: skip_cutscene(): Cutscene is already being skipped.");
		return; }
	
	o_age_main.skipping_cutscene = true;
	o_age_main.fast_forward();
}

function txr_save_game(_slot)
{
	if ((_slot < 0) || (_slot > 9))
	{ show_debug_message("AGE: save_game(): Can't save. Saveslot must be between 0 and 9.");
		return; }
	
	o_age_main.saving_the_game_was_requested = _slot; //in o_age_main's Step Event this is checked and the game is saved if no blocking threads are active
}

function txr_load_game(_slot)
{
	if ((_slot < 0) || (_slot > 9))
	{ show_debug_message("AGE: load_game(): Can't load. Saveslot must be between 0 and 9.");
		return; }
	
	o_age_main.loading_the_game_was_requested = _slot;  //in o_age_main's Step Event this is checked and the game is loaded if no blocking threads are active
}