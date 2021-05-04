//	+-----------------------------------------------+
//	|  Worldwide Copyright (c) (2002 -  2019)		|
//	|  Impression Technology			|
//	|						|
//	| Sales:   sales@impression-technology.com	|
//	| Support: support@impression-technology.com	|
//	+-----------------------------------------------+

//
//   \\V-CAMMIS-IMG\FormDB\runtime.isl

//
string ENVIRONMENT;

// Database connection handle
opaque DB_Handle;
boolean DB_Connected = false;

//Export output path for idx, cnt, xml, zip files
string IMAGE_SERVER = "OCRIMGPRDMED001";
string EXPORT_OUTPUT_PATH;
string EXPORT_INDEX_PATH;			// Misc. forms index file output folder
string EXPORT_CSV_PATH;				// Form path for summary .csv file
string EXPORT_RTP_CSV_PATH;         // Form path for RTP summary.csv file
string EXPORT_INDEX_IMAGE_PATH;		// MIsc. forms multi-page TIFF file output folder
string EXPORT_TAR3_PATH;            // Export path for TAR3 .tif and .DAC files.
//01/21/2020 - rsanchez60@dxc.com - add new CORR output path
string EXPORT_CORR_PATH;

//Oracle Connection
string Oracle_DBName = "V_KTAR_INFO";
string Oracle_DSN = "TARQuery";
string Oracle_UserId = "DXC_ICAPAPPL_USER_SAC";
string Oracle_Password = "surgeuser01";
opaque Oracle_Handle;
boolean Oracle_Connected = false;

// Database connection parameters
string DB_DSN = "CAMMIS";
string DB_UserId = "sa";
string DB_Password = "sa";
// Statistics database connection variables
opaque iStatistics_DB_Handle;
boolean iStatistics_DB_Connected = false;
string iStatistics_DB_DSN = "CA_iStatistics";
string iStatistics_DB_UserId = "sa";
string iStatistics_DB_Password = "sa";
string iStatistics_DB_Name = "CA_iStatistics";
string STORED_PROC_UPDATE_CLAIM_STAT = "sp_update_claim_statistics";  //no sp exist even in DE, not used
string STORED_PROC_INSERT_CLAIM_STAT = "sp_insert_claim_statistics";

string STORED_PROC_INSERT_BATCH_STAT = "sp_insert_batch_statistics";
string STORED_PROC_UPDATE_BATCH_STAT = "sp_update_batch_statistics";
string STORED_PROC_UPDATE_BATCH_STAT_NUM_DOCS = "sp_update_batch_statistics_Num_Docs";
string STORED_PROC_GetNextCCN = "GetNextCCN";
string STORED_PROC_SaveLastCCN = "SaveLastCCN";

number MaxBatchSize = 999;

string Table_RejectCode = "RejectCode";  
string Column_Reject_Code = "Reject_Code";
string Column_Reject_Reason = "Reject_Reason";

//Custom lookup database & tables
string DB_Name = "CAMMIS";

string TABLE_RECIPIENT = "recipient"; 
string COL_RECIPIENT_ID = "recipient_id";
string COL_RECIPIENT_LNAME = "recipient_lname";
string COL_RECIPIENT_FNAME = "recipient_fname";

string TABLE_PROVIDER = "provider_type";
string COL_PROVIDER_ID = "provider_id";
string COL_PROVIDER_TYPE = "provider_type";
string COL_PROVIDER_TAXONOMY = "provider_taxonomy";


string TABLE_DIAG = "diag";
string COL_DIAG_CODE = "diag_code";

string TABLE_DIAG9 = "diag9";
string COL_DIAG_CODE9 = "diag_code";

string TABLE_DIAG10 = "diag10";
string COL_DIAG_CODE10 = "diag_code";

string TABLE_TAXONOMY = "taxonomy";
string COL_TAXONOMY_ID = "taxonomy_id";

string TABLE_NDC = "ndc";
string COL_NDC = "ndc";

string TABLE_REVENUE = "revenue";  
string COL_REVENUE_CODE = "revenue_code";

string TABLE_PROC_CODE  = "proc_code";
string COL_PROC_CODE = "proc_code";

string TABLE_QUADRANT_PROC_CODE  = "quadrant_proc_code";
string COL_QUADRANT_PROC_CODE = "quadrant_proc_code";

string TABLE_PROC_ICD9 = "icd_9_cm"; 
string COL_ICD_PROC_CODE = "icd_9_cm_code";

string TABLE_MOD = "mod";
string COL_MODIFIER = "modifier";

string TABLE_DRUG = "drug"; //Not used for delete
string COL_DRUG_MANUFACTURER_CODE = "drug_manufacturer_code";
string COL_DRUG_CODE = "drug_code";
string COL_DRUG_PACKAGE_SIZE = "drug_package_size";

string TABLE_REASON = "reason"; 
string COL_REASON_CODE = "reason_code";

string TABLE_TYPEOFBILL = "TypeOfBill"; //Not used for delete
string COL_TYPEOFBILL = "TypeOfBill";

//Event Log Variables
opaque EventLog_Handle;
string ISL_EVENTLOG_HOST = IMAGE_SERVER;
string strEventSourceName = "";
boolean bEventLogReady = false;
boolean bMsgBoxAllowed = false;
string MsgBoxApps = "IFIELDEDIT|IEXCMANUALID|IEDITKFI|IEXCEDIT|IEDITKFP";
string ISL_ERR_INSTRUCTIONS = "An unexpected edit rule error has been encountered. Please report the following error message to the iCapture system administrator.";
string FIELD_NOT_FOUND = "### Field not found ###";

string REGSTRY_KEY_ISCANPLUS = "SOFTWARE\\Impression Technology\\iScanPlus\\7.0\\";
number NUMBER_OF_BACKDATE_SCAN = 365;

string LOOKUP_TABLES_PATH = "";
// 04/19/2019 - ewong - Holidays Lookup Table
string HOLIDAY_TABLE_FILE = "Holidays.txt";
string HOLIDAY_TABLE = "Holidays";

// 01/11/2021 - ProductID Lookup Table
string PRODUCTID_TABLE_FILE = "ProductID.txt";
string PRODUCTID_TABLE = "ProductIds";

string strErrMsg = "";
string strCOMMA = ",";
string TAB = "        ";
string CR = char (13);
string LF = char (10);
string NL = LF;

string getQrfBatchId(opaque hQRF)
{
	string strQrfBatchId;
	boolean bStatus;

	bStatus = get_qrf_BATCH_info(hQRF,  "QRF_BATCH_NAME", strQrfBatchId);
	if (! bStatus)
		strQrfBatchId = "";
	return(strQrfBatchId);
}

boolean LogErrMsg(string strHost, string strSourceClient, opaque hEventLog, string strErrMsg, string strTitle, boolean bDisplayToo, boolean bBeep)
{
	boolean bStatus;
	// Ensure that an exclamation point icon is displayed on the dialog.
	string strMsgType = "Error";

	bStatus = log_error(hEventLog, strErrMsg);
	if (! bStatus) {
		close_event_log(hEventLog);
		bStatus = open_event_log(strHost, strSourceClient, hEventLog);
		if(bStatus)
			bStatus = log_error(hEventLog, strErrMsg);
	}

	if (bDisplayToo) {
		if (ISL_ERR_INSTRUCTIONS != "")
			strErrMsg = concatenate(ISL_ERR_INSTRUCTIONS, CR, LF, CR, LF, strErrMsg);
		bStatus = message_box(strErrMsg, strTitle , strMsgType,  bBeep);
	}
	return(bStatus);
}

boolean LogErrMsg(opaque hEventLog, string strErrMsg, string strTitle, boolean bDisplayToo, boolean bBeep)
{
	boolean bStatus;

	bStatus = LogErrMsg(ISL_EVENTLOG_HOST, strEventSourceName, hEventLog, strErrMsg, strTitle, bBeep, bDisplayToo);
	return(bStatus);
}

boolean LogErrMsg(opaque hEventLog, string strErrMsg, boolean bDisplayToo, boolean bBeep)
{
	boolean bStatus;
	string strTitle = "iSL Error Message Dialog";

	bStatus = LogErrMsg(hEventLog, strErrMsg, strTitle, bDisplayToo, bBeep);
	return(bStatus);
}
// --->

