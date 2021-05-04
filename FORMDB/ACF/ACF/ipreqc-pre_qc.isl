// \\V-CAMMIS-IMG\FORMDB\ACF\ACF\iPreQC-PRE_QC.isl

//Return true if specified field is READ + WRITE
string special_fields = "";


boolean preQC_form_entry(number iteration)
{
	boolean bStatus = true;
	number field_count, i, form_no;
	string fname, fvalue;

	//get field count in form
	field_count = get_field_count(DOCUMENT);

	//loop through all fields
	for(i=1; i<=field_count; i=i+1) {

		form_no = form_no_by_field(DOCUMENT, i);
		//only process this form's fields
		if (FORMNO == form_no) {
			fname = field_name(DOCUMENT, i);
			
			//Set the field to Read-Only, so it not being presented to KDO for QC
			if(match(fname, special_fields) || reject_code_exists())
			{
				if(fname != "reject_code")
					set_attribute(DOCUMENT, form_no, fname, "READ_ONLY", true);
			}
			
			// don't QC the READ_ONLY fields
			if (IsFieldReadWrite(fname, DOCUMENT, FORMNO)) {				
				
				//turn off double key so blank field doesn't stop for inspection.
				set_attribute(DOCUMENT, FORMNO, fname, "DOUBLE_KEY", 0);
				// clear the OVERRIDE
				set_attribute(DOCUMENT, FORMNO, fname, "OVERRIDE", 0);

			}
			else { 
				// don't QC the READ_ONLY fields
				clear_field(DOCUMENT, FORMNO, fname);
				field_inspect_never(DOCUMENT, FORMNO, fname);
			}
		}
	}
	
	return(bStatus);
}

