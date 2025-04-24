function Walkarea_Manager() constructor
{
	walkarea_mask = undefined;
	
	walkarea_ids = [c_blue,c_yellow,c_green,c_aqua];
	
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
		//this is then used to occupy the cells of the mp_grid of the Pathfinder
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
	}
	
	static is_point_on_walkarea = function(_x, _y)
	{
		//returns -1 if no walkarea was found at the point or the index of the walkarea found
		if (!surface_exists(walkarea_mask))
			return -1;
		
		var p = surface_getpixel(walkarea_mask,_x,_y);
		
		return (array_get_index(walkarea_ids,p))
	}
	
	static room_start = function()
	{
		update_walkarea_mask();
	}
	
	static debug_draw = function()
	{
		if (!surface_exists(walkarea_mask))
			return;
		
		//draw_set_alpha(0.5);
		draw_surface(walkarea_mask,0,0);
		draw_set_alpha(1);
	}
	
	static cleanup = function()
	{
		if (surface_exists(walkarea_mask))
			surface_free(walkarea_mask);
		
		if (sprite_exists(walkarea_sprite))
			sprite_delete(walkarea_sprite);
	}
}