    include "msx-constants.asm"
    include "sound-constants.asm"


KEY_WEAPON_BIT: equ 0
KEY_JUMP_BIT: equ 1
KEY_INVENTORY_BIT: equ 2
KEY_INTERACT_BIT: equ 3
KEY_LEFT_BIT: equ 4
KEY_UP_BIT: equ 5
KEY_DOWN_BIT: equ 6
KEY_RIGHT_BIT: equ 7


MAX_SPRITES: equ 32
FIRST_OBJECT_SPRITE: equ 3  ; 0, 1 are the player, 2 is player weapon

MAX_ROOM_OBJECTS: equ 16
MAX_ROOM_PLAYER_BULLETS: equ 8
MAX_ROOM_TILE_OBJECTS: equ 10
MAX_ROOM_SIZE: equ 32*24*4
MAX_INTERAREA_CONNECTIONS: equ 12

ROOM_REDRAW_FLAG_BIT: equ 0
HUD_REDRAW_FLAG_BIT: equ 1
COINS_REDRAW_FLAG_BIT: equ 2
WEAPON_REDRAW_FLAG_BIT: equ 3  ; weapon and ammo

HUD_MAX_TIME: equ 100

CHUNK_WIDTH: equ 16
CHUNK_HEIGHT: equ 12
MAX_CHUNK_LOCATIONS: equ 12
CHUNK_SIZE: equ CHUNK_WIDTH * CHUNK_HEIGHT + MAX_CHUNK_LOCATIONS * 5
CHUNK_FLAG_BOSS_MASK: equ #01

PCG_DIRECTION_LEFT: equ 8
PCG_DIRECTION_UP: equ 4
PCG_DIRECTION_RIGHT: equ 2
PCG_DIRECTION_DOWN: equ 1

PCG_DIRECTION_LEFT_BIT: equ 3
PCG_DIRECTION_UP_BIT: equ 2
PCG_DIRECTION_RIGHT_BIT: equ 1
PCG_DIRECTION_DOWN_BIT: equ 0

INTERAREA_CONNECTION_SIZE: equ 8  ; id1, id2, x1, y1, direction1, x2, y2, direction2


MAX_WORLD_AREAS: equ 10
MAX_AREA_WIDTH: equ 16  
MAX_AREA_SIZE: equ 8 * 8  ; as long as width * height is smaller or equal to 8 * 8, we are fine
MAX_AREA_N_TAGS: equ 32
MAX_AREA_N_OBJECTS: equ 40  ; some tags might spawn two objects (door + lock)
WORLD_AREA__SIZE: equ 4 + 1 + 1 + 1 + MAX_AREA_SIZE * 2 + MAX_AREA_N_TAGS * 3
WORLD_AREA__CONNECTIONS_OFFSET: equ 4 + 1 + 1 + 1
WORLD_AREA__DIVISION_IDS_OFFSET: equ WORLD_AREA__CONNECTIONS_OFFSET + MAX_AREA_SIZE
WORLD_AREA__TAGS_OFFSET equ WORLD_AREA__DIVISION_IDS_OFFSET + MAX_AREA_SIZE  ; each tag is 3 bytes: tag, location (x+y*width), lockDirection

AREA_OBJECT_STRUCT_SIZE: equ 4
AREA_OBJECT_STRUCT_TYPE: equ 0
AREA_OBJECT_STRUCT_OFFSET: equ 1
AREA_OBJECT_STRUCT_ID: equ 2  ; these are area-relative. So, to globally identify an object, we need (area, ID)
AREA_OBJECT_STRUCT_EXTRA: equ 3

SPRITE_OBJECT_TYPE_NONE: equ 0
SPRITE_OBJECT_TYPE_WATER_SPLASH: equ 1
SPRITE_OBJECT_TYPE_BLOCK_DUST: equ 2
SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE: equ 3
SPRITE_OBJECT_TYPE_PLAYER_BULLET_DART: equ 4
SPRITE_OBJECT_TYPE_PLAYER_BULLET_SPEAR: equ 5
SPRITE_OBJECT_TYPE_PLAYER_BULLET_RAY: equ 6
SPRITE_OBJECT_TYPE_EXPLOSION: equ 7

