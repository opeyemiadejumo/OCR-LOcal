// FormDB\ACF\HEADER\global.isl
//

boolean batchOpened = false;
//boolean bResetIA = false;

string ErrorMsg = "";

// 07202020
number iLastDocNum = 0;

// ImageAddress string format:
// fieldA.fieldB.fieldC.fieldD

// parse the ImageAddress and return the "fieldC" value
string
getDocCount()
{
  string record = "";
  number pos1, pos2, pos3;

  if (!bound(ImageAddress))
    return record;

  record = substitute(ImageAddress, " ", "");		// remove spaces
  pos1 = find(record, ".");
  pos2 = find(record, ".", pos1+1);
  pos3 = find(record, ".", pos2+1);

  record = mid(record, pos2+1, pos3-pos2-1);	// get DocCount
  //record = mid(record, pos1+1, pos2-pos1-1);	// get BatchCount

  record = substitute(record, "\\.", "");
// record = right(record, 5);
  record = lfill(record, 3, "0");

  return (record);
}

boolean checkDailyCount(string& batch_no)
{
	boolean ok = true;
	string szTodayDate = "";
	string szLastUpdateDate = "";
	string strScannerReg;
	opaque reg_handle;
	number iLastBatchNo;
	string regValueYYYYMMDD = "";
	
	string _mmddyyyy = "";
	_mmddyyyy = JulianToMMDDYYYY(receive_date);
	// make sure receive_date is a valid date
	if ((_mmddyyyy != format(date(_mmddyyyy), "mmddyyyy")) ||
		((date)_mmddyyyy > (date)today()))
		return false;

	strScannerReg = concatenate("SOFTWARE\\Impression Technology\\iScanPlus\\7.0\\", ENVIRONMENT, "\\", "receive_date");

	ok = open_registry("", "HKEY_LOCAL_MACHINE",  strScannerReg, "rw", reg_handle);
	if (! ok) return false;

	// regValueYYYYMMDD is in yyyymmdd format
    regValueYYYYMMDD = concatenate(right(_mmddyyyy , 4), left(_mmddyyyy , 4));
	
	ok = query_registry_number_value(reg_handle, regValueYYYYMMDD, iLastBatchNo);
    if (!ok) {	// if not exist, create it and value zero
        iLastBatchNo = 0;
        ok = set_registry_number_value(reg_handle, regValueYYYYMMDD, iLastBatchNo);
        if (!ok) {	// failed
          close_registry(reg_handle);
          return false;
        }
    }
	close_registry(reg_handle);
	
// let scanner autometically increament the count
//	// increment the batch count
//	iLastBatchNo = iLastBatchNo + 1;

	// format the return value
	batch_no = lfill((string)iLastBatchNo, 4, "0");
	return true;
}

//
void SetFaxBatch()
{
	receive_date = format((date)today(), "yyjjj");
	attachment = "Regular";
	form_id = "ACF";
	claim_type = "ACF-FAX";
	crossover = "N";
	use_patch2 = "1";
	capture = "OCR";
	signature = "N/A";
	set_scan_date_time(scan_date);
}

// SetBatchID() will retrun a character string 
// format: "SIIYYJJJBBBBB"
//  SID - ScannerID, use SourceID
//	YYJJJ - Year Julian date	// parse "receive_date"
//  BBBB - Batch Number 		// use "batch_number"
string
SetBatchID ()
{
	string batch_id = "";
	boolean ok;
	string _mmddyyyy = "";

	if (BatchName != "") {	// rescan mode
		batchOpened = true;
		return (BatchName);
	}

	// Fax document
	if (left(SourceID, 1) == "F") {
		// set default values for Fax
		SetFaxBatch();
	}

	_mmddyyyy = JulianToMMDDYYYY(receive_date);
	if (format (date (_mmddyyyy), "mmddyyyy") != _mmddyyyy)	// bad date format
		return (batch_id);

	// 07202020
	iLastDocNum = 0;
	
	batch_id = concatenate(	rfill(SourceID, 3, "0"), receive_date,	batch_number );
	return (batch_id);
}

