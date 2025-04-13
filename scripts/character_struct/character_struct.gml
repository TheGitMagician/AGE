function Character() constructor
{
	enabled = true;
	room_curr = undefined;
	room_prev = undefined;
	x = 0;
	y = 0;
	name = "Egon";
	
	blocked = false;
	
	sprite_left = noone;
	sprite_right = noone;	
	sprite_up = noone;
	sprite_down = noone;
	
	costume_walking = "";
	
	walking = false;
	xend = 0;
	yend = 0;
	walk_speed = 2;
	walk_anim_speed = 0.2;
	
	direction = 0; //0=down, 1=up, 2=right, 3=left

	sprite_index = noone;
	image_index = 0;
	image_speed = 0;
	image_xscale = 1;
	
	costume_last_sprite = noone;
	
	animating = false;
	animate_repeat_style = age.once;
	animate_direction = age.forward;
	animate_sprite_index_before_animation = noone;
	animate_image_index_before_animation = 0;
	animate_image_speed_before_animation = 0;
	
	static set_animation = function(name)
	{
		//@TODO: what happens if only _up and _right are supplied (or any other combination without _down)?
		//could this work with the binary trick 1,2,4,8 for the animation directions?
		var asset_down,asset_up,asset_right,asset_left;
		
		asset_down = asset_get_index(name+"_down");
		asset_up = asset_get_index(name+"_up");
		asset_right = asset_get_index(name+"_right");
		asset_left = asset_get_index(name+"_left");
		
		
		if ((asset_down == -1) && (asset_down == -1) && (asset_right == -1) && (asset_left == -1))
		{
			var asset_index = asset_get_index(name);
			if (asset_index == -1)
			{
				show_debug_message("AGE: `"+name+"` - No matching asset found for the animation. Asset must be the exact name or end in '_down', '_up', '_right', '_left'.");
				return;
			}
			sprite_down = asset_index;		
			sprite_up = asset_index;				
			sprite_right = asset_index;
			sprite_left = asset_index;
		}
		else if ((asset_down != -1) && (asset_up == -1) && (asset_right == -1) && (asset_left == -1))
		{
			sprite_down = asset_down;		
			sprite_up = asset_down;			
			sprite_right = asset_down;
			sprite_left = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right == -1) && (asset_left == -1))
		{
			sprite_down = asset_down;
			sprite_up = asset_up;			
			sprite_right = asset_down;
			sprite_left = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right != -1) && (asset_left == -1))
		{
			sprite_down = asset_down;
			sprite_up = asset_up;			
			sprite_right = asset_right;
			sprite_left = noone;
		}
		else
		{
			sprite_down = asset_down;
			sprite_up = asset_up;			
			sprite_right = asset_right;
			sprite_left = asset_left;
		}
	}
	
	static animate = function(_name, _speed, _repeat_style=age.once, _blocking=age.no_block, _direction=age.forward, _first_frame=0)
	{
		var asset_index = asset_get_index(_name);
		if (asset_index == -1)
		{
			show_debug_message("AGE: `"+_name+"` - No matching asset found for the animation. Asset must be the exact name.");
			return;
		}
		
		animate_sprite_index_before_animation = sprite_index;
		animate_image_index_before_animation = image_index;
		animate_image_xscale_before_animation = image_xscale;
		animate_image_speed_before_animation = image_speed;
		
		sprite_index = asset_index;
		
		if ((_direction == age.backward) && (_first_frame == 0)) image_index = sprite_get_number(sprite_index);
		else if (_direction == age.backward) image_index = _first_frame+1;
		else image_index = _first_frame;
		
		image_speed = _speed;
		image_xscale = 1;
		animate_repeat_style = _repeat_style;
		animate_direction = _direction;
		
		animating = true;
		
		if (_blocking == age.block)
		{
			blocked = true;
			txr_wait(-1);
		}
	}
	
	static release_animation = function()
	{
		set_animation(costume_walking);
	}
	
	static set_walking_costume = function(name)
	{
		costume_walking = name;
		set_animation(name);
		
		if (direction == 0) sprite_index = sprite_down;
		else if (direction == 1) sprite_index = sprite_up;
		else if (direction == 2) sprite_index = sprite_right;
		else if (direction == 3)
		{
			if (sprite_left == noone)
			{
				image_xscale = -1;
				sprite_index = sprite_right;
			}
			else
			{
				image_xscale = 1;
				sprite_index = sprite_left;
			}			
		}
	}
	
	static face_direction = function(dir)
	{
		image_xscale = ((dir == AGE_DIR_LEFT) && (sprite_left == noone)) ? -1 : 1;
		
		switch (dir)
		{
			case AGE_DIR_RIGHT:
				sprite_index = sprite_right;
				direction = 2;
				break;
			case AGE_DIR_LEFT:
				if (sprite_left == noone) sprite_index = sprite_right;
				else sprite_index = sprite_left;
				direction = 3;
				break;
			case AGE_DIR_UP:
			sprite_index = sprite_up;
			direction = 1;
			break;
			case AGE_DIR_DOWN:
			sprite_index = sprite_down;
			direction = 0;
			break;
		}
	}
	
	static change_room = function(new_room)
	{
		room_prev = room_curr;
		room_curr = new_room;
	}
	
	static say = function(text)
	{
		if (room_curr != room)
		{
			show_debug_message("AGE: Warning: Character `"+name+"` cannot say anything because it's not in the current room.");
			return;
		}
		
		var i,pos;
	
		//make sure GameMaker's newline characters are recognized
		text = string_replace_all(text,"\\n","\n");

		//replace [ characters with newline characters
		i = 1;
		pos = string_pos_ext("[", text, 1);
		while (pos != 0)
		{
			if (string_char_at(text,pos-1) != "\\") text = string_replace_at(text, pos, "\n");
			else text = string_delete(text, pos-1, 1);
			pos = string_pos_ext("[", text, pos);
		}
	
		//replace % characters with the matching additional argument (e.g. "Hello %", "World" -> "Hello World")
		i = 1;
		pos = string_pos_ext("%", text, 1);
		while (pos != 0)
		{
			if (string_char_at(text,pos-1) != "\\") text = string_replace_at(text, pos, string(argument[i++]));
			else text = string_delete(text, pos-1, 1);
			pos = string_pos_ext("%", text, pos);
		}
		
		var duration = 20;
		o_gui.show_text(x,y-sprite_get_height(sprite_index),text,duration);
		txr_wait(duration);
	}
	
	static walk = function(_xend,_yend,_blocking)
	{
		if (room_curr != room)
		{
			show_debug_message("AGE: Warning: Character `"+name+"` not moved because it's not in the current room.");
			return;
		}
		
		xend = _xend;
		yend = _yend;
		walking = true;
		
		var dir = point_direction(x,y,xend,yend);
		
		dir = ((((dir + 45) mod 360) + 360) mod 360) div 90;
		
		image_xscale = ((dir == 2) && (sprite_left == noone)) ? -1 : 1;
	
		switch (dir)
		{
	    case 0:
				sprite_index = sprite_right;
				direction = 2;
				break;
	    case 1:
				sprite_index = sprite_up;
				direction = 1;
				break;
	    case 2:
				if (sprite_left == noone) sprite_index = sprite_right;
				else sprite_index = sprite_left;
				direction = 3;
				break;
	    case 3:
				sprite_index = sprite_down;
				direction = 0;
				break;
		}
	
		image_index = 1;
		image_speed = walk_anim_speed;
		
		if (_blocking)
		{
			blocked = true;
			txr_wait(-1);
		}
	}
}