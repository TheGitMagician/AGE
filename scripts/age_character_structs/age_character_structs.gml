function AGE_Character() constructor
{
	script_name = "";
	
	enabled = true;
	current_room = undefined;
	previous_room = undefined;
	x = 0;
	y = 0;
	name = "";
	is_the_player = false;
	
	blocked = false;
	yield_manager = undefined;
	called_from_rep_exec_always = false;
	
	walk_sprite_left = noone;
	walk_sprite_right = noone;	
	walk_sprite_up = noone;
	walk_sprite_down = noone;
	
	current_costume = undefined;
	previous_costume = undefined;
	costume_sprites_left = [];
	costume_sprites_right = [];
	costume_sprites_up = [];
	costume_sprites_down = [];
	
	walking = false;
	walk_speed = 2;
	walk_anim_speed = 0.3;
	
	moving = false; //moving is walking without the walk animation
	
	movement_path = noone;
	movement_percent_along_path = 0; //0-1
	movement_check_direction_interval = 0.1;
	movement_next_direction_check = 0;
	movement_speed_on_path = 0;
	movement_speed_modifier = 1;
	
	direction = 0; //0=right, 1=up, 2=left, 3=down

	sprite_index = noone;
	image_index = 0;
	image_speed = 0;
	image_xscale = 1;
	
	scale_factor = 1;
	manual_scaling = false; //whether the character uses the scaling values of walkable areas or whatever the user sets `scale_factor` to
	
	solid = true;
	blocking_width = -1;
	blocking_height = -1;
	
	animating = false;
	animate_repeat_style = age.once;
	animate_direction = age.forward;
	animate_sprite_index_before_animation = noone;
	animate_image_index_before_animation = 0;
	animate_image_speed_before_animation = 0;
	
	inventory_items = []; //each entry is an array: [item_reference, quantity]
	active_inventory_item = undefined;
	
	talking = false;
	talk_duration_remaining = 0;
	talk_anim_speed = 0.3;
	talk_current_line = "";
	talk_textblock = undefined; //the ID of the textblock in o_gui that displays the speech text
	
	speech_color = c_white;
	
	separate_talking_head = false;
	talking_head_sprite_down = noone;
	talking_head_sprite_up = noone;
	talking_head_sprite_right = noone;
	talking_head_sprite_left = noone;
	talking_head_sprite_index = noone;
	talking_head_image_index = 0;
	
	//variables only needed for de/serialization
	movement_path_serialized = [];
	
	static set_animation = function(name)
	{
		//@TODO: what happens if only _up and _right are supplied (or any other combination without _down)?
		//could this work with the binary trick 1,2,4,8 for the animation directions?
		var asset_down,asset_up,asset_right,asset_left;
		
		asset_down = asset_get_index(name+"_down");
		asset_up = asset_get_index(name+"_up");
		asset_right = asset_get_index(name+"_right");
		asset_left = asset_get_index(name+"_left");
		
		
		if ((asset_down == -1) && (asset_up == -1) && (asset_right == -1) && (asset_left == -1))
		{
			var asset_index = asset_get_index(name);
			if (asset_index == -1)
			{ show_debug_message("AGE: `"+name+"` - No matching asset found for the animation. Asset must be the exact name or end in '_down', '_up', '_right', '_left'.");
				return; }
			walk_sprite_down = asset_index;		
			walk_sprite_up = asset_index;				
			walk_sprite_right = asset_index;
			walk_sprite_left = asset_index;
		}
		else if ((asset_down != -1) && (asset_up == -1) && (asset_right == -1) && (asset_left == -1))
		{
			walk_sprite_down = asset_down;		
			walk_sprite_up = asset_down;			
			walk_sprite_right = asset_down;
			walk_sprite_left = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right == -1) && (asset_left == -1))
		{
			walk_sprite_down = asset_down;
			walk_sprite_up = asset_up;			
			walk_sprite_right = asset_down;
			walk_sprite_left = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right != -1) && (asset_left == -1))
		{
			walk_sprite_down = asset_down;
			walk_sprite_up = asset_up;			
			walk_sprite_right = asset_right;
			walk_sprite_left = noone;
		}
		else
		{
			walk_sprite_down = asset_down;
			walk_sprite_up = asset_up;			
			walk_sprite_right = asset_right;
			walk_sprite_left = asset_left;
		}
	}
	
	static animate = function(_sprite, _speed, _repeat_style=age.once, _blocking=false, _direction=age.forward, _first_frame=0)
	{
		if (!sprite_exists(_sprite)) //a more robust check would be `if (asset_get_type(_name) != asset_sprite)` but that doesn't work on HTML5
		{ show_debug_message("AGE: `"+string(_sprite)+"` - No matching sprite asset found for the animation.");
			return; }
		
		//animate_sprite_index_before_animation = sprite_index;
		//animate_image_index_before_animation = image_index;
		//animate_image_xscale_before_animation = image_xscale;
		//animate_image_speed_before_animation = image_speed;
		costume_before_animation = current_costume;
		
		sprite_index = _sprite;
		
		if ((_direction == age.backward) && (_first_frame == 0)) image_index = sprite_get_number(sprite_index);
		else if (_direction == age.backward) image_index = _first_frame+1;
		else image_index = _first_frame;
		
		image_speed = _speed;
		image_xscale = 1;
		animate_repeat_style = _repeat_style;
		animate_direction = _direction;
		
		animating = true;
		__rep_exec_always_check();
		
		if (_blocking)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
		}
	}
	
	static release_animation = function()
	{
		//set_animation(costume_walking);
	}
	
	static define_costume = function(_costume, _sprite_name)
	{
		//@TODO: what happens if only _up and _right are supplied (or any other combination without _down)?
		//could this work with the binary trick 1,2,4,8 for the animation directions?
		var asset_down, asset_up, asset_right, asset_left, sprite_left, sprite_right, sprite_up, sprite_down, body_string;
		
		//check if the talking costume contains a separate talking head
		if ((_costume == age.costume_talk) && (asset_get_index(_sprite_name+"_body_down") != -1))
			body_string = "_body";
		else
			body_string = "";
		
		//read the sprite assets
		asset_down	= asset_get_index(_sprite_name + body_string + "_down");
		asset_up		=	asset_get_index(_sprite_name + body_string + "_up");
		asset_right	= asset_get_index(_sprite_name + body_string + "_right");
		asset_left	= asset_get_index(_sprite_name + body_string + "_left");
		
		//depending on which sprites (left, right, up, down) are available, assign the sprites to the costume
		if ((asset_down == -1) && (asset_up == -1) && (asset_right == -1) && (asset_left == -1))
		{
			var asset_index = asset_get_index(_sprite_name);
			if (asset_index == -1)
			{ show_debug_message("AGE: `"+_sprite_name+"` - No matching asset found for the animation. Asset must be the exact name or end in '_down', '_up', '_right', '_left'.");
				return; }
			costume_sprites_down[_costume] = asset_index;		
			costume_sprites_up[_costume] = asset_index;				
			costume_sprites_right[_costume] = asset_index;
			costume_sprites_left[_costume] = asset_index;
		}
		else if ((asset_down != -1) && (asset_up == -1) && (asset_right == -1) && (asset_left == -1))
		{
			costume_sprites_down[_costume] = asset_down;		
			costume_sprites_up[_costume] = asset_down;			
			costume_sprites_right[_costume] = asset_down;
			costume_sprites_left[_costume] = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right == -1) && (asset_left == -1))
		{
			costume_sprites_down[_costume] = asset_down;
			costume_sprites_up[_costume] = asset_up;			
			costume_sprites_right[_costume] = asset_down;
			costume_sprites_left[_costume] = asset_down;
		}
		else if ((asset_down != -1) && (asset_up != -1) && (asset_right != -1) && (asset_left == -1))
		{
			costume_sprites_down[_costume] = asset_down;
			costume_sprites_up[_costume] = asset_up;			
			costume_sprites_right[_costume] = asset_right;
			costume_sprites_left[_costume] = noone;
		}
		else
		{
			costume_sprites_down[_costume] = asset_down;
			costume_sprites_up[_costume] = asset_up;			
			costume_sprites_right[_costume] = asset_right;
			costume_sprites_left[_costume] = asset_left;
		}
		
		//if it's a talking costume with a separate talking head then save these sprites as well
		if ((_costume == age.costume_talk) && (body_string != ""))
		{
			separate_talking_head = true;
			
			if (asset_down != -1)		talking_head_sprite_down	= asset_get_index(_sprite_name + "_head_down");
			if (asset_up != -1)			talking_head_sprite_up		= asset_get_index(_sprite_name + "_head_up");
			if (asset_right != -1)	talking_head_sprite_right = asset_get_index(_sprite_name + "_head_right");
			if (asset_left != -1)		talking_head_sprite_left	= asset_get_index(_sprite_name + "_head_left");
		}
	}
	
	static change_costume = function(_costume)
	{
		previous_costume = current_costume;
		current_costume = _costume;
		
		image_index = 0;
		image_speed = 0;
		
		__update_sprites();
		
		//		if (walking)
		//{
		//	image_speed = walk_anim_speed;
		//	image_index = 1;
		//}
	}
	
	static face_direction = function(_dir)
	{
		direction = _dir;
		
		__update_sprites();
	}
	
	static face_location = function(_x, _y)
	{
		//calculate direction
		var dir = point_direction(x,y,_x,_y);
		
		if ((dir > 30) && (dir < 150))				direction = 1;
		else if ((dir > 210) && (dir < 330))	direction = 3;
		else if ((dir >= 150) && (dir <=210)) direction = 2;
		else																	direction = 0;
		
		face_direction(direction);
	}
	
	static change_room = function(_new_room, _x=-1, _y=-1, _dir=-1)
	{
		if (!room_exists(_new_room)) //a more robust check would be `if (asset_get_type(_new_room) != asset_room)` but that doesn't work on HTML5
		{ show_debug_message("AGE: Character.change_room(): Can't change room because room `"+string(_new_room)+"` doesn't exist.");
			return; }
		
		if (current_room == _new_room)
		{ show_debug_message("AGE: Character.change_room(): Can't change room because `"+script_name+"`is already in room `"+room_get_name(current_room)+"`.");
			return; }
		
		if (_x != -1) x = _x;
		if (_y != -1) y = _y;
		if (_dir != -1) face_direction(_dir);
		
		previous_room = current_room;
		current_room = _new_room;		
		
		if (is_the_player) //if the player character changes rooms then the new room has to be loaded
		{
			//stop movement of all characters/objects in the current room
			stop_moving();
			
			var i,n;
			n = array_length(o_age_main.characters);
			for (i=0; i<n; i++)
				if ((o_age_main.characters[i].current_room == room) && (o_age_main.characters[i].moving)) o_age_main.characters[i].stop_moving();
			
			n = array_length(o_age_main.objects);
			for (i=0; i<n; i++)
				if ((o_age_main.objects[i].in_room == room) && (o_age_main.objects[i].moving)) o_age_main.objects[i].stop_moving();
			
			//if a cutscene is currently active and being skipped a little "detour" is necessary
			//because the room change only happens at the end of the current event
			if (o_age_main.skipping_cutscene) 
			{
				o_age_main.continue_skipping_cutscene_after_room_change = true;
				o_age_main.skipping_cutscene = false;
			}
			
			//finally go to the new room
			room_goto(current_room);			
		}
		else //if another character changes rooms then occupy/free its position on the mp_grid
		{
			if (solid) o_age_main.walkarea_manager.update_mp_grid();
			
			if (current_room == room) //character enters the currently active room
			{
				__update_scale_level();
			}
		}
	}
	
	static say = function(_text, _blocking=true)
	{
		if (current_room != room)
		{ show_debug_message("AGE: Warning: Character `"+script_name+"` cannot say anything because it's not in the current room.");
			return; }
		
		var talking_head_height = 0;
		
		__parse_text(_text)
		
		talking = true;
		__rep_exec_always_check();
		
		talk_duration_remaining = floor(min(10,string_length(_text)) / o_age_main.text_reading_speed * game_get_speed(gamespeed_fps));
		talk_current_line = _text;
		
		change_costume(age.costume_talk);
		
		if (separate_talking_head)
			talking_head_height = sprite_get_height(talking_head_sprite_index);
		
		if (!o_age_main.skipping_cutscene)
			talk_textblock = o_gui.create_textblock(self,_text,x,y-sprite_get_height(sprite_index)-talking_head_height);
		
		if (_blocking)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
		}
	}
	
	static say_background = function(_text)
	{
		say(_text,false);
	}
	
	static walk = function(_xend,_yend,_blocking)
	{
		if (current_room != room)
		{ show_debug_message("AGE: Warning: Character `"+script_name+"` not moved because it's not in the current room.");
			return; }
		
		//temporarily disable solid flag and re-calculate walkarea mask (which automatically also updates the mp_grid)
		//this is necessary so that the character can start walking and isn't boxed in by its own blocking box in the pathfinding grid
		//if (solid)
		//{
		//	solid = false;
		//	o_age_main.walkarea_manager.update_walkarea_mask();
		//	solid = true;
		//}
		o_age_main.walkarea_manager.update_mp_grid([self]);
		
		var goal_pos = o_age_main.walkarea_manager.find_nearest_point_on_walkarea(_xend,_yend);
		
		var path = o_age_main.walkarea_manager.calculate_path_to_point(x,y,goal_pos[0],goal_pos[1]);
		
		if (path == noone)
		{ show_debug_message("AGE: Warning: No path to provided endpoint found.");
			return; }
				
		movement_path = path_duplicate(path); //path has to be duplicated because the original path gets freed from memory as soon as calculate_path_to_point() has finished
		movement_percent_along_path = 0;
		movement_next_direction_check = 0;
		movement_speed_modifier = 1;
		
		moving = true;
		walking = true;
		__rep_exec_always_check();
		
		image_index = 1; //because frame 0 in the walking sprite is the standing frame
		image_speed = walk_anim_speed;
		
		movement_speed_on_path = walk_speed / path_get_length(movement_path);
		
		if (_blocking)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
		}
	}
		
	static stop_moving = function()
	{
		if (walking)
		{
			image_index = 0;
			image_speed = 0;
		}
		
		if (!animating)
		{
			__update_sprites();
		}
	
		if (path_exists(movement_path))
		{
			path_delete(movement_path);
			movement_path = noone;
		}
		
		walking = false;
		moving = false;
		
		if (solid) o_age_main.walkarea_manager.update_mp_grid(); //occupy the new position of the character in the mp_grid		
	}
	
	static add_inventory = function(_item, _quantity=1, _at_index=-1)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
		{ show_debug_message("AGE: Character.add_inventory(): Supplied item is not a valid inventory item.");
			return; }
		
		if (_quantity <= 0)
		{ show_debug_message("AGE: Character.add_inventory(): Quantity has to be larger than 0.");
			return; }
		
		if ((_at_index < -1) || (_at_index > array_length(inventory_items)))
		{ show_debug_message("AGE: Character.add_inventory(): Insertion index outside the allowed range `-1 - "+string(array_length(inventory_items))+"`.");
			return; }
		
		var i, n=array_length(inventory_items), has_item_already_at_slot=-1;
		
		for (i=0; i<n; i++)
		{
			if (inventory_items[i][0] == _item)
			{ has_item_already_at_slot = i; break; }
		}		
		
		if (has_item_already_at_slot == -1)
		{
			//character doesn't have item yet
			//so add it to the end of the list or insert it at the given index
			if (_at_index == -1)	array_push(inventory_items, [_item, _quantity]);
			else									array_insert(inventory_items,_at_index, [_item, _quantity]);
		}
		else
		{
			//character has item already so increase its quantity
			if (_at_index != -1)
				show_debug_message("AGE: Character.add_inventory(): Character already has this inventory item at slot "+string(has_item_already_at_slot)+". Ignoring insertion index.");
			
			inventory_items[has_item_already_at_slot][1] += _quantity;
		}
		
		//@TODO: trigger update of inventory UI?
		
		//@TODO: trigger an on_event for inventory_add
	}
	
	static lose_inventory = function(_item, _quantity=1)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
			{ show_debug_message("AGE: Character.lose_inventory(): Supplied item is not a valid inventory item.");
				return; }
		
		if (_quantity <= 0)
			{ show_debug_message("AGE: Character.lose_inventory(): Quantity has to be larger than 0.");
				return; }
		
		var i, n=array_length(inventory_items), item_is_at_slot=-1;
		
		for (i=0; i<n; i++)
		{
			if (inventory_items[i][0] == _item)
			{ item_is_at_slot = i; break; }
		}
		
		if (item_is_at_slot == -1)
			{ show_debug_message("AGE: Character.lose_inventory(): Character doesn't have item "+_item.script_name+".");
				return; }
		
		var original_quantity_of_item = inventory_items[item_is_at_slot][1];
		
		//remove the supplied quantity of the item
		inventory_items[item_is_at_slot][1] -= _quantity;
		
		if (inventory_items[item_is_at_slot][1] < 0)
			show_debug_message("AGE: Character.lose_inventory(): Character only had "+string(original_quantity_of_item)+" of item `"+_item.script_name+"`. Removed all of them. Maybe check the quantity before removing the item.");
		
		//if none of the item is remaining then remove the inventory slot
		if (inventory_items[item_is_at_slot][1] <= 0)
			array_delete(inventory_items,item_is_at_slot,1);
		
		if (active_inventory_item == _item)
			active_inventory_item = undefined;
			//@TODO: force update of cursor mode?
		
		//@TODO: trigger update of inventory UI?
		
		//@TODO: trigger an on_event for inventory_lose
	}
	
	static __set_active_inventory_item = function(_item)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
		{ show_debug_message("AGE: Character.active_inventory_item: Supplied item is not a valid inventory item.");
			return; }
			
		//can be set to an item or to `undefined`
		if ((_item != undefined) && (!has_inventory_item(_item)))
		{ show_debug_message("AGE Character.active_inventory_item: Can't set active inventory item because the character doesn't have it.");
			return; }
			
		active_inventory_item = _item;
		
		//TODO: change cursor mode?
		
		//TODO: trigger update of inventory UI?		
	}
	
	static has_inventory_item = function(_item)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
		{ show_debug_message("AGE: Character.has_inventory_item():  The supplied item is not a valid inventory item.");
			return false; }
		
		var i, n=array_length(inventory_items);
		for (i=0; i<n; i++)
		{
			if (inventory_items[i][0] == _item)
				return true;
		}
		return false;
	}
	
	static get_inventory_quantity = function(_item)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
		{ show_debug_message("AGE: Character.get_inventory_quantity(): Supplied item is not a valid inventory item.");
			return 0; }
		
		var i, n=array_length(inventory_items);
		for (i=0; i<n; i++)
		{
			if (inventory_items[i][0] == _item)
				return inventory_items[i][1];
		}
		return 0;
	}
	
	static set_inventory_quantity = function(_item, _quantity)
	{
		if (!is_instanceof(_item,AGE_Inventory_Item))
		{ show_debug_message("AGE: Character.set_inventory_quantity():  The supplied item is not a valid inventory item.");
			return; }
			
		if (_quantity < 0)
		{ show_debug_message("AGE: Character.set_inventory_quantity():  Quantity must be 0 or a positive number.");
			return; }
		
		var i, n=array_length(inventory_items), item_is_at_slot=-1;
		for (i=0; i<n; i++)
		{
			if (inventory_items[i][0] == _item)
			{ item_is_at_slot = i; break; }
		}
		
		//new item is added
		if ((item_is_at_slot == -1) && (_quantity > 0))
		{
			array_push(inventory_items, [_item, _quantity]);
			return
		}
		
		//existing item's quantity is modified
		if ((item_is_at_slot != -1) && (_quantity > 0))
		{
			inventory_items[item_is_at_slot][1] = _quantity;
			return;
		}
		
		//existing item is removed because quantity is 0
		if ((item_is_at_slot != -1) && (_quantity == 0))
		{
			array_delete(inventory_items, item_is_at_slot, 1);
			
			if (active_inventory_item == _item)
			active_inventory_item = undefined;
			
			return;
			//@TODO: force update of cursor mode?
		
			//@TODO: trigger update of inventory UI?
		
			//@TODO: trigger an on_event for inventory_lose
		}
	}
	
	static set_as_player = function()
	{
		if (o_age_main.player == self)
		{ show_debug_message("AGE: Character.set_as_player(): `"+script_name+"` already is the player character.");
			return; }
		
		var i,n;
		n = array_length(o_age_main.characters);
		for (i=0; i<n; i++)
			o_age_main.characters[i].is_the_player = false;
		
		is_the_player = true;
				
		o_age_main.player = self;
		
		if (current_room != room)
		{
			if (o_age_main.skipping_cutscene)
			{
				o_age_main.continue_skipping_cutscene_after_room_change = true;
				o_age_main.skipping_cutscene = false;
			}
			room_goto(current_room);
		}
	}
	
	static __update_sprites = function()
	{
		image_xscale = ((direction == 2) && (costume_sprites_left[current_costume] == noone)) ? -1 : 1;
	
		switch (direction)
		{
			case 0:
				sprite_index = costume_sprites_right[current_costume];
				break;
			case 1:
				sprite_index = costume_sprites_up[current_costume];
				break;
			case 2:
				if (costume_sprites_left[current_costume] == noone) sprite_index = costume_sprites_right[current_costume];
				else sprite_index = costume_sprites_left[current_costume];
				break;
			case 3:
				sprite_index = costume_sprites_down[current_costume];
				break;
		}
		
		//update talking head
		if ((current_costume == age.costume_talk) && (separate_talking_head))
		{
			talking_head_image_index = 0;
			
			switch (direction)
			{
				case 0:
					talking_head_sprite_index = talking_head_sprite_right;
					break;
				case 1:
					talking_head_sprite_index = talking_head_sprite_up;
					break;
				case 2:
					if (costume_sprites_left[current_costume] == noone) talking_head_sprite_index = talking_head_sprite_right;
					else talking_head_sprite_index = talking_head_sprite_left;
					break;
				case 3:
					talking_head_sprite_index = talking_head_sprite_down;
					break;
			}
		}
	}
	
	static __update_scale_level = function()
	{
		if (current_room != room) return;
		if (manual_scaling) return;

		var w = o_age_main.walkarea_manager.point_get_walkarea_index(x,y);
		if (w > -1) scale_factor = o_age_main.walkarea_manager.get_scaling_at_walkarea_y(w,y);
	}
	
	static __rep_exec_always_check = function()
	{
		//this method is only used in functions which have an ongoing effect (e.g. walking, moving, talking)
		//this flag is then checked when the object is updated to make sure that the effect continues running even if the game is blocked
		//if - and only if - the function was started from a rep_exec_always script
		if (txr_thread_current[txr_thread.type] == txr_thread_type.rep_exec_always) called_from_rep_exec_always = true;
	}
	
	static __parse_text = function(_text)
	{
		var text = _text;
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
	}
	
	static __serialize = function()
	{
		//save current movement path by turning its points into an array and saving that
		if (path_exists(movement_path))
		{
			movement_path_serialized = age_convert_path_to_array(movement_path);
		}
	}
	
	static __deserialize = function()
	{
		//load current movement path by turing the saved array into a path resource
		if (array_length(movement_path_serialized) > 0)
		{
			movement_path = age_convert_array_to_path(movement_path_serialized);
			movement_path_serialized = [];
		}
	}
	
	static __draw = function()
	{
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale*scale_factor,scale_factor,0,c_white,1);

		if ((current_costume == age.costume_talk) && (separate_talking_head))
			draw_sprite_ext(talking_head_sprite_index,talking_head_image_index,x,y,image_xscale*scale_factor,scale_factor,0,c_white,1);
	}
	
	static __cleanup = function()
	{
		if (path_exists(movement_path))
			path_delete(movement_path);
	}
}

