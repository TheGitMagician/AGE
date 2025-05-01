function AGE_Global_Manager() constructor
{
	waiting = false;
	wait_steps = 0;
	
	blocked = false;
	yield_manager = undefined;
	
	//timers
	timers = array_create(20,-1);
	timers_active = [];
	
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
	
	static set_timer = function(_timer,_steps)
	{
		if (_steps <= 0)
		{ show_debug_message("AGE: set_timer(): Steps has to be a positive number.");
			return; }
			
		timers[_timer] = _steps;
		
		if (array_get_index(timers_active,_timer) == -1)	
			array_push(timers_active,_timer);
	}
	
	static is_timer_expired = function(_timer)
	{
		if ((_timer < 0) || (_timer >= 20))
		{ show_debug_message("AGE: is_timer_expired(): Not a valid timer. Has to be between 0 and 19.");
			return; }
		
		if (timers[_timer] == 0) return true;
		else return false;
	}
	
	static stop_timer = function(_timer)
	{
		if ((_timer < 0) || (_timer >= 20))
		{ show_debug_message("AGE: stop_timer(): Not a valid timer. Has to be between 0 and 19.");
			return; }
		
		if (array_get_index(timers_active,_timer) == -1)
		{ show_debug_message("AGE: stop_timer(): Timer `"+string(_timer)+"` was not running.");
			return; }
		
		timers[_timer] = -1;

		array_delete(timers_active,array_get_index(timers_active,_timer),1);
	}
	
	static get_timer_pos = function(_timer)
	{
		if ((_timer < 0) || (_timer >= 20))
		{ show_debug_message("AGE: stop_timer(): Not a valid timer. Has to be between 0 and 19.");
			return -1; }
		
		return timers[_timer];
	}
	
	static claim_event = function()
	{
		//if multiple scripts exists of one event type (e.g. global_rep_exec and room's rep_exec) then this function
		//stops the triggering of further scripts of this event type in this step
		//this is managed in the Step Event of o_age_main
		switch (txr_thread_current[txr_thread.type])
		{
			case txr_thread_type.global_rep_exec:
				o_age_main.event_claimed |= age_event.rep_exec;
				break;
			case txr_thread_type.global_rep_exec_always:
				o_age_main.event_claimed |= age_event.rep_exec_always;
				break;
		}
	}
	
	static __step = function()
	{
		//process wait
		if (waiting)
		{
			wait_steps --;
		
			if (wait_steps <= 0)
			{
				waiting = false;
				wait_steps = 0;
			
				if (blocked)
				{
					blocked = false;
					yield_manager.continue_thread();
				}
			}
		}
		
		//process timers
		var i,n;
		n = array_length(timers_active);
		for (i=n-1; i>=0; i--)
		{
			timers[timers_active[i]] --;
			
			if (timers[timers_active[i]] == -1)
			{
				array_delete(timers_active,i,1);
			}
		}
	}
	
	static __cleanup = function()
	{
	}
}