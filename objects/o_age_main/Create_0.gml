//constants used in AGE scripts
enum age
{
	forward,
	backward,
	once,
	loop,
	block,
	no_block,
	sizeof,
	option_on,
	option_off,
	option_off_for_now,
	option_off_forever
}

//constants used for TXR threads
enum txr_thread_type
{
	standard,
	dialog,
	rep_exec,
	rep_exec_always
}

function initialize_variables()
{
	blocked = false;

	draw_order = [];

	characters = [];
	objects = [];
	inventory_items = [];
	dialogs = [];
	
	player = undefined;

	mx = mouse_x;
	my = mouse_y;

	cursor_mode = "walk";

	//repeatedly execute variables
	thread_global_repeatedly_execute = undefined;

	thread_room_repeatedly_execute = undefined;
	thread_room_repeatedly_execute_always = undefined;

	//cutscene variables
	in_cutscene = false;
	skipping_cutscene = false;

	//savegame variables
	saving_the_game_was_requested = -1; //is set to the save slot that should be saved at and waits until the game can be saved (see Step Event)
	loading_the_game_was_requested = -1; //is set to the save slot that should be loaded and waits until the game can be loaded (see Step Event)
}

function initialize_game_managers()
{
	//load global manager
	global_manager = new Global_Manager();

	//load all dialogs into memory
	dialog = new Dialog_Manager();
	dialog.load_file("dialogs.txt");

	//load walkarea manager
	walkarea_manager = new Walkarea_Manager();
	show_walkareas = false; //@DEBUG!!! also delete the other occurances

	pathfinder = new Pathfinder();
}

function create_character(_script_name, _settings_struct)
{
	if (variable_instance_exists(self,_script_name))
	{ show_debug_message("AGE: Can't create character `"+_script_name+"` because the script name already exists.");
		return; }
		
	var char = new Character();
	
	variable_instance_set(self,_script_name,char); //add character's script name to instance variables so that it can be accessed by TXR
	array_push(characters, char); //add character reference to characters array so that it can be processed in other events
	
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
				o_age_main.player = char;
				break;
		}
	}
}

function create_inventory_item(_script_name, _settings_struct)
{
	if (variable_instance_exists(self,_script_name))
	{ show_debug_message("AGE: Can't create inventory item `"+_script_name+"` because the script name already exists.");
		return; }
		
	var inv_item = new Inventory_Item();
	
	variable_instance_set(self,_script_name,inv_item); //add item's script name to instance variables so that it can be accessed by TXR
	array_push(inventory_items, inv_item); //add item reference to inventory_items array so that it can be processed in other events
	
	inv_item.script_name = _script_name;
	
	//apply settings to the inventory_item
	var i,s;
	s = variable_struct_get_names(_settings_struct);
	for (i=0; i<array_length(s); i++)
	{
		switch (s[i])
		{
			case "name":
				inv_item.name = _settings_struct.name;
				break;
			case "sprite":
				inv_item.sprite = _settings_struct.sprite;
				break;
		}
	}
}

