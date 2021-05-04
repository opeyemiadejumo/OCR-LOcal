//FormDB\ACF\ACF\IEXPORT-EXPORT.ISL

boolean iExport_form_entry(number iteration)
{
	boolean ok = true;
	string arc_file, ccn_file, temp;
	number width, height;
	
	if (batch_iteration_count == 1) 
	{
		//we still need ccn/roll number for rejected claim
		if(document_ccn == "")
		{
			document_ccn = ccn;
			array_set(ccn_list, DOCNO, 1, document_ccn);
		}

		if (DOCNO == 1 && FORMNO == 1)
			first_ccn = ccn;
		//keep assigning until last form
		//last_ccn = ccn;
		if (!reject_code_exists()) 
		{
			//count non-rejected claims
			claim_count = claim_count + 1;
							
			if (ok) 
			{
				//make a copy of the .arc file
				if (left(SourceID, 1) == "F")		// Fax Batch -  use tif image
					arc_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
				else
					//arc_file = path_exists(pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc"))) ? pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc")) : pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
					arc_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".tif"));
				ccn_file = pathname(BATCH, concatenate(form_path(DOCUMENT, FORMNO), ".arc+ccn"));
				ok = copy_file(arc_file, ccn_file);
				if (!ok) {
					error_message = concatenate("Fail to copy .arc image for DOCNO: ", (string)DOCNO, ", form: ", (string)FORMNO);
					log_error(EventLog_Handle, error_message);
				}
			}
			
			if (ok) 
			{
				//burn ccn value on image
				//boolean insert_text_on_image(string image_file, string text_message, cell_t field, number text_orientation);
				ok = get_image_dimensions(ccn_file, width, height);
		
				//09/13/2020 - rsanchez60@dxc.com - Modify to use the dimenstions instead of fdf field location
				if(ok)
					ok = insert_text_on_image(ccn_file, document_ccn, 50, height - 100, 350, height - 50, 0);

				if (!ok) {
					error_message = concatenate("Fail to burn CCN onto image: ", ccn_file, " for DOCNO: ", (string)DOCNO, ", form: ", (string)FORMNO);
					log_error(EventLog_Handle, error_message);
				}
			}
		}
	} 
	else 
	{
		//populate ccn from array
		array_get(ccn_list, DOCNO, 1, temp);
		ccn = temp;
		document_ccn = temp;

		if (!reject_code_exists()) 
		{
			//If the first document is reject the CCN will be blank.
			if(first_ccn == "")
				first_ccn = ccn;
				
			last_ccn = ccn;	
			
			ALL_CLAIMS_REJECTED = false;
			//ok = output_ACF();
		}
		else 
		{
			sum_claims_rejected = sum_claims_rejected + 1;
			ok = export_REJ_record(dcn, reject_station_id, reject_operator_id, reject_process_id, reject_code);
		}

		if (!ok)
			clean_up_busy_file(concatenate("Cannot output record info for ", name(FORM)));
	}
	
	return ok;
}

