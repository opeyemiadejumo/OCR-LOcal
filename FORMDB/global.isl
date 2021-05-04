//FormDB\global.isl

// Application types.
boolean scanner = match (APPLICATION, "iScanPlus-[^-]+|iScanTAR-[^-]+|iScanClaim-[^-]+|iScanDR-[^-]+");
boolean kfi_edit = match (APPLICATION, "iEditKFI-KFI_EDIT");
boolean kfi_verify = match (APPLICATION, "iEditKFI-KFI_VERIFY");
boolean xover_edit = match (APPLICATION, "iEditKFI-CROSSOVER.*");
boolean preXOVER = match (APPLICATION, "iPreXOVER-PRE_XOVER");
boolean preKFI = match (APPLICATION, "iPreKFI-PRE_KFI");
boolean postKFI = match (APPLICATION, "iPostKFI-POST_KFI");
boolean postOCR = match (APPLICATION, "iPostOCR-POST_OCR");
boolean postTAR = match (APPLICATION, "iPostTAR-POST_TAR");														   
boolean preINDEX = match (APPLICATION, "iPreIndex-PRE_INDEX");
boolean ocr_edit = match (APPLICATION, "iFieldEdit-OCR_EDIT.*");
boolean itransbuilder = match(APPLICATION, "iTransBuilder-TRANS_BUILDER");
boolean iexport = match(APPLICATION, "iExport-EXPORT");
boolean kfp_edit = match(APPLICATION, "iEditKFP-.*");
boolean preQC = match (APPLICATION, "iPreQC-PRE_QC");
boolean qc_edit = match (APPLICATION, "iExcEdit-QC_EDIT");
boolean preEXPORT = match (APPLICATION, "iPreExport-PRE_EXPORT");
boolean index_tar = match (APPLICATION, "iEditKFI-INDEX_TAR");
boolean idx_tar_appeal = match (APPLICATION, "iEditKFI-IDX_TAR_APPEAL");
boolean RejectCount = match (APPLICATION, "iRejectCount-REJECT_COUNT");
//04/06/2020 - rsanchez60@dxc.com -
boolean any_KDE = match (APPLICATION, "(iEditKFI|iFieldEdit|iEditKFP|iExcEdit)-[^-]+");

// Common error string values returned by iSL built-in functions
string strUNKNOWN_FIELD_NAME = "### Field not found ###";
string error_message = "";

//***********************************************************
//constant definitions - ** DO NOT MODIFY **
string strBLANK = "";
string alphabet_upper = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ";
string alphabet_lower = "abcdefghijklmnñopqrstuvwxyz";
string alphabet_alpha = concatenate (alphabet_upper, alphabet_lower);
string alphabet_digit = "0123456789";
string alphabet_alnum = concatenate (alphabet_alpha, alphabet_digit);
//05/12/2020 - rsanchez60@dxc.com - added alphabet_negative_amount
string alphabet_negative_amount = "-0123456789";
//06/19/2020 - rsanchez60@dxc.com - 
string alphabet_name = concatenate (" ", alphabet_alnum);

string BLANK = "BLANK";
string NO_BLANK = "NO_BLANK";
string DB_LOOKUP = "DB_LOOKUP";
string NO_DB_LOOKUP = "NO_DB_LOOKUP";
string FIRST = "FIRST";
string LAST = "LAST";
//***********************************************************

string first_dcn = "";
string last_dcn = "";
string first_ccn = "";
string last_ccn = "";

string EDIT_QUEUES = "OCR_EDIT.*|KFI_EDIT|KFI_VERIFY|INDEX_EDIT|CROSSOVER.*|INDEX_TAR|IDX_TAR_APPEAL|IDX_DRUGREBATE|INDEX_CORR";
string REJECT_FIELDS = "reject_code|reject_station_id|reject_operator_id|reject_process_id";

//Valid values definitions
string valid_Medicare  = "MCARE|MEDICARE";
string valid_Medical  = "MEDICAL|MEDI-CAL";
string valid_Medicare_value_codes = "A1|A2|B1|B2";

// Cut-off for converting 2-digit years to 4-digit years.
number y2k_cutoff = 25;

//06/23/2020 - rsanchez60@dxc.com - allow spaces
//05/26/2020 - rsanchez60@dxc.com - MC - Remove special characters - From DHCS feedback should not key any special characters in the Names fields
//02/10/2020 - RSanchez60@dxc.com - AN (24)  including special characters (! & ( ) +  - . / ; : = ? # $ % ' ") with the exception of comma (,)
// string RE_NAME_24 = "[\!\&\(\)\+-\.\/\;\:=\?\#\$\%\'\"[:alnum:]]{0,24}";
string RE_NAME_24 = "[[:space:][:alnum:]]{0,24}";
//"
string RE_NOT_COMMA = "[^,]+";

void
fixup_alphas_to_digits (string& S)
{
  S = substitute (S, "[DOo]", "0");
  S = substitute (S, "[IiLl/]", "1");
  S = substitute (S, "[Zz]", "2");
  S = substitute (S, "[Ss]", "5");
  S = substitute (S, "[B]", "8");
  S = substitute (S, "[W]", "6");
  S = substitute (S, "[Q]", "9");
  S = substitute (S, "[Y]", "4");

  return;
}

// 01/08/2003	BFV
void
convert_digits2alphas(string &strVal)
{
	strVal = substitute(strVal, "[0]", "O");
	strVal = substitute(strVal, "[1]", "L");
	strVal = substitute(strVal, "[2]", "Z");
	strVal = substitute(strVal, "[5]", "S");
	strVal = substitute(strVal, "[8]", "B");
	
	return;
}

void
fixup_digits_to_alphas (string& S)
{
  S = substitute (S, "0", "O");
  S = substitute (S, "1", "I");
  S = substitute (S, "2", "Z");
  S = substitute (S, "5", "S");
  S = substitute (S, "8", "B");

  return;
}

boolean
validateModifiers(string code, number min, number max)
{
	boolean ok;
	string mod, err_mods;
	string pattern = concatenate("([[:alnum:]]{2}){", (string)min, ",", (string)max, "}");
	
	error_message = "";

	ok = match(code, pattern);
	if (!ok)
		error_message = "Procedure Code Modifier must be 0, 2, 4, 6 or 8 characters.";

	if (ok) {
		err_mods = "";
		while (len(code) >= 2) {
			mod = left(code, 2);
			if (!is_valid_Modifier(mod)) {
				ok = false;
				if (err_mods != "")
					err_mods = concatenate(err_mods, ",", mod);
				else
					err_mods = mod;
			}
			code = right(code, len(code) - 2);
		}

		if (!ok)
			error_message = concatenate("Modifier(s) not found in table: ", err_mods, ".");
	}

	return ok;
}

