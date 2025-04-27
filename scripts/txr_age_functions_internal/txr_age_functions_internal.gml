function txr_age_thread_resume(_thread)
{
	//this is a special version of txr_thread_resume()
	//it makes sure that the special thread types (like rep_exec or rep_exec_always) are handled correctly
	
	//returns whether the thread still exists after having been run
	//the thread keeps existing, if it is yielded by a blocking function or it is a rep_exec or rep_exec_always thread
	//which are kept in memory so that they can be restarted over and over
	
	//hint: TXR also provides a return value of the thread which is stored in _thread[txr_thread.result]
	//however, this function is focused on getting the thread running so it doesn't return this result
	//if you want to check it you have to call _thread[txr_thread.result] yourself after starting the thread 
	
	var thread_still_exists = true;
	
	switch (txr_thread_resume(_thread))
	{
		case txr_thread_status.finished:
			//the thread runs completely to the end without any blocking commands
			//in that case it can be destroyed immediately - unless it is a rep_exec or rep_exec_always which get restarted the next frame
			txr_error = "";
			result = _thread[txr_thread.result];
			if ((_thread[txr_thread.type] != txr_thread_type.rep_exec) && (_thread[txr_thread.type] != txr_thread_type.rep_exec_always))
			{
				thread_still_exists = false;
				txr_thread_destroy(_thread);				
			}
			break;
			
		case txr_thread_status.error:
			//the thread ran into an error while trying to execute it
			//the error message is shown and the thread destroyed
			thread_still_exists = false;
			txr_error = _thread[txr_thread.result];
			show_debug_message(txr_error);
			txr_thread_destroy(_thread);
			if (_thread[txr_thread.type] != txr_thread_type.rep_exec)
				o_age_main.thread_room_repeatedly_execute = undefined;
			else if (_thread[txr_thread.type] != txr_thread_type.rep_exec_always)
				o_age_main.thread_room_repeatedly_execute_always = undefined;
			break;				
		
		case txr_thread_status.yield:
			//special case for repeatedly_execute_always scripts: they must never yield because if they do,
			//it means that they contain a blocking function which is not allowed in these script
			if (_thread[txr_thread.type] != txr_thread_type.rep_exec_always)
				break;
			
			thread_still_exists = false;
			show_debug_message("AGE: repeatedly_execute_always script was stopped because it contains a blocking function which is not allowed.");
			txr_thread_destroy(_thread);
			o_age_main.thread_room_repeatedly_execute_always = undefined;
			break;
	}
	
	return thread_still_exists;
}