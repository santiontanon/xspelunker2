PCG_WORLD_START_ADDRESS: equ $

	org #c000

tmp_pcg_world__floodfill_open_list: ds virtual 256  ; (should be 256-aligned)
tmp_pcg_world__floodfill_open_list_bot: ds virtual 2
tmp_pcg_world__floodfill_open_list_top: ds virtual 2

tmp_pcg_world__candidates_list: equ tmp_pcg_world__floodfill_open_list
tmp_pcg_world__candidates_list_top: equ tmp_pcg_world__floodfill_open_list_bot
tmp_pcg_world__candidates_list_size: equ tmp_pcg_world__floodfill_open_list_top

tmp_pcg_world__mst_open_list: equ tmp_pcg_world__candidates_list
tmp_pcg_world__mst_open_list_top: equ tmp_pcg_world__candidates_list_top
tmp_pcg_world__mst_open_list_size: equ tmp_pcg_world__candidates_list_size

tmp_pcg_world__tag_list: equ tmp_pcg_world__candidates_list
tmp_pcg_world__tag_list_size: equ tmp_pcg_world__candidates_list_size

tmp_pcg_world__tmp_ptr: ds virtual 2
tmp_pcg_world__tags: ds virtual MAX_AREA_SIZE * MAX_WORLD_AREAS * 2  ; tags for all areas, at most 2 tags per room

pcg_generate_world_tmp_a0p1: ds virtual 2
pcg_generate_world_tmp_a0p2: ds virtual 2
pcg_generate_world_tmp_a1p1: ds virtual 2
pcg_generate_world_tmp_a1p2: ds virtual 2
pcg_generate_world_tmp_a2p1: ds virtual 2
pcg_generate_world_tmp_a2p2: ds virtual 2

tmp_pcg_world__minimum_spanning_tree_top: ds virtual 2
tmp_pcg_world__minimum_spanning_tree_n_nodes: ds virtual 1
tmp_pcg_world__minimum_spanning_tree: ds virtual MAX_N_DIVISIONS*MST_STRUCTURE_SIZE
tmp_pcg_world__mst_neighbors_list: ds virtual 256
tmp_pcg_world__mst_neighbors_list_top: ds virtual 2
tmp_pcg_world__mst_neighbors_list_size: ds virtual 1
tmp_pcg_world__mst_divisions: ds virtual MAX_N_DIVISIONS  ; one byte per division with 0 or 1, "1" meaning the division is in the tree already.

tmp_pcg_world__vertical_check_in_left_most: ds virtual 1  ; 0: only check left-most, 1: also check top-most, 2: also check bottom-most, 3: no vertical connections

tmp_pcg_world__mst_mars_start: ds virtual 2
tmp_pcg_world__mst_moon_start: ds virtual 2
tmp_pcg_world__mst_main_n_nodes: ds virtual 1
tmp_pcg_world__mst_mars_n_nodes: ds virtual 1
tmp_pcg_world__mst_moon_n_nodes: ds virtual 1

tmp_pcg_world__lock_directions: ds virtual 20 * 2  ; 40 bytes (assume at most 20 locks)
tmp_pcg_world__lock_directions_size: ds virtual 1

tmp_pcg_world__mission_start_node: ds virtual 2
tmp_pcg_world__mission_teleporter_atlantis_node: ds virtual 2
tmp_pcg_world__mission_teleporter_mars_node: ds virtual 2
tmp_pcg_world__mission_teleporter_moon_node: ds virtual 2
tmp_pcg_world__mission_boss1_node: ds virtual 2
tmp_pcg_world__mission_boss2_node: ds virtual 2
tmp_pcg_world__mission_boss3_node: ds virtual 2
tmp_pcg_world__mission_boss4_node: ds virtual 2
tmp_pcg_world__mission_boss5_node: ds virtual 2
tmp_pcg_world__mission_boss6_node: ds virtual 2
tmp_pcg_world__mission_boss7_node: ds virtual 2
tmp_pcg_world__mission_midpoint_node: ds virtual 2
tmp_pcg_world__mission_ending_node: ds virtual 2

tmp_pcg_world__riddle_syllable_word_width: ds virtual 2


IF $ > #d000
	ERROR "pcg-world.asm uses too much RAM in buffer_4096!"
ENDIF

	org current_room__tile_map

tmp_pcg_world__useable_nodes: ds virtual 128 * 2
tmp_pcg_world__useable_nodes_size: ds virtual 1
tmp_pcg_world__reachable_nodes: ds virtual 128 * 2
tmp_pcg_world__reachable_nodes_size: ds virtual 1

SUB_QUEST_OPEN_LIST_SIZE: equ 32
tmp_pcg_world__quest_spec_open_list: ds virtual QUEST_SPEC_STRUCTURE_SIZE * SUB_QUEST_OPEN_LIST_SIZE
tmp_pcg_world__quest_spec_open_list_size: ds virtual 1

tmp_pcg_world__available_lock_keys_obstacles: ds virtual pcg_world__available_lock_keys_chests_rom - pcg_world__available_lock_keys_obstacles_rom
tmp_pcg_world__available_lock_keys_chests: ds virtual pcg_world__available_lock_keys_rom - pcg_world__available_lock_keys_chests_rom
tmp_pcg_world__available_lock_keys: ds virtual pcg_world__available_lock_keys_init_rom_end - pcg_world__available_lock_keys_rom

tmp_pcg_world__lock_tag_tmp: ds virtual 1
tmp_pcg_world__key_tag_tmp: ds virtual 1
tmp_pcg_world__root_to_remove: ds virtual 2

tmp_pcg_world__tagless_list: ds virtual 256
tmp_pcg_world__tagless_list_size: ds virtual 1

tmp_pcg_world__n_small_keys: ds virtual 1
tmp_pcg_world__quest_type: ds virtual 1

IF $ > current_room__tile_map + MAX_ROOM_SIZE
	ERROR "pcg-world.asm uses too much RAM in current_room__tile_map!"
ENDIF

	org PCG_WORLD_START_ADDRESS

tmp_pcg_world__area_0_connections: equ current_world__area_data + 4 + 1 + 1 + 1
tmp_pcg_world__area_0_divisions: equ tmp_pcg_world__area_0_connections + MAX_AREA_SIZE
tmp_pcg_world__area_0_tags: equ tmp_pcg_world__area_0_divisions + MAX_AREA_SIZE
tmp_pcg_world__area_10_connections: equ tmp_pcg_world__area_0_connections + WORLD_AREA__SIZE*10
tmp_pcg_world__area_11_connections: equ tmp_pcg_world__area_0_connections + WORLD_AREA__SIZE*11
tmp_pcg_world__area_3_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*3
tmp_pcg_world__area_5_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*5
tmp_pcg_world__area_6_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*6
tmp_pcg_world__area_7_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*7
tmp_pcg_world__area_9_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*9
tmp_pcg_world__area_10_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*10
tmp_pcg_world__area_11_divisions: equ tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE*11

; Minimum-spanning tree node structure (12 bytes):
MST_STRUCTURE_SIZE: equ 12
MST_DIVISION_ID: equ 0
MST_AREA_ID: equ 1
MST_X: equ 2
MST_Y: equ 3
MST_OFFSET: equ 4
MST_N_DESCENDANTS: equ 5
MST_TAG1: equ 6
MST_TAG2: equ 7
MST_PARENT_DIRECTION: equ 8
MST_PARENT_PTR: equ 9  ; 2 bytes
MST_DEPTH: equ 11

; Quest-spec structure:
QUEST_SPEC_STRUCTURE_SIZE: equ 9
QUEST_SPEC_START_DIV_PTR: equ 0
QUEST_SPEC_GOAL_DIV_PTR: equ 2
QUEST_SPEC_START_POINT_OFFSET: equ 4
QUEST_SPEC_GOAL_POINT_OFFSET: equ 5
QUEST_SPEC_START_TAG: equ 6
QUEST_SPEC_GOAL_TAG: equ 7
QUEST_SPEC_N_SUBQUESTS: equ 8


;-----------------------------------------------
pcg__area_sizes_easy:
	db 6, 2
	db 6, 6
	db 6, 6
	db 9, 3
	db 6, 6
	db 3, 3
	db 4, 6
	db 4, 6
	db 6, 6
	db 6, 6
	db 6, 6
	db 6, 6

pcg__area_sizes_hard:
pcg__area_sizes_normal:
	db 7, 2
	db 7, 7
	db 7, 7
	db 9, 3
	db 7, 7
	db 3, 3
	db 5, 7
	db 5, 7
	db 7, 7
	db 7, 7
	db 7, 7
	db 7, 7

pcg__area_sizes_hardest:
	db 8, 2
	db 8, 8
	db 8, 8
	db 9, 3
	db 8, 8
	db 3, 3
	db 6, 8
	db 6, 8
	db 8, 8
	db 8, 8
	db 8, 8
	db 8, 8

; 0: follow layout exactly if provided
; 1: follow layout approximately
pcg__area_layout_fidelity:
	db 1
	db 1
	db 1
	db 0  ; confluence
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1

pcg__area_layout_ptrs_easy:
	dw pcg__full_layout
	dw pcg__temple_inscriptions_layout_easy
	dw pcg__hidden_temple_layout_easy
	dw pcg__confluence_layout
	dw pcg__inverted_pyramid_layout_easy
	dw pcg__fireshaft_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout

pcg__area_layout_ptrs_normal:
pcg__area_layout_ptrs_hard:
	dw pcg__full_layout
	dw pcg__temple_inscriptions_layout_normal
	dw pcg__hidden_temple_layout_normal
	dw pcg__confluence_layout
	dw pcg__inverted_pyramid_layout_normal
	dw pcg__fireshaft_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout

pcg__area_layout_ptrs_hardest:
	dw pcg__full_layout
	dw pcg__temple_inscriptions_layout_hardest
	dw pcg__hidden_temple_layout_hardest
	dw pcg__confluence_layout
	dw pcg__inverted_pyramid_layout_hardest
	dw pcg__fireshaft_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout

pcg__temple_inscriptions_layout_easy:
pcg__hidden_temple_layout_easy:
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 0
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1

pcg__inverted_pyramid_layout_easy:
	db 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1
	db 0, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 0, 0
	db 0, 0, 1, 1, 0, 0

pcg__temple_inscriptions_layout_normal:
pcg__hidden_temple_layout_normal:
	db 0, 0, 0, 1, 0, 0, 0
	db 0, 0, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 0
	db 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1

pcg__inverted_pyramid_layout_normal:
	db 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1
	db 0, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 0, 0
	db 0, 0, 0, 1, 0, 0, 0

pcg__temple_inscriptions_layout_hardest:
pcg__hidden_temple_layout_hardest:
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1

pcg__inverted_pyramid_layout_hardest:
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0

pcg__confluence_layout:
	db 1, 0, 0, 1, 1, 1, 0, 0, 1
	db 1, 1, 1, 1, 1, 1, 1, 1, 1
	db 0, 0, 0, 0, 1, 0, 0, 0, 0

pcg__fireshaft_layout:
	db 0, 1, 0
	db 1, 1, 1
	db 0, 1, 0

pcg__full_layout:  ; for those areas for which we do not want to have a predefined layout:
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1

pgc__n_divisions_per_area:
	db  6, 15, 15,  4  ; 40 + 2
	db 15,  1, 12, 12  ; 42 + 2
	db 13, 13, 12, 12  ; 50 -> 42+42+50 = 134 + 4 divisions (+ 4 since there are 4 hardcoded divisions in the confluence)
MAX_N_DIVISIONS: equ 136

pcg_world__available_lock_keys_init_rom:
pcg_world__available_lock_keys_obstacles_rom:
	db TAG_BUTTON_DOOR1, TAG_BUTTON1
	db TAG_BUTTON_DOOR2, TAG_BUTTON2
	db TAG_BUTTON_DOOR3, TAG_BUTTON3
	db TAG_BUTTON_DOOR4, TAG_BUTTON4
	db TAG_BREAKABLE_WALL1, TAG_NONE
	db TAG_BREAKABLE_WALL2, TAG_NONE
	db TAG_BREAKABLE_WALL3, TAG_NONE
	db TAG_BREAKABLE_WALL4, TAG_NONE
	db TAG_BLOCK_PUZZLE1, TAG_NONE
	db TAG_BLOCK_PUZZLE2, TAG_NONE
	db TAG_BLOCK_PUZZLE3, TAG_NONE
	db TAG_BLOCK_PUZZLE4, TAG_NONE
	db #ff
pcg_world__available_lock_keys_chests_rom:
	db TAG_RED_CHEST, TAG_RED_KEY
	db TAG_GREEN_CHEST, TAG_GREEN_KEY
	db TAG_BLUE_CHEST, TAG_BLUE_KEY
	db TAG_YELLOW_CHEST, TAG_YELLOW_KEY
	db TAG_WHITE_CHEST, TAG_WHITE_KEY
	db TAG_PURPLE_CHEST, TAG_PURPLE_KEY
	db #ff
pcg_world__available_lock_keys_rom:
	db TAG_RED_LOCK, TAG_RED_KEY
	db TAG_GREEN_LOCK, TAG_GREEN_KEY
	db TAG_BLUE_LOCK, TAG_BLUE_KEY
	db TAG_YELLOW_LOCK, TAG_YELLOW_KEY
	db TAG_WHITE_LOCK, TAG_WHITE_KEY
	db TAG_PURPLE_LOCK, TAG_PURPLE_KEY
	db TAG_TRIAL1_LOCK, TAG_TRIAL1_CLUE
	db TAG_TRIAL2_LOCK, TAG_TRIAL2_CLUE
	db TAG_TRIAL3_LOCK, TAG_TRIAL3_CLUE
	db TAG_TRIAL4_LOCK, TAG_TRIAL4_CLUE
	db TAG_COMBINATION1_LOCK, TAG_COMBINATION1_CLUE
	db TAG_COMBINATION2_LOCK, TAG_COMBINATION2_CLUE
	db TAG_COMBINATION3_LOCK, TAG_COMBINATION3_CLUE
	db TAG_COMBINATION4_LOCK, TAG_COMBINATION4_CLUE
	db TAG_BALL_LOCK, TAG_BALL_KEY
	db TAG_IDOL_LOCK, TAG_IDOL_KEY
	db TAG_GEAR_LOCK, TAG_GEAR_KEY
	db TAG_ASTRONAUT_LOCK, TAG_ASTRONAUT_KEY
	db #ff
pcg_world__available_lock_keys_init_rom_end:


pcg_world__optional_object_table:
	; tag, area, probability of spawning, probability of small key chest
	; weapons:
	db TAG_WEAPON_HAMMER, 1, 239, 63
	db TAG_WEAPON_MACUAHUITL, 2, 239, 63
	db TAG_WEAPON_SHIELD, 4, 239, 63
	db TAG_WEAPON_SLING, 0, 239, 63
	db TAG_WEAPON_BLOWGUN, 4, 239, 63
	db TAG_WEAPON_ATLATL, 6, 239, 63
	db TAG_WEAPON_RAYGUN, 9, 239, 63
	db TAG_WEAPON_OBSIDIAN_KNIVE, 7, 239, 63
	db TAG_WEAPON_FIRE_HAMMER, 8, 239, 63
	db TAG_WEAPON_ICE_MACUAHUITL, 9, 239, 63
	; map pieces:
	db TAG_MAP_PIECE1, 2, 255, 0
	db TAG_MAP_PIECE2, 4, 255, 0
	db TAG_MAP_PIECE3, 6, 255, 0
	db TAG_MAP_PIECE4, 8, 255, 0
	db TAG_MAP_PIECE5, 9, 255, 0
	db TAG_MAP_PIECE6, 10, 255, 0
	db TAG_MAP_PIECE7, 11, 255, 0
	; hearts:
	db TAG_HEART1, #ff, 239, 63
	db TAG_HEART2, #ff, 239, 63
	db TAG_HEART3, #ff, 239, 63
	db TAG_HEART4, #ff, 239, 63
	db TAG_HEART5, #ff, 239, 63
	; teleporters:
	db TAG_TELEPORTER1, 0, 239, 0
	db TAG_TELEPORTER2, 1, 239, 0
	db TAG_TELEPORTER3, 2, 239, 0
	db TAG_TELEPORTER4, 4, 239, 0
	db TAG_TELEPORTER5, 6, 239, 0
	db TAG_TELEPORTER6, 7, 239, 0
	db TAG_TELEPORTER7, 8, 239, 0
	db TAG_TELEPORTER8, 9, 239, 0
	; optional items:
	db TAG_ITEM_SANDALS, #fe, 255, 0  ; #fe = areas 1, 2, 3 or 4
	db TAG_ITEM_GLOVES, #ff, 239, 63
	db TAG_ITEM_WARRIOR_HAT, #ff, 239, 63
	db TAG_ITEM_ARMOR, #ff, 239, 63
	db TAG_ITEM_CHAAC, #ff, 239, 63
	db TAG_ITEM_SEASHELL, #ff, 239, 63
	db TAG_ITEM_BELT, #ff, 239, 63
	db TAG_ITEM_ICE_CAPE, #ff, 239, 63
	; small keys:
	db TAG_SMALL_KEY1, #ff, 255, 0
	db TAG_SMALL_KEY2, #ff, 255, 0
	db TAG_SMALL_KEY3, #ff, 255, 0
	db TAG_SMALL_KEY4, #ff, 255, 0
	; random trivia:
	db TAG_STORY_TRIVIA1, #ff, 239, 0
	db TAG_STORY_TRIVIA2, #ff, 239, 0
	db TAG_STORY_TRIVIA3, #ff, 239, 0
	db TAG_STORY_TRIVIA4, #ff, 239, 0
	db TAG_STORY_TRIVIA5, #ff, 239, 0
	db TAG_STORY_TRIVIA6, #ff, 239, 0
	db TAG_STORY_TRIVIA7, #ff, 239, 0
	db TAG_STORY_TRIVIA8, #ff, 239, 0
	; calendar name clue:
	db TAG_CALENDAR_NAME_CLUE, #fd, 255, 0  ; #fd = areas 10, 11
	; xibalba tablets:
	db TAG_XIBALBA_CLUE, 8, 255, 0
	db TAG_XIBALBA_STORY1, 8, 80, 0
	db TAG_XIBALBA_STORY2, 8, 80, 0
	db TAG_XIBALBA_STORY3, 8, 80, 0
	db TAG_XIBALBA_STORY4, 8, 80, 0
	db TAG_XIBALBA_STORY5, 8, 80, 0
	db TAG_XIBALBA_LORDS1, 8, 80, 0
	db TAG_XIBALBA_LORDS2, 8, 80, 0
	db TAG_XIBALBA_LORDS3, 8, 80, 0
	db TAG_XIBALBA_LORDS4, 8, 80, 0
	db TAG_XIBALBA_LORDS5, 8, 80, 0
	db TAG_XIBALBA_LORDS6, 8, 80, 0
	db TAG_XIBALBA_LORDS7, 8, 80, 0
	; atlantis tablets:
	db TAG_ATLANTIS_TABLET2, 9, 255, 0
	db TAG_ATLANTIS_TABLET3, 9, 192, 0
	db TAG_ATLANTIS_TABLET4, 9, 192, 0
	db TAG_ATLANTIS_TABLET5, 9, 192, 0
pcg_world__optional_object_table_end:


;-----------------------------------------------
; output:
; - z: success
; - nz: failure
pcg_generate_world:
	ld hl, current_world__seed
	ld de, rng_seed1
	ldi
	ldi
	ldi
	ldi