boolean validateDateFormat(string valDate, string date_format)
{
	boolean ok = false;
	number value;

	date_format = lower(date_format);
	if (match(date_format, "mmddyy")) {
		ok = (valDate == format((date)valDate, "mmddyy"));
	} else if (match(date_format, "mmddyyyy")) {
		ok = (valDate == format((date)valDate, "mmddyyyy"));
	} else if (date_format == "mmddyy|mmddyyyy") {
		ok = (valDate == format((date)valDate, "mmddyy") || valDate == format((date)valDate, "mmddyyyy"));
	} else if (date_format == "mmddyyyy|mmddyy") {
		ok = (valDate == format((date)valDate, "mmddyy") || valDate == format((date)valDate, "mmddyyyy"));
	}

	if (ok && valDate == format((date)valDate, "mmddyyyy")) {
		value = number(format((date)valDate, "yyyy"));
		ok = (value > 1900);
	}

	return ok;
}

string
getMultiLine(string start_pos, string str)
{
	number i, n;

	n = find(str, NL);
	if (n == 0)
		return str;
	else if (start_pos == FIRST)
		return left(str, n - 1);
	else {
		//LAST - reverse search for new line character
		n = len(str);
		for(i = n; i >= 1; i = i - 1) {
			if (mid(str, i, 1) == NL)
				return right(str, n - i);
		}
	}

	return str;
}

// 05/11/04 C.Hou - New function to extract data:
//	if start_pos is FIRST:	Extract first line's first 'length' characters.
//	if start_pos is LAST:	Extract last line's last 'length' characters.
string
getMultiLine(string start_pos, string str, number length)
{
	number i, n;

	n = find(str, NL);
	if (n == 0) {
		// single line
		if (start_pos == FIRST)
			return left(str, length);
		if (start_pos == LAST)
			return right(str, length);
			
	}

	// multi-lines found

	if (start_pos == FIRST) {
		// Extract first line's first 'length' characters.
		if (n-1 < length)
			return left(str, n - 1);
		else
			return left(str, length);
	}
	
	if (start_pos == LAST) {
		// Extract last line's last 'length' characters.
		// Reverse search for new line character.
		n = len(str);
		for(i = n; i >= 1; i = i - 1) {
			if (mid(str, i, 1) == NL) {
				if (n - i < length)
					return right(str, n - i);
				else
					return right(str, length);
			}
		}
	}

	return str;
}

