function repeatedly_execute_cave(){
	var content = @'
		if (oHat.moving == false)
		{
			if (oHat.y > 60)
			{
				oHat.move(oHat.x,32,false);
			}
			else
			{
				oHat.move(oHat.x,64,false);
			}
		}
		';
	
	return content;
}