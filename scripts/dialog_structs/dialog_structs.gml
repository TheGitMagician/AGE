function Dialog(dialog_manager) constructor
{
	static manager = dialog_manager; //the instance of the Dialog_Manager struct that controls this dialog
	
	script_name = ""; //the name used in TXR scripts to access this dialog
	
	options = []; //each entry is again an array: [option_text, option_script, option_state, option_say]
	
	static start = function()
	{
		if ((manager.current_dialog != undefined) && (!manager.handing_over_from_other_dialog))
		{
			show_debug_message("AGE: Can't start a new dialog while another dialog is currently active. Use stop() to end the current dialog first.");
			return;
		}
		else manager.handing_over_from_other_dialog = false;
		
		//if the dialog is started from scratch (and not started from goto_previous() or goto_dialog())
		//then reset options that were set to option_off_for_now
		if (manager.current_dialog == undefined)
		{
			var i;
			for (i=1; i<array_length(options); i++)
			{
				if (options[i][2] == age.option_off_for_now)
				{
					options[i][2] = age.option_on;
				}
			}
		}
		
		//start dialog
		manager.current_dialog = self;
		
		//if the dialog features an opening script then run that script
		if (options[0][1] != "")
		{
			var th;
			th = txr_run(options[0][1], txr_thread_type.dialog);
			if (th != -1) manager.currently_active_txr_thread = th;
		}
	}

	//private
	static __stop = function()
	{
		manager.current_dialog = undefined;
		manager.previous_dialog = undefined;
		manager.show_dialog_options = false;
		manager.currently_active_txr_thread = undefined;
		manager.current_dialog_was_stopped = false;
	}
	
	static run_option = function(_option_nr)
	{
		//check if there is an active dialog
		if (manager.current_dialog == undefined)
		{
			show_debug_message("AGE: Can't run dialog option because there is currently no active dialog. Use start() first to start a dialog.");
			return;
		}
		
		//check if option is valid
		if ((_option_nr <= 0) || (_option_nr > array_length(options)-1))
		{
			show_debug_message("AGE: Trying to run dialog option `"+string(_option_nr)+"` which is outside the allowed range: `1-"+string(array_length(options)-1)+"`.");
			return;
		}
		
		//check if option is active
		if (options[_option_nr][2] != age.option_on)
		{
			show_debug_message("AGE: Can't run dialog option `"+string(_option_nr)+"` because it is deactivated.");
			return;
		}		
		
		//run option
		manager.show_dialog_options = false;
		
		var th;
		th = txr_run(options[_option_nr][1], txr_thread_type.dialog);
		if (th != -1) manager.currently_active_txr_thread = th;
	}

	static set_option_state = function(_option_nr, _state)
	{		
		//check if option exists
		if ((_option_nr < 0) || (_option_nr > array_length(options)-1))
		{
			show_debug_message("AGE: Trying to run dialog option `"+string(_option_nr)+"` which is outside the allowed range: `0-"+string(array_length(options)-1)+"`.");
			return;
		}
		
		//check if state change is valid
		if ((_state != age.option_on) && (_state != age.option_off) && (_state != age.option_off_for_now) && (_state != age.option_off_forever))
		{
			show_debug_message("AGE: Can't set dialog option state. State has to be either `age.option_on`, `age.option_off`, `age.option_off_for_now`, or `age.option_off_forever`.");
			return;
		}
		if ((_state == age.option_on) && (options[_option_nr][2] == age.option_off_forever))
		{
			return;
		}
		
		//set state
		options[_option_nr][2] = _state;
	}

	//@DEBUG
	static debug_show_txr_script_for_option = function(_option_nr)
	{
		var s,i=1,n=1;
		s = string_copy(options[_option_nr][1],1,string_length(options[_option_nr][1]));
		while (string_pos_ext("\n",s,i) > 0)
		{
			i = string_pos_ext("\n",s,i);
			s = string_replace_at(s,i,"\n"+string(n)+") ");
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
	currently_active_txr_thread = undefined; //pointer to the TXR thread that stores the currently running dialog script	
	show_dialog_options = false;
	handing_over_from_other_dialog = false; //is true when one running dialog hands over to another dialog (e.g. via goto-previous or goto-dialog)
	current_dialog_was_stopped = false; //gets set to true if dialog.stop() was called from outside. Causes the current dialog to stop after the active script has finished
	
	static parse_dialog_file_into_database = function(_filename)
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
			
			//new dialog
			if (string_starts_with(line,"==="))
			{
				//we have hit the start of a new dialog (or the end of file), so...
				
				//store the finished script that has been created for the last option of the *previous* dialog
				if (current_option_id != -1)
				{
					current_dialog.options[current_option_id][1] = current_script;
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
					current_dialog.options[current_option_id][1] = current_script;
				}
								
				//then start a new script				
				if (o == "S") //line starts with @S
				{
					current_option_id = 0; //0 stands for the opening script that is run before the options are displayed
				}
				else //line starts with @1, @2, ...
				{
					current_option_id = real(o);
					
					//set option description
					tt = string_split_ext(line,[" ","\t"],true,1);
					current_dialog.options[current_option_id][0] = string_trim(tt[1]);
					
					//set option state
					current_dialog.options[current_option_id][2] = age.option_on;
				}
				current_script = "";
			}
			
			//comment
			else if (string_starts_with(line,"//"))
				continue;
			
			//empty line
			else if (string_trim(line) == "")
				continue;
			
			//indented line signals that this line is written in actual TXR script, not in the special dialog script format
			//so no special parsing needed - just add the line to the end of the current option script
			else if ((string_starts_with(line, " ")) || (string_starts_with(line, "\t")))
				current_script += "\n" + string_trim_start(line);			
			
			else if (string_trim(line) == "return")
				current_script += "\ncurrent_dialog_return();\nreturn 0;";
			
			else if (string_trim(line) == "stop")
				current_script += "\n" + current_dialog.script_name + ".__stop();\nreturn 0;";
				
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
		if (current_dialog == undefined)
		{
			show_debug_message("AGE: Can't return to dialog options because no dialog is currently active.");
			return;
		}
		
		if (current_dialog_was_stopped)
		{
			current_dialog.__stop();
			return;
		}
		
		show_dialog_options = true;
	}
	
	static goto_previous = function()
	{
		if (previous_dialog == undefined)
		{
			show_debug_message("AGE: Can't return to previous dialog. No previous dialog stored. Ending Dialog.");
			if (current_dialog != undefined) current_dialog.__stop();
			return;
		}
		
		if (current_dialog_was_stopped)
		{
			current_dialog.__stop();
			return;
		}
		
		goto_dialog(previous_dialog);
	}
	
	static goto_dialog = function(_dialog)
	{		
		if (current_dialog == undefined)
		{
			show_debug_message("AGE: Can't change dialogs because no dialog is currently active. Use start() first to start a dialog.");
			return;
		}
		
		if (current_dialog_was_stopped)
		{
			current_dialog.__stop();
			return;
		}
		
		if (!is_instanceof(_dialog,Dialog))
		{
			show_debug_message("AGE: Can't go to dialog `"+_dialog+"`. Not a valid dialog. Ending dialog.");
			if (current_dialog != undefined) current_dialog.__stop();
			return;
		}
		
		previous_dialog = current_dialog;
		handing_over_from_other_dialog = true;
		
		_dialog.start();
	}
	
	static stop = function()
	{
		if (current_dialog == undefined)
		{
			show_debug_message("AGE: Can't stop dialog because no dialog is currently active.");
			return;
		}
		
		//@TODO: this behavior might have to be customized depending from where the stop() method was called - see AGS manual for Dialog.Stop() 
		current_dialog_was_stopped = true;
	}
}