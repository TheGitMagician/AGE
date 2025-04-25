function Inventory_Item() constructor
{
	script_name = "";
	
	name = "";
	
	sprite = noone;
	
	static __set_sprite = function(_name)
	{
		if (asset_get_type(_name) != asset_sprite)
		{ show_debug_message("AGE: `"+_name+"` - No matching sprite asset found.");
			return; }
			
		var asset_index = asset_get_index(_name);
		
		sprite = asset_index;
	}
	
	static __set_name = function(_name)
	{
		name = string(_name);
	}
	
	static __set_script_name = function(_name)
	{
		show_message("Im running.");
	}
}

function Inventory_Manager() constructor
{
	static get_id_by_name = function(_script_name)
	{
		if (variable_instance_exists(o_age_main,_script_name))
		{
			if (is_instanceof(variable_instance_get(o_age_main, _script_name), Inventory_Item))
				return variable_instance_get(o_age_main,_script_name);
			else
				return undefined;
		}
		else
			return undefined;
	}
}