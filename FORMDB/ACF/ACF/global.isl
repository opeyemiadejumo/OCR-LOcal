//FormDB\ACF\ACF\GLOBAL.ISL

// string ieditor_form_entry(string strEnv, string strWorkflow, 
	// string strInstance, boolean bIsAppendForm, number nPageNo)
// {
	// return "";
// }

boolean form_entry(number iteration)
{
	boolean ok = true;

	if (ok && postOCR)
		ok = postOCR_form_entry(iteration);
		
	if (ok && preKFI)
		ok = preKFI_form_entry(iteration);
		
	if (ok && iexport)
		ok = iExport_form_entry(iteration);

	if (ok && preQC)
		ok = preQC_form_entry(iteration);

	if(ok && preEXPORT)
		ok = preEXPORT_form_entry(iteration);
		
	if (ok && RejectCount)
		ok = RejectCount_form_entry(iteration);
		
	return ok;
}

boolean form_exit(number iteration)
{
	return true;
}

boolean set_QRF_values(string dummyfield)
{
	//set dcn to QRF DLN value
	//if (postOCR || preKFI)
	//	dcn = PAGE_DLN;
	boolean ok = true;
	string strDLN;
	
	if(trim(dcn) != "")
		return true;
		
	if (postOCR || preKFI)
	{
		ok = get_qrf_PAGE_info(iSL_QRF, DOCNO, FORMNO, "QRF_DLN", strDLN);
		if(ok)
			dcn = strDLN;
	}
	return true;
}

boolean reject_code_exists()
{
	return is_valid_reject_code(trim(reject_code), claim_type);
}

void
set_field_READ_WRITE(string fname)
{
	set_field_value(DOCUMENT, FORMNO, fname, field_value(DOCUMENT, FORMNO, fname));
	mark_field(DOCUMENT, FORMNO, fname, "Please verify.");
	set_attribute(DOCUMENT, FORMNO, fname, "READ_ONLY", 0);
}

void
set_field_READ_ONLY(string fname)
{
	set_field_value(DOCUMENT, FORMNO, fname, "");
	clear_field(DOCUMENT, FORMNO, fname);
	field_inspect_never(DOCUMENT, FORMNO, fname);
	set_attribute(DOCUMENT, FORMNO, fname, "READ_ONLY", 1);
}


//function to check ACN
boolean validate_ACN(string strFieldId)
{
	boolean ok = true;
	
	if (len(strFieldId) != 11)
		return false;
	
	// LUHN (Mod 10) Check Digit Algorithm
	ok = mod10_checkdigit_verify(strFieldId);
	return ok;
}


//if reject_code is set, clear all flags to avoid stopping in any field
scrub
	is_valid_reject_code(reject_code, claim_type)
	@ reject_code
{
	true:
	{
		boolean rejected = false;
		get(reject_code, "REJECTED", rejected);
		if (!rejected)
			reject_all_forms(reject_code);	
	}
	
	//code to "un"-reject the claim
	false:
	{
		boolean rejected = false;
		get(reject_code, "REJECTED", rejected);
		if (rejected)
			un_reject_all_forms(reject_code);	
	}
}


//Business Rules
assert
	set_QRF_values(dcn)
	@ dcn
	# "";

assert
	trim(reject_code) == "?"
		? false
		: true
	@ reject_code
	# get_reject_code_list(trim(claim_type));

assert
	trim(reject_code) == "?" ||
	trim(reject_code) == "" || is_valid_reject_code(reject_code, claim_type)
	@ reject_code
	# display(reject_code) " must be valid Reject Code or blank.";

	
//
// Rule ACF.1 - ACF.3  -- acn
//	1. Must not be blank	- not overridable
//	2. Must be 11 characters - overridable
//	3. Use LUHN formula to perform check digit validation - overridable
// 
//Rule ACF.1 - acn must not be blank
assert
!reject_code_exists()
	? trim(acn) != ""
	: true
@ acn
# "ACN must not be blank. REJECT - Must have A C N. Rule ACF.1";

//Rule ACF.2 - acn be 11 characters
assert
!reject_code_exists()
	? trim(acn) == "" || overridden(acn) || (match(acn, "[[:digit:]]{11}"))
	: true
@ acn
# "ACN must be 11 characters. Rule ACF.2";

//Rule ACF.3 - acn must pass check digit routine
assert
!reject_code_exists()
	? trim(acn) == "" || overridden(acn) ||
			validate_ACN(trim(acn))
	: true
@ acn
# "ACN must pass check digit routine. Rule ACF.3";

	
//Rule ACF.4 - prov_number - Provider ID must be 9 or 10 characters
assert
	!reject_code_exists() && IsFieldReadWrite(DOCUMENT, FORMNO, prov_number)
		? overridden(prov_number) ||
			trim(prov_number) == "" ||
			match(prov_number, "[[:alnum:]]{9}") || match(prov_number, "[[:alnum:]]{10}")
		: true
	@ prov_number
	# "Provider ID must be 9 or 10 characters. Rule ACF.4";
	
//Rule ACF.5 - prov_number - Check Provider id against Provider table 
assert
	!reject_code_exists() && IsFieldReadWrite(DOCUMENT, FORMNO, prov_number)
		? overridden(prov_number) ||
			trim(prov_number) == "" ||
			is_valid_Provider(prov_number)
		: true
	@ prov_number
	# "Failed Provider id lookup. Rule ACF.5";
	
//Rule ACF.6 - prov_number - Provider ID must not be blank
assert
	!reject_code_exists() && IsFieldReadWrite(DOCUMENT, FORMNO, prov_number)
		? overridden(prov_number) ||
			trim(prov_number) != ""
		: true
	@ prov_number
	# "Provider ID must not be blank. Rule ACF.6";

//Rule ACF.7 - Provider Signature - Valid Values 1 or 0
assert
	!reject_code_exists() && IsFieldReadWrite(DOCUMENT, FORMNO, prov_signature)
		? (trim(prov_signature) == "" && overridden(prov_signature)) ||
			match(prov_signature, "1|0")
		: true
	@ prov_signature
	# "Signature should not be blank. Valid Values 1 or 0. Rule ACF.7";