ROOM_OBJECT_STRUCT_SIZE: equ 9
ROOM_OBJECT_STRUCT_TYPE: equ 0
ROOM_OBJECT_STRUCT_PIXEL_X: equ 1
ROOM_OBJECT_STRUCT_TILE_X: equ 2
ROOM_OBJECT_STRUCT_PIXEL_Y: equ 3
ROOM_OBJECT_STRUCT_TILE_Y: equ 4
ROOM_OBJECT_STRUCT_STATE: equ 5
ROOM_OBJECT_STRUCT_SPEED_X: equ 6
ROOM_OBJECT_STRUCT_SPEED_Y: equ 7
ROOM_OBJECT_STRUCT_HIT_ID: equ 8  ; used by player bullets only, to avoid multi-hit

ROOM_TILE_OBJECT_STRUCT_SIZE: equ 12
ROOM_TILE_OBJECT_STRUCT_ID: equ 0
ROOM_TILE_OBJECT_STRUCT_TYPE: equ 1
ROOM_TILE_OBJECT_STRUCT_X: equ 2  ; tile resolution
ROOM_TILE_OBJECT_STRUCT_Y: equ 3
ROOM_TILE_OBJECT_STRUCT_STATE: equ 4  ; for breakable walls, these are the remaining hit points
ROOM_TILE_OBJECT_STRUCT_BACKGROUND: equ 5  ; 4 bytes
ROOM_TILE_OBJECT_STRUCT_WIDTH: equ 9  ; only used by breakable walls
ROOM_TILE_OBJECT_STRUCT_HEIGHT: equ 10  ; only used by breakable walls
ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID: equ 11  ; only used by breakable walls

PLAYER_COLLISION_UP_LEEWAY: equ 3  ; collision box height will be 16 - PLAYER_COLLISION_UP_LEEWAY
PLAYER_COLLISION_WIDTH: equ 4
PLAYER_MAX_SWIMMING_INERTIA_TIME: equ 8
PLAYER_PIXEL_X_ON_LADDER: equ 6
PLAYER_PUSHING_TIME: equ 32

PLAYER_MAX_HEALTH: equ 10*4
PLAYER_INITIAL_MAX_HEALTH: equ 8
PLAYER_IMMUNITY_TIME: equ 48
PLAYER_MAX_OXYGEN: equ 16

PLAYER_STATE_IDLE: equ 0
PLAYER_STATE_WALKING: equ 2
PLAYER_STATE_FALLING: equ 4
PLAYER_STATE_JUMPING: equ 6
PLAYER_STATE_CROUCHING: equ 8
PLAYER_STATE_CRAWLING: equ 10
PLAYER_STATE_ROPE: equ 12
PLAYER_STATE_LADDER: equ 14
PLAYER_STATE_SWIMMING: equ 16
PLAYER_STATE_WEAPON_SWING: equ 18
PLAYER_STATE_WEAPON_SWING_JUMPING: equ 20
PLAYER_STATE_WEAPON_SWING_FALLING: equ 22
PLAYER_STATE_WEAPON_SWING_CROUCHING: equ 24
PLAYER_STATE_DIRECTIONAL_WEAPON: equ 26
PLAYER_STATE_DIRECTIONAL_WEAPON_JUMPING: equ 28
PLAYER_STATE_DIRECTIONAL_WEAPON_FALLING: equ 30
PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING: equ 32
PLAYER_STATE_HURT: equ 34
PLAYER_STATE_DEAD: equ 36

PLAYER_WEAPON_SWING_MACHETE_FORWARD: equ 0
PLAYER_WEAPON_SWING_MACHETE_UP: equ 1
PLAYER_WEAPON_SWING_MACHETE_CROUCHING: equ 2
PLAYER_WEAPON_SWING_MACHETE_DOWN: equ 3
PLAYER_WEAPON_SWING_HAMMER1: equ 4  ; 3 frame animation
PLAYER_WEAPON_SWING_HAMMER2: equ 5
PLAYER_WEAPON_SWING_HAMMER3: equ 6
PLAYER_WEAPON_SWING_MACUAHUITL1: equ 7  ; 2 frame animation
PLAYER_WEAPON_SWING_MACUAHUITL2: equ 8
PLAYER_WEAPON_SHIELD_FORWARD: equ 9
PLAYER_WEAPON_SHIELD_UP: equ 10
PLAYER_WEAPON_SHIELD_CROUCHING: equ 11
PLAYER_WEAPON_DIRECTIONAL_FW: equ 12
PLAYER_WEAPON_DIRECTIONAL_FW_UP: equ 13
PLAYER_WEAPON_DIRECTIONAL_UP: equ 14

