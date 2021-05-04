//FormDB\IEXPORT-EXPORT.ISL

string CHAR_STX = char(02);	//hex 0x02 = dec 2
string CHAR_ETX = char(03);	//hex 0x03 = dec 3
string CHAR_GS = char(29);	//hex ox1d = dec 29
string CHAR_RS = char(30);	//hex 0x1e = dec 30
string CHAR_FS = char(28);	//hex 0x1c = dec 28

// define output batch files
string REJ_output_file = "";
string IND_output_file = "";
string ZIP_output_file = "";
string DATA_output_file = "";
string CSV_output_file = "";

//file handles
opaque hREJfile;
opaque hINDfile;
opaque hDATAFile;
opaque hCSVfile;

//open file indicators
boolean bREJOpened = false;
boolean bINDOpened = false;
boolean bZIPOpened = false;
boolean bDATAOpened = false;
boolean bCSVOpened = false;

number REJ_record_count = 0;

number line_count = 40;

string
insertDecimal(string value, number dec_precision)
{
	string val1, val2;
	
	if (trim(value) == "") return "";	// empty string


	//12 converts to 12.000
	if (match(value, "[[:digit:]]+"))
		value = concatenate(value, ".", rept("0", dec_precision));

	//12.0 converts to 12.000
	//0.12 converts to 0.120
	else if (match(value, "([[:digit:]]*)\.([[:digit:]]*)")) {
		val1 = substitute(value, "([[:digit:]]*)\.([[:digit:]]*)", "\\1");
		val2 = substitute(value, "([[:digit:]]*)\.([[:digit:]]*)", "\\2");
		val2 = rfill(left(val2, dec_precision), dec_precision, "0" );
		value = concatenate(val1, ".", val2);
	}
	
	return value;
}

boolean open_CSV_file(string filename)
{
	boolean ok;
	string err_msg;

	bCSVOpened = false;

	CSV_output_file = pathname(EXPORT_CSV_PATH, filename);

	// Empty previous IND output file if exists
	truncate(CSV_output_file);

	ok = open(CSV_output_file, hCSVfile);
	if (!ok) {
		err_msg = concatenate("Fail to open CSV output file: ", CSV_output_file);
		log_error(EventLog_Handle, err_msg);
		bCSVOpened = false;
		return false;
	}

	bCSVOpened = true;

	return ok;
}

boolean open_RTP_CSV_file(string filename)
{
	boolean ok;
	string err_msg;

	bCSVOpened = false;

	CSV_output_file = pathname(EXPORT_RTP_CSV_PATH, filename);

	// Empty previous IND output file if exists
	truncate(CSV_output_file);

	ok = open(CSV_output_file, hCSVfile);
	if (!ok) {
		err_msg = concatenate("Fail to open CSV output file: ", CSV_output_file);
		log_error(EventLog_Handle, err_msg);
		bCSVOpened = false;
		return false;
	}

	bCSVOpened = true;

	return ok;
}

boolean close_CSV_file()
{
	boolean ok;
	string final_path;
	string err_msg;

	if (bCSVOpened) {
		close(hCSVfile);
		bCSVOpened = false;
	}

	if (get_file_size(CSV_output_file) != 0) {
		final_path = substitute(CSV_output_file, "_busy", "");
		remove(final_path);
		ok = rename(CSV_output_file, final_path);
		if (! ok) {
			err_msg = concatenate("Fail to rename CSV output file: ", CSV_output_file, " to ", final_path);
			log_error(EventLog_Handle, err_msg);
			return false;
		}
	}
	else
		remove(CSV_output_file);  // remove empty CSV output file

	return true;
}

