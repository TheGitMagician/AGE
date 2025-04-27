function Object() constructor
{
	script_name = "";
	
	enabled = true;
	in_room = undefined;	
	x = 0;
	y = 0;	
	name = "";
	
	sprite_index = noone;
	image_index = 0;
	
	blocked = false;
	yield_manager = undefined;

	moving = false;
	//xend = 0;
	//yend = 0;
	move_speed = 2;
	
	movement_path = noone;
	movement_percent_along_path = 0; //0-1
	movement_speed_on_path = 0;
	
	solid = true;
	blocking_width = -1;
	blocking_height = -1;
	
	called_from_rep_exec_always = false;
	
	static move = function(_xend,_yend,_blocking,_anywhere=false)
	{
		if (in_room != room)
		{ show_debug_message("AGE: Object.move(): Object `"+script_name+"` not moved because it's not in the current room.");
			return; }
		
		if (txr_thread_current[txr_thread.type] == txr_thread_type.rep_exec_always) called_from_rep_exec_always = true;
		
		//stop previous movement
		stop_moving();
		
		if (_anywhere)
		{
			movement_path = path_add();
			path_set_closed(movement_path,false);		
			path_set_kind(movement_path, 0);
			path_add_point(movement_path,x,y,1);
			path_add_point(movement_path,_xend,_yend,1);
		}
		else //move on walkareas
		{
			var path = o_age_main.walkarea_manager.calculate_path_to_point(x,y,_xend,_yend);
		
			if (path == noone)
			{ show_debug_message("AGE: Warning: No path to provided endpoint found.");
				return; }
			
			movement_path = path_duplicate(path); //path has to be duplicated because the original path gets freed from memory as soon as calculate_path_to_point() has finished
		}		
		
		movement_percent_along_path = 0;
		movement_speed_modifier = 1;
		
		moving = true;
		
		movement_speed_on_path = move_speed / path_get_length(movement_path);
		
		if (_blocking)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
		}
	}
	
	static stop_moving = function()
	{	
		if (path_exists(movement_path))
		{
			path_delete(movement_path);
			movement_path = noone;
		}
		
		if (solid) o_age_main.walkarea_manager.update_mp_grid(); //occupy the new position of the character in the mp_grid
		
		walking = false;
		moving = false;
	}
	
	static __draw = function()
	{
		draw_sprite_ext(sprite_index,image_index,x,y,1,1,0,c_white,1);
	}
	
	static __cleanup = function()
	{
		if (path_exists(movement_path))
			path_delete(movement_path);
	}
}