boolean LogErrMsg(opaque hEventLog, string strErrMsg, string strBatchId)
{
	boolean bStatus;

	if (trim(strBatchId) != "")
		strErrMsg = concatenate("Batch Id: ", strBatchId, CR, LF, strErrMsg);

	bStatus = LogErrMsg(hEventLog, strErrMsg, bMsgBoxAllowed, bMsgBoxAllowed);
	return(bStatus);
}

boolean LogErrMsg(opaque hEventLog, string strErrMsg)
{
	boolean bStatus;

	bStatus = LogErrMsg(hEventLog, strErrMsg, "");
	return(bStatus);
}

// Connect to the specified DSN and use the specified database.
boolean Connect_Database(
		string DSN,
		string UserId,
		string Password,
		string DBName,
		opaque& DBHandle)
{
    boolean ok;
	string strErrMsg;
	
    ok = DB_Connect(DSN, UserId, Password, DBHandle);
    if (ok) {
        ok = DB_UseDatabase(DBHandle, DBName);
        if (ok != true)
            DB_Disconnect(DBHandle);
    }
	if (!ok) {
		strErrMsg = concatenate("Failed DB Connection to DSN:", DSN, ", DB:", DBName);
		log_error(EventLog_Handle, strErrMsg);
		return ok;
	}

    return ok;
}
boolean OracleConnectToDatabase(string strDSN, string strUserID, string strPassword, string strDefaultDB, opaque & hDB)
{
	boolean ok = true;
	number DBConnectRetries = 3;
	string strErrorMsg = "";

	ok = DB_Connect(strDSN, strUserID, strPassword, hDB);
	while(!ok && DBConnectRetries > 1)
	{
		ok = DB_Connect(strDSN, strUserID, strPassword, hDB);
		DBConnectRetries = DBConnectRetries - 1;
	}

	if(!ok)
	{
		//log the error message
		strErrorMsg = concatenate("Failed to connect to database. DSN <", strDSN, ">, UserID <", strUserID, ">, DefaultDB <", strDefaultDB, ">.");
		log_error(EventLog_Handle, strErrorMsg);
		return false;
	}

	return true;
}

boolean Reconnect_CAMMIS()
{
    boolean ok;

	DB_Disconnect(DB_Handle);
	DB_Connected = false;

    ok = DB_Connect(DB_DSN, DB_UserId, DB_Password, DB_Handle);
    if (ok) {
        ok = DB_UseDatabase(DB_Handle, DB_Name);
        if (ok != true)
            DB_Disconnect(DB_Handle);
    }

    return ok;
}

boolean Reconnect_Oracle()
{
    boolean ok;

	DB_Disconnect(Oracle_Handle);
	Oracle_Connected = false;

    ok = DB_Connect(Oracle_DSN, Oracle_UserId, Oracle_Password, Oracle_Handle);
    if (ok) {
        ok = DB_UseDatabase(Oracle_Handle, Oracle_DBName);
        if (ok != true)
            DB_Disconnect(Oracle_Handle);
    }

    return ok;
}
// 05012017
// This function will delete all the at least certain days old registry value under "strScannerReg"
boolean Cleanup_Registry(string strScannerReg, number _days_to_keep)
{
    opaque reg_handle;
    boolean ok = true;
    number i;
    string value_name = "";
    string newStr = "";

    // open the local registry
    ok = open_registry("", "HKEY_LOCAL_MACHINE", strScannerReg, "rw", reg_handle);
    if (!ok)	// failed
        return ok;

    for (i=0; ok==true; i=i+1) {
        ok = enum_registry_value(reg_handle, i, value_name);
        if (ok && (len(value_name) == 8)) {	// check the date!
            newStr = concatenate(right(value_name , 4), left(value_name , 4));
            if ((today() - _days_to_keep) > date(newStr)) { // delete all the at least _days_to_keep days old registry value
                delete_registry_value(reg_handle, value_name);
				i = i - 1;		// need to reduce by one for the current item
			}
        }
    }        

    close_registry(reg_handle);
    return true;
}

// 05012017
// This function will delete all the at least NUMBER_OF_BACKDATE_SCAN days old registry value under
// registry key "SOFTWARE\\Impression Technology\\iScanPlus\\7.0\\" for each type of documents
boolean Cleanup_Old_Registry(string _env)
{
    boolean ok = true;
	string strScannerReg;

	strScannerReg = concatenate(REGSTRY_KEY_ISCANPLUS, _env, "\\receive_date");		// for MED, UB04 & DEN
	ok = Cleanup_Registry(strScannerReg, NUMBER_OF_BACKDATE_SCAN);
	if (!ok)	// failed
        return ok;


		
    return true;
}

// process_entry function is called during the process start-up time
// by the following processes: iTransBuilder, iPostProc, iEditor,
// and iExport applications.
boolean process_entry(string Workflow, string AppName, string Env)
{
	boolean ok = true;
	string strErrMsg;

	strEventSourceName = concatenate(AppName, "(iSL)");		// 03052010

	AppName=AppName;
	//  03052010 open eventlog
	ok = open_event_log(ISL_EVENTLOG_HOST, strEventSourceName, EventLog_Handle);
	if(!ok)
		//try to connect to local machine if failed
		ok = open_event_log(get_host_name(), strEventSourceName, EventLog_Handle);
	if (ok)
		bEventLogReady = true;
	
	if (!ok)
		return(false);
	 
	// 07072010
	if (match(AppName, "iScanPlus|iScanClaim|iScanTAR|iScanDR")) {
		if (match(Env, "CA_PROD|DEFAULT"))
			ENVIRONMENT = "CA_PROD";
		else
			//01/06/2020 - rsanchez60@dxc.com - changed CA_MODEL to CA_TRAIN
			ENVIRONMENT = "CA_TRAIN";
		
		// 04192019 load Holidays.txt for Holidays Lookup Table
		if (match(Env, "CA_PROD|DEFAULT"))
			LOOKUP_TABLES_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\FormDB");
		else
			LOOKUP_TABLES_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\FormDB");

		ok = load_table(pathname(LOOKUP_TABLES_PATH, HOLIDAY_TABLE_FILE), HOLIDAY_TABLE, 1, 8, 10, 25, true);
		if (!ok) {
			strErrMsg = concatenate("Failed to load: ", pathname(LOOKUP_TABLES_PATH, HOLIDAY_TABLE_FILE));
			log_error(EventLog_Handle, strErrMsg);
			return ok;
		}
		
		ok = Cleanup_Old_Registry(ENVIRONMENT);
		return ok;
	}
	
	// 01/11/2021 - ProductID Lookup Table
	if (ok && !match(upper(AppName), "IEXPORT|IEXPORT-EXPORT|IPREEXPORT")) {	

		if (match(Env, "CA_PROD|DEFAULT"))
			LOOKUP_TABLES_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\FormDB");
		else
			LOOKUP_TABLES_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\FormDB");
			
		ok = load_table(pathname(LOOKUP_TABLES_PATH, PRODUCTID_TABLE_FILE), PRODUCTID_TABLE, 1, 11, 13, 1, true);
		if (!ok) {
			strErrMsg = concatenate("Failed to load: ", pathname(LOOKUP_TABLES_PATH, PRODUCTID_TABLE_FILE));
			log_error(EventLog_Handle, strErrMsg);
			return ok;
		}
	}
	
	if (ok && match(upper(AppName), "IPREEXPORT")) {
        ok = Fetch_MaxBatchSize_Registry(Env);
        if (! ok) return false; // fail
	}

	if (ok && match(upper(AppName), "IEXPORT|IEXPORT-EXPORT")) {
		//set the output directories based on Environment
		if (match(Env, "CA_PROD|DEFAULT")) {
			ENVIRONMENT = "PROD";
			//08/24/2020 - SS - Output file changes
			//EXPORT_OUTPUT_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CAMMIS\\READY");
			EXPORT_OUTPUT_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CAMMIS\\PREPACKAGED");
			
			// 04/21/2017 C.Hou: Misc. forms index file output folder
			EXPORT_INDEX_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\TIS");
			// 04/21/2017 C.Hou: Misc. forms multi-page TIFF image file output folder
			EXPORT_INDEX_IMAGE_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\TIS\\Images");
			
			//01/21/2020 - rsanchez60@dxc.com - change path to new SURGE\TAR3 output path
			EXPORT_TAR3_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\SURGE\\TAR3");
			
			//01/21/2020 - rsanchez60@dxc.com - add new CORR output path
			EXPORT_CORR_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CRM\\CORR");
			
			EXPORT_CSV_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\Summary");
			
			EXPORT_RTP_CSV_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\RTP_Summary");
			
		} else {
			ENVIRONMENT = "TRAIN";
			//08/24/2020 - SS - Output file changes
			//EXPORT_OUTPUT_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CAMMIS\\READY");
			EXPORT_OUTPUT_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CAMMIS\\PREPACKAGED");
			
			// 04/21/2017 C.Hou: Misc. forms index file output folder
			EXPORT_INDEX_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\TIS");
			// 04/21/2017 C.Hou: Misc. forms multi-page TIFF image file output folder
			EXPORT_INDEX_IMAGE_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\TIS\\Images");
			
			//01/21/2020 - rsanchez60@dxc.com - change path to new SURGE\TAR3 output path
			EXPORT_TAR3_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\SURGE\\TAR3");
			
			//01/21/2020 - rsanchez60@dxc.com - add new CORR output path
			EXPORT_CORR_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\CRM\\CORR");
			
			EXPORT_CSV_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\Summary");
			
			EXPORT_RTP_CSV_PATH = concatenate ("\\\\", IMAGE_SERVER, "\\Output\\RTP_Summary");
		}
		
		//set font for ccn imprint
		set_text_font("Arial", 16, true, false);
	}

	//set the Statistics DB based on Environment
	if (match(Env, "CA_PROD|DEFAULT")) {		
		iStatistics_DB_DSN = "CA_iStatistics";
		iStatistics_DB_Name = "CA_iStatistics";
	} else {
		iStatistics_DB_DSN = "CA_iStatTrain";
		iStatistics_DB_Name = "CA_iStatistics";
	}
	
	//08/14/2020 - rsanchez60@dxc.com - assign Oracle_DSN per environment 
	//set the DB based on Environment
	if (match(Env, "CA_PROD|DEFAULT")) {		
		DB_DSN = "CAMMIS";
		Oracle_DSN = "TARQuery_PROD";
	} else {
		DB_DSN = "CAMMIS_TRAIN";
		Oracle_DSN = "TARQuery";
	}

	// All the IQMMIS iSL application should connect to the DB.
	DB_Connected = Connect_Database(DB_DSN, DB_UserId, DB_Password,
                                   DB_Name, DB_Handle);

	if(!DB_Connected)
		return false;
	
	//For iEditor the connection to oracle database is done in form entry for TAR & TAR_APPEAL.

	return ok;
}

