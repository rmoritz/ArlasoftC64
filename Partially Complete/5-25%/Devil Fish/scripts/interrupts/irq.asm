
IRQ: {

	.label IRQControlRegister1 = $dc0d
	.label IRQControlRegister2 = $dd0d


	DisableCIA: {

		// prevent CIA interrupts now the kernal is banked out
		lda #$7f
		sta IRQControlRegister1
		sta IRQControlRegister2

		rts

	}


	SetupInterrupts: {

		sei 	// disable interrupt flag
		lda VIC.INTERRUPT_CONTROL
		ora #%00000001		// turn on raster interrupts
		sta VIC.INTERRUPT_CONTROL

		lda #<MainIRQ
		ldx #>MainIRQ
		ldy #250
		jsr SetNextInterrupt

		asl VIC.INTERRUPT_STATUS
		cli

		rts


	}



	SetNextInterrupt: {

		sta REGISTERS.RASTER_INTERRUPT_VECTOR
		stx REGISTERS.RASTER_INTERRUPT_VECTOR + 1
		sty VIC.RASTER_Y
		lda VIC.SCREEN_CONTROL
		and #%01111111		// don't use 255+
		sta VIC.SCREEN_CONTROL

		rts
	}



	MainIRQ: {

		

		:StoreState()

		//inc $d020

		

		ldy #2
		jsr INPUT.ReadJoystick


		inc ZP_COUNTER

		lda MAIN.GameActive
		beq Paused

		GameActive:

			jsr DOG.Update
			jsr SCORE.CheckScoreToAdd
			
			jmp Finish

		Paused:

		
		lda MAIN.GameOverTimer
		beq CheckFireButton

		dec MAIN.GameOverTimer

		CheckFireButton:

			ldy #1
			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq Finish

			jsr MAIN.ResetGame

		//dec $d020


		Finish:

		asl VIC.INTERRUPT_STATUS


		//lda #<BirdIRQ
		//ldx #>BirdIRQ
		//ldy #BirdRasterLine
		//jsr SetNextInterrupt

		:RestoreState()

		rti

	}

	





}