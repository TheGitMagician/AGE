function repeatedly_execute_always_cave(){
	var content = @'
		if (oHatMoveAlways.moving == false)
		{
			if (oHatMoveAlways.y > 60)
			{
				oHatMoveAlways.move(oHatMoveAlways.x,32,false);
			}
			else
			{
				oHatMoveAlways.move(oHatMoveAlways.x,64,false);
			}
		}
		';
	
	return content;
}