    include "constants-msx.asm"
    include "sound-constants.asm"

COLLISION_DEBUG: equ 0
; COLLISION_DEBUG: equ 1  ; player
; COLLISION_DEBUG: equ 2  ; enemies


    include "constants-tags.asm"
FIRST_TILE_ENEMY_TAG: equ TAG_ENEMY_CARNIVORE_PLANT


KEY_WEAPON_BIT: equ 0
KEY_JUMP_BIT: equ 1
KEY_INVENTORY_BIT: equ 2
KEY_INTERACT_BIT: equ 3
KEY_LEFT_BIT: equ 4
KEY_UP_BIT: equ 5
KEY_DOWN_BIT: equ 6
KEY_RIGHT_BIT: equ 7


STORY_STATE__START: equ 0
STORY_STATE__ENTERED_RUINS: equ 1
STORY_STATE__FOUND_CALENDAR: equ 2
STORY_STATE__GOT_LETTER1: equ 3
STORY_STATE__CALENDAR_AFTER_LETTER1: equ 4
STORY_STATE__PLACED_FIRST_POWER_STONE: equ 5  ; first stone activates the teleporters
STORY_STATE__FOUND_LOST_VENDOR: equ 6
STORY_STATE__GOT_LETTER2: equ 7  ; where Elaine explains NOT to destroy the calendar stone
STORY_STATE__FIGHTING_ALIENS: equ 8  ; player defeated the first 5 bosses, and made it back to the calendar stone room, where he's ambushed by aliens
STORY_STATE__DEFEATED_ALIENS: equ 9  ; alien battle won (and Elaine is now permanently in the calendar room)


MAX_SPRITES: equ 32
FIRST_OBJECT_SPRITE: equ 3  ; 0, 1 are the player, 2 is player weapon
; The VDP can hold 64 16x16 sprite patterns, we will use them as follows:
; - 0, 1: player
; - 2: player weapon
; - 3 - 23: misc sprites (player bullets, splashes, explosion, etc.)
; - 24 - 63: enemies
FIRST_OBJECT_SPRITE_PATTERN: equ 3
FIRST_ENEMY_SPRITE_PATTERN: equ 24

ENEMY_RESPAWN_TABLE_SIZE: equ 4  ; size of hthe enemy respawn table (that remembers which enemies have already been killed)
MAX_ROOM_SPRITE_OBJECTS: equ 8  ; water splashes, etc. (decorations)
MAX_ROOM_PLAYER_BULLETS: equ 8
MAX_ROOM_SPRITE_ENEMIES: equ 12
MAX_ROOM_TILE_OBJECTS: equ 13  ; xibalba lords boss room needs 13 objects
MAX_ROOM_SIZE: equ 32*24*4
MAX_INTERAREA_CONNECTIONS: equ 12
MAX_CHESTS: equ 10
MAX_TABLETS: equ 21
MAX_SPECIAL_ROOMS_PER_AREA: equ 2

ROOM_REDRAW_FLAG_BIT: equ 0
HUD_REDRAW_FLAG_BIT: equ 1
COINS_REDRAW_FLAG_BIT: equ 2
WEAPON_REDRAW_FLAG_BIT: equ 3  ; weapon and ammo
AFTER_ROOOMREDRAW_CLEAR_MASK: equ #f0  ; to clear all the redraw flags, but not the ones below
REUPLOAD_INGAME_OBJECT_TILES_FLAG_BIT: equ 4
REUPLOAD_INGAME_OBJECT_TILES_FLAG_CLEAR_MASK: equ #ef  ; assuming REUPLOAD_INGAME_OBJECT_TILES_FLAG_BIT = 4


HUD_MAX_TIME: equ 100

; interactuable items: bullets, coins, and items/chests/locks have this tile range:
FIRST_REGULAR_ITEM_TILE: equ 32
LAST_REGULAR_ITEM_TILE: equ 48

