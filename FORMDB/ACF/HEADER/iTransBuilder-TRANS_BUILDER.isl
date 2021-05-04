//FORMDB\<all documents>\HEADER\iTransBuilder-TRANS_BUILDER.isl

// 10192020
// 10302020 - Only apply to Scanned Batch
assert
	match(barcode, "[0-9]{2}[[:alpha:]]{1}[0-9]{6}") || (left(SourceID, 1) == "F")
	@ barcode
	# "barcode: Wrong Format of Header Sheet barcode!";
	