boolean open_IND_file(string filename)
{
	boolean ok;
	string err_msg;

	bINDOpened = false;

	IND_output_file = pathname(EXPORT_INDEX_PATH, filename);

	// Empty previous IND output file if exists
	truncate(IND_output_file);

	ok = open(IND_output_file, hINDfile);
	if (!ok) {
		err_msg = concatenate("Fail to open Index output file: ", IND_output_file);
		log_error(EventLog_Handle, err_msg);
		bINDOpened = false;
		return false;
	}

	bINDOpened = true;

	return ok;
}

boolean close_IND_file()
{
	boolean ok;
	string final_path;
	string err_msg;

	if (bINDOpened) {
		close(hINDfile);
		bINDOpened = false;
	}

	if (get_file_size(IND_output_file) != 0) {
		final_path = substitute(IND_output_file, "_busy", "");
		remove(final_path);
		ok = rename(IND_output_file, final_path);
		if (! ok) {
			err_msg = concatenate("Fail to rename Index output file: ", IND_output_file, " to ", final_path);
			log_error(EventLog_Handle, err_msg);
			return false;
		}
	}
	else
		remove(IND_output_file);  // remove empty index output file

	return true;
}

boolean open_ZIP_file(string filename)
{
	boolean ok;
	string err_msg;

	bZIPOpened = false;

	ZIP_output_file = pathname(EXPORT_INDEX_PATH, filename);

	// remove previous ZIP output file if exists
	remove(ZIP_output_file);

	//clean up file if exists
	ok = zipplugin_open_zip(ZIP_output_file, "OVERWRITE");	
	if (!ok) {
		err_msg = concatenate("Fail to open Zip output file: ", ZIP_output_file);
		log_error(EventLog_Handle, err_msg);
		bZIPOpened = false;
		return false;
	}

	bZIPOpened = true;

	return ok;
}


//01/21/2020 - rsanchez60@dxc.com - created 2nd open_ZIP_file function with 2 parameters to pass a path instead of using default path:EXPORT_INDEX_PATH
boolean open_ZIP_file(string path, string filename)
{
	boolean ok;
	string err_msg;

	bZIPOpened = false;

	ZIP_output_file = pathname(path, filename);

	// remove previous ZIP output file if exists
	remove(ZIP_output_file);

	//clean up file if exists
	ok = zipplugin_open_zip(ZIP_output_file, "OVERWRITE");	
	if (!ok) {
		err_msg = concatenate("Fail to open Zip output file: ", ZIP_output_file);
		log_error(EventLog_Handle, err_msg);
		bZIPOpened = false;
		return false;
	}

	bZIPOpened = true;

	return ok;
}

boolean close_ZIP_file()
{
	boolean ok;
	string final_path, trigger_file;
	string err_msg;

	if (bZIPOpened) {
		zipplugin_close_zip();
		bZIPOpened = false;
	}

	if (get_file_size(ZIP_output_file) != 0) {
		final_path = substitute(ZIP_output_file, "_busy", "");
		remove(final_path);
		ok = rename(ZIP_output_file, final_path);
		if (! ok) {
			err_msg = concatenate("Fail to rename ZIP output file: ", ZIP_output_file, " to ", final_path);
			log_error(EventLog_Handle, err_msg);
			return false;
		}

		//07/13/2020 - rsanchez60@dxc.com - removed trigger directory
		//05/18/2020 - rsanchez60@dxc.com - 
		if (ok) {
			//compose trigger filename from final zip file name
			trigger_file = substitute(final_path, "([_[:alnum:]]+).zip", "\\1.trigger");
			//create an empty trigger file
			output(trigger_file, "");
		}

	}
	else
		remove(ZIP_output_file);  // remove empty zip file

	return true;
}

boolean close_ZIP_file2()
{
	boolean ok;
	string final_path, trigger_file;
	string err_msg;

	if (bZIPOpened) {
		zipplugin_close_zip();
		bZIPOpened = false;
	}

	if (get_file_size(ZIP_output_file) != 0) {
		final_path = substitute(ZIP_output_file, "_busy", "");
		remove(final_path);
		ok = rename(ZIP_output_file, final_path);
		if (! ok) {
			err_msg = concatenate("Fail to rename ZIP output file: ", ZIP_output_file, " to ", final_path);
			log_error(EventLog_Handle, err_msg);
			return false;
		}
	}
	else
		remove(ZIP_output_file);  // remove empty zip file

	return true;
}

