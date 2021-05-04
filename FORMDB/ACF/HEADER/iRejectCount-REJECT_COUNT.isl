//FormDB\ACF\HEADER\iRejectCount-REJECT_COUNT.ISL

number batch_iterations = 1;
number total_rejected_claims = 0;

boolean batch_exit()
{
	reject_count = string(total_rejected_claims);
	
	return true;
}