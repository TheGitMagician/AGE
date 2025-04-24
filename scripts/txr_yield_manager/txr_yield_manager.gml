function TXR_Yield_Manager(_thread, _blocking=true) constructor
{
	thread = _thread;
	blocking = _blocking;
	
	function yield_thread() //this function is automatically run when the struct is instantiated (see last line)
	{
		//stop the current thread
		txr_thread_yield();
	
		//block the game
		if (blocking)
			o_age_main.blocked = true;
	}

	function continue_thread()
	{
		//unblock the game
		if (blocking)
			o_age_main.blocked = false;

		//continue the thread
		var th = thread;

		var result = undefined;
		switch (txr_thread_resume(th))
		{
			case txr_thread_status.finished:
				txr_error = "";
				result = th[txr_thread.result];
				txr_thread_destroy(th);
				break;
			case txr_thread_status.error:
				txr_error = th[txr_thread.result];
				show_debug_message(txr_error);
				txr_thread_destroy(th);
				return -1;
			//the other option is that the thread yields again (because of another blocking AGE function).
			//in that case the thread is later resumed by TXR_Yield_Manager again which also checks if it can be destroyed afterwards
		}
		//the variable `result` contains the return value of the finished script - in the case we need to use it
		
		return result;
	}
	
	yield_thread();
}