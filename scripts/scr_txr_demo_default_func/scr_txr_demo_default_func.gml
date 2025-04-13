function scr_txr_demo_default_func() {
	//this is the default function that is called if a function in a script doesn't exists / hasn't been exposed to TXR
	//the arguments that you can use in this function are
	//[0]= name of the missing function
	//[1],[2],...= the arguments that were supplied to this missing function.
	//When the error is thrown as a debug message it automatically adds line/column information about where the error occured
	txr_function_error = "`"+string(argument[0]) + "()` is not a known function or script.";
}
