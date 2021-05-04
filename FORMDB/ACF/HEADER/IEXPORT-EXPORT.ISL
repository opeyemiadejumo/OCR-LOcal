//FormDB\ACF\HEADER\IEXPORT-EXPORT.ISL

number batch_iteration_count = 0;
number DocNo = 0;
number claim_count = 0;

boolean ALL_CLAIMS_REJECTED = false;
number sum_claims_processed, sum_claims_rejected;
boolean AT_LEAST_ONE_CLAIM_REJECTED = false;
opaque ccn_list;

boolean batch_entry()
{
	boolean ok = true;
	string filename = "";
	string strIndexFileName = "";
	string strRTPFileName = "";
	string strSUMFileName = "";
	string subdir = "";

	//increment the batch iteration count
	batch_iteration_count = batch_iteration_count + 1;
	if (batch_iteration_count == 1) {
		ALL_CLAIMS_REJECTED = true;
		AT_LEAST_ONE_CLAIM_REJECTED = false;		
		
		//initialize array of ccn 
		ok = array_init(NumDocs, 1, ccn_list);
		if(!ok) return false;
	} 
	else 
	{
		//initialize batch variables
		sum_claims_processed = 0;
		sum_claims_rejected = 0;
		
		//fname.REJ - will rename at closing
		ok = open_REJ_file(concatenate(BatchName, ".REJ_busy"));
		
		if(ok)
			ok = open_CSV_file(concatenate(BatchName, ".csv_busy"));
			
		//fname.txt - will rename at closing
		if (ok && !ALL_CLAIMS_REJECTED)
		{
			//open zip file
			//01/21/2020 - rsanchez60@dxc.com - prefixed filename with claim type
			subdir = "ACF";
			ok = open_ZIP_file(pathname(subdir, concatenate(subdir, "_", BatchName, ".zip_busy")));
			if(!ok) 
			{
				clean_up_busy_file("");
				return false;
			}

			//first remove and then create a folder with BatchName to copy index.dat and images
			rmdir_recursive(pathname(EXPORT_INDEX_PATH, BatchName));
			ok = mkdir(pathname(EXPORT_INDEX_PATH, BatchName));
			if(!ok)
			{
				clean_up_busy_file("");
				return false;
			}

			ok = open_IND_file(pathname(BatchName, "index.dat_busy"));
			
			////one per batch
			//ok = open_DATA_file(concatenate(BatchName, ".DAT_busy"));			
		}
		
		if (!ok)
			clean_up_busy_file("");
	}		
	return ok;
}

boolean batch_exit()
{
	boolean ok = true;
	string final_path, busy_path;
	
	string temp, batchCCN, trigger_file, trigger_path;
	opaque hTRIGfile;

	if (batch_iteration_count == 2) 
	{
		ok = close_REJ_file();
		
		if(ok)
			ok = close_CSV_file();
			
		if (ok && !ALL_CLAIMS_REJECTED) 
		{
			ok = close_IND_file();
			
			//add index file to the zip
			final_path = pathname(EXPORT_INDEX_PATH, concatenate(BatchName, "\\index.dat"));
			ok = zipplugin_add_file_to_zip(final_path, false);

			// 06042019 - Create trigger file based on new ACF spec.
			array_get(ccn_list, 1, 1, temp);
			batchCCN = left(temp, 8);
			trigger_file = concatenate(batchCCN, ".trigger");
			trigger_path = pathname(EXPORT_INDEX_PATH, concatenate(BatchName, "\\", trigger_file));
			
			// Create an empty trigger file
			truncate(trigger_path);
			ok = open(trigger_path, hTRIGfile);
			if (ok)
				close(hTRIGfile);
			
			// add it to the zip
			ok = zipplugin_add_file_to_zip(trigger_path, false);		
		

			//remove the subfolder containing index file
			rmdir_recursive(pathname(EXPORT_INDEX_PATH, BatchName));

			//close zip file
			if(ok)
				close_ZIP_file();

			// close_DATA_file();
		}
		
		if (!ok)
			clean_up_busy_file("");
		
		if (ok)
			   update_batch_statistics(BatchName, (string)NumDocs, "", substitute(APPLICATION, "[^-]+-([^-]+)", "\\1"));
		
		array_destroy(ccn_list);
	}
	return ok;
}

//one per batch
boolean export_DATA_header()
{
	boolean ok = true;
	string buffer = "";
	string reel = "";
	
	ok = open_DATA_header(concatenate(BatchName, ".HDR_busy"));
	
	// | | Len:4 | 
	buffer = concatenate(buffer, "0022");

	// | | Len:4 | 
	buffer = concatenate(buffer, "CZZZ");

	//reel | N | Len:5 | Position 4 thru 8 in the YJJJRRBBSSS;Last digit of the julian date of the batch;Roll number and Batch number
	reel = mid(first_ccn, 4, 5);
	buffer = concatenate(buffer, reel);

	//Claim count | N | Len:5 | 
	buffer = concatenate(buffer, format_number(string(claim_count), 5));

	// | | Len:4 | 
	buffer = concatenate(buffer, "O11 ");

	ok = output(hDATAHeaderFile, buffer);
	if (ok)
		ok = close_DATA_header();
	if (!ok)
		clean_up_busy_file(concatenate("Exporting batch HEADER. Output file: ", DATAHeader_output_file));
		
	return ok;
}

boolean export_DATA_trailer()
{
	boolean ok = true;
	string buffer = "";
	string rollno = "";
	string batchno = "";

	ok = open_DATA_trailer(concatenate(BatchName, ".TLR_busy"));

	// | | Len:4 | 
	buffer = concatenate(buffer, "0161");

	// | | Len:4 | 
	buffer = concatenate(buffer, "B001");

	//YJJJ of CCN | N | Len:4 | 
	buffer = concatenate(buffer, left(first_ccn, 4));

	// | | Len:3 | 
	buffer = concatenate(buffer, "OCR");

	//receive_date| MMDDYY | Len:6 | 
	buffer = concatenate(buffer, format_date(JulianToMMDDYYYY(receive_date)));
	
	// claim_type mapping
	//claim_type | AN | Len:2 | 
	buffer = concatenate(buffer, format_string(get_claim_type_mapping(claim_type), 2, " "));

	//RR of CCN | N | Len:2 | 
	//get Roll# from first page ccn. CCN format: YJJJRRBBDDD
	rollno = mid(first_ccn, 5, 2);
	buffer = concatenate(buffer, format_number(rollno, 2));

	//BB of CCN | N | Len:2 | 
	//get Batch Number from first page ccn. CCN format: YJJJRRBBDDD
	batchno = mid(first_ccn, 7, 2);
	buffer = concatenate(buffer, format_number(batchno, 2));

	//The last claim SSS of the batch of CCN | N | Len:3 | 
	buffer = concatenate(buffer, right(last_ccn,3));

	// | | Len:1 | 
	buffer = concatenate(buffer, rept(" ", 1));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:2 | 
	buffer = concatenate(buffer, rept(" ", 2));

	// | | Len:3 | 
	buffer = concatenate(buffer, rept(" ", 3));

	// | | Len:2 | 
	buffer = concatenate(buffer, rept(" ", 2));

	// | | Len:3 | 
	buffer = concatenate(buffer, "BIC");

	ok = output(hDATATrailerFile, buffer);
	
	if (ok)
		ok = close_DATA_trailer();
	if (!ok)
		clean_up_busy_file(concatenate("Exporting batch TRAILER. Output file: ", DATATrailer_output_file));
		
	return ok;
}
