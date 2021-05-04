// \\V-CAMMIS-IMG\FORMDB\ACF\ACF\iExcEdit-QC_EDIT.isl
//

/////////////////////////////////////////////////////////////////////////////////////
//QC Rules
////////////////////////////////////////////////////////////////////////////////////

//allow "?" for drop-down selection
assert
	bound(reject_code) && IsFieldReadWrite(DOCUMENT, FORMNO, reject_code)
			? (overridden(reject_code) || trim(reject_code) == "?" ||
               verify_history(get_result_count(reject_code),
               previous_result(reject_code), reject_code))
            : true
      @ reject_code
      # "The value you entered does not match the previously keyed result.("previous_result(reject_code)") ";

assert
  bound(acn) && IsFieldReadWrite(DOCUMENT, FORMNO, acn)
    ? (overridden(acn) || (previous_result(acn) == acn))
    : true
@ acn
# "The value you entered does not match the previously keyed result. ("
   previous_result(acn)  ").";
   
assert
  bound(prov_number) && IsFieldReadWrite(DOCUMENT, FORMNO, prov_number)
    ? (overridden(prov_number) || (previous_result(prov_number) == prov_number))
    : true
@ prov_number
# "The value you entered does not match the previously keyed result. ("
   previous_result(prov_number)  ").";

