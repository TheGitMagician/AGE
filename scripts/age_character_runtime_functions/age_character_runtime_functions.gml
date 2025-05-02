//@TODO: Why are these functions in a separate file? Shouldn't they be bound to the Character struct as static functions?
function update_character_move()
{
	//if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!walking) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	movement_percent_along_path += movement_speed_on_path * movement_speed_modifier;
	
	__update_scale_level();
	
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
		//advance direction check position
		movement_next_direction_check += min(1, (movement_percent_along_path / movement_check_direction_interval) * movement_check_direction_interval);
		
		//calculate direction
		var dir = point_direction(x,y,path_get_x(movement_path,movement_next_direction_check),path_get_y(movement_path,movement_next_direction_check));
		
		if ((dir > 30) && (dir < 150))				{ direction = 1;  movement_speed_modifier = 0.8; }
		else if ((dir > 210) && (dir < 330))	{ direction = 3;  movement_speed_modifier = 0.8; }
		else if ((dir >= 150) && (dir <=210)) { direction = 2;  movement_speed_modifier = 1; } 
		else																	{ direction = 0;  movement_speed_modifier = 1; }
		
		//advance walking animation if no other dedicated animation is currently playing
		if (!animating)	
			__update_sprites();
	}
	
	//advance position along path
	x = path_get_x(movement_path,movement_percent_along_path);
	y = path_get_y(movement_path,movement_percent_along_path);
	
	//update image index if no other dedicated animation is playing
	if (!animating)
	{
		image_index += image_speed;
		if (image_index >= sprite_get_number(sprite_index))
		{
			image_index -= sprite_get_number(sprite_index) - 1; //-1 because the first frame contains the standing pose which is skipped while walking
		}
	}
}

function update_character_talk()
{
	//if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
	if (!talking) return; //@TODO this check is redundant currently because it is also done in o_age_main's Step Event
	
	talk_duration_remaining --;
	
	if (talk_duration_remaining <= 0)
	{
		talking = false;
		talk_duration_remaining = 0;
		
		if (talk_textblock != undefined)
		{
			talk_textblock.destroy();
			talk_textblock = undefined;
		}
		
		change_costume(previous_costume);
		
		if (blocked)
		{
			blocked = false;
			yield_manager.continue_thread();
		}
		
		return;
	}
	
	if (separate_talking_head)
	{
		talking_head_image_index += talk_anim_speed;
		if (talking_head_image_index >= sprite_get_number(talking_head_sprite_index))
		{
			talking_head_image_index -= sprite_get_number(talking_head_sprite_index);
		}
	}
}

function update_character_animation()
{
	//if ((o_age_main.blocked) && (called_from_rep_exec_always == false)) return;
	
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
	//sprite_index = animate_sprite_index_before_animation;
	//image_index = animate_image_index_before_animation;
	//image_xscale = animate_image_xscale_before_animation;
	//image_speed = animate_image_speed_before_animation;
	change_costume(costume_before_animation);
	
	if (blocked)
	{
		blocked = false;
		yield_manager.continue_thread();
	}
}