//@TODO: Why are these functions in a separate file? Shouldn't they be bound to the Character struct as static functions?
function update_character_move()
{
	if (walking)
	{
		var d = point_distance(x,y,xend,yend);
	
		if (d < walk_speed)
		{
			x = xend;
			y = yend;
		
			walking = false;
		
			image_index = 0;
			image_speed = 0;
		
			if (blocked)
			{
				with (o_txr_dummy) event_perform(ev_alarm,0);
				blocked = false;
			}
		}
		else
		{
			var dir = point_direction(x,y,xend,yend);
		
			x += lengthdir_x(walk_speed,dir);
			y += lengthdir_y(walk_speed,dir);
			
			image_index += image_speed;
			if (image_index >= sprite_get_number(sprite_index))
			{
				image_index -= sprite_get_number(sprite_index) - 1; //-1 because the first frame contains the standing pose which is skipped while walking
			}
		}
	}	
}

function update_character_animation()
{
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
		with (o_txr_dummy) event_perform(ev_alarm,0);
		blocked = false;
	}
}

function character_draw()
{
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,1,0,c_white,1);
}