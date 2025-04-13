/// @description string_replace_at(_str, _pos, _insert)
/// @param str
/// @param pos
/// @param insert
/// @credits: FrostyCat on the GameMaker forums: https://forum.gamemaker.io/index.php?threads/replace-character-at-index-in-string.74984/
function string_replace_at(_str, _pos, _insert)
{
	return string_copy(_str, 1, _pos-1) + _insert + string_delete(_str, 1, _pos);
}