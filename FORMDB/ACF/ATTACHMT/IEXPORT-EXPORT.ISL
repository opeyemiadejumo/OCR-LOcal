//FormDB\ACF\ATTACHMT\iExport-EXPORT.isl

boolean form_entry(number iteration)
{
	boolean ok = true;
	string arc_file, ccn_file;
	number width, height;
	
	//only process on batch_iteration_count == 1
	if (batch_iteration_count == 1) 
	{
		//we still need ccn/roll number for rejected claim
		if(document_ccn == "")
		{
			document_ccn = ccn;
			array_set(ccn_list, DOCNO, 1, document_ccn);
		}

		//make a copy of the .arc file
		if (left(SourceID, 1) == "F")		// Fax Batch -  use tif image
			arc_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
		else
			//arc_file = path_exists(pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc"))) ? pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc")) : pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
			arc_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
		ccn_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc+ccn"));
		ok = copy_file(arc_file, ccn_file);
		if (!ok) 
		{
			error_message = concatenate("Fail to copy .arc image for DOCNO: ", (string)DOCNO, ", form: ", (string)FORMNO);
			log_error(EventLog_Handle, error_message);
		}
	
		if (ok) 
		{
			//burn ccn value on image
			//boolean insert_text_on_image(string image_file, string text_message, cell_t field, number text_orientation);
			ok = get_image_dimensions(ccn_file, width, height);
			
			if (height > 100) {
				//06/12/20 - SS - Modify to use the dimenstions instead of fdf field location
				if(ok)
					ok = insert_text_on_image(ccn_file, document_ccn, 50, height - 100, 350, height - 50, 0);
								
				if (!ok) 
				{
					error_message = concatenate("Fail to burn CCN onto image: ", ccn_file, " for DOCNO: ", (string)DOCNO, ", form: ", (string)FORMNO);
					log_error(EventLog_Handle, error_message);
				}
			}
		}
			
		return ok;
	}
	return true;
}


