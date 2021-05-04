//FormDB\ACF\ACF\iprekfi-pre_kfi.isl
	
boolean preKFI_form_entry(number iteration)
{
	boolean ok = true;
	
	// 06062019	- For Scan-Batch: 
	//				. Scrub the header's signature to form-level.
	//				. Make the field readonly and do not present to operator.
	//			- For Fax-batch
	//				. Present to operator if is low-confidence
	
	//make reject_code inspect never
	inspect_never(reject_code);
	reject_code = trim(reject_code);
	clear(reject_code);
	
	if (left(SourceID, 1) != "F") {
		if(signature == "Y")
			prov_signature = "1";
		else if(signature == "N")
			prov_signature = "0";
		
		if(prov_signature == "1" || prov_signature == "0")
		{
			inspect_never(prov_signature);
			//set_field_READ_ONLY("prov_signature");
		}
	}
	
	return ok;
}
