//@TODO: Why are these functions in a separate file? Shouldn't they be bound to the Character struct as static functions?
function update_character_move()
{
	if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!walking) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	movement_percent_along_path += movement_speed_on_path * movement_speed_modifier;
	
	if (movement_percent_along_path >= 1)
	{
		stop_moving();
		
		if (blocked)
		{
			blocked = false;
			yield_manager.continue_thread();
		}
		
		return;
	}
	
	if (movement_percent_along_path > movement_next_direction_check)
	{
		movement_next_direction_check += min(1, (movement_percent_along_path / 0.1) * 0.1);
		
		var dir = point_direction(x,y,path_get_x(movement_path,movement_next_direction_check),path_get_y(movement_path,movement_next_direction_check));
		
		if ((dir > 30) && (dir < 150))				{ dir = 1;  movement_speed_modifier = 0.8; }
		else if ((dir > 210) && (dir < 330))	{ dir = 3;  movement_speed_modifier = 0.8; }
		else if ((dir >= 150) && (dir <=210)) { dir = 2;  movement_speed_modifier = 1; } 
		else																	{ dir = 0;  movement_speed_modifier = 1; }
		//dir = ((((dir + 45) mod 360) + 360) mod 360) div 90;
		
		image_xscale = ((dir == 2) && (sprite_left == noone)) ? -1 : 1;
	
		switch (dir)
		{
		  case 0:
				sprite_index = sprite_right;
				direction = 2;
				break;
		  case 1:
				sprite_index = sprite_up;
				direction = 1;
				break;
		  case 2:
				if (sprite_left == noone) sprite_index = sprite_right;
				else sprite_index = sprite_left;
				direction = 3;
				break;
		  case 3:
				sprite_index = sprite_down;
				direction = 0;
				break;
		}
	}
	
	x = path_get_x(movement_path,movement_percent_along_path);
	y = path_get_y(movement_path,movement_percent_along_path);
	
	image_index += image_speed;
	if (image_index >= sprite_get_number(sprite_index))
	{
		image_index -= sprite_get_number(sprite_index) - 1; //-1 because the first frame contains the standing pose which is skipped while walking
	}
}

function update_character_animation()
{
	if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!animating) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	if (animate_direction == age.forward)
	{
		image_index += image_speed;
		if (image_index >= sprite_get_number(sprite_index))
		{
			if (animate_repeat_style == age.loop)
			{
				image_index -= sprite_get_number(sprite_index);
				return;
			}
		}
		else return;
	}
	else //backward
	{
		image_index -= image_speed;
		if (image_index <= 0)
		{
			if (animate_repeat_style == age.loop)
			{
				image_index += sprite_get_number(sprite_index);
				return;
			}
		}
		else return;
	}
	
	//if we reach this point the animation has ended
	animating = false;				
	sprite_index = animate_sprite_index_before_animation;
	image_index = animate_image_index_before_animation;
	image_xscale = animate_image_xscale_before_animation;
	image_speed = animate_image_speed_before_animation;
	
	if (blocked)
	{
		blocked = false;
		yield_manager.continue_thread();
	}
}

function update_character_say()
{
	if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!talking) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	talk_duration_remaining --;
	
	if (talk_duration_remaining <= 0)
	{
		talking = false;
		talk_duration_remaining = 0;
		
		o_gui.delete_textblock(talk_textblock);
		talk_textblock = undefined;
		
		
		blocked = false;
		yield_manager.continue_thread();
	}
}

function draw_character()
{
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,1,0,c_white,1);
}