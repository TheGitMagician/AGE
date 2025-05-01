function AGE_Walkarea_Manager() constructor
{
	//@TODO: decide on the approach for updating the walkareas and mp_grid
	//1) update_walkarea_mask_original() and update_mp_grid_original() use a surface and surface_get_pixel() to check for walkarea IDs
	//and a dynamic sprite to populate the mp_grid
	//2) update_walkarea_mask() and update_walkarea_grid() use grids to store and check the walkarea IDs and populate the mp_grid
	//the original approach is faster to load but a bit slower when checking for walkarea IDs (because of surface_get_pixel()).
	//it also uses objects which could be used to set things like scale factors directly in the Room Editor
	//the new approach is slower to load but faster when checking for walkarea IDs and when updating the mp_grid whenever a character moves
	//since you often have to check for walkarea IDs and update the mp_grid when things move around I currently have decided to keep the new approach
	
	max_nr_walkareas = 10;
	
	mask_width = room_width; //@TODO these width and height values should be handed over by the constructor or be calculated from a scale factor that is handed over from the constructor
	mask_height = room_height;	
	mask_surface = noone; // the surface that stores the walkareas	
	mask_sprite = noone; //dynamic sprite of the walkarea surface that is created in update_walkarea_mask() and used in update_mp_grid() to populate the mp_grid
	
	walkarea_ids = [c_blue,c_yellow,c_green,c_aqua];
	
	grid_ids = ds_grid_create(mask_width,mask_height); //stores the IDs of the walkareas (-1=no walkarea, 0,1,2,...=walkarea indices)
	grid_mask = ds_grid_create(mask_width,mask_height); //used for the mp_grid (0=walkarea, 1=no walkarea / blocked by character or object)
	
	grid_scale_levels = ds_grid_create(max_nr_walkareas,mask_height); //this is a special grid because it only stores one column for each walkarea
	//each column stores the scale levels for one walkarea along the y-axis (1=standard scale, 0=invisible, 2=double size)
	
	//motion planning variables
	mp_grid = undefined;	
	current_path = noone;
	
	static update_walkarea_mask = function()
	{
		if (!surface_exists(mask_surface))
			mask_surface = surface_create(mask_width,mask_height);
		
		var elements, i, e, xx, yy, xscale, yscale, s, buffer, ix, iy, pixel;
		
		//clear grids
		ds_grid_clear(grid_ids,-1);
		ds_grid_clear(grid_mask,0);
		
		//create surface
		surface_set_target(mask_surface);			
		draw_clear_alpha(c_white,1);		
		
		//iterate through all layer sprites and draw them onto the surface
		elements = layer_get_all_elements("Walkareas");
		
		for (i=0; i<array_length(elements); i++)
		{
			e = elements[i];
			xx = layer_sprite_get_x(e);
			yy = layer_sprite_get_y(e);
			xscale = layer_sprite_get_xscale(e);
			yscale = layer_sprite_get_yscale(e);
			s = layer_sprite_get_sprite(e);
			
			draw_sprite_ext(s,0,xx,yy,xscale,yscale,0,c_white,1);
		}
		
		//convert surface to buffer
		buffer = buffer_create(4 * mask_width * mask_height, buffer_fixed, 1);
		buffer_get_surface(buffer, mask_surface, 0);
		
		//extract color data and write walkarea IDs to grid
		for (ix=0; ix<mask_width; ix++)
		{
			for (iy=0; iy<mask_height; iy++)
			{
				pixel = buffer_peek(buffer, 4 * (ix + iy * mask_width), buffer_u32); //extracts info in ABGR Format
				
				switch (make_color_rgb(pixel & $ff, (pixel >> 8) & $ff, (pixel >> 16) & $ff))
				{
					case c_blue:
						ds_grid_set(grid_ids,ix,iy,0);
						break;
					case c_yellow:
						ds_grid_set(grid_ids,ix,iy,1);
						break;
					default:
						ds_grid_set(grid_mask,ix,iy,1);
						break;
				}
			}
		}
		//a = (pixel >> 24) & $ff,    // Alpha [0-255]    
		//r = pixel & $ff,            // Red [0-255]  
		//g = (pixel >> 8) & $ff,     // Green [0-255]    
		//b = (pixel >> 16) & $ff;    // Blue [0-255] 
		
		//cleanup
		buffer_delete(buffer);		
		surface_reset_target();		
		//surface_free(mask_surface); //@TODO re-activate this line once bug #10520 is resolved
		
		//whenever the walkarea mask has been updated the mp_grid should also be populated freshly
		update_mp_grid();
	}

	static update_walkarea_mask_original = function()
	{
		if (!surface_exists(mask_surface))
			mask_surface = surface_create(mask_width,mask_height);
		
		var elements, i, e, xx, yy, xscale, yscale, s;
		
		surface_set_target(mask_surface);
			
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
			
			draw_sprite_ext(s,0,xx,yy,xscale,yscale,0,c_white,1);
		}
		
		surface_reset_target();
		
		mask_sprite = sprite_create_from_surface(mask_surface,0,0,surface_get_width(mask_surface),surface_get_height(mask_surface),true,false,0,0);
		sprite_collision_mask(mask_sprite,false,bboxmode_fullimage,0,0,0,0,bboxkind_precise,0);
		
		//whenever the walkarea mask has been updated the mp_grid should also be populated freshly
		update_mp_grid_original();
	}

	static is_point_on_walkarea = function(_x,_y)
	{
		if (mp_grid == undefined)
			return false;
		
		var r = mp_grid_get_cell(mp_grid,_x,_y);
		
		return (r == 0); //true for a cell on a walkarea, false otherwise
	}
	
	static point_get_walkarea_index = function(_x,_y)
	{
		return ds_grid_get(grid_ids,_x,_y);
		////returns -1 if there is no walkarea at the point or the index of the walkarea found
		//if (!is_point_on_walkarea(_x,_y))
		//	return -1;
		
		//if (!surface_exists(mask_surface))
		//	return -1;
		
		//var p = surface_getpixel(mask_surface,_x,_y);
		
		//return (array_get_index(walkarea_ids,p))
	}
	
	static set_scaling = function(_id,_min,_max)
	{
		if ((_id < 0) || (_id >= max_nr_walkareas))
		{ show_debug_message("AGE: set_scaling(): Invalid walkarea ID. Must be between 0 and "+string(max_nr_walkareas)+".");
			return; }
		
		if ((_min < 0) || (_min > 2) || (_max < 0) || (_max > 2))
		{ show_debug_message("AGE: set_scaling(): Invalid scale factor. Factors must be between 0 and 2.");
			return; }
		
		var start_y, end_y, ix, iy, height, i;
		
		//find top and bottom edges of walkarea
		start_y = -1;
		end_y = -1;
		for (iy=0; iy<mask_height; iy++)
		{
			for (ix=0; ix<mask_width; ix++)
			{
				if (ds_grid_get(grid_ids,ix,iy) == _id)
				{
					start_y = iy;
					break;
				}
			}
			
			if (start_y > -1)
				break;
		}
		
		for (iy=mask_height-1; iy>=0; iy--)
		{
			for (ix=0; ix<mask_width; ix++)
			{
				if (ds_grid_get(grid_ids,ix,iy) == _id)
				{
					end_y = iy;
					break;
				}
			}
			
			if (end_y > -1)
				break;
		}
			
		height = end_y - start_y;

		ds_grid_set_region(grid_scale_levels,_id,0,_id,mask_height-1,1);
		
		i=0;
		for (iy=start_y; iy<end_y; iy++)
		{
			ds_grid_set(grid_scale_levels, _id, iy, _min+((_max-_min)*(i/height)));
			i++;
		}
	}
	
	static get_scaling_at_walkarea_y = function(_id,_iy)
	{
		if ((_id < 0) || (_id >= max_nr_walkareas))
		{ show_debug_message("AGE: set_scaling(): Invalid walkarea ID. Must be between 0 and "+string(max_nr_walkareas)+".");
			return; }		
		
		return ds_grid_get(grid_scale_levels,_id,_iy);
	}
	
	static find_nearest_point_on_walkarea = function(_x,_y)
	{
		//uses breadth-first-search and returns an array - either [-1,-1] if no point was found or [x,y]
		if (mp_grid == undefined)
			return [-1,-1];
		
		if (mp_grid_get_cell(mp_grid,_x,_y) == 0)
			return [_x,_y];
		
		var grid_visited, queue, directions, pos, i, new_x, new_y, final_pos, found_it;
		
		grid_visited = ds_grid_create(mask_width,mask_height);
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
				
				if ((new_x >= 0) && (new_x < mask_width) && (new_y >= 0) && (new_y < mask_height))
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
	
	static update_mp_grid = function(_excluding=[])
	{
		//this function updates the mp_grid which is used for pathfinding
		//you can pass an array with character and object references that will be skipped when
		//the blocking boxes around characters/objects are added in the second part of this function
		//this is currently used in Character.walk() to stop the character that starts walking from
		//blocking himself from walking
		
		if (mp_grid == undefined)
			mp_grid = mp_grid_create(0,0,mask_width,mask_height,1,1);
		else
			mp_grid_clear_all(mp_grid);
		
		//transfer the mask grid (0=walkable area, 1=blocked area) into the mp_grid
		ds_grid_to_mp_grid(grid_mask,mp_grid);
		
		//go through all solid characters and objects in the room and add their blocking box to the mask
		var i,n,c,blocking_w,blocking_h,blocking_x,blocking_y;
		n = array_length(o_age_main.characters);
		for (i=0; i<n; i++)
		{
			c = o_age_main.characters[i];
			if ((c.current_room != room) || (!c.solid) || (array_get_index(_excluding,c) != -1))
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
	
	static update_mp_grid_original = function(_excluding=[])
	{
		//this function updates the mp_grid which is used for pathfinding
		//you can pass an array with character and object references that will be skipped when
		//the blocking boxes around characters/objects are added in the second part of this function
		//this is currently used in Character.walk() to stop the character that starts walking from
		//blocking himself from walking
		
		if (mask_surface == undefined)
			return;
		
		if (mp_grid == undefined)
			mp_grid = mp_grid_create(0,0,mask_width,mask_height,1,1);
		else
			mp_grid_clear_all(mp_grid);
		
		//the fastest way I have found so far to add the walkarea sprites to the mp_grid is to use the builtin function mp_grid_add_instances()
		//@TODO: could an alternative be to use a buffer that is created from the surface using buffer_get_surface() in combination with
		//a surface that is stored in surface_r8unorm format (so only one byte per pixel?)
		//for now:
		//create an instance of the walkarea helper object
		//create a dynamic sprite that holds the walkarea mask - with precise collision
		//apply the sprite to the object and use the instance of the object to occupy the grid cells 
		var iid = instance_create_layer(0,0,"Walkareas",o_walkarea_helper);		
		iid.sprite_index = mask_sprite;		
		mp_grid_add_instances(mp_grid,o_walkarea_helper,true);		
		instance_destroy(iid);
		
		//go through all solid characters and objects in the room and add their blocking box to the mask
		var i,n,c,blocking_w,blocking_h,blocking_x,blocking_y;
		n = array_length(o_age_main.characters);
		for (i=0; i<n; i++)
		{
			c = o_age_main.characters[i];
			if ((c.current_room != room) || (!c.solid) || (array_get_index(_excluding,c) != -1))
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
		if (!surface_exists(mask_surface))
			return;
		
		//draw_set_alpha(0.5);
		//draw_surface(mask_surface,0,0);
		//draw_set_alpha(1);
		
		draw_sprite(mask_sprite,0,0,0);
	}

	static __room_start = function()
	{
		update_walkarea_mask(); //this automatically also updates the mp_grid
	}
	
	static __room_end = function()
	{
		if (surface_exists(mask_surface)) //@TODO remove this block once bug #10520 is resolved
			surface_free(mask_surface);
	}
		
	static __cleanup = function()
	{
		if (surface_exists(mask_surface))
			surface_free(mask_surface);
		
		if (sprite_exists(mask_sprite))
			sprite_delete(mask_sprite);
		
		if (mp_grid != undefined)
			mp_grid_destroy(mp_grid)
		
		if (path_exists(current_path))
			path_delete(current_path);
			
		if (ds_exists(grid_ids,ds_type_grid))
			ds_grid_destroy(grid_ids);
		
		if (ds_exists(grid_mask,ds_type_grid))
			ds_grid_destroy(grid_mask);
			
		if (ds_exists(grid_scale_levels,ds_type_grid))
			ds_grid_destroy(grid_scale_levels);
	}
}