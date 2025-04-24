function update_global_manager()
{
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
}