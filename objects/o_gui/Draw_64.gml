var i,e,n;

//Draw Statusline
draw_set_color(c_white);
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_text(160,150,string(o_age_main.in_cutscene))//statusline);


//Draw Textblocks
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

n = array_length(textblocks);
for (i=0; i<n; i++)
{
	textblocks[i].draw();
}

draw_set_color(c_white);

//Reset Drawing Variables
draw_set_halign(fa_left);
draw_set_valign(fa_top);

//Draw Dialog Options
if (o_age_main.dialog.options_are_displayed)
{
	var d = o_age_main.dialog.current_dialog;
	var option_count = 0;
	for (i=1; i<d.option_count; i++)
	{
		if (d.has_option_been_chosen(i)) draw_set_color(c_gray);
		else draw_set_color(c_white);
		if (d.get_option_state(i, __AGE_DLG_OPTN_FLG_STATE) == age.option_on)
		{			
			draw_text(5,150+option_count*12,string(i)+") "+ d.get_option_text(i));
			option_count ++;
		}
	}
}

draw_set_color(c_white);



//Draw DEBUG Info
draw_text(2,0,string("Game Blocked: "+string(o_age_main.blocked)));
draw_text(2,12,string("Cursor Mode: "+o_age_main.cursor_mode));
draw_text(2,22,string("Active Threads: "+string(o_age_main.threads)));