// SetOfflineBatchID() will retrun a character string 
// format: "RRYYJJJBBB" (same sa SetBatchID ())
string
SetOfflineBatchID ()
{
 	return ( SetBatchID () );
}


// SetDLNString() will retrun a character string 
// format: SIIYYJJJBBBBDDD, where
//  SID - ScannerID, use SourceID
//	YYJJJ - Year Julian date	// parse "receive_date"
//  BBBB - Batch Number 		// use "batch_number"
//	DDDD - Document sequence number
string
SetDLNString (number pageNum)
{
	string szDLN = "";
	string szDocCnt = "";
	number pageNo;
	number DocNo;	// 07202020
	
	if (bound(LastPageEndorserString) && (LastPageEndorserString != "")) {

		szDLN = trim(LastPageEndorserString);
		// 07202020
		DocNo = (number)right(szDLN, 3);
		if (DocNo < iLastDocNum) {
			log_error(EventLog_Handle, 
				concatenate("DLN reset in batch ", BatchName,
				", incorrect DLN ", szDLN, " detected."));
			szDLN = "";
		}
		else
			iLastDocNum = DocNo;
			
		return (szDLN);
	}
	else {
		szDocCnt = getDocCount();
			
		szDLN = concatenate( rfill(SourceID, 3, "0"), receive_date, batch_number, szDocCnt);
		// 07202020
		DocNo = (number)szDocCnt;
		if (DocNo < iLastDocNum) {
			log_error(EventLog_Handle, 
				concatenate("DLN reset in batch ", BatchName,
				", incorrect DLN ", szDLN, " detected."));
			szDLN = "";
		}
		else
			iLastDocNum = DocNo;
			
		return (szDLN);
	}

	return (szDLN);
}

// SetInitIAString() returns a string which shows the initial ImageAddress string that
// will useful for composing imprint string.
//
// CA's im-print format SIIYYJJJBBBBDDDD
//  SID - ScannerID, use SourceID
//	YYJJJ - Year Julian date	// parse "receive_date"
//  BBBB - Batch Number 		// use "batch_number"
//	DDDD - Document sequence number
//	001  - dummy number for IA's field_d	// always start from "001; Kodak need this, otherwise
//						// the batchNumber CANNOT start zero !!
string
SetInitIAString()
{
	string szJulianDate = "";
	string szIAString = "";
	string szLastBatchNo;
	boolean ok;
	number _batchNo;
	string szStartDoc = "";

	// 03112011 check "LastUpdateDate" value
	ok = checkDailyCount(szLastBatchNo);
	if (! ok) return "";

	if ((AutoScan != 1) && (Manual_HeaderSheet == 0)) {
		_batchNo = (number)szLastBatchNo + 1;
		szLastBatchNo = (string)_batchNo;
		szLastBatchNo = lfill(szLastBatchNo, 4, "0");
	}
	if ((AutoScan == 1) || (Manual_HeaderSheet == 1))
		szStartDoc = "001";
	else
		szStartDoc = "000";

	batch_number = szLastBatchNo;
	
	if ((AutoScan != 1) && (Manual_HeaderSheet == 1)) {	// increment batch_number by 1
		batch_number = (string)((number)batch_number + 1);
		batch_number = lfill(batch_number, 4, "0");
	}
	
	//szJulianDate = format((date)receive_date, "yyjjj");
	szIAString  = concatenate(rfill(SourceID, 3, "0"), receive_date, ".",
							  szLastBatchNo, ".",
							  szStartDoc, ".",
							  "001");
	return (szIAString);
}

// SetNextIAString()
string
SetNextIAString()
{
	string szJulianDate = "";
	string szIAString = "";
	string szStartDoc = "";
	string szStartBatchNo = "";

	//bResetIA = True;
	//return SetInitIAString();
	
	szStartBatchNo = batch_number;
	
	if ((AutoScan != 1) && (Manual_HeaderSheet == 1)) {	// decrement start batch# by 1
		szStartBatchNo = (string)((number)batch_number - 1);
		szStartBatchNo = lfill(szStartBatchNo, 4, "0");
	}
	
	if (use_patch2 == "0")
		szStartDoc = "001";
	else 
		szStartDoc = "000";
		
	//szJulianDate = format((date)receive_date, "yyjjj");
	szIAString  = concatenate(rfill(SourceID, 3, "0"), receive_date, ".",
							  szStartBatchNo, ".",
							  szStartDoc, ".",
							  "001");
	return (szIAString);
}


