if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) exit;

if (moving)
{
	var d = point_distance(x,y,xend,yend);
	
	if (d < move_speed)
	{
		x = xend;
		y = yend;
		
		moving = false;
		
		called_from_rep_exec_always = false;
		
		if (move_blocking)
		{
			with (o_txr_dummy) event_perform(ev_alarm,0);
			move_blocking = false;
		}
	}
	else
	{
		var dir = point_direction(x,y,xend,yend);
		
		x += lengthdir_x(move_speed,dir);
		y += lengthdir_y(move_speed,dir);
	}
}