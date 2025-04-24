function Global_Manager() constructor
{
	waiting = false;
	wait_steps = 0;
	
	blocked = false;
	yield_manager = undefined;
	
	static wait = function(_steps)
	{
		if (_steps <= 0)
		{ show_debug_message("AGE: wait(): Steps has to be a positive number.");
			return; }
		
		waiting = true;
		wait_steps = _steps;
		
		blocked = true;
		yield_manager = new TXR_Yield_Manager(txr_thread_current,true);
	}

}