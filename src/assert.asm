
;-----------------------------------------------
ASSERT_NEVER_EXECUTED: macro
IF DEBUG == 1
	di
	halt
ENDIF
	endm


;-----------------------------------------------
ASSERT_A_LT: macro value
IF DEBUG == 1
	push af
		cp value
		jr c, ASSERT_HL_INDIRECT_LT_OK
		; assertion failed!
		di
		halt
ASSERT_HL_INDIRECT_LT_OK:
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_B_NOT_EQ: macro value
IF DEBUG == 1
	push af
		ld a, b
		cp value
		jr nz, ASSERT_B_NOT_EQ_OK
		; assertion failed!
		di
		halt
ASSERT_B_NOT_EQ_OK:
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_SP_EQ: macro value
IF DEBUG == 1
	push af
	push bc
	push hl
		ld hl, 0
		add hl, sp
		ld bc, value - 6  ; "- 6" since we just pushed 3 registers
		or a
		sbc hl, bc
		jr z, ASSERT_SP_EQ_OK
		; assertion failed!
		di
		halt
ASSERT_SP_EQ_OK:
	pop hl
	pop bc
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_HL_LEQ: macro value
IF DEBUG == 1	
	push af
	push bc
	push hl
	    or a
	    ld bc, value
	    sbc hl, bc
		jp c, ASSERT_HL_LEQ_OK
		; assertion failed!
		di
		halt
ASSERT_HL_LEQ_OK:
	pop hl
	pop bc
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_IX_LEQ: macro value
IF DEBUG == 1	
	push af
	push bc
	push hl
		push ix
		pop hl
	    or a
	    ld bc, value
	    sbc hl, bc
		jp c, ASSERT_IX_LEQ_OK
		; assertion failed!
		di
		halt
ASSERT_IX_LEQ_OK:
	pop hl
	pop bc
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_IY_LEQ: macro value
IF DEBUG == 1	
	push af
	push bc
	push hl
		push iy
		pop hl
	    or a
	    ld bc, value
	    sbc hl, bc
		jp c, ASSERT_IY_LEQ_OK
		; assertion failed!
		di
		halt
ASSERT_IY_LEQ_OK:
	pop hl
	pop bc
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_HL_INDIRECT_LT: macro value
IF DEBUG == 1
	push af
		ld a, (hl)
		cp value
		jr c, ASSERT_HL_INDIRECT_LT_OK
		; assertion failed!
		di
		halt
ASSERT_HL_INDIRECT_LT_OK:
	pop af
ENDIF
	endm


;-----------------------------------------------
ASSERT_BC_ABS_LEQ: macro value
IF DEBUG == 1
	push af
	push bc
	push hl
		bit 7, b
		jr nz, ASSERT_BC_ABS_LEQ_NEGATIVE
ASSERT_BC_ABS_LEQ_POSIVITE:
		ld h, b
		ld l, c
		ld bc, value
		or a
		sbc hl, bc
		jr c, ASSERT_BC_ABS_LEQ_END
		jr z, ASSERT_BC_ABS_LEQ_END
		; assertion failed!
		di
		halt
ASSERT_BC_ABS_LEQ_NEGATIVE:
		ld h, b
		ld l, c
		ld bc, value
		or a
		adc hl, bc
		jr c, ASSERT_BC_ABS_LEQ_END
		jr z, ASSERT_BC_ABS_LEQ_END
		; assertion failed!
		di
		halt
ASSERT_BC_ABS_LEQ_END:
	pop hl
	pop bc
	pop af
ENDIF
	endm


