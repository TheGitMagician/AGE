function repeatedly_execute_always_cave(){
	var content = @'
		if (hat_move_always.moving == false)
		{
			if (hat_move_always.y > 60)
			{
				hat_move_always.move(hat_move_always.x,32,false);
			}
			else
			{
				hat_move_always.move(hat_move_always.x,64,false);
			}
		}
		';
	
	return content;
}