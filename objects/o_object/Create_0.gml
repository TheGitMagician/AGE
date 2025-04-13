name = "";

sprite = noone;

moving = false;
move_blocking = false;
move_speed = 2;
xend = 0;
yend = 0;

called_from_rep_exec_always = false;

move = function(xe,ye,block)
{
	if (txr_thread_current[txr_thread.type] == txr_thread_type.rep_exec_always) called_from_rep_exec_always = true;
	
	xend = xe;
	yend = ye;
	
	moving = true;
	
	var dir = point_direction(x,y,xend,yend);
	
	if (block)
	{
		move_blocking = true;
		txr_wait(-1);
	}
}

jumping = function()
{
	x = x-10;
}