;     out (#2c),a  ; DEBUG	
	call pcg_generate_world__init
	call pcg_generate_world__generate_area_layouts  ; uses the connections space to store the layout
	call pcg_generate_world__generate_divisions  ; fills divisionIDs 
	call pcg_generate_world__generate_area_connections  ; fills current_world__interarea_connections
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__generate_spanning_tree  ; generates connections (each tree root to its parent)
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__generate_mission  ; adds all the area tags to the divisions
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__spawn_additional_objects  ; fills additional tags to some divisions
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__generate_tag_data  ; generates the area tags, chest content and shop extra items from all the info above
	call pcg_generate_world__puzzles  ; tablet contents, combination puzzles, trial types, stone numbers 
;     out (#2d),a  ; DEBUG	

	; DEBUG:
; 	ld hl, hardcoded_world_data
; 	ld de, current_world__area_data
; 	ld bc, hardcoded_world_data_end - hardcoded_world_data
; 	call pcg_debug__arrays_equal  ; mdl-watch: "checking hardcoded world data", hl, de, bc
; 	ld hl, hardcoded_area_data_0__connections
; 	ld de, tmp_pcg_world__area_0_connections
; 	ld bc, MAX_AREA_SIZE * 2  ; + MAX_AREA_N_TAGS * 3
; 	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 0", hl, de, bc
; 	ld hl, hardcoded_area_data_10__connections
; 	ld de, tmp_pcg_world__area_10_connections
; 	ld bc, MAX_AREA_SIZE * 2
; 	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 10", hl, de, bc
; 	ld hl, hardcoded_area_data_11__connections
; 	ld de, tmp_pcg_world__area_11_connections
; 	ld bc, MAX_AREA_SIZE * 2
; 	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 11", hl, de, bc

	; for now just copy over the hardcoded data:
; 	ld hl, hardcoded_world_data
; 	ld de, current_world__area_data
; 	ld bc, hardcoded_world_data_end - hardcoded_world_data
; 	ldir

	xor a  ; z
	ret


pcg_generate_world_fail:
	or 1  ; nz, mdl-watch: "pcg_generate_world_fail!"
	ret


; pcg_debug__arrays_equal:
; 	ld a, (de)
; 	cp (hl)
; 	jr nz, pcg_debug__arrays_equal_fail
; 	inc de
; 	inc hl
; 	dec bc
; 	ld a, c
; 	or b
; 	ret z
; 	jr pcg_debug__arrays_equal


; pcg_debug__arrays_equal_fail:
; 	ld a, (hl)  ; mdl-watch: "pcg_debug__arrays_equal_fail: (hl)", hl, a
; 	ld a, (de)  ; mdl-watch: "pcg_debug__arrays_equal_fail: (de)", de, a
; 	di  ; mdl-watch: "pcg_debug__arrays_equal_fail: bc", bc
; 	halt



;-----------------------------------------------
pcg_generate_world__init:
	; random seed:
	ld hl, rng_seed1
	ld de, current_world__seed
	ldi
	ldi
	ldi
	ldi

	ld hl, current_world__chest_content
	ld bc, MAX_CHESTS * 2 + 1 - 1
	ld a, #ff
	call clear_memory_a

	xor a
	ld (tmp_pcg_world__lock_directions_size), a
	ret


;-----------------------------------------------
; each world area is:
; - seed: 4 bytes
; - id: 1 byte
; - width, height: 1 + 1 bytes
; - connections: MAX_AREA_SIZE bytes
; - divisionIDs: MAX_AREA_SIZE bytes
; - tags: MAX_AREA_N_TAGS * 3
; This method fills:
; - seed, id, width, height
; - uses the connections space to store the layout (which will later be overwritten).
pcg_generate_world__generate_area_layouts:
	ld b, MAX_WORLD_AREAS
	ld de, current_world__area_data
pcg_generate_world__generate_area_layouts_loop:
	push bc
		push de
			ld ixl, e
			ld ixh, d  ; save the ptr to the current area in 'ix' for later use.

			; fill: seed, ID, width, height
			ld a, b
			sub MAX_WORLD_AREAS
			neg  ; a = area ID

			ld hl, rng_seed1
			ldi
			ldi
			ldi
			ldi

			ld (de), a  ; ID
			inc de

			push af
				ld a, (current_world__difficulty)				
				ld hl, pcg__area_sizes_easy
				or a
				jr z, pcg_generate_world__generate_area_layouts_loop_sizes_set
				ld hl, pcg__area_sizes_normal
				dec a
				jr z, pcg_generate_world__generate_area_layouts_loop_sizes_set
				ld hl, pcg__area_sizes_hard
				dec a
				jr z, pcg_generate_world__generate_area_layouts_loop_sizes_set
				ld hl, pcg__area_sizes_hardest
pcg_generate_world__generate_area_layouts_loop_sizes_set:
			pop af
			add a, a
			ADD_HL_A
			ldi  ; width
			ldi  ; height

			; fill the layout in the "connections" space in "current_world__area_data"
			ld c, (ix + 4 + 1)  ; width
			ld b, (ix + 4 + 2)  ; height

			ld a, (current_world__difficulty)				
			ld hl, pcg__area_layout_ptrs_easy
			or a
			jr z, pcg_generate_world__generate_area_layouts_loop_ptrs_set
			ld hl, pcg__area_layout_ptrs_normal
			dec a
			jr z, pcg_generate_world__generate_area_layouts_loop_ptrs_set
			ld hl, pcg__area_layout_ptrs_hard
			dec a
			jr z, pcg_generate_world__generate_area_layouts_loop_ptrs_set
			ld hl, pcg__area_layout_ptrs_hardest
pcg_generate_world__generate_area_layouts_loop_ptrs_set:
			ld a, (ix + 4)  ; ID
			add a, a
			ADD_HL_A
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a

			push hl
				ld hl, pcg__area_layout_fidelity
				ld a, (ix + 4)  ; ID
				ADD_HL_A
				ld a, (hl)  ; fidelity
			pop hl
; 		    out (#2c),a  ; DEBUG	
			call pcg_generate_world__generate_area_layout
;     		out (#2d),a  ; DEBUG	
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
		ex de, hl
	pop bc
	dec b
	jp nz, pcg_generate_world__generate_area_layouts_loop
	ret


;-----------------------------------------------
; input:
; - c, b: width, height
; - de: ptr to generate the layout to
; - hl: ptr to predefined layout
; - a: layout fidelity (0: copy, 1: approximate)
pcg_generate_world__generate_area_layout:
	; init to all #ff:
	push af
	push hl
	push de
	push bc
		ex de, hl
		ld bc, MAX_AREA_SIZE - 1
		ld a, #ff
		call clear_memory_a
	pop bc
	pop de
	pop hl
	pop af

	or a
	jr nz, pcg_generate_world__generate_area_layout_from_scratch
pcg_generate_world__generate_area_layout_copy:
	; copy the provided layout:
	ld iyl, 0  ; next room ID
pcg_generate_world__generate_area_layout_copy_y_loop:
	push bc
		ld b, c
pcg_generate_world__generate_area_layout_copy_x_loop:
		ld a, (hl)
		or a
		jr z, pcg_generate_world__generate_area_layout_copy_next
		; room:
		ld a, iyl
		inc iyl
		ld (de), a
pcg_generate_world__generate_area_layout_copy_next:
		inc hl
		inc de
		djnz pcg_generate_world__generate_area_layout_copy_x_loop
	pop bc
	djnz pcg_generate_world__generate_area_layout_copy_y_loop
	ret

pcg_generate_world__generate_area_layout_from_scratch:
	ld (tmp_pcg_world__tmp_ptr), hl  ; hl has a pointer to the reference layout
	ld iyl, 1  ; number of rooms
	ld ixl, c
	ld ixh, b  ; move width, height to ix, to leave bc free

	; compute how many rooms do we want:
	xor a
	srl b  ; b /= 2
	push bc
pcg_generate_world__generate_area_layout_from_scratch_loop1:
		add a, c
		djnz pcg_generate_world__generate_area_layout_from_scratch_loop1
		dec a  ; one less, since we already start with one
		ld iyh, a  ; target number of rooms
	pop bc

	srl c  ; c /= 2
	xor a
	call pcg_generate_world__generate_area_layout_set_room  ; set the first room in the middle of the map
pcg_generate_world__generate_area_layout_from_scratch_loop2:
	; c, b: random position in the map:
	ld c, ixh
	call random_modulo
	ld b, a
	ld c, ixl
	call random_modulo
	ld c, a
	call pcg_generate_world__layout_offset_from_c_b_ixl
	ld l, a
	ld h, 0
	add hl, de
	ld a, (hl)
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2
	; check if there is a room to the left:
	ld a, c
	or a
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue1  ; left-edge
	dec hl
	ld a, (hl)
	inc hl
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue1:
	; check if there is a room to the right:
	ld a, c
	inc a
	cp ixl
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue2  ; right-edge
	inc hl
	ld a, (hl)
	dec hl
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room	
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue2:
	; check if there is a room above:
	ld a, b
	or a
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue3  ; top-edge
	push bc
		ld c, ixl
		ld b, 0
		or a
		sbc hl, bc
		ld a, (hl)
		add hl, bc
	pop bc
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue3:
	; check if there is a room below:
	ld a, b
	inc a
	cp ixh
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue4  ; bottom-edge
	push bc
		ld c, ixl
		ld b, 0
		add hl, bc
		ld a, (hl)
		or a
		sbc hl, bc
	pop bc
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue4:
	jr pcg_generate_world__generate_area_layout_from_scratch_loop2
pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room:
	; have a chance to reject the room if it does not follow the provided layout pattern:
	push bc
		or a  
		sbc hl, de
		ld bc, (tmp_pcg_world__tmp_ptr)
		add hl, bc  ; hl: ptr to the layout pattern
		ld a, (hl)
		or a
	pop bc
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_add_room
	call random_a
	cp 244  ; acceptance threshold
	jr c, pcg_generate_world__generate_area_layout_from_scratch_loop2
pcg_generate_world__generate_area_layout_from_scratch_loop2_add_room:
	ld a, iyl
	call pcg_generate_world__generate_area_layout_set_room
	inc iyl
	dec iyh
	jp nz, pcg_generate_world__generate_area_layout_from_scratch_loop2
	ret


;-----------------------------------------------
; [de + c + b*ixl] = a
; input:
; - a: room ID
; - c, b: x, y, coordinates
; - ixl: width
; - de: ptr to map layout we are creating
pcg_generate_world__generate_area_layout_set_room:
	push af
		call pcg_generate_world__layout_offset_from_c_b_ixl
		ld l, a
		ld h, 0
		add hl, de
	pop af
	ld (hl), a
	ret


;-----------------------------------------------
pcg_generate_world__generate_divisions:
	; Initialize the division buffers to all 0s for places with rooms, and #ff for places without rooms:
	ld b, MAX_WORLD_AREAS
	ld hl, tmp_pcg_world__area_0_divisions
	ld de, tmp_pcg_world__area_0_connections  ; currently contains the room IDs
pcg_generate_world__generate_divisions_init_loop:
	push bc
		push hl
			push de
				ld b, MAX_AREA_SIZE
pcg_generate_world__generate_divisions_init_loop2:
				ld a, (de)
				cp #ff  ; if there is no room (#ff), write a #ff, otherwise, write a 0
				jr z, pcg_generate_world__generate_divisions_init_loop2_a_set
				xor a
pcg_generate_world__generate_divisions_init_loop2_a_set:
				ld (hl), a
				inc hl
				inc de
				djnz pcg_generate_world__generate_divisions_init_loop2
			pop hl
			ld bc, WORLD_AREA__SIZE
			add hl, bc
			ex de, hl
		pop hl
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_divisions_init_loop

	; Hardcoded divisions (confluence + midpoint):
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 3 + 3
	ld (hl), 1
	inc hl
	ld (hl), 1
	inc hl
	ld (hl), 1
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 3 + 3 + 9
	ld (hl), 2
	inc hl
	ld (hl), 2
	inc hl
	ld (hl), 2
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 5 + 1
	ld (hl), 3
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 5 + 1 + 3
	ld (hl), 4
	ld iyl, 5  ; next division ID

	ld b, MAX_WORLD_AREAS
	ld hl, pgc__n_divisions_per_area
	ld ix, current_world__area_data
pcg_generate_world__generate_divisions_loop:
; 	push hl  ; mdl-watch: "test__generate_divisions area ----------------------- ", b
; 		ld hl, (rng_seed1)  ; mdl-watch: "test__seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "test__seed2", hl
; 	pop hl

	push bc
	push hl
		ld c, (ix + 4 + 1)  ; width
		ld b, (ix + 4 + 2)  ; height

		; size of the area in bytes: a = c * b
		xor a
pcg_generate_world__generate_divisions_loop_size_loop:
		add a, c
		djnz pcg_generate_world__generate_divisions_loop_size_loop
		ld c, a
		ld b, (hl)  ; b = target number of divisions in this area

		push bc
			push ix
			pop hl
			ld bc, 4 + 1 + 1 + 1 + MAX_AREA_SIZE
			add hl, bc  ; hl = ptr to the divisions
		pop bc

		; b: number of divisions to generate
		; c: area size
pcg_generate_world__generate_divisions_loop2:
		call random_modulo
		push hl
			ADD_HL_A
			ld a, (hl)
			or a
			jr nz, pcg_generate_world__generate_divisions_loop2_next
			ld a, iyl
			ld (hl), a
			inc iyl
			dec b
pcg_generate_world__generate_divisions_loop2_next:
		pop hl
		ld a, b
		or a
		jr nz, pcg_generate_world__generate_divisions_loop2

		; flood fill:
		call pcg_generate_world__area_division_floodfill

		ld bc, WORLD_AREA__SIZE
		add ix, bc
	pop hl
	pop bc
	inc hl
	djnz pcg_generate_world__generate_divisions_loop
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the current area info
; - hl: ptr to the current divisions (ix + 4 + 1 + 1 + 1 + MAX_AREA_SIZE)
pcg_generate_world__area_division_floodfill:
	; create the open list:
	ld c, (ix + 4 + 1)  ; width
	ld b, (ix + 4 + 2)  ; height
	ld de, tmp_pcg_world__floodfill_open_list  ; 256-aligned
	ld (tmp_pcg_world__floodfill_open_list_bot), de
	ld (tmp_pcg_world__tmp_ptr), hl  ; storing the beginning of the divisions area
pcg_generate_world__area_division_floodfill_open_list_loop_y:
	push bc
pcg_generate_world__area_division_floodfill_open_list_loop_x:
		ld a, (hl)
		or a  ; no division
		jr z, pcg_generate_world__area_division_floodfill_open_list_loop_x_next
		cp #ff  ; no room
		jr z, pcg_generate_world__area_division_floodfill_open_list_loop_x_next
		; we have a division seed:
		ld a, c
		sub (ix + 4 + 1)
		neg
		ld (de), a  ; x
		inc de
		ld a, b
		sub (ix + 4 + 2)
		neg
		ld (de), a  ; y
		inc de
		push hl
		push bc
			ld bc, (tmp_pcg_world__tmp_ptr)
			or a
			sbc hl, bc
			ld a, l
			ld (de), a  ; offset
			inc de
		pop bc
		pop hl
pcg_generate_world__area_division_floodfill_open_list_loop_x_next:
		inc hl
		dec c
		jr nz, pcg_generate_world__area_division_floodfill_open_list_loop_x
	pop bc
	djnz pcg_generate_world__area_division_floodfill_open_list_loop_y
	ld (tmp_pcg_world__floodfill_open_list_top), de

	; fill while the open list is not empty:
	; - we only update "e", since "de" points to a circular list of size 256, and we want to rotate back to the beginning
pcg_generate_world__area_division_floodfill_loop:
	ld de, (tmp_pcg_world__floodfill_open_list_bot)  ; next element of the list
	ld a, (de)
	ld c, a  ; x
	inc e
	ld a, (de)
	ld b, a  ; y
	inc e
	; Here: c = x, b = y
	ld a, c
	or a  ; x == 0?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_left
	; check left:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	dec hl
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_left
	ex af, af'
	dec c
	call pcg_generate_world__area_division_floodfill_push
	inc c
pcg_generate_world__area_division_floodfill_loop_no_left:
	ld a, c
	inc a
	cp (ix + 4 + 1)  ; x == width - 1?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_right
	; check right:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	inc hl
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_right
	ex af, af'
	inc c
	call pcg_generate_world__area_division_floodfill_push
	dec c
pcg_generate_world__area_division_floodfill_loop_no_right:
	ld a, b
	or a  ; y == 0?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_up
	; check up:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	push bc
		ld b, 0
		ld c, (ix + 4 + 1)  ; width
		or a
		sbc hl, bc
	pop bc
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_up
	ex af, af'
	dec b
	call pcg_generate_world__area_division_floodfill_push
	inc b
pcg_generate_world__area_division_floodfill_loop_no_up:
	ld a, b
	inc a
	cp (ix + 4 + 2)  ; y == height - 1?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_down
	; check down:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	push bc
		ld b, 0
		ld c, (ix + 4 + 1)  ; width
		add hl, bc
	pop bc
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_down
	ex af, af'
	inc b
	call pcg_generate_world__area_division_floodfill_push
	; dec b
pcg_generate_world__area_division_floodfill_loop_no_down:
	inc e
	ld (tmp_pcg_world__floodfill_open_list_bot), de

	; list empty?
	ld hl, (tmp_pcg_world__floodfill_open_list_top)
	or a
	sbc hl, de
	jp nz, pcg_generate_world__area_division_floodfill_loop
	ret


pcg_generate_world__area_division_floodfill_push:
	; hl: ptr to the division we are filling
	; de: ptr to the open list
	; c, b: x, y
	ld (hl), a  ; update the division ID
	push de
		ld de, (tmp_pcg_world__floodfill_open_list_top)
		ld a, c
		ld (de), a  ; x
		inc e
		ld a, b
		ld (de), a  ; y
		inc e
		push bc
			ld bc, (tmp_pcg_world__tmp_ptr)
			or a
			sbc hl, bc
		pop bc
		ld a, l
		ld (de), a  ; offset
		inc e
		ld (tmp_pcg_world__floodfill_open_list_top), de
	pop de
	ret


;-----------------------------------------------
; output:
; - z: success
; - nz: failure
pcg_generate_world__generate_area_connections:
	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__generate_area_connections seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_area_connections seed2", hl
; 	pop hl
	; DEBUG-end		

	; clear all the tags, as we will use them to prevent replication of inter-area connections:
	ld hl, tmp_pcg_world__tags
	ld bc, MAX_AREA_SIZE * MAX_WORLD_AREAS * 2 - 1
	call clear_memory

	ld hl, current_world__interarea_connections
	ld bc, MAX_INTERAREA_CONNECTIONS * INTERAREA_CONNECTION_SIZE + 1 - 1
	ld a, #ff
	call clear_memory_a

	ld hl, current_world__interarea_connections
	ld (tmp_pcg_world__tmp_ptr), hl	

	; a0p1:
	xor a
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	xor a
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a0p2:
	xor a
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p2), bc
	xor a
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; swap a0p1/a0p2 so that a0p1.x < a0p2.x:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a0p2)
	ld a, c
	cp e
	jr c, pcg_generate_world__generate_area_connections_no_a0p1_a0p2_swap
	ld (pcg_generate_world_tmp_a0p1), de
	ld (pcg_generate_world_tmp_a0p2), bc
pcg_generate_world__generate_area_connections_no_a0p1_a0p2_swap:

	; a1p1:
	ld a, 1
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 1
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; create jungle -> temple of inscriptions connection:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a1p1)
	ld iyl, 0
	ld iyh, 1
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a2p1:
	ld a, 2
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p1), bc
	ld a, 2
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; create jungle -> hidden temple connection:
	ld bc, (pcg_generate_world_tmp_a0p2)
	ld de, (pcg_generate_world_tmp_a2p1)
	ld iyl, 0
	ld iyh, 2
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a1p2:
	ld a, 1
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 1
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a2p2:
	ld a, 2
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p1), bc
	ld a, 2
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; temple of inscriptions connection -> confluence:
	ld bc, (pcg_generate_world_tmp_a1p1)
	ld de, #0000
	ld iyl, 1
	ld iyh, 3
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; hidden temple connection -> confluence:
	ld bc, (pcg_generate_world_tmp_a2p1)
	ld de, #0008
	ld iyl, 2
	ld iyh, 3
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a4p1:
	ld a, 4
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 4
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; confluence -> inverted pyramid:
	ld bc, #0204
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 3
	ld iyh, 4
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a4p2:
	ld a, 4
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p2), bc
	ld a, 4
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; inverted pyramid -> fire shaft:
	ld bc, (pcg_generate_world_tmp_a0p2)
	ld de, #0001
	ld iyl, 4
	ld iyh, 5
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a6p1:
	ld a, 6
	call pcg_generate_world__random_right_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 6
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0100
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 6
	ld ixl, PCG_DIRECTION_LEFT
	ld ixh, PCG_DIRECTION_RIGHT
	call pcg_generate_world__generate_area_connections_add_connection

	; a7p1:
	xor a
	ld (tmp_pcg_world__vertical_check_in_left_most), a
	ld a, 7
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0102
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 7
	ld ixl, PCG_DIRECTION_RIGHT
	ld ixh, PCG_DIRECTION_LEFT
	call pcg_generate_world__generate_area_connections_add_connection
    
	; a8p1:
	ld a, 8
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 8
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0201
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection    

	; a7p3:
	ld a, 7
	call pcg_generate_world__random_right_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a9p1:
	ld a, 9
	call pcg_generate_world__random_bottom_left_most_point
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 9
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves east -> atlantis:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a1p1)
	ld iyl, 7
	ld iyh, 9
	ld ixl, PCG_DIRECTION_RIGHT
	ld ixh, PCG_DIRECTION_LEFT
	call pcg_generate_world__generate_area_connections_add_connection    

	; a8p2:
	ld a, 8
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p2), bc
	ld a, 8
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	call random_a
	and #01
	jr nz, pcg_generate_world__generate_area_connections_connection_to_east_caves	
