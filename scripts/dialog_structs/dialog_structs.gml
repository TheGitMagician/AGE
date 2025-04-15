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
	
	static start = function()
	{			
		if ((manager.current_dialog != undefined) && (!manager.handing_over_from_other_dialog))
		{
			show_debug_message("AGE: Can't start a new dialog while another dialog is currently active. Use dialog.stop() to end the current dialog first or if you are in a dialog script use current_dialog_goto_dialog(x) to change topics.");
			return;
		}
		
		manager.handing_over_from_other_dialog = false;
		
		//if the dialog is started from scratch (and not started from goto_previous() or goto_dialog())
		//then reset options that were set to option_off_for_now
		//and also reset all chosen states
		if (manager.current_dialog == undefined)
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
		}
		
		//start dialog
		manager.current_dialog = self;
		
		//if the dialog features an opening script then run that script
		if (option_script[0] != "")
		{
			manager.currently_executed_option = 0;
			
			var th;
			th = txr_run(option_script[0], txr_thread_type.dialog);
			if (th != -1) manager.currently_active_txr_thread = th;
		}
	}
	
	static get_option_count = function()
	{
		return option_count;
	}

	static get_option_state = function(_option_nr)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{
			show_debug_message("AGE: Trying to get state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return;
		}
		
		return option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE];
	}
	
	static set_option_state = function(_option_nr, _state)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{
			show_debug_message("AGE: Trying to set state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return;
		}
		
		//check if state change is valid
		if ((_state != age.option_on) && (_state != age.option_off) && (_state != age.option_off_for_now) && (_state != age.option_off_forever))
		{
			show_debug_message("AGE: Can't set dialog option state. State has to be either `age.option_on`, `age.option_off`, `age.option_off_for_now`, or `age.option_off_forever`.");
			return;
		}
		if ((_state == age.option_on) && (option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] == age.option_off_forever))
		{
			return;
		}
		
		//set state
		option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] = _state;
	}
	
	static get_option_text = function(_option_nr) //we don't currently allow setting the option text because then all options would have to be saved with the game
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{
			show_debug_message("AGE: Trying to get text of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return;
		}
		
		return option_text[_option_nr];
	}
	
	static get_has_option_been_chosen = function(_option_nr)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{
			show_debug_message("AGE: Trying to get chosen state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return;
		}
		
		return option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN];
	}
	
	static set_has_option_been_chosen = function(_option_nr, _chosen)
	{
		//check if option exists
		if ((_option_nr < 1) || (_option_nr > option_count-1))
		{
			show_debug_message("AGE: Trying to set chosen state of option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(option_count-1)+"`.");
			return;
		}
		
		option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = _chosen;
	}
	
	static get_script_name = function()
	{
		return script_name;
	}
	
	//@DEBUG
	static debug_show_txr_script_for_option = function(_option_nr)
	{
		var s,i=1,n=1;
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
	current_dialog = undefined; //pointer to the current dialog struct
	previous_dialog = undefined; //pointer to the previous dialog struct (if a dialog is currently running)
	currently_executed_option = -1;
	currently_active_txr_thread = undefined; //pointer to the TXR thread that stores the currently running dialog script	
	show_dialog_options = false;
	handing_over_from_other_dialog = false; //is true when one running dialog hands over to another dialog (e.g. via goto-previous or goto-dialog)
	
	static load_file = function(_filename)
	{
		var buffer,lines,line,i,current_dialog=undefined,current_option_id=-1,current_script,o,n,tt=[];
		
		//load file
		buffer = buffer_load(working_directory + _filename);	
		if (buffer == -1)
		{
			show_debug_message("AGE: Dialog File `"+_filename+"` couldn't be loaded. File doesn't exist or is corrupt.");
			return -1;
		}		
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
					
				//create an instance variable for the finished struct of the *previous* dialog so that it can be accessed by TXR scripts			
				if (current_dialog != undefined)
				{
					variable_instance_set(o_age_main,current_dialog.script_name,current_dialog);
				}
				
				//then start a new dialog struct
				line = string_replace(line,"===","");
				current_dialog = new Dialog(self);
				current_dialog.script_name = string_trim(line);
			}
			
			//new dialog option (or opening text)
			else if (string_starts_with(line,"@"))
			{
				o = string_char_at(line,2);
				
				//we have hit the start of a new option, so...					
				//store the finished script that has been created for the *previous* option
				if (current_option_id != -1)
				{
					if (!string_ends_with(current_script,"return 0;")) current_script += "\ncurrent_dialog_return();\nreturn 0;"; //make sure that each option script ends with a return statement
					current_dialog.option_script[current_option_id] = current_script;
				}
								
				//then start a new option and script				
				if (o == "S") //line starts with @S
				{
					current_option_id = 0; //0 stands for the opening script that is run before the options are displayed
				}
				else //line starts with @1, @2, ...
				{
					current_option_id = real(o);
					
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
				tt = string_split(line,":",true,1);
				current_script += "\n" + string_trim(tt[0]) + @'.say("' + string_trim(tt[1]) + @'");';
			}
		}
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
		{
			show_debug_message("AGE: Can't return to dialog options because no dialog is currently active.");
			return;
		}
		
		//end dialog if all options have been disabled
		var i,all_options_disabled=true;
		for (i=1; i<current_dialog.option_count; i++)
		{
			if (current_dialog.option_flags[i][__AGE_DLG_OPTN_FLG_STATE] == age.option_on)
			{
				all_options_disabled = false;
				break;
			}
		}
		if (all_options_disabled) 
		{
			show_debug_message("AGE: All options for the current dialog have been disabled. Ending dialog.");
			if (current_dialog != undefined) stop();
			return;
		}
		
		currently_executed_option = -1;
		show_dialog_options = true;
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
			show_debug_message("AGE: Can't go to dialog `"+_dialog+"`. Not a valid dialog. Ending dialog.");
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
		{
			show_debug_message("AGE: Can't stop dialog because no dialog is currently active.");
			return;
		}
		
		//stop execution of current option script
		if (currently_active_txr_thread != undefined)
		{
			txr_thread_destroy(currently_active_txr_thread);
		}	
		
		//reset variables
		current_dialog = undefined;
		previous_dialog = undefined;
		currently_executed_option = -1;
		show_dialog_options = false;
		currently_active_txr_thread = undefined;
		handing_over_from_other_dialog = false;
	}
	
	static run_option = function(_option_nr)
	{
		//check if there is an active dialog
		if (current_dialog == undefined)
		{
			show_debug_message("AGE: Can't run dialog option because there is currently no active dialog. Use start() first to start a dialog.");
			return false;
		}
		
		var d = current_dialog;
		
		//check if option is valid
		if ((_option_nr < 1) || (_option_nr > d.option_count-1))
		{
			show_debug_message("AGE: Trying to run dialog option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(d.option_count-1)+"`.");
			return false;
		}
		
		//check if option is active
		if (d.option_flags[_option_nr][__AGE_DLG_OPTN_FLG_STATE] != age.option_on)
		{
			show_debug_message("AGE: Can't run dialog option `"+string(_option_nr)+"` because it is deactivated.");
			return false;
		}
		
		//run option
		d.option_flags[_option_nr][__AGE_DLG_OPTN_FLG_WAS_CHOSEN] = true;
		
		show_dialog_options = false;
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
	
	static are_options_displayed = function()
	{
		return show_dialog_options;
	}
	
	static get_current_dialog = function()
	{
		return current_dialog;
	}
	
	static get_current_option = function()
	{
		return currently_executed_option;
	}
	
	static get_id_by_name = function(_script_name)
	{
		if (variable_instance_exists(o_age_main,_script_name))
			return variable_instance_get(o_age_main,_script_name);
		else
			return undefined;
	}
}