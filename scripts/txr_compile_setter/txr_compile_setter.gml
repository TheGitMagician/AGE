/// @param node
/// @returns {bool} whether encountered an error
function txr_compile_setter(q) {
	var out = txr_compile_list;
	switch (q[0]) {
		case txr_node.ident:
			var s = q[2];
			/*// example of global_some -> global.some
			if (string_length(s) > 7 && string_copy(s, 1, 7) == "global_") {
				out.add([txr_action._string, q[1], string_delete(s, 1, 7)]);
				out.add([txr_action.call, q[1], scr_txr_demo_global_set, 2]);
			} else
			//*/
			if (ds_map_exists(global.txr_constant_map, s)) {
				return txr_throw_at("Constants are not settable", q);
			} else if (ds_map_exists(txr_build_locals, s)) {
				ds_list_add(out, [txr_action.set_local, q[1], s]);
			} else {
				ds_list_add(out, [txr_action.set_ident, q[1], s]);
			}
			return false;
		
		case txr_node.field:			
			if (txr_compile_expr(q[2])) return true;
			
			//we are now looking for whether this field has an associated setter method in its struct
			//these setter methods have to be named like the field/variable with the prefix __set_ (e.g. for test -> __set_test() )
			//if it has, we restructure the thread actions so that the setter method is called instead of simply setting the field to the new value
			var s = q[2];
			var special_setter = false;
			var field = variable_instance_get(o_age_main, s[2]);
			if (typeof(field) == "struct") {
				if (variable_struct_exists(field, "__set_"+q[3])) {
					special_setter = true;
				}
			}
			//@TODO: how slow is the above code? The alternative would be to provide an explicit list with the setter functions (see code at the bottom of this script)
			//is this worth a test?
				
			if (special_setter)	{
				//the second to last entry in the action list contains the value to set to (the last entry is the identifier of which the field is supposed to be set)
				//grab that second to last entry, delete it, and then construct a new set of actions which actually call the corresponding setter function for the field
				//this is done by first adding the field (in this case the name of the setter method in the struct), then the value to set to, and finally the value_call with the correct number of arguments for the method
				var value_to_set_to = ds_list_find_value(out, ds_list_size(out)-2);
				ds_list_delete(out, ds_list_size(out)-2);
				ds_list_add(out, [txr_action.get_field, q[1], "__set_"+q[3]]);
				ds_list_add(out, value_to_set_to);
				ds_list_add(out, [txr_action.value_call, q[1], 1]);
			}				
			else {
				//this is the classic field setter as it was included in TXR
				ds_list_add(out, [txr_action.set_field, q[1], q[3]]);
			}
			return false;
		
		case txr_node.array_access:
			if (txr_compile_expr(q[2])) return true;
			if (txr_compile_expr(q[3])) return true;
			ds_list_add(out, [txr_action.set_array, q[1]]);
			return false;
		
		default: return txr_throw_at("Expression is not settable", q);
	}
}


//alternative code (see comment for txr_node.field above)
//var special_setter = true;
//if (is_instanceof(variable_instance_get(o_age_main,s[2]), AGE_Character))
//{
//	switch (q[3])
//	{
//		case: "testerei"
//			break;
//					
//		default:
//			special_setter = false;
//			break;
//	}
//}