boolean open_REJ_file(string filename)
{
	boolean ok = true;
	
	bREJOpened = false;

	//05312019 REJ file not required at this point
	return true;

	REJ_output_file = pathname(EXPORT_OUTPUT_PATH, filename);

	// Empty previous REJ output file if exists
	truncate(REJ_output_file);
	ok = open(REJ_output_file, hREJfile);
	if (ok)
		bREJOpened = true;
	else
		clean_up_busy_file(concatenate("Cannot create: ", REJ_output_file));

	REJ_record_count = 0;

	return ok;
}

boolean close_REJ_file()
{
	boolean ok;
	string final_path;
	string err_msg;

	//05312019 REJ file not required at this point
	return true;

	if (bREJOpened) {
		close(hREJfile);
		bREJOpened = false;
	}

	if (get_file_size(REJ_output_file) != 0) {
		final_path = substitute(REJ_output_file, "_busy", "");
		remove(final_path);
		ok = rename(REJ_output_file, final_path);
		if (! ok) {
			err_msg = concatenate("Fail to rename reject output file: ", REJ_output_file, " to ", final_path);
			log_error(EventLog_Handle, err_msg);
			return false;
		}
	}
	else
		remove(REJ_output_file);  // remove empty reject output file

	REJ_record_count = 0;

	return true;
}

boolean export_REJ_header()
{
	boolean ok;
	string buffer;

	buffer = rfill("DCN", 17, " ");						// DCN(15) + space(2)
	buffer = concatenate(buffer, rfill("Host Name", 14, " "));		// Host(12) + space(2)
	buffer = concatenate(buffer, rfill("Operator/Process", 21, " "));	// Operator(8) + "/" + Process(10) + space(2)
	buffer = concatenate(buffer, rfill("Code", 6, " "));			// "(" + RejectCode(2) + ")" + space(2)
	buffer = concatenate(buffer, "Reject Reason");

	ok = output(hREJfile, buffer);

	return ok;
}


boolean export_REJ_record(string dcn, string station_id, string operator_id, string process_id, string reject_code)
{
	boolean ok = true;
	string reject_code_desc;
	string buffer = "";

	//05312019 REJ file not required at this point
	return true;

	if (REJ_record_count == 0)
		export_REJ_header();

	buffer = rfill(left(trim(dcn), 15), 15, " ");
	buffer = concatenate(buffer, rept(" ", 2));
	buffer = concatenate(buffer, rfill(left(trim(station_id), 12), 12, " "));
	buffer = concatenate(buffer, rept(" ", 2));
	buffer = concatenate(buffer, lfill(left(trim(operator_id), 8), 8, " "));
	buffer = concatenate(buffer, "/");
	buffer = concatenate(buffer, rfill(left(trim(process_id), 10), 10, " "));
	buffer = concatenate(buffer, rept(" ", 2));
	buffer = concatenate(buffer, "(");
	buffer = concatenate(buffer, lfill(left(trim(reject_code), 2), 2, "0"));
	buffer = concatenate(buffer, ")  ");

	ok = query_Reject_Reason(reject_code, reject_code_desc);
	if (ok) {
		buffer = concatenate(buffer, rfill(left(trim(reject_code_desc), 50), 50, " "));
		ok = output(hREJfile, buffer);
	}

	REJ_record_count = REJ_record_count + 1;

	return ok;	
}