// process_exit function is called during the process exit time by
// the following processes:  iTransBuilder, iPostProc, iEditor,
// and iExport.
boolean process_exit(string Workflow, string AppName, string Env)
{
    boolean ok = true;

    if (DB_Connected == true) {
        ok = DB_Disconnect(DB_Handle);
        DB_Connected = false;
    }
	
    if (Oracle_Connected == true) {
        ok = DB_Disconnect(Oracle_Handle);
        Oracle_Connected = false;
    }	
    
    return ok;
}

boolean update_claim_statistics(string claim_dcn, string reject_code, string reject_operator)
{
	boolean ok = true;
	string strRetVal = "";
	string strExportDate = "";

	//first check if database is connected
	if(!iStatistics_DB_Connected)
	{
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;
	}

	//validate input parameters before calling stored procedure
	if(claim_dcn == "" || reject_code == "")
		return false;

	strExportDate = format(today(), "mm/dd/yyyy");
	strExportDate = concatenate(strExportDate, " ", time("hh:mm:ss"));

	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_UPDATE_CLAIM_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											claim_dcn,						//input parameter dcn
											"IN",							//type of parameter
											reject_code,					//input parameter Reject_Code
											"IN",							//type of parameter
											reject_operator,				//input parameter Reject_Operator
											"IN",							//type of parameter
											strExportDate,					//input parameter Export_Date
											"IN"							//type of parameter
											);
	if(!ok)
	{
		//re-connect database in case stale connection
		DB_Disconnect(iStatistics_DB_Handle);
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
												0,								//type of database - 0 - MS SQL
												"",								//schema name - blank for MS SQL
												"",								//package name - blank for MS SQL
												STORED_PROC_UPDATE_CLAIM_STAT,	//stored procedure name
												true,							//boolean flag to indicate return value exists
												strRetVal,						//return value of the stored procedure
												claim_dcn,						//input parameter dcn
												"IN",							//type of parameter
												reject_code,					//input parameter Reject_Code
												"IN",							//type of parameter
												reject_operator,				//input parameter Reject_Operator
												"IN",							//type of parameter
												strExportDate,					//input parameter Export_Date
												"IN"							//type of parameter
												);
		if(!ok) return false;
	}

	//check any error returned by stored procedure
	if(strRetVal != "0")
		return false;

	return true;
}

boolean insert_claim_statistics(string claim_dcn, string roll_number, string batch_number,
number pages, string claim_type, string reject_code, string reject_operator, string scan_date,
string import_date)
{
	boolean ok = true;
	string strRetVal = "";
	string strExportDate = "";

	//first check if database is connected
	if(!iStatistics_DB_Connected)
	{
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;
	}

	//validate input parameters before calling stored procedure
	if(claim_dcn == "")
		return false;

	strExportDate = format(today(), "mm/dd/yyyy");
	strExportDate = concatenate(strExportDate, " ", time("hh:mm:ss"));

	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_INSERT_CLAIM_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											claim_dcn,						//input parameter dcn
											"IN",							//type of parameter
											roll_number,					//input parameter Region
											"IN",							//type of parameter
											batch_number,					//input parameter Batch_Num
											"IN",							//type of parameter
											(string)pages,					//input parameter Pages
											"IN",							//type of parameter
											claim_type,						//input parameter Doc_Type
											"IN",							//type of parameter
											reject_code,					//input parameter Reject_Code
											"IN",							//type of parameter
											reject_operator,				//input parameter Reject_Operator
											"IN",							//type of parameter
											scan_date,						//input parameter Scan_Date
											"IN",							//type of parameter
											import_date,					//input parameter Import_Date
											"IN",							//type of parameter
											strExportDate,					//input parameter Export_Date
											"IN"							//type of parameter
											);
	if(!ok)
	{
		//re-connect database in case stale connection
		DB_Disconnect(iStatistics_DB_Handle);
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;

		//call the stored procedure again
	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_INSERT_CLAIM_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											claim_dcn,						//input parameter dcn
											"IN",							//type of parameter
											roll_number,					//input parameter Region
											"IN",							//type of parameter
											batch_number,					//input parameter Batch_Num
											"IN",							//type of parameter
											(string)pages,					//input parameter Pages
											"IN",							//type of parameter
											claim_type,						//input parameter Doc_Type
											"IN",							//type of parameter
											reject_code,					//input parameter Reject_Code
											"IN",							//type of parameter
											reject_operator,				//input parameter Reject_Operator
											"IN",							//type of parameter
											scan_date,						//input parameter Scan_Date
											"IN",							//type of parameter
											import_date,					//input parameter Import_Date
											"IN",							//type of parameter
											strExportDate,					//input parameter Export_Date
											"IN"							//type of parameter
											);
		if(!ok) return false;
	}

	//check any error returned by stored procedure
	if(strRetVal != "0")
		return false;

	return true;
}