pcg_generate_world__generate_area_connections_connection_to_west_caves:
	; a6p2:
	ld a, 6
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p2), bc
	ld a, 6
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves west -> xibalba:
	ld bc, (pcg_generate_world_tmp_a2p2)
	ld de, (pcg_generate_world_tmp_a1p2)
	ld iyl, 6
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	jr pcg_generate_world__generate_area_connections_connection_to_caves_done
pcg_generate_world__generate_area_connections_connection_to_east_caves:
	; a7p2:
	ld a, 7
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p2), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves west -> xibalba:
	ld bc, (pcg_generate_world_tmp_a2p2)
	ld de, (pcg_generate_world_tmp_a1p2)
	ld iyl, 7
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

pcg_generate_world__generate_area_connections_connection_to_caves_done:

	ld hl, (tmp_pcg_world__tmp_ptr)
	ld (hl), #ff  ; sentinel

	; clear the tags again:
	ld hl, tmp_pcg_world__tags
	ld bc, MAX_AREA_SIZE * MAX_WORLD_AREAS * 2 - 1
	call clear_memory

	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - iyl: area 1
; - iyl: area 2
; - c, b: x1, y1
; - e, d: x2, y2
; - ixl: direction1
; - ixh: direction2
pcg_generate_world__generate_area_connections_add_connection:
	ld hl, (tmp_pcg_world__tmp_ptr)  ; mdl-watch2: "pcg_generate_world__generate_area_connections_add_connection", iyl, iyh, c, b, e, d, ixl, ixh
	; - each connection is 8 bytes: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	ld a, iyl
	ld (hl), a
	inc hl
	ld a, iyh
	ld (hl), a
	inc hl
	ld a, ixl
	call pcg_generate_world__generate_area_connections_add_connection_random_chunk
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld a, ixl
	ld (hl), a
	inc hl
	ld c, e
	ld b, d
	ld a, ixh
	call pcg_generate_world__generate_area_connections_add_connection_random_chunk
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld a, ixh
	ld (hl), a
	inc hl
	ld (tmp_pcg_world__tmp_ptr), hl
	ret


pcg_generate_world__generate_area_connections_add_connection_random_chunk:
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_left
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_up
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_right
pcg_generate_world__generate_area_connections_add_connection_random_chunk_down:
	call random_a
	and #01
	add a, c
	add a, c
	ld c, a
	ld a, b
	add a, a
	inc a
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_up:
	call random_a
	and #01
	add a, c
	add a, c
	ld c, a
	ld a, b
	add a, a
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_left:
	ld a, c
	add a, c
	ld c, a
	call random_a
	and #01
	add a, b
	add a, b
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_right:
	ld a, c
	add a, c
	inc a
	ld c, a
	call random_a
	and #01
	add a, b
	add a, b
	ld b, a
	ret


;-----------------------------------------------
; input:
; - a: target area
; output:
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_area_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_area_point_tagless_ptrs_loop_done
pcg_generate_world__random_area_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_area_point_tagless_ptrs_loop
pcg_generate_world__random_area_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc

	xor a
pcg_generate_world__random_area_point_tagless_ptrs_loop2:
	add a, c
	djnz pcg_generate_world__random_area_point_tagless_ptrs_loop2
	ld c, a  ; c = width * height
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c: area width * height

pcg_generate_world__random_area_point_tagless_loop3:
	call random_modulo
	push hl
	push de
		ld b, a
		ADD_HL_A
		ld a, (hl)
		cp #ff  ; no room
		jr z, pcg_generate_world__random_area_point_tagless_ptrs_next_pop
		; there is a room here, is it tagless?
		ld a, b
		ADD_DE_A
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_area_point_tagless_ptrs_next_pop
		; found!
	pop de
	pop hl
	ld l, b  ; offset
	ret  ; z

pcg_generate_world__random_area_point_tagless_ptrs_next_pop:
	pop de
	pop hl
	jr pcg_generate_world__random_area_point_tagless_loop3


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_bottom_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop
pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, b
		cp 1  ; are we at the bottom
		jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_continue
		; is there a room below?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			add hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next  ; not a bottom room
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_y

pcg_generate_world__random_bottom_most_point_tagless_sample:
	; choose one at random:
	ld a, (tmp_pcg_world__candidates_list_size)
	or a
	jr z, pcg_generate_world__random_bottom_most_point_tagless_fail
	ld c, a
	call random_modulo
; 	nop  ; DEBUG:  mdl-watch: "sample point idx / candidates", a, c
	add a, a
	ld hl, tmp_pcg_world__candidates_list
	ADD_HL_A
	ld c, (hl)
	inc hl
	ld b, (hl)  ; mdl-watch2: "    x, y", c, b

	ld a, b
	or a
	ld a, c
	jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop_done
pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop:
	add a, ixl
	djnz pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop
pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop_done:
	ld b, (hl)  ; recover y
	ld l, a  ; l = offset (x + y * width)  mdl-watch2: "    offset", l
	xor a  ; z
	ret
pcg_generate_world__random_bottom_most_point_tagless_fail:
	or 1  ; mdl-watch2: "point sampling failure! no candidates!"
	ret


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_top_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_top_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_top_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_top_most_point_tagless_ptrs_loop
pcg_generate_world__random_top_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_top_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, b
		cp ixh  ; are we at the top of the map?
		jr z, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_continue
		; is there a room above?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			or a
			sbc hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next  ; not a top room
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_top_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_left_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_left_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_left_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_left_most_point_tagless_ptrs_loop
pcg_generate_world__random_left_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_left_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, c
		cp ixl  ; are we at the left-most of the map?
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue
		; is there a room to the left?
		dec hl
		ld a, (hl)
		inc hl
		inc a  ; cp #ff
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next  ; not a left-most room
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue:
		ld a, (tmp_pcg_world__vertical_check_in_left_most)
		bit 0, a
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue2
		; we need to check if the room is also top-most:
		ld a, b
		cp ixh  ; are we at the top-most of the map?
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue2
		; is there a room above?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			or a
			sbc hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next  ; not a top-most room
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue2:
		ld a, (tmp_pcg_world__vertical_check_in_left_most)
		bit 1, a
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue3
		; we need to check if the room is also top-most:
		ld a, b
		cp 1  ; are we at the bottom of the map?
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue3
		; is there a room above?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			add hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next  ; not a bottom room
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue3:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_left_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_right_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_right_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_right_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_right_most_point_tagless_ptrs_loop
pcg_generate_world__random_right_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_right_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, c
		cp 1  ; are we at the right-most of the map?
		jr z, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_continue
		; is there a room to the right
		inc hl
		ld a, (hl)
		dec hl
		inc a  ; cp #ff
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next  ; not a top room
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_right_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------:
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_bottom_left_most_point:
	; get divisions ptr:
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_bottom_left_most_point_ptrs_loop_done
pcg_generate_world__random_bottom_left_most_point_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	dec a
	jr nz, pcg_generate_world__random_bottom_left_most_point_ptrs_loop
pcg_generate_world__random_bottom_left_most_point_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find first match in every map row, and keep the last:
	ld iy, #0000
pcg_generate_world__random_bottom_left_most_point_candidates_loop_y:
	push bc
pcg_generate_world__random_bottom_left_most_point_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_bottom_left_most_point_candidates_loop_x_next
		; there is a room here:
		ld a, c
		sub ixl
		neg
		ld iyl, a  ; x
		ld a, b
		sub ixh
		neg
		ld iyh, a  ; y
		; next row:
		ld b, 0
		add hl, bc
		jr pcg_generate_world__random_bottom_left_most_point_candidates_loop_y_next
pcg_generate_world__random_bottom_left_most_point_candidates_loop_x_next:
		inc hl
		dec c
		jr nz, pcg_generate_world__random_bottom_left_most_point_candidates_loop_x
pcg_generate_world__random_bottom_left_most_point_candidates_loop_y_next:
	pop bc
	djnz pcg_generate_world__random_bottom_left_most_point_candidates_loop_y
	ld c, iyl
	ld b, iyh

	ld a, b
	or a
	ld a, c
	jr z, pcg_generate_world__random_bottom_left_most_point_final_loop_done
pcg_generate_world__random_bottom_left_most_point_final_loop:
	add a, ixl
	djnz pcg_generate_world__random_bottom_left_most_point_final_loop
pcg_generate_world__random_bottom_left_most_point_final_loop_done:
	ld b, iyh
	ld l, a  ; l = offset (x + y * width)
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - a: area
; - b: tag
; - l: offset
; output:
; - z: success
; - nz: failure
pcg_generate_world__add_tag:
	ld c, l  ; mdl-watch2: "pcg_generate_world__add_tag (area, tag, offset)", a, b, l
	ld hl, tmp_pcg_world__tags
	or a
	jr z, pcg_generate_world__add_tag_loop_done
	ld de, MAX_AREA_SIZE * 2
pcg_generate_world__add_tag_loop:
	add hl, de
	dec a
	jr nz, pcg_generate_world__add_tag_loop
pcg_generate_world__add_tag_loop_done:
	push bc
		ld b, 0
		add hl, bc
		add hl, bc  ; we add it twice, since we can have two tags per room
	pop bc
	ld a, (hl)
	cp b
	ret z  ; tag is already there
	; make sure we are not adding a tag to the start/end/etc. rooms:
	cp TAG_START
	jr z, pcg_generate_world__add_tag_fail
	cp TAG_ENDING
	jr z, pcg_generate_world__add_tag_fail
	cp TAG_TELEPORTER_ATLANTIS
	jr z, pcg_generate_world__add_tag_fail
	or a
	jr z, pcg_generate_world__add_tag_found_spot
	call pcg_generate_world__tags_collide
	ret nz
	inc hl
	ld a, (hl)
	cp b
	ret z  ; tag is already there
	or a
	jr nz, pcg_generate_world__add_tag_fail  ; we do not "ret nz", so that we can have an mdl watch statement
pcg_generate_world__add_tag_found_spot:
	ld (hl), b  ; mdl-watch2: "added!"
	ret  ; we will always have "z" here
pcg_generate_world__add_tag_fail:
	; DEBUG
; 	dec hl
; 	ld a, (hl)  ; mdl-watch: "pcg_generate_world__add_tag fail! (previous, new)", a, b
; 	inc hl
; 	ld a, (hl)  ; mdl-watch: "pcg_generate_world__add_tag fail! (previous, new)", a, b
	; DEBUG
	or 1
	ret


;-----------------------------------------------
; Same as "pcg_generate_world__add_tag" but only checks if the tag can be added instead of
; actually adding it.
; input:
; - a: area
; - b: tag
; - l: offset
; output:
; - z: success
; - nz: failure
pcg_generate_world__could_add_tag:
	ld c, l  ; mdl-watch2: "pcg_generate_world__could_add_tag", a, b, l
	ld hl, tmp_pcg_world__tags
	or a
	jr z, pcg_generate_world__could_add_tag_loop_done
	ld de, MAX_AREA_SIZE * 2
pcg_generate_world__could_add_tag_loop:
	add hl, de
	dec a
	jr nz, pcg_generate_world__could_add_tag_loop
pcg_generate_world__could_add_tag_loop_done:
	push bc
		ld b, 0
		add hl, bc
		add hl, bc  ; we add it twice, since we can have two tags per room
	pop bc
	ld a, (hl)
	cp b
	ret z  ; tag is already there
	or a
	ret z  ; empty spot
	call pcg_generate_world__tags_collide
	ret nz
	inc hl
	ld a, (hl)
	cp b
	ret z  ; tag is already there
	or a
	ret


;-----------------------------------------------
; input:
; - a: tag1
; - b: tag2
; output:
; - nz: collision
; - z: all ok
pcg_generate_world__tags_collide:
	; collision if both tags are block puzzles, doors, breakable walls or other directional locks:
	; - it happens that it's all tags before (and including) TAG_ASTRONAUT_LOCK
	ld c, a  ; mdl-watch2: "    pcg_generate_world__tags_collide:", a, b
	or a
	jr z, pcg_generate_world__tags_collide_no_collision
	cp TAG_ASTRONAUT_LOCK + 1
	jr nc, pcg_generate_world__tags_collide_no_collision
	ld a, b
	or a
	jr z, pcg_generate_world__tags_collide_no_collision
	ld a, c
	ld a, b
	cp TAG_ASTRONAUT_LOCK + 1
	ld a, c
	jr nc, pcg_generate_world__tags_collide_no_collision
	; collision:
	or 1
	ld a, c  ; mdl-watch2: "    collision!", a, b
	ret
pcg_generate_world__tags_collide_no_collision:
	xor a  ; z
	ld a, c
	ret


;-----------------------------------------------
pcg_generate_world__generate_spanning_tree:
	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree seed2", hl
; 	pop hl
	; DEBUG-end		

	; clear all the connections:
	ld hl, tmp_pcg_world__area_0_connections
	ld b, MAX_WORLD_AREAS
pcg_generate_world__generate_spanning_tree_clear_loop:
	push bc
		push hl
			ld bc, MAX_AREA_SIZE - 1
			call clear_memory
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_spanning_tree_clear_loop

	ld hl, tmp_pcg_world__mst_divisions
	ld bc, MAX_N_DIVISIONS - 1
	call clear_memory

	; init the tree as empty:
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld (tmp_pcg_world__minimum_spanning_tree_top), hl
	xor a
	ld (tmp_pcg_world__minimum_spanning_tree_n_nodes), a

	; Minimum-Spanning Tree for the main map:
	; Sample the root point (a random left-most point in jungle):
	inc a  ; a = 1  (also check top-most)
	ld (tmp_pcg_world__vertical_check_in_left_most), a
	xor a
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 0
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld (tmp_pcg_world__mst_main_n_nodes), a
	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	ld (tmp_pcg_world__mst_mars_start), hl

	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree (before mars) seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree (before mars) seed2", hl
; 	pop hl
	; DEBUG-end		

	; Minimum-Spanning Tree for Mars:
	xor a
	ld (tmp_pcg_world__vertical_check_in_left_most), a
	ld a, 10
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 10
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld b, a
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	sub b
	ld (tmp_pcg_world__mst_mars_n_nodes), a

	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	ld (tmp_pcg_world__mst_moon_start), hl

	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree (before moon) seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree (before moon) seed2", hl
; 	pop hl
	; DEBUG-end		

	; Minimum-Spanning Tree for Moon:
	xor a
	ld (tmp_pcg_world__vertical_check_in_left_most), a
	ld a, 11
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 11
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld b, a
	ld a, (tmp_pcg_world__mst_mars_n_nodes)
	ld c, a
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	sub b
	sub c
	ld (tmp_pcg_world__mst_moon_n_nodes), a

	; Add connections:
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld b, a
	ld ix, tmp_pcg_world__minimum_spanning_tree
pcg_generate_world__generate_spanning_tree_connections_loop:
	ld a, (ix + MST_PARENT_PTR)
	ld iyl, a
	ld a, (ix + MST_PARENT_PTR + 1)
	ld iyh, a  ; iy = parent ptr
	or iyl  ; if no parent, skip
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_next
	ld a, (ix + MST_AREA_ID)
	cp (iy + MST_AREA_ID)  ; if it's an interarea connection, skip
	jr nz, pcg_generate_world__generate_spanning_tree_connections_loop_next
	; get connections ptr:
	push bc
		call pcg_generate_world__get_area_ptr
		ld bc, 5
		add hl, bc
		ld e, (hl)  ; e = area width
		inc hl
		inc hl  ; hl = ptr to connections
	pop bc
	ld a, (ix + MST_PARENT_DIRECTION)
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_left
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_up
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_right
pcg_generate_world__generate_spanning_tree_connections_loop_down:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_DOWN
	ld (hl), a
	ld d, 0  ; 'e' has the width here
	add hl, de
	ld a, (hl)
	or PCG_DIRECTION_UP
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_left:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_LEFT
	ld (hl), a
	dec hl
	ld a, (hl)
	or PCG_DIRECTION_RIGHT
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_up:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_UP
	ld (hl), a
	ld d, 0  ; 'e' has the width here
	or a
	sbc hl, de
	ld a, (hl)
	or PCG_DIRECTION_DOWN
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_right:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_RIGHT
	ld (hl), a
	inc hl
	ld a, (hl)
	or PCG_DIRECTION_LEFT
	ld (hl), a
pcg_generate_world__generate_spanning_tree_connections_loop_next:
	ld de, MST_STRUCTURE_SIZE
	add ix, de
	dec b
	jp nz, pcg_generate_world__generate_spanning_tree_connections_loop
	ret


;-----------------------------------------------
; input:
; - c, b: x, y of the starting point
; - l: offset of the starting point
; - h: area of the starting point
pcg_generate_world__generate_spanning_tree_internal:
	ld a, l
	ld ixl, a  ; offset
	ld ixh, 0  ; parent direction
	ld a, h  ; area ID
	ld de, 0  ; parent
	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	push hl
		call pcg_generate_world__push_mst_node
	pop de

	; init the open list:
	ld hl, tmp_pcg_world__mst_open_list
	ld a, 1
	ld (tmp_pcg_world__mst_open_list_size), a
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (tmp_pcg_world__mst_open_list_top), hl

pcg_generate_world__generate_spanning_tree_loop:
	; DEBUG-start
; 	push hl
; 	push de
; 		ld hl, (rng_seed1)
; 		ld de, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_spanning_tree_loop seed", hl, de
; 	pop de
; 	pop hl
	; DEBUG-end		

	; pop one node from the open list at random:
	call pcg_generate_world__mst_random_pop_from_open  ; de = ptr to an MST node

	; get division neighbor points:
	push de
		call pcg_generate_world__mst_get_division_neighbor_points
	pop ix

	; iterate through them in a random order:
pcg_generate_world__generate_spanning_tree_neighbor_loop:
	ld a, (tmp_pcg_world__mst_neighbors_list_size)
	or a
	jr z, pcg_generate_world__generate_spanning_tree_neighbor_loop_done

	; select a child at random:
	; each child is 5 bytes:
	; - division ID
	; - area ID
	; - x, y
	; - direction
	cp 1
	jr z, pcg_generate_world__generate_spanning_tree_neighbor_loop_just_one
	ld c, a
	call random_modulo
	jr pcg_generate_world__generate_spanning_tree_neighbor_loop_neighbor_selected
pcg_generate_world__generate_spanning_tree_neighbor_loop_just_one:
	xor a
pcg_generate_world__generate_spanning_tree_neighbor_loop_neighbor_selected:
	push af
		ld c, a
		add a, a
		add a, a
		add a, c
		ld hl, tmp_pcg_world__mst_neighbors_list
		ADD_HL_A  ; hl = ptr to the child we selected

		; check that the division ID it would had is not yet on the tree:
		ld a, (hl)
		push hl
			ld hl, tmp_pcg_world__mst_divisions - 1  ; -1 since the firs division is 0
			ADD_HL_A
			ld a, (hl)
			or a
		pop hl
		jr nz, pcg_generate_world__generate_spanning_tree_neighbor_loop_next

		; add to the tree:
		push hl
		push ix
			ld e, ixl  ; ptr to parent
			ld d, ixh
			inc hl
			ld a, (hl)  ; area ID
			push af
				inc hl
				ld c, (hl)  ; x
				inc hl
				ld b, (hl)  ; y
				inc hl
				ld a, (hl)  ; direction
				ld ixh, a
				; compute offset:
			pop af
			push af
				call pcg_generate_world__layout_offset_from_c_b_area
				ld ixl, a  ; offset
			pop af

			; push the new node we will create into the open list:
			push de
				ld hl, (tmp_pcg_world__mst_open_list_top)
				ld de, (tmp_pcg_world__minimum_spanning_tree_top)
				ld (hl), e
				inc hl
				ld (hl), d
				inc hl
				ld (tmp_pcg_world__mst_open_list_top), hl
				ld hl, tmp_pcg_world__mst_open_list_size
				inc (hl)
			pop de

			call pcg_generate_world__push_mst_node
		pop ix
		pop hl

pcg_generate_world__generate_spanning_tree_neighbor_loop_next:
		; remove the child ("hl") from the neighbors list:
		ld e, l
		ld d, h
		ld bc, 5
		add hl, bc
	pop af  ; we recover the index of this child
	ld c, a
	ld a, (tmp_pcg_world__mst_neighbors_list_size)
	sub c
	dec a
	jr z, pcg_generate_world__generate_spanning_tree_neighbor_loop_next_continue
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__generate_spanning_tree_neighbor_loop_next_continue:

	ld hl, tmp_pcg_world__mst_neighbors_list_size
	dec (hl)
	jp pcg_generate_world__generate_spanning_tree_neighbor_loop
pcg_generate_world__generate_spanning_tree_neighbor_loop_done:

	ld a, (tmp_pcg_world__mst_open_list_size)
	or a
	jp nz, pcg_generate_world__generate_spanning_tree_loop
	ret