// 10082004 this function will be called only when re-open a offline batch.
// SetNextIAString(number pageNum)
string
SetNextIAStringByPage(number pageNum)
{
	string szJulianDate = "";
	string szIAString = "";
	string MMDD = "";
	string YY = "";
	number pageNo;

	if (Duplex)
	pageNo = (pageNum+1)/2;
	else
	pageNo = pageNum;

	//szJulianDate = format((date)receive_date, "yyjjj");
	szIAString  = concatenate ( rfill(SourceID, 3, "0"), receive_date, ".",
								lfill(batch_number, 4, "0"), ".",
								"001.001");
	return (szIAString);
}

// GetIAStringFormat() returns a string which shows the format of ImageAddress string
string
GetIAStringFormat ()
{
	string szFormat = "";
	
//	// 2019 test
//	boolean ok;
//	string szStart = "";
//	ok = checkDailyCount(szStart);
//	
//	if (ok) return szStart;
//	else
//		return "1";

	szFormat = "Fixed\%3L\%2L\%1L";
	return (szFormat);
}

// HeaderSheetAutoUpdate()
string
HeaderSheetAutoUpdate()
{
  boolean ok;
  string szStart = "";
  number n;

  n = (number)batch_number + 1;
	
  batch_number = lfill((string)n, 4, "0");

  return szStart;
}


// SetClientData() will retrun a character string 
// format: SIIYYJJJBBBBDDDC   "
//  SID - ScannerID, use SourceID
//	YYJJJ 		- Year Julian date			// parse "receive_date"
//  BBBB 		- Batch Number 				// use "batch_number"
//	DDD  		- Document sequence number
//  CCCC-SUBTYPE - Claim Type/Sub-Type		// use "claim_type"
string
SetClientData ()
{
	string client_data = "";
	string strScannerReg = "";
	opaque reg_handle;
	boolean ok;
	string regValueYYYYMMDD = "";
	string _mmddyyyy = "";
	
	_mmddyyyy = JulianToMMDDYYYY(receive_date);

	if (!scanner) {		// use BatchName to re-construct the ClienData
		client_data = concatenate(BatchName, claim_type);		// lfill(claim_type, 1, "0"));
		client_data = rfill(client_data, 32, " ");
		return client_data;
	}
		
	strScannerReg = concatenate("SOFTWARE\\Impression Technology\\iScanPlus\\7.0\\", ENVIRONMENT, "\\", "receive_date");
	ok = open_registry("", "HKEY_LOCAL_MACHINE",  strScannerReg, "rw", reg_handle);
	if (! ok) return false;

	// regValueYYYYMMDD is in YYYYMMDD format
	regValueYYYYMMDD = concatenate(right(_mmddyyyy , 4), left(_mmddyyyy , 4));
	ok = set_registry_number_value(reg_handle, regValueYYYYMMDD, (number)batch_number);

	close_registry(reg_handle);

	client_data = concatenate(rfill(SourceID, 3, "0"),
							  receive_date,		//format((date)receive_date, "yyjjj"),
							  batch_number,
							  claim_type);		// lfill(claim_type, 1, "0"));
	client_data = rfill(client_data, 32, " ");
	return (client_data);
}

//
// General function for iTransBuilder to return "BatchType" based on doc_type set at scan time
string get_batch_type ()
{
//	if (use_patch2 == "0")
//		return ("Single");
//	else
		return ("Attachment");			
}

string get_next_TRANSBUILDER_fail_route()
{
	if (left(SourceID, 1) == "F")
		return "FAX_EXC";
	else
		return "SCAN_EXCEPTION";
}

string get_next_TRANSBUILDER_success_route()
{
	if (capture == "KFI")
		return "KFI";
	else
		return "OCR_FORM";
}