boolean query_Reject_Reason(string& reject_code, string& reject_reason)
{
    number rows;
    string condition;
    opaque ResultHandle;
    boolean retried = false;
    boolean ok = true;

	while (true) {
	
		if (!iStatistics_DB_Connected) {
			iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
										iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
			if (!iStatistics_DB_Connected) {
				if (bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error connecting to: ", iStatistics_DB_DSN));
				return false;
			}
		}

		condition = concatenate(Column_Reject_Code, "='", reject_code, "'");
		rows = DB_Select(iStatistics_DB_Handle, Table_RejectCode, condition,
						ResultHandle, Column_Reject_Reason);
						
		if (rows > 0) {
			ok = DB_GetResult(ResultHandle, 1, Column_Reject_Reason, reject_reason);
			DB_DisposeResult(ResultHandle);
			if (!ok && bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error getting results from: ", Table_RejectCode));
			return ok;
		}

		if (rows == 0) {
			if (bEventLogReady)
				log_error(EventLog_Handle, concatenate("Reject Code not in table: ", reject_code));
			return false; //not found
		}
		
		// DB query error
		if (! retried) {
			// retry once by disconnecting & reconnecting
			DB_Disconnect(iStatistics_DB_Handle);
			iStatistics_DB_Connected = false;
			retried = true;
		}
		else
			return false;  // failed on retry
	}
}

boolean insert_batch_statistics(
	string Batch_Num,
	string Doc_ID,
	string Claim_Type,
	number Num_Docs,
	string Scan_Date,
	string Header_Doc_Count,
	string Last_Queue)
{
	boolean ok = true;
	string strRetVal = "";
	string Julian_Date = mid(Batch_Num, 6, 3); //substitute(Batch_Num, "[[:alnum:]]{6}([[:digit:]]{3}).*", "\\1");	//RRYYYYJJJCBBB

	//first check if database is connected
	if(!iStatistics_DB_Connected)
	{
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;
	}

	//validate input parameters before calling stored procedure
	if (Batch_Num == "")
		return false;

	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_INSERT_BATCH_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											Julian_Date,					//input parameter
											"IN",							//type of parameter
											Batch_Num,						//input parameter
											"IN",							//type of parameter
											Doc_ID,							//input parameter
											"IN",							//type of parameter
											Claim_Type,						//input parameter
											"IN",							//type of parameter
											(string)Num_Docs,				//input parameter
											"IN",							//type of parameter
											format(date(Scan_Date), "yyyy-mm-dd"),	//input parameter
											"IN",							//type of parameter
											Header_Doc_Count,				//input parameter
											"IN",							//type of parameter
											Last_Queue,						//input parameter
											"IN"							//type of parameter
											);
	if(!ok)
	{
		//re-connect database in case stale connection
		DB_Disconnect(iStatistics_DB_Handle);
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_INSERT_BATCH_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											Julian_Date,					//input parameter
											"IN",							//type of parameter
											Batch_Num,						//input parameter
											"IN",							//type of parameter
											Doc_ID,							//input parameter
											"IN",							//type of parameter
											Claim_Type,						//input parameter
											"IN",							//type of parameter
											(string)Num_Docs,				//input parameter
											"IN",							//type of parameter
											format(date(Scan_Date), "yyyy-mm-dd"),	//input parameter
											"IN",							//type of parameter
											Header_Doc_Count,				//input parameter
											"IN",							//type of parameter
											Last_Queue,						//input parameter
											"IN"							//type of parameter
											);
		if(!ok) return false;
	}

	//check any error returned by stored procedure
	if(strRetVal != "0")
		return false;

	return true;
}


boolean update_batch_statistics(
	string Batch_Num,
	string Header_Doc_Count,
	string Operator_Name,
	string Last_Queue)
{
	boolean ok = true;
	string strRetVal = "";

	//first check if database is connected
	if(!iStatistics_DB_Connected)
	{
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;
	}

	//validate input parameters before calling stored procedure
	if (Batch_Num == "")
		return false;

	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_UPDATE_BATCH_STAT,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											Batch_Num,						//input parameter
											"IN",							//type of parameter
											Header_Doc_Count,				//input parameter
											"IN",							//type of parameter
											Operator_Name,					//input parameter
											"IN",							//type of parameter
											Last_Queue,						//input parameter
											"IN"							//type of parameter
											);
	if(!ok)
	{
		//re-connect database in case stale connection
		DB_Disconnect(iStatistics_DB_Handle);
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
												0,								//type of database - 0 - MS SQL
												"",								//schema name - blank for MS SQL
												"",								//package name - blank for MS SQL
												STORED_PROC_UPDATE_BATCH_STAT,	//stored procedure name
												true,							//boolean flag to indicate return value exists
												strRetVal,						//return value of the stored procedure
												Batch_Num,						//input parameter
												"IN",							//type of parameter
												Operator_Name,					//input parameter
												"IN",							//type of parameter
												Last_Queue,							//input parameter
												"IN"							//type of parameter
												);
		if(!ok) return false;
	}

	//check any error returned by stored procedure
	if(strRetVal != "0")
		return false;

	return true;
}

//09/06/11 - RSanchez - Change request DE-005 - 
//	Create Stored Procedure to update the number of docs/claims for a 2 detail batch
//	Export report: count 2nd Detail Section as a separate claim.
boolean update_batch_statistics_Num_Docs(
	string Batch_Num,
	string Num_Docs)
{
	boolean ok = true;
	string strRetVal = "";

	//first check if database is connected
	if(!iStatistics_DB_Connected)
	{
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;
	}

	//validate input parameters before calling stored procedure
	if (Batch_Num == "")
		return false;

	ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
											0,								//type of database - 0 - MS SQL
											"",								//schema name - blank for MS SQL
											"",								//package name - blank for MS SQL
											STORED_PROC_UPDATE_BATCH_STAT_NUM_DOCS,	//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											Batch_Num,						//input parameter
											"IN",							//type of parameter
											Num_Docs,						//input parameter
											"IN"							//type of parameter
											);
	if(!ok)
	{
		//re-connect database in case stale connection
		DB_Disconnect(iStatistics_DB_Handle);
		//try to re-connect
		iStatistics_DB_Connected = Connect_Database(iStatistics_DB_DSN, iStatistics_DB_UserId, 
									iStatistics_DB_Password, iStatistics_DB_Name, iStatistics_DB_Handle);
		if(!iStatistics_DB_Connected)
			return false;

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(iStatistics_DB_Handle,			//database connection handle
												0,								//type of database - 0 - MS SQL
												"",								//schema name - blank for MS SQL
												"",								//package name - blank for MS SQL
												STORED_PROC_UPDATE_BATCH_STAT_NUM_DOCS,	//stored procedure name
												true,							//boolean flag to indicate return value exists
												strRetVal,						//return value of the stored procedure
												Batch_Num,						//input parameter
												"IN",							//type of parameter
												Num_Docs,						//input parameter
												"IN"							//type of parameter
												);
		if(!ok) return false;
	}

	//check any error returned by stored procedure
	if(strRetVal != "0")
		return false;

	return true;
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

