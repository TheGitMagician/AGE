var i,e,n;

//Draw Statusline
draw_set_color(c_white);
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_text(160,150,statusline);


//Draw Textblocks
draw_set_valign(fa_bottom);

n = ds_list_size(li_textblocks);

for (i=0; i<n; i++)
{
	e = ds_list_find_value(li_textblocks,i);
	draw_text(e.xpos,e.ypos,e.text);
}

//Reset Drawing Variables
draw_set_halign(fa_left);
draw_set_valign(fa_top);

//Draw Dialog Options
if (o_age_main.dialog_manager.show_dialog_options)
{
	var o = o_age_main.dialog_manager.current_dialog.options;
	var option_count = 0;
	n = array_length(o);
	for (i=1; i<n; i++)
	{
		if (o[i][2] == age.option_on)
		{			
			e = o[i][0];
			draw_text(5,150+option_count*12,string(i)+") "+e);
			option_count ++;
		}
	}
}



//Draw DEBUG Info
draw_text(2,0,string("Game Blocked: "+string(o_age_main.blocked)));
draw_text(2,12,string("Cursor Mode: "+o_age_main.cursor_mode));
draw_text(2,22,string("Active Threads: "+string(o_age_main.threads)));