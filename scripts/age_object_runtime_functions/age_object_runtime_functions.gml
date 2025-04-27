function update_object_move()
{
	if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!moving) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	movement_percent_along_path += movement_speed_on_path * movement_speed_modifier;
	
	if (movement_percent_along_path >= 1)
	{
		moving = false;
		
		if (path_exists(movement_path))
		{
			path_delete(movement_path);
			movement_path = noone;
		}
		
		if (blocked)
		{
			blocked = false;
			yield_manager.continue_thread();
		}
		
		return;
	}
	
	x = path_get_x(movement_path,movement_percent_along_path);
	y = path_get_y(movement_path,movement_percent_along_path);
}