;-----------------------------------------------
; Finds all the points that are neighbors to a given mst node, as candidates to be roots
; of children nodes of the given node (pointed to by "de").
; 
; input:
; - de: ptr to a mst node
pcg_generate_world__mst_get_division_neighbor_points:
	ld hl, tmp_pcg_world__mst_neighbors_list
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	xor a
	ld (tmp_pcg_world__mst_neighbors_list_size), a

	; get ptr to area:
	ld ixl, e
	ld ixh, d
	ld a, (ix + MST_AREA_ID)
	call pcg_generate_world__get_area_ptr  ; hl = area ptr

	; get area width/height, and ptr to division IDs:
	ld bc, 5
	add hl, bc
	ld c, (hl)  ; width
	inc hl
	ld b, (hl)  ; height
	ld de, MAX_AREA_SIZE + 1
	add hl, de  ; hl = divisionIDs ptr
	ld iyl, c  ; width
	ld iyh, b  ; height

	; Find neighbors on the current division:
pcg_generate_world__mst_get_division_neighbor_points_loop_y:
	push bc
pcg_generate_world__mst_get_division_neighbor_points_loop_x:
		ld a, (hl)
		cp #ff
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		cp (ix + MST_DIVISION_ID)
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next

		; check left:
		ld a, c
		cp iyl
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left
		dec hl
		ld a, (hl)
		inc hl
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_LEFT
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left:

		; check right:
		ld a, c
		cp 1
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right
		inc hl
		ld a, (hl)
		dec hl
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_RIGHT
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right:

		; check up:
		ld a, b
		cp iyh
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up
		ld d, 0
		ld e, iyl
		or a
		sbc hl, de
		ld a, (hl)
		add hl, de
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_UP
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up:

		; check down:
		ld a, b
		cp 1
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		ld d, 0
		ld e, iyl
		add hl, de
		ld a, (hl)
		or a
		sbc hl, de
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_DOWN

pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor:
		push hl
			ld hl, (tmp_pcg_world__mst_neighbors_list_top)
			ld (hl), a  ; division ID
			inc hl
			ld a, (ix + MST_AREA_ID)
			ld (hl), a  ; area ID
			inc hl
			ld a, c
			sub iyl
			neg
			ld (hl), a  ; x
			inc hl
			ld a, b
			sub iyh
			neg
			ld (hl), a  ; y
			inc hl
			ld (hl), e  ; direction
			inc hl
			ld (tmp_pcg_world__mst_neighbors_list_top), hl
			ld hl, tmp_pcg_world__mst_neighbors_list_size
			inc (hl)
		pop hl
pcg_generate_world__mst_get_division_neighbor_points_loop_x_next:
		inc hl
		dec c
		jp nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x
	pop bc
	dec b
	jp nz, pcg_generate_world__mst_get_division_neighbor_points_loop_y

	; Find neighbors through inter-area connections:
	; - here ix still has a pointer to the minimum-spanning-tree node
	ld iy, current_world__interarea_connections
pcg_generate_world__mst_get_division_connections_loop:
	ld a, (iy)
	cp #ff
	jp z, pcg_generate_world__mst_get_division_connections_loop_done
	; each connection is: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 2)  ; x
		ld b, (iy + 3)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; division ID of the first point of this connection
	cp (ix + MST_DIVISION_ID)
	jr nz, pcg_generate_world__mst_get_division_connections_loop_check_p2
	; add p2 as a neighbor:
	ld a, (iy + 1)  ; p2.area
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 5)  ; x
		ld b, (iy + 6)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; p2.division ID

	ld hl, (tmp_pcg_world__mst_neighbors_list_top)
	ld (hl), a  ; division ID
	inc hl
	ld a, (iy + 1)
	ld (hl), a  ; area ID
	inc hl
	ld a, (iy + 5)
	srl a	
	ld (hl), a  ; x
	inc hl
	ld a, (iy + 6)
	srl a	
	ld (hl), a  ; y
	inc hl
	ld a, (iy + 7)
	ld (hl), a  ; direction
	inc hl
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	ld hl, tmp_pcg_world__mst_neighbors_list_size
	inc (hl)
	jr pcg_generate_world__mst_get_division_connections_loop_next
pcg_generate_world__mst_get_division_connections_loop_check_p2:
	ld a, (iy + 1)
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 5)  ; x
		ld b, (iy + 6)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; division ID of the second point of this connection
	cp (ix + MST_DIVISION_ID)
	jr nz, pcg_generate_world__mst_get_division_connections_loop_next
	; add p1 as a neighbor:
	ld a, (iy)  ; p1.area
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 2)  ; x
		ld b, (iy + 3)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; p1.division ID

	ld hl, (tmp_pcg_world__mst_neighbors_list_top)
	ld (hl), a  ; division ID
	inc hl
	ld a, (iy + 0)
	ld (hl), a  ; area ID
	inc hl
	ld a, (iy + 2)
	srl a		
	ld (hl), a  ; x
	inc hl
	ld a, (iy + 3)
	srl a	
	ld (hl), a  ; y
	inc hl
	ld a, (iy + 4)
	ld (hl), a  ; direction
	inc hl
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	ld hl, tmp_pcg_world__mst_neighbors_list_size
	inc (hl)
pcg_generate_world__mst_get_division_connections_loop_next:
	ld bc, 8
	add iy, bc
	jp pcg_generate_world__mst_get_division_connections_loop
pcg_generate_world__mst_get_division_connections_loop_done:
	ret


;-----------------------------------------------
; output:
; - de: ptr to an mst node
pcg_generate_world__mst_random_pop_from_open:
	; DEBUG-start
; 	ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__mst_random_pop_from_open        seed1: ", hl
; 	ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__mst_random_pop_from_open        seed2: ", hl
	; DEBUG-end

	ld hl, tmp_pcg_world__mst_open_list_size
	ld a, (hl)
	dec (hl)

	ld hl, (tmp_pcg_world__mst_open_list_top)
	dec hl
	dec hl
	ld (tmp_pcg_world__mst_open_list_top), hl

	cp 1
	jr z, pcg_generate_world__mst_random_pop_from_open_1
	ld c, a
	call random_modulo
	jp pcg_generate_world__mst_random_pop_from_open_sampled
pcg_generate_world__mst_random_pop_from_open_1:
	xor a
pcg_generate_world__mst_random_pop_from_open_sampled:
	ld hl, tmp_pcg_world__mst_open_list
	add a, a
	push af
		ADD_HL_A
		ld e, (hl)
		inc hl
		ld d, (hl)  ; de: ptr to note to pop
		ld a, (tmp_pcg_world__mst_open_list_size)
		add a, a
		ld c, a
	pop af
	push de
		; shift copy ("length - n" - 1) * 2 bytes, 2 bytes to the left
		ld e, l
		ld d, h
		dec de
		inc hl
		sub c
		jr z, pcg_generate_world__mst_random_pop_from_open_done
		neg
		ld b, 0
		ld c, a
		ldir
pcg_generate_world__mst_random_pop_from_open_done:
	pop de
	ret


;-----------------------------------------------
; Minimum-spanning tree node structure (10 bytes):
; input:
; - a: area ID
; - c, b: x, y
; - ixl: offset
; - ixh: direction
; - de: parent ptr
pcg_generate_world__push_mst_node:
	; get the division ID:
	ld hl, tmp_pcg_world__minimum_spanning_tree_n_nodes
	inc (hl)
	push af
		push bc
			ld hl, tmp_pcg_world__area_0_divisions
			or a
			jr z, pcg_generate_world__push_mst_node_ptr_loop_done
			ld bc, WORLD_AREA__SIZE
pcg_generate_world__push_mst_node_ptr_loop:
			add hl, bc
			dec a
			jr nz, pcg_generate_world__push_mst_node_ptr_loop
pcg_generate_world__push_mst_node_ptr_loop_done:
			ld b, 0
			ld c, ixl
			add hl, bc
			ld a, (hl)  ; division ID
		pop bc
		ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
		ld (hl), a  ; division ID
		push hl
			ld hl, tmp_pcg_world__mst_divisions - 1  ; -1 since the firs division is 0
			ADD_HL_A
			ld (hl), 1  ; mark the division as already being in the tree
		pop hl
		inc hl
	pop af
	ld (hl), a  ; area ID
	inc hl
	ld (hl), c  ; x
	inc hl
	ld (hl), c  ; y
	inc hl
	ld a, ixl
	ld (hl), a  ; offset
	inc hl
	ld (hl), 0  ; n descendants
	inc hl
	ld (hl), 0  ; tag 1
	inc hl
	ld (hl), 0  ; tag 2
	inc hl
	ld a, ixh
	ld (hl), a  ; direction
	inc hl
	ld (hl), e  ; parent ptr
	inc hl
	ld (hl), d
	inc hl
	ld a, e
	or d
	jr z, pcg_generate_world__push_mst_node_depth_set
	ex de, hl
	push bc
		ld bc, MST_DEPTH
		add hl, bc
		ld a, (hl)  ; parent depth
		inc a
		or a
		sbc hl, bc  ; restore the parent ptr
	pop bc
	ex de, hl
pcg_generate_world__push_mst_node_depth_set:
	ld (hl), a  ; depth
	inc hl
	ld (tmp_pcg_world__minimum_spanning_tree_top), hl

pcg_generate_world__push_mst_node_n_descendants_loop:
	ld a, e
	or d
	ret z  ; if parent is empty, we are done
	; otherwise, increase n_descendants by one:
	ld hl, MST_N_DESCENDANTS
	add hl, de
	inc (hl)
	ld de, MST_PARENT_PTR - MST_N_DESCENDANTS
	add hl, de
	ld e, (hl)  ; get the next parent
	inc hl
	ld d, (hl)
	jr pcg_generate_world__push_mst_node_n_descendants_loop


;-----------------------------------------------
; output:
; - z: all ok
; - nz: some error happened
pcg_generate_world__generate_mission:
	; DEBUG-start
; 	push hl  
; 		ld hl, (rng_seed1)  ; mdl-watch: "pcg_generate_world__generate_mission        seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_mission        seed2: ", hl
; 	pop hl
	; DEBUG-end

	ld hl, pcg_world__available_lock_keys_init_rom
	ld de, tmp_pcg_world__available_lock_keys_obstacles
	ld bc, pcg_world__available_lock_keys_init_rom_end - pcg_world__available_lock_keys_init_rom
	ldir

	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld (tmp_pcg_world__mission_start_node), hl
	ld b, TAG_START
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld a, 9  ; atlantis
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld b, 0
	ld c, l
	ld hl, tmp_pcg_world__area_9_divisions
	add hl, bc
	ld a, (hl)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_teleporter_atlantis_node), hl
	ld a, TAG_TELEPORTER_ATLANTIS
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	ld hl, (tmp_pcg_world__mst_mars_start)
	ld (tmp_pcg_world__mission_teleporter_mars_node), hl
	ld a, TAG_TELEPORTER_MARS
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	ld hl, (tmp_pcg_world__mst_moon_start)
	ld (tmp_pcg_world__mission_teleporter_moon_node), hl
	ld a, TAG_TELEPORTER_MOON
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	; DEBUG-start
; 	push hl  ; mdl-watch: "just before boss locations"
; 		ld hl, (rng_seed1)  ; mdl-watch: "        seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "        seed2: ", hl
; 	pop hl
	; DEBUG-end

	; boss locations:
	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 1  ; temple of inscriptions
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss1_node), hl
	ld b, TAG_BOSS1_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 2  ; hidden temple
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss2_node), hl
	ld b, TAG_BOSS2_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 4  ; inverted pyramid
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss3_node), hl
	ld b, TAG_BOSS3_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 8  ; xibalba
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
; 	ld a, (hl)  ; DEBUG: mdl-watch: "boss4 div", a
	ld (tmp_pcg_world__mission_boss4_node), hl
	ld b, TAG_BOSS4_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 9  ; atlantis
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
; 	ld a, (hl)  ; DEBUG: mdl-watch: "boss5 div", a
	ld (tmp_pcg_world__mission_boss5_node), hl
	ld b, TAG_BOSS5_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, (tmp_pcg_world__mst_mars_start)
	ld a, (tmp_pcg_world__mst_mars_n_nodes)
	ld c, 10  ; mars
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz

	ld (tmp_pcg_world__mission_boss6_node), hl
	ld b, TAG_BOSS6_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	ld ix, (tmp_pcg_world__mst_moon_start)
	ld a, (tmp_pcg_world__mst_moon_n_nodes)
	ld c, 11  ; moon
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss7_node), hl
	ld b, TAG_BOSS7_CHESTLOCK
	ex de, hl  ; mst node
	call pcg_generate_world__add_tag_to_root_in_mst_node_division

	; midpoint:
	ld a, (tmp_pcg_world__area_5_divisions + 1)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_midpoint_node), hl
	ld c, TAG_MIDPOINT
	ld b, PCG_DIRECTION_DOWN
	call pcg_generate_world__add_lock_direction

	; ending:
	ld a, (tmp_pcg_world__area_3_divisions + 3)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_ending_node), hl
	ld b, TAG_ENDING
	ex de, hl  ; mst node
	ld l, 3
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
	ret nz

	; 8-bridge room:
	xor a
	ld (current_world__astronomy_room_area), a
	ld a, 3  ; no vertical connections
	ld (tmp_pcg_world__vertical_check_in_left_most), a
	ld de, tmp_pcg_world__area_6_divisions
	ld a, 6  ; caves west
	push af
	push de
		call pcg_generate_world__random_left_most_point_tagless
		jr z, pcg_generate_world__generate_mission_8_bridge_point_set
	pop de
	pop af
	ld de, tmp_pcg_world__area_7_divisions
	ld a, 7  ; caves east
	push af
	push de
		call pcg_generate_world__random_left_most_point_tagless
		jr nz, pcg_generate_world__generate_mission_no_8_bridge_room_pop
pcg_generate_world__generate_mission_8_bridge_point_set:
	; place 8-bridge room:
	pop de  ; recover the area where the 8 bridge is
	pop af  ; recover the area
	ld (current_world__astronomy_room_area), a
	ld b, 0
	ld c, l  ; offset
	push hl
		ex de, hl  ; tmp_pcg_world__area_6_divisions or tmp_pcg_world__area_7_divisions
		add hl, bc
		ld a, (hl)  ; division ID
		call pcg_generate_world__get_mst_node_by_division_id
		ex de, hl  ; mst node
	pop hl  ; recover the offset
	ld b, TAG_8_BRIDGE_ROOM
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
	jr pcg_generate_world__generate_mission_no_8_bridge_room
pcg_generate_world__generate_mission_no_8_bridge_room_pop:
	pop de
	pop af
pcg_generate_world__generate_mission_no_8_bridge_room:
	xor a
	ld (tmp_pcg_world__vertical_check_in_left_most), a

	; firestone forge:
	ld a, (current_world__spawn_firestone_forge)
	or a
	jr z, pcg_generate_world__generate_mission_no_firestone_forge
	ld a, 11  ; moon
	call pcg_generate_world__random_area_point_tagless
	jr nz, pcg_generate_world__generate_mission_no_firestone_forge
	; place firestone forge:
	ld de, tmp_pcg_world__area_11_divisions
	ld b, 0
	ld c, l  ; offset
	push hl
		ex de, hl  ; tmp_pcg_world__area_11_divisions
		add hl, bc
		ld a, (hl)  ; division ID
		call pcg_generate_world__get_mst_node_by_division_id
		ex de, hl  ; mst node
	pop hl  ; recover the offset
	ld b, TAG_FIRESTONE_FORGE
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
pcg_generate_world__generate_mission_no_firestone_forge:

	; boss 9 room:
	xor a
	ld (current_world__boss9_room_area), a
	ld de, tmp_pcg_world__area_6_divisions
	ld a, 6  ; caves west
	push af
	push de
		call pcg_generate_world__random_bottom_most_point_tagless
		jr z, pcg_generate_world__generate_mission_boss_9_point_set
	pop de
	pop af
	ld de, tmp_pcg_world__area_7_divisions
	ld a, 7  ; caves east
	push af
	push de
		call pcg_generate_world__random_bottom_most_point_tagless
		jr nz, pcg_generate_world__generate_mission_no_boss_9_room_pop
pcg_generate_world__generate_mission_boss_9_point_set:
	; place boss 9 room:
	pop de  ; recover the area where the boss 9 is
	pop af  ; recover the area
	ld (current_world__boss9_room_area), a
	ld b, 0
	ld c, l  ; offset
	push hl
		ex de, hl  ; tmp_pcg_world__area_6_divisions or tmp_pcg_world__area_7_divisions
		add hl, bc
		ld a, (hl)  ; division ID
		call pcg_generate_world__get_mst_node_by_division_id
		ex de, hl  ; mst node
	pop hl  ; recover the offset
	ld b, TAG_BOSS_9_ROOM
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
	jr pcg_generate_world__generate_mission_no_boss_9_room
pcg_generate_world__generate_mission_no_boss_9_room_pop:
	pop de
	pop af
pcg_generate_world__generate_mission_no_boss_9_room:

	; Generate quests:
	ld ix, tmp_pcg_world__minimum_spanning_tree  ; root
	ld iy, (tmp_pcg_world__mission_midpoint_node)  ; do not go past this point
	call pcg_generate_world__reachable_nodes

	ld hl, tmp_pcg_world__reachable_nodes
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 128 * 2 + 1
	ldir  ; useable are the same as reachable at the beginning

	; add "midpoint" to the reachable list (not to the useable list)
	ld hl, tmp_pcg_world__reachable_nodes_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__reachable_nodes
	add a, a
	ADD_HL_A
	ld bc, (tmp_pcg_world__mission_midpoint_node)
	ld (hl), c
	inc hl
	ld (hl), b

	xor a
	ld (tmp_pcg_world__quest_spec_open_list_size), a
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss1_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS1_CHESTLOCK
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss2_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS2_CHESTLOCK
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss3_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS3_CHESTLOCK
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_midpoint_node, 2, #ff, #ff, TAG_START, TAG_MIDPOINT
; 	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_ending_node, 2, #ff, #ff, TAG_NONE, TAG_ENDING
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_ending_node, 2, #ff, #ff, TAG_NONE, TAG_NONE
	call pcg_generate_world__generate_subquests
	ret nz

	; path to midpoint:
	; xor a
	; ld (tmp_pcg_world__quest_spec_open_list_size), a
	; PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_boss1_node, tmp_pcg_world__mission_midpoint_node, 0, #ff, #ff, TAG_NONE, TAG_NONE
	; call pcg_generate_world__generate_subquests
	; ret nz

	; for the bosses 4 and 5, create "current reachable area" (from midpoint on), and do the same:
	ld ix, (tmp_pcg_world__mission_midpoint_node)  ; root
	ld iy, 0  ; do not go past this point
	call pcg_generate_world__reachable_nodes
	ld hl, tmp_pcg_world__reachable_nodes
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 128 * 2 + 1
	ldir  ; 'pcg_generate_world__reachable_nodes' generates the list in 'reachable', we copy it to 'useable'.

	ld ix, tmp_pcg_world__minimum_spanning_tree  ; root
	ld iy, 0  ; do not go past this point
	call pcg_generate_world__reachable_nodes

	xor a
	ld (tmp_pcg_world__quest_spec_open_list_size), a
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_midpoint_node, tmp_pcg_world__mission_boss4_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS4_CHESTLOCK
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_midpoint_node, tmp_pcg_world__mission_boss5_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS5_CHESTLOCK
	call pcg_generate_world__generate_subquests
	ret nz

	; for the bosses 6 and 7, create "current reachable area" from some point in areas 10 and 11, and do the same:
	ld ix, (tmp_pcg_world__mst_mars_start)  ; mars root
	ld iy, 0  ; do not go past this point
	call pcg_generate_world__reachable_nodes
	ld hl, tmp_pcg_world__reachable_nodes
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 128 * 2 + 1
	ldir  ; useable are the same as reachable at the beginning
	xor a
	ld (tmp_pcg_world__quest_spec_open_list_size), a
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_teleporter_mars_node, tmp_pcg_world__mission_boss6_node, 2, #ff, #ff, TAG_NONE, TAG_BOSS6_CHESTLOCK
	call pcg_generate_world__generate_subquests
	ret nz

	ld ix, (tmp_pcg_world__mst_moon_start)  ; moon root
	ld iy, 0  ; do not go past this point
	call pcg_generate_world__reachable_nodes
	ld hl, tmp_pcg_world__reachable_nodes
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 128 * 2 + 1
	ldir  ; useable are the same as reachable at the beginning
	xor a
	ld (tmp_pcg_world__quest_spec_open_list_size), a
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_teleporter_moon_node, tmp_pcg_world__mission_boss7_node, 2, #ff, #ff, TAG_NONE, TAG_BOSS7_CHESTLOCK
	call pcg_generate_world__generate_subquests
	ret nz

	xor a  ; z
	ret


;-----------------------------------------------
; output:
; - z: success
; - nz: failure
pcg_generate_world__generate_subquests:
	; DEBUG-start