boolean GetNextBatchCCN(string strDCN, string strClaimType, string strReceivedDate, number nDocCount, string & strBatchCCN, number & nStartingCCNSeqNo)
{
	boolean ok = true;
	string strRetVal = "";
	string strNextRollNumber = "";
	string strNextBatchNumber = "";
	string strNextSeqNum = "";
	string strLastCCN = "";

	//first check if database is connected
	if(!DB_Connected)
	{
		//try to re-connect
		DB_Connected = Connect_Database(DB_DSN, DB_UserId, DB_Password, DB_Name, DB_Handle);
		if(!DB_Connected)
			return false;
	}

	ok = DB_StoredProcedure_WithParamTypes(DB_Handle,			//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											STORED_PROC_GetNextCCN,					//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											strClaimType,						//input parameter ClaimType
											"IN",							//type of parameter
											strReceivedDate,					//input parameter Received Date
											"IN",							//type of parameter
											(string)nDocCount,					//input parameter claims count
											"IN",							//type of parameter
											(string)MaxBatchSize,					//input parameter max batch size
											"IN",							//type of parameter
											strNextRollNumber,					//output parameter for roll number
											"OUT",							//type of parameter
											strNextBatchNumber,					//output parameter for batch number
											"OUT",							//type of parameter
											strNextSeqNum,						//output parameter for next seq number
											"OUT"							//type of parameter
											);
	
	if(!ok)
	{
		log_error(EventLog_Handle, "GetNextBatchCCN: CAMMIS database stored procedure GetNextCCN failed first time, trying to reconnect database...");
		//try reconnecting database
		ok = Reconnect_CAMMIS();
		if(!ok)
		{
			log_error(EventLog_Handle, "GetNextBatchCCN: Database reconnect failed.");
			return false;
		}

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,			//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											STORED_PROC_GetNextCCN,					//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											strClaimType,						//input parameter ClaimType
											"IN",							//type of parameter
											strReceivedDate,					//input parameter Received Date
											"IN",							//type of parameter
											(string)nDocCount,					//input parameter claims count
											"IN",							//type of parameter
											(string)MaxBatchSize,					//input parameter max batch size
											"IN",							//type of parameter
											strNextRollNumber,					//output parameter for roll number
											"OUT",							//type of parameter
											strNextBatchNumber,					//output parameter for batch number
											"OUT",							//type of parameter
											strNextSeqNum,						//output parameter for next seq number
											"OUT"							//type of parameter
											);
		if(!ok)
		{
			log_error(EventLog_Handle, "GetNextBatchCCN: CAMMIS database stored procedure GetNextCCN failed second time.");
			return false;
		}
	}

	//check any error returned by stored procedure
	if(strRetVal == "-1")
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned -1. ClaimType (", strClaimType, ") not found in ClaimTypeCategory table."));
			return false;
	}
	if(strRetVal == "-2")
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned -2. Roll numbers and batch numbers are exhausted for ClaimType (", strClaimType, ")."));
			return false;
	}
	if(strRetVal == "-3")
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned -3. No batch numbers are available for ClaimType (", strClaimType, ")."));
			return false;
	}
	if(strRetVal == "-4")
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned -4. Claim type doesn't exist in BatchRangeClaimType table. ClaimType (", strClaimType, ")."));
			return false;
	}
	if(strRetVal == "-5")
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned -5. Document count exceeds maximum batch size. ClaimType (", strClaimType, ")."));
			return false;
	}
	if((number)strRetVal < 0)
	{
		log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned error no(", strRetVal, "). ClaimType (", strClaimType, ")."));
			return false;
	}

	if(strRetVal == "0")
	{
		if(trim(strNextRollNumber) == "")
		{
			log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned blank roll number for ClaimType (", strClaimType, ")."));
			return false;
		}
		if(trim(strNextBatchNumber) == "")
		{
			log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned blank batch number for ClaimType (", strClaimType, ")."));
			return false;
		}
		if(trim(strNextSeqNum) == "")
		{
			log_error(EventLog_Handle, concatenate("GetNextBatchCCN: GetNextCCN returned blank seq number for ClaimType (", strClaimType, ")."));
			return false;
		}

		strBatchCCN = concatenate(right(format((date)strReceivedDate, "yyjjj"), 4), lfill(trim(strNextRollNumber), 2, "0"), lfill(trim(strNextBatchNumber), 2, "0"));
		nStartingCCNSeqNo = (number)trim(strNextSeqNum);
		strLastCCN = concatenate(strBatchCCN, lfill((string)(nStartingCCNSeqNo-1+nDocCount), 3, "0"));
		return SaveLastCCN(strClaimType, strReceivedDate, strLastCCN);
	}

	return false;
}

boolean SaveLastCCN(string strClaimType, string strReceivedDate, string strCCN)
{
	boolean ok = true;
	string strRetVal = "";

	//first check if database is connected
	if(!DB_Connected)
	{
		//try to re-connect
		DB_Connected = Connect_Database(DB_DSN, DB_UserId, DB_Password, DB_Name, DB_Handle);
		if(!DB_Connected)
			return false;
	}

	ok = DB_StoredProcedure_WithParamTypes(DB_Handle,			//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											STORED_PROC_SaveLastCCN,				//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											strClaimType,						//input parameter ClaimType
											"IN",							//type of parameter
											strReceivedDate,					//input parameter Received Date
											"IN",							//type of parameter
											strCCN,							//input parameter Last CCN
											"IN",							//type of parameter
											mid(strCCN, 5, 2),					//input parameter Roll number
											"IN",							//type of parameter
											(string)((number)mid(strCCN, 7, 2)),			//output parameter for batch number
											"IN",							//type of parameter
											(string)((number)mid(strCCN, 9, 3)),			//output parameter for seq number
											"IN");							//type of parameter
	
	if(!ok)
	{
		log_error(EventLog_Handle, "SaveLastCCN: CAMMIS database stored procedure SaveLastCCN failed first time, trying to reconnect database...");
		//try reconnecting database
		ok = Reconnect_CAMMIS();
		if(!ok)
		{
			log_error(EventLog_Handle, "SaveLastCCN: Database reconnect failed.");
			return false;
		}

		//call the stored procedure again
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,			//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											STORED_PROC_SaveLastCCN,				//stored procedure name
											true,							//boolean flag to indicate return value exists
											strRetVal,						//return value of the stored procedure
											strClaimType,						//input parameter ClaimType
											"IN",							//type of parameter
											strReceivedDate,					//input parameter Received Date
											"IN",							//type of parameter
											strCCN,							//input parameter Last CCN
											"IN",							//type of parameter
											mid(strCCN, 6, 2),					//input parameter Roll number
											"IN",							//type of parameter
											(string)((number)mid(strCCN, 8, 2)),			//output parameter for batch number
											"IN",							//type of parameter
											(string)((number)mid(strCCN, 10, 3)),			//output parameter for seq number
											"IN");							//type of parameter

		if(!ok)
		{
			log_error(EventLog_Handle, "SaveLastCCN: CAMMIS database stored procedure SaveLastCCN failed second time.");
			return false;
		}
	}

	//check any error returned by stored procedure
	if((number)strRetVal < 0)
	{
		log_error(EventLog_Handle, concatenate("SaveLastCCN: SaveLastCCN returned (", strRetVal, ")for ClaimType (", strClaimType, "), Received date (", strReceivedDate, "), CCN (", strCCN, ")."));
			return false;
	}

	return true;
}

boolean GetNextTARBatchCCN(string strDCN, string strClaimType, string strReceivedDate, number nDocCount, string & strBatchCCN, number & nStartingCCNSeqNo)
{
	boolean ok;
	number nRowCount = 0;
	string strSearchCond;
	opaque hResults;
	string strLastCCN, strLastCCNBatchNumber, strLastCCNSeqNum;
	string strNextCCNBatchNumber, strNextCCNSeqNum, strNextLastCCN, strSource;

	if(trim(strReceivedDate) == "" || trim(strClaimType) == "")
	{
		log_error(EventLog_Handle, "GetNextTARBatchCCN: Blank claim type or received date to generate a new CCN failed.");
		return false;
	}

	//first, query last CCN number for claim type and received date
	strSearchCond = concatenate("ClaimType = '", strClaimType, "' AND ReceivedDate = '", strReceivedDate, "'");
	nRowCount = DB_Select(DB_Handle, "LastTAR3CCN", strSearchCond, hResults, "LastCCN");
	if(nRowCount == -1)
	{
		log_error(EventLog_Handle, "GetNextTARBatchCCN: CAMMIS database query to get last CCN failed, trying to reconnect database...");
		//try reconnecting database
		ok = Reconnect_CAMMIS();
		if(!ok)
		{
			log_error(EventLog_Handle, "GetNextTARBatchCCN: Database reconnect failed.");
			return false;
		}

		//execute the query again
		nRowCount = DB_Select(DB_Handle, "LastTAR3CCN", strSearchCond, hResults, "LastCCN");
		if(nRowCount == -1)
		{
			log_error(EventLog_Handle, "GetNextTARBatchCCN: CAMMIS database query to get last CCN failed again even after reconnecting database.");
			return false;
		}
	}
	if(nRowCount > 0)
	{
		ok = DB_GetResult(hResults, 1, "LastCCN", strLastCCN);
		if(!ok)
		{
			log_error(EventLog_Handle, "GetNextTARBatchCCN: DB_GetResult failed after querying for LastCCN.");
			DB_DisposeResult(hResults);
			return false;
		}
		DB_DisposeResult(hResults);
	}
	
	if(upper(left(strDCN, 1)) == "F")
		strSource = "F"; //for fax
	else
		strSource = "P"; //for evrything else - scanning

	//check if there was a CCN generated before for the claim type and the received date
	if(trim(strLastCCN) == "")
	{
		//this is the first CCN for claim type and received date
		//format batch CCN as yyyyjjjcbbb
		//strBatchCCN = concatenate("20", mid(strDCN, 4, 5), strSource, "001");
		strBatchCCN = concatenate("20", format((date)strReceivedDate, "yyjjj"), strSource, "001");
		nStartingCCNSeqNo = 1;
		strNextLastCCN = concatenate(strBatchCCN, lfill((string)nDocCount, 3, "0"));
		return SaveLastTAR3CCN(strClaimType, strReceivedDate, strNextLastCCN, true);
	}

	//now, last CCN must be in yyyyjjjcbbb### format 
	strLastCCNBatchNumber = mid(trim(strLastCCN), 9, 3);
	strLastCCNSeqNum = mid(trim(strLastCCN), 12, 3);

	//now check if claim sequence number is exhausted
	if(((number)strLastCCNSeqNum + nDocCount) > 999)
	{
		 //now check if batch number is also exhausted
		if((number)strLastCCNBatchNumber == 999) 
		{
			log_error(EventLog_Handle, concatenate("GetNextTARBatchCCN: All batch numbers are used up for ClaimType(", strClaimType, ") and ReceivedDate(", strReceivedDate, "). Reset database entries and try again."));
			return false;
		}
		else
		{
			//increment batch number and set claim seq number to 001
			strNextCCNBatchNumber = string((number)strLastCCNBatchNumber + 1);
			//claim seq numbers should be 001
			strNextCCNSeqNum = "001";
		}
	}
	else
	{
		strNextCCNBatchNumber = strLastCCNBatchNumber;
		strNextCCNSeqNum = string((number)strLastCCNSeqNum + 1);
	}
	
	//format batch CCN as yyyyjjjcbbb
	//strBatchCCN = concatenate("20", mid(strDCN, 4, 5), strSource, lfill(trim(strNextCCNBatchNumber), 3, "0"));
	strBatchCCN = concatenate("20", format((date)strReceivedDate, "yyjjj"), strSource, lfill(trim(strNextCCNBatchNumber), 3, "0"));
	nStartingCCNSeqNo = (number)strNextCCNSeqNum;
	strNextLastCCN = concatenate(strBatchCCN, lfill((string)(nStartingCCNSeqNo-1+nDocCount), 3, "0"));
	return SaveLastTAR3CCN(strClaimType, strReceivedDate, strNextLastCCN, false);
}

