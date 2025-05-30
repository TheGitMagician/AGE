function AGE_Inventory_Item() constructor
{
	script_name = "";
	
	name = "";
	
	sprite = noone;
	
	static __set_sprite = function(_sprite)
	{
		if (!sprite_exists(_sprite)) //a more robust check would be `if (asset_get_type(_sprite) != asset_sprite)` but that doesn't work on HTML5
		{ show_debug_message("AGE: `"+string(_sprite)+"` - No matching sprite asset found.");
			return; }
		
		sprite = _sprite;
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

function AGE_Inventory_Manager() constructor
{
	//the actual inventory item structs are stored in o_age_main's inventory_items[] array.
	//yes, this is not nicely decoupled - they could be stored in here, but it has some benefits if they are stored centrally
	//so it is important that this manager knows the central object (o_age_main) and can refer to it when it accesses the inventory items
	o = o_age_main;
	
	static create = function(_script_name,_settings_struct)
	{
		if (variable_instance_exists(o,_script_name))
		{ show_debug_message("AGE: Can't create inventory item `"+_script_name+"` because the script name already exists.");
			return; }
		
		var inv_item = new AGE_Inventory_Item();
	
		variable_instance_set(o,_script_name,inv_item); //add item's script name to o_age_main's variables so that it can be accessed by TXR
		array_push(o.inventory_items, inv_item); //add item reference to o_age_main's inventory_items array so that it can be accessed by other resources
	
		inv_item.script_name = _script_name;
	
		//apply settings to the inventory_item
		var i,s;
		s = variable_struct_get_names(_settings_struct);
		for (i=0; i<array_length(s); i++)
		{
			switch (s[i])
			{
				case "name":
					inv_item.name = _settings_struct.name;
					break;
				case "sprite":
					inv_item.sprite = _settings_struct.sprite;
					break;
			}
		}
	}
	
	static get_struct_by_name = function(_script_name)
	{
		if (!variable_instance_exists(o,_script_name))
			return undefined;
		
		var v = variable_instance_get(o, _script_name);
		
		if (is_instanceof(v, AGE_Inventory_Item))
			return v;
		else
			return undefined;
	}
	
	static __cleanup = function()
	{
	}
}