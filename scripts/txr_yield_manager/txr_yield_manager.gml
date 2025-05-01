//the struct that is created whenever a TXR thread is blocked
//it stores the thread reference and can restart it (either automatically after a timer has run out or called externally)
function TXR_Yield_Manager(_thread, _blocking=true) constructor
{
	thread = _thread;
	blocking = _blocking;
	
	static yield_thread = function() //this function is automatically run when the struct is instantiated (see last line)
	{
		txr_thread_yield();
	
		//block the game
		if (blocking)
			o_age_main.blocked = true;
	}
	
	static update = function()
	{
		//count down the yield timer
		//if (!o_age_main.blocked)
	}

	static continue_thread = function()
	{
		//returns true if the thread still exists after it has been restarted or
		//false if the thread has been destroyed (because it has reached the end or has caused an error)
		
		//unblock the game
		if (blocking)
			o_age_main.blocked = false;

		//continue the thread
		return txr_age_thread_resume(thread);	
	}
	
	yield_thread();
}