function create_object(_script_name, _settings_struct)
{
	if (variable_instance_exists(self,_script_name))
	{ show_debug_message("AGE: Can't create object `"+_script_name+"` because the script name already exists.");
		return; }
	
	var obj = new Object();
	
	variable_instance_set(self,_script_name,obj); //add object's script name to instance variables so that it can be accessed by TXR
	array_push(objects, obj); //add oject reference to objects array so that it can be processed in other events
	
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

function fast_forward()
{
	while (skipping_cutscene)
	{
		event_perform(ev_step,ev_step_normal);
	}
}

function unload_game()
{
	//since the game manager like Dialog_Manager don't hold any data on their own, they don't have to be re-initialized when the game is unloaded
	//only the variables have to be reset - which also means that all characters/inventory items/dialogs, etc. will be unloaded
	//since they are stored in the arrays in this object (like characters[])
	unload_room_threads();
	
	initialize_variables();
}

function load_room_threads()
{
	var script_name, script_asset, th;

	#region REPEATEDLY_EXECUTE
	script_name = room_get_name(room);
	script_name = string_delete(script_name,1,3); //remove rm_ prefix
	script_name = "repeatedly_execute_"+script_name;
	script_asset = asset_get_index(script_name);
	if (script_exists(script_asset))
	{
		//create the repeatedly_execute thread
		//this thread re-runs every frame until the room is left (at which point it is destroyed)
		th = txr_run(script_asset(), txr_thread_type.rep_exec);
		if (th != -1) thread_room_repeatedly_execute = th;
	}
	else
		thread_room_repeatedly_execute = undefined;
	#endregion

	#region REPEATEDLY_EXECUTE_ALWAYS
	script_name = room_get_name(room);
	script_name = string_delete(script_name,1,3); //remove rm_ prefix
	script_name = "repeatedly_execute_always_"+script_name;
	script_asset = asset_get_index(script_name);
	if (script_exists(script_asset)){
		//create the repeatedly_execute thread
		//this thread re-runs every frame until the room is left (at which point it is destroyed)
	
		//additionaly also mark this thread as rep_exec_always so that the callees of this thread
		//know that they may perform code even when the game is blocked
		th = txr_run(script_asset(), txr_thread_type.rep_exec_always);
		if (th != -1) thread_room_repeatedly_execute_always = th;
	}
	else
		thread_room_repeatedly_execute_always = undefined;
	#endregion
}

function unload_room_threads()
{
	if (thread_room_repeatedly_execute != undefined)
	{
		txr_thread_destroy(thread_room_repeatedly_execute);
		thread_room_repeatedly_execute = undefined;
	}

	if (thread_room_repeatedly_execute_always != undefined)
	{
		txr_thread_destroy(thread_room_repeatedly_execute_always);
		thread_room_repeatedly_execute_always = undefined;
	}
}

function save_game(_slot)
{
	//returns true if saving was succesful
	
	//we don't have to check the validity of the savegame slot here because it is already checked in txr_save_game()
	var s,j,f,filename,i;
	
	filename = "savegame_"+string(_slot)+".txt";
	
	j = {};
	j.version = "0.1.0";
	j.datetime = date_current_datetime();
	j.characters = characters;
	j.inventory_items = inventory_items;
	
	
	
	//----serialization begin
	s = json_stringify(j);
	//for (i=0; i<array_length(characters); i++)
	//{
	//	s = json_stringify(characters[i]);
	//}
	
	//----serialization end
	
	//s = json_stringify(j);
	
	f = file_text_open_write(working_directory+filename);
	if (f == -1)
	{ show_debug_message("AGE: save_game(): Can't save. Couldn't open text file for saving.");
		return false; }
	
	file_text_write_string(f,s);
	
	if (file_text_close(f) == false)
	{ show_debug_message("AGE: save_game(): Can't save. Couldn't close text file for saving.");
		return false; }
	
	show_debug_message(current_time);
	return true;
}

function load_game(_slot)
{
	//returns true if saving was succesful
	
	//we don't have to check the validity of the savegame slot here because it is already checked in txr_load_game()
	var s,j,b,filename,i,belongs_to_struct;
	
	filename = "savegame_"+string(_slot)+".txt";
	
	b = buffer_load(working_directory+filename);
	if (b == -1)
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't open the text file for loading.");
		return false; }
	
	try
		s = buffer_read(b,buffer_string);
	catch(_e)
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't read content of text file for loading.");
		buffer_delete(b);
		return false; }
	
	buffer_delete(b);
	
	try	
		j = json_parse(s);
	catch(_e)
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't parse JSON string from file.");
		return false; }
	
	// ----- at this point the game data has successfully been read from the savefile -> now load it into the game -----
	unload_game();
	
	//load characters
	belongs_to_struct = static_get(Character);
	for (i=0; i<array_length(j.characters); i++)
	{
		array_push(characters,j.characters[i]); //add character reference to characters array so that it can be processed in other events
		
		static_set(characters[i],belongs_to_struct);
		if (characters[i].is_the_player)
			o_age_main.player = characters[i];
		
		variable_instance_set(self,characters[i].script_name,characters[i]); //add character's script name to instance variables so that it can be accessed by TXR
	}
	
	//load inventory items
	belongs_to_struct = static_get(Inventory_Item);
	for (i=0; i<array_length(j.inventory_items); i++)
	{
		array_push(inventory_items,j.inventory_items[i]); //add inventory item reference to inventory_items array so that it can be processed in other events
		
		array_push(inventory_items,j.inventory_items[i]);
		static_set(inventory_items[i],belongs_to_struct);
		
		variable_instance_set(self,inventory_items[i].script_name,inventory_items[i]); //add inventory item's script name to instance variables so that it can be accessed by TXR
	}
	
	//check if a player character has been defined
	if (player == undefined)
	{ show_debug_message("AGE: load_game(): Can't load game. No character defined as the player character.");
		return false; }
	
	//change rooms if necessary, else restart the current room
	if (player.current_room != room)
	{
		room_goto(room);
	}
	else
		event_perform(ev_other,ev_room_start);
	
	return true;
}

initialize_variables();
initialize_game_managers();