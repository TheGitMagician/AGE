function repeatedly_execute_always_cave(){
	var content = @'
		if (oHatMoveAlways.moving == false)
		{
			if (oHatMoveAlways.y > 60)
			{
				oHatMoveAlways.move(oHatMoveAlways.x,32,eNoBlock,eAnywhere);
			}
			else
			{
				oHatMoveAlways.move(oHatMoveAlways.x,64,eNoBlock,eAnywhere);
			}
		}
		
		if (is_timer_expired(1))
		{
			cSophia.say_background("Stop it, Indi!");
		}
		';
	
	return content;
}