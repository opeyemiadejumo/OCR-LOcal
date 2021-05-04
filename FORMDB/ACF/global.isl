//FormDB\ACF\global.isl

number first_ACF_formno, last_ACF_formno;

number get_last_FormID_form_no(string formID)
{
	number i = 0;
	number nRetVal = 1;	

	for(i=FORMCNT; i>=1; i=i-1)
	{
		if(upper(form_name(DOCUMENT, i)) == formID)
			return i;
	}

	return nRetVal;
}

number get_first_FormID_form_no(string formID)
{
	number i = 0;

	for(i=1; i<=FORMCNT; i=i+1)
	{
		if(upper(form_name(DOCUMENT, i)) == formID)
			return i;
	}

	return -1;
}

//if reject_code is set, clear all flags to avoid stopping in any field
void reject_all_forms(string reject_code)
{
	string fname;
	number form_no, i, j, field_count;

	if (trim(field_value(DOCUMENT, 1, "reject_station_id")) == "") {
		set_field_value(DOCUMENT, 1, "reject_station_id", get_host_name());
		set_field_value(DOCUMENT, 1, "reject_operator_id", get_login_name());
		set_field_value(DOCUMENT, 1, "reject_process_id", substitute(APPLICATION, "[^-]+-([^-]+)", "\\1"));
	}
	//get field count in form
	field_count = get_field_count(DOCUMENT);
	//loop through all the FORMS on the document
	for(i=1; i<=field_count; i=i+1) {
		//get field name
		fname = field_name(DOCUMENT, i);
		//get the formno of the field
		form_no = form_no_by_field(DOCUMENT, i);

		//ensure all forms get the same reject_code value
		if (fname == "reject_code") {
			set_field_value(DOCUMENT, form_no, "reject_code", reject_code);
			set_attribute(DOCUMENT, form_no, fname, "REJECTED", 1);
		}
		else	//reset field value to itself
			set_field_value(DOCUMENT, form_no, fname, field_value(DOCUMENT, form_no, fname));

		//clear all flags to avoid stopping in any field; but don't clear data, just in case.
		clear_field(DOCUMENT, form_no, fname);
		field_inspect_never(DOCUMENT, form_no, fname);
				
		//if claim IS rejected, remove double-key from all fields
		set_attribute(DOCUMENT, form_no, fname, "DOUBLE_KEY", 0);
	}

}

void un_reject_all_forms(string reject_code)
{
	string fname;
	number form_no, i, j, field_count;
	number read_only;

	if (trim(reject_code) == "") {
		//get field count in form
		field_count = get_field_count(DOCUMENT);
		//loop through all the fields on the document
		for(i=1; i<=field_count; i=i+1) {
			//get field name
			fname = field_name(DOCUMENT, i);
			//get the formno of the field
			form_no = form_no_by_field(DOCUMENT, i);

			//clear all reject field values
			if (match(fname, REJECT_FIELDS)) {
				set_field_value(DOCUMENT, form_no, fname, "");
				if (match(fname, "reject_code")) {
					set_attribute(DOCUMENT, form_no, fname, "REJECTED", 0);
					clear_field(DOCUMENT, form_no, fname);
					field_inspect_never(DOCUMENT, form_no, fname);
				}
			} else {
				//mark READ+WRITE fields for inspection
				get_attribute(DOCUMENT, form_no, fname, "READ_ONLY", read_only);
				if (read_only == 0) { //0 = READ+WRITE
					mark_field(DOCUMENT, form_no, fname, "Please verify.");
					field_inspect_always(DOCUMENT, form_no, fname);
				}
			}
		}
	}
}

