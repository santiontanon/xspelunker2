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
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 128  ; tile-based enemy type and chance (out of 256)
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
	db 2
	db TAG_ENEMY_ANT_COLONY, 24  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_ANT_COLONY2, 96  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISH, 1
	db ENEMY_FISH_JUMPER, 7
	db ENEMY_BAT, 1
	db ENEMY_BAT_AGGRESSIVE, 7
	db ENEMY_SKELETON_FLAME1, 1
	db ENEMY_SKELETON_FLAME2, 7
	db ENEMY_ROCKMAN, 1
	db ENEMY_ROCKMAN2, 7

pcg_enemy_generation_table_xibalba_hardest:
	db 2  ; 2 enemies per "screen" area
	db 4
	db TAG_ENEMY_STONE_OWL, 80
	db TAG_ENEMY_FIREBALL_GENERATOR, 64
	db TAG_ENEMY_IMP_GENERATOR, 64
	db TAG_ENEMY_IMP_GENERATOR2, 255
	db 7  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_BAT, 1
	db ENEMY_BAT_AGGRESSIVE, 7
	db ENEMY_SKELETON_FLAME1, 1
	db ENEMY_SKELETON_FLAME2, 7
	db ENEMY_SKELETON_SLEEPER, 8
	db ENEMY_FIRE_IMP, 1
	db ENEMY_FIRE_IMP2, 7

pcg_enemy_generation_table_atlantis_hardest:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_SENTINEL, 96  ; tile-based enemy type and chance (out of 256)
	db 5  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISHMAN2, 8
	db ENEMY_GHOST2, 8
	db ENEMY_FISH_JUMPER, 8
	db ENEMY_SKELETON_THROWER3, 4
	db ENEMY_SKELETON_THROWER4, 4

pcg_enemy_generation_table_mars_hardest:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_MARS_VENT, 128  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_MARS_BIGMECH, 128  ; tile-based enemy type and chance (out of 256)
	db 4  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_MARS_SNAIL2, 8
	db ENEMY_MARS_BLOB2, 8
	db ENEMY_MARS_DRONE2, 8
	db ENEMY_MARS_ROBOT2, 8

pcg_enemy_generation_table_moon_hardest:
	db 2  ; 2 enemies per "screen" area
	db 0
	db 0  ; possible sprite enemy types to be spawned (weights below should add up to 32)