// List of Reject Code & Reasons
string
get_reject_code_list(string _claim_type)
{
	string strList;

	strList = concatenate("||", LF);
	strList = concatenate(strList, rfill("|1|", 5, " "), TAB, "Bad/Unreadable image", LF);
	if(_claim_type != "RTP")
	{
		strList = concatenate(strList, rfill("|2|", 5, " "), TAB, "Claim form version invalid", LF);
		strList = concatenate(strList, rfill("|3|", 5, " "), TAB, "Scanned as incorrect claim/form type", LF);
	}
	
	strList = concatenate(strList, rfill("|4|", 5, " "), TAB, "Missing required claim data", LF);
	strList = concatenate(strList, rfill("|5|", 5, " "), TAB, "Must be valid calendar date", LF);
	strList = concatenate(strList, rfill("|6|", 5, " "), TAB, "Invalid date format", LF);	
	if(_claim_type != "RTP")
	{
		strList = concatenate(strList, rfill("|7|", 5, " "), TAB, "Date greater than 999 days", LF);
	}
	strList = concatenate(strList, rfill("|8|", 5, " "), TAB, "Future date not allowed", LF);
	
	if(_claim_type != "RTP")
	{
		strList = concatenate(strList, rfill("|9|", 5, " "), TAB, "Illegible Insureds/Recipient/Medical ID", LF);
	}
	
	if (left(_claim_type,3) == "MED") {
		
		strList = concatenate(strList, rfill("|10|", 5, " "), TAB, "Missing required detail information", LF);
		strList = concatenate(strList, rfill("|11|", 5, " "), TAB, "Too many detail lines for submitted claim type", LF);	
		strList = concatenate(strList, rfill("|12|", 5, " "), TAB, "Invalid amount (alpha/negative)", LF);	

		if(_claim_type == "MED-XO")
			strList = concatenate(strList, rfill("|13|", 5, " "), TAB, "No EOMB date", LF);

		//06/04/2020 - rsanchez60@dxc.com - addED for MED+MEDXO
		strList = concatenate(strList, rfill("|32|", 5, " "), TAB, "Required provider data missing/invalid", LF);
			
	}
	else if (left(_claim_type,4) == "OUTP" || left(_claim_type,3) == "INP") {
		 
		strList = concatenate(strList, rfill("|20|", 5, " "), TAB, "Too many detail lines for submitted claim type", LF);
		strList = concatenate(strList, rfill("|21|", 5, " "), TAB, "Missing total line revenue code 01, 001, 0001", LF);
		strList = concatenate(strList, rfill("|22|", 5, " "), TAB, "Invalid amount (alpha/negative)", LF);		
		//04/22/2020 - rsanchez60@dxc.com - added new reject reason
		strList = concatenate(strList, rfill("|23|", 5, " "), TAB, "Type of Bill is less than 3-digits/blank", LF);		
		strList = concatenate(strList, rfill("|24|", 5, " "), TAB, "Cannot be more than one MediCal payer on claim", LF);		
		
		if(left(_claim_type,4) == "OUTP")
		 {
			strList = concatenate(strList, rfill("|30|", 5, " "), TAB, "More than 1 total revenue code on claim", LF);
			strList = concatenate(strList, rfill("|31|", 5, " "), TAB, "Medi-Cal payer missing/invalid", LF);
			strList = concatenate(strList, rfill("|32|", 5, " "), TAB, "Required provider data missing/invalid", LF);
						
			
			if(_claim_type == "OUTP-XO")
			{
				strList = concatenate(strList, rfill("|33|", 5, " "), TAB, "Missing value code for crossover", LF);		
				//05/05/2020 - rsanchez60@dxc.com - added 'No valid detail lines billed' to Crossover
				strList = concatenate(strList, rfill("|35|", 5, " "), TAB, "No valid detail lines billed", LF);
			}
			else
			{
				strList = concatenate(strList, rfill("|34|", 5, " "), TAB, "Value code/amount invalid", LF);			
				strList = concatenate(strList, rfill("|35|", 5, " "), TAB, "No valid detail lines billed", LF);
				if(_claim_type == "OUTP-ADJ-VD" || _claim_type == "OUTP-A-ADJVD")
				{
					strList = concatenate(strList, rfill("|36|", 5, " "), TAB, "Missing av code", LF);
					strList = concatenate(strList, rfill("|37|", 5, " "), TAB, "Orig ccn invalid", LF);
					strList = concatenate(strList, rfill("|38|", 5, " "), TAB, "Missing reason code", LF);
				}
			}
		}
		else if(left(_claim_type,3) == "INP")
		{
			strList = concatenate(strList, rfill("|31|", 5, " "), TAB, "Medi-Cal payer missing/invalid", LF);
			if(_claim_type == "INP-ADJ-VD" || _claim_type == "INP-A-ADJVD")
			{
				strList = concatenate(strList, rfill("|36|", 5, " "), TAB, "Missing av code", LF);
				strList = concatenate(strList, rfill("|37|", 5, " "), TAB, "Orig ccn invalid", LF);
				strList = concatenate(strList, rfill("|38|", 5, " "), TAB, "Missing reason code", LF);
				//05/26/2020 - rsanchez60@dxc.com - 
				strList = concatenate(strList, rfill("|76|", 5, " "), TAB, "Invalid line number for form ADJ_VD", LF);
			}
		}
	}
	else if (left(_claim_type,3) == "LTC") {
		strList = concatenate(strList, rfill("|40|", 5, " "), TAB, "Missing required detail information", LF);
		strList = concatenate(strList, rfill("|41|", 5, " "), TAB, "Too many detail lines for submitted claim type", LF);
		strList = concatenate(strList, rfill("|42|", 5, " "), TAB, "Invalid Delete Box value", LF);
		//SS 02142020 - Added the reject reason
		strList = concatenate(strList, rfill("|43|", 5, " "), TAB, "No provider data", LF);
	}
	else if (_claim_type == "CIF-LTC" || _claim_type == "CIF-INP" ||
		 _claim_type == "CIF-REG" || _claim_type == "CIF-XO") {
		strList = concatenate(strList, rfill("|50|", 5, " "), TAB, "Document number not numeric", LF);
		strList = concatenate(strList, rfill("|51|", 5, " "), TAB, "Document number not 8 digits", LF);
		strList = concatenate(strList, rfill("|52|", 5, " "), TAB, "Document number blank", LF);
		strList = concatenate(strList, rfill("|53|", 5, " "), TAB, "No provider data", LF);
		strList = concatenate(strList, rfill("|54|", 5, " "), TAB, "Value is not X, Y or blank", LF);
		strList = concatenate(strList, rfill("|55|", 5, " "), TAB, "Claim control & line number invalid", LF);
		strList = concatenate(strList, rfill("|56|", 5, " "), TAB, "Too many detail lines", LF);
		strList = concatenate(strList, rfill("|57|", 5, " "), TAB, "No valid detail line", LF);
		//05/26/2020 - rsanchez60@dxc.com - 
		strList = concatenate(strList, rfill("|58|", 5, " "), TAB, "Missing Patient's Medical ID and CCN", LF);
	}
	else if (_claim_type == "APEL-REG" || _claim_type == "APEL-RESUB" || _claim_type == "APEL-NCCI") {
		strList = concatenate(strList, rfill("|60|", 5, " "), TAB, "Doc number must not be blank", LF);
		//05/05/2020 - rsanchez60@dxc.com - changed reject code '61' reason to 'Document Number not starting with F,T,S,G, or H or is not followed by 7 digits'
		strList = concatenate(strList, rfill("|61|", 5, " "), TAB, "Document Number not starting with F,T,S,G, or H or is not followed by 7 digits", LF);
		strList = concatenate(strList, rfill("|62|", 5, " "), TAB, "No provider data", LF);
	}
	else if (left(_claim_type,4) == "PHAR" || left(_claim_type,4) == "DRUG") {
		//06/02/2020 - rsanchez60@dxc.com - 
		strList = concatenate(strList, rfill("|32|", 5, " "), TAB, "Required provider data missing/invalid", LF);
		strList = concatenate(strList, rfill("|70|", 5, " "), TAB, "Missing required detail information", LF);
		strList = concatenate(strList, rfill("|71|", 5, " "), TAB, "Too many detail lines for submitted claim type", LF);
		strList = concatenate(strList, rfill("|72|", 5, " "), TAB, "Date must be 8 digits", LF);
		if(left(_claim_type,4) == "PHAR")
			strList = concatenate(strList, rfill("|73|", 5, " "), TAB, "Invalid delete box value", LF);
		strList = concatenate(strList, rfill("|74|", 5, " "), TAB, "Decimal not allowed", LF);
		
		if(_claim_type == "PHAR-ADJ-VD" || _claim_type == "DRUG-ADJ-VD" || _claim_type == "PHAR-A-ADJVD" || _claim_type == "DRUG-A-ADJVD")
		{
			strList = concatenate(strList, rfill("|75|", 5, " "), TAB, "Old ccn line required", LF);
			strList = concatenate(strList, rfill("|76|", 5, " "), TAB, "Invalid line number for form ADJ_VD", LF);
		}
		
		if(left(_claim_type,4) == "DRUG")
		{
			strList = concatenate(strList, rfill("|77|", 5, " "), TAB, "Details must be consecutive", LF);
			
			if(_claim_type == "DRUG-ADJ-VD" || _claim_type == "DRUG-A-ADJVD")
				strList = concatenate(strList, rfill("|78|", 5, " "), TAB, "Roll invalid for form ADJ_VD", LF);
		}
		
		if(left(_claim_type,4) == "PHAR")
			strList = concatenate(strList, rfill("|79|", 5, " "), TAB, "Invalid Fill Number given Product ID/NDC", LF);
			
	}
	else if (_claim_type == "ACF-SCAN" || _claim_type == "ACF-FAX") {
		strList = concatenate(strList, rfill("|80|", 5, " "), TAB, "Must have A C N", LF);
		strList = concatenate(strList, rfill("|81|", 5, " "), TAB, "Not original attachment control number", LF);
	}
	else if(_claim_type == "TAR3")
	{
		strList = concatenate(strList, rfill("|85|", 5, " "), TAB, "TAR -3 form not received as expected", LF);
		strList = concatenate(strList, rfill("|92|", 5, " "), TAB, "Missing Receipt Date", LF);
	}
	else if(_claim_type == "TAR" || _claim_type == "TAR_APPEAL")
	{
		strList = concatenate(strList, rfill("|90|", 5, " "), TAB, "Missing TCN", LF);
		strList = concatenate(strList, rfill("|91|", 5, " "), TAB, "Missing Medi-Cal ID", LF);
		strList = concatenate(strList, rfill("|92|", 5, " "), TAB, "Missing Receipt Date", LF);
		
		if(_claim_type == "TAR")
		{
			strList = concatenate(strList, rfill("|93|", 5, " "), TAB, "Missing DCN", LF);
			strList = concatenate(strList, rfill("|94|", 5, " "), TAB, "Appeal TAR in Reg TAR queue", LF);
			strList = concatenate(strList, rfill("|95|", 5, " "), TAB, "Missing NPI", LF);
		}
		else if(_claim_type == "TAR_APPEAL")
		{
			strList = concatenate(strList, rfill("|97|", 5, " "), TAB, "Missing Appeal Number", LF);
			strList = concatenate(strList, rfill("|98|", 5, " "), TAB, "Missing Rec Date", LF);
		}

	}						  
	else if(_claim_type == "RTP")
	{		
		strList = concatenate(strList, rfill("|44|", 5, " "), TAB, "Missing / Invalid RTP Document Type", LF);
		strList = concatenate(strList, rfill("|45|", 5, " "), TAB, "Missing / Invalid RTP Reason", LF);
		strList = concatenate(strList, rfill("|46|", 5, " "), TAB, "Missing Provider ID / NPI and Recipient ID", LF);
		strList = concatenate(strList, rfill("|47|", 5, " "), TAB, "Missing / Invalid DCN", LF);
		strList = concatenate(strList, rfill("|48|", 5, " "), TAB, "Date greater than 60 days", LF);
		strList = concatenate(strList, rfill("|49|", 5, " "), TAB, "Missing Return via Mail Date and Return via Fax Date", LF);
		strList = concatenate(strList, rfill("|72|", 5, " "), TAB, "Date must be 8 digits", LF);
		strList = concatenate(strList, rfill("|92|", 5, " "), TAB, "Missing Receipt Date", LF);
	}
	
	strList = concatenate(strList, rfill("|99|", 5, " "), TAB, "Other");

	return (strList);
}