STONE_DAMAGE: equ 1
DART_DAMAGE: equ 1
SPEAR_DAMAGE: equ 2
RAYGUN_DAMAGE: equ 2


; - 7 boss keys
; - 7 boss idols
; - 6 color keys
; - 4 key items (clay doll, gear, ball, idol)
; - 6 mayan upgrade items (sandals, etc.)
; - 2 alien upgrade items
; - 3 elaine letters
; - 1 map
N_INVENTORY_ITEM_TYPES: equ 7 + 7 + 6 + 4 + 6 + 2 + 3 + 1
N_INVENTORY_WEAPON_TYPES: equ 4 + 4 + 3  ; 4 base, 4 ranged, 3 upgrades

; - initial piece just has: jungle + first pyramid, then one piece for each of the rest
N_MAP_PIECES: equ 9

;-----------------------------------------------
; PCG tags: (autogenerated, do not change manually)
TAG_NONE: equ 0
TAG_BLOCK_PUZZLE1: equ 1
TAG_BLOCK_PUZZLE2: equ 2
TAG_BLOCK_PUZZLE3: equ 3
TAG_BLOCK_PUZZLE4: equ 4
TAG_BUTTON_DOOR1: equ 5
TAG_BUTTON_DOOR2: equ 6
TAG_BUTTON_DOOR3: equ 7
TAG_BUTTON_DOOR4: equ 8
TAG_BREAKABLE_WALL1: equ 9  ; all breakable walls are this type when instantiated in a room
TAG_BREAKABLE_WALL2: equ 10
TAG_BREAKABLE_WALL3: equ 11
TAG_BREAKABLE_WALL4: equ 12
TAG_RED_LOCK: equ 13
TAG_GREEN_LOCK: equ 14
TAG_BLUE_LOCK: equ 15
TAG_YELLOW_LOCK: equ 16
TAG_WHITE_LOCK: equ 17
TAG_PURPLE_LOCK: equ 18
TAG_TRIAL1_LOCK: equ 19
TAG_TRIAL2_LOCK: equ 20
TAG_TRIAL3_LOCK: equ 21
TAG_TRIAL4_LOCK: equ 22
TAG_COMBINATION1_LOCK: equ 23  ; spawn a door (and a special combination chunk)
TAG_COMBINATION2_LOCK: equ 24
TAG_COMBINATION3_LOCK: equ 25
TAG_COMBINATION4_LOCK: equ 26
TAG_BALL_LOCK: equ 27
TAG_IDOL_LOCK: equ 28
TAG_GEAR_LOCK: equ 29
TAG_ASTRONAUT_LOCK: equ 30
TAG_START: equ 31
TAG_ENDING: equ 32
TAG_MIDPOINT: equ 33
TAG_BUTTON1: equ 34
TAG_BUTTON2: equ 35
TAG_BUTTON3: equ 36
TAG_BUTTON4: equ 37
TAG_BREAKABLE_WALL1_KEY: equ 38
TAG_BREAKABLE_WALL2_KEY: equ 39
TAG_BREAKABLE_WALL3_KEY: equ 40
TAG_BREAKABLE_WALL4_KEY: equ 41
TAG_BLOCK_PUZZLE_KEY1: equ 42
TAG_BLOCK_PUZZLE_KEY2: equ 43
TAG_BLOCK_PUZZLE_KEY3: equ 44
TAG_BLOCK_PUZZLE_KEY4: equ 45
TAG_RED_KEY: equ 46
TAG_GREEN_KEY: equ 47
TAG_BLUE_KEY: equ 48
TAG_YELLOW_KEY: equ 49
TAG_WHITE_KEY: equ 50
TAG_PURPLE_KEY: equ 51
TAG_RED_CHEST: equ 52
TAG_GREEN_CHEST: equ 53
TAG_BLUE_CHEST: equ 54
TAG_YELLOW_CHEST: equ 55
TAG_WHITE_CHEST: equ 56
TAG_PURPLE_CHEST: equ 57
TAG_TRIAL1_CLUE: equ 58
TAG_TRIAL2_CLUE: equ 59
TAG_TRIAL3_CLUE: equ 60
TAG_TRIAL4_CLUE: equ 61
TAG_COMBINATION1_CLUE: equ 62
TAG_COMBINATION2_CLUE: equ 63
TAG_COMBINATION3_CLUE: equ 64
TAG_COMBINATION4_CLUE: equ 65
TAG_BALL_KEY: equ 66
TAG_IDOL_KEY: equ 67
TAG_GEAR_KEY: equ 68
TAG_ASTRONAUT_KEY: equ 69
TAG_BOSS1: equ 70
TAG_BOSS1_KEY: equ 71
TAG_BOSS1_CHESTLOCK: equ 72
TAG_BOSS2: equ 73
TAG_BOSS2_KEY: equ 74
TAG_BOSS2_CHESTLOCK: equ 75
TAG_BOSS3: equ 76
TAG_BOSS3_KEY: equ 77
TAG_BOSS3_CHESTLOCK: equ 78
TAG_BOSS4: equ 79
TAG_BOSS4_KEY: equ 80
TAG_BOSS4_CHESTLOCK: equ 81
TAG_BOSS5: equ 82
TAG_BOSS5_KEY: equ 83
TAG_BOSS5_CHESTLOCK: equ 84
TAG_BOSS6: equ 85
TAG_BOSS6_KEY: equ 86
TAG_BOSS6_CHESTLOCK: equ 87
TAG_BOSS7: equ 88
TAG_BOSS7_KEY: equ 89
TAG_BOSS7_CHESTLOCK: equ 90
; tags above can ONLY appear once in the whole game
N_UNIQUE_TAGS: equ 91
; tags below can appear multiple times (and do not have state, they are reset every time you enter in a room):
TAG_PUSHABLE_BLOCK: equ 91

