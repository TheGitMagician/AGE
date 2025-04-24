function txr_run(_code, _thread_type=txr_thread_type.standard)
{
	var pg,th;
	
	//compile the code
	pg = txr_compile(_code);
	
	if (pg == undefined)
	{
		show_debug_message(txr_error);
		return -1;
	}
	//else show_debug_message(txr_program_print(pg));	

	//create a thread from the compiled code
	th = txr_thread_create(pg, undefined, _thread_type);
	
	//start the thread
	var result = undefined;
	switch (txr_thread_resume(th))
	{
		//the thread runs completely to the end without any blocking commands
		//in that case it can be destroyed immediately - unless it is a rep_exec or rep_exec_always which get restarted every frame!
		case txr_thread_status.finished:
			txr_error = "";
			result = th[txr_thread.result];
			if ((_thread_type != txr_thread_type.rep_exec) && (_thread_type != txr_thread_type.rep_exec_always))
				txr_thread_destroy(th);
			break;
		//the thread ran into an error while trying to execute it
		//the error message is shown and the thread destroyed
		case txr_thread_status.error:
			txr_error = th[txr_thread.result];
			show_debug_message(txr_error);
			txr_thread_destroy(th);
			return -1;
		//the other option is that the thread yields (because of a blocking AGE function).
		//in that case the thread is later resumed by TXR_Yield_Manager which also checks if it can be destroyed afterwards
	}
	//the variable `result` contains the return value of the finished script - in the case we need to use it
	
	
	
	return th;
}