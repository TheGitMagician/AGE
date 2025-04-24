/// @param node
/// @returns {bool} whether encountered an error
function txr_compile_getter(q) {
	var out = txr_compile_list;
	switch (q[0]) {
		case txr_node.ident:
			var s = q[2];
			/*// example of global_some -> global.some
			if (string_length(s) > 7 && string_copy(s, 1, 7) == "global_") {
				out.add([txr_action._string, q[1], string_delete(s, 1, 7)]);
				out.add([txr_action.call, q[1], scr_txr_demo_global_get, 1]);
			} else
			//*/
			if (ds_map_exists(global.txr_constant_map, s))
			{
				//identifier is a constant that was added via txr_constant_add()
				var val = global.txr_constant_map[?s];
				if (is_string(val)) {
					ds_list_add(out, [txr_action._string, q[1], val]);
				} else {
					ds_list_add(out, [txr_action.number, q[1], val]);
				}
			}
			else if (ds_map_exists(txr_build_locals, s))
			{
				//identifier is a local variable that was defined inside the TXR script via the keyword `var`
				ds_list_add(out, [txr_action.get_local, q[1], s]);
			} 
			else if (asset_get_index(q[2]) != -1)
			{
				//identifier is an asset from the game
				if ((!string_starts_with(q[2],"rm")) && (!string_starts_with(q[2],"s"))) 
					return txr_throw_at("Only assets starting with 'rm' or 's' can be accessed from AGL scripts.", q);
				
				ds_list_add(out, [txr_action.number, q[1], asset_get_index(q[2])]);
			}
			else
			{
				//identifier is none of the above - so should be a variable from o_age_main
				//this is to ensure that TXR is sandboxed and cannot simply access any variable from any object
				if (variable_instance_exists(o_age_main,q[2]) == false) 
					return txr_throw_at("No matching struct/variable/asset `"+q[2]+"` can be found.", q);
				
				ds_list_add(out, [txr_action.ident, q[1], s]);
			}
			return false;
		case txr_node.field:
			if (txr_compile_expr(q[2])) return true;
			ds_list_add(out, [txr_action.get_field, q[1], q[3]]);
			return false;
		case txr_node.array_access:
			if (txr_compile_expr(q[2])) return true;
			if (txr_compile_expr(q[3])) return true;
			ds_list_add(out, [txr_action.get_array, q[1]]);
			return false;
		default: return txr_throw_at("Expression is not gettable", q);
	}
}
