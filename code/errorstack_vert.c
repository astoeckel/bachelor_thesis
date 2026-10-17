// Iterate over 8 pixel blocks in the intermediate
// column
for (int y = 0; y < h8; y++) {
	// Load the interpolation factors from facY
	__m128i fac = _mm_load_si128(facYPtr++);

	// Load the shuffle mask from shuffleMaskY
	__m128i shuffle = _mm_load_si128(shuffleMaskYPtr++);

	// Load the input data from the intermediate row
	// and apply the offset offsYPtr
	__m128i in = _mm_loadu_si128(
			(__m128i*)(src + *(offsYPtr++)));

	// Shuffle the input word according to the
	// shuffle mask
	in = _mm_shuffle_epi8(in, shuffle);

	// Perform the actual interpolation, scale
	// the result down to a 8-bit range
	__m128i ss = _mm_maddubs_epi16(in, fac);
	ss = _mm_srli_epi16(ss, TEMPL_SCALE_FACTOR_LOG);

	// Calculate the absolute difference between
	// SS and CV
	__m128i cv = _mm_load_si128(cvPtr++);
	__m128i err = _mm_sub_epi16(ss, cv);
	err = _mm_abs_epi16(err);

	// Mask invalid results with maximal error
	__m128i mask = _mm_cmpeq_epi16(shuffle, cmpMask);
	mask = _mm_srli_epi16(mask, MAX_ERR_SHIFT);
	err = _mm_or_si128(err, mask);

	// Store the result in the error stack
	_mm_store_si128(tar++, err);
}
