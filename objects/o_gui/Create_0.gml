display_set_gui_size(320,200);

statusline = "";

textblocks = [];

function Textblock(_x,_y,_text,_duration,_color=c_white) constructor
{	
	xpos = _x;
	ypos = _y;
	text = _text;
	duration = _duration;
	color = _color;
	
	static update = function()
	{
		duration --;
		
		if (duration <= 0)
		{
			var i = array_get(textblocks,self);
			array_delete(textblocks,i,1);
		}
	}
}

function create_textblock(_x,_y,_text,_duration,_color)
{
	var t = new Textblock(_x,_y,_text,_duration,_color);
	
	array_push(textblocks, t);
	
	return t;
}

function delete_textblock(_id)
{
	var i = array_get_index(textblocks,_id);
	
	if (i == -1) return;
	
	array_delete(textblocks,i,1);
}

function delete_all_textblocks()
{
	array_delete(textblocks,0,array_length(textblocks));
}