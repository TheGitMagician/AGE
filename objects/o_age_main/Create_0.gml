//constants used in AGE scripts
enum age
{
	forward,
	backward,
	once,
	loop,
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
	rep_exec_always,
	global_rep_exec,
	global_rep_exec_always,
	game_on_start
}

enum age_event
{
	//these values have to be powers of two because they are used to set the bitmask in the variable `event_claimed`
	rep_exec = 1,
	rep_exec_always = 2,
}

//@DEBUG
threads = 0;

function initialize_variables()
{
	if (!variable_instance_exists(self,"game_started"))
		game_started = false; //make sure that this variable is really only set if the game has never been run before
	
	blocked = false;
	
	event_claimed = 0; //stores the bitmask of events that have been claimed by using the values from the enum `age_event`

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
	thread_global_repeatedly_execute_always = undefined;

	thread_room_repeatedly_execute = undefined;
	thread_room_repeatedly_execute_always = undefined;

	//cutscene variables
	in_cutscene = false;
	skipping_cutscene = false;
	continue_skipping_cutscene_after_room_change = false;

	//savegame variables
	saving_the_game_was_requested = -1; //is set to the save slot that should be saved at and waits until the game can be saved (see Step Event)
	loading_the_game_was_requested = -1; //is set to the save slot that should be loaded and waits until the game can be loaded (see Step Event)
}

function initialize_game_managers()
{
	global_manager = new Global_Manager();
	character = new Character_Manager();
	object = new Object_Manager();
	inventory = new Inventory_Manager();
	dialog = new Dialog_Manager();

	walkarea_manager = new Walkarea_Manager();
}

function fast_forward()
{
	while (skipping_cutscene)
	{
		event_perform(ev_step,ev_step_normal);
	}
}

function start_game()
{
	if (game_started) return;
	
	var script_asset;

	script_asset = asset_get_index("game_on_start");
	if (script_exists(script_asset))
		txr_run(script_asset(), txr_thread_type.game_on_start);	
	
	game_started = true;
}

function unload_game()
{
	//since the game managers like Dialog_Manager don't hold any data on their own, they don't have to be re-initialized when the game is unloaded
	//only the variables have to be reset - which also means that all characters/inventory items/dialogs, etc. will be unloaded
	//since they are stored in the arrays in this object (like characters[])	
	
	unload_room_threads();
	unload_global_threads();
	
	initialize_variables();
}

function load_global_threads()
{
	var script_asset, th;

	#region GLOBAL_REPEATEDLY_EXECUTE
	script_asset = asset_get_index("global_repeatedly_execute");
	if (script_exists(script_asset))
	{
		//create the repeatedly_execute thread
		//this thread re-runs every frame until the room is left (at which point it is destroyed)
		th = txr_run(script_asset(), txr_thread_type.global_rep_exec);
		if (th != -1) thread_global_repeatedly_execute = th;
	}
	else
		thread_global_repeatedly_execute = undefined;
	#endregion
	
	#region GLOBAL_REPEATEDLY_EXECUTE_ALWAYS
	script_asset = asset_get_index("global_repeatedly_execute_always");
	if (script_exists(script_asset))
	{
		//create the repeatedly_execute_always thread
		//this thread re-runs every frame until the room is left (at which point it is destroyed)
		th = txr_run(script_asset(), txr_thread_type.global_rep_exec_always);
		if (th != -1) thread_global_repeatedly_execute_always = th;
	}
	else
		thread_global_repeatedly_execute_always = undefined;
	#endregion
}

function unload_global_threads()
{
	if (thread_global_repeatedly_execute != undefined)
	{
		txr_thread_destroy(thread_global_repeatedly_execute);
		thread_global_repeatedly_execute = undefined;
	}
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
	var i,n,s,j,b,filename;
	
	filename = "savegame_"+string(_slot)+".txt";
	
	//----serialization begin
	n = array_length(characters);
	for (i=0; i<n; i++)
		characters[i].__serialize();
	
	j = {};
	j.version = "0.1.0";
	j.datetime = date_current_datetime();
	j.characters = characters;
	j.objects = objects;
	j.inventory_items = inventory_items;		
	//----serialization end
	
	try
		s = json_stringify(j);
	catch(_e)
	{ show_debug_message("AGE: save_game(): Can't save. Couldn't convert game data into JSON string.");
		return false; }
	
	b = buffer_create(1, buffer_grow, 1);
	buffer_write(b, buffer_string, s);
	
	try
		buffer_save(b, working_directory+filename);
	catch(_e)
	{ show_debug_message("AGE: save_game(): Can't save. Couldn't write buffer to savegame file.");
		buffer_delete(b);
		return false; }
	
	buffer_delete(b);
	
	//f = file_text_open_write(working_directory+filename);
	//if (f == -1)
	//{ show_debug_message("AGE: save_game(): Can't save. Couldn't open text file for saving.");
	//	return false; }
	
	//file_text_write_string(f,s);
	
	//if (file_text_close(f) == false)
	//{ show_debug_message("AGE: save_game(): Can't save. Couldn't close text file for saving.");
	//	return false; }
	
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
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't open the savegame file.");
		return false; }
	
	try
		s = buffer_read(b,buffer_string);
	catch(_e)
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't read the content of the savegame file.");
		buffer_delete(b);
		return false; }
	
	buffer_delete(b);
	
	try	
		j = json_parse(s);
	catch(_e)
	{ show_debug_message("AGE: load_game(): Can't load. Couldn't generate game data from JSON string in the savegame file.");
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
		
		characters[i].__deserialize();
		
		variable_instance_set(self,characters[i].script_name,characters[i]); //add character's script name to instance variables so that it can be accessed by TXR
	}
	
	//load objects
	belongs_to_struct = static_get(Object);
	for (i=0; i<array_length(j.objects); i++)
	{
		array_push(objects,j.objects[i]); //add object reference to objects array so that it can be processed in other events
		
		static_set(objects[i],belongs_to_struct);
		
		variable_instance_set(self,objects[i].script_name,objects[i]); //add object's script name to instance variables so that it can be accessed by TXR
	}
	
	//load inventory items
	belongs_to_struct = static_get(Inventory_Item);
	for (i=0; i<array_length(j.inventory_items); i++)
	{
		array_push(inventory_items,j.inventory_items[i]); //add inventory item reference to inventory_items array so that it can be processed in other events
		
		static_set(inventory_items[i],belongs_to_struct);
		
		variable_instance_set(self,inventory_items[i].script_name,inventory_items[i]); //add inventory item's script name to instance variables so that it can be accessed by TXR
	}
	
	//check if a player character has been defined
	if (player == undefined)
	{ show_debug_message("AGE: load_game(): Can't load game. No character defined as the player character.");
		return false; }
		
	//load global threads
	load_global_threads();
	
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
//start_game() also has to be called - but ideally after all objects have been initialized, so currently it is stared in rm_init's Creation Code after all objects have been created
//load_global_threads() also has to be called - but ideally after all objects have been initialized, so currently it is stared in rm_init's Creation Code after all objects have been created