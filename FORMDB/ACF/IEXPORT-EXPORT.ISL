//FORMDB\ACF\iexport-export.isl

number batch_iterations = 2;
number document_iterations = 1;
number detail_count = 0;
boolean rejected_claim = false;
string document_ccn = "";

// Document entry function, called from iExport after
boolean document_entry(number iteration)
{
	boolean ok = true;
	string src_tiff;
	
	//initiate first and last page ACF variables
	first_ACF_formno = get_first_FormID_form_no("ACF");
	last_ACF_formno = first_ACF_formno;
	
	rejected_claim = (trim(field_value(DOCUMENT, first_ACF_formno, "reject_code")) != "");
	
	if (batch_iteration_count == 1) 
	{
		first_ccn = "";
		last_ccn = "";
			
		//clear ALL_CLAIMS_REJECTED indicator when non-rejected claim found in first pass
		if (!rejected_claim)
			ALL_CLAIMS_REJECTED = false;
		else
			AT_LEAST_ONE_CLAIM_REJECTED = true;
			
	} 
	else 
	{
		//retrieve CCN and use it to be filename
		array_get(ccn_list, DOCNO, 1, document_ccn);

		if (!rejected_claim) 
		{
			// Generate the multi-page TIFF file in internal batch_dir folder
			src_tiff = Generate_MultiPage_TIFF(document_ccn);
			if (src_tiff == "")
				return false;
				
			// add the multi-page tiff file to the zip file
			ok = zipplugin_add_file_to_zip(src_tiff, false);
			// delete the .tif file after done
			remove(src_tiff);
			if (!ok) 
			{
				err_msg = concatenate("Failed to add image file (", src_tiff, ") to ", ZIP_output_file);
				clean_up_busy_file(err_msg);
				return false;  
			}
		
			//output for all DCNs in the batch that were processed.
			if (ok) {
				ok = Output_Index(first_ACF_formno);
			}
			
			error_message = "";
			if (!ok)
				clean_up_busy_file(error_message);
		}
	}
	return ok;
}

// Document exit function, called from iExport after
boolean document_exit(number iteration)
{
	boolean ok = true;
	string claim_dcn, reject_code, reject_operator;
	string strImportDateTime;
	string rollno;

	//only process for second batch iteration
	if (batch_iteration_count == 1)
		return true;

	//get the DCN from first form
	claim_dcn = trim(field_value(DOCUMENT, first_ACF_formno, "dcn"));
	
	//Output file for all documents (rejected/not rejected)
	if (ok) {
		ok = Output_CSV(claim_dcn);
	}	
	
	reject_code = "0";
	reject_operator = "";

	//check if the claim is rejected
	//this function will return reject_code and reject_operator if the claim was rejected
	is_claim_rejected(reject_code, reject_operator);

	//get the import date time from iTransBuilder date time stamp from header dcr
	strImportDateTime = get_import_date_time();

	//get Roll# from first page ccn. CCN format: YJJJRRBBDDD
	//rollno = mid(document_ccn, 5, 2);
	rollno = mid(field_value(DOCUMENT,1,"ccn"), 5, 2);
	//insert a record into ClaimStatistics database table
	ok = insert_claim_statistics(claim_dcn, rollno, batch_number, FORMCNT, claim_type, 
			reject_code, reject_operator, scan_date, strImportDateTime);
	if(!ok)
	{
		clean_up_busy_file("Cannot insert_claim_statistics on table ClaimStatistics.");
		return false;
	}

	return true;
}

