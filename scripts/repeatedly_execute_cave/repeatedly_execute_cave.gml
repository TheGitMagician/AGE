function repeatedly_execute_cave(){
	var content = @'
		if (oHat.moving == false)
		{
			if (oHat.y > 60)
			{
				oHat.move(oHat.x,32,eNoBlock,eAnywhere);
			}
			else
			{
				oHat.move(oHat.x,64,eNoBlock,eAnywhere);
			}
		}
		';
	
	return content;
}