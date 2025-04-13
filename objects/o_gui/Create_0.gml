statusline = "";

li_textblocks = ds_list_create();

function textblock(x,y,t,dur) constructor
{	
	xpos = x;
	ypos = y;
	text = t;
	duration = dur;
	
	static countdown = function()
	{
		duration --;
		if (duration <= 0)
		{
			var i = ds_list_find_index(o_gui.li_textblocks,self);
			ds_list_delete(o_gui.li_textblocks,i);
		}
	}
}

function show_text(x,y,t,dur)
{
	ds_list_add(li_textblocks, new textblock(x,y,t,dur));
}