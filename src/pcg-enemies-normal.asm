;-----------------------------------------------
pcg_enemy_generation_table_normal:
	dw pcg_enemy_generation_table_jungle_normal
	dw pcg_enemy_generation_table_pyramid1_normal
	dw pcg_enemy_generation_table_pyramid2_normal
	dw pcg_enemy_generation_table_confluence_normal
	dw pcg_enemy_generation_table_pyramid3_normal
	dw pcg_enemy_generation_table_fire_shaft_normal
	dw pcg_enemy_generation_table_caves_west_normal
	dw pcg_enemy_generation_table_caves_east_normal
	dw pcg_enemy_generation_table_xibalba_normal
	dw pcg_enemy_generation_table_atlantis_normal
	dw pcg_enemy_generation_table_mars_normal
	dw pcg_enemy_generation_table_moon_normal

pcg_enemy_generation_table_jungle_normal:
	db 2  ; enemies per "screen" area
	db 2  ; possible tile enemy types to be spawned
	db TAG_ENEMY_CARNIVORE_PLANT, 48  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_BEE_HIVE, 96  ; tile-based enemy type and chance (out of 256)
	db 10  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 5  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 2
	db ENEMY_SNAKE_POISON, 2
	db ENEMY_FROG, 5  ; enemy type and weight
	db ENEMY_FROG_JUMPER, 2
	db ENEMY_FROG_TONGUE, 2
	db ENEMY_MONKEY, 6  ; enemy type and weight
	db ENEMY_MONKEY_THROWER, 2
	db ENEMY_FISH, 4
	db ENEMY_FISH_JUMPER, 2

pcg_enemy_generation_table_pyramid1_normal:
pcg_enemy_generation_table_pyramid2_normal:
pcg_enemy_generation_table_pyramid3_normal:
pcg_enemy_generation_table_fire_shaft_normal:
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 96  ; tile-based enemy type and chance (out of 256)
	db 11  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_SNAKE, 5  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 2
	db ENEMY_SNAKE_POISON, 2
	db ENEMY_FISH, 5
	db ENEMY_FISH_JUMPER, 2
	db ENEMY_BAT, 5
	db ENEMY_BAT_AGGRESSIVE, 2
	db ENEMY_SKELETON, 5
	db ENEMY_SKELETON_THROWER1, 2
	db ENEMY_SKELETON_THROWER2, 2

pcg_enemy_generation_table_confluence_normal:
pcg_enemy_generation_table_caves_west_normal:
pcg_enemy_generation_table_caves_east_normal:
	db 2  ; 2 enemies per "screen" area
	db 2
	db TAG_ENEMY_ANT_COLONY, 64  ; tile-based enemy type and chance (out of 256)
	db TAG_ENEMY_ANT_COLONY2, 64  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISH, 5
	db ENEMY_FISH_JUMPER, 3
	db ENEMY_BAT, 5
	db ENEMY_BAT_AGGRESSIVE, 3
	db ENEMY_SKELETON_FLAME1, 5
	db ENEMY_SKELETON_FLAME2, 3
	db ENEMY_ROCKMAN, 5
	db ENEMY_ROCKMAN2, 3

pcg_enemy_generation_table_xibalba_normal:
	db 2  ; 2 enemies per "screen" area
	db 3
	db TAG_ENEMY_STONE_OWL, 96
	db TAG_ENEMY_FIREBALL_GENERATOR, 96
	db TAG_ENEMY_IMP_GENERATOR, 255
	db 7  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_BAT, 5
	db ENEMY_BAT_AGGRESSIVE, 3
	db ENEMY_SKELETON_FLAME1, 5
	db ENEMY_SKELETON_FLAME2, 3
	db ENEMY_SKELETON_SLEEPER, 8
	db ENEMY_FIRE_IMP, 5
	db ENEMY_FIRE_IMP2, 3

pcg_enemy_generation_table_atlantis_normal:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_SENTINEL, 255  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_FISHMAN, 4
	db ENEMY_FISHMAN2, 4
	db ENEMY_GHOST, 4
	db ENEMY_GHOST2, 4
	db ENEMY_FISH, 4
	db ENEMY_FISH_JUMPER, 4
	db ENEMY_SKELETON_THROWER3, 4
	db ENEMY_SKELETON_THROWER4, 4

pcg_enemy_generation_table_mars_normal:
	db 2  ; 2 enemies per "screen" area
	db 0
; 	db TAG_ENEMY_MARS_VENT, 64  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_MARS_BIGMECH, 64  ; tile-based enemy type and chance (out of 256)
	db 8  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_MARS_SNAIL1, 4
	db ENEMY_MARS_SNAIL2, 4
	db ENEMY_MARS_BLOB1, 4
	db ENEMY_MARS_BLOB2, 4
	db ENEMY_MARS_DRONE1, 4
	db ENEMY_MARS_DRONE2, 4
	db ENEMY_MARS_ROBOT1, 4
	db ENEMY_MARS_ROBOT2, 4

pcg_enemy_generation_table_moon_normal:
	db 2  ; 2 enemies per "screen" area
	db 0
	db 4  ; possible sprite enemy types to be spawned (weights below should add up to 32)
	db ENEMY_MARS_DRONE1, 8
	db ENEMY_MARS_DRONE2, 8
	db ENEMY_MARS_ROBOT1, 8
	db ENEMY_MARS_ROBOT2, 8
