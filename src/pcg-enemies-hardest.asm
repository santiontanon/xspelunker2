;-----------------------------------------------
pcg_enemy_generation_table_hardest:
	dw pcg_enemy_generation_table_jungle_hardest
	dw pcg_enemy_generation_table_pyramid1_hardest
	dw pcg_enemy_generation_table_pyramid2_hardest
	dw pcg_enemy_generation_table_confluence_hardest
	dw pcg_enemy_generation_table_pyramid3_hardest
	dw pcg_enemy_generation_table_fire_shaft_hardest
	dw pcg_enemy_generation_table_caves_west_hardest
	dw pcg_enemy_generation_table_caves_east_hardest
	dw pcg_enemy_generation_table_xibalba_hardest
	dw pcg_enemy_generation_table_atlantis_hardest
	dw pcg_enemy_generation_table_mars_hardest
	dw pcg_enemy_generation_table_moon_hardest

pcg_enemy_generation_table_jungle_hardest:
	db 2  ; enemies per "screen" area
	db 2  ; possible tile enemy types to be spawned
	db TAG_ENEMY_CARNIVORE_PLANT, 96  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_BEE_HIVE, 160  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_ANT_COLONY, 192  ; tile-based enemy type and chance (out of 256)
	db 10  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 2  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 3
	db ENEMY_SNAKE_POISON, 4
	db ENEMY_FROG, 2  ; enemy type and weight
	db ENEMY_FROG_JUMPER, 3
	db ENEMY_FROG_TONGUE, 4
	db ENEMY_MONKEY, 3  ; enemy type and weight
	db ENEMY_MONKEY_THROWER, 5
	db ENEMY_FISH, 2
	db ENEMY_FISH_JUMPER, 4

pcg_enemy_generation_table_pyramid1_hardest:
pcg_enemy_generation_table_pyramid2_hardest:
pcg_enemy_generation_table_pyramid3_hardest:
pcg_enemy_generation_table_fire_shaft_hardest:
pcg_enemy_generation_table_xibalba_hardest:
pcg_enemy_generation_table_atlantis_hardest:
pcg_enemy_generation_table_mars_hardest:
pcg_enemy_generation_table_moon_hardest:
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 96  ; tile-based enemy type and chance (out of 256)
	db 11  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 2  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 3
	db ENEMY_SNAKE_POISON, 4
	db ENEMY_FISH, 2
	db ENEMY_FISH_JUMPER, 5
	db ENEMY_BAT, 2
	db ENEMY_BAT_AGGRESSIVE, 5
	db ENEMY_SKELETON, 2
	db ENEMY_SKELETON_THROWER1, 3
	db ENEMY_SKELETON_THROWER2, 4

pcg_enemy_generation_table_confluence_hardest:
pcg_enemy_generation_table_caves_west_hardest:
pcg_enemy_generation_table_caves_east_hardest:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_CARNIVORE_PLANT, 48  ; tile-based enemy type and chance (out of 256)
	db 6  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISH, 2
	db ENEMY_FISH_JUMPER, 6
	db ENEMY_BAT, 2
	db ENEMY_BAT_AGGRESSIVE, 6
	db ENEMY_SKELETON_THROWER1, 4
	db ENEMY_SKELETON_THROWER2, 4
	db ENEMY_SKELETON_FLAME1, 2
	db ENEMY_SKELETON_FLAME2, 6
