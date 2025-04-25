function age_convert_path_to_array(_path)
{
	//returns the array
	var i,n,arr;
			
	arr = [];
			
	n = path_get_number(_path);
	
	for (i=0; i<n; i++)
	{
		array_push(arr,path_get_point_x(_path,i));
		array_push(arr,path_get_point_y(_path,i));
	}
	
	return arr;
}

function age_convert_array_to_path(_array)
{
	//returns the path data structure
	var i,n,p;
	
	p = path_add();
	path_set_closed(p,false);
	path_set_kind(p,0);
			
	n = array_length(_array);
	for (i=0; i<n-1; i+=2)
		path_add_point(p,_array[i],_array[i+1],1);
	
	return p;
}