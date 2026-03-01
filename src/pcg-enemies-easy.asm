;-----------------------------------------------
pcg_enemy_generation_table_easy:
	dw pcg_enemy_generation_table_jungle_easy
	dw pcg_enemy_generation_table_pyramid1_easy
	dw pcg_enemy_generation_table_pyramid2_easy
	dw pcg_enemy_generation_table_confluence_easy
	dw pcg_enemy_generation_table_pyramid3_easy
	dw pcg_enemy_generation_table_fire_shaft_easy
	dw pcg_enemy_generation_table_caves_west_easy
	dw pcg_enemy_generation_table_caves_east_easy
	dw pcg_enemy_generation_table_xibalba_easy
	dw pcg_enemy_generation_table_atlantis_easy
	dw pcg_enemy_generation_table_mars_easy
	dw pcg_enemy_generation_table_moon_easy

pcg_enemy_generation_table_jungle_easy:
	db 2  ; enemies per "screen" area
	db 2  ; possible tile enemy types to be spawned
	db TAG_ENEMY_CARNIVORE_PLANT, 24  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_BEE_HIVE, 40  ; tile-based enemy type and chance (out of 256)
	db 10  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 7  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 1
	db ENEMY_SNAKE_POISON, 1
	db ENEMY_FROG, 7  ; enemy type and weight
	db ENEMY_FROG_JUMPER, 1
	db ENEMY_FROG_TONGUE, 1
	db ENEMY_MONKEY, 7  ; enemy type and weight
	db ENEMY_MONKEY_THROWER, 1
	db ENEMY_FISH, 5
	db ENEMY_FISH_JUMPER, 1

pcg_enemy_generation_table_pyramid1_easy:
pcg_enemy_generation_table_pyramid2_easy:
pcg_enemy_generation_table_pyramid3_easy:
pcg_enemy_generation_table_fire_shaft_easy:
pcg_enemy_generation_table_mars_easy:
pcg_enemy_generation_table_moon_easy:
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 48  ; tile-based enemy type and chance (out of 256)
	db 10  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 7  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 1
	db ENEMY_SNAKE_POISON, 1
	db ENEMY_FISH, 6
	db ENEMY_FISH_JUMPER, 1
	db ENEMY_BAT, 6
	db ENEMY_BAT_AGGRESSIVE, 1
	db ENEMY_SKELETON, 7
	db ENEMY_SKELETON_THROWER1, 1
	db ENEMY_SKELETON_THROWER2, 1

pcg_enemy_generation_table_confluence_easy:
pcg_enemy_generation_table_caves_west_easy:
pcg_enemy_generation_table_caves_east_easy:
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_ANT_COLONY, 48  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_ANT_COLONY2, 0  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISH, 7
	db ENEMY_FISH_JUMPER, 1
	db ENEMY_BAT, 7
	db ENEMY_BAT_AGGRESSIVE, 1
	db ENEMY_SKELETON_FLAME1, 7
	db ENEMY_SKELETON_FLAME2, 1
	db ENEMY_ROCKMAN, 7
	db ENEMY_ROCKMAN2, 1

pcg_enemy_generation_table_xibalba_easy:
	db 2  ; 2 enemies per "screen" area
	db 3
	db TAG_ENEMY_STONE_OWL, 64
	db TAG_ENEMY_FIREBALL_GENERATOR, 80
	db TAG_ENEMY_IMP_GENERATOR, 128
	db 7  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_BAT, 8
	db ENEMY_BAT_AGGRESSIVE, 1
	db ENEMY_SKELETON_FLAME1, 8
	db ENEMY_SKELETON_FLAME2, 1
	db ENEMY_SKELETON_SLEEPER, 5
	db ENEMY_FIRE_IMP, 8
	db ENEMY_FIRE_IMP2, 1

pcg_enemy_generation_table_atlantis_easy:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_CARNIVORE_PLANT, 48  ; tile-based enemy type and chance (out of 256)
	db 4  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_GHOST, 8
	db ENEMY_GHOST2, 8
	db ENEMY_FISHMAN, 8
	db ENEMY_FISHMAN2, 8
; 	db ENEMY_FISH, 6
; 	db ENEMY_FISH_JUMPER, 2
; 	db ENEMY_SKELETON_THROWER1, 6
; 	db ENEMY_SKELETON_THROWER2, 2