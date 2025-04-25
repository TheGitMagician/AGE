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
	
	called_from_rep_exec_always = false;
	
	static move = function(_xend,_yend,_blocking)
	{
		if (in_room != room)
		{ show_debug_message("AGE: Object.move(): Object `"+script_name+"` not moved because it's not in the current room.");
			return; }
		
		if (txr_thread_current[txr_thread.type] == txr_thread_type.rep_exec_always) called_from_rep_exec_always = true;
		
		var path = o_age_main.pathfinder.calculate_path_to_point(x,y,_xend,_yend,true);
		
		if (path == undefined)
		{ show_debug_message("AGE: Warning: No path to provided endpoint found.");
			return; }
		
		movement_path = path_duplicate(path);
		movement_percent_along_path = 0;
		movement_speed_modifier = 1;
		
		moving = true;
		
		movement_speed_on_path = move_speed / path_get_length(movement_path);
		
		if (_blocking == age.block)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
		}
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