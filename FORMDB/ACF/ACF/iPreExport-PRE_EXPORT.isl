//FormDB\ACF\ACF\iPreExport-PRE_EXPORT.ISL

boolean preEXPORT_form_entry(number iteration)
{
	boolean ok = true;
	string strCCN = "";
	number i = 0;

	//Don't assign ccn for rejected claim
	if (reject_code_exists())
		return true;
	
	//check if we already has a valid ccn saved in earlier processing
	if(len(trim(ccn)) == 11)
	{
		//no need to generate CCN again, save batchCCN from earlier attempt
		BatchCCN = left(trim(ccn), 8);
		CurrentCCNSeqNo = ((number)mid(trim(ccn), 9, 3)) + 1;
	}
	else
	{
		//for first document, generate BatchCCN
		if(trim(BatchCCN) == "")
		{
			//generate Batch level CCN
			ok = GetNextBatchCCN(dcn, trim(claim_type), JulianToMMDDYYYY(receive_date), (NumDocs-(number)reject_count), BatchCCN, CurrentCCNSeqNo);
			if (!ok) 
			{
				error_message = "form_entry: Fail to get BatchCCN.";
				log_error(EventLog_Handle, error_message);
				return false;
			}
			if(trim(BatchCCN) == "")
			{
				error_message = "form_entry: Blank BatchCCN returned.";
				log_error(EventLog_Handle, error_message);
				return false;
			}
		}

		strCCN = concatenate(BatchCCN, lfill((string)CurrentCCNSeqNo, 3, "0"));
		if(len(strCCN) != 11)
		{
			error_message = "form_entry: Invalid CCN generated.";
			log_error(EventLog_Handle, error_message);
			return false;
		}

		//populate to all the forms of this document
		for(i=1; i<=FORMCNT; i=i+1)
		{
			if(is_field_bound(DOCUMENT, i, "ccn"))
				set_field_value(DOCUMENT, i , "ccn", strCCN);
		}
		//increment DDD of CCN for next document
		CurrentCCNSeqNo = CurrentCCNSeqNo + 1;
	}
	

	return true;
}
