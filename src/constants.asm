    include "msx-constants.asm"
;     include "sound-constants.asm"


MAX_ROOM_OBJECTS: equ 16

ROOM_OBJECT_STRUCT_SIZE: equ 4
ROOM_OBJECT_STRUCT_TYPE: equ 0
ROOM_OBJECT_STRUCT_X: equ 1
ROOM_OBJECT_STRUCT_Y: equ 2


;-----------------------------------------------
; - This macro changes which page is mapped to #4000 - 7fff
SETMEGAROMPAGE_4000:    MACRO ?p1
IF ?p1 == 0
    xor a
ELSE
    ld a, ?p1
ENDIF
    di
    ld (current_megarom_page_in_4000), a
rom_mapper_page_to_update_4000:
    ld (#6000), a
    ei
    ENDM


SETMEGAROMPAGE_4000_PRESERVE_FLAGS:    MACRO ?p1
    ld a, ?p1
    di
    ld (current_megarom_page_in_4000), a
rom_mapper_page_to_update_4000:
    ld (#6000), a
    ei
    ENDM


;-----------------------------------------------
; - This macro changes which page is mapped to #4000 - 7fff
SETMEGAROMPAGE_4000_A:    MACRO
    di
    ld (current_megarom_page_in_4000), a
rom_mapper_page_to_update_4000:
    ld (#6000), a
    ei
    ENDM


;-----------------------------------------------
; - This macro changes which page is mapped to #4000 - 7fff
SETMEGAROMPAGE_4000_A_WITHOUT_TRACKING:    MACRO
rom_mapper_page_to_update_4000:
    ld (#6000), a
    ENDM


;-----------------------------------------------
; - This macro changes which page is mapped to #8000 - bfff
SETMEGAROMPAGE_8000:    MACRO ?p1
IF ?p1 == 0
    xor a
ELSE
    ld a, ?p1
ENDIF
    di
    ld (current_megarom_page_in_8000), a
rom_mapper_page_to_update_8000:
    ld (#7000), a
    ei
    ENDM

;-----------------------------------------------
; - This macro changes which page is mapped to #8000 - bfff
SETMEGAROMPAGE_8000_WITHOUT_TRACKING:    MACRO ?p1
IF ?p1 == 0
    xor a
ELSE
    ld a, ?p1
ENDIF
rom_mapper_page_to_update_8000:
    ld (#7000), a
    ENDM


;-----------------------------------------------
; - This macro changes which page is mapped to #8000 - bfff
SETMEGAROMPAGE_8000_A:    MACRO
    di
    ld (current_megarom_page_in_8000), a
rom_mapper_page_to_update_8000:    
    ld (#7000), a
    ei
    ENDM


;-----------------------------------------------
; - This macro changes which page is mapped to #8000 - bfff
SETMEGAROMPAGE_8000_A_WITHOUT_TRACKING:    MACRO
rom_mapper_page_to_update_8000:
    ld (#7000), a
    ENDM

