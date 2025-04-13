function repeatedly_execute_cave(){
	var content = @'
		if (hat.moving == false)
		{
			if (hat.y > 60)
			{
				hat.move(hat.x,32,false);
			}
			else
			{
				hat.move(hat.x,64,false);
			}
		}
		';
	
	return content;
}