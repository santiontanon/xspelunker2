    include "msx-constants.asm"
    include "sound-constants.asm"


MAX_SPRITES: equ 32
FIRST_OBJECT_SPRITE: equ 2  ; 0, 1 are the player

MAX_ROOM_OBJECTS: equ 16
MAX_ROOM_SIZE: equ 32*24*4

CHUNK_WIDTH: equ 16
CHUNK_HEIGHT: equ 12
MAX_CHUNK_LOCATIONS: equ 12
CHUNK_SIZE: equ CHUNK_WIDTH * CHUNK_HEIGHT + MAX_CHUNK_LOCATIONS * 5


CHUNK_FLAG_BOSS_MASK: equ #01


MAX_AREA_WIDTH: equ 10
MAX_AREA_HEIGHT: equ 10


PLAYER_COLLISION_UP_LEEWAY: equ 3  ; collision box height will be 16 - PLAYER_COLLISION_UP_LEEWAY
PLAYER_COLLISION_WIDTH: equ 4
PLAYER_MAX_SWIMMING_INERTIA_TIME: equ 8

PLAYER_STATE_IDLE: equ 0
PLAYER_STATE_WALKING: equ 2
PLAYER_STATE_FALLING: equ 4
PLAYER_STATE_JUMPING: equ 6
PLAYER_STATE_CROUCH: equ 8
PLAYER_STATE_CRAWLING: equ 10
PLAYER_STATE_ROPE: equ 12
PLAYER_STATE_LADDER: equ 14
PLAYER_STATE_SWIMMING: equ 16


SPRITE_OBJECT_TYPE_NONE: equ 0
SPRITE_OBJECT_TYPE_WATER_SPLASH: equ 1


ROOM_OBJECT_STRUCT_SIZE: equ 8
ROOM_OBJECT_STRUCT_TYPE: equ 0
ROOM_OBJECT_STRUCT_TILE_X: equ 1
ROOM_OBJECT_STRUCT_PIXEL_X: equ 2
ROOM_OBJECT_STRUCT_TILE_Y: equ 3
ROOM_OBJECT_STRUCT_PIXEL_Y: equ 4
ROOM_OBJECT_STRUCT_STATE: equ 5
; ...: 6, 7 unused


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