void clean_up_busy_file(string error_message)
{
	// close files
 	if (bINDOpened)	close(hINDfile);
 	if (bREJOpened)	close(hREJfile);
 	if (bDATAOpened)	close(hDATAFile);
	if (bZIPOpened) zipplugin_close_zip();
	if (bCSVOpened)	close(hCSVfile);
	
	// set file indicators to false
	bINDOpened = false;
	bREJOpened = false;
	bDATAOpened = false;
	bZIPOpened = false;
	bCSVOpened = false;
	
	// remove _busy files
	remove(IND_output_file);
	remove(REJ_output_file);
	remove(DATA_output_file);
	remove(ZIP_output_file);
	remove(CSV_output_file);
	
	if (bEventLogReady & trim(error_message) != "")
		log_error(EventLog_Handle, error_message);
}

boolean open_DATA_file(string outputDir, string filename)
{
	bDATAOpened = false;
	DATA_output_file = pathname(concatenate(EXPORT_OUTPUT_PATH, "\\", outputDir), filename);

	//generate output file, cleanup if exists, & open
	truncate(DATA_output_file);
	bDATAOpened = open(DATA_output_file, hDATAFile);
	if (!bDATAOpened)
		clean_up_busy_file(concatenate("Cannot open: ", DATA_output_file));
	return bDATAOpened;
}

boolean close_DATA_file(string oldFileName, string newFileName)
{
	boolean ok = true;
	string final_path;

	//close the file
	bDATAOpened = !(close(hDATAFile));
	
	if (get_file_size(DATA_output_file) == 0)
		remove(DATA_output_file);
	else
	{
		//now rename the file to .DAT
		final_path = substitute(DATA_output_file, "_busy", "");
		final_path = substitute(final_path, oldFileName, newFileName);
		
		remove(final_path);
		ok = rename(DATA_output_file, final_path);
		if (!ok)
			clean_up_busy_file(concatenate("Cannot rename: ", DATA_output_file, " to: ", final_path));
	}
	return ok;
}

number sum_tpl_amt(string &document, number formno, number formcnt)
{
	number i;
	number total = 0;
	
	for (i=formno; i <= formcnt; i=i+1) {
		if (match(form_name(document, i),"EOMB_1"))
			total = total + number(field_value(document, i, "amt_paid_mcare"));
	}
	
	return total;
}


string
convertToDollars(string value)
{
	string RE_cents = "([[:digit:]]+)([[:digit:]]{2})";

	if (trim(value) == "") return "";
	
	//amount should be minimum 3 digits before inserting decimal
	//1 --> 001
	//10 --> 010
	//100 = 100
	value = lfill(trim(value), 3, "0");
	//insert decimal in third position from end of string
	value = substitute(value, RE_cents, "\\1.\\2");
	return value;
}

void on_all_claims_rejected()
{
	//close the file
	if (bDATAOpened)
		bDATAOpened = !(close(hDATAFile));
	//remove ._busy file
	remove(DATA_output_file);
	//remove file too, if exists
	remove(substitute(DATA_output_file, "_busy", ""));
}

//one checkbox
string format_marksense(string checkbox, string value_true, string value_false)
{
	return (checkbox == "1") ? value_true : value_false;
}
//two checkboxes
string format_marksense(string checkbox_true, string checkbox_false, string value_true, string value_false)
{
	string value = "";
	
	if (checkbox_true == "1")
		value = value_true;
	else if (checkbox_false == "1")
		value = value_false;
	else
		value = " ";
	return value;
}

//recipient_id | AN | Len:14 | 1. if 9 chars, right justify 0 fill
//2. if 10 characters, output first 9, right justify, 0 fill
//3. if 15 characters, output first 14
//4. Default alphanumeric is blank
//5. If not 9, 10,14 or 15 characters Left justify and blank fill all alphanumeric field
string
format_recipient_id(string id)
{

	id = trim(id);
	if (len(id) == 9 || len(id) == 10)
		id = lfill(left(id,9), 14, "0");
	else if (len(id) == 14 || len(id) == 15)
		id = left(id,14);
	else
		id = rfill(left(id,14), 14, " ");
	
	return id;
}