boolean
is_valid_reject_code(string code, string _claim_type)
{
	string strList;

	if (trim(code) == "")
		return false;
	
	
	if(_claim_type != "RTP")
		strList = "1|2|3|4|5|6|7|8|9";
	else
		strList = "1|4|5|6|8";
		

	if (left(_claim_type,3) == "MED") {
		
		strList = concatenate(strList, "|10|11|12");
	

		if(_claim_type == "MED-XO")
			strList = concatenate(strList, "|13");

		//06/04/2020 - rsanchez60@dxc.com - 	
		strList = concatenate(strList, "|32");
			
	}
	else if (left(_claim_type,4) == "OUTP" || left(_claim_type,3) == "INP") {
		 
		strList = concatenate(strList, "|20|21|22|23|24");
		
		if(left(_claim_type,4) == "OUTP")
		 {
			strList = concatenate(strList, "|30|31|32");
						
			
			if(_claim_type == "OUTP-XO")
			{
				strList = concatenate(strList, "|33|35");
			}
			else
			{
				strList = concatenate(strList, "|34|35");
				if(_claim_type == "OUTP-ADJ-VD" || _claim_type == "OUTP-A-ADJVD")
				{
					strList = concatenate(strList, "|36|37|38");
				}
			}
		}
		else if(left(_claim_type,3) == "INP")
		{
			strList = concatenate(strList, "|31");
			if(_claim_type == "INP-ADJ-VD" || _claim_type == "INP-A-ADJVD")
			{
				//05/26/2020 - rsanchez60@dxc.com - added 76
				strList = concatenate(strList, "|36|37|38|76");
			}
		}
	}
	else if (left(_claim_type,3) == "LTC") {
		strList = concatenate(strList, "|40|41|42|43");
	}
	else if (_claim_type == "CIF-LTC" || _claim_type == "CIF-INP" ||
		 _claim_type == "CIF-REG" || _claim_type == "CIF-XO") {
		strList = concatenate(strList, "|50|51|52|53|54|55|56|57|58");
	}
	else if (_claim_type == "APEL-REG" || _claim_type == "APEL-RESUB" || _claim_type == "APEL-NCCI") {
		strList = concatenate(strList, "|60|61|62");
	}
	else if (left(_claim_type,4) == "PHAR" || left(_claim_type,4) == "DRUG") {
		//06/01/2020 - rsanchez60@dxc.com - added 32
		strList = concatenate(strList, "32|70|71|72");
		if(left(_claim_type,4) == "PHAR")
			strList = concatenate(strList, "|73");
		strList = concatenate(strList, "|74");
		
		if(_claim_type == "PHAR-ADJ-VD" || _claim_type == "DRUG-ADJ-VD" || _claim_type == "PHAR-A-ADJVD" || _claim_type == "DRUG-A-ADJVD")
		{
			strList = concatenate(strList, "|75|76");
		}
		
		if(left(_claim_type,4) == "DRUG")
		{
			strList = concatenate(strList, "|77");
			
			if(_claim_type == "DRUG-ADJ-VD" || _claim_type == "DRUG-A-ADJVD")
				strList = concatenate(strList, "|78");
		}
		
		if(left(_claim_type,4) == "PHAR")
			strList = concatenate(strList, "|79");
	}
	else if (_claim_type == "ACF-SCAN" || _claim_type == "ACF-FAX") {
		strList = concatenate(strList, "|80|81");
	}
	else if(_claim_type == "TAR3")
	{
		strList = concatenate(strList, "|85|92");
	}
	else if(_claim_type == "TAR" || _claim_type == "TAR_APPEAL")
	{
		strList = concatenate(strList, "|90|91|92");
			
		if(_claim_type == "TAR")
			strList = concatenate(strList, "|93|94|95");
		else if(_claim_type == "TAR_APPEAL")
			strList = concatenate(strList, "|97|98");
	}																																									   
	else if(_claim_type == "RTP")
		strList = concatenate(strList, "|44|45|46|47|48|49|72|92");
		
	strList = concatenate(strList, "|99");
	
	//return match(code, "1|2|3|4|5|6|7|10|11|12|13|20|21|22|30|31|32|33|34|35|36|37|38|40|41|42|43|50|51|52|53|54|55|56|57|60|61|62|70|71|72|73|74|75|76|77|78|80|81|85|99");
	return match(code, strList);
}

//Convert alphas to digits
string
convert_to_numeric(string in_str)
{
	in_str = substitute(in_str, "O", "0");
	in_str = substitute(in_str, "D", "0");
	in_str = substitute(in_str, "L", "1");
	in_str = substitute(in_str, "I", "1");
	in_str = substitute(in_str, "Z", "2");
	in_str = substitute(in_str, "K", "3");
	in_str = substitute(in_str, "A", "4");
	in_str = substitute(in_str, "S", "5");
	in_str = substitute(in_str, "G", "6");
	in_str = substitute(in_str, "T", "7");
	in_str = substitute(in_str, "B", "8");
	in_str = substitute(in_str, "Y", "9");
	return in_str;
}

//Convert digits to alphas
string
convert_to_alpha(string in_str)
{
	in_str = substitute(in_str, "0", "O");
	in_str = substitute(in_str, "1", "L");
	in_str = substitute(in_str, "2", "Z");
	in_str = substitute(in_str, "3", "Z");
	in_str = substitute(in_str, "4", "A");
	in_str = substitute(in_str, "5", "S");
	in_str = substitute(in_str, "6", "G");
	in_str = substitute(in_str, "7", "T");
	in_str = substitute(in_str, "8", "B");
	in_str = substitute(in_str, "9", "Y");
	return in_str;
}

boolean validateDateFormat2(string _date, number length)
{
	string _mm, _dd, _yy, _yyyy;

	if (len(_date) == 6 || len(_date) == 8)
	{
		if(length != 0 && len(_date) != length)
			return false;
		
		_date = trim(_date);
		if (_date == "") return false;
		
		_mm = left(_date, 2);
		
		if (!match(_mm, "0[1-9]|1[0-2]"))
			return false;
			
			
		_dd = mid(_date, 3, 2);
		
		if (!match(_dd, "0[1-9]|1[0-9]|2[0-9]|3[0-1]"))
			return false;	

		return true;
	}
	else
		return false;
}

boolean
isFutureDate(string _date)
{
	string _mm, _dd, _yy, _yyyy;

	_date = trim(_date);
	if (_date == "") return false;
	
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

	return (date(concatenate(_mm, _dd,_yyyy)) > today());
}

