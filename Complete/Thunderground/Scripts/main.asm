//exomizer sfx sys -t 64 -x "inc $d020" -o yakf.exo yakf.prg

.var sid = LoadSid("../assets/sfx/blank.sid")

MAIN: {

	#import "data/zeropage.asm"

	BasicUpstart2(Entry)

	*=$1000 "Modules"

	#import "data/labels.asm"
	#import "data/vic.asm"
	#import "game/system/irq.asm"
	#import "common/utility.asm"
	#import "common/macros.asm"
	#import "common/input.asm"
	
	#import "common/maploader.asm"
	#import "common/plot.asm"
	#import "common/random.asm"
	#import "game/system/score.asm"
	//#import "game/system/sound.asm"

	* = $2000

	#import "game/gameplay/player.asm"
	#import "game/gameplay/bases.asm"
	#import "game/gameplay/bullet.asm"
	#import "game/gameplay/level.asm"
	#import "game/gameplay/lives.asm"

	
	

	* = $8000

	#import "game/gameplay/bomb.asm"
	#import "game/gameplay/token.asm"
	#import "game/gameplay/enemy.asm"
	#import "game/system/title.asm"
	#import "common/sfx.asm"	

	// sega sonic bros
	// freeze atari
	// qwak


	

	* = * "Main"

	PerformFrameCodeFlag:	.byte FALSE
	GameIsOver:				.byte FALSE
	GameActive: 			.byte FALSE
	MachineType: 			.byte PAL

	GameMode:				.byte 0
	GameOverTimer:			.byte 30

	Entry: {


		jsr IRQ.DisableCIA
		jsr UTILITY.BankOutKernalAndBasic


		lda #GAME_MODE_TITLE
		sta GameMode

		lda #0
		jsr sid.init
		jsr set_sfx_routine
		jsr RANDOM.init
		
		jsr IRQ.SetupInterrupts

		jsr SetGameColours
		jsr SetupVIC

		//jsr $3000
		

		jmp TitleScreen

		jmp InitialiseGame

	}



	TitleScreen: {


		lda #GAME_MODE_TITLE
		sta GameMode

		lda #0
		sta GameActive
		
		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2

 		jsr SetGameColours

 		lda #GREEN
		sta VIC.BACKGROUND_COLOR
		sta LEVEL.TopColour

		lda #RED
		sta VIC.EXTENDED_BG_COLOR_1


 		lda #2
 		sta MAPLOADER.CurrentMapID

 		jsr MAPLOADER.DrawMap

		jsr LEVEL.DrawNumber
		jsr SCORE.NewLevel


		lda #0
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y

		lda #1
		sta GameActive

		jmp Loop


	}





	ResetGame: {

		lda #0
		sta GameActive
		
		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2

 		jsr SetGameColours

		//jsr UTILITY.ClearScreen

		jsr LEVEL.Reset
		jsr LoadScreen	

		jsr SCORE.Reset
		jsr LIVES.Initialise
		jsr PLAYER.Initialise
		jsr BASES.Initialise
		jsr ENEMY.NewGame
		jsr BOMB.NewLevel
		jsr BULLET.NewLevel
		
	
		lda #GAME_MODE_PLAY
		sta GameMode

		lda #255
		sta VIC.SPRITE_ENABLE

		lda #0
		sta VIC.SPRITE_0_Y
		sta VIC.SPRITE_1_Y
		sta VIC.SPRITE_2_Y
		sta VIC.SPRITE_3_Y
		sta VIC.SPRITE_4_Y
		sta VIC.SPRITE_5_Y
		sta VIC.SPRITE_6_Y
		sta VIC.SPRITE_7_Y

		lda #1
		sta GameActive



		rts

	}

	


	InitialiseGame: {
		
		jsr ResetGame



		jmp Loop

	}



	LoadScreen: {

		lda LEVEL.CurrentMap
		sta MAPLOADER.CurrentMapID

		jsr MAPLOADER.DrawMap
		jsr LEVEL.DrawNumber
		jsr SCORE.NewLevel

		rts
	}


	NextLevel: {


		lda #0
		sta GameActive

		jsr LoadScreen

		jsr PLAYER.Initialise
		jsr BASES.Initialise
		jsr LEVEL.NewLevel
		jsr ENEMY.NewLevel
		jsr BOMB.NewLevel
		jsr BULLET.NewLevel



		lda #1
		sta GameActive



		rts
	}

	SetupVIC: {

		//lda #0
		//sta $bfff

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

		lda #%00000000
		sta VIC.SPRITE_MULTICOLOR


	SwitchOnMulticolourMode:

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2


		rts
	}

	// traffic speeds
	// sounds
	  
	SetGameColours: {

		lda #BLACK
		sta VIC.BACKGROUND_COLOR

		lda #BLACK
		sta VIC.BORDER_COLOR

		lda #ORANGE
		sta VIC.SPRITE_MULTICOLOR_1

		lda #BROWN
		sta VIC.EXTENDED_BG_COLOR_1
		
	 	lda #ORANGE
	 	sta VIC.EXTENDED_BG_COLOR_2

	 	lda #LIGHT_GRAY
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


		lda GameActive
		beq GamePaused

		lda GameMode
		cmp #GAME_MODE_PLAY
		beq Playing

		cmp #GAME_MODE_INTERSTITION
		beq Inter

		cmp #GAME_MODE_BURP
		beq Burp

		cmp #GAME_MODE_CLOSED
		beq Closed

		cmp #GAME_MODE_OVER
		beq GameOver

		cmp #GAME_MODE_TITLE
		beq TitleScreen2

		TitleScreen2:

			lda GameOverTimer
			beq ReadyTitle

			dec GameOverTimer
			jmp NoFire

			ReadyTitle:

			ldy #1
			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq NoFire

			//jsr SOUND.Tick

			lda #120
			sta GameOverTimer

			jmp InitialiseGame

		NoFire:
				
			jsr TITLE.FrameUpdate
			jmp Loop


		Inter:

			
			jmp Loop

		Burp:

		
			jmp Loop


		Closed:
			jmp Loop


		Playing:	

			//inc $d020
			jsr BASES.FrameUpdate
			jsr PLAYER.FrameUpdate
			jsr BULLET.FrameUpdate
			jsr LEVEL.FrameUpdate
			jsr ENEMY.FrameUpdate
			jsr BOMB.FrameUpdate
		

			
		
		//	dec $d020

			jmp Loop

		PreStage:

		
			jmp Loop

		GameOver:

			lda GameOverTimer
			beq Ready

			dec GameOverTimer
			jmp Loop

			Ready:

			lda #30
			sta GameOverTimer

			jmp TitleScreen


		GamePaused:

			jmp Loop

	}	
 
}

// Our bullets to enemies
// Their bullets to each other
// Their bullets to us
// Them to us

#import "data/assets.asm"