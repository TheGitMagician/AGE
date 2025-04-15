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

hat = o_hat; //@DEBUG!!!!!!!!!!!
hat_move_always = o_hat_move_always; //@DEBUG!!!!!!!!!!!

mx = mouse_x;
my = mouse_y;

cursor_mode = "walk";

thread_global_repeatedly_execute = undefined;

thread_room_repeatedly_execute = undefined;
thread_room_repeatedly_execute_always = undefined;

function create_character(script_name, settings_struct)
{
	var char = new Character();
	
	variable_instance_set(self,script_name,char); //add character's script name to instance variables so that it can be accessed by TXR
	array_push(characters, char); //add character reference to character array so that it can be processed in other events
	
	//apply settings to the character
	var i,s;
	s = variable_struct_get_names(settings_struct);
	for (i=0; i<array_length(s); i++)
	{
		switch (s[i])
		{
			case "starting_room":
				char.room_curr = settings_struct.starting_room;
				break;
			case "x":
				char.x = settings_struct.x;
				break;
			case "y":
				char.y = settings_struct.y;
				break;
			case "name":
				char.name = settings_struct.name;
				break;
			case "walking_costume":
				char.set_walking_costume(settings_struct.walking_costume);
				break;
		}
	}
}

//load all dialogs into memory
dialog = new Dialog_Manager();
dialog.load_file("dialogs.txt");