// This function is used in KFI_VERIFY to compare two keying values.
boolean  verify_history(number n, string history, string value)
{
	boolean bMatch;

	bMatch = (history == value) ? true : false;

	if (! bMatch) {
		bMatch = ((value == format(date(value), "mmddyyyy")) || (value == format(date(value), "mmddyy"))) ? true : false;
		if (bMatch)
			bMatch = ((history == format(date(value), "mmddyyyy")) || (history == format(date(value), "mmddyy"))) ? true : false;
	}

	return(bMatch);
}

void scrub_date(string &strDate)
{
	
	//10/12/2017 - rsanchez - remove 1's OCR'ed instead of '/' e.g. mm/dd/yyyy OCR'ed as mm1dd1yyyy, mm/dd1yyyy or mm1dd/yyyy
	string RE_extra_1s = "(([[:digit:]]{2})[1]([[:digit:]]{2})[1]([[:digit:]]{4}))";
	RE_extra_1s = concatenate(RE_extra_1s, "|(([[:digit:]]{2})[/]([[:digit:]]{2})[1]([[:digit:]]{4}))");
	RE_extra_1s = concatenate(RE_extra_1s, "|(([[:digit:]]{2})[1]([[:digit:]]{2})[/]([[:digit:]]{4}))");
	if (match(strDate, RE_extra_1s)) {
		strDate = substitute(strDate, "([[:digit:]]{2})[/1]([[:digit:]]{2})[/1]([[:digit:]]{4})", "\\1\\2\\3");
		inspect_always(strDate);
	}
	
	//convert 1's OCR'ed as / back to 1's on 6 digit dates
	if (len(strDate) == 6 && match(strDate, ".*[/].*"))
		strDate = substitute(strDate, "[/]", "1");
		
	constrain(strDate, alphabet_digit);
	if (len(strDate) > 8) {
		strDate = left(strDate, 8);
		inspect_always(strDate);
	}
	set(strDate, "MAX_CHARS", 8);
}

void
scrub_size(string &fvalue, number size)
{
	if (len(fvalue) > size)
		fvalue = left(fvalue, size);
	set(fvalue, "MAX_CHARS", size);
}

//S.Shah 10/02/2017 - Added to remove the value after the decimal point. Ex. Input: NN.NN  Output: NN
void
scrub_unit(string &fvalue)
{
	string RE_decimal_val = "([\-]?[\.\,[:digit:]]*)[\.\,][[:digit:]]{0,2}";
	
	//Remove the value after the decimal points.
	if (match(fvalue, RE_decimal_val))
		fvalue = substitute(fvalue, RE_decimal_val, "\\1");
}

boolean
valid_year(number yyyy)
{
  boolean ok = true;
  number curr_year = year(today());

  if ( (yyyy > curr_year)
    || (yyyy < 1950) )
    ok = false;

  return ok;
}

//
// Parse ImageAddress string:
// Extract the first part to third part of original ImageAddress string.
// 	Original string: "010104.      3456.      001.       002"
//	Output string:   "0101043456001"
string
ParseImageAddress (string fullStr)
{
  string record;
  string str1;
  string str3;
  string out1;
  string out2;
  string out3;
  number pos1, pos2, pos3;

  record = substitute(fullStr, " ", "");		// remove spaces
  pos1 = find(record, ".");
  pos2 = find(record, ".", pos1+1);
  pos3 = find(record, ".", pos2+1);

  out1 = left(record, pos1-1);
  out2 = mid(record, pos1+1, pos2-pos1-1);	// NOT including the "."
  out3 = mid(record, pos2+1, pos3-pos2-1);
  record = concatenate(out1, out2, out3);
  return (record);
}

//08/04/2020 - rsanchez60@dxc.com - Add:
//	Last, First, M
//	Last, First, Middle 
//07/14/2020 - rsanchez60@dxc.com - comma is sometimes OCR'ed as period; account for period in name parsing
//Parse and extract the full name in the following formats:
// (Expected: last name always printed first)
// 1.
//	AAA, BBB, C    -->> Last: AAA,			First: BBB,		Middle: C
//	AAA, BBB, CCC  -->> Last: AAA,			First: BBB,		Middle: C
// 2.
//	AAA, BBB       -->> Last: AAA,			First: BBB,		Middle: 
//	AAA, BBB CCC   -->> Last: AAA,			First: BBB CCC,	Middle: 
//	AAA, BBB C     -->> Last: AAA,			First: BBB C,	Middle: 
//	AAA, BBB C.    -->> Last: AAA,			First: BBB C,	Middle: 
// 3.
//	AAA AAA, BBB C    -->> Last: AAA,		First: BBB C,	Middle: 
//	AAA C. BBB     -->> Last: AAA C,		First: BBB,		Middle: 
// Defaults - leave in Last:
//	AAA BBB C      -->> Last: AAA BBB C,	First: ,		Middle: 
//	AAA BBB        -->> Last: AAA BBB,		First: ,		Middle: 
//	AAA C BBB      -->> Last: AAA C BBB,	First: ,		Middle: 

void
parse_name(string fullname, string &first, string &middle, string &last)
{

	string RE_FULLNAME1 = "([[:alnum:]]+)[,]?[[:space:]]([[:alnum:]]+)[,]?[[:space:]]([[:alnum:]]+)$";
	string RE_FULLNAME2 = "([[:alnum:]]+)[,]?[[:space:]](.+)$";
	string RE_FULLNAME3 = "([[:alnum:]]+[[:space:]][[:alnum:]]+)[,]?[[:space:]](.+)$";

	fullname = trim(fullname);
	//replace multiple spaces with a single space
	fullname = substitute(fullname, "[[:space:]]+", " ");
	//replace periods with commas
	fullname = substitute(fullname, "[.]", ",");
	//remove non- comma, space, or alnum characters
	fullname = substitute(fullname, "[^,[:space:][:alnum:]]", "");
	
	if (match(fullname, RE_FULLNAME1)) {
		//	AAA, BBB, C    -->> Last: AAA,			First: BBB,		Middle: C
		//	AAA, BBB, CCC  -->> Last: AAA,			First: BBB,		Middle: C
		last = trim(substitute(fullname, RE_FULLNAME1, "\\1"));
		first = trim(substitute(fullname, RE_FULLNAME1, "\\2"));
		middle = trim(substitute(fullname, RE_FULLNAME1, "\\3"));
	} else if (match(fullname, RE_FULLNAME2)) {
		//	AAA, BBB       -->> Last: AAA,			First: BBB,		Middle: 
		//	AAA, BBB CCC   -->> Last: AAA,			First: BBB CCC,	Middle: 
		//	AAA, BBB C     -->> Last: AAA,			First: BBB C,	Middle: 
		//	AAA, BBB C.    -->> Last: AAA,			First: BBB C,	Middle: 
		last = trim(substitute(fullname, RE_FULLNAME2, "\\1"));
		first = trim(substitute(fullname, RE_FULLNAME2, "\\2"));
		middle = "";
	} else if (match(fullname, RE_FULLNAME3)) {
		//	AAA AAA, BBB C -->> Last: AAA AAA,		First: BBB C,	Middle: 
		//	AAA C. BBB     -->> Last: AAA C,		First: BBB,		Middle:
		last = trim(substitute(fullname, RE_FULLNAME3, "\\1"));
		first = trim(substitute(fullname, RE_FULLNAME3, "\\2"));
		middle = "";
	}
}

