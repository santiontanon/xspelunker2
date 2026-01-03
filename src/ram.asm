;-----------------------------------------------
; RAM:
; mdl:page 0
    org #c000   ; RAM goes to the 4th page
RAM:
buffer_4096: ds virtual 4096

text_draw_buffer: ds virtual 32*8

current_world__name: ds virtual 16
current_world__difficulty: ds virtual 1  ; 0: easy, 1: normal, 2: hard, 3: hardest (updated in "gamestart_draw_difficulty")
; difficulty settings (derived from 'current_world__difficulty'):
current_world__difficulty_attack_warn_time: ds virtual 1
current_world__difficulty_bullet_speed: ds virtual 1


current_world__seed: ds virtual 4
; WORLD_AREA__SIZE: 4 + 1 + 1 + 1 + MAX_AREA_SIZE * 2 + MAX_AREA_N_TAGS * 3
; each world area is:
; - seed: 4 bytes
; - id: 1 byte
; - width, height: 1 + 1 bytes
; - connections: MAX_AREA_SIZE bytes
; - divisionIDs: MAX_AREA_SIZE bytes
; - tags: MAX_AREA_N_TAGS * 3
current_world__area_data: ds virtual WORLD_AREA__SIZE * MAX_WORLD_AREAS
; each connection is 8 bytes: ; id1, id2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
current_world__interarea_connections: ds virtual MAX_INTERAREA_CONNECTIONS * INTERAREA_CONNECTION_SIZE + 1  ; +1 byte for the #ff sentinel
current_world__chest_content: ds virtual MAX_CHESTS * 2 + 1  ; chest_tag, content_tag (+1 byte for the #ff sentinel)
current_world__tablet_content: ds virtual MAX_TABLETS * 3 + 1  ; tablet_tag, content_ptr (+1 byte for the #ff sentinel)
current_world__combination_solutions: ds virtual 4 * 8
current_world__trial_types: ds virtual 4
current_world__power_stone_numbers: ds virtual 5
current_world__shop_extra_items: ds virtual 2
current_world__maya_puzzle_riddles: ds virtual 3 * 2  ; 2 sentences of 3 bytes each
current_world__maya_puzzle2_combination1: ds virtual 4
current_world__maya_puzzle2_combination2: ds virtual 4
current_world__maya_puzzle3_nametable: ds virtual 10*3
current_world__maya_puzzle3_word: ds virtual 20


current_area__seed: ds virtual 4
current_area__id: ds virtual 1
current_area__width: ds virtual 1  ; in rooms
current_area__height: ds virtual 1  ; in rooms
current_area__room_ids: ds virtual MAX_AREA_SIZE
current_area__chunks_ids: ds virtual MAX_AREA_SIZE * 2 * 2
current_area__objects: ds virtual MAX_AREA_N_OBJECTS * AREA_OBJECT_STRUCT_SIZE
current_area__special_room_room_id_offset: ds virtual 1  ; used to identify the location of the calendar/teleporter room, for collisions
current_area__special_room_chunk_id_offset: ds virtual 1  ; used to identify the location of the calendar/teleporter room, for collisions

current_area__n_chunk_banks: ds virtual 1
current_area__chunks_page: ds virtual 1
current_area__chunk_fg_bank_ptrs: ds virtual 2
current_area__standard_chunk_pool_ptr: ds virtual 2
current_area__boss_chunk_pool_ptr: ds virtual 2
current_area__block_chunk_pool_ptr: ds virtual 2
current_area__combination_chunk_pool_ptr: ds virtual 2
current_area__chunk_flags_ptr: ds virtual 2
current_area__chunk_edgecollisions_ptr: ds virtual 2
current_area__standard_chunk_pool_size: ds virtual 1
current_area__standard_chunk_pool_first_id: ds virtual 1
current_area__boss_chunk_pool_size: ds virtual 1
current_area__boss_chunk_pool_first_id: ds virtual 1
current_area__block_chunk_pool_size: ds virtual 1
current_area__block_chunk_pool_first_id: ds virtual 1
current_area__combination_chunk_pool_size: ds virtual 1
current_area__combination_chunk_pool_first_id: ds virtual 1


current_room__id: ds virtual 1
current_room__x: ds virtual 1  ; coordinates within the area of the top-left room corner (in "screens")
current_room__y: ds virtual 1
current_room__width_in_screens: ds virtual 1
current_room__height_in_screens: ds virtual 1
current_room__width: ds virtual 1
current_room__height: ds virtual 1
current_room__tile_map: ds virtual MAX_ROOM_SIZE
current_room__max_scroll_x: ds virtual 1
current_room__max_scroll_y: ds virtual 1
    ; We separate the sprite objects into 4 groups: player, player bullets, enemies, and other objects
current_room__player_bullets: ds virtual MAX_ROOM_PLAYER_BULLETS * ROOM_OBJECT_STRUCT_SIZE
current_room__player_bullets_sentinel: ds virtual 1  ; set to #ff
current_room__sprite_enemies: ds virtual MAX_ROOM_SPRITE_ENEMIES * ROOM_OBJECT_STRUCT_SIZE
current_room__sprite_enemies_sentinel: ds virtual 1  ; set to #ff
current_room__sprite_objects: ds virtual MAX_ROOM_SPRITE_OBJECTS * ROOM_OBJECT_STRUCT_SIZE
current_room__sprite_objects_sentinel: ds virtual 1  ; set to #ff
current_room__tile_objects: ds virtual MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE
current_room__tile_objects_sentinel: ds virtual 1  ; set to #fe
current_room__trial_fn: ds virtual 2
current_room__tileset_page: ds virtual 1
current_room__tileset_ptr: ds virtual 2
current_room__animation_fn_ptr: ds virtual 2
current_room__collision_ptr_page: ds virtual 1
current_room__collision_ptr: ds virtual 2  ; 256 bytes of this ptr will be copied to 'current_room__collision_table'.
current_room__enemy_sprites_ptr: ds virtual 2
current_room__tileset_overrides_item_tiles: ds virtual 1
current_room__collision_table: ds virtual 256
; Variables to remember which enemies have already been killed,
; and do not respawn them unless you go a few rooms away and come back:
current_room__initial_enemy_ids: ds virtual MAX_ROOM_SPRITE_ENEMIES + 1 + 1  ; IDs of the enemies that are spawned at room start (the "+ 1 + 1" is for the one possible tile enemy, and for the sentinel byte)
current_room__initial_enemy_ids_end:

state_play_update_agenda_tbl_ptr: ds virtual 2

RAM_to_zero_on_game_start:

; initialized to #ff
enemy_respawn_table: ds ENEMY_RESPAWN_TABLE_SIZE * (1 + 1 + 1 + MAX_ROOM_SPRITE_ENEMIES + 1 + 1)
    ; - time: 1 byte (how long has this been entry stored, incremented by 1 each time the player changes rooms)
    ; - area_id, room_id: 1 + 1 bytes
    ; - already_killed_enemy_ids: MAX_ROOM_SPRITE_ENEMIES + 1 + 1 bytes
enemy_respawn_table_end:


; rendering variables:
draw_room_row_offset: ds virtual 2
sprite_attribute_table: ds virtual MAX_SPRITES * 4  ; first 2 sprites are the player sprites, 3rd is player weapon
n_displayed_object_sprites: ds virtual 1
n_displayed_object_sprites_without_player_bullets: ds virtual 1
n_displayed_object_sprites_last_frame: ds virtual 1

room_desired_scroll_x: ds virtual 1
room_desired_scroll_y: ds virtual 1
room_scroll_x: ds virtual 1
room_scroll_y: ds virtual 1

; game state variables:

; for each possible unique object, we maintain its state:
; - 0: default state
; - 1: broken breakable wall, picked up item, opened lock/door
; the offset of a given object is its tag ID
global_state__objects: ds virtual N_UNIQUE_TAGS

; These are used to correct collisions in 'check_collision_with_next_chunk_left', etc.
; Specifically, if a wall/door is open, we overwrite the calculation of the method above. We keep this
; in this separate list, since we would have to re-generate a room to reconstruct this info from the
; 'global_object_state' list.
; area ID + 1, chunk, x1, y1, x2, y2
global_state__open_walls: ds virtual 6 * N_PATH_OPENING_TAGS

global_state__story: ds virtual 1
global_state__used_teleporter_before: ds virtual 1

global_state__power_calendar: ds virtual 6  ; 0: empty
                                            ; 1: inactive stone
                                            ; 2 - 7: one of the power stones 
global_state__n_power_stones_in_calendar: ds virtual 1  ; for convenience (it should be the number of elements in 'global_state__power_calendar' that are >= 2)
                                            ; 1 stone placed: teleporters activate
                                            ; 3 stones placed: opens the path to the fire shaft in "midpoint"
                                            ; 5 stones: allows for activating the stone

global_state__maya_riddle: ds virtual 1  ; 0: not solved, 1: solved first line, 2: solved
global_state__solved_final_riddle: ds virtual 1

player_x: ds virtual 2  ; 1st the pixel and 2nd byte is the tile coordinate
player_y: ds virtual 2  ; 1st the pixel and 2nd byte is the tile coordinate
player_state: ds virtual 1
player_state_timer: ds virtual 1
player_weapon_state_timer: ds virtual 1
player_requested_frame: ds virtual 1  ; the player frame we want to render
player_requested_weapon_sprite: ds virtual 3  ; sprite, x offs, y offs
player_weapon_swing_type: ds virtual 1
player_water_inertia_x: ds virtual 1
player_water_inertia_y: ds virtual 1
player_water_inertia_x_timer: ds virtual 1
player_water_inertia_y_timer: ds virtual 1
player_jump_is_cancelable: ds virtual 1  ; 1: if we can stop the jump by lifting the jump key.
                                         ; 0: the jump will proceed to maximum height without allowing player to stop it early (used for when coming out of the water).
player_jump_no_grab_timer: ds virtual 1  ; player can grab to ropes/ladders only if this is 0.
                                         ; This is used for when jumping off a ladder/rope, so that the player does not grab again immediately on the next frame.
player_push_block_timer: ds virtual 1
player_no_rope_or_ladder_this_frame: ds virtual 1  ; to prevent infinite loops in the player routine when holding to a ladder fails
player_combination_levers_state: ds virtual 8  ; to simplify combination lever checking
player_trial_completion_state: ds virtual 1

player_health: ds virtual 1
player_max_health: ds virtual 1
player_oxygen: ds virtual 1
player_inventory_weapons: ds virtual N_INVENTORY_WEAPON_TYPES
player_inventory_weapon_ammo: ds virtual 4
player_inventory_items: ds virtual N_INVENTORY_ITEM_TYPES
player_inventory_coins: ds virtual 1
player_inventory_n_small_keys: ds virtual 1
; player_inventory_map_pieces: ds virtual N_MAP_PIECES
player_current_item: ds virtual 1  ; 0 - 10 are weapons, 11 - 35 are inventory key items
player_immunity_timer: ds virtual 1  ; if != 0, nothing can hurt the player
player_can_double_jump: ds virtual 1

player_current_swing_hit_id: ds virtual 1
player_new_hit_id: ds virtual 1
player_weapon_hitbox_check_result: ds virtual 1  ; 1: no hit, 0: hit

tile_enemy_hit_fn_ptr: ds virtual 2  ; custom function for the effect of hitting a tile-based enemy: if a player weapon hits a tile in the "tile enemy" range, this method will be called.
tile_enemy_last_collision_id: ds virtual 1
tile_enemy_work_memory: ds virtual 64  ; - some large tile-based enemies need extra memory
                                       ; - only one is spawned per room at most. So, they can safely 
                                       ;   use this space without more than one enemy competing for it.

redraw_flags: ds virtual 1  ; bits:
                            ; - 0: room
                            ; - 1: hud
                            ; - 2: hud coins (re-renders the text into the tiles)
                            ; - 3: hud ammo  (re-renders the text into the tiles)
                            ; - 4: reupload ingame object tiles
in_game_event_fn_ptr: ds virtual 2
in_game_event_fn_page: ds virtual 1
in_game_event_fn_arg: ds virtual 1
play_seashell_flag: ds virtual 1

; inventory state variables:
inventory_cursor_position_x: ds virtual 1
inventory_cursor_position_y: ds virtual 1

hud_redraw_timer: ds virtual 1  ; if this is 0, the hud is not drawn (when config_hud_type == 0)
hud_draw_buffer: ds virtual 64

keyboard_state:        ds virtual 1
keyboard_clicks:       ds virtual 1
keyboard_state_prev:   ds virtual 1

boss_door_exit_to_room: ds virtual 1
boss_door_exit_to_x: ds virtual 1
boss_door_exit_to_y: ds virtual 1

item_object_to_upload_to_vdp: ds virtual 2  ; 4 tiles will be copied
large_object_to_upload_to_vdp: ds virtual 2
large_object_to_upload_to_vdp_size: ds virtual 1  ; number of bytes to be copied
enemy_tiles_to_upload_to_vdp: ds virtual 2
enemy_tiles_to_upload_to_vdp_page: ds virtual 2

config_keyboard_special_case: ds virtual 1

boss__in_boss_room: ds virtual 1  ; 0: normal room, 1: boss room
boss__active: ds virtual 1  ; 1 when we are fighting a boss (only when the boss is alive), 0 otherwise
boss__room_bg_buffer: equ current_room__tile_map + 32*24*2  ; the room is copied here, so that background can be restored when the boss moves around
boss__behavior: ds virtual 1  ; which boss behavior is being executed
boss__state: ds virtual 1  ; state within the current boss behavior
boss__state_timer: ds virtual 1
boss__x: ds virtual 1
boss__y: ds virtual 1
boss__x2: ds virtual 1  ; for bosses that have two parts
boss__y2: ds virtual 1
boss__clear_bbox_1: ds virtual 4  ; ptr, w, h  (used to restore boss background)
boss__clear_bbox_2: ds virtual 4  ; ptr, w, h  (used to restore boss background, for bosses made out of two pieces)
boss__hp: ds virtual 2  ; hit points, 16bit
boss__last_collision_id: ds virtual 1
boss__hit_fn: ds virtual 2  ; when the player hits a tile with collision type '9' this method is called
boss__hit_timer: ds virtual 1  ; for displaying "boss hit" animations
boss__2_direction:  ; 0: left, 1: right
boss__3_head_attached:  ; 0: attached, 1: dettached
boss__1_has_staff: ds virtual 1
boss__1_staff_hp: ds virtual 1
boss__1_settings:
boss__2_settings: 
boss__3_settings:
    ds virtual 12  ; difficulty parameters of the boss

RAM_to_zero_on_game_start_end:

; temporary variables:
temporary_variables: ds virtual 10
tmp_hud_drawing_hl: equ temporary_variables
tmp_hud_drawing_de: equ temporary_variables + 2
tmp_dialog_pointer_position: equ tmp_hud_drawing_hl
tmp_map_pointer_position: equ tmp_hud_drawing_hl
tmp_letter_line_width: equ tmp_hud_drawing_hl
tmp_letter_line_color: equ tmp_hud_drawing_hl + 1
tmp_puzzlebox_state: equ tmp_hud_drawing_hl
tmp_puzzlebox_pointer: equ tmp_hud_drawing_hl + 4
tmp_enemy_pcg_platform_loc_ptr: equ temporary_variables
tmp_enemy_pcg_water_loc_ptr: equ temporary_variables + 2
tmp_enemy_pcg_ceiling_loc_ptr: equ temporary_variables + 4
tmp_enemy_pcg_n_platform_locs: equ temporary_variables + 6
tmp_enemy_pcg_n_water_locs: equ temporary_variables + 7
tmp_enemy_pcg_n_ceiling_locs: equ temporary_variables + 8
tmp_enemy_pcg_next_enemy_id: equ temporary_variables + 9
tmp_get_tile_object_behind_player_ptr: equ temporary_variables
tmp_shop_cursor_position: equ temporary_variables
tmp_gamestart_cursor_position1: equ temporary_variables  ; world name, start, back or help
tmp_gamestart_cursor_position2: equ temporary_variables + 1  ; position within the world name

config_hud_type: ds virtual 1  ; 0: minimal, 1: minimal always visible, 2: full
config_inventory_key_combo: ds virtual 1  ; 0: down+jump, 1: none
config_interact_with_down: ds virtual 1  ; 0: yes, 1: no
config_interact_with_up: ds virtual 1  ; 0: yes, 1: no
; each key is matrix row + bit mask
config_keyboard: ds virtual 2 * 8  ; RIGHT, DOWN, UP, LEFT, INTERACT, INVENTORY, JUMP, SPACE

options_called_from: ds virtual 1  ; 0: options called from inventory, 1: called from title

; sound variables:
MUSIC_tempo:                        ds virtual 1
MUSIC_original_tempo:               ds virtual 1  ; tempo that was requested before adjusting it for 50/60Hz.
beginning_of_sound_variables_except_tempo:
current_music_ptr:                  ds virtual 2  ; ptr to the compressed song currently playing
MUSIC_play:                         ds virtual 1
MUSIC_tempo_counter:                ds virtual 1
MUSIC_instruments:                  ds virtual 3
MUSIC_channel3_instrument_buffer:   ds virtual 1  ; this stores the instrument of channel 3, which is special, since SFX might overwrite it
MUSIC_start_pointer:                ds virtual 2  
SFX_pointer:                        ds virtual 2
MUSIC_pointer:                      ds virtual 2
MUSIC_repeat_stack_ptr:             ds virtual 2
MUSIC_repeat_stack:                 ds virtual 4*3
MUSIC_instrument_envelope_ptr:      ds virtual 3*2
SFX_priority:                       ds virtual 1  ; the SFX from the game have more priority than those triggered by music
MUSIC_transpose:                    ds virtual 1
MUSIC_time_step_required:           ds virtual 1
end_of_sound_variables:


rng_seed1: ds virtual 2  ; state of the random number generator
rng_seed2: ds virtual 2

interrupt_cycle: ds virtual 1  ; incremented at each interrupt
game_cycle: ds virtual 1  ; incremented at each game loop cycle

dzx0t_last_offset_tmp:              ds virtual 2

start_of_interrupt_code_ram: ds virtual end_of_interrupt_code_rom - start_of_interrupt_code_rom

current_megarom_page_in_4000:       ds virtual 1
current_megarom_page_in_8000:       ds virtual 1

; CPU_turbo_r:  ds virtual 1 ; 0 no turbo-r, 1: turbo-r
isComputer50HzOr60Hz:  ds virtual 1  ; 0: 50Hz, 1: 60Hz
RAM_slot: ds virtual 1  ; slot where the game was inserted

end_of_ram:
