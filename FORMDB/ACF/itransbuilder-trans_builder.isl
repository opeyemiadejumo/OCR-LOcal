//
// validate function for ACF
//
string validate_form_sequence()
{
	number i, iNumACF;
	string formname;
	string errormsg = "";
	boolean _fax;

	iNumACF = 0;
	_fax = false;

	//search all forms to count the number of ACF form.
	for (i=1; i<=FORMCNT; i=i+1) {
		formname = trim(form_name(DOCUMENT, i));
		if (formname == "ACF") {
			iNumACF = iNumACF + 1;
			if (iNumACF > 1)
				mark_field(DOCUMENT, i, "dcn", "Multiple ACF has been detected!");
		}
		else if (formname == "FAXPAGE") {
			_fax = true;
			mark_field(DOCUMENT, i, "dcn", "Please inspect faxpage");
		}
	}
	
	if (_fax)
		errormsg = "Please inspect each fax page!";
	else if (iNumACF > 1)
		errormsg = "Multiple ACF has been detected!";

	return errormsg;
}