//Provider Name (ignore line)
//Provider Street Address 1
//Provider Street Address 2 (optional)
//City, State Zip 
//parse the multi-line address to:
//address line 1
//address line 2
//city, ST 99999-9999
void
parse_address(string &address_line1, string &address_line2, string &city, string &state, string &zip)
{
	string multi_line, last_line;
	
	//regular exp to get the last line in multi-line field
	string RE_parse_line = concatenate("([^", LF, "]*[", LF, "])?([^", LF, "]*[", LF, "])?([^", LF, "]*[", LF, "])?([^", LF, "]*)");
	string RE_line_1 = "\\1";
	string RE_line_2 = "\\2";
	string RE_line_3 = "\\3";
	string RE_last_line = "\\4";
	
	//regular exp to parse format: City, SS, ZZZZZ-ZZZZ
	string RE_city_state_zip_line = "([[:alnum:][:space:]]{2,30})[[:punct:][:space:]]+([[:alnum:]]{2})[[:space:][:punct:]]+([[:alnum:]]{5}([[:space:][:punct:]])*[[:alnum:]]{0,4})";
	string RE_city = "\\1";
	string RE_state = "\\2";
	string RE_zip = "\\3";	
	
	multi_line = upper(trim(address_line1));
	
	//if last line contains phone numbers or provider ids, REMOVE
	last_line = trim(substitute(multi_line, RE_parse_line, RE_last_line));
	if (match(last_line, "[[:digit:][:punct:][:space:]]+")) {
		multi_line = trim(left(multi_line, len(multi_line)-len(last_line)));
	}

	//ignore line 1; instead, assign line 2 to address_line1 and line 3 to address_line2
	//address_line1 = trim(substitute(multi_line, RE_parse_line, RE_line_1));
	//address_line2 = trim(substitute(multi_line, RE_parse_line, RE_line_2));
	address_line1 = trim(substitute(multi_line, RE_parse_line, RE_line_2));
	address_line2 = trim(substitute(multi_line, RE_parse_line, RE_line_3));
	//address_line3 = trim(substitute(multi_line, RE_parse_line, RE_line_3));	//line 3 may be empty
	last_line = trim(substitute(multi_line, RE_parse_line, RE_last_line));
	
	//city, state zip parsing
	if (match(last_line, RE_city_state_zip_line)) {
		city = substitute(last_line, RE_city_state_zip_line, RE_city);
		state = substitute(last_line, RE_city_state_zip_line, RE_state);
		zip = substitute(last_line, RE_city_state_zip_line, RE_zip);
	//} else if (address_line3 != "" && match(address_line3, RE_city_state_zip_line)) {
	} else if (address_line2 != "" && match(address_line2, RE_city_state_zip_line)) {
		city = substitute(address_line2, RE_city_state_zip_line, RE_city);
		state = substitute(address_line2, RE_city_state_zip_line, RE_state);
		zip = substitute(address_line2, RE_city_state_zip_line, RE_zip);
		address_line2 = "";
	}
	
	fixup_digits_to_alphas(city);
	fixup_digits_to_alphas(state);
	fixup_alphas_to_digits(zip);	
	
	constrain(state, alphabet_alpha);
	constrain(zip, alphabet_digit);	
	
	inspect_always(address_line1);
	inspect_always(address_line2);
	inspect_always(city);
	inspect_always(state);
	inspect_always(zip);
}

//Validate if length equals 4 or 6 positions:
//Positions 1-2 equal 00-23, Positions 3-4 equal 00-59, Positions 5-6 equal 00-59
boolean validate_time(string t)
{
	boolean ok = false;
	string hh,mm,ss;
	
	if (len(t) == 6){
		hh = left(t,2);
		mm = mid(t,3,2);
		ss = right(t,2);
		ok = (number(hh) >= 0 && number(hh) <= 23) &&
			(number(mm) >= 0 && number(mm) <= 59) &&
			(number(ss) >= 0 && number(ss) <= 59);
	} else if (len(t) == 4){
		hh = left(t,2);
		mm = right(t,2);
		ok = number(hh) >= 0 && number(hh) <= 23 &&
			number(mm) >= 0 && number(mm) <= 59;
	}
	return ok;
}

//New CAMMIS functions
boolean validate_Insured_ID(string id)
{
	boolean ok = true;
	number total = 0;
	
	error_message = "";
	id = trim(id);
	
	// Must not be blank
	ok = id != "";
	if (!ok) error_message = "Must not be blank.";
	
	// Must be 9,10,14 or 15 characters
	if (ok) {
		ok = match(id, "[[:alnum:]]{9,10}|[[:alnum:]]{14,15}");
		if (!ok)
			error_message = "Must be 9, 10, 14 or 15 characters.";
	}

	// If 9 characters the last character is not a 0 (zero) or O (alpha oh)
	//if (ok && len(id) == 9) {
	//	ok = !match(right(id), "0|O");
	//	if (!ok)
	//		error_message = "9 characters ID cannot end with a 0 (zero) or O (alpha oh).";
	//}
	
	// First 8 digits should be numeric
	// If populated value is 9 characters and First 8 digits are numeric (0-9) and The 9th char is one of these char: ACDEFGHIMNSTUVWXYZ  validate
	if (ok && len(id) == 9) {
		ok = match(id, "[[:digit:]]{8}[ACDEFGHIMNSTUVWXYZ]");
		if (!ok)
			error_message = "9 characters ID format must be 8 digits followed by one of: ACDEFGHIMNSTUVWXYZ.";
	}

	// "Perform checkdigit routine  if populated value is 10 or 15 characters. 
    // If 10 characters convert even positions by 0 -> 0 (1 - 9) -> (9 - 1) take the sum of the first 9(converted) digits MOD 10.
	//This should equal the 10th digit.  Alpha characters equate to 0.
	if (ok && len(id) == 10) {
		ok = meds_verify_id(id);
		if (!ok)
			error_message = "Must satisfy checkdigit, verify Insured ID.";
	}
	
    // If 15 chars convert the even position digits by (0 - 9) -> (0246813579)  then take the sum of the first 14 (converted) digits MOD 10.  This should equal the 15th digit"
	if (ok && len(id) == 15) {
		ok = bid_verify_id(id);
		if (!ok)
			error_message = "Invalid 15 chars ID, must satisfy checkdigit.";
	}
	
	// "If 14 chars must satisfy BIC Algorithm
	// Perform BIC Algorithm if populated value is 14 characters. 
	// If valid validate Insured ID if not  flag
		// 5a. The first digit must be 9.
		// 5b. The 9th char must be one of these char: ACDEFGHIMNSTUVWXYZ
		// 5c. The 10th digit is the check digit.
		// 5d. The last 4 digits must be numerics
		// 5e. The 11th digit must be numeric
		// 5f. The last 3 digits must be between 1-366."
		//format:9XXXXXXXAc9999
	if (ok && len(id) == 14) {
		ok = bic_verify_id(id);
		if (!ok)
			error_message = "Invalid 14 chars ID format for BIC Algorithm.";
	}
	
	return ok;
}

