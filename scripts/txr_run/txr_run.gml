function txr_run(_code, _thread_type=txr_thread_type.standard)
{
	//returns the pointer to the thread
	//or -1 if 
	//-there was a compile error
	//-the thread hasn't been started correctly because of an error
	//-the thread has started and then has already finished running because there were no blocking functions
	//-the thread is a rep_exec or rep_exec_always thread which is kept in memory so that it can be started over and over again
	
	var pg,th,thread_still_exists;
	
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
	thread_still_exists = txr_age_thread_resume(th);
	
	if (!thread_still_exists) return -1;
	
	return th;
}