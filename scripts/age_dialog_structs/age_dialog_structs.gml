#macro __AGE_DLG_OPTN_FLG_STATE 0
#macro __AGE_DLG_OPTN_FLG_SAY 1
#macro __AGE_DLG_OPTN_FLG_WAS_CHOSEN 2

function Dialog(_dialog_manager) constructor
{
	//things to remember
	// * option 0 is the entry point for the dialog (@S in the dialog script)
	//     so the actual options start with number 1
	// * the individual dialogs have no stop() method because Dialog Manager handles the end of the conversation in its stop() method
	
	static manager = _dialog_manager; //the instance of the Dialog_Manager struct that controls this dialog
	
	script_name = ""; //the name used in TXR scripts to access this dialog
	
	option_text =   []; //the text for this option shown in the dialog GUI
	option_script = []; //the connected TXR script that is run when this option is selected
	option_flags =  []; //each entry is again an array [option_state, option_say, option_was_chosen]
	option_count =  0;  //stores the number of options for this dialog (e.g. 3 means that the dialog has 1 entry point + 2 actual options)
	
	dialog_counter = -1; //hacky way to find out if the dialog has been started for the first time in a conversation (and thus some flags need to be reset like option_was_chosen or option_off_for_now)
											 //see the same variable in Dialog_Manager for a description of how this works
	
	static start = function()
	{
		//if there is currently a dialog running then the start() command can only be called if another dialog hands the conversation over to this new dialog
		//the variable `handing_over_from_other_dialog` is only set to true in Dialog_Manager if goto_dialog() is called (can also be triggered from goto_previous())
		if ((manager.current_dialog != undefined) && (!manager.handing_over_from_other_dialog))
		{ show_debug_message("AGE: Can't start a new dialog while another dialog is currently active. Use dialog.stop() to end the current dialog first or if you are in a dialog script use current_dialog_goto_dialog(x) to change topics."); return; }
		
		//if the dialog is started for the first time in a conversation
		//then reset options that were set to `option_off_for_now`
		//and also reset option_was_chosen to false
		if (dialog_counter != manager.dialog_counter)
		{
			var i;
			for (i=1; i<option_count; i++)
			{
				if (option_flags[i][__AGE_DLG_OPTN_FLG_STATE] == age.option_off_for_now)
				{
					option_flags[i][__AGE_DLG_OPTN_FLG_STATE] = age.option_on;
				}
				
				option_flags[i][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = false;
			}
			
			dialog_counter = manager.dialog_counter;
		}
		
		//start dialog
		manager.current_dialog = self;
		manager.handing_over_from_other_dialog = false;
		manager.room_at_dialog_start = room;
		
		//if the dialog features an opening script then run that script
		if (option_script[0] != "")
		{
			manager.currently_executed_option = 0;
			
			var th;
			th = txr_run(option_script[0], txr_thread_type.dialog);
			if (th != -1) manager.currently_active_txr_thread = th;
		}
	}

	static get_option_state = function(_option_nr)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to get state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
		
		return option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE];
	}
	
	static set_option_state = function(_option_nr, _state)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to set state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
		
		//check if state change is valid
		if ((_state != age.option_on) && (_state != age.option_off) && (_state != age.option_off_for_now) && (_state != age.option_off_forever))
		{ show_debug_message("AGE: Can't set dialog option state. State has to be either `age.option_on`, `age.option_off`, `age.option_off_for_now`, or `age.option_off_forever`.");
			return; }
			
		if ((_state == age.option_on) && (option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] == age.option_off_forever))
			return;
		
		//set state
		option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] = _state;
	}
	
	static get_option_text = function(_option_nr) //we don't currently allow setting the option text because then all options would have to be saved with the game
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to get text of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
		
		return option_text[_option_nr];
	}
	
	static has_option_been_chosen = function(_option_nr)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to get chosen state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
		
		return option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN];
	}
	
	static set_has_option_been_chosen = function(_option_nr, _chosen)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to set chosen state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
		
		option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = _chosen;
	}
	
	//@DEBUG
	static debug_show_txr_script_for_option = function(_option_nr)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{ show_debug_message("AGE: Trying to get chosen state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return; }
			
		var s, i=1, n=1;
		s = string_copy(option_script[_option_nr],1,string_length(option_script[_option_nr]));
		while (string_pos_ext("\n",s,i) > 0)
		{
			i = string_pos_ext("\n",s,i);
			s = string_replace_at(s,i,"\n"+string(n)+")\t");
			n ++;
			i += 2;
		}
		show_debug_message(s);
	}
}