boolean set_scan_date_time(string _scan_date)
{
	string _date = "";
	string _current_time = "";
	string _hh, _mm, _ss;

	// TEST
//	number i;
//	i= weekday(receive_date);
	
	if ((scanner || (left(SourceID, 1) == "F")) && (trim(scan_date) == ""))
	{
		_date = format((date)today(), "mm/dd/yyyy");

		_current_time = time("hhmmss");
		_hh = left(_current_time, 2);
		_mm = mid(_current_time, 3, 2);
		_ss = right(_current_time, 2);

		scan_date = concatenate(_date, " ", _hh, ":", _mm, ":", _ss);
	}
	return true;
}

boolean IsHoliday(string dummy)
{
	boolean ok = true;
	string Holiday_Name = "";
	
	ErrorMsg = "";
	ok = table_lookup(HOLIDAY_TABLE, JulianToMMDDYYYY(receive_date), Holiday_Name);
	if (ok) {
		// receive_date is a holiday
		ErrorMsg = concatenate("Receive Date is ", Holiday_Name, ": cannot be a holiday. Rule H.5");
	}
	return ok;
}

boolean scrub_doc_count(string _dummy)
{
	doc_count = (string)NumDocs;
	return true;
}

boolean set_claim_type(string _dummy)
{
	if (left(SourceID, 1) == "F")
		claim_type = "ACF-FAX";
	else
		claim_type = "ACF-SCAN";
		
	return true;
}


// Global header rules.

//Rule H.1 - receive_date: Must be a valid date.	- not overridable
assert
	(JulianToMMDDYYYY(receive_date) == format(date(JulianToMMDDYYYY(receive_date)), "mmddyyyy")) &&
	(match(receive_date, "[[:digit:]]{5}"))
	@ receive_date
	# "Receive Date: Must be a valid date. Format: yyjjj. Rule H.1";

//Rule H.2 - receive_date: cannot be a future date.	- not overridable
assert
	(date)JulianToMMDDYYYY(receive_date) <= (date)today()		// || overridden(receive_date)
	@ receive_date
	# "Receive Date: cannot be a future date. Rule H.2";

// Rule H.3 - receive_date: cannot be a older date over NUMBER_OF_BACKDATE_SCAN.	// - not overridable
assert
	(date)JulianToMMDDYYYY(receive_date) > ((date)today() - NUMBER_OF_BACKDATE_SCAN)		// || overridden(receive_date)
	@ receive_date
	# "Receive Date: cannot be older than " NUMBER_OF_BACKDATE_SCAN " days. Rule H.3";

//Rule H.4 - receive_date: cannot be a weekend date - overridable
assert
	(!scanner) ||
	overridden(receive_date) ||
	((weekday(date(JulianToMMDDYYYY(receive_date))) > 1) && (weekday(date(JulianToMMDDYYYY(receive_date))) < 7))
	@ receive_date
	# "Receive Date: cannot be a weekend date. Rule H.4";
	
//Rule H.5 - receive_date: cannot be a holiday - overridable
assert
	(!scanner) ||
	overridden(receive_date) ||
	(IsHoliday(receive_date) == false)
	@ receive_date
	# ErrorMsg;
	
// Rule H.6 - set scan_date (scrub)
assert
	(!scanner) ||
	set_scan_date_time(scan_date)
	@ scan_date
	# "";

assert
	set_claim_type(claim_type)
	@ claim_type
	# "";

// Scrub number of documents from QRF to doc_count
//assert
//	(itransbuilder)
//		? scrub_doc_count(doc_count)
//		: true
//	@ EndOfForm
//	# "";


//Insert custom Batch Statistics		
assert
	(itransbuilder)
       ? insert_batch_statistics(BatchName, DocID, claim_type, NumDocs, scan_date, (string)NumDocs, substitute(APPLICATION, "[^-]+-([^-]+)", "\\1"))
       : true
	@ EndOfForm
	# "";

//Update custom Batch Statistics	
assert
	(preXOVER || preKFI || postKFI || postOCR || preINDEX)  && claim_type != ""
       ? update_batch_statistics(BatchName, (string)NumDocs, "", substitute(APPLICATION, "[^-]+-([^-]+)", "\\1"))
       : true
	@ EndOfForm
	# "";
