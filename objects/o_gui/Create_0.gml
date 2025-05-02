display_set_gui_size(320,200);

statusline = "";

textblocks = [];

function Textblock(_char,_text,_x=undefined,_y=undefined) constructor
{
	parent = other;
	
	char = _char;
	text = _text;
	xpos = _x;
	ypos = _y;	
	color = _char.speech_color;
	
	static destroy = function()
	{
		var i = array_get_index(parent.textblocks,self);
		array_delete(parent.textblocks,i,1);
	}
	
	static __draw_gui = function()
	{
		// !!! the textblocks have to be drawn with draw_set_halign set to fa_center and draw_set_valign set to fa_bottom
		var xx,yy,margin,max_width;
		
		margin = 5; 
		max_width = 150;
		
		xx = (xpos == undefined) ? char.x : xpos;
		yy = (ypos == undefined) ? char.y : ypos;
		
		xx = clamp(xx,margin+(min(max_width,string_width(text)) div 2),room_width-min(min(max_width,string_width(text)) div 2,string_width(text))-margin);
		yy = clamp(yy,string_height_ext(text,font_get_size(fnt_pixel),min(max_width,string_width(text)))+margin,room_height-margin);
		
		draw_set_color(char.speech_color);
		draw_text_ext(xx,yy,text,font_get_size(fnt_pixel),min(max_width,string_width(text)));
	}
}

function create_textblock(_char, _text, _x, _y)
{
	var t = new Textblock(_char, _text, _x, _y);	
	array_push(textblocks, t);
	
	return t;
}