function Dialog_Manager() constructor
{
	//the actual inventory item structs are stored in o_age_main's dialogs[] array.
	//yes, this is not nicely decoupled - they could be stored in here, but it has some benefits if they are stored centrally
	//so it is important that this manager knows the central object (o_age_main) and can refer to it when it accesses the dialogs
	o = o_age_main;
	
	//remember to reset these variables in the stop() method
	current_dialog = undefined; //pointer to the current dialog struct
	previous_dialog = undefined; //pointer to the previous dialog struct (if a dialog is currently running)
	currently_executed_option = -1;
	currently_active_txr_thread = undefined; //pointer to the TXR thread that stores the currently running dialog script	
	options_are_displayed = false;
	handing_over_from_other_dialog = false; //is true only when one running dialog hands over to another dialog (set in goto_dialog() - which can also be triggered from goto_previous())
	room_at_dialog_start = noone; //tracks the room so that the dialog can be stopped if the room has been changed during the conversation
	
	//and now a hacky way to track whether a dialog has been restarted within an ongoing conversation or is started for the first time since the conversation has started
	//this is done by comparing the counter in the dialog (starting at -1) to this counter (starting at 0).
	//If it's not the same then the dialog has been started for the first time in this conversation (and its counter is adjusted to the current value and some flags are reset (e.g. option_chosen, state_off_for_now).
	//Once stop() is called the counter here is increased by one so when the next conversation starts the dialog's counter again doesn't match and its flags are reset again.
	dialog_counter = 0;
	
	static load_file = function(_filename)
	{
		//returns true if file was parsed successfully or false if there were errors during parsing
		//@TODO: should the function store the parsed dialogs locally until the parsing is finished and only then
		//transfer them to o_age_main? Right now, if a parse error happens, all the dialogs that have been parsed
		//already are stored in o_age_main and the other ones aren't.
		var buffer,lines,line,i,current_dialog=undefined,current_option_id=-1,current_script,opt,n,tt=[];
		
		//load file
		buffer = buffer_load(working_directory + _filename);	
		if (buffer == -1)
		{ show_debug_message("AGE: Dialog File `"+_filename+"` couldn't be loaded. File doesn't exist or is corrupt.");
			return false; }
		
		lines = buffer_read(buffer, buffer_string);
		buffer_delete(buffer);

		lines = string_split(lines,"\n");
		
		//add hacky way to trigger the saving of the last dialog at the end of the file
		array_push(lines,"===");
	
		n = array_length(lines);
		for (i=0; i<n; i++)
		{
			line = lines[i];
			
			//strip out comments
			if (string_pos("//",line) > 0)
				line = string_copy(line,1,string_pos("//",line)-1);
			
			//empty line
			if (string_trim(line) == "")
				continue;
			
			//new dialog
			if (string_starts_with(line,"==="))
			{
				//we have hit the start of a new dialog (or the end of file), so...
				
				//store the finished script that has been created for the last option of the *previous* dialog
				if (current_option_id != -1)
				{
					if (!string_ends_with(current_script,"return 0;")) current_script += "\ncurrent_dialog_return();\nreturn 0;"; //make sure that each option script ends with a return statement
					current_dialog.option_script[current_option_id] = current_script;
					current_option_id = -1;
				}
				
				// -------- this is where a finished dialog is transferred into the game ----------
				//create an instance variable for the finished struct of the *previous* dialog in o_age_main so that it can be accessed by TXR scripts
				//and add it to o_age_main's dialogs array so that it can be accessed by other resources
				if (current_dialog != undefined)
				{
					variable_instance_set(o,current_dialog.script_name,current_dialog);
					array_push(o.dialogs,current_dialog);
				}
				
				//then start a new dialog struct
				line = string_replace(line,"===","");
				current_dialog = new Dialog(self);
				current_dialog.script_name = string_trim(line);
			}
			
			//new dialog option (or opening text)
			else if (string_starts_with(line,"@"))
			{
				opt = string_char_at(line,2);
				
				//we have hit the start of a new option, so...					
				//store the finished script that has been created for the *previous* option
				if (current_option_id != -1)
				{
					if (!string_ends_with(current_script,"return 0;")) current_script += "\ncurrent_dialog_return();\nreturn 0;"; //make sure that each option script ends with a return statement
					current_dialog.option_script[current_option_id] = current_script;
				}
								
				//then start a new option and script				
				if (opt == "S") //line starts with @S
				{
					current_option_id = 0; //0 stands for the opening script that is run before the options are displayed
				}
				else //line starts with @1, @2, ...
				{
					current_option_id = real(opt);
					
					//set option description
					tt = string_split_ext(line,[" ","\t"],true,1);
					current_dialog.option_text[current_option_id] = string_trim(tt[1]);
					
					//set option state
					current_dialog.option_flags[current_option_id][__AGE_DLG_OPTN_FLG_STATE] = age.option_on;
					current_dialog.option_flags[current_option_id][__AGE_DLG_OPTN_FLG_SAY] = false;
					current_dialog.option_flags[current_option_id][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = false;
				}
				current_dialog.option_count ++;
				current_script = "";
			}
			
			//indented line signals that this line is written in actual TXR script, not in the special dialog script format
			//so no special parsing needed - just add the line to the end of the current option script
			else if ((string_starts_with(line, " ")) || (string_starts_with(line, "\t")))
				current_script += "\n" + string_trim_start(line);			
			
			else if (string_trim(line) == "return")
				current_script += "\ncurrent_dialog_return();\nreturn 0;";
			
			else if (string_trim(line) == "stop")
				current_script += "\ncurrent_dialog_stop();\nreturn 0;";
				
			else if (string_trim(line) == "goto-previous")
				current_script += "\ncurrent_dialog_goto_previous();\nreturn 0;";	

			else if (string_starts_with(line, "goto-dialog"))
			{
				tt = string_split(line," ",true,1);
				current_script += "\ncurrent_dialog_goto_dialog(" + string_trim(tt[1]) + ");\nreturn 0;";
			}
			
			else if (string_starts_with(line, "run-script"))
			{
				var scr;
				tt = string_split(line," ",true,1);
				scr = asset_get_index(string_trim(tt[1]));
				if (script_exists(scr)) current_script += "\n" + scr();
				else show_debug_message("AGE - Warning: Called dialog script `"+ string_trim(tt[1]) +"` doesn't exist.");
			}
			
			else if (string_starts_with(line, "option-on"))
			{
				tt = string_split(line," ",true,1);
				current_script += "\n" + current_dialog.script_name + ".set_option_state(" + string_trim(tt[1]) + ",eOptionOn);";
			}
			
			else if (string_starts_with(line, "option-off-forever")) //it's important that this check is done before "option-off" because they start with the same string
			{
				tt = string_split(line," ",true,1);
				current_script += "\n" + current_dialog.script_name + ".set_option_state(" + string_trim(tt[1]) + ",eOptionOffForever);";
			}
			
			else if (string_starts_with(line, "option-off-for-now")) //it's important that this check is done before "option-off" because they start with the same string
			{
				tt = string_split(line," ",true,1);
				current_script += "\n" + current_dialog.script_name + ".set_option_state(" + string_trim(tt[1]) + ",eOptionOffForNow);";
			}
			
			else if (string_starts_with(line, "option-off"))
			{
				tt = string_split(line," ",true,1);
				current_script += "\n" + current_dialog.script_name + ".set_option_state(" + string_trim(tt[1]) + ",eOptionOff);";
			}
			
			//line written in the dialog script format (character_name: line  - e.g. cHero: Look at me, I'm a hero!)
			//so convert the line into TXR script by adding the necessary TXR code around the building blocks
			else
			{
				try
				{
					tt = string_split(line,":",true,1);
					current_script += "\n" + string_trim(tt[0]) + @'.say("' + string_trim(tt[1]) + @'");';
				}
				catch(_error)
				{
					show_message("AGE: Error parsing dialog file `"+_filename+"`. Stopped at dialog `"+current_dialog.script_name+"` because the following line couldn't be parsed:\n"+line);
					return false
				}
			}
		}
		
		return true;
	}
	
	static return_to_options = function()
	{
		//stop execution of current option script
		if (currently_active_txr_thread != undefined)
		{
			txr_thread_destroy(currently_active_txr_thread);
			currently_active_txr_thread = undefined;
		}
		
		if (current_dialog == undefined)
		{ show_debug_message("AGE: Can't return to dialog options because no dialog is currently active.");
			return; }
		
		//end dialog if all options have been disabled
		var i,all_options_disabled=true;
		for (i=1; i<current_dialog.option_count; i++)
		{
			if (current_dialog.option_flags[i][__AGE_DLG_OPTN_FLG_STATE] == age.option_on)
				{ all_options_disabled = false; break; }
		}
		if (all_options_disabled) 
		{
			show_debug_message("AGE: All options for the current dialog have been disabled. Ending dialog.");
			if (current_dialog != undefined) stop();
			return;
		}
		
		//end dialog if the room has been changed while the option was active
		if (room != room_at_dialog_start)
		{
			show_debug_message("AGE: Room has been changed while the option was active. Ending dialog.");
			if (current_dialog != undefined) stop();
			return;
		}
		
		currently_executed_option = -1;
		options_are_displayed = true;
	}
	
	static goto_previous = function()
	{
		//stop execution of current option script
		if (currently_active_txr_thread != undefined)
		{
			txr_thread_destroy(currently_active_txr_thread);
			currently_active_txr_thread = undefined;
		}
		
		if (previous_dialog == undefined)
		{
			show_debug_message("AGE: Can't return to previous dialog. No previous dialog stored. Ending Dialog.");
			if (current_dialog != undefined) stop();
			return;
		}
		
		goto_dialog(previous_dialog);
	}
	
	static goto_dialog = function(_dialog)
	{
		//stop execution of current option script
		if (currently_active_txr_thread != undefined)
		{
			txr_thread_destroy(currently_active_txr_thread);
			currently_active_txr_thread = undefined;
		}
		
		if (current_dialog == undefined)
		{
			show_debug_message("AGE: Can't change dialogs because no dialog is currently active. Use start() first to start a dialog.");
			return;
		}
		
		if (!is_instanceof(_dialog,Dialog))
		{
			show_debug_message("AGE: Can't change dialog. The supplied dialog is not a valid dialog. Ending dialog.");
			if (current_dialog != undefined) stop();
			return;
		}
		
		previous_dialog = current_dialog;
		handing_over_from_other_dialog = true;
		currently_executed_option = -1;
		
		_dialog.start();
	}
	
	static stop = function()
	{
		if (current_dialog == undefined)
		{ show_debug_message("AGE: Can't stop dialog because no dialog is currently active.");
			return; }
		
		//stop execution of current option script
		if (currently_active_txr_thread != undefined)
		{
			txr_thread_destroy(currently_active_txr_thread);
		}	
		
		//reset variables
		current_dialog = undefined;
		previous_dialog = undefined;
		currently_executed_option = -1;
		options_are_displayed = false;
		currently_active_txr_thread = undefined;
		handing_over_from_other_dialog = false;
		room_at_dialog_start = noone;
		
		dialog_counter ++; //this counts up so that the next time a dialog is started it recognizes that a new conversation has started (as opposed to the dialog being started from within a running conversation)
	}
	
	static run_option = function(_option_nr)
	{
		//check if there is an active dialog
		if (current_dialog == undefined)
		{ show_debug_message("AGE: Can't run dialog option because there is currently no active dialog. Use start() first to start a dialog.");
			return false; }
		
		var d = current_dialog;
		
		//check if option is valid
		if ((_option_nr < 1) || (_option_nr > d.option_count-1))
		{ show_debug_message("AGE: Trying to run dialog option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(d.option_count-1)+"`.");
			return false; }
		
		//check if option is active
		if (d.option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] != age.option_on)
		{ show_debug_message("AGE: Can't run dialog option `"+string(_option_nr)+"` because it is deactivated.");
			return false; }
		
		//run option
		d.option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = true;
		
		options_are_displayed = false;
		currently_executed_option = _option_nr;
		
		var th;
		th = txr_run(d.option_script[_option_nr], txr_thread_type.dialog);
		if (th != -1)
		{
			currently_active_txr_thread = th;
			return true;
		}
		else return false;
	}
	
	static get_struct_by_name = function(_script_name)
	{
		if (!variable_instance_exists(o,_script_name))
			return undefined;
		
		var v = variable_instance_get(o, _script_name);
		
		if (is_instanceof(v, Dialog))
			return v;
		else
			return undefined;
	}
	
	static __cleanup = function()
	{
	}
}