boolean SaveLastTAR3CCN(string strClaimType, string strReceivedDate, string strCCN, boolean bInsert)
{
	boolean ok;
	string strSearchCondition;

	if(bInsert)
	{
		ok = DB_Insert(DB_Handle, "LastTAR3CCN", "ClaimType", strClaimType, "ReceivedDate", strReceivedDate, "LastCCN", strCCN);
		if(!ok)
		{
			log_error(EventLog_Handle, concatenate("SaveTAR3LastCCN: DB_Insert falied while inserting ClaimType(", strClaimType, "), ReceivedDate(", strReceivedDate, ") and LastCCN(", strCCN, "). Check database entries."));
			return false;
		}
	}
	else
	{
		strSearchCondition = concatenate("ClaimType = '", strClaimType, "' AND ReceivedDate='", strReceivedDate, "'");
		ok = DB_Update(DB_Handle, "LastTAR3CCN", strSearchCondition, "LastCCN", strCCN);
		if(!ok)
		{
			log_error(EventLog_Handle, concatenate("SaveTAR3LastCCN: DB_Update falied while updating LastCCN(", strCCN, ") for ClaimType(", strClaimType, ") and ReceivedDate(", strReceivedDate, "). Check database entries."));
			return false;
		}
	}
	return true;
}

boolean is_valid_Diagnosis(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "isvalidDiagnosis");
}

boolean is_valid_HCPCS(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "isvalidHCPCS");
}

boolean is_valid_POS(string value)
{
	//As instructed by CH if string is longer than 2 only first 2 characters will be compared.
	string strvalue;
	strvalue = value;
	
	if(trim(strvalue) == "")
		return false;
		
	if (len(strvalue) > 2)
		strvalue = left(strvalue,2);
	return is_valid_generic(strvalue, "isvalidPOS");
}

boolean is_valid_Procedure_Code(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "isvalidProcedureCode");
}

boolean is_valid_UPN(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "isvalidDRUG");
}

boolean is_valid_DRUG(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "isvalidDRUG");
}

boolean is_valid_LabelID(string value)
{
	if(trim(value) == "")
		return false;
		
	return is_valid_generic(value, "IsValidLabeler");
}

boolean is_valid_TOB(string value)
{
	//As instructed by CH if string is longer than 2 only first 2 characters will be compared.
	string strvalue;
	strvalue = value;
	
	if(trim(strvalue) == "")
		return false;
		
	//03/17/2020 - rsanchez60@dxc.com - If the code is keyed with a leading zero followed by 3 digits, the rule should remove the leading 0 and then check the code against the valid file.
	if (match(strvalue, "0[[:digit:]]{3}"))
		strvalue = right(strvalue,3);
	
	if (len(strvalue) > 2)
		strvalue = left(strvalue,2);
	return is_valid_generic(strvalue, "isvalidTOB");
}

boolean is_valid_Payer(string strctype, string strpayername)
{
    number rows;
    string condition;
    opaque ResultHandle;
    boolean retried = false;
    boolean ok = true;
	string strResult = "";
	
	if(trim(strpayername) == "")
		return false;
	
	while (true) {
	
		if (!DB_Connected) {
			DB_Connected = Connect_Database(DB_DSN, DB_UserId, 
										DB_Password, DB_Name, DB_Handle);
			if (!DB_Connected) {
				if (bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error connecting to: ", DB_DSN));
				return false;
			}
		}

		condition = concatenate("PayerName ='", strpayername, "' AND ClaimType = '", strctype,"'");
		rows = DB_Select(DB_Handle, "Payer", condition,
						ResultHandle, "PayerName");
						
		if (rows > 0) {
			ok = DB_GetResult(ResultHandle, 1, "PayerName", strResult);
			DB_DisposeResult(ResultHandle);
			if (!ok && bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error getting results from: ", "Payer"));
			return true;
		}

		if (rows == 0) {

			return false; //not found
		}
		
		// DB query error
		if (! retried) {
			// retry once by disconnecting & reconnecting
			DB_Disconnect(DB_Handle);
			DB_Connected = false;
			retried = true;
		}
		else
			return false;  // failed on retry
	}
}

boolean is_valid_Provider(string strprovider)
{
	boolean ok = true;
	string strRetVal = "";
	boolean bReTry = false;
	boolean bIS_RECORD_PRESENT = false;
	string strIS_RECORD_PRESENT = "0";
	string sp_isvalidprovider = "IsValidProvider";
	
	if(trim(strprovider) == "")
		return false;
		
	//check if database is connected
	if(!DB_Connected)
	{
		log_error(EventLog_Handle, "CAMMIS database is not connected in is_valid_Provider(...). Trying to reconnect...");
		if(!Reconnect_CAMMIS())
		{
			log_error(EventLog_Handle, 
							"CAMMIS Database reconnect failed in is_valid_Provider(...).");
			return false;
		}
	}


	bReTry = false;

	do
	{
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,		//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											sp_isvalidprovider,	//stored procedure name
											true,						//boolean flag to indicate return value exists
											strRetVal,					//return value of the stored procedure
											strprovider,
											"IN",						//type of parameter
											strIS_RECORD_PRESENT,
											"OUT");										
		if(!ok)
		{
			log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalidprovider, " failed for provider: ", 
								strprovider,
								bReTry ? " 2nd time." : " 1st time."));
			//check if we had already tried
			if(bReTry)
				return false;

			//try reconnecting database
			if(!Reconnect_CAMMIS())
			{
				log_error(EventLog_Handle, 
								"Database reconnect failed after stored procedure isvalidprovider call failed.");
				return false;
			}
			bReTry = true;
		}
		else
			bReTry = false;
	} while(bReTry);

	if((number)strRetVal != 0)
	{
		log_error(EventLog_Handle, 
				concatenate("Stored procedure isvalidprovider returned -1 for provider:", 
								strprovider));
		return false;
	}

	if (ok)
	{
		if((number)strIS_RECORD_PRESENT >= 1)
			bIS_RECORD_PRESENT = true;
		else
			bIS_RECORD_PRESENT = false;
			
		return bIS_RECORD_PRESENT;
	}
	else
		return false;
}

