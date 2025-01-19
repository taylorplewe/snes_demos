	.macro a8
		sep #%00100000 ; a 8 bit
	.endmacro
	.macro a16
		rep #%00100000 ; a 16 bit
	.endmacro
	.macro i8
		sep #%00010000 ; x & y 8 bit
	.endmacro
	.macro i16
		rep #%00010000 ; x & y 16 bit
	.endmacro
	.macro asr
		.if .asize = 8
			.a8
			cmp #$80
			ror a
		.else
			.a16
			cmp #$8000
			ror a
		.endif
	.endmacro
	.macro mul num1, num2
		.if (.not .match({num1}, a))
			.if (.match({num1}, x))
				txa
			.elseif (.match({num1}, y))
				tya
			.else
				lda num1
			.endif
		.endif
		xba
		.if (.match({num2}, x))
			txa
		.elseif (.match({num2}, y))
			tya
		.else
			lda num2
		.endif
		jsr _mul
	.endmacro

	; dma/hdma
	.a8
	.i16
	.macro dma_set chan, reg, dmap, src, count
		.local CHANOFFS
		CHANOFFS = chan * $10

		lda #dmap
		sta DMAP0 +CHANOFFS
		ldx #.loword(src)
		stx A1T0L +CHANOFFS
		lda #^src
		sta A1B0 +CHANOFFS
		lda #<reg
		sta BBAD0 +CHANOFFS
		.ifnblank count
		ldx #count
		stx DAS0L +CHANOFFS
		.endif
	.endmacro
	.macro dma chan, reg, dmap, src, count
		dma_set chan, reg, dmap, src, count

		lda #1 << chan
		sta MDMAEN ; run it
	.endmacro
	.macro hdma chan, reg, dmap, src
		dma_set chan, reg, dmap, src

		lda #1 << chan
		sta HDMAEN ; run it
	.endmacro