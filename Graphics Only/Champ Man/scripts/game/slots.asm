SLOTS: {



	//Columns:	.byte 7, 10, 17, 20, 27, 30, 34, 37, 27, 30,  17, 20, 7, 10, 0, 3, 12, 15, 18, 21, 24
	//Rows:		.byte 0, 0, 0, 0, 0, 0, 10, 10,  21, 21, 21, 21, 21, 21, 10, 10, 10, 10, 10, 10, 10, 10

	Columns:	.byte 7, 17, 27, 34, 27, 17, 7, 0
				.byte 10, 20, 30, 37, 30, 20, 10, 3
				.byte 12, 15, 18, 21, 24

	Rows:		.byte 0, 0, 0, 10, 21, 21, 21, 10
				.byte 0, 0, 0, 10, 21, 21, 21, 10
				.byte 10, 10, 10, 10, 10


	Shown:		.byte 1, 0, 0, 0, 0, 0, 0, 0
				.byte 1, 0, 0, 0, 0, 0, 0, 0
				.byte 1, 1, 1, 1, 1

	XPosLSB:	.fill 29, 26 + (i * 8)
				.fill 11, i * 8
	XPosMSB:	.fill 29, 0
				.fill 11, 1
	YPos:		.fill 25, 52 + (i * 8)


	NextSlotID:	.byte 0

	

}