; 	push hl  ; mdl-watch: "pcg_generate_world__generate_subquests -------------------"
; 		ld hl, (rng_seed1)  ; mdl-watch: "        seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "        seed2: ", hl
; 	pop hl
	; DEBUG-end

pcg_generate_world__generate_subquests_loop:
	ld a, (tmp_pcg_world__quest_spec_open_list_size)  ; mdl-watch2: ""
	or a  ; mdl-watch2: "pcg_generate_world__generate_subquests", a
	ret z

	ld ix, tmp_pcg_world__quest_spec_open_list  ; ix = ptr to first subquest in the open list

	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "        seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "        seed2: ", hl
; 	pop hl
	; DEBUG-end

	; DEBUG-start:
; 	ld a, (tmp_pcg_world__useable_nodes_size)  ; mdl-watch: "    useable", a
; 	ld a, (tmp_pcg_world__reachable_nodes_size)  ; mdl-watch: "    reachable", a
; 	ld e, (ix + QUEST_SPEC_START_DIV_PTR)
; 	ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
; 	ld a, (de)  ; mdl-watch: "    start div", a
; 	ld e, (ix + QUEST_SPEC_GOAL_DIV_PTR)
; 	ld d, (ix + QUEST_SPEC_GOAL_DIV_PTR + 1)
; 	ld a, (de)  ; mdl-watch: "    goal div", a
; 	ld a, (ix + QUEST_SPEC_START_POINT_OFFSET)  ; mdl-watch: "    start offs", a
; 	ld a, (ix + QUEST_SPEC_GOAL_POINT_OFFSET)  ; mdl-watch: "    goal offs", a
; 	ld a, (ix + QUEST_SPEC_START_TAG)  ; mdl-watch: "    start tag", a
; 	ld a, (ix + QUEST_SPEC_GOAL_TAG)  ; mdl-watch: "    goal tag", a
; 	ld a, (ix + QUEST_SPEC_N_SUBQUESTS)  ; mdl-watch: "    subquests", a
	; DEBUG-end:

	; Choose the subquest pattern to use, and use it to decompose the subquest:
	ld a, (ix + QUEST_SPEC_N_SUBQUESTS)
	or a
	jp z, pcg_generate_world__generate_subquests_0_subquests
	; need a decomposition pattern that can decompose a quest into other subquests:
	ld c, 3
	call random_modulo
	ld c, a  ; quest type
	ld iyl, 0  ; key_tag
	ld iyh, 0  ; lock_tag

	ld a, (ix + QUEST_SPEC_GOAL_TAG)
	cp TAG_BOSS1_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS2_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS3_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS4_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS5_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS6_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_BOSS7_CHESTLOCK
	jr z, pcg_generate_world__generate_subquests_boss_tag
	cp TAG_MIDPOINT
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_ENDING
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON1
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON2
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON3
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON4
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON_DOOR1
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON_DOOR2
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON_DOOR3
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BUTTON_DOOR4
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BREAKABLE_WALL1
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BREAKABLE_WALL2
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BREAKABLE_WALL3
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_BREAKABLE_WALL4
	jr z, pcg_generate_world__generate_subquests_no_chest
	cp TAG_NONE
	jr z, pcg_generate_world__generate_subquests_no_chest
	jr pcg_generate_world__generate_subquests_continue
pcg_generate_world__generate_subquests_boss_tag:
	ld c, 1  ; quest type  ; mdl-watch2: "    boss tag"
	dec a
	ld iyl, a  ; key_tag
	inc a
	ld iyh, a  ; lock_tag
	jr pcg_generate_world__generate_subquests_continue
pcg_generate_world__generate_subquests_no_chest:
	ld a, c  ; mdl-watch2: "no chest"
	cp 1
	jr nz, pcg_generate_world__generate_subquests_continue
	call random_a
	and #01
	add a, a
	ld c, a  ; quest type 0 or 2: obstacle, key_lock  ; mdl-watch2: "        new quest type", c
pcg_generate_world__generate_subquests_continue:

	; if we are out of chests, just use key/lock:
	ld a, (tmp_pcg_world__available_lock_keys_chests)
	cp #ff
	jr nz, pcg_generate_world__generate_subquests_continue2
	ld a, c  ; quest type
	cp 1
	jr nz, pcg_generate_world__generate_subquests_continue2
	ld a, iyh
	or a
	jr nz, pcg_generate_world__generate_subquests_continue2

	ld c, 2  ; quest type = key/lock

pcg_generate_world__generate_subquests_continue2:
	ld a, c  ; mdl-watch2: "quest pattern decomposition type:", a
	or a
	jr z, pcg_generate_world__generate_subquests_obstacle_decomposition
	dec a
	jr z, pcg_generate_world__generate_subquests_lock_chest_decomposition
pcg_generate_world__generate_subquests_lock_key_decomposition:
	ld a, iyh  ; lock tag
	or a
	jr nz, pcg_generate_world__generate_subquests_lock_key_decomposition_lock_set
	ld hl, tmp_pcg_world__available_lock_keys
	call pcg_generate_world__generate_subquests_sample_lock_key
	ret nz
pcg_generate_world__generate_subquests_lock_key_decomposition_lock_set:
	call pcg_generate_world__subquest_pattern__lock_key
	ret nz
	jr pcg_generate_world__generate_subquests_decomposed

pcg_generate_world__generate_subquests_obstacle_decomposition:
	ld a, iyh  ; lock tag
	or a
	jr nz, pcg_generate_world__generate_subquests_obstacle_decomposition_lock_set
	ld hl, tmp_pcg_world__available_lock_keys_obstacles
	call pcg_generate_world__generate_subquests_sample_lock_key
	ret nz
pcg_generate_world__generate_subquests_obstacle_decomposition_lock_set:
	call pcg_generate_world__subquest_pattern__obstacle
	ret nz
	jr pcg_generate_world__generate_subquests_decomposed

pcg_generate_world__generate_subquests_lock_chest_decomposition:
	ld a, iyh  ; lock tag
	or a
	jr nz, pcg_generate_world__generate_subquests_lock_chest_decomposition_lock_set
	ld hl, tmp_pcg_world__available_lock_keys_chests
	call pcg_generate_world__generate_subquests_sample_lock_key
	ret nz
pcg_generate_world__generate_subquests_lock_chest_decomposition_lock_set:
	call pcg_generate_world__add_goal_tag_to_chest_content
	call pcg_generate_world__subquest_pattern__chest
	ret nz
	jr pcg_generate_world__generate_subquests_decomposed

pcg_generate_world__generate_subquests_0_subquests:
	call pcg_generate_world__subquest_pattern__a_to_b
	ret nz
pcg_generate_world__generate_subquests_decomposed:
	ld hl, tmp_pcg_world__quest_spec_open_list + QUEST_SPEC_STRUCTURE_SIZE
	ld de, tmp_pcg_world__quest_spec_open_list
	ld bc, (SUB_QUEST_OPEN_LIST_SIZE - 1) * QUEST_SPEC_STRUCTURE_SIZE
	ldir
	ld hl, tmp_pcg_world__quest_spec_open_list_size
	dec (hl)
	jp pcg_generate_world__generate_subquests_loop


;-----------------------------------------------
; input:
; - hl: list of available lock keys
; output:
; - iyl: key
; - iyh: lock
; - z: success
; - nz: failure
pcg_generate_world__generate_subquests_sample_lock_key:
	push bc
		ld c, 0
		push hl
pcg_generate_world__generate_subquests_sample_lock_key_loop:
			ld a, (hl)
			cp #ff
			jr z, pcg_generate_world__generate_subquests_sample_lock_key_count_done
			inc hl
			inc hl
			inc c
			jr pcg_generate_world__generate_subquests_sample_lock_key_loop
pcg_generate_world__generate_subquests_sample_lock_key_count_done:
		pop hl
		ld a, c
		or a
		jr z, pcg_generate_world__generate_subquests_sample_lock_key_fail

		; DEBUG-start
; 		push hl
; 			ld hl, (rng_seed1)  ; mdl-watch: "        randomLock, seed1: ", hl
; 			ld hl, (rng_seed2)  ; mdl-watch: "        randomLock, seed2: ", hl
; 		pop hl
		; DEBUG-end

		call random_modulo
; 		nop  ; DEBUG mdl-watch: "        randomLock", a, c, hl
		add a, a
		ADD_HL_A
		ld a, (hl)
		ld iyh, a  ; mdl-watch2: "            lock", iyh
		inc hl
		ld a, (hl)
		ld iyl, a

		; remove the tag "iyl" from all the available lists:
		ld hl, tmp_pcg_world__available_lock_keys_obstacles
		call pcg_generate_world__generate_subquests_sample_lock_key_delete_selected
		ld hl, tmp_pcg_world__available_lock_keys_chests
		call pcg_generate_world__generate_subquests_sample_lock_key_delete_selected
		ld hl, tmp_pcg_world__available_lock_keys
		call pcg_generate_world__generate_subquests_sample_lock_key_delete_selected
		
; 		; remove the key/lock from the array:
; 		ld d, h
; 		ld e, l
; 		dec de
; 		inc hl
; pcg_generate_world__generate_subquests_sample_lock_key_delete_loop:
; 		ld a, (hl)
; 		cp #ff
; 		jr z, pcg_generate_world__generate_subquests_sample_lock_key_delete_loop_done
; 		ldi
; 		ldi
; 		jr pcg_generate_world__generate_subquests_sample_lock_key_delete_loop
; pcg_generate_world__generate_subquests_sample_lock_key_delete_loop_done:
; 		ld (de), a  ; copy the #ff

	pop bc
	xor a
	ret
pcg_generate_world__generate_subquests_sample_lock_key_fail:
	pop bc
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - iyh: lock to delete
; - iyl: key to delete
; - hl: list to delete from
pcg_generate_world__generate_subquests_sample_lock_key_delete_selected:
	ld e, l
	ld d, h
pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_loop:
	ld a, (hl)
	ldi
	cp #ff
	ret z  ; we are done
	cp iyh
	jr z, pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_found_lock
	ld a, (hl)
	ldi
	cp TAG_NONE
	jr z, pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_loop
	cp iyl
	jr nz, pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_loop
	dec de
	dec de
	jr pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_loop

pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_found_lock:
	ldi
	dec de
	dec de
	jr pcg_generate_world__generate_subquests_sample_lock_key_delete_selected_loop


;-----------------------------------------------
; input:
; - iyh: chest
; - (ix + QUEST_SPEC_GOAL_TAG): chest content
pcg_generate_world__add_goal_tag_to_chest_content:
	ld b, (ix + QUEST_SPEC_GOAL_TAG)

;-----------------------------------------------
; input:
; - iyh: chest
; - b: chest content	
pcg_generate_world__add_b_to_chest_content:
	; do not add records for boss chestlocks:
	ld a, iyh
	cp TAG_BOSS1_CHESTLOCK
	ret z
	cp TAG_BOSS2_CHESTLOCK
	ret z
	cp TAG_BOSS3_CHESTLOCK
	ret z
	cp TAG_BOSS4_CHESTLOCK
	ret z
	cp TAG_BOSS5_CHESTLOCK
	ret z
	cp TAG_BOSS6_CHESTLOCK
	ret z
	cp TAG_BOSS7_CHESTLOCK
	ret z
	ld hl, current_world__chest_content
pcg_generate_world__add_b_to_chest_content_loop:
	ld a, (hl)
	cp #ff
	jr z, pcg_generate_world__add_b_to_chest_content_loop_done
	inc hl
	inc hl
	jr pcg_generate_world__add_b_to_chest_content_loop
pcg_generate_world__add_b_to_chest_content_loop_done:
	ld a, iyh
	ld (hl), a
	inc hl
	ld (hl), b
	ret


;-----------------------------------------------
; input:
; - ix: ptr to subquest
; output:
; - z: success
; - nz: failure
pcg_generate_world__subquest_pattern__a_to_b:
	; add start tag:
	ld e, (ix + QUEST_SPEC_START_DIV_PTR)
	ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
	ld a, (ix + QUEST_SPEC_START_TAG)
	or a
	call nz, pcg_generate_world__subquest_pattern__add_start_tag
	ret nz

	; add goal tag:
	ld e, (ix + QUEST_SPEC_GOAL_DIV_PTR)
	ld d, (ix + QUEST_SPEC_GOAL_DIV_PTR + 1)
	ld a, (ix + QUEST_SPEC_GOAL_TAG)
	or a
	call nz, pcg_generate_world__subquest_pattern__add_goal_tag
	ret


;-----------------------------------------------
; input:
; - ix: ptr to subquest
; - iyh: lock tag
; - iyl: key tag
; output:
; - z: success
; - nz: failure
pcg_generate_world__subquest_pattern__obstacle:
	; Lock is the point that connects to the goal (in the area of the parent)
	ld a, iyh  ; mdl-watch2: "pcg_generate_world__subquest_pattern__obstacle, key / lock", iyl, iyh
	ld (tmp_pcg_world__lock_tag_tmp), a
	ld a, iyl
	ld (tmp_pcg_world__key_tag_tmp), a

	; DEBUG
; 	ld l, (ix + QUEST_SPEC_START_DIV_PTR)
; 	ld h, (ix + QUEST_SPEC_START_DIV_PTR + 1)
; 	ld a, (hl)  ; mdl-watch: "   quest start div", a	
; 	ld l, (ix + QUEST_SPEC_GOAL_DIV_PTR)
; 	ld h, (ix + QUEST_SPEC_GOAL_DIV_PTR + 1)
; 	ld a, (hl)  ; mdl-watch: "   quest goal div", a	
; 	ld a, (ix + QUEST_SPEC_START_TAG)  ; DEBUG: mdl-watch: "   quest start tag", a	
; 	ld a, (ix + QUEST_SPEC_GOAL_TAG)  ; DEBUG: mdl-watch: "   quest goal tag", a	
	; DEBUG

	call pcg_generate_world__subquest_pattern__pick_goal_lock_node  ; iy: chosen node, l = point offset, (tmp_pcg_world__root_to_remove) = root to remove
	ret nz

	; place the lock tag, key tag, and lock direction:
	push bc
	push hl
	push de
		; b: tag to place
		ld a, (tmp_pcg_world__lock_tag_tmp)
		ld b, a  ; mdl-watch2: "pcg_generate_world__subquest_pattern__obstacle, tag:", a
		call pcg_generate_world__add_tag_to_point_in_mst_node_division
	pop de
	pop hl
	pop bc
	ret nz
	push bc
	push hl
		; b: tag to place
		ld a, (tmp_pcg_world__key_tag_tmp)
		ld b, a
		call pcg_generate_world__add_tag_to_point_in_mst_node_division
	pop hl
	pop bc
	ret nz

	ld a, (tmp_pcg_world__lock_tag_tmp)
	; here:
	; - a: lock tag
	; - c: lock direction
	; - l: lock offset
	ld b, c
	ld c, a
	push hl
	push bc
		call pcg_generate_world__add_lock_direction
	pop bc
	pop hl

	; remove all the descendants of the lock point from "useable" and "reachable":
	push iy
	push hl
	push bc
		ld iy, (tmp_pcg_world__root_to_remove)
		ld a, (iy + MST_DIVISION_ID)
		call pcg_generate_world__remove_useable_reachable_descendants
	pop bc
	pop hl
	pop iy
	ld a, (tmp_pcg_world__key_tag_tmp)  ; key tag
	push af
		ld a, l  ; key offset
		push af
			; push a new sub quest, start -> lock:
			ld hl, tmp_pcg_world__quest_spec_open_list_size
			ld a, (hl)
			inc (hl)
			ld hl, tmp_pcg_world__quest_spec_open_list
			ld c, a
			add a, a
			add a, a
			add a, a
			add a, c
			ADD_HL_A
			ld e, (ix + QUEST_SPEC_START_DIV_PTR)
			ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
			ld (hl), e
			inc hl
			ld (hl), d
			inc hl
			push iy
			pop de
; 			ld a, (iy + MST_DIVISION_ID)  ; DEBUG  ; mdl-watch2: "       *** new quest goal division:", a
			ld (hl), e
			inc hl
			ld (hl), d
			inc hl
			ld a, (ix + QUEST_SPEC_START_POINT_OFFSET)
			cp #ff
			jr nz, pcg_generate_world__subquest_pattern__obstacle_start_offset_set
			; get the root point from the start division:
			ld e, (ix + QUEST_SPEC_START_DIV_PTR)
			ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
REPT MST_OFFSET
			inc de
ENDR
			ld a, (de)  ; offset
pcg_generate_world__subquest_pattern__obstacle_start_offset_set:
			ld (hl), a
			inc hl
		pop af  
		ld (hl), a  ; key offset  ; mdl-watch2: "       *** new quest goal offset:", a
		inc hl
		ld a, (ix + QUEST_SPEC_START_TAG)
		ld (hl), a
		inc hl
	pop af  ; key tag
	ld (hl), a
	inc hl
	ld a, (ix + QUEST_SPEC_N_SUBQUESTS)
	dec a
	ld (hl), a

	; add the remainder of the tags (start/goal, which can be done just calling a_to_b):
	jp pcg_generate_world__subquest_pattern__a_to_b


;-----------------------------------------------
; input:
; - ix: ptr to subquest
; - iyl: key tag
; - iyh: lock tag
; output:
; - z: success
; - nz: failure
pcg_generate_world__subquest_pattern__chest:

	ld a, 1  ; mdl-watch2: "    pcg_generate_world__subquest_pattern__chest, key/lock", iyl, iyh
	ld (tmp_pcg_world__quest_type), a

	; remove goal and its descendants from reachable/useable:
; 	ld l, (ix + QUEST_SPEC_GOAL_DIV_PTR)
; 	ld h, (ix + QUEST_SPEC_GOAL_DIV_PTR + 1)
; 	ld a, (hl)  ; division ID of goal
; 	push iy
; 		call pcg_generate_world__remove_useable_reachable_descendants
; 	pop iy

pcg_generate_world__subquest_pattern__lock_key_entry_point:
	; Pick key division:
	push ix
	push iy
		call pcg_generate_world__random_mst_node_favoring_leaves_tagless
	pop iy
	pop ix
	ret nz

	; DEBUG
; 	ld a, (de)  ; mdl-watch:"    key division: ", a
	; DEBUG

	; Pick a random point on the key division:
	ex de, hl  ; hl = pointer to the mst node
	push hl
	push ix
	push iy
		call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
	pop iy
	pop ix
	pop de  ; ptr to mst node
	ret nz

	; Place key tag:
	ld b, iyl  ; mdl-watch2: "    key tag, lock tag:", iyl, iyh
	push bc
	push hl
	push de
	push iy
		; de: ptr to mst node
		call pcg_generate_world__add_tag_to_point_in_mst_node_division
	pop iy
	pop de
	pop hl
	pop bc
	ret nz

	; push a new sub quest, start -> key:
	ld a, b
	push af
		ld a, l
		push af
			ld hl, tmp_pcg_world__quest_spec_open_list_size
			ld a, (hl)
			inc (hl)
			ld hl, tmp_pcg_world__quest_spec_open_list
			ld c, a
			add a, a
			add a, a
			add a, a
			add a, c
			ADD_HL_A
			push de
				ld e, (ix + QUEST_SPEC_START_DIV_PTR)
				ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
				ld (hl), e
				inc hl
				ld (hl), d
				inc hl
			pop de
; 			ld a, (de)  ; DEBUG  ; mdl-watch2: "       *** new quest goal division:", a
			ld (hl), e  ; goal div ptr
			inc hl
			ld (hl), d
			inc hl
			ld a, (ix + QUEST_SPEC_START_POINT_OFFSET)
			cp #ff
			jr nz, pcg_generate_world__subquest_pattern__chest_start_offset_set
			; get the root point from the start division:
			ld e, (ix + QUEST_SPEC_START_DIV_PTR)
			ld d, (ix + QUEST_SPEC_START_DIV_PTR + 1)
REPT MST_OFFSET
			inc de
ENDR
			ld a, (de)  ; offset