boolean is_valid_Provider_Zip(string strzipcode)
{
	boolean ok = true;
	string strRetVal = "";
	boolean bReTry = false;
	boolean bIS_RECORD_PRESENT = false;
	string strIS_RECORD_PRESENT = "0";
	string sp_isvalidproviderzip = "IsValidProviderZip";

	if(trim(strzipcode) == "")
		return false;
		
	//check if database is connected
	if(!DB_Connected)
	{
		log_error(EventLog_Handle, "CAMMIS database is not connected in is_valid_Provider_Zip(...). Trying to reconnect...");
		if(!Reconnect_CAMMIS())
		{
			log_error(EventLog_Handle, 
							"CAMMIS Database reconnect failed in is_valid_Provider_Zip(...).");
			return false;
		}
	}


	bReTry = false;

	do
	{
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,		//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											sp_isvalidproviderzip,	//stored procedure name
											true,						//boolean flag to indicate return value exists
											strRetVal,					//return value of the stored procedure
											strzipcode,
											"IN",						//type of parameter
											strIS_RECORD_PRESENT,
											"OUT");										
		if(!ok)
		{
			log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalidproviderzip, " failed for zipcode: ", 
								strzipcode,
								bReTry ? " 2nd time." : " 1st time."));
			//check if we had already tried
			if(bReTry)
				return false;

			//try reconnecting database
			if(!Reconnect_CAMMIS())
			{
				log_error(EventLog_Handle, 
								"Database reconnect failed after stored procedure isvalidproviderzip call failed.");
				return false;
			}
			bReTry = true;
		}
		else
			bReTry = false;
	} while(bReTry);

	if((number)strRetVal != 0)
	{
		log_error(EventLog_Handle, 
				concatenate("Stored procedure isvalidproviderzip returned -1 for zipcode:", 
								strzipcode));
		return false;
	}
	strIS_RECORD_PRESENT = strIS_RECORD_PRESENT;
	if (ok)
	{
		if((number)strIS_RECORD_PRESENT >= 1)
			bIS_RECORD_PRESENT = true;
		else
			bIS_RECORD_PRESENT = false;
			
		return bIS_RECORD_PRESENT;
	}
	else
		return false;
}

boolean is_valid_Revenue_Code(string strrevcode)
{
	boolean ok = true;
	string strRetVal = "";
	boolean bReTry = false;
	boolean bIS_RECORD_PRESENT = false;
	string strIS_RECORD_PRESENT = "0";
	string sp_isvalidrevcode = "IsValidRevenueCode";
	
	if(trim(strrevcode) == "")
		return false;
		
	//3/17/2020 - rsanchez60@dxc.com - 2. Perform lookup on Revenue Code table using all four digits if leading digit is 0. If leading digit is not zero and field is just 3 digits, add leading zero and then check for all four digits in table.
	if (len(trim(strrevcode)) == 3)
		strrevcode = concatenate("0", strrevcode);
		
	//check if database is connected
	if(!DB_Connected)
	{
		log_error(EventLog_Handle, "CAMMIS database is not connected in is_valid_Revenue_Code(...). Trying to reconnect...");
		if(!Reconnect_CAMMIS())
		{
			log_error(EventLog_Handle, 
							"CAMMIS Database reconnect failed in is_valid_Revenue_Code(...).");
			return false;
		}
	}


	bReTry = false;

	do
	{
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,		//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											sp_isvalidrevcode,	//stored procedure name
											true,						//boolean flag to indicate return value exists
											strRetVal,					//return value of the stored procedure
											strrevcode,
											"IN",						//type of parameter
											strIS_RECORD_PRESENT,
											"OUT");										
		if(!ok)
		{
			log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalidrevcode, " failed for revcode: ", 
								strrevcode,
								bReTry ? " 2nd time." : " 1st time."));
			//check if we had already tried
			if(bReTry)
				return false;

			//try reconnecting database
			if(!Reconnect_CAMMIS())
			{
				log_error(EventLog_Handle, 
								concatenate("Database reconnect failed after stored procedure", sp_isvalidrevcode ,"call failed."));
				return false;
			}
			bReTry = true;
		}
		else
			bReTry = false;
	} while(bReTry);

	if((number)strRetVal != 0)
	{
		log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalidrevcode, "returned -1 for revcode:", 
								strrevcode));
		return false;
	}

	if (ok)
	{
		if((number)strIS_RECORD_PRESENT >= 1)
			bIS_RECORD_PRESENT = true;
		else
			bIS_RECORD_PRESENT = false;
			
		return bIS_RECORD_PRESENT;
	}
	else
		return false;
}

boolean is_valid_Modifier(string strcode)
{
	boolean ok = true;
	string strRetVal = "";
	boolean bReTry = false;
	boolean bIS_RECORD_PRESENT = false;
	string strIS_RECORD_PRESENT = "0";
	string sp_isvalid = "isvalidModifier";
	
	if(trim(strcode) == "")
		return false;
		
	//check if database is connected
	if(!DB_Connected)
	{
		log_error(EventLog_Handle, "CAMMIS database is not connected in is_valid_Modifier(...). Trying to reconnect...");
		if(!Reconnect_CAMMIS())
		{
			log_error(EventLog_Handle, 
							"CAMMIS Database reconnect failed in is_valid_Modifier(...).");
			return false;
		}
	}


	bReTry = false;

	do
	{
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,		//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											sp_isvalid,	//stored procedure name
											true,						//boolean flag to indicate return value exists
											strRetVal,					//return value of the stored procedure
											strcode,
											"IN",						//type of parameter
											strIS_RECORD_PRESENT,
											"OUT");										
		if(!ok)
		{
			log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalid, " failed for revcode: ", 
								strcode,
								bReTry ? " 2nd time." : " 1st time."));
			//check if we had already tried
			if(bReTry)
				return false;

			//try reconnecting database
			if(!Reconnect_CAMMIS())
			{
				log_error(EventLog_Handle, 
								concatenate("Database reconnect failed after stored procedure", sp_isvalid ,"call failed."));
				return false;
			}
			bReTry = true;
		}
		else
			bReTry = false;
	} while(bReTry);

	if((number)strRetVal != 0)
	{
		log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalid, "returned -1 for revcode:", 
								strcode));
		return false;
	}

	if (ok)
	{
		if((number)strIS_RECORD_PRESENT >= 1)
			bIS_RECORD_PRESENT = true;
		else
			bIS_RECORD_PRESENT = false;
			
		return bIS_RECORD_PRESENT;
	}
	else
		return false;
}

boolean is_valid_generic(string strcode, string sp_isvalid)
{
	boolean ok = true;
	string strRetVal = "";
	boolean bReTry = false;
	boolean bIS_RECORD_PRESENT = false;
	string strIS_RECORD_PRESENT = "0";
	//string sp_isvalid = "isvalidModifier";
	
	if(trim(strcode) == "")
		return false;
		
	//check if database is connected
	if(!DB_Connected)
	{
		log_error(EventLog_Handle, concatenate("CAMMIS database is not connected in ", sp_isvalid,"(...). Trying to reconnect..."));
		if(!Reconnect_CAMMIS())
		{
			log_error(EventLog_Handle, 
							concatenate("CAMMIS Database reconnect failed in ",sp_isvalid," (...)."));
			return false;
		}
	}


	bReTry = false;

	do
	{
		ok = DB_StoredProcedure_WithParamTypes(DB_Handle,		//database connection handle
											0,							//type of database - 0 - MS SQL
											"",							//schema name - blank for MS SQL
											"",							//package name - blank for MS SQL
											sp_isvalid,	//stored procedure name
											true,						//boolean flag to indicate return value exists
											strRetVal,					//return value of the stored procedure
											strcode,
											"IN",						//type of parameter
											strIS_RECORD_PRESENT,
											"OUT");										
		if(!ok)
		{
			log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalid, " failed for revcode: ", 
								strcode,
								bReTry ? " 2nd time." : " 1st time."));
			//check if we had already tried
			if(bReTry)
				return false;

			//try reconnecting database
			if(!Reconnect_CAMMIS())
			{
				log_error(EventLog_Handle, 
								concatenate("Database reconnect failed after stored procedure", sp_isvalid ,"call failed."));
				return false;
			}
			bReTry = true;
		}
		else
			bReTry = false;
	} while(bReTry);

	if((number)strRetVal != 0)
	{
		log_error(EventLog_Handle, 
				concatenate("Stored procedure ", sp_isvalid, "returned -1 for revcode:", 
								strcode));
		return false;
	}

	if (ok)
	{
		if((number)strIS_RECORD_PRESENT >= 1)
			bIS_RECORD_PRESENT = true;
		else
			bIS_RECORD_PRESENT = false;
			
		return bIS_RECORD_PRESENT;
	}
	else
		return false;
}

