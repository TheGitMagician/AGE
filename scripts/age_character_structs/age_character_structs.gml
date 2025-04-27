function Character() constructor
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
	
	sprite_left = noone;
	sprite_right = noone;	
	sprite_up = noone;
	sprite_down = noone;
	
	costume_walking = "";
	
	walking = false;
	//xend = 0;
	//yend = 0;
	walk_speed = 2;
	walk_anim_speed = 0.2;
	
	moving = false; //moving is walking without the walk animation
	
	movement_path = noone;
	movement_percent_along_path = 0; //0-1
	movement_check_direction_interval = 0.1;
	movement_next_direction_check = 0;
	movement_speed_on_path = 0;
	movement_speed_modifier = 1;
	
	direction = 0; //0=down, 1=up, 2=right, 3=left

	sprite_index = noone;
	image_index = 0;
	image_speed = 0;
	image_xscale = 1;
	
	costume_last_sprite = noone;
	
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
	talk_current_line = "";
	talk_textblock = undefined; //the ID of the textblock in o_gui that displays the speech text
	
	speech_color = c_white;
	
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
		
		
		if ((asset_down == -1) && (asset_down == -1) && (asset_right == -1) && (asset_left == -1))
		{
			var asset_index = asset_get_index(name);
			if (asset_index == -1)
			{ show_debug_message("AGE: `"+name+"` - No matching asset found for the animation. Asset must be the exact name or end in '_down', '_up', '_right', '_left'.");
				return; }
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
	
	static animate = function(_name, _speed, _repeat_style=age.once, _blocking=false, _direction=age.forward, _first_frame=0)
	{
		if (asset_get_type(_name) != asset_sprite)
		{ show_debug_message("AGE: `"+_name+"` - No matching sprite asset found for the animation.");
			return; }
		
		var asset_index = asset_get_index(_name);
		
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
		
		if (_blocking)
		{
			blocked = true;
			yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
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
	
	static face_direction = function(_dir)
	{
		image_xscale = ((_dir == AGE_DIR_LEFT) && (sprite_left == noone)) ? -1 : 1;
		
		switch (_dir)
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
	
	static change_room = function(_new_room, _x=-1, _y=-1, _dir=-1)
	{
		if (asset_get_type(_new_room) != asset_room)
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
			if (o_age_main.skipping_cutscene)
			{
				o_age_main.continue_skipping_cutscene_after_room_change = true;
				o_age_main.skipping_cutscene = false;
			}
			room_goto(current_room);			
		}
		else //if another character changes rooms then free its position on the mp_grid
		{
			if (solid) o_age_main.walkarea_manager.update_mp_grid();
		}
	}
	
	static say = function(text)
	{
		if (current_room != room)
		{ show_debug_message("AGE: Warning: Character `"+script_name+"` cannot say anything because it's not in the current room.");
			return; }
		
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
		
		talking = true;
		talk_duration_remaining = 20;
		talk_current_line = text;
		
		if (!o_age_main.skipping_cutscene)
			talk_textblock = o_gui.create_textblock(self,text,x,y-sprite_get_height(sprite_index),talk_duration_remaining);
		
		blocked = true;
		yield_manager = new TXR_Yield_Manager(txr_thread_current, true);
	}
	
	static walk = function(_xend,_yend,_blocking)
	{
		if (current_room != room)
		{ show_debug_message("AGE: Warning: Character `"+script_name+"` not moved because it's not in the current room.");
			return; }
		
		//temporarily disable solid flag and re-calculate walkarea mask (which automatically also updates the mp_grid)
		//this is necessary so that the character can start walking and isn't boxed in by its own blocking box in the pathfinding grid
		if (solid)
		{
			solid = false;
			o_age_main.walkarea_manager.update_walkarea_mask();
			solid = true;
		}
		
		var goal_pos = o_age_main.walkarea_manager.find_nearest_point_on_walkarea(_xend,_yend);
		
		var path = o_age_main.walkarea_manager.calculate_path_to_point(x,y,goal_pos[0],goal_pos[1]);
		
		if (path == noone)
		{ show_debug_message("AGE: Warning: No path to provided endpoint found.");
			return; }
				
		movement_path = path_duplicate(path); //path has to be duplicated because the original path gets freed from memory as soon as calculate_path_to_point() has finished
		movement_percent_along_path = 0;
		movement_next_direction_check = 0;
		movement_speed_modifier = 1;
		
		walking = true;
		
		image_index = 1;
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
	
		if (path_exists(movement_path))
		{
			path_delete(movement_path);
			movement_path = noone;
		}
		
		if (solid) o_age_main.walkarea_manager.update_mp_grid(); //occupy the new position of the character in the mp_grid
		
		walking = false;
		moving = false;
	}
	
	static add_inventory = function(_item, _quantity=1, _at_index=-1)
	{
		if (!is_instanceof(_item,Inventory_Item))
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
		if (!is_instanceof(_item,Inventory_Item))
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
		if (!is_instanceof(_item,Inventory_Item))
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
		if (!is_instanceof(_item,Inventory_Item))
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
		if (!is_instanceof(_item,Inventory_Item))
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
		if (!is_instanceof(_item,Inventory_Item))
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
		draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,1,0,c_white,1);
	}
	
	static __cleanup = function()
	{
		if (path_exists(movement_path))
			path_delete(movement_path);
	}
}

function Character_Manager() constructor
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
		
		var char = new Character();
	
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
					char.set_walking_costume(_settings_struct.walking_costume);
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
	
			if (char.animating)
				with (char) update_character_animation();
	
			if (char.talking)
				with (char) update_character_say();
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