// Convert MMDDYY or MMDDYYYY date format to MMDDYY format.
// "1.Output as MMDDYY
// 3. If invalid date format send default 000000
// 4. If date not calendar date output value keyed"
string format_date(string value)
{
	value = trim(value);
	if (validateDateFormat(value, "mmddyyyy|mmddyy"))
		value = format(date(value), "mmddyy");
	else if (match(value, "[[:digit:]]{6}")) {
		//do nothing; return same value
	} else
		value = "000000";
		
	return value;
}

// Convert MMDDYY or MMDDYYYY date format to YYYYMMDD format.
// If blank, output "00000000".
// If zeros, output "00000000".
// If invalid date, output "00000000".
string format_date2(string _date)
{
	string _mm, _dd, _yy, _yyyy;

	_date = trim(_date);
	if (_date == "") return "00000000";
	if (match(_date, "[0]+")) return "00000000";
	if (!validateDateFormat(_date, "mmddyyyy|mmddyy")) return "00000000";
	
	_mm = left(_date, 2);
	_dd = mid(_date, 3, 2);
	if (len(_date) == 6)
	{
		_yy = right(_date, 2);
		if (number(_yy) <= y2k_cutoff)
			_yyyy = concatenate("20", _yy);
		else
			_yyyy = concatenate("19", _yy);
	}
	else
		_yyyy = right(_date, 4);

	return concatenate(_yyyy, _mm, _dd);	
}

// Convert MMDDYY or MMDDYYYY date format to CCMMDDYY format.
// If blank, output "00000000".
// If zeros, output "00000000".
// If invalid date, output "00000000".
string format_date3(string _date)
{
	string _mm, _dd, _yy, _yyyy;

	_date = trim(_date);
	if (_date == "") return "00000000";
	if (match(_date, "[0]+")) return "00000000";
	if (!validateDateFormat(_date, "mmddyyyy|mmddyy")) return "00000000";
	
	_mm = left(_date, 2);
	_dd = mid(_date, 3, 2);
	if (len(_date) == 6)
	{
		_yy = right(_date, 2);
		if (number(_yy) <= y2k_cutoff)
			_yyyy = concatenate("20", _yy);
		else
			_yyyy = concatenate("19", _yy);
	}
	else
		_yyyy = right(_date, 4);

	return concatenate(left(_yyyy,2), _mm, _dd,right(_yyyy,2));
}

string
format_number(string value, number length)
{
	//remove -,.
	constrain(value, alphabet_digit);
	return lfill(left(string(number(value)), length), length, "0");
}

string
format_string(string value, number length, string filler)
{
	return rfill(left(trim(value), length), length, filler);
}

string get_claim_type_mapping(string claim_type)
{
	string ctype = "";
	
	if (match(left(claim_type,4), "PHAR")) {
		ctype = "01";
	} else if (match(left(claim_type,4), "DRUG")) {
		ctype = "01";
	} else if (match(left(claim_type,3), "LTC")) {
		ctype = "02";
	} else if (match(claim_type, "INP-REG|INP-SPBU|INP-ATCH|INP-RESUB|INP-OOY|INP-ADJ-VD|INP-A-RES|INP-A-ADJVD")) {
		ctype = "03";
	} else if (match(claim_type, "OUTP-REG|OUTP-SPBU|OUTP-ATCH|OUTP-RESUB|OUTP-OOY|OUTP-ADJ-VD|OUTP-A-RES|OUTP-A-ADJVD")) {
		ctype = "04";
	} else if (match(claim_type, "OUTP-XO")) {
		ctype = "04";
	} else if (match(claim_type, "MED-REG|MED-SPBU|MED-ATCH|MED-RESUB|MED-OOY|MED-ADJ-VD|MED-A-RES|MED-A-ADJVD")) {
		ctype = "05";
	} else if (match(claim_type, "MED-XO")) {
		ctype = "05";
	}

	return ctype;
}