FIRST_ITEM_TILE: equ 44  ; tiles 44, 45, 46, 47 are reserved for items/chests/locks spawned in the current room
FIRST_LARGE_ITEM_TILE: equ 48  ; tiles 48 - 63 are reserved for large items (e.g. doors) spawned in the current room
FIRST_ENEMY_TILE: equ 64

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
CALENDAR_ROOM_ID: equ 100  ; areas are at most 8 * 8 rooms in size, so this ID is impossible to generate naturally
TELEPORTER_ROOM_ID: equ 101  ; areas are at most 8 * 8 rooms in size, so this ID is impossible to generate naturally
START_ROOM_ID: equ 102
TEMPLE_OF_POSEIDON_ID: equ 103

MAX_WORLD_AREAS: equ 12
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
AREA_OBJECT_STRUCT_OFFSET: equ 1  ; in chunks
AREA_OBJECT_STRUCT_ID: equ 2  ; these are area-relative. So, to globally identify an object, we need (area, ID)
AREA_OBJECT_STRUCT_EXTRA: equ 3

SPRITE_OBJECT_TYPE_NONE: equ 0
SPRITE_OBJECT_TYPE_WATER_SPLASH: equ 1
SPRITE_OBJECT_TYPE_BLOCK_DUST: equ 2
SPRITE_OBJECT_TYPE_4TILE_APPART_DUST: equ 3
SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE: equ 4
SPRITE_OBJECT_TYPE_PLAYER_BULLET_DART: equ 5
SPRITE_OBJECT_TYPE_PLAYER_BULLET_SPEAR: equ 6
SPRITE_OBJECT_TYPE_PLAYER_BULLET_RAY: equ 7
SPRITE_OBJECT_TYPE_EXPLOSION: equ 8
SPRITE_OBJECT_TYPE_BIG_EXPLOSION: equ 9
SPRITE_OBJECT_TYPE_SHOPKEEPER: equ 10
SPRITE_OBJECT_TYPE_LOST_VENDOR: equ 11
SPRITE_OBJECT_TYPE_SHOPKEEPER2: equ 12
SPRITE_OBJECT_TYPE_BOSS_EXTRAS: equ 13  ; additional decorational sprites for bosses
SPRITE_OBJECT_TYPE_XIBALBA_LORD_GHOST: equ 14
SPRITE_OBJECT_TYPE_ATLANTIS_SENTINEL_EXTRAS: equ 5

SENTINEL_DECORATION_SPRITE: equ 30

ROOM_OBJECT_STRUCT_SIZE: equ 13
ROOM_OBJECT_STRUCT_ID: equ 0
ROOM_OBJECT_STRUCT_TYPE: equ 1
ROOM_OBJECT_STRUCT_PIXEL_X: equ 2
ROOM_OBJECT_STRUCT_TILE_X: equ 3
ROOM_OBJECT_STRUCT_PIXEL_Y: equ 4
ROOM_OBJECT_STRUCT_TILE_Y: equ 5
ROOM_OBJECT_STRUCT_STATE: equ 6
ROOM_OBJECT_STRUCT_STATE_TIMER: equ 7  ; used by enemies (instead of SPEED_X)
ROOM_OBJECT_STRUCT_SPEED_X: equ 7
ROOM_OBJECT_STRUCT_SPEED_Y: equ 8
ROOM_OBJECT_STRUCT_LAST_HIT_ID: equ 8  ; used by enemies (instead of SPEED_Y)
ROOM_OBJECT_STRUCT_HIT_ID: equ 9  ; used by player bullets only, to avoid multi-hit
ROOM_OBJECT_STRUCT_HEALTH: equ 9  ; used by enemies only
ROOM_OBJECT_STRUCT_BULLET_STATE: equ 9  ; used by some bullets only
ROOM_OBJECT_STRUCT_BRESENHAM_STATE: equ 10
ROOM_OBJECT_STRUCT_EXTRA1: equ 11  ; used by some enemies that need extra state (e.g. fire imps)
ROOM_OBJECT_STRUCT_EXTRA2: equ 12  ; used by some enemies that need extra state (e.g. fire imps)