string get_reject_operator(number nFormNo)
{
	string _value, _reject_operator, _comment;
	number _cnt, _gen_no, i, dash_pos;

	// get the result count of the "reject_code" field.
	_cnt = get_result_count(DOCUMENT, nFormNo, "reject_code");
	if (_cnt <= 0) return "";     // no result

	//loop thru to get to the last edit result
	for(i=_cnt; i>0; i=i-1)
	{
		//get the value as well as generation number first
		_value = get_field_result(DOCUMENT, nFormNo, "reject_code", i, _gen_no);
		//value is blank, claim not rejected
		if (_value == "") return "";

		//get the comment which is in the form Application-Queue
		_comment = trim(get_comment(DOCUMENT, _gen_no));
		//now check if the queue is one of the edit queue
		dash_pos = find(_comment, "-");
		if(dash_pos != 0)
		{
			if(match(upper(mid(_comment, dash_pos+1)), EDIT_QUEUES))
					return get_author_name(DOCUMENT, _gen_no);
		}
	}
	return "";
}

boolean is_claim_rejected(string & claim_dcn, string & reject_code, string & reject_operator)
{
	number nFormNo = 0;

	for(nFormNo=1; nFormNo<=FORMCNT; nFormNo=nFormNo+1)
	{
		//check if the form is ACF form
		if (match(upper(form_name(DOCUMENT, nFormNo)), "ACF"))
		{
			//check if the reject_code field is non-blank
			if(trim(field_value(DOCUMENT, nFormNo, "reject_code")) != "")
			{
				claim_dcn = left(trim(field_value(DOCUMENT, nFormNo, "dcn")), 13);
				reject_code = trim(field_value(DOCUMENT, nFormNo, "reject_code"));
				//reject_operator = trim(field_value(DOCUMENT, nFormNo, "reject_operator"));
				reject_operator = get_reject_operator(nFormNo);
				return true;
			}
		}
	}
	return false;
}

boolean is_claim_rejected(string & reject_code, string & reject_operator)
{
	number nFormNo = 0;

	for(nFormNo=1; nFormNo<=FORMCNT; nFormNo=nFormNo+1)
	{
		//check if the form is ACF form
		if (match(upper(form_name(DOCUMENT, nFormNo)), "ACF"))
		{
			//check if the reject_code field is non-blank
			if(trim(field_value(DOCUMENT, nFormNo, "reject_code")) != "")
			{
				reject_code = trim(field_value(DOCUMENT, nFormNo, "reject_code"));
				reject_operator = get_reject_operator(nFormNo);
				return true;
			}
		}
	}
	return false;
}

string get_import_date_time()
{
	number nGenCount, nGenNo;
	string strAutorName = "";
	string strAuthorDate = "";
	string strAuthorTime = "";

	nGenCount = get_generation_count(DOCUMENT);
	for(nGenNo=0; nGenNo<nGenCount; nGenNo=nGenNo+1)
	{
		strAutorName = get_author_name(DOCUMENT, nGenNo);
		if(upper(strAutorName) == upper("iTransBuilder-TRANS_BUILDER"))
		{
			strAuthorDate = get_author_date(DOCUMENT, nGenNo);
			strAuthorDate = substitute(strAuthorDate, "-", "");
			strAuthorDate = format_date2(strAuthorDate);
			strAuthorTime = get_author_time(DOCUMENT, nGenNo);
			return concatenate(strAuthorDate, " ", strAuthorTime);
		}
	}
	return "";
}


// Generate multi-page TIFF file for all non-blank images of current document.
// This function converts all TIFF image to 200 dpi before concatenating them into multi-page TIFF.
// Upon success, this function returns the multi-page TIFF file path which is
//    <BatchDir>\<1st page's TCN>.tif
// When failed, this function returns "".
// This function deletes the multi-page TIFF file first (if exist), which may be created from previous failed export attempt.
// Failed multi-page TIFF file is left un-deleted for debugging purpose.
string Generate_MultiPage_TIFF(string output_dcn)
{
	string dst_file, ccn_file;
	string formname,ccn_field;
	number i, page_count;
	boolean ok;

	dst_file = pathname(BATCH, concatenate(output_dcn, ".tif"));
	// remove the multi-page TIFF file first (if exist).
	remove(dst_file);

	page_count = 0;
	for (i = 1; i <= FORMCNT; i=i+1) {
		formname = form_name(DOCUMENT, i);
		if (formname != "BLANK") {
			page_count = page_count + 1;	// increment the page count in multi-page TIFF

			//use .arc+ccn image created at first pass form-level iExport
			ccn_file = pathname(BATCH, concatenate(form_path(DOCUMENT, i), ".arc+ccn"));

			ok = append_tiff(dst_file, ccn_file);
			if (!ok) {
				error_message = concatenate("Fail to append TIFF file ", ccn_file, " to ", dst_file);
				log_error(EventLog_Handle, error_message);
				return ""; // error; fail to append TIFF
			}
			remove(ccn_file);
		}	
	}

	if (page_count == 0) {
		error_message = concatenate("Document contains all blank pages. Batch: ", BATCH, " , Doc #: ", DOCNO);
		log_error(EventLog_Handle, error_message);
		return "";	// error; document contains all blank pages
	}

	return dst_file;
}

