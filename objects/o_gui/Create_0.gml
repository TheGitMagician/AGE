display_set_gui_size(320,200);

statusline = "";

textblocks = [];

function Textblock(_char,_text,_x=undefined,_y=undefined,_duration) constructor
{
	char = _char;
	text = _text;
	xpos = _x;
	ypos = _y;	
	duration = _duration;
	color = _char.speech_color;
	
	static __step = function()
	{
		duration --;
		
		if (duration <= 0)
		{
			var i = array_get(textblocks,self);
			array_delete(textblocks,i,1);
		}
	}
	
	static __draw_gui = function()
	{
		var xx,yy,margin,max_width;
		
		margin = 5; 
		max_width = 150;
		
		xx = (xpos == undefined) ? char.x : xpos;
		yy = (ypos == undefined) ? char.y : ypos;
		
		xx = clamp(xx,margin+(max_width div 2),room_width-min(max_width div 2,string_width(text))-margin);
		yy = clamp(yy,string_height_ext(text,font_get_size(fnt_pixel),min(max_width,string_width(text)))+margin,room_height-margin);
		
		draw_set_color(char.speech_color);
		draw_text_ext(xx,yy,text,font_get_size(fnt_pixel),min(max_width,string_width(text)));
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