ROOM_TILE_OBJECT_STRUCT_SIZE: equ 12
ROOM_TILE_OBJECT_STRUCT_ID: equ 0
ROOM_TILE_OBJECT_STRUCT_TYPE: equ 1
ROOM_TILE_OBJECT_STRUCT_X: equ 2  ; tile resolution
ROOM_TILE_OBJECT_STRUCT_Y: equ 3
ROOM_TILE_OBJECT_STRUCT_STATE: equ 4  ; for breakable walls, these are the remaining hit points
ROOM_TILE_OBJECT_STRUCT_STATE_TIMER: equ 5  ; for tile-based enemies
ROOM_TILE_OBJECT_STRUCT_HEALTH: equ 6  ; for tile-based enemies
ROOM_TILE_OBJECT_STRUCT_BACKGROUND: equ 7  ; 4 bytes (only for 2x2 objects)
ROOM_TILE_OBJECT_STRUCT_WIDTH: equ 9  ; only used by breakable walls
ROOM_TILE_OBJECT_STRUCT_HEIGHT: equ 10  ; only used by breakable walls
ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID: equ 11  ; only used by breakable walls / enemies
ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR: equ 7  ; only used by tile enemies
ROOM_TILE_OBJECT_STRUCT_EXTRA1: equ 9  ; used by objects that do not store width/height (e.g. atlantis sentinel)
ROOM_TILE_OBJECT_STRUCT_EXTRA2: equ 10  ; used by objects that do not store width/height (e.g. atlantis sentinel)

PLAYER_COLLISION_UP_LEEWAY: equ 3  ; collision box height will be 16 - (8 - PLAYER_COLLISION_UP_LEEWAY)
PLAYER_COLLISION_WIDTH: equ 4
PLAYER_MAX_SWIMMING_INERTIA_TIME: equ 8
PLAYER_PIXEL_X_ON_LADDER: equ 6
PLAYER_PUSHING_TIME: equ 32

PLAYER_MAX_HEALTH: equ 8*4
PLAYER_INITIAL_MAX_HEALTH: equ 3*4  ; start with 3 hearts, and can grow up to 8 hearts
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
PLAYER_STATE_TELEPORT_IN: equ 38

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
; PLAYER_WEAPON_SHIELD_CROUCHING: equ 11  ; not used
PLAYER_WEAPON_DIRECTIONAL_FW: equ 12
PLAYER_WEAPON_DIRECTIONAL_FW_UP: equ 13
PLAYER_WEAPON_DIRECTIONAL_UP: equ 14
PLAYER_WEAPON_SWING_ITEM: equ 15  ; when the player presses the attack button with an item selected

STONE_DAMAGE: equ 1
DART_DAMAGE: equ 1
SPEAR_DAMAGE: equ 2
RAYGUN_DAMAGE: equ 2

MACHETE_COOLDOWN: equ 8
MACUAHUITL_COOLDOWN: equ 12
HAMMER_COOLDOWN: equ 18

MACUAHUITL_SWING_TIME: equ 8  ; 4 frames after animation start
HAMMER_ANIMATION_TIME1: equ 12 ; 6 frames after animation start
HAMMER_ANIMATION_TIME2: equ 8


