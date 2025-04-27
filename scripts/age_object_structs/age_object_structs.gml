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
	called_from_rep_exec_always = false;

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
	
	
	static move = function(_xend,_yend,_blocking,_anywhere=false)
	{
		if (in_room != room)
		{ show_debug_message("AGE: Object.move(): Object `"+script_name+"` not moved because it's not in the current room.");
			return; }
		
		__rep_exec_always_check();
		
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
		
		moving = false;
	}
	
	static __rep_exec_always_check = function()
	{
		//this method is only used in functions which have an ongoing effect (e.g. walking, moving)
		//this flag is then checked when the character is updated to make sure that the effect continues running even if the game is blocked
		//if - and only if - the function was started from a rep_exec_always script
		if (txr_thread_current[txr_thread.type] == txr_thread_type.rep_exec_always) called_from_rep_exec_always = true;
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

function Object_Manager() constructor
{
	//the actual object structs are stored in o_age_main's objects[] array.
	//yes, this is not nicely decoupled - they could be stored in here, but it has some benefits if they are stored centrally
	//so it is important that this manager knows the central object (o_age_main) and can refer to it when it accesses the objects
	o = o_age_main;
	
	static create = function(_script_name,_settings_struct)
	{
		if (variable_instance_exists(o,_script_name))
		{ show_debug_message("AGE: Can't create object `"+_script_name+"` because the script name already exists.");
			return; }
	
		var obj = new Object();
	
		variable_instance_set(o,_script_name,obj); //add object's script name to o_age_main's variables so that it can be accessed by TXR
		array_push(o.objects, obj); //add oject reference to o_age_main's objects array so that it can be accessed by other resources
	
		obj.script_name = _script_name;
	
		//apply settings to the object
		var i,s;
		s = variable_struct_get_names(_settings_struct);
		for (i=0; i<array_length(s); i++)
		{
			switch (s[i])
			{
				case "in_room":
					obj.in_room = _settings_struct.in_room;
					break;
				case "x":
					obj.x = _settings_struct.x;
					break;
				case "y":
					obj.y = _settings_struct.y;
					break;
				case "name":
					obj.name = _settings_struct.name;
					break;
				case "sprite":
					obj.sprite_index = _settings_struct.sprite;
					break;
			}
		}
	}
	
	static __step = function()
	{
		var i,n,obj;
		n = array_length(o.objects);
		for (i=0; i<n; i++)
		{
			obj = o.objects[i];
	
			if ((obj.in_room != room) || (obj.enabled == false)) continue;
	
			//@TOOD: we're checking obj.moving here but in update_object_move() there is another check. Only one is needed. Perhaps this one here is better.
			//same also with the other checks
			if (obj.moving)
				with (obj) update_object_move();
		}
	}
	
	static __cleanup = function()
	{
		var i,n;
		n = array_length(o.objects);
		for (i=0; i<n; i++)
		{
			o.objects[i].__cleanup();
		}
	}
}