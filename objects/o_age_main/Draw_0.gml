var i,n,char;

n = array_length(characters);
for (i=0; i<n; i++)
{
	char = characters[i];
	
	if ((char.room_current != room) || (char.enabled == false)) continue; //@TODO: manage a list with all chars that have to be drawn instead of always looping through all of them. Update the list when functions like change_room() or enable() are called
	
	with (char) character_draw();
}