; Types of sprite enemies (tile-based enemies are with the other tags below):
; enemies you cannot hit:
ENEMY_BULLET: equ 1
ENEMY_POISON_BULLET: equ 2
ENEMY_PARABOLA_BULLET: equ 3
ENEMY_BULLET_WHIRLWIND: equ 4
ENEMY_BULLET_LIGHTNING: equ 5
ENEMY_BULLET_SONIC_BOOM: equ 6
ENEMY_BULLET_BOSS2_SPIKES: equ 7
ENEMY_BULLET_BOSS3_DEBRIS: equ 8
ENEMY_BULLET_FIREBALL: equ 9
ENEMY_PUS_DROP: equ 10
ENEMY_BLOOD_DROP: equ 11
ENEMY_PUS_BALL: equ 12
ENEMY_BLOOD_BALL: equ 13
ENEMY_BOSS4_BLADES: equ 14
ENEMY_BULLET_WATERBALL: equ 15
ENEMY_BULLET_LASER: equ 16
ENEMY_BULLET_IGNORING_WALLS: equ 17
ENEMY_BULLET_BUBBLE: equ 18
; enemies you can hit:
ENEMY_SNAKE: equ 19
ENEMY_SNAKE_DASHER: equ ENEMY_SNAKE + 1
ENEMY_SNAKE_POISON: equ ENEMY_SNAKE + 2
ENEMY_FISH: equ ENEMY_SNAKE + 3
ENEMY_FISH_JUMPER: equ ENEMY_SNAKE + 4
ENEMY_BAT: equ ENEMY_SNAKE + 5
ENEMY_BAT_AGGRESSIVE: equ ENEMY_SNAKE + 6
ENEMY_SKELETON: equ ENEMY_SNAKE + 7
ENEMY_SKELETON_THROWER1: equ ENEMY_SNAKE + 8
ENEMY_SKELETON_THROWER2: equ ENEMY_SNAKE + 9
ENEMY_BONE_BULLET: equ ENEMY_SNAKE + 10
ENEMY_BONE_PARABOLA_BULLET: equ ENEMY_SNAKE + 11
ENEMY_FROG: equ ENEMY_SNAKE + 12
ENEMY_FROG_JUMPER: equ ENEMY_SNAKE + 13
ENEMY_FROG_TONGUE: equ ENEMY_SNAKE + 14
ENEMY_BEE: equ ENEMY_SNAKE + 15
ENEMY_MONKEY: equ ENEMY_SNAKE + 16
ENEMY_MONKEY_THROWER: equ ENEMY_SNAKE + 17
ENEMY_SKELETON_FLAME1: equ ENEMY_SNAKE + 18
ENEMY_SKELETON_FLAME2: equ ENEMY_SNAKE + 19
ENEMY_ROCKMAN: equ ENEMY_SNAKE + 20
ENEMY_ROCKMAN2: equ ENEMY_SNAKE + 21
ENEMY_ANT: equ ENEMY_SNAKE + 22
ENEMY_ANT2: equ ENEMY_SNAKE + 23
ENEMY_SKELETON_SLEEPER: equ ENEMY_SNAKE + 24
ENEMY_FIRE_IMP: equ ENEMY_SNAKE + 25
ENEMY_FIRE_IMP2: equ ENEMY_SNAKE + 26
ENEMY_FIREBALL: equ ENEMY_SNAKE + 27
ENEMY_SKELETON_THROWER3: equ ENEMY_SNAKE + 28  ; tougher version of thrower1
ENEMY_SKELETON_THROWER4: equ ENEMY_SNAKE + 29  ; tougher version of thrower2
ENEMY_GHOST: equ ENEMY_SNAKE + 30
ENEMY_GHOST2: equ ENEMY_SNAKE + 31
ENEMY_FISHMAN: equ ENEMY_SNAKE + 32
ENEMY_FISHMAN2: equ ENEMY_SNAKE + 33
ENEMY_SENTINEL_ROCK: equ ENEMY_SNAKE + 34
ENEMY_ALIEN: equ ENEMY_SNAKE + 35

