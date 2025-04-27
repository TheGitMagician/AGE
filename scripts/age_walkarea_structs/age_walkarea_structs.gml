function Walkarea_Manager() constructor
{
	walkarea_mask = undefined; // the surface that stores the walkareas
	walkarea_ids = [c_blue,c_yellow,c_green,c_aqua];
	walkarea_sprite = noone; //dynamic sprite of the walkarea surface that is created in update_walkarea_mask() and used in update_mp_grid() to populate the mp_grid
	
	//motion planning variables
	mp_grid = undefined;	
	current_path = noone;
	
	static update_walkarea_mask = function()
	{
		if (!surface_exists(walkarea_mask))
			walkarea_mask = surface_create(room_width,room_height);
		
		var elements, i, e, xx, yy, xscale, yscale, s;
		
		surface_set_target(walkarea_mask);
			
		draw_clear_alpha(c_white,1);
		
		elements = layer_get_all_elements("Walkareas");
		
		//the idea is that we go through all sprites on the room layer "Walkareas" and draw them onto the white background
		//the blend color is c_black so that all the sprites will be drawn completely black
		//finally a black pixel is drawn in the lower left corner of the surface
		//when the dynamic sprite is created this lower left corner is used as the transparent "background" color which is erased from the sprite
		//this leaves us with a white "hull" around the empty walkareas
		//this is then used to occupy the cells of the mp_grid
		//all the white areas block the mp_grid so that only the walkareas are left as valid target points for pathfinding
		
		//iterate through all layer sprites and draw them onto the surface in black
		for (i=0; i<array_length(elements); i++)
		{
			e = elements[i];
			xx = layer_sprite_get_x(e);
			yy = layer_sprite_get_y(e);
			xscale = layer_sprite_get_xscale(e);
			yscale = layer_sprite_get_yscale(e);
			s = layer_sprite_get_sprite(e);
			
			draw_sprite_ext(s,0,xx,yy,xscale,yscale,0,c_black,1);
		}
		
		//draw the pixel in the lower left corner in the color that will be erased from the image when it is turned into a dynamic sprite
		draw_set_color(c_black);
		draw_point(0,surface_get_height(walkarea_mask)-1);
		draw_set_color(c_white);
		
		surface_reset_target();
		
		walkarea_sprite = sprite_create_from_surface(walkarea_mask,0,0,surface_get_width(walkarea_mask),surface_get_height(walkarea_mask),true,false,0,0);
		sprite_collision_mask(walkarea_sprite,false,bboxmode_fullimage,0,0,0,0,bboxkind_precise,0);
		
		//whenever the walkarea mask has been updated the mp_grid should also be populated freshly
		update_mp_grid();
	}
	
	static is_point_on_walkarea = function(_x,_y)
	{
		if (mp_grid == undefined)
			return;
		
		var r = mp_grid_get_cell(mp_grid,_x,_y);
		
		return (r == 0); //true for a cell on a walkarea, false otherwise
	}
	
	static point_get_walkarea_index = function(_x,_y)
	{
		//returns -1 if there is no walkarea at the point or the index of the walkarea found
		if (!is_point_on_walkarea(_x,_y))
			return -1;
		
		if (!surface_exists(walkarea_mask))
			return -1;
		
		var p = surface_getpixel(walkarea_mask,_x,_y);
		
		return (array_get_index(walkarea_ids,p))
	}
	
	static find_nearest_point_on_walkarea = function(_x,_y)
	{
		//uses breadth-first-search and returns an array - either [-1,-1] if no point was found or [x,y]
		if (mp_grid == undefined)
			return [-1,-1];
		
		if (mp_grid_get_cell(mp_grid,_x,_y) == 0)
			return [_x,_y];
		
		var grid_visited, queue, directions, pos, i, new_x, new_y, final_pos, found_it;
		
		grid_visited = ds_grid_create(room_width,room_height);
		ds_grid_clear(grid_visited, 0);
		ds_grid_set(grid_visited,_x,_y,1);
		
		queue = ds_queue_create();
		ds_queue_enqueue(queue,[_x,_y]);
		
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
	
	static update_mp_grid = function()
	{
		if (walkarea_mask == undefined)
			return;
		
		if (mp_grid == undefined)
			mp_grid = mp_grid_create(0,0,room_width,room_height,1,1);
		else
			mp_grid_clear_all(mp_grid);
		
		//the fastest way I have found so far to add the walkarea sprites to the mp_grid is to use the builtin- function mp_grid_add_instances()
		//@TODO: could an alternative be to use a buffer that is created from the surface using buffer_get_surface() in combination with
		//a surface that is stored in surface_r8unorm format (so only one byte per pixel?)
		//for now:
		//create an instance of the walkarea helper object
		//create a dynamic sprite that holds the walkarea mask - with precise collision
		//apply the sprite to the object and use the instance of the object to occupy the grid cells 
		var iid = instance_create_layer(0,0,"Walkareas",o_walkarea_helper);		
		iid.sprite_index = walkarea_sprite;
		
		mp_grid_add_instances(mp_grid,o_walkarea_helper,true);
		//mp_grid_add_rectangle(mp_grid,0,0,200,200);
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
	
	static calculate_path_to_point = function(_xstart, _ystart, _xgoal, _ygoal)
	{
		//returns noone if no path was found or a path resource with the path to the goal 
		if (path_exists(current_path))
			path_delete(current_path);
		
		current_path = path_add();
		path_set_closed(current_path,false);
		path_set_kind(current_path, 0);
			
		//calculate the path to the goal
		if (mp_grid_path(mp_grid, current_path, _xstart, _ystart, _xgoal, _ygoal, true) == true)
		{
			//@TODO this reduction of path points leads to the problem that the paths can lead through non-walkable areas
			//if that happens and you try to start a new path exactly at that point, no valid path is found because the starting
			//coordinates are outside of walkable areas
			//one option would be to just reduce the resolution of the mp_grid
				
			//optimize path by reducing the number of path points to around 10%, keeping the first and last points intact
			//var nr,i,optimize_amount,counter;
				
			//nr = path_get_number(current_path);
				
			//optimize_amount = max(5,nr div 10); //remain around 10% of path points, a minimum of 5 points
			//counter = 0;
			//for (i=nr-2; i>0; i--)
			//{
			//	if (counter < optimize_amount)
			//	{
			//		path_delete_point(current_path,i);
			//		counter ++;
			//	}
			//	else
			//		counter = 0;
			//}
				
			return current_path;
		}				
		else return noone; //no path to goal could be found
	}
	
	static debug_draw = function() //@DEBUG
	{
		if (!surface_exists(walkarea_mask))
			return;
		
		//draw_set_alpha(0.5);
		//draw_surface(walkarea_mask,0,0);
		//draw_set_alpha(1);
		
		draw_sprite(walkarea_sprite,0,0,0);
	}
	
	static __room_start = function()
	{
		update_walkarea_mask(); //this automatically also updates the mp_grid
	}
		
	static __cleanup = function()
	{
		if (surface_exists(walkarea_mask))
			surface_free(walkarea_mask);
		
		if (sprite_exists(walkarea_sprite))
			sprite_delete(walkarea_sprite);
		
		if (mp_grid != undefined)
			mp_grid_destroy(mp_grid)
		
		if (path_exists(current_path))
			path_delete(current_path);
	}
}