pcg_generate_world__subquest_pattern__chest_start_offset_set:
			ld (hl), a
			inc hl
		pop af  
		ld (hl), a  ; key offset  ; mdl-watch2: "       *** new quest goal offset:", a
		inc hl
		ld a, (ix + QUEST_SPEC_START_TAG)
		ld (hl), a
		inc hl
	pop af  ; key tag
	ld (hl), a
	inc hl
	ld a, (ix + QUEST_SPEC_N_SUBQUESTS)
	dec a
	ld (hl), a

	ld a, (tmp_pcg_world__quest_type)
	cp 1  ; chest
	jr nz, pcg_generate_world__subquest_pattern__chest_not_a_chest
	; swap the goal tag by the chest tag (except if it's a boss chest):
	ld a, iyh
	ld (ix + QUEST_SPEC_GOAL_TAG), a
pcg_generate_world__subquest_pattern__chest_not_a_chest:
	; add the remainder of the tags (start/goal, which can be done just calling a_to_b):
	; replace the goal tag with the chest tag:
	jp pcg_generate_world__subquest_pattern__a_to_b


;-----------------------------------------------
; input:
; - ix: ptr to subquest
; - iyl: key tag
; - iyh: lock tag
; output:
; - z: success
; - nz: failure
pcg_generate_world__subquest_pattern__lock_key:
	ld (tmp_pcg_world__tmp_ptr), iy  ; mdl-watch2: "    pcg_generate_world__subquest_pattern__lock_key, key/lock", iyl, iyh

	; Lock is the point that connects to the goal (in the area of the parent)
	; (computed in the same exact way as for the __obstacle subquest pattern)
	ld a, iyh
	ld (tmp_pcg_world__lock_tag_tmp), a
	call pcg_generate_world__subquest_pattern__pick_goal_lock_node  ; iy = chosen node, l = point offset, (tmp_pcg_world__root_to_remove) = root to remove
	ret nz

	; place the lock tag, and lock direction:
	push bc
	push hl
		ld bc, (tmp_pcg_world__tmp_ptr)  ; b = lock tag
		push iy
		pop de  ; de = mst node
		call pcg_generate_world__add_tag_to_point_in_mst_node_division
	pop hl
	pop bc
	ret nz

	ld a, (tmp_pcg_world__lock_tag_tmp)
	; here:
	; - a: lock tag
	; - c: lock direction
	; - l: lock offset
	ld b, c
	ld c, a
	push hl
	push bc
		call pcg_generate_world__add_lock_direction
	pop bc
	pop hl

	; Update "reachable" (remove the descendants of the lock):
	; remove all the descendants of the lock point from "useable" and "reachable":
	push hl
	push bc
		ld iy, (tmp_pcg_world__root_to_remove)
		ld a, (iy + MST_DIVISION_ID)
		call pcg_generate_world__remove_useable_reachable_descendants
	pop bc
	pop hl

	ld a, 2
	ld (tmp_pcg_world__quest_type), a

	ld iy, (tmp_pcg_world__tmp_ptr)  ; recover key tag and lock tag
	jp pcg_generate_world__subquest_pattern__lock_key_entry_point


;-----------------------------------------------
; input:
; - ix: ptr to subquest
; output:
; - iy: ptr to chosen node
; - l: offset
; - (tmp_pcg_world__root_to_remove): ptr to the root to remove from useable/reachable
; - z: success
; - nz: failure
pcg_generate_world__subquest_pattern__pick_goal_lock_node:
	; Get the parent area and desired point (if no more parents, fail):
	; If the parent is in a different area than the current division, 
	; we are going through an inter-area connection.
	ld c, (ix + QUEST_SPEC_GOAL_DIV_PTR)
	ld b, (ix + QUEST_SPEC_GOAL_DIV_PTR + 1)
	push bc
	pop iy
	ld (tmp_pcg_world__root_to_remove), iy
pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop:
	ld a, (iy + MST_PARENT_PTR)
	or (iy + MST_PARENT_PTR + 1)
	jp z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail_no_pop  ; no more parents, fail

	; See if we could place the tag (and set the lock direction):
	ld (tmp_pcg_world__root_to_remove), iy
	ld c, (iy + MST_PARENT_PTR)
	ld b, (iy + MST_PARENT_PTR + 1)
; 	ld a, (iy + MST_DIVISION_ID)  ; DEBUG: mdl-watch: "    pick_goal_lock_node loop div id from", a
; 	ld a, (bc)  ; DEBUG: mdl-watch: "    pick_goal_lock_node loop div id to", a
	inc bc
	ld a, (bc)  ; MST_AREA_ID of the parent  ; mdl-watch2: "    pick_goal_lock_node loop ptr, area id", bc, a
	dec bc
	cp (iy + MST_AREA_ID)
	jr nz, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection

	; get area width since we might need it before:
	push bc  ; mdl-watch2: "    same area"
		call pcg_generate_world__get_area_ptr
		ld bc, 5
		add hl, bc
		ld d, (hl)  ; area width

		ld a, (iy + MST_PARENT_DIRECTION)
		ld e, (iy + MST_OFFSET)
	pop iy
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_left
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_up
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_right

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_down:
	ld b, (iy + MST_AREA_ID)
	ld a, e  ; offset
	add a, d  ; area width
	ld e, a
	ld c, PCG_DIRECTION_UP
	jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_left:
	ld b, (iy + MST_AREA_ID)
	dec e  ; offset
	ld c, PCG_DIRECTION_RIGHT
	jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_up:
	ld b, (iy + MST_AREA_ID)
	ld a, e  ; offset
	sub a, d  ; area width
	ld e, a
	ld c, PCG_DIRECTION_DOWN
	jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_right:
	ld b, (iy + MST_AREA_ID)
	inc e  ; offset
	ld c, PCG_DIRECTION_LEFT
	jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection:
	; Find the inter-area connection that goes from area 'a' to area 'iy + MST_AREA_ID'
	; and get the offset and direction of the point in area 'a':
	ld e, a
; 	ld a, (iy + MST_AREA_ID)  ; DEBUG: mdl-watch: "    interarea_connection path between areas:", e, a
	push bc  ; save the ptr to the parent
		ld hl, current_world__interarea_connections
pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop:
		ld a, (hl)  ; mdl-watch2: "        area1", a
		cp #ff
		jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail
		inc hl
		cp e
		jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_pre_match1
		ld a, (hl)  ; hl points to areaID2
		cp e
		jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_pre_match2
		; no match!
		inc hl  ; hl points to x1
		jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop_next

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_pre_match1:
		ld a, (hl)  ; hl points fo areaID2
		cp (iy + MST_AREA_ID)
		jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match1
		inc hl
		; no match!
		jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop_next

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_pre_match2:
		dec hl
		ld a, (hl)  ; hl points to areaID1
		cp (iy + MST_AREA_ID)
		jr z, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match2
		; no match!
		inc hl
		inc hl  ; hl points to x1
		jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop_next

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop_next:
		ld bc, 6
		add hl, bc
		jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_loop

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail:
	pop iy  ; mdl-watch2: "pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail"
pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail_no_pop:
	or 1  ; nz  ; mdl-watch2: "pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_fail_no_pop"
	ret

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match1:
		; we need: direction1, and offset = x1 + y1 * width1
		inc hl
		ld c, (hl)  ; x1 in chunks
		srl c
		inc hl
		ld b, (hl)  ; y1 in chunks
		srl b
		inc hl
		ld d, (hl)  ; direction1  ; mdl-watch2: "        x1, y1, direction1:", c, b, d
		jr pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match_continue
pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match2:
		; we need: direction2, and offset = x2 + y2 * width2
		inc hl
		inc hl
		inc hl
		inc hl
		inc hl
		ld c, (hl)  ; x2 in chunks
		srl c
		inc hl
		ld b, (hl)  ; y2 in chunks
		srl b
		inc hl
		ld d, (hl)  ; direction2  ; mdl-watch2: "        x2, y2, direction2:", c, b, d
pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_interarea_connection_match_continue:
		push bc	
		push ix
			ld a, e
			call pcg_generate_world__layout_offset_from_c_b_area
		pop ix
		pop bc
		ld b, e  ; area ID
		ld c, d  ; direction
		ld e, a  ; offset    ; mdl-watch2: "    point from interarea_connection (area, direction, offset)", b, c, e
	pop iy  ; set the current node to the parent ptr

pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue:

	; here:
	; - b: area ID where to place the lock
	; - c: direction of the lock
	; - e: offset where to place the lock

	; Try to place the tag, and if successful, we are done, otherwise,
	; loop back to get the parent's parent:

	; - b: tag
	; - de: mst node
	; - l: point offset
	ld l, e  ; offset  ; mdl-watch2: "pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop_continue (offset)", l
	ld e, iyl
	ld d, iyh  ; mst node ptr  ; mdl-watch2: "    iy value before before", iy
	ld a, (tmp_pcg_world__lock_tag_tmp)
	ld b, a
	push bc
	push de
	push hl
		call pcg_generate_world__could_add_tag_to_point_in_mst_node_division_p
	pop hl
	pop de
	pop bc
	jp nz, pcg_generate_world__subquest_pattern__pick_goal_lock_node_find_lock_node_loop
	ret


;-----------------------------------------------
; output:
; - de: ptr to mst node
; - z: success
; - nz: failure
pcg_generate_world__random_mst_node_favoring_leaves_tagless:
	ld hl, tmp_pcg_world__useable_nodes
	ld a, (tmp_pcg_world__useable_nodes_size)
	ld b, a
	or a
	jr z, pcg_generate_world__random_mst_node_favoring_leaves_tagless_fail
	ld iyl, 255  ; best n_descendants
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld ixl, e
	ld ixh, d
	ld a, (ix + MST_PARENT_PTR)
	or (ix + MST_PARENT_PTR + 1)
	jr z, pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_next  ; it's the root
	ld a, (ix + MST_TAG1)
	or a
	jr nz, pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_next  ; it's not tagless
	ld a, iyl
	cp (ix + MST_N_DESCENDANTS)
	jr c, pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_next  ; we have something with less descendants, ignore
	jr z, pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_leaf_continue
	; clear the current candidate list, which had nodes with more descendants:
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
	ld a, (ix + MST_N_DESCENDANTS)
	ld iyl, a  ; mark the current best number of descendants

pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_leaf_continue:
	push hl
		ld hl, tmp_pcg_world__candidates_list_size
		ld a, (hl)
		inc (hl)
		ld hl, tmp_pcg_world__candidates_list
		add a, a
		ADD_HL_A
		ld a, ixl
		ld (hl), a
		inc hl
		ld a, ixh
		ld (hl), a
	pop hl

pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop_next:
	djnz pcg_generate_world__random_mst_node_favoring_leaves_tagless_loop

	; sample one at random:
	ld a, (tmp_pcg_world__candidates_list_size)  ; mdl-watch2: "        pcg_generate_world__random_mst_node_favoring_leaves_tagless, candidate list size: ", a
	or a
	jr z, pcg_generate_world__random_mst_node_favoring_leaves_tagless_fail
	ld c, a
	call random_modulo
	ld hl, tmp_pcg_world__candidates_list
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)

	xor a  ; z
	ret
pcg_generate_world__random_mst_node_favoring_leaves_tagless_fail:
	or 1  ; nz  ; msl-watch: "pcg_generate_world__random_mst_node_favoring_leaves_tagless_fail"
	ret


;-----------------------------------------------
; input:
; - a: division of the mst node whose descendants we need to remove
pcg_generate_world__remove_useable_reachable_descendants:
	ld iyl, a  ; mdl-watch2: "pcg_generate_world__remove_useable_reachable_descendants", a
	ld hl, tmp_pcg_world__useable_nodes
	ld a, (tmp_pcg_world__useable_nodes_size)
	ld b, a
	or a
	jr z, pcg_generate_world__remove_useable_reachable_descendants_continue
	call pcg_generate_world__remove_useable_reachable_descendants_internal
	ld a, iyh
	ld (tmp_pcg_world__useable_nodes_size), a
pcg_generate_world__remove_useable_reachable_descendants_continue:
	ld hl, tmp_pcg_world__reachable_nodes
	ld a, (tmp_pcg_world__reachable_nodes_size)
	ld b, a
	or a
	ret z
	call pcg_generate_world__remove_useable_reachable_descendants_internal
	ld a, iyh
	ld (tmp_pcg_world__reachable_nodes_size), a
	ret

pcg_generate_world__remove_useable_reachable_descendants_internal
	; copy the list to a temporary space:
	push hl
	push bc
		ld de, tmp_pcg_world__floodfill_open_list
		add a, a
		ld b, 0
		ld c, a
		ldir
	pop bc
	pop de
	ld hl, tmp_pcg_world__floodfill_open_list

	; copy the elements back one by one if they do not have iyl as the parent:
	ld iyh, 0  ; size of the new list
pcg_generate_world__remove_useable_reachable_descendants_internal_loop:
	push bc
		ld c, (hl)
		inc hl
		ld b, (hl)
		dec hl
		push hl
pcg_generate_world__remove_useable_reachable_descendants_internal_loop_parent_loop:
			ld a, (bc)
			cp iyl
			jr z, pcg_generate_world__remove_useable_reachable_descendants_internal_loop_next
			; get the parent:
			ld hl, 9
			add hl, bc
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld a, c
			or b
			jr z, pcg_generate_world__remove_useable_reachable_descendants_internal_loop_keep
			jr pcg_generate_world__remove_useable_reachable_descendants_internal_loop_parent_loop
pcg_generate_world__remove_useable_reachable_descendants_internal_loop_keep:
		pop hl
		push hl
			ld a, (hl)
			ld (de), a
			inc hl
			inc de
			ld a, (hl)
			ld (de), a
			inc de
			inc iyh
pcg_generate_world__remove_useable_reachable_descendants_internal_loop_next:
		pop hl
		inc hl
		inc hl
	pop bc
	djnz pcg_generate_world__remove_useable_reachable_descendants_internal_loop
	ret


;-----------------------------------------------
; input:
; - de: div ptr
; - a: tag
; output:
; - z: success
; - nz: failed to place the tag
pcg_generate_world__subquest_pattern__add_goal_tag:
	ld b, a
	ld a, (ix + QUEST_SPEC_GOAL_POINT_OFFSET)  ; mdl-watch2: "         goal offset, tag:", a, b
	jr pcg_generate_world__subquest_pattern__add_start_tag_entry_point
pcg_generate_world__subquest_pattern__add_start_tag:
	ld b, a
	ld a, (ix + QUEST_SPEC_START_POINT_OFFSET)  ; mdl-watch2: "         start offset, tag:", a, b
pcg_generate_world__subquest_pattern__add_start_tag_entry_point:
	cp #ff
	ld l, a
	jr nz, pcg_generate_world__subquest_pattern__add_tag_offset_set
	; get offset from mst node:
	push de
REPT MST_OFFSET
		inc de
ENDR
		ld a, (de)
		ld l, a
	pop de
pcg_generate_world__subquest_pattern__add_tag_offset_set:
	jp pcg_generate_world__add_tag_to_point_in_mst_node_division


;-----------------------------------------------
; point offset #ff is ignored
PCG_WORLD__PUSH_QUEST: macro start_node_ptr, goal_node_ptr, n_subquests, start_point_offset, goal_point_offset, start_tag, goal_tag
	ld hl, tmp_pcg_world__quest_spec_open_list_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__quest_spec_open_list
IF QUEST_SPEC_STRUCTURE_SIZE != 9
	ERROR "QUEST_SPEC_STRUCTURE_SIZE != 9!"
ENDIF
	ld c, a
	add a, a
	add a, a
	add a, a
	add a, c
	ADD_HL_A

	ld de, (start_node_ptr)
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld de, (goal_node_ptr)
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), start_point_offset
	inc hl
	ld (hl), goal_point_offset
	inc hl
	ld (hl), start_tag
	inc hl
	ld (hl), goal_tag
	inc hl
	ld (hl), n_subquests
	endm


;-----------------------------------------------
; input:
; - ix: start node
; - iy: block
pcg_generate_world__reachable_nodes:
	xor a
	ld (tmp_pcg_world__reachable_nodes_size), a
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld b, a
pcg_generate_world__reachable_nodes_loop:
	; check if the node is a child of "ix", without going through "iy"
	push bc
		push hl
pcg_generate_world__reachable_nodes_loop_parent_loop:
			ld c, ixl
			ld b, ixh
			or a
			sbc hl, bc
			jr z, pcg_generate_world__reachable_nodes_match
			add hl, bc
			ld c, iyl
			ld b, iyh
			or a
			sbc hl, bc
			jr z, pcg_generate_world__reachable_nodes_block
			add hl, bc

			ld bc, MST_PARENT_PTR
			add hl, bc
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a
			or h
			jr z, pcg_generate_world__reachable_nodes_block  ; we reached the top without crossing the start node
			jr pcg_generate_world__reachable_nodes_loop_parent_loop

pcg_generate_world__reachable_nodes_block:
		pop hl
pcg_generate_world__reachable_nodes_loop_next:
		ld bc, MST_STRUCTURE_SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__reachable_nodes_loop
	ret	

pcg_generate_world__reachable_nodes_match:
		pop hl

		; add node to rechable:
		ex de, hl
			ld hl, tmp_pcg_world__reachable_nodes_size
			ld a, (hl)
			inc (hl)
			ld hl, tmp_pcg_world__reachable_nodes
			add a, a
			ADD_HL_A
			ld (hl), e
			inc hl
			ld (hl), d
		ex de, hl
		ld a, (hl)
		jr pcg_generate_world__reachable_nodes_loop_next


;-----------------------------------------------
; input:
; - c: lock tag
; - b: direction
pcg_generate_world__add_lock_direction:
	ld hl, tmp_pcg_world__lock_directions_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__lock_directions
	add a, a
	ADD_HL_A
	ld (hl), c
	inc hl
	ld (hl), b
	ret


;-----------------------------------------------
; Selects a random leaf on the minimum spanning tree, favoring leaves that
; have a higher depth.
; input:
; - ix: MST root node ptr
; - a: MST size
; - c: target area
; output:
; - hl: ptr to mst node
; - z: found one
; - nz: not found
pcg_generate_world__random_area_mst_node_only_leaves:
	ld b, a
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
	ld iyl, 0  ; current best depth
pcg_generate_world__random_area_mst_node_only_leaves_loop:
	ld a, (ix + MST_TAG1)
	or a
	jr nz, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	ld a, (ix + MST_N_DESCENDANTS)
	or a
	jr nz, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	; leaf:
	ld a, (ix + MST_AREA_ID)
	cp c
	jr nz, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	ld a, (ix + MST_DEPTH)
	cp iyl
	jr c, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	jr z, pcg_generate_world__random_area_mst_node_only_leaves_same_depth
	; we found a deeper leaf, reset the list:
	ld iyl, a  ; new depth
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_area_mst_node_only_leaves_same_depth:
	; new leaf, add to the list:
	ld hl, tmp_pcg_world__candidates_list_size
	ld a, (hl)
	inc (hl)
	add a, a
	ld hl, tmp_pcg_world__candidates_list
	ADD_HL_A
	ld a, ixl
	ld (hl), a
	inc hl
	ld a, ixh
	ld (hl), a

pcg_generate_world__random_area_mst_node_only_leaves_loop_next:
	ld de, MST_STRUCTURE_SIZE
	add ix, de
	djnz pcg_generate_world__random_area_mst_node_only_leaves_loop

	ld a, (tmp_pcg_world__candidates_list_size)
	or a
	jr z, pcg_generate_world__random_area_mst_node_only_leaves_fail

	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "        seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "        seed2: ", hl
; 	pop hl
	; DEBUG-end

	ld c, a
	call random_modulo
	ld hl, tmp_pcg_world__candidates_list  ; mdl-watch2: "pcg_generate_world__random_area_mst_node_only_leaves", a, c
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	xor a  ; z
	ld a, (hl)
	ret
pcg_generate_world__random_area_mst_node_only_leaves_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: tag
; - hl: mst node
; output:
; - z: all ok
; - nz: tag could not be added (too many tags in the division)
pcg_generate_world__add_tag_to_random_point_in_mst_node_division:
	; pick a random note from the division:
	ld b, a  ; tag
	push bc
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless
	pop de
	pop bc
	ret nz  ; no point available
	jr pcg_generate_world__add_tag_to_point_in_mst_node_division


;-----------------------------------------------
; input:
; - b: tag
; - de: mst node
; - l: point offset
; output:
; - z: all ok
; - nz: tag could not be added (too many tags in the division)
pcg_generate_world__add_tag_to_root_in_mst_node_division:
	push de
REPT MST_OFFSET
		inc de
ENDR
		ld a, (de)
		ld l, a  ; get offset of the root
	pop de
pcg_generate_world__add_tag_to_point_in_mst_node_division:
	ld a, b
	or a
	ret z  ; TAG_NONE does not need to be placed
	; add tag to the point:
	push de
; 		ld a, (de)  ; DEBUG  ; mdl-watch2: "pcg_generate_world__add_tag_to_point_in_mst_node_division (tag, div, offset)", b, a, l
		inc de
		ld a, (de)  ; area ID (since MST_AREA_ID == 1)
		; here l = offset of the point sampled above
		call pcg_generate_world__add_tag
	pop hl
	ret nz  ; we cannot add the tag

	; add tag to mst node:
	ld de, MST_TAG1
	add hl, de
	ld 	a, (hl)  ; mdl-watch2: "    first", a
	cp b
	ret z  ; tag is already there
	or a
	jr nz, pcg_generate_world__add_tag_to_random_point_in_mst_node_division_continue
	ld (hl), b  ; tag
	xor a  ; z
	ret