; - 7 boss keys
; - 6 boss power stones
; - 6 color keys
; - 1 small key
; - 4 key items (ball, idol, gear, clay doll)
; - 6 mayan upgrade items (sandals, etc.)
; - 2 alien upgrade items
; - 2 elaine letters
; - 1 map
; - 2 half stones
; - 2 puzzle boxes
; - 1 golden key
; - 1 skull charm
; - 2 charybdis / scylla eyes
N_INVENTORY_ITEM_TYPES: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 2 + 2 + 1 + 1 + 2  ; 43
N_INVENTORY_WEAPON_TYPES: equ 4 + 4 + 3  ; 4 base, 4 ranged, 3 upgrades
INVENTORY_ITEM_BOSS5_KEY: equ 4
INVENTORY_ITEM_POWER_STONE1: equ 7
INVENTORY_ITEM_COLOR_KEY1: equ 7 + 6
INVENTORY_ITEM_SMALL_KEY: equ 7 + 6 + 6
INVENTORY_ITEM_BALL: equ 7 + 6 + 6 + 1
INVENTORY_ITEM_IDOL: equ 7 + 6 + 6 + 1 + 1
INVENTORY_ITEM_GEAR: equ 7 + 6 + 6 + 1 + 2
INVENTORY_ITEM_CLAY_DOLL: equ 7 + 6 + 6 + 1 + 3
INVENTORY_ITEM_SANDALS: equ 7 + 6 + 6 + 1 + 4
INVENTORY_ITEM_GLOVES: equ INVENTORY_ITEM_SANDALS + 1
INVENTORY_ITEM_WARRIOR_HAT: equ INVENTORY_ITEM_SANDALS + 2
INVENTORY_ITEM_COTTON_ARMOR: equ INVENTORY_ITEM_SANDALS + 3
INVENTORY_ITEM_CHAAC_BLESSING: equ INVENTORY_ITEM_SANDALS + 4
INVENTORY_ITEM_SEASHELL: equ INVENTORY_ITEM_SANDALS + 5
INVENTORY_ITEM_ANTIGRAV_BELT: equ INVENTORY_ITEM_SANDALS + 6
INVENTORY_ITEM_ICE_CAPE: equ INVENTORY_ITEM_SANDALS + 7
INVENTORY_ITEM_LETTER1: equ 7 + 6 + 6 + 1 + 4 + 6 + 2  ; 32
INVENTORY_ITEM_LETTER2: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 1  ; 33
INVENTORY_ITEM_HALF_POWER_STONE1: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1
INVENTORY_ITEM_HALF_POWER_STONE2: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 1
INVENTORY_ITEM_PUZZLEBOX_MARS: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 2
INVENTORY_ITEM_PUZZLEBOX_MOON: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 2 + 1
INVENTORY_ITEM_GOLDEN_KEY: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 2 + 2
INVENTORY_ITEM_SKULL_CHARM: equ 7 + 6 + 6 + 1 + 4 + 6 + 2 + 2 + 1 + 2 + 2 + 1  ; 40
INVENTORY_ITEM_CHARYBDIS_EYE: equ INVENTORY_ITEM_SKULL_CHARM + 1  ; 41
INVENTORY_ITEM_SCYLLA_EYE: equ INVENTORY_ITEM_CHARYBDIS_EYE + 1   ; 42
; - initial piece just has: jungle + first pyramid, then one piece for each of the rest
; N_MAP_PIECES: equ 9

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
CHUNK_LOCATION_LAVA_GENERATOR_MASK: equ #1000
CHUNK_LOCATION_SENTINEL_MASK: equ #2000

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
CHUNK_LOCATION_LAVA_GENERATOR: equ 13
CHUNK_LOCATION_SENTINEL: equ 14


;-----------------------------------------------
; - This macro changes which page is mapped to #4000 - 7fff
; SETMEGAROMPAGE_4000:    MACRO ?p1
; IF ?p1 == 0
;     xor a
; ELSE
;     ld a, ?p1
; ENDIF
;     di
;     ld (current_megarom_page_in_4000), a
; rom_mapper_page_to_update_4000:
;     ld (#6000), a
;     ei
;     ENDM


; SETMEGAROMPAGE_4000_PRESERVE_FLAGS:    MACRO ?p1
;     ld a, ?p1
;     di
;     ld (current_megarom_page_in_4000), a
; rom_mapper_page_to_update_4000:
;     ld (#6000), a
;     ei
;     ENDM


; ;-----------------------------------------------
; ; - This macro changes which page is mapped to #4000 - 7fff
; SETMEGAROMPAGE_4000_A:    MACRO
;     di
;     ld (current_megarom_page_in_4000), a
; rom_mapper_page_to_update_4000:
;     ld (#6000), a
;     ei
;     ENDM


; ;-----------------------------------------------
; ; - This macro changes which page is mapped to #4000 - 7fff
; SETMEGAROMPAGE_4000_A_WITHOUT_TRACKING:    MACRO
; rom_mapper_page_to_update_4000:
;     ld (#6000), a
;     ENDM


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

