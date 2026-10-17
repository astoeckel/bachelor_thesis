// Shuffle masks used for interlacing
const __m128i shuffleLo1 = _mm_set_epi8(
		0, 0x80, 1, 0x80, 2, 0x80, 3, 0x80,
		4, 0x80, 5, 0x80, 6, 0x80, 7, 0x80);
const __m128i shuffleLo2 = _mm_set_epi8(
		0x80, 0, 0x80, 1, 0x80, 2, 0x80, 3,
		0x80, 4, 0x80, 5, 0x80, 6, 0x80, 7};
const __m128i shuffleHi1 = _mm_set_epi8(
		8, 0x80, 9, 0x80, 10, 0x80, 11, 0x80,
		12, 0x80, 13, 0x80, 14, 0x80, 15, 0x80};
const __m128i shuffleHi2 = _mm_set_epi8(
		0x80, 8, 0x80, 9, 0x80, 10, 0x80, 11,
		0x80, 12, 0x80, 13, 0x80, 14, 0x80, 15};

// Load the source pointers
__m128i *src1 = (__m128i*)snapshot.components[c].ptr(
		tarX(d, x) + 0 + ssXOffs);
__m128i *src2 = (__m128i*)snapshot.components[c].ptr(
		tarX(d, x) + 1 + ssXOffs);

// Load the factors
__m128i fac = _mm_set_epi8(
		facX(x)[0], facX(x)[1],
		facX(x)[0], facX(x)[1],
		[...]);

for (int y = 0; y < h16; y++) {
	// Load the two source words (16x8-bit)
	__m128i in1 = _mm_load_si128(src1++);
	__m128i in2 = _mm_load_si128(src2++);

	// Interlace the two input words and process the
	// LO part
	__m128i in1Lo = _mm_shuffle_epi8(in1, shuffleLo1);
	__m128i in2Lo = _mm_shuffle_epi8(in2, shuffleLo2);
	__m128i inLo = _mm_or_si128(in1Lo, in2Lo);

	// Calculate a 16-bit intermediate result
	__m128i resLo = _mm_maddubs_epi16(inLo, fac);

	// Scale the result down to a 8-bit range
	resLo = _mm_srai_epi16(resLo, TEMPL_SCALE_FACTOR_LOG);

	// Interlace the two input words and process the
	// HI part
	__m128i in1Hi = _mm_shuffle_epi8(in1, shuffleHi1);
	__m128i in2Hi = _mm_shuffle_epi8(in2, shuffleHi2);
	__m128i inHi = _mm_or_si128(in1Hi, in2Hi);

	// Calculate a 16-bit intermediate result
	__m128i resHi = _mm_maddubs_epi16(inHi, fac);

	// Interlace the 8x16-bit words and store the
	// result
	__m128i res = _mm_packus_epi16(resLo, resHi);
	_mm_store_si128(tar++, res);
}