boolean get_tar_data(string document_cntl_num, string & tcn, string & recip_meds_id, string & recip_id, string & last_name, string & first_name, string & date_of_birth, string & subm_provider_id, string & prvdr_bus_loc_name, string & lgl_name, 
					 string & service_ind, string & service_name, string & consultant_id, string & date_time_released)
{
    number rows;
    string condition;
    opaque ResultHandle;
    boolean retried = false;
    boolean ok = true;
	string strResult = "";
	
	if(trim(document_cntl_num) == "")
		return false;
		
	while (true) {
	
		if (!Oracle_Connected) {
			Oracle_Connected = OracleConnectToDatabase(Oracle_DSN, Oracle_UserId, 
										Oracle_Password, Oracle_DBName, Oracle_Handle);
			if (!Oracle_Connected) {
				if (bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error connecting to: ", Oracle_DSN));
				return false;
			}
		}

		condition = concatenate("DOCUMENT_CNTL_NUM ='", document_cntl_num,"'");
		
		rows = DB_Select(Oracle_Handle, Oracle_DBName, condition,
						ResultHandle, 
			"TCN",
			"RECIP_MEDS_ID",
			"RECIP_ID", 
			"LAST_NAME", 
			"FIRST_NAME",  
			"DATE_OF_BIRTH", 
			"SUBM_PROVIDER_ID",
			"PRVDR_BUS_LOC_NAME", 
			"LGL_NAME",
			"service_ind",
			"service_name",
			"consultant_id",
			"DATE_TIME_RELEASED"
						);
						
		if (rows > 0) {
			ok = DB_GetResult(ResultHandle, 1, "TCN", tcn);
			ok = DB_GetResult(ResultHandle, 1, "RECIP_MEDS_ID", recip_meds_id);
			ok = DB_GetResult(ResultHandle, 1, "RECIP_ID",  recip_id);
			ok = DB_GetResult(ResultHandle, 1, "LAST_NAME",  last_name);
			ok = DB_GetResult(ResultHandle, 1, "FIRST_NAME",   first_name);
			ok = DB_GetResult(ResultHandle, 1, "DATE_OF_BIRTH",  date_of_birth);
			ok = DB_GetResult(ResultHandle, 1, "SUBM_PROVIDER_ID",  subm_provider_id);
			ok = DB_GetResult(ResultHandle, 1, "PRVDR_BUS_LOC_NAME",  prvdr_bus_loc_name);
			ok = DB_GetResult(ResultHandle, 1, "LGL_NAME", lgl_name);
			ok = DB_GetResult(ResultHandle, 1, "service_ind", service_ind);
			ok = DB_GetResult(ResultHandle, 1, "service_name", service_name);
			ok = DB_GetResult(ResultHandle, 1, "consultant_id", consultant_id);
			ok = DB_GetResult(ResultHandle, 1, "DATE_TIME_RELEASED", date_time_released);
			DB_DisposeResult(ResultHandle);
			if (!ok && bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error getting results from: ", "TAR table"));

			return true;
		}

		if (rows == 0) {
			tcn= "";
			recip_meds_id= "";
			recip_id= ""; 
			last_name= ""; 
			first_name= "";  
			date_of_birth= ""; 
			subm_provider_id = subm_provider_id;
			prvdr_bus_loc_name= ""; 
			lgl_name= "";
			service_ind = "";
			service_name = "";
			consultant_id = "";
			date_time_released = "";
			return false; //not found
		}
		
		// Oracle DB query error
		if (! retried) {
			// retry once by disconnecting & reconnecting
			DB_Disconnect(Oracle_Handle);
			Oracle_Connected = false;
			retried = true;
		}
		else
			return false;  // failed on retry
			
	}
}

boolean get_tar_appeal_data(string appeal_no, string & tcn, string & cin, string & medicaid_id, string & last_name, string & first_name,  string & date_of_birth, string & provider_business_name, string & tar_original_receipt_date)
{
    number rows;
    string condition;
    opaque ResultHandle;
    boolean retried = false;
    boolean ok = true;
	string strResult = "";
	
	if(trim(appeal_no) == "")
		return false;
		
	while (true) {
	
		if (!DB_Connected) {
			DB_Connected = Connect_Database(DB_DSN, DB_UserId, 
										DB_Password, DB_Name, DB_Handle);
			if (!DB_Connected) {
				if (bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error connecting to: ", DB_DSN));
				return false;
			}
		}

		condition = concatenate("appeal_no ='", appeal_no,"'");
		rows = DB_Select(DB_Handle, "TAR_Appeal", condition,
						ResultHandle, 
			"tcn",
			"cin",
			"medicaid_id", 
			"Beneficiary_Last_Name", 
			"Beneficiary_First_name",  
			"Beneficiary_Date_of_Birth", 
			"provider_business_name", 
			"tar_original_receipt_date"
						);
						
		if (rows > 0) {
			ok = DB_GetResult(ResultHandle, 1, "tcn", tcn);
			ok = DB_GetResult(ResultHandle, 1, "cin", cin);
			ok = DB_GetResult(ResultHandle, 1, "medicaid_id",  medicaid_id);
			ok = DB_GetResult(ResultHandle, 1, "Beneficiary_Last_Name",  last_name);
			ok = DB_GetResult(ResultHandle, 1, "Beneficiary_First_name",   first_name);
			ok = DB_GetResult(ResultHandle, 1, "Beneficiary_Date_of_Birth",  date_of_birth);
			ok = DB_GetResult(ResultHandle, 1, "provider_business_name",  provider_business_name);
			ok = DB_GetResult(ResultHandle, 1, "tar_original_receipt_date", tar_original_receipt_date);
			DB_DisposeResult(ResultHandle);
			if (!ok && bEventLogReady)
					log_error(EventLog_Handle, concatenate("Error getting results from: ", "Tar Appeal Table"));
					
			tcn= tcn;
			cin= cin;
			medicaid_id= medicaid_id; 
			last_name= last_name; 
			first_name= first_name;  
			date_of_birth= date_of_birth; 
			provider_business_name= provider_business_name; 
			tar_original_receipt_date= tar_original_receipt_date;						
			return true;
		}

		if (rows == 0) {
			tcn= "";
			cin= "";
			medicaid_id= ""; 
			last_name= ""; 
			first_name= "";  
			date_of_birth= ""; 
			provider_business_name= ""; 
			tar_original_receipt_date= "";
			return false; //not found
		}

		
		// DB query error
		if (! retried) {
			// retry once by disconnecting & reconnecting
			DB_Disconnect(DB_Handle);
			DB_Connected = false;
			retried = true;
		}
		else
			return false;  // failed on retry
	}
}

boolean Fetch_MaxBatchSize_Registry(string Env)
{
	string strSubKey, strHost, strEnvKeyPath;
	opaque hRegKey;
	boolean ok = true;
	number numMaxBatchSize;
	
	// First fetch configuration name
	strSubKey = "Software\\Impression Technology\\Configuration\\";

	if(trim(Env) != "") // Use specified environment if it's not blank
		strSubKey = concatenate(strSubKey, Env);
	else                // Otherwise, use DEFAULT environment
		strSubKey = concatenate(strSubKey, "DEFAULT");

	ok = open_registry(IMAGE_SERVER, "HKEY_LOCAL_MACHINE", 
				strSubKey, "r", hRegKey);
	if(!ok) return false;

	// Query for host and base key for that environment
	ok = query_registry_string_value(hRegKey, "ConfHost", strHost);
	if(!ok) return false;

	ok = query_registry_string_value(hRegKey, "ConfRegSubKey", strEnvKeyPath);
	if(!ok) return false;

	// Close the configuration key
	close_registry(hRegKey);

	// Open iExportFAX subkey under Env key
	strSubKey = concatenate(strEnvKeyPath, "\\iPackageOutput\\7.0\\IQMMIS");
	ok = open_registry(strHost, "HKEY_LOCAL_MACHINE",
				strSubKey, "r", hRegKey);
	//if(!ok) return false;
	
	if(ok)
		ok = query_registry_number_value(hRegKey, "MaxBatchSize", numMaxBatchSize);
		
	if(!ok) 
		MaxBatchSize = 999;
	else
		MaxBatchSize = numMaxBatchSize;
	
	//close the registry key
	close_registry(hRegKey);

	return true;
}