//08/04/2020 - rsanchez60@dxc.com -
//"The rule for this value states 'single character 4-9 or 00000000004 or 00000000008, but the edit is allowing for 00000000004 thru 00000000009, which is wrong.
//Please update the rule to only allow for 00000000004 and 00000000008 for this rule."
boolean validate_Prior_Auth(string value)
{
	boolean ok = true;

	error_message = "";
	value = trim(value);
	
	// "1. If entered value is single digit but does not equal to 4 - 9 ,alert user
	ok = match(value, "[4-9]");
	
	//08/04/2020 - rsanchez60@dxc.com - 00000000004 or 00000000008
	// "2. If entered value is 11 digits and first 10 digits are not ""0""s and last digit does not equal to 4 - 9 alert user
	if (!ok)
		ok = match(value, "0{10}[48]");
		
	// "3.   If entered value is 10 characters , but does not start with a digit from 1 - 8 , alert user
	if (!ok)
		ok = match(value, "[1-8][[:alnum:]]{9}");
	
	// "4.  If entered value is 6 characters but does not start with an alpha character and /or end with a ""4"" alert user
	if (!ok)
		ok = match(value, "[[:alpha:]][[:alnum:]]{4}4");
	
	// alert user ""Prior Authorization must be either 
	// a single digit from 4 - 9, or ""00000000004"", or
	// 10 characters starting  with a digit from 1 - 8, or
	// 6 characters starting with an alpha character and ending with a ""4"""""
	if (!ok) {
		error_message =	concatenate("Value must be either:", CR, LF);
		error_message =	concatenate(error_message, "a single digit from 4 - 9, or", CR, LF);
		error_message =	concatenate(error_message, "'00000000004' or '00000000008', or", CR, LF);
		error_message =	concatenate(error_message, "10 characters starting  with a digit from 1 - 8, or", CR, LF);
		error_message =	concatenate(error_message, "6 characters starting with an alpha character and ending with a '4'.");
	}
	return ok;
}

boolean validate_UPN(string value)
{

	boolean ok = true;
	error_message = "";
	
	// If blank, leave blank
	value = trim(value);
	
	if (value == "")
		return true;
	
	// 2. If first two characters are HI and (Position 3 thru end of string  does not equal to 6-18 alphanumerics and/or  value is not found on  UPN table ), alert user 
	ok = match(value, "HI[[:alnum:]]{6,18}");
	
	// 3. If first two characters are N4 and (Position 3 thru end of string does not equal to 11 numbers and/or value is not found on  UPN table or DRUG table) , alert user 
	if (!ok)
		ok = match(value, "N4[[:digit:]]{11}");
	
	// 4. If first two characters are UK and (Position 3 thru end of string does not equal to 14 numbers and/or value is not found on  UPN table ), alert user 
	if (!ok)
		ok = match(value, "UK[[:digit:]]{14}");
	
	// 5. If first two characters are UP and (Position 3 thru end of string does not equal to 12 numbers and/or value is not found on  UPN table ), alert user
	if (!ok)
		ok = match(value, "UP[[:digit:]]{12}");
	
	// 6. If first two characters are EN and (Position 3 thru end of string does not equal to 13 numbers and/or value is not found on  UPN table ), alert user 
	if (!ok)
		ok = match(value, "EN[[:digit:]]{13}");
	
	// 7. If first two characters are EO and (Position 3 thru end of string does not equal to 8 numbers and/or value is not found on  UPN table ), alert user "
	if (!ok)
		ok = match(value, "EO[[:digit:]]{8}");
	
	// 8. If first two characters are ON and (Position 3 thru end of string does not equal to 1-19 alphanumerics and/or value is not found on  UPN table ),alert user 
	if (!ok)
		ok = match(value, "ON[[:alnum:]]{1,19}");
	
	if (!ok) {
		error_message = concatenate("Invalid format. Valid formats are:", CR, LF);
		error_message = concatenate(error_message, "HI followed by 6-18 alphanumeric characters", CR, LF);
		error_message = concatenate(error_message, "N4 followed by 11 digits", CR, LF);
		error_message = concatenate(error_message, "UK followed by 14 digits", CR, LF);
		error_message = concatenate(error_message, "UP followed by 12 digits", CR, LF);
		error_message = concatenate(error_message, "EN followed by 13 digits", CR, LF);
		error_message = concatenate(error_message, "EO followed by 8 digits", CR, LF);
		error_message = concatenate(error_message, "ON followed by 1-19 alphanumeric characters");
	}
	
	if (ok) {
		//remove the qualifier before querying
		ok = is_valid_UPN(left(value, len(value)-2));
		if (!ok)
			error_message = "Code not found in UPN table.";
		if (!ok && match(value, "N4[[:digit:]]{11}")) {
			//remove the qualifier before querying
			ok = is_valid_DRUG(left(value, len(value)-2));
			if (!ok)
				error_message = "Code not found in UPN and DRUG tables.";
		}
	}
	return ok;
}

boolean validate_UPN_quantity(string value)
{
	boolean ok = true;
	error_message = "";
	
	value = trim(value);
	//If blank, leave blank
	if (value == "")
		return true;
	
	// Max of 12 characters alphanumeric.
	ok = match(value, "[[:alnum:]]{0,12}");
	if (!ok) error_message = "Must be 12 or less alphanumeric characters.";
	
	// First 2 characters should be UN, F2, GR or ML
	if (ok) {
		ok = match(left(value,2), "UN|F2|GR|ML");
		if (!ok) error_message = "First 2 characters must be UN, F2, GR or ML.";
	}
	// If first 2 characters UN,F2,GR or ML then remaining should be numeric
	if (ok) {
		ok = match(value, "(UN|F2|GR|ML)[[:digit:]]{10}");
		if (!ok) error_message = "First 2 characters are UN, F2, GR or ML and remaining must be 10 digits.";
	}
	
	return ok;
}

//convert from a past julian date in format YJJJ
string convert_date_from_YJJJ(string julian)
{
	string mmddyy, base_date, curr_yy, curr_y;
	number y, yy, jjj, curr_decade;
	
	if (match(julian, "[[:digit:]]{4}")) {
		curr_yy = format(today(), "yy");
		curr_y = right(curr_yy);
		curr_decade = number(curr_yy) - number(curr_y);
		y = number(left(julian));
		jjj = number(right(julian,3));
		
		if (y <= number(curr_y))
			yy = curr_decade + y;
		else
			//last decade + y
			yy = curr_decade - 10 + y;
		
		base_date = concatenate("010120", string(yy));
		mmddyy = format(date(base_date) + jjj - 1, "mmddyy");

		//The julian date is invalid
		if(string(yy) != right(mmddyy,2))
			mmddyy = "000000";
	} else
		mmddyy = "000000";
	
	return mmddyy;
}

