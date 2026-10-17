// Load the mask used for reversing 16-bit
// SSE words.
const __mm128i reverseMask = _mm_set_epi8(
		14, 15, 12, 13, 10, 11, 8,
		9, 6, 7, 4, 5, 2, 3, 0, 1);

// Iterate over each row in the template
for (int yt = -h2; yt <= h2; yt++) {
	// Fetch the pointer to the row descriptor
	// containing the actual length of the row (len)
	// as well as a the count of words that have to
	// be skipped.
	FastGaussTemplateRowDescr rowDescr = *(rowPtr++);

	// Fetch the target pointers
	__m128i *tarPtr1, *tarPtr2;
	if (flip) {
		tarPtr1 = ((__m128i*)&(tar(y - yt, x)))
				+ rowDescr.skip + 0;
		tarPtr2 = ((__m128i*)&(tar(y + yt, x)))
				- rowDescr.skip - 1;
	} else {
		tarPtr1 = ((__m128i*)&(tar(y + yt, x)))
				+ rowDescr.skip + 0;
		tarPtr2 = ((__m128i*)&(tar(y - yt, x)))
				- rowDescr.skip - 1;
	}

	// Iterate over each SSE word in the row
	for (int i = 0; i < rowDescr.len; i++) {
		// Load gauss template and calculate its
		// reverse
		__m128i block1 = _mm_load_si128(blockPtr++);
		__m128i block2 = _mm_shuffle_epi8(block1,
				reverseMask);

		// Load the target blocks, add the gauss
		// template data and store the result
		__m128i tar1 = _mm_loadu_si128(tarPtr1);
		tar1 = _mm_adds_epi16(tar1, block1);
		_mm_storeu_si128(tarPtr1++, tar1);

		__m128i tar2 = _mm_loadu_si128(tarPtr2);
		tar2 = _mm_adds_epi16(tar2, block2);
		_mm_storeu_si128(tarPtr2--, tar2);
	}
}