boolean Output_Index(number _first_ACF_formno)
{
	boolean ok;
	string buffer = "";
	string _value = "";

	//CCN	| Len:11
	buffer = document_ccn;

	//Source | Len:1 
	if (left(BatchName, 1) == "F")
		buffer = concatenate(buffer, "|", "F");
	else
		buffer = concatenate(buffer, "|", "O");

	//acn | Len:11
	_value = trim(field_value(DOCUMENT, _first_ACF_formno, "acn"));
	buffer = concatenate(buffer, "|", lfill(_value, 11, "0"));

	//provider_no | Len:10 | 
	_value = trim(field_value(DOCUMENT, _first_ACF_formno, "prov_number"));
	buffer = concatenate(buffer, "|", rfill(_value, 10, " "));

	//Registration | Len:0 | 	- always blank
	buffer = concatenate(buffer, "|");

	//Signature	| Len:1
	_value = trim(field_value(DOCUMENT, _first_ACF_formno, "prov_signature"));
	buffer = concatenate(buffer,  "|", _value);

	//Attachment | Len:1
	if (FORMCNT > 1)
		buffer = concatenate(buffer,  "|", "1");
	else
		buffer = concatenate(buffer,  "|", "0");
	
	ok = output(hINDfile, buffer);
	if (!ok) {
		error_message = concatenate("Failed to output to Index file: ", IdxFile);
		log_error(EventLog_Handle, error_message);
		return false;  // error; failed to output to index file
	}

	return true;
}

boolean Output_CSV(string strDCN)
{
	boolean ok;
	string buffer, temp;
	
	//Claim Type
	buffer = claim_type;
	
	//Scan Date Time	
	temp = left(ScanTime, 8);
	buffer = concatenate(buffer, ",", format((date)temp, "mm-dd-yyyy"), " ", right(ScanTime,8));
	
	//Export Date Time
	if(rejected_claim)
		buffer = concatenate(buffer, ",", "");
	else
		buffer = concatenate(buffer, ",", format(today(), "mm-dd-yyyy"), " ", time("hh:mm:ss"));
	
	//Batch Header Barcode
	buffer = concatenate(buffer, ",", barcode);	

	//05/15/2020 - rsanchez60@dxc.com - output CCN for rejected claims as well
	buffer = concatenate(buffer, ",", document_ccn);
	
	//Document DCN
	buffer = concatenate(buffer, ",", strDCN);
	
	//Page Count
	buffer = concatenate(buffer, ",", (string)FORMCNT);
	
	//Claim Rejected?
	if(rejected_claim)
		buffer = concatenate(buffer, ",", "Y");
	else
		buffer = concatenate(buffer, ",", "N");
	
	//There is no .tif file for rejected file.
	if(rejected_claim)
		buffer = concatenate(buffer, ",", "");
	else
		buffer = concatenate(buffer,  ",", document_ccn, ".tif");
		
	ok = output(hCSVfile, buffer);
	if (!ok) {
		error_message = concatenate("Failed to output to CSV file: ", CSV_output_file);
		log_error(EventLog_Handle, error_message);
		return false;  // error; failed to output to index file
	}

	return true;
}