function AGE_Character_Manager() constructor
{
	//the actual character structs are stored in o_age_main's characters[] array.
	//yes, this is not nicely decoupled - they could be stored in here, but it has some benefits if they are stored centrally
	//so it is important that this manager knows the central object (o_age_main) and can refer to it when it accesses the characters
	o = o_age_main;
	
	static create = function(_script_name, _settings_struct)
	{
		if (variable_instance_exists(o,_script_name))
		{ show_debug_message("AGE: Can't create character `"+_script_name+"` because the script name already exists.");
			return; }
		
		var char = new AGE_Character();
	
		variable_instance_set(o,_script_name,char); //add character's script name to o_age_main's variables so that it can be accessed by TXR
		array_push(o.characters, char); //add character reference to o_age_main's characters array so that it can be accessed by other resources
	
		char.script_name = _script_name;
	
		//apply settings to the character
		var i,s;
		s = variable_struct_get_names(_settings_struct);
		for (i=0; i<array_length(s); i++)
		{
			switch (s[i])
			{
				case "starting_room":
					char.current_room = _settings_struct.starting_room;
					break;
				case "x":
					char.x = _settings_struct.x;
					break;
				case "y":
					char.y = _settings_struct.y;
					break;
				case "name":
					char.name = _settings_struct.name;
					break;
				case "walking_costume":
					char.define_costume(age.costume_walk,_settings_struct.walking_costume);
					break;
				case "talking_costume":
					char.define_costume(age.costume_talk,_settings_struct.talking_costume);
					break;
				case "speech_color":
					char.speech_color = _settings_struct.speech_color;
					break;
				case "is_player_character":
					char.is_the_player = _settings_struct.is_player_character;
					o.player = char;
					break;
			}
		}
		
		char.change_costume(age.costume_walk);
	}
	
	static __step = function()
	{
		var i,n,char;
		n = array_length(o.characters);
		for (i=0; i<n; i++)
		{
			char = o.characters[i];
	
			if ((char.current_room != room) || (char.enabled == false)) continue;
	
			//@TOOD: we're checking char.walking here but in update_character_move() there is another check. Only one is needed. Perhaps this one here is better.
			//same also with the other checks
			if (char.walking)
				with (char) update_character_move();
			
			if (char.talking)
				with (char) update_character_talk();
	
			if (char.animating)
				with (char) update_character_animation();			
		}
	}
	
	static __cleanup = function()
	{
		var i,n;
		n = array_length(o.characters);
		for (i=0; i<n; i++)
		{
			o.characters[i].__cleanup();
		}
	}
}