N_PATH_OPENING_TAGS: equ 32  ; there are less than this, but just in case (this is the number of tags above that spawn a breakable wall or door).


; auto generated, do not edit manually:
    include "autogenerated/chunk-constants.asm"

CHUNK_LOCATION_ITEM_MASK: equ #0001
CHUNK_LOCATION_BIG_ITEM_MASK: equ #0002
CHUNK_LOCATION_4X4_ITEM_MASK: equ #0004
CHUNK_LOCATION_BREAKABLE_LEFT_MASK: equ #0008
CHUNK_LOCATION_BREAKABLE_UP_MASK: equ #0010
CHUNK_LOCATION_BREAKABLE_RIGHT_MASK: equ #0020
CHUNK_LOCATION_BREAKABLE_DOWN_MASK: equ #0040
CHUNK_LOCATION_DOOR_LEFT_MASK: equ #0080
CHUNK_LOCATION_DOOR_UP_MASK: equ #0100
CHUNK_LOCATION_DOOR_RIGHT_MASK: equ #0200
CHUNK_LOCATION_DOOR_DOWN_MASK: equ #0400
CHUNK_LOCATION_PUSHABLE_BLOCK_MASK: equ #0800

CHUNK_LOCATION_ITEM: equ 1
CHUNK_LOCATION_BIG_ITEM: equ 2
CHUNK_LOCATION_4X4_ITEM: equ 3
CHUNK_LOCATION_BREAKABLE_LEFT: equ 4
CHUNK_LOCATION_BREAKABLE_UP: equ 5
CHUNK_LOCATION_BREAKABLE_RIGHT: equ 6
CHUNK_LOCATION_BREAKABLE_DOWN: equ 7
CHUNK_LOCATION_DOOR_LEFT: equ 8
CHUNK_LOCATION_DOOR_UP: equ 9
CHUNK_LOCATION_DOOR_RIGHT: equ 10
CHUNK_LOCATION_DOOR_DOWN: equ 11
CHUNK_LOCATION_PUSHABLE_BLOCK: equ 12


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

