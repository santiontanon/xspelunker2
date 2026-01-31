;-----------------------------------------------
pcg_enemy_generation_table_hard:
	dw pcg_enemy_generation_table_jungle_hard
	dw pcg_enemy_generation_table_pyramid1_hard
	dw pcg_enemy_generation_table_pyramid2_hard
	dw pcg_enemy_generation_table_confluence_hard
	dw pcg_enemy_generation_table_pyramid3_hard
	dw pcg_enemy_generation_table_fire_shaft_hard
	dw pcg_enemy_generation_table_caves_west_hard
	dw pcg_enemy_generation_table_caves_east_hard
	dw pcg_enemy_generation_table_xibalba_hard
	dw pcg_enemy_generation_table_atlantis_hard
	dw pcg_enemy_generation_table_mars_hard
	dw pcg_enemy_generation_table_moon_hard

pcg_enemy_generation_table_jungle_hard:
	db 2  ; enemies per "screen" area
	db 2  ; possible tile enemy types to be spawned
	db TAG_ENEMY_CARNIVORE_PLANT, 64  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_BEE_HIVE, 128  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_ANT_COLONY, 140  ; tile-based enemy type and chance (out of 256)
	db 10  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 3  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 3
	db ENEMY_SNAKE_POISON, 3
	db ENEMY_FROG, 3  ; enemy type and weight
	db ENEMY_FROG_JUMPER, 3
	db ENEMY_FROG_TONGUE, 3
	db ENEMY_MONKEY, 4  ; enemy type and weight
	db ENEMY_MONKEY_THROWER, 4
	db ENEMY_FISH, 3
	db ENEMY_FISH_JUMPER, 3

pcg_enemy_generation_table_pyramid1_hard:
pcg_enemy_generation_table_pyramid2_hard:
pcg_enemy_generation_table_pyramid3_hard:
pcg_enemy_generation_table_fire_shaft_hard:
pcg_enemy_generation_table_atlantis_hard:
pcg_enemy_generation_table_mars_hard:
pcg_enemy_generation_table_moon_hard:
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 96  ; tile-based enemy type and chance (out of 256)
	db 11  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 3  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 3
	db ENEMY_SNAKE_POISON, 3
	db ENEMY_FISH, 4
	db ENEMY_FISH_JUMPER, 3
	db ENEMY_BAT, 4
	db ENEMY_BAT_AGGRESSIVE, 3
	db ENEMY_SKELETON, 3
	db ENEMY_SKELETON_THROWER1, 3
	db ENEMY_SKELETON_THROWER2, 3

pcg_enemy_generation_table_confluence_hard:
pcg_enemy_generation_table_caves_west_hard:
pcg_enemy_generation_table_caves_east_hard:
	db 2  ; 2 enemies per "screen" area
	db 2
	db TAG_ENEMY_ANT_COLONY, 48  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_ANT_COLONY2, 96  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISH, 3
	db ENEMY_FISH_JUMPER, 5
	db ENEMY_BAT, 3
	db ENEMY_BAT_AGGRESSIVE, 5
	db ENEMY_SKELETON_FLAME1, 3
	db ENEMY_SKELETON_FLAME2, 5
	db ENEMY_ROCKMAN, 3
	db ENEMY_ROCKMAN2, 5

pcg_enemy_generation_table_xibalba_hard:
	db 2  ; 2 enemies per "screen" area
	db 0
	db 7  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_BAT, 3
	db ENEMY_BAT_AGGRESSIVE, 5
	db ENEMY_SKELETON_FLAME1, 3
	db ENEMY_SKELETON_FLAME2, 5
	db ENEMY_SKELETON_SLEEPER, 8
	db ENEMY_FIRE_IMP, 3
	db ENEMY_FIRE_IMP2, 5
