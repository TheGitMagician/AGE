function Pathfinder() constructor
{
	mp_grid = undefined;
	
	current_path = noone;
	
	static update_mp_grid = function(_walkarea_manager)
	{
		if (_walkarea_manager.walkarea_mask == undefined)
			return;
		
		if (mp_grid == undefined)
			mp_grid = mp_grid_create(0,0,room_width,room_height,1,1);
		else
			mp_grid_clear_all(mp_grid);
			
		//create an instance of the walkarea helper object
		//create a dynamic sprite that holds the walkarea mask - with precise collision
		//apply the sprite to the object and use the instance of the object to occupy the grid cells 
		var iid = instance_create_layer(0,0,"Walkareas",o_walkarea_helper);		
		iid.sprite_index = _walkarea_manager.walkarea_sprite;
		
		mp_grid_add_instances(mp_grid,o_walkarea_helper,true);
		
		instance_destroy(iid);
		
		//go through all solid characters and objects in the room and add their blocking box to the mask
		var i,n,c,blocking_w,blocking_h,blocking_x,blocking_y;
		n = array_length(o_age_main.characters);
		for (i=0; i<n; i++)
		{
			c = o_age_main.characters[i];
			if ((c.current_room != room) || (!c.solid))
				continue;
			
			if (c.blocking_width <= 0) blocking_w = sprite_get_width(c.sprite_index)*1.5;
			else blocking_w = c.blocking_width;
			
			
			if (c.blocking_height <= 0) blocking_h = 10;
			else blocking_h = c.blocking_height;
			
			blocking_x = floor(c.x - (blocking_w/2));
			blocking_y = floor(c.y - (blocking_h/2));
			
			mp_grid_add_rectangle(mp_grid,blocking_x,blocking_y,blocking_x+blocking_w,blocking_y+blocking_h);
		}
	}
	
	static is_point_on_walkarea = function(_xx,_yy)
	{
		if (mp_grid == undefined)
			return;
		
		var r = mp_grid_get_cell(mp_grid,_xx,_yy);
		
		return (r == 0); //true for a cell on a walkarea, false otherwise
	}
	
	static find_nearest_point_on_walkarea = function(_xx,_yy)
	{
		if (mp_grid == undefined)
			return [-1,-1];
		
		if (mp_grid_get_cell(mp_grid,_xx,_yy) == 0)
			return [_xx,_yy];
		
		var grid_visited, queue, directions, pos, i, new_x, new_y, final_pos, found_it;
		
		grid_visited = ds_grid_create(room_width,room_height);
		ds_grid_clear(grid_visited, 0);
		ds_grid_set(grid_visited,_xx,_yy,1);
		
		queue = ds_queue_create();
		ds_queue_enqueue(queue,[_xx,_yy]);
		
		directions = [[-1,0], [1,0], [0,-1], [0,1]];
		
		final_pos = [-1,-1];
		found_it = false;
		
		while (ds_queue_size(queue) > 0)
		{
			pos = ds_queue_dequeue(queue);
			
			for (i=0; i<4; i++)
			{
				new_x = pos[0] + directions[i][0];
				new_y = pos[1] + directions[i][1];
				
				if ((new_x >= 0) && (new_x < room_width) && (new_y >= 0) && (new_y < room_height))
				{
					if (ds_grid_get(grid_visited,new_x,new_y) == 0)
					{
						if (mp_grid_get_cell(mp_grid,new_x,new_y) == 0)
						{
							final_pos = [new_x,new_y];
							found_it = true;
							break;
						}
						
						ds_queue_enqueue(queue,[new_x,new_y]);
						ds_grid_set(grid_visited,new_x,new_y,1);
					}				
				}
			}
			
			if (found_it) break;
		}
		
		ds_grid_destroy(grid_visited);
		ds_queue_destroy(queue);
		
		return final_pos;		
	}
	
	static calculate_path_to_point = function(_xstart, _ystart, _xgoal, _ygoal, _anywhere=false)
	{
		if (path_exists(current_path))
			path_delete(current_path);
		
		current_path = path_add();
		path_set_closed(current_path,false);
		
		if (_anywhere)
		{
			path_set_kind(current_path, 0);
			path_add_point(current_path,_xstart,_ystart,1);
			path_add_point(current_path,_xgoal,_ygoal,1);
			return current_path;
		}
		else //on walkareas
		{
			path_set_kind(current_path, 1);
			if (mp_grid_path(mp_grid, current_path, _xstart, _ystart, _xgoal, _ygoal, true) == true)
				return current_path;
			else return undefined;
		}
	}
	
	static room_start = function(_walkarea_manager)
	{
		update_mp_grid(_walkarea_manager);
	}
	
	static cleanup = function()
	{
		if (mp_grid != undefined)
			mp_grid_destroy(mp_grid)
		
		if (path_exists(current_path))
			path_delete(current_path);
	}
}