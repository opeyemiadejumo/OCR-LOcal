//FormDB\PHARMACY\HEADER\<iEditorMode>.ISL

number batch_iterations = 1;

boolean batch_exit()
{
	boolean ok = true;

	//Update custom Batch Statistics	
	update_batch_statistics(BatchName, (string)NumDocs, get_login_name(), substitute(APPLICATION, "[^-]+-([^-]+)", "\\1"));

	return ok;
}