pcg_generate_world__add_tag_to_random_point_in_mst_node_division_continue:
	inc hl
	ld 	a, (hl)  ; mdl-watch2: "    second", a
	cp b
	ret z  ; tag is already there
	or a
	ret nz  ; node already has 2 tags, which is the max!
	ld (hl), b  ; tag
	xor a  ; z
	ret


;-----------------------------------------------
; Same as "pcg_generate_world__add_tag_to_point_in_mst_node_division", but only checks if
; the tag can be added, insteasd of actually adding it.
; input:
; - b: tag
; - de: mst node
; - l: point offset
; output:
; - z: all ok
; - nz: tag could not be added (too many tags in the division)
pcg_generate_world__could_add_tag_to_point_in_mst_node_division_p:
	; add tag to the point:
	push de
		inc de
		ld a, (de)  ; area ID (since MST_AREA_ID == 1)
		; here l = offset of the point sampled above
		call pcg_generate_world__could_add_tag
	pop hl
	ret nz  ; we cannot add the tag
	
	; add tag to mst node:
	ld de, MST_TAG1
	add hl, de
	ld 	a, (hl)
	cp b
	ret z  ; tag is already there
	or a
	ret z  ; no tag
	call pcg_generate_world__tags_collide
	ret nz
	inc hl
	ld 	a, (hl)
	cp b
	ret z  ; tag is already there
	or a
	ret


;-----------------------------------------------
; input:
; - hl: ptr to mst node
; output:
; - c, b: x, y
; - l: offset
; - z: success
; - nz: failure
pcg_generate_world__random_division_point_from_mst_node_tagless:
	ld a, (hl)  ; division ID  ; mdl-watch2: "    pcg_generate_world__random_division_point_from_mst_node_tagless (div)", a
	inc hl
	push af
		ld a, (hl)  ; area ID

		; get divisions and tags ptrs:
		; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
		; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
		ld de, tmp_pcg_world__tags
		ld hl, current_world__area_data + 4 + 1
		or a
		jr z, pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop_done
pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop:
		ld bc, WORLD_AREA__SIZE
		add hl, bc
		ex hl, de
			ld bc, MAX_AREA_SIZE * 2
			add hl, bc
		ex hl, de
		dec a
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop
pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop_done:
		ld c, (hl)
		inc hl
		ld b, (hl)
		push bc
			ld bc, MAX_AREA_SIZE + 1
			add hl, bc
		pop bc
		; Here:
		; - hl: ptr to divisions
		; - de: ptr to tags
		; - c, b: area width, height
		ld ixl, c
		ld ixh, b

		; find candidates:
		ld iy, tmp_pcg_world__candidates_list
		ld (tmp_pcg_world__candidates_list_top), iy
		xor a
		ld (tmp_pcg_world__candidates_list_size), a
	pop af  ; recover the target division ID
	ld iyl, a  ; division ID we are after
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x:
		ld a, (hl)
		cp iyl  ; matches the division ID?
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next
		; add a candidate:
		push hl
			ld hl, (tmp_pcg_world__candidates_list_top)
			ld a, c
			sub ixl
			neg
			ld (hl), a  ; x
			inc hl
			ld a, b
			sub ixh
			neg
			ld (hl), a  ; y
			inc hl
			ld (tmp_pcg_world__candidates_list_top), hl
		pop hl
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_y
; 	ld a, (tmp_pcg_world__candidates_list_size)  ; DEBUG: mdl-watch: "    pcg_generate_world__random_division_point_from_mst_node_tagless candidates", a
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: division ID
; output:
; - hl: ptr to mst node
pcg_generate_world__get_mst_node_by_division_id:
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld bc, MST_STRUCTURE_SIZE
pcg_generate_world__get_mst_node_by_division_id_loop:
	cp (hl)  ; since MST_DIVISION_ID == 0, we can just cp (hl).
	ret z
	add hl, bc
	jr pcg_generate_world__get_mst_node_by_division_id_loop


;-----------------------------------------------
pcg_generate_world__spawn_additional_objects:
	; get the list of all the tagless nodes:

	; DEBUG-start
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "test__pcg_generate_world__spawn_additional_objects seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "test__pcg_generate_world__spawn_additional_objects seed2", hl
; 	pop hl
	; DEBUG-end

	xor a
	ld (tmp_pcg_world__tagless_list_size), a
	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld b, a
	ld de, MST_STRUCTURE_SIZE
pcg_generate_world__spawn_additional_objects_tagless_loop:
; 	ld l, (ix + MST_DIVISION_ID)  ; DEBUG
; 	ld h, (ix + MST_TAG2)  ; DEBUG
	ld a, (ix + MST_TAG1)  ; mdl-watch2: "tagless div/tag1/tag2", l, a, h
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_tagless_loop_next
; 	ld l, (ix + MST_DIVISION_ID)  ; DEBUG  mdl-watch: "tagless div", l
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__tagless_list
	add a, a
	ADD_HL_A
	ld a, ixl
	ld (hl), a
	inc hl
	ld a, ixh
	ld (hl), a
pcg_generate_world__spawn_additional_objects_tagless_loop_next:
	add ix, de
	djnz pcg_generate_world__spawn_additional_objects_tagless_loop

; 	ld a, (tmp_pcg_world__tagless_list_size)  ; DEBUG  mdl-watch: "n tagless nodes:", a

	; Guardian statues:
	call pcg_generate_world__puzzles_stelae_status
	ld a, (current_world__stela_status)
	bit 0, a  ; left stela
	jr z, pcg_generate_world__spawn_additional_objects_no_guardian_statue1
	ld c, 1  ; temple of inscriptions
	call pcg_generate_world__spawn_additional_objects_sample_node_from_area  ; hl = ptr to node
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue1
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
	pop de
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue1
	ld b, TAG_GUARDIAN_CAIMAN1
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
pcg_generate_world__spawn_additional_objects_no_guardian_statue1:

	ld a, (current_world__stela_status)
	bit 1, a  ; right stela
	jr z, pcg_generate_world__spawn_additional_objects_no_guardian_statue2
	ld c, 2  ; lost temple
	call pcg_generate_world__spawn_additional_objects_sample_node_from_area  ; hl = ptr to node
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue2
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
	pop de
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue2
	ld b, TAG_GUARDIAN_CAIMAN2
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
pcg_generate_world__spawn_additional_objects_no_guardian_statue2:

	ld a, (current_world__stela_status)
	bit 2, a  ; middle stela
	jr z, pcg_generate_world__spawn_additional_objects_no_guardian_statue3
	ld c, 4  ; inverted pyramid
	call pcg_generate_world__spawn_additional_objects_sample_node_from_area  ; hl = ptr to node
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue3
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
	pop de
	jr nz, pcg_generate_world__spawn_additional_objects_no_guardian_statue3
	ld b, TAG_GUARDIAN_CAIMAN3
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
pcg_generate_world__spawn_additional_objects_no_guardian_statue3:

    ; lost vendor: pick a random tagless division from area 2:
	ld c, 2  ; lost temple
	call pcg_generate_world__spawn_additional_objects_sample_node_from_area  ; hl = ptr to node
	ret nz
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
	pop de  ; mdl-watch2: "lost vendor:", c, b, l
	ret nz
	ld b, TAG_LOST_VENDOR
	call pcg_generate_world__add_tag_to_point_in_mst_node_division
	ret nz

    ; spawn maya secret puzzle clues
    ld b, 7
pcg_generate_world__spawn_additional_objects_maya_clues_loop:
	push bc
		call pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11  ; hl = ptr to node
		ret nz
		push hl
			call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
		pop de  ; mdl-watch2: "maya secret puzzle clue:", c, b, l
		ret nz
	pop bc
	push bc
		; DEBUG
; 		ld a, (de)  ; mdl-watch: "    area div: ", a
		; DEBUG
		ld a, 7
		sub b
		add a, TAG_MAYA_RIDDLE_CLUE1
		ld b, a
		call pcg_generate_world__add_tag_to_point_in_mst_node_division
		ret nz
	pop bc
	djnz pcg_generate_world__spawn_additional_objects_maya_clues_loop

    ; weapons, map pieces, hearts, teleporters
    xor a
    ld (tmp_pcg_world__n_small_keys), a
    ld b, (pcg_world__optional_object_table_end - pcg_world__optional_object_table) / 4
    ld ix, pcg_world__optional_object_table
pcg_generate_world__spawn_additional_objects_other_object_loop:
	; DEBUG START
; 	push hl
; 		ld hl, (rng_seed1)  ; mdl-watch: "test__optional_objects seed1", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "test__optional_objects seed2", hl
; 	pop hl
	; DEBUG END
	push bc
		ld a, (ix)  ; tag
		cp TAG_SMALL_KEY1
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_small_key1
		cp TAG_SMALL_KEY2
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_small_key2
		cp TAG_SMALL_KEY3
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_small_key3
		cp TAG_SMALL_KEY4
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_small_key4
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_continue
pcg_generate_world__spawn_additional_objects_other_object_loop_small_key1:
		ld a, (tmp_pcg_world__n_small_keys)
		cp 1 
		jp c, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_continue
pcg_generate_world__spawn_additional_objects_other_object_loop_small_key2:
		ld a, (tmp_pcg_world__n_small_keys)
		cp 2 
		jp c, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_continue
pcg_generate_world__spawn_additional_objects_other_object_loop_small_key3:
		ld a, (tmp_pcg_world__n_small_keys)
		cp 3 
		jp c, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_continue
pcg_generate_world__spawn_additional_objects_other_object_loop_small_key4:
		ld a, (tmp_pcg_world__n_small_keys)
		cp 4
		jp c, pcg_generate_world__spawn_additional_objects_other_object_loop_next
pcg_generate_world__spawn_additional_objects_other_object_loop_continue:
		ld a, (ix + 2)
		cp #ff
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn
		call random_a
		cp (ix + 2)  ; probability of spawning  ; mdl-watch2: "  spawn?", a
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn
		jp nc, pcg_generate_world__spawn_additional_objects_other_object_loop_next
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn:
		ld a, (ix + 1)  ; area
		cp #ff  ; any area
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_any_area
		cp #fe  ; areas 1, 2, 3, 4
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_area_1_2_3_4
		cp #fd  ; areas 10, 11
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_area_10_11
		ld c, a  ; mdl-watch2: "area: ", c
		push ix
			call pcg_generate_world__spawn_additional_objects_sample_node_from_area  ; hl = ptr to node
		pop ix
; 		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop
		jp nz, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_node_sampled
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_area_1_2_3_4:
		push ix
			call pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4  ; hl = ptr to node
		pop ix
; 		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop
		jp nz, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_node_sampled
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_area_10_11:
		push ix
			call pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11  ; hl = ptr to node
		pop ix
; 		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop
		jp nz, pcg_generate_world__spawn_additional_objects_other_object_loop_next
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_node_sampled
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_any_area:
		push ix
			call pcg_generate_world__spawn_additional_objects_sample_node_from_any_area  ; hl = ptr to node
		pop ix
; 		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop
		jp nz, pcg_generate_world__spawn_additional_objects_other_object_loop_next
pcg_generate_world__spawn_additional_objects_other_object_loop_node_sampled:
		push hl
		push ix
			call pcg_generate_world__random_division_point_from_mst_node_tagless  ; c, b: x, y, l: offset
		pop ix
		pop de  ; mdl-watch2: "other object:", c, b, l
		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop

		ld a, (tmp_pcg_world__n_small_keys)
		cp 4
		jr nc, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_without_small_chest
		ld a, (ix + 3)
		or a
		jr z, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_without_small_chest
		call random_a
		cp (ix + 3)  ; probability of small chest
		jr nc, pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_without_small_chest
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_with_small_chest:
		; spawn with small chest:
		ld a, (tmp_pcg_world__n_small_keys)
		inc a
		ld (tmp_pcg_world__n_small_keys), a
		add a, TAG_SMALL_KEY_CHEST1 - 1  ; "- 1" to undo the "inc a" above
		ld iyh, a  ; chest
		ld b, (ix)  ; tag  ; mdl-watch2: "other object (with small key chest):", b, iyh
		push hl
		push de
			call pcg_generate_world__add_b_to_chest_content
		pop de
		pop hl
		ld b, iyh
		jr pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_with_small_chest_entry_point
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_without_small_chest:
		ld b, (ix)  ; tag  ; mdl-watch2: "other object:", b
pcg_generate_world__spawn_additional_objects_other_object_loop_spawn_with_small_chest_entry_point:
		push ix
			call pcg_generate_world__add_tag_to_point_in_mst_node_division
		pop ix
		jp nz, pcg_generate_world__spawn_additional_objects_fail_pop
pcg_generate_world__spawn_additional_objects_other_object_loop_next:
		ld de, 4
		add ix, de
	pop bc
	dec b
	jp nz, pcg_generate_world__spawn_additional_objects_other_object_loop

    xor a  ; z
	ret

pcg_generate_world__spawn_additional_objects_fail_pop:
	pop bc
	or 1  ; nz  ; mdl-watch2: "pcg_generate_world__spawn_additional_objects_fail_pop", b
	ret


;-----------------------------------------------
get_not_spawned_item_tags_table:
	db TAG_WEAPON_BLOWGUN  ; this one the first to ensure it will be in the shop if unspawned
	db TAG_WEAPON_HAMMER
	db TAG_WEAPON_MACUAHUITL
	db TAG_WEAPON_SHIELD
	db TAG_WEAPON_SLING
	db TAG_WEAPON_ATLATL
	db TAG_WEAPON_RAYGUN
	db TAG_WEAPON_OBSIDIAN_KNIVE
	db TAG_WEAPON_FIRE_HAMMER
	db TAG_WEAPON_ICE_MACUAHUITL
	db TAG_ITEM_SANDALS
	db TAG_ITEM_GLOVES
	db TAG_ITEM_WARRIOR_HAT
	db TAG_ITEM_ARMOR
	db TAG_ITEM_CHAAC
	db TAG_ITEM_SEASHELL
	db TAG_ITEM_BELT
	db TAG_ITEM_ICE_CAPE
get_not_spawned_item_tags_table_end


pcg_generate_world__get_not_spawned_item_tags:
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
	ld hl, tmp_pcg_world__candidates_list
	ld (hl), 0
	inc hl
	ld (hl), 0
	dec hl

	ld ix, get_not_spawned_item_tags_table
	ld b, get_not_spawned_item_tags_table_end - get_not_spawned_item_tags_table
pcg_generate_world__get_not_spawned_item_tags_loop:
	push bc
		ld c, (ix)  ; mdl-watch2: "pcg_generate_world__get_not_spawned_item_tags", c
		call pcg_generate_world__item_spawned_p
	pop bc
	jr z, pcg_generate_world__get_not_spawned_item_tags_loop_next
	ld hl, tmp_pcg_world__candidates_list_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__candidates_list
	ADD_HL_A
	ld a, (ix)  ; mdl-watch2: "    not spawned"
	ld (hl), a
pcg_generate_world__get_not_spawned_item_tags_loop_next:
	inc ix
	djnz pcg_generate_world__get_not_spawned_item_tags_loop

	ret


;-----------------------------------------------
; input:
; - c: item
; output:
; - z: spawned
; - nz: not spawned
pcg_generate_world__item_spawned_p:
	ld hl, tmp_pcg_world__area_0_tags
	ld b, MAX_WORLD_AREAS
pcg_generate_world__item_spawned_p_area_loop:
	push bc
		push hl
			ld b, MAX_AREA_N_TAGS
pcg_generate_world__item_spawned_p_tag_loop:
			ld a, (hl)
			cp c
			jr z, pcg_generate_world__item_spawned_p_found
			cp #ff
			jr z, pcg_generate_world__item_spawned_p_tag_loop_done
			inc hl
			inc hl
			inc hl
			djnz pcg_generate_world__item_spawned_p_tag_loop
pcg_generate_world__item_spawned_p_tag_loop_done:
		pop hl
		ld de, WORLD_AREA__SIZE
		add hl, de
	pop bc
	djnz pcg_generate_world__item_spawned_p_area_loop

	; check if it's within chest tag:
	ld hl, current_world__chest_content + 1
	ld b, MAX_CHESTS
pcg_generate_world__item_spawned_p_chest_loop:
	ld a, (hl)
	cp c
	jr z, pcg_generate_world__item_spawned_p_found_no_pop
	cp #ff
	jr z, pcg_generate_world__item_spawned_p_chest_loop_done
	inc hl
	inc hl
	djnz pcg_generate_world__item_spawned_p_chest_loop
pcg_generate_world__item_spawned_p_chest_loop_done:
	or 1  ; nz
	ret

pcg_generate_world__item_spawned_p_found:
		pop hl
	pop bc
pcg_generate_world__item_spawned_p_found_no_pop:
	xor a ; z
	ret


;-----------------------------------------------
; input:
; - c: target area
; output:
; - hl: ptr to node
; - z: success
; - nz: failure
pcg_generate_world__spawn_additional_objects_sample_node_from_area:
	ld hl, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	ld b, a
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_from_area_fail
	ld ixl, 0  ; number of matches
pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc de
	ld a, (de)  ; MST_AREA_ID
	cp c
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop_next
; 	dec de  ; DEBUG
; 	ld a, (de)  ; DEBUG mdl-watch: "    tag less candidate div", a
	inc ixl
pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop
	ld a, ixl
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_from_area_fail
	push bc
		ld c, a
		call random_modulo
		ld ixl, a  ; selected node, mdl-watch2: "additional objects candidates chosen/candidates:", a, c
	pop bc

	; second loop, copying the list to a new location, skipping the selected one (to
	; remove it):
	; - copy the list to "tmp_pcg_world__useable_nodes" (without the selected one)
	; - then copy it back to "tmp_pcg_world__tagless_list"
	; - decrease its size by 1 
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	dec (hl)
	ld hl, tmp_pcg_world__tagless_list
	ld de, tmp_pcg_world__useable_nodes
	ld b, a
pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2:
	push de
		ld e, (hl)
		inc hl
		ld d, (hl)
		dec hl
		inc de
		ld a, (de)  ; MST_AREA_ID
		cp c
	pop de
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2_no_match
	; match:
	ld a, ixl
	dec ixl
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2_no_match
	; found!
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	inc hl
	jr pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2_next
pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2_no_match:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de	
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_from_area_loop2

	ld hl, tmp_pcg_world__useable_nodes
	ld de, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	add a, a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_from_area_no_copy
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__spawn_additional_objects_sample_node_from_area_no_copy:

	push iy
	pop hl

	xor a  ; z
	ret
pcg_generate_world__spawn_additional_objects_sample_node_from_area_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; output:
; - hl: ptr to node
; - z: success
; - nz: failure
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11:
	ld hl, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	ld b, a
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_fail
	ld ixl, 0  ; number of matches
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc de
	ld a, (de)  ; MST_AREA_ID
	cp 10
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop_next
	cp 11
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop_next
; 	dec de  ; DEBUG
; 	ld a, (de)  ; DEBUG  mdl-watch: "except_10_11 div", a
	inc ixl
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop
	ld a, ixl
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_fail
	push bc
		ld c, a
		call random_modulo
		ld ixl, a  ; selected node, mdl-watch2: "additional objects candidates chosen/candidates:", a, c
	pop bc

	; second loop, copying the list to a new location, skipping the selected on (to
	; remove it):
	; - copy the list to "tmp_pcg_world__useable_nodes" (without the selected one)
	; - then copy it back to "tmp_pcg_world__tagless_list"
	; - decrease its size by 1 
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	dec (hl)
	ld hl, tmp_pcg_world__tagless_list
	ld de, tmp_pcg_world__useable_nodes
	ld b, a
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2:
	push de
		ld e, (hl)
		inc hl
		ld d, (hl)
		dec hl
		inc de
		ld a, (de)  ; MST_AREA_ID
	pop de
	cp 10
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_no_match
	cp 11
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_no_match
	; match:
	ld a, ixl
	dec ixl
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_no_match
	; found!
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	inc hl
	jr pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_next
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_no_match:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de	
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_loop2

	ld hl, tmp_pcg_world__useable_nodes
	ld de, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	add a, a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_no_copy
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_no_copy:
	push iy
	pop hl

	xor a  ; z
	ret
pcg_generate_world__spawn_additional_objects_sample_node_except_areas_10_11_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; output:
; - hl: ptr to node
; - z: success
; - nz: failure
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4:
	ld hl, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	ld b, a
	or a
	jp z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_fail
	ld ixl, 0  ; number of matches
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc de
	ld a, (de)  ; MST_AREA_ID
	cp 1
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_match
	cp 2
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_match
	cp 3
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_match
	cp 4
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_match
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_next
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_match:
	inc ixl
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop
	ld a, ixl
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_fail
	push bc
		ld c, a
		call random_modulo
		ld ixl, a  ; selected node, mdl-watch2: "additional objects candidates chosen/candidates:", a, c
	pop bc

	; second loop, copying the list to a new location, skipping the selected on (to
	; remove it):
	; - copy the list to "tmp_pcg_world__useable_nodes" (without the selected one)
	; - then copy it back to "tmp_pcg_world__tagless_list"
	; - decrease its size by 1 
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	dec (hl)
	ld hl, tmp_pcg_world__tagless_list
	ld de, tmp_pcg_world__useable_nodes
	ld b, a
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2:
	push de
		ld e, (hl)
		inc hl
		ld d, (hl)
		dec hl
		inc de
		ld a, (de)  ; MST_AREA_ID
	pop de
	cp 1
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_match
	cp 2
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_match
	cp 3
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_match
	cp 4
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_match
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_no_match
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_match:
	; match:
	ld a, ixl
	dec ixl
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_no_match
	; found!
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	inc hl
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_next
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_no_match:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de	
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_loop2

	ld hl, tmp_pcg_world__useable_nodes
	ld de, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	add a, a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_no_copy
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_no_copy:
	push iy
	pop hl

	xor a  ; z
	ret
