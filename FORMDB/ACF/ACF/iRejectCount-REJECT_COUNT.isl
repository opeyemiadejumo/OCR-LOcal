//FormDB\ACF\ACF\iRejectCount-REJECT_COUNT.ISL

boolean RejectCount_form_entry(number iteration)
{
	if(trim(reject_code) != "")
		total_rejected_claims = total_rejected_claims + 1;

	return true;
}