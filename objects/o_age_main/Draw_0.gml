//exit if this is not an AGE room (all AGE rooms need to have the tag "AGE")
if (!asset_has_tags(room, "AGE", asset_room))
	exit


//mp_grid_draw(o_age_main.walkarea_manager.mp_grid);


var i,n;

n = array_length(draw_order);
for (i=0; i<n; i++)
{
	draw_order[i].__draw();
}

//if (path_exists(cIndi.movement_path))
//{
//	draw_path(cIndi.movement_path,0,0,true);
//}