pcg_generate_world__spawn_additional_objects_sample_node_areas_1_2_3_4_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; output:
; - hl: ptr to node
; - z: success
; - nz: failure
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11:
	ld hl, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	ld b, a
	or a
	jp z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_fail
	ld ixl, 0  ; number of matches
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop:
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	inc de
	ld a, (de)  ; MST_AREA_ID
	cp 10
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop_match
	cp 11
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop_match
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop_next
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop_match:
	inc ixl
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop
	ld a, ixl
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_fail
	push bc
		ld c, a
		call random_modulo
		ld ixl, a  ; selected node, mdl-watch2: "additional objects candidates chosen/candidates:", a, c
	pop bc

	; second loop, copying the list to a new location, skipping the selected on (to
	; remove it):
	; - copy the list to "tmp_pcg_world__useable_nodes" (without the selected one)
	; - then copy it back to "tmp_pcg_world__tagless_list"
	; - decrease its size by 1 
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	dec (hl)
	ld hl, tmp_pcg_world__tagless_list
	ld de, tmp_pcg_world__useable_nodes
	ld b, a
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2:
	push de
		ld e, (hl)
		inc hl
		ld d, (hl)
		dec hl
		inc de
		ld a, (de)  ; MST_AREA_ID
	pop de
	cp 10
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_match
	cp 11
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_match
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_no_match
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_match:
	; match:
	ld a, ixl
	dec ixl
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_no_match
	; found!
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	inc hl
	jr pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_next
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_no_match:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de	
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_loop2

	ld hl, tmp_pcg_world__useable_nodes
	ld de, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	add a, a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_no_copy
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_no_copy:
	push iy
	pop hl

	xor a  ; z
	ret
pcg_generate_world__spawn_additional_objects_sample_node_areas_10_11_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; output:
; - hl: ptr to node
; - z: success
; - nz: failure
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area:
	ld a, (tmp_pcg_world__tagless_list_size)
	or a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_fail
	ld c, a
	call random_modulo
	ld ixl, a  ; selected node, mdl-watch2: "additional objects candidates chosen/candidates:", a, c

	; second loop, copying the list to a new location, skipping the selected on (to
	; remove it):
	; - copy the list to "tmp_pcg_world__useable_nodes" (without the selected one)
	; - then copy it back to "tmp_pcg_world__tagless_list"
	; - decrease its size by 1 
	ld hl, tmp_pcg_world__tagless_list_size
	ld a, (hl)
	dec (hl)
	ld hl, tmp_pcg_world__tagless_list
	ld de, tmp_pcg_world__useable_nodes
	ld b, a
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2:
	push de
		ld e, (hl)
		inc hl
		ld d, (hl)
		dec hl
		inc de
		ld a, (de)  ; MST_AREA_ID
	pop de
	ld a, ixl
	dec ixl
	or a
	jr nz, pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2_no_match
	; found!
	ld a, (hl)
	ld iyl, a
	inc hl
	ld a, (hl)
	ld iyh, a
	inc hl
	jr pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2_next
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2_no_match:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de	
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2_next:
	djnz pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_loop2

	ld hl, tmp_pcg_world__useable_nodes
	ld de, tmp_pcg_world__tagless_list
	ld a, (tmp_pcg_world__tagless_list_size)
	add a, a
	jr z, pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_no_copy
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_no_copy:

	push iy
	pop hl

	xor a  ; z
	ret
pcg_generate_world__spawn_additional_objects_sample_node_from_any_area_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
pcg_generate_world__generate_tag_data:
	ld de, tmp_pcg_world__tags
	ld hl, tmp_pcg_world__area_0_tags
	ld b, MAX_WORLD_AREAS
pcg_generate_world__generate_tag_data_area_loop:
	push bc
		push hl
			push de
				ld bc, MAX_AREA_N_TAGS * 3 - 1
				call clear_memory
			pop hl
			push hl
				; Get all the placed tags in the area: tag + offset
				call pcg_generate_world__generate_sorted_area_tag_list  ; list goes to "tmp_pcg_world__tag_list"
			pop de
		pop hl

		push hl
		push de
			call pcg_generate_world__generate_tag_data_internal
		pop de
		pop hl

		; Advance the pointers
		ld bc, WORLD_AREA__SIZE
		add hl, bc
		ex de, hl
			ld bc, MAX_AREA_SIZE * 2
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_world__generate_tag_data_area_loop

	; extra shop items:
	call pcg_generate_world__get_not_spawned_item_tags  ; fills tmp_pcg_world__candidates_list
	ld hl, tmp_pcg_world__candidates_list
	ld de, current_world__shop_extra_items
	ldi
	ldi

	ret


;-----------------------------------------------
; input:
; - hl: pointer to the tag area data to generate
pcg_generate_world__generate_tag_data_internal:
	ld a, (tmp_pcg_world__tag_list_size)  ; mdl-watch2: "pcg_generate_world__generate_tag_data_internal", hl
	ld b, a
	or a
	jr z, pcg_generate_world__generate_tag_data_internal_loop_done
	ld de, tmp_pcg_world__tag_list
pcg_generate_world__generate_tag_data_internal_loop:
	; For each tag:
	ld a, (de)

	; check if it's within a chest:
	push hl
		call pcg_generate_world__tag_is_in_a_chest_p
	pop hl
	jr z, pcg_generate_world__generate_tag_data_internal_loop_next

	ld iyl, 0  ; default direction:
	; check if it's a lock in tmp_pcg_world__lock_directions, and get its direction:
	push hl
	push bc
		ld a, (tmp_pcg_world__lock_directions_size)
		ld hl, tmp_pcg_world__lock_directions
		or a
		jr z, pcg_generate_world__generate_tag_data_internal_lock_direction_loop_done
		ld b, a
		ld a, (de)  ; recover the tag
pcg_generate_world__generate_tag_data_internal_lock_direction_loop:
		cp (hl)
		jr nz, pcg_generate_world__generate_tag_data_internal_lock_direction_loop_next
		inc hl
		ld a, (hl)  ; lock direction
		ld iyl, a
		jr pcg_generate_world__generate_tag_data_internal_lock_direction_loop_done
pcg_generate_world__generate_tag_data_internal_lock_direction_loop_next:
		inc hl
		inc hl
		djnz pcg_generate_world__generate_tag_data_internal_lock_direction_loop
pcg_generate_world__generate_tag_data_internal_lock_direction_loop_done:
	pop bc
	pop hl

	ld a, (de)  ; tag
	ld (hl), a  ; mdl-watch2: "  area tags", hl, a
	inc hl
	inc de
	ld a, (de)  ; offset, mdl-watch2: "      offset", a
	ld (hl), a
	inc hl
	inc de
	ld a, iyl  ; direction
	ld (hl), a
	inc hl
	jr pcg_generate_world__generate_tag_data_internal_loop_next_no_inc

pcg_generate_world__generate_tag_data_internal_loop_next:
	inc de
	inc de
pcg_generate_world__generate_tag_data_internal_loop_next_no_inc:
	djnz pcg_generate_world__generate_tag_data_internal_loop
pcg_generate_world__generate_tag_data_internal_loop_done:
; 	ld (hl), #ff  ; sentinel
	ret


;-----------------------------------------------
; input:
; - a: tag
; output:
; - z: tag is within a chest
; - nz: tag is not within a chest
pcg_generate_world__tag_is_in_a_chest_p:
	ld c, a
	ld hl, current_world__chest_content
pcg_generate_world__tag_is_in_a_chest_p_loop:
	ld a, (hl)
	cp #ff
	jr z, pcg_generate_world__tag_is_in_a_chest_p_not_found
	inc hl
	ld a, (hl)
	cp c
	ret z  ; found
	inc hl
	jr pcg_generate_world__tag_is_in_a_chest_p_loop
pcg_generate_world__tag_is_in_a_chest_p_not_found:
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - hl: ptr to the entry of the corresponding area in "tmp_pcg_world__tags".
pcg_generate_world__generate_sorted_area_tag_list:
	ld de, tmp_pcg_world__tag_list  ; mdl-watch2: "pcg_generate_world__generate_sorted_area_tag_list"
	ld iyl, 0  ; list size
	ld b, MAX_AREA_SIZE
pcg_generate_world__generate_sorted_area_tag_list_loop:
	ld a, (hl)
	or a
	jr z, pcg_generate_world__generate_sorted_area_tag_list_loop_next2
	; there is a tag:
	ld (de), a  ; tag  ; mdl-watch2: "    tag 1: ", a
	inc de
	ld a, b
	sub MAX_AREA_SIZE
	neg
	ld (de), a  ; offset  ; mdl-watch2: "    offset 1: ", a
	inc de
	inc iyl

	inc hl
	ld a, (hl)
	or a
	jr z, pcg_generate_world__generate_sorted_area_tag_list_loop_next1
	; there is a second tag:
	ld (de), a  ; tag  ; mdl-watch2: "    tag 2: ", a
	inc de
	ld a, b
	sub MAX_AREA_SIZE
	neg
	ld (de), a  ; offset  ; mdl-watch2: "    offset 2: ", a
	inc de
	inc iyl
	jr pcg_generate_world__generate_sorted_area_tag_list_loop_next1

pcg_generate_world__generate_sorted_area_tag_list_loop_next2:
	inc hl
pcg_generate_world__generate_sorted_area_tag_list_loop_next1:
	inc hl

	djnz pcg_generate_world__generate_sorted_area_tag_list_loop

	ld a, iyl
	ld (tmp_pcg_world__tag_list_size), a  ; mdl-watch2:  "    n tags:", a

pcg_generate_world__generate_sorted_area_tag_list_sort:
	; Sort them by increasing TAG (bubble sort):
	ld a, iyl
	cp 2
	ret c

	ld b, iyl
	dec b
pcg_generate_world__generate_sorted_area_tag_list_sort_loop1:
	push bc
		ld hl, tmp_pcg_world__tag_list
		ld de, tmp_pcg_world__tag_list + 2
		ld ixl, 0  ; no swap
pcg_generate_world__generate_sorted_area_tag_list_sort_loop2:
		ld a, (de)
		cp (hl)
		jr nc, pcg_generate_world__generate_sorted_area_tag_list_sort_loop2_next
		; swap:
		ld ixl, 1
		ld c, (hl)
		ld (hl), a
		ld a, c
		ld (de), a

		inc de
		inc hl
		ld a, (de)
		ld c, (hl)
		ld (hl), a
		ld a, c
		ld (de), a
		dec de
		dec hl

pcg_generate_world__generate_sorted_area_tag_list_sort_loop2_next:
		inc hl
		inc de
		inc hl
		inc de
		djnz pcg_generate_world__generate_sorted_area_tag_list_sort_loop2
	pop bc
	ld a, ixl
	or a
	jr z, pcg_generate_world__generate_sorted_area_tag_list_sort_done  ; no swap done in the last iteration
	djnz pcg_generate_world__generate_sorted_area_tag_list_sort_loop1
pcg_generate_world__generate_sorted_area_tag_list_sort_done:
	ret


;-----------------------------------------------
pcg_generate_world__tablet_combination_content_table:
	dw combination_tablet_type_1_fn
	dw combination_tablet_type_2_fn
	dw combination_tablet_type_3_fn
	dw combination_tablet_type_4_fn

pcg_generate_world__tablet_trivia_content_table:
	dw story_trivia_tablet_fn_story1
	dw story_trivia_tablet_fn_story2
	dw story_trivia_tablet_fn_story3
	dw story_trivia_tablet_fn_story4
	dw story_trivia_tablet_fn_story5
	dw story_trivia_tablet_fn_story6
	dw story_trivia_tablet_fn_story7
	dw story_trivia_tablet_fn_story8
	dw story_trivia_tablet_fn_story9
	dw story_trivia_tablet_fn_story10
	dw story_trivia_tablet_fn_story11
	dw story_trivia_tablet_fn_story12
	dw story_trivia_tablet_fn_story13
	dw story_trivia_tablet_fn_story14
	dw story_trivia_tablet_fn_story15
	dw story_trivia_tablet_fn_clue1
	dw story_trivia_tablet_fn_clue2
	dw story_trivia_tablet_fn_clue3
	dw story_trivia_tablet_fn_clue4
pcg_generate_world__tablet_trivia_content_table_end:


pcg_generate_world__puzzles:
	; generate tablet contents:
	; DEBUG-start
; 	push hl  
; 		ld hl, (rng_seed1)  ; mdl-watch: "test__pcg_generate_world__puzzles seed1: ", hl
; 		ld hl, (rng_seed2)  ; mdl-watch: "test__pcg_generate_world__puzzles seed2: ", hl
; 	pop hl
	; DEBUG-end

	ld hl, current_world__tablet_content
	ld bc, MAX_TABLETS * 3 + 1 - 1
	ld a, #ff
	call clear_memory_a

	; combination clues:
	ld c, 4
	call random_modulo
	ld hl, pcg_generate_world__tablet_combination_content_table
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, TAG_COMBINATION1_CLUE
	call pcg_generate_world__add_tablet_content

	ld c, 4
	call random_modulo
	ld hl, pcg_generate_world__tablet_combination_content_table
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, TAG_COMBINATION2_CLUE
	call pcg_generate_world__add_tablet_content

	ld c, 4
	call random_modulo
	ld hl, pcg_generate_world__tablet_combination_content_table
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, TAG_COMBINATION3_CLUE
	call pcg_generate_world__add_tablet_content

	ld c, 4
	call random_modulo
	ld hl, pcg_generate_world__tablet_combination_content_table
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, TAG_COMBINATION4_CLUE
	call pcg_generate_world__add_tablet_content

	ld a, TAG_TRIAL1_CLUE
	ld de, trial_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_TRIAL2_CLUE
	ld de, trial_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_TRIAL3_CLUE
	ld de, trial_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_TRIAL4_CLUE
	ld de, trial_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE1
	ld de, maya_clue1_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE2
	ld de, maya_clue2_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE3
	ld de, maya_clue3_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE4
	ld de, maya_clue4_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE5
	ld de, maya_clue5_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE6
	ld de, maya_clue6_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, TAG_MAYA_RIDDLE_CLUE7
	ld de, maya_clue7_tablet_fn
	call pcg_generate_world__add_tablet_content

	ld a, (pcg_generate_world__tablet_trivia_content_table_end - pcg_generate_world__tablet_trivia_content_table)/2
	ld (tmp_pcg_world__candidates_list_size), a
	ld b, a
	ld hl, tmp_pcg_world__candidates_list
	xor a
pcg_generate_world__puzzles_trivia_loop:
	ld (hl), a
	inc hl
	inc a
	djnz pcg_generate_world__puzzles_trivia_loop

	ld b, 8
pcg_generate_world__puzzles_trivia_loop2:
	push bc
		ld a, (tmp_pcg_world__candidates_list_size)
		ld c, a
		call random_modulo
		ld hl, tmp_pcg_world__candidates_list
		ADD_HL_A
		ld a, (hl)
		push af
			add a, a
			ld hl, pcg_generate_world__tablet_trivia_content_table
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			
			ld a, TAG_STORY_TRIVIA1
			sub b
			add a, 8
			call pcg_generate_world__add_tablet_content
		pop af
		ld c, a

		; remove from candidate list
		ld hl, tmp_pcg_world__candidates_list
		ld de, tmp_pcg_world__candidates_list
		ld a, (tmp_pcg_world__candidates_list_size)
		ld b, a
		dec a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__puzzles_trivia_loop2_remove_loop:
		ld a, (hl)
		inc hl
		ld (de), a
		inc de
		cp c
		jr nz, pcg_generate_world__puzzles_trivia_loop2_remove_loop_skip
		dec de
pcg_generate_world__puzzles_trivia_loop2_remove_loop_skip:
		djnz pcg_generate_world__puzzles_trivia_loop2_remove_loop
	pop bc
	djnz pcg_generate_world__puzzles_trivia_loop2

	ld a, TAG_CALENDAR_NAME_CLUE
	ld de, calendar_name_clue_tablet_fn
	call pcg_generate_world__add_tablet_content

	; combination solutions:
	ld hl, current_world__combination_solutions
	ld b, 4 * 8
pcg_generate_world__puzzles_combination_loop:
	ld c, 3
	call random_modulo
	ld (hl), a
	inc hl
	djnz pcg_generate_world__puzzles_combination_loop

	; trial types:
	ld hl, current_world__trial_types
	ld b, 4
pcg_generate_world__puzzles_trial_types_loop:
	ld c, 8
	call random_modulo
	ld (hl), a
	inc hl
	djnz pcg_generate_world__puzzles_trial_types_loop

	; power stone numbers:
	ld hl, current_world__power_stone_numbers
	ld b, 5
pcg_generate_world__puzzles_power_numbers_loop:
	ld c, 8
	call random_modulo
	inc a
	ld (hl), a
	inc hl
	djnz pcg_generate_world__puzzles_power_numbers_loop

	call pcg_generate_maya_puzzle_riddles
	call pcg_generate_syllable_riddles
	jp pcg_generate_atlantis_boss_riddle


;-----------------------------------------------
pcg_generate_world__puzzles_stelae_status:
	; stella condition bits, based on the random seed:
	ld l, 0
	ld de, (current_world__seed)
	ld a, d
	and #03
	ld c, a
	ld a, e
	and #c0
	or c
	jr nz, pcg_generate_world__puzzles_stela_center_set
	ld l, 4
pcg_generate_world__puzzles_stela_center_set:
	; count the number of 1 bits:
	xor a
	ld b, 8
pcg_generate_world__puzzles_stela_loop1:
	rrc e
	adc a, 0
	djnz pcg_generate_world__puzzles_stela_loop1
	ld b, 8
pcg_generate_world__puzzles_stela_loop2:
	rrc d
	adc a, 0
	djnz pcg_generate_world__puzzles_stela_loop2
	; if it's an even number, left stella is active, if it's an odd one, right stella is active:
	and #01
	jr z, pcg_generate_world__puzzles_stela_left_active
	set 1, l
	jr pcg_generate_world__puzzles_stela_set
pcg_generate_world__puzzles_stela_left_active:
	set 0, l
pcg_generate_world__puzzles_stela_set:
	ld a, l
	ld (current_world__stela_status), a	
	ret


;-----------------------------------------------
; input:
; - a: tag
; - de: fn
pcg_generate_world__add_tablet_content:
	ld hl, current_world__tablet_content
	ld c, a
pcg_generate_world__add_tablet_content_loop:
	ld a, (hl)
	cp #ff
	jr z, pcg_generate_world__add_tablet_content_loop_end
	inc hl
	inc hl
	inc hl
	jr pcg_generate_world__add_tablet_content_loop
pcg_generate_world__add_tablet_content_loop_end:
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	ret


;-----------------------------------------------
; input:
; - a: area
; - c, b: x, y
; output:
; - a: offset
pcg_generate_world__layout_offset_from_c_b_area:
	push bc
		call pcg_generate_world__get_area_ptr
		ld bc, 5
		add hl, bc
		ld a, (hl)  ; width
		ld ixl, a
	pop bc
	; jp pcg_generate_world__layout_offset_from_c_b_ixl


;-----------------------------------------------
; input:
; - ixl: width
; - c, b: x, y
; output:
; - a: offset
pcg_generate_world__layout_offset_from_c_b_ixl:
	ld a, b
	or a
	jr z, pcg_generate_world__layout_offset_from_c_b_ixl_loop_done
	xor a
	push bc
pcg_generate_world__layout_offset_from_c_b_ixl_loop:
		add a, ixl
		djnz pcg_generate_world__layout_offset_from_c_b_ixl_loop
	pop bc
pcg_generate_world__layout_offset_from_c_b_ixl_loop_done:
	add a, c
	ret


;-----------------------------------------------
; input:
; - a: area ID
; output:
; - hl: area ptr
pcg_generate_world__get_area_ptr:
	ld hl, current_world__area_data
	or a
	ret z
	ld bc, WORLD_AREA__SIZE
pcg_generate_world__get_area_ptr_loop:
	add hl, bc
	dec a
	jr nz, pcg_generate_world__get_area_ptr_loop
	ret

