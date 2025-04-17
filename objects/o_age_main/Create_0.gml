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

blocked = false;

characters = [];
inventory_items = [];

hat = o_hat; //@DEBUG!!!!!!!!!!!
hat_move_always = o_hat_move_always; //@DEBUG!!!!!!!!!!!

mx = mouse_x;
my = mouse_y;

cursor_mode = "walk";

thread_global_repeatedly_execute = undefined;

thread_room_repeatedly_execute = undefined;
thread_room_repeatedly_execute_always = undefined;

function create_character(_script_name, _settings_struct)
{
	var char = new Character();
	
	variable_instance_set(self,_script_name,char); //add character's script name to instance variables so that it can be accessed by TXR
	array_push(characters, char); //add character reference to character array so that it can be processed in other events
	
	char.script_name = _script_name;
	
	//apply settings to the character
	var i,s;
	s = variable_struct_get_names(_settings_struct);
	for (i=0; i<array_length(s); i++)
	{
		switch (s[i])
		{
			case "starting_room":
				char.room_current = _settings_struct.starting_room;
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
		}
	}
}

function create_inventory_item(_script_name, _settings_struct)
{
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

//load all dialogs into memory
dialog = new Dialog_Manager();
dialog.load_file("dialogs.txt");