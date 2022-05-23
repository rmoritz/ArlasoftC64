  //exomizer sfx sys -t 64 -x "inc $d020" -o yakf.exo yakf.prg

  //exomizer sfx sys -t 64 -x "lda #14 sta $d021 inc $d020" -o galaga.prg bin/main.prg

//.var sid = LoadSid("../assets/goattracker/blank.sid")

MAIN: {

	#import "data/zeropage.asm"

	BasicUpstart2(Entry)

	*=$880 "Modules"

	#import "data/labels.asm"
	#import "data/vic.asm"
	#import "game/system/irq.asm"
	#import "common/utility.asm"
	#import "common/macros.asm"
	#import "common/input.asm"

	#import "common/maploader.asm"
	#import "common/random.asm"
	#import "common/plot.asm"
	#import "common/sfx.asm"

	#import "game/gameplay/glob.asm"
	

	* = * "Main"

	GameActive: 			.byte FALSE
	PerformFrameCodeFlag:	.byte FALSE
	GameIsOver:				.byte FALSE
	MachineType: 			.byte PAL

	GameMode:				.byte 0
	
	Entry: {

		lda $2A6
		sta MachineType

		jsr IRQ.DisableCIA

		jsr UTILITY.BankOutKernalAndBasic

		lda #SUBTUNE_BLANK
		//jsr sid.init

		jsr set_sfx_routine
		jsr RANDOM.init
		jsr IRQ.SetupInterrupts
		jsr SetGameColours	
		jsr SetupVIC
		jsr SetupRestoreKey

		lda #1
		sta GameIsOver

		
		jmp InitialiseGame

	}

	

	SetupRestoreKey: {

		lda #<nmi
		sta $fffa
		lda #>nmi
		sta $fffb

		rts
	}


	Unpause: {

		inc GameActive

		ldy #BLACK
		sty $d020

	

		rts
	}


	nmi: {

		:StoreState()

		
			lda GameMode
			cmp #GAME_MODE_PLAY
			beq CanPause


			jmp Exit

		CanPause:

			lda GameActive
			bne Pause

			jsr Unpause
		
			jmp Exit

		Pause:

			lda #0
			sta $D418

			lda #PURPLE
			//sta $d020

			lda #23
			sta TextRow

			lda #7
			sta TextColumn

			ldx #GREEN
			

			dec GameActive
	
		

		Exit:

		:RestoreState()

		rti
	}


	


	ResetGame: {

		lda #0
		sta GameActive
		sta $d020
		
		lda #0
		sta MAPLOADER.CurrentMapID

		jsr MAPLOADER.DrawMap

		jsr GLOB.Initialise

		lda #1
		sta GameActive

		lda #ALL_ON
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR

		lda #GAME_MODE_PLAY
		sta GameMode
		
		
		rts

	}


	InitialiseGame: {
		
		jsr ResetGame

		jmp Loop

	}


	SetupVIC: {

		lda #0
		sta $bfff

		lda #ALL_ON
		sta VIC.SPRITE_ENABLE

		lda #%00001100
		sta VIC.MEMORY_SETUP

		//Set VIC BANK 3, last two bits = 00
		lda VIC.BANK_SELECT
		and #%11111100
		//ora #%00000001
		sta VIC.BANK_SELECT

		lda #%00000000
		sta VIC.SPRITE_PRIORITY


	SwitchOnMulticolourMode:

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2


		rts
	}

	SetGameColours: {

		lda #BLACK
		sta VIC.BACKGROUND_COLOR

		lda #BLACK
		sta VIC.BORDER_COLOR
		sta VIC.SPRITE_MULTICOLOR_1

		lda #ORANGE
		sta VIC.EXTENDED_BG_COLOR_1


	 	lda #WHITE
	 	sta VIC.EXTENDED_BG_COLOR_2

	 	lda #WHITE
	 	sta VIC.SPRITE_MULTICOLOR_2

		rts

	}



	Loop: {

		lda PerformFrameCodeFlag
		beq Loop

		jmp FrameCode

	}




	FrameCode: {

		lda #0
		sta PerformFrameCodeFlag

		
	IsActive:

		lda GameMode
		cmp #GAME_MODE_PLAY
		beq Playing
		
		Playing:	

			lda IRQ.SidTimer
			bmi DoPalMode

		DoNTSCMode:

			lda IRQ.SidTimer
			cmp #1
			beq Skip

			jmp DoPalMode

			inc $d020


			dec $d020
		
		Skip:

			//lda IRQ.SidTimer
			//cmp #1
			//bne DoMore


			jmp Loop
			
		DoMore:

		DoPalMode:

			jsr GLOB.FrameUpdate

			jmp Loop

	}	

	
 
}


	//#import "game/system/sampler.asm"	
	#import "data/assets.asm"

