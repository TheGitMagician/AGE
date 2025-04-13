function txr_wait(frames)
{
	//stop the current thread
	var th = txr_thread_yield();
	
	//hand the thread pointer over into the dummy object so that
	//it can be restarted from there
	if (th != undefined)
	{
		with (o_txr.dummy)
		{
			thread = th;
			alarm[0] = frames;
		}
	}
	
	//block the game
	o_age_main.blocked = true;
}