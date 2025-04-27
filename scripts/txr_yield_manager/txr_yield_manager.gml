function TXR_Yield_Manager(_thread, _blocking=true) constructor
{
	thread = _thread;
	blocking = _blocking;
	
	function yield_thread() //this function is automatically run when the struct is instantiated (see last line)
	{
		txr_thread_yield();
	
		//block the game
		if (blocking)
			o_age_main.blocked = true;
	}

	function continue_thread()
	{
		//returns the result of the thread (or -1 if thread doesn't produce a result)
		
		//unblock the game
		if (blocking)
			o_age_main.blocked = false;

		//continue the thread
		return txr_age_thread_resume(thread);	
	}
	
	yield_thread();
}