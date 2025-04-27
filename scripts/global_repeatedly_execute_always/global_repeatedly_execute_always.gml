function global_repeatedly_execute_always(){
	var content = @'
		if ((get_timer_pos(0) == 30) && (!cIndi.talking))
		{
			cIndi.say_background("*hicks*");
			set_timer(1,20);
		}
		
		if (is_timer_expired(0))
		{			
			set_timer(0,80);
		}
		';
	
	return content;
}