boolean meds_verify_id(string id)
{
	string newid = "";

	//first verify that this is 10 characters id
	if(len(id) != 10)
		return false;

	// "If 10 chars must satisfy BIC Algorithm
	// Perform MED ID Algorithm if populated value is 10 characters. 
	// 5a. if not numeric, convert first 9 characters by replacing alpha characters with zero 0.
	// 5b. The 10th digit is the check digit.
	// 5c. Perform check digit verification on first 9 digits and verify against 10th digit

	//substitute any non-numeric characters of first 9-characters to 0 (zero)
	newid = substitute(left(id, 9), "[ACDEFGHIMNSTUVWXYZ]", "0");
	//append 10th character from original id as a check digit to verify 
	newid = concatenate(newid, mid(id, 10, 1));
	//now verify check digit
	if(!verify_cammis_check_digit(newid))
		return false;
	
	return true;
}

boolean bic_verify_id(string id)
{
	string newid = "";

	//first verify that this is 14 characters id
	if(len(id) != 14)
		return false;

	// "If 14 chars must satisfy BIC Algorithm
	// Perform BIC Algorithm if populated value is 14 characters. 
	// 5a. if not numeric, convert first 9 characters by replacing alpha characters with zero 0.
	// 5b. The 9th char must be one of these char: ACDEFGHIMNSTUVWXYZ
	// 5c. The 10th digit is the check digit.
	// 5d. Perform check digit verification on first 9 digits and verify against 10th digit
	// 5e. The 11th digit must be numeric
	// 5f. The last 3 digits must be between 1-366."

	//04/30/2020 - rsanchez60@dxc.com - validate 5b. The 9th char must be one of these char: ACDEFGHIMNSTUVWXYZ
	if (!match(mid(id, 9, 1), "[ACDEFGHIMNSTUVWXYZ]"))
		return false;

	//substitute any non-numeric characters of first 9-characters to 0 (zero)
	newid = substitute(left(id, 9), "[ACDEFGHIMNSTUVWXYZ]", "0");
	//append 10th character from original id as a check digit to verify 
	newid = concatenate(newid, mid(id, 10, 1));
	//now verify check digit
	if(!verify_cammis_check_digit(newid))
		return false;

	//validate 11th position is numeric (0-9)
	if(!match(mid(id, 11, 1), "[[:digit:]]"))
		return false;
	//validate last 3 digits to be between 1 to 366
	if(!(number(right(id,3)) >= 1 && number(right(id,3)) <= 366))
		return false;
	
	return true;
}

boolean verify_cammis_check_digit(string id)
{
	number nOddPosSum=0, nEvenPosSum=0, i, sum=0;

	//add up odd position digits
	for(i=1; i<len(id); i=i+2)
		nOddPosSum = nOddPosSum + (number)mid(id, i, 1);

	//add up even position digits after conversion
	for(i=2; i<len(id); i=i+2)
		nEvenPosSum = nEvenPosSum + ((number)mid(id, i, 1) == 0 ? 0 : (10-(number)mid(id, i, 1)));

	//add sum of odd positioned digits and sum of weighted even positioned digits 
	sum = nOddPosSum + nEvenPosSum;
	return ((number)right(id, 1) == (sum%10));
}

boolean bid_verify_id(string id)
{
	string conversion15 = "0246813579";
	number i;
	number total = 0;
	number sumOddPos=0, sumEvenPos=0;
	string newid = "";

	//first verify teh id is 15 characters long
	if(len(id) != 15) 
		return false;

	//substitute any non-numeric characters of first 14-characters to 0 (zero)
	newid = substitute(left(id, 14), "[ACDEFGHIMNSTUVWXYZ]", "0");

    //add up odd position digits
	for(i=1; i<=14; i=i+2)
		sumOddPos = sumOddPos + (number)mid(newid, i, 1);

	//now add up even position digits after conversion
	for(i=2; i<=14; i=i+2)
		sumEvenPos = sumEvenPos + (number)mid(conversion15, (number)mid(newid, i, 1)+1, 1);

	//add both sums
	total = sumOddPos + sumEvenPos;

	if((number)right(id, 1) != (total%10))
		return false;

	return true;
}

boolean IsFieldReadWrite(string strFieldName, string &strDoc, number nFormNo)
{
	number nValue;

	boolean bStatus = get_attribute(strDoc, nFormNo, strFieldName, "READ_ONLY", nValue);

	if (! bStatus) {
		strErrMsg = concatenate("get_attribute(", strDoc, strCOMMA, string(nFormNo), strCOMMA, strFieldName, strCOMMA, "READ_ONLY, ...) failed within IsFieldReadWrite(...) iSL function!");
		LogErrMsg(EventLog_Handle, strErrMsg, true);
	}

	return (nValue == 0);	//0 = READ+WRITE
}

boolean IsFieldReadWrite(string &strDoc, number nFormNo, string &strField)
{
	return(IsFieldReadWrite(name(strField), strDoc, nFormNo));
}

boolean validateEntityName(string &strEntityName, string strRuleNo, string strDocName, string &strErrMsg, number strlen)
{
	boolean bStatus;

	bStatus = (trim(strEntityName) != "") ? true : false;
	if (bStatus) {
		bStatus = (len(strEntityName) < strlen) ? true : false;
		if (bStatus) {

			string WHITE_SPACE0_RX = "[ ]*";
			string WHITE_SPACE1_RX = "[ ]+";
			string WORD_RX = concatenate("[", alphabet_alpha, "]+");
			string strEntityNameRegX = concatenate(WORD_RX, "(", WHITE_SPACE1_RX, WORD_RX, ")", "*");

			bStatus = match(strEntityName, strEntityNameRegX) ? true : false;
			if (! bStatus)
				strErrMsg = concatenate("Invalid \"", display(strEntityName), "\" value! Rule ", strDocName, " ", strRuleNo, ".3");
		}
		else
			strErrMsg = concatenate("\"", display(strEntityName), "\" value must be between 1 and 32 characters! Rule ", strDocName, " ", strRuleNo, ".2"); 
	}
	else
		strErrMsg = concatenate("\"", display(strEntityName), "\" cannot be blank. Rule ", strDocName, " ", strRuleNo, ".1");

	return(bStatus);
}

string getClaimType(string _claim_type)
{
	if(right(_claim_type,5) == "RESUB" && _claim_type != "APEL-RESUB")
		return "RESUB_ADJ";
	else if(right(_claim_type,6) == "ADJ-VD")
		return "RESUB_ADJ";
	else if(right(_claim_type,3) == "OOY")
		return "OOY";
	else if(right(_claim_type,4) == "SPBU")
		return "SPBU";
	else if (_claim_type == "APEL-RESUB" || right(_claim_type,5) == "A-RES" || right(_claim_type,7) == "A-ADJVD")
		return "APEL-RESUB";
	else if(_claim_type == "INP-REG" || _claim_type == "INP-ATCH")
		return "INP";
	
	return _claim_type;
}

// 03252020 - e. wong
// Convert date format from YYJJJ to MMDDYYYY
string JulianToMMDDYYYY(string _YYJJJ)
{
	string mmddyyyy = "";
	string YYYY, JJJ;
	string newdate;
	date date1;

	YYYY = concatenate("20", left(_YYJJJ,2));
	JJJ = right(_YYJJJ,3);

	newdate = concatenate("1/1/", YYYY);
	date1 = date(newdate) + number(JJJ) - 1;

	mmddyyyy = format(date1, "mmddyyyy");
	return mmddyyyy;
}

