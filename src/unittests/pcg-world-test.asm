; Unit tests run on MDL, and not on an MSX machine, so, we can use the whole 64k space.
	org #0000
	ld sp, #ffff

	include "../constants.asm"
	include "../auxiliar.asm"
	include "../input.asm"
	include "../hardcoded-world.asm"
	include "../pcg-world.asm"
	include "../pcg-riddles.asm"
	include "empty-callbacks.asm"


;-----------------------------------------------
test_start:
	call test__remove_useable_reachable_descendants
	call test__pcg_generate_world__generate_sorted_area_tag_list_sort
	call test__pcg_generate_world__generate_subquests_sample_lock_key_delete_selected

test_end:
	jr test_end


;-----------------------------------------------
; input:
; - hl, de: arrays to compare
; - bc: length
test__arrays_equal:
	ld a, (de)
	cp (hl)
	jr nz, test__arrays_equal_fail
	inc de
	inc hl
	dec bc
	ld a, c
	or b
	ret z
	jr test__arrays_equal


;-----------------------------------------------
test__arrays_equal_fail:
	or 1 ; mdl-watch: "test__arrays_equal_fail", bc
	ret


;-----------------------------------------------
test_fake_tag_data_1:
	db 1, 10

test_fake_tag_data_2_sorted:
	db 1, 10, 2, 20

test_fake_tag_data_2_unsorted:
	db 2, 20, 1, 10

test_fake_tag_data_4_sorted:
	db 1, 10, 2, 20, 3, 30, 4, 40

test_fake_tag_data_4_unsorted:
	db 4, 40, 2, 20, 1, 10, 3, 30


test__pcg_generate_world__generate_sorted_area_tag_list_sort:
	; length 1:
	ld hl, test_fake_tag_data_1
	ld de, tmp_pcg_world__tag_list
	ld bc, 2
	ldir
	ld iyl, 1
	call pcg_generate_world__generate_sorted_area_tag_list_sort
	ld hl, tmp_pcg_world__tag_list
	ld de, test_fake_tag_data_1
	ld bc, 2
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__pcg_generate_world__generate_sorted_area_tag_list_sort, length 1: success'

	; length 2, sorted:
	ld hl, test_fake_tag_data_2_sorted
	ld de, tmp_pcg_world__tag_list
	ld bc, 4
	ldir
	ld iyl, 2
	call pcg_generate_world__generate_sorted_area_tag_list_sort
	ld hl, tmp_pcg_world__tag_list
	ld de, test_fake_tag_data_2_sorted
	ld bc, 4
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__pcg_generate_world__generate_sorted_area_tag_list_sort, length 2 sorted: success'

	; length 2, unsorted:
	ld hl, test_fake_tag_data_2_unsorted
	ld de, tmp_pcg_world__tag_list
	ld bc, 4
	ldir
	ld iyl, 2
	call pcg_generate_world__generate_sorted_area_tag_list_sort
	ld hl, tmp_pcg_world__tag_list
	ld de, test_fake_tag_data_2_sorted
	ld bc, 4
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__pcg_generate_world__generate_sorted_area_tag_list_sort, length 2 unsorted: success'

	; length 4, unsorted:
	ld hl, test_fake_tag_data_4_unsorted
	ld de, tmp_pcg_world__tag_list
	ld bc, 8
	ldir
	ld iyl, 4
	call pcg_generate_world__generate_sorted_area_tag_list_sort
	ld hl, tmp_pcg_world__tag_list
	ld de, test_fake_tag_data_4_sorted
	ld bc, 8
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__pcg_generate_world__generate_sorted_area_tag_list_sort, length 4 unsorted: success'

	; ...
	ret


;-----------------------------------------------
MST_NODE_MACRO: macro divid, areaid, x, y, offset, n_descendants, tag1, tag2, parent_direction, parent, depth
	db divid, areaid, x, y, offset, n_descendants, tag1, tag2, parent_direction
	dw parent
	db depth
	endm

test_fake_mst:
	;
	; 1 --> 2 --> 3
	;   |
	;    -> 4
	;
test_fake_mst_n1:
	MST_NODE_MACRO 1, 0, 0, 0, 0, 3, TAG_NONE, TAG_NONE, 0, 0, 0
test_fake_mst_n2:
	MST_NODE_MACRO 2, 0, 1, 0, 1, 1, TAG_NONE, TAG_NONE, PCG_DIRECTION_LEFT, test_fake_mst_n1, 1
test_fake_mst_n3:
	MST_NODE_MACRO 3, 0, 2, 0, 2, 0, TAG_NONE, TAG_NONE, PCG_DIRECTION_LEFT, test_fake_mst_n2, 1
test_fake_mst_n4:
	MST_NODE_MACRO 4, 0, 0, 1, 8, 0, TAG_NONE, TAG_NONE, PCG_DIRECTION_LEFT, test_fake_mst_n1, 2

test_reachable:
	dw test_fake_mst_n1, test_fake_mst_n2, test_fake_mst_n3, test_fake_mst_n4

test_reachable_expected_removing_2:
	dw test_fake_mst_n1, test_fake_mst_n4

test_reachable_expected_removing_4:
	dw test_fake_mst_n1, test_fake_mst_n2, test_fake_mst_n3

test__remove_useable_reachable_descendants_init:
	ld hl, test_reachable
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 8
	ldir
	ld hl, test_reachable
	ld de, tmp_pcg_world__reachable_nodes
	ld bc, 8
	ldir
	ld a, 4
	ld (tmp_pcg_world__useable_nodes_size), a
	ld (tmp_pcg_world__reachable_nodes_size), a
	ret

test__remove_useable_reachable_descendants:
	call test__remove_useable_reachable_descendants_init
	ld a, 4
	call pcg_generate_world__remove_useable_reachable_descendants
	ld hl, tmp_pcg_world__reachable_nodes
	ld de, test_reachable_expected_removing_4
	ld bc, 6
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__remove_useable_reachable_descendants, remove 4: success'

	call test__remove_useable_reachable_descendants_init
	ld a, 2
	call pcg_generate_world__remove_useable_reachable_descendants
	ld hl, tmp_pcg_world__reachable_nodes
	ld de, test_reachable_expected_removing_2
	ld bc, 4
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__remove_useable_reachable_descendants, remove 2: success'
	ret


;-----------------------------------------------
lock_key_options_rom:
	db TAG_RED_CHEST, TAG_RED_KEY
	db TAG_GREEN_CHEST, TAG_GREEN_KEY
	db TAG_BLUE_CHEST, TAG_BLUE_KEY
	db TAG_YELLOW_CHEST, TAG_YELLOW_KEY
	db TAG_WHITE_CHEST, TAG_WHITE_KEY
	db TAG_PURPLE_CHEST, TAG_PURPLE_KEY
	db #ff
lock_key_options_rom_end:

lock_key_options_expected_rom:
	db TAG_RED_CHEST, TAG_RED_KEY
	db TAG_GREEN_CHEST, TAG_GREEN_KEY
	db TAG_BLUE_CHEST, TAG_BLUE_KEY
	db TAG_WHITE_CHEST, TAG_WHITE_KEY
	db TAG_PURPLE_CHEST, TAG_PURPLE_KEY
	db #ff
lock_key_options_expected_rom_end:

test__pcg_generate_world__generate_subquests_sample_lock_key_delete_selected:
	ld hl, lock_key_options_rom
	ld de, tmp_pcg_world__candidates_list
	ld bc, lock_key_options_rom_end - lock_key_options_rom
	ldir

	ld iyl, TAG_YELLOW_KEY
	ld hl, tmp_pcg_world__candidates_list
	call pcg_generate_world__generate_subquests_sample_lock_key_delete_selected

	ld hl, tmp_pcg_world__candidates_list
	ld de, lock_key_options_expected_rom
	ld bc, lock_key_options_expected_rom_end - lock_key_options_expected_rom
	call test__arrays_equal
	ret nz
	nop  ; mdl-watch: 'test__pcg_generate_world__generate_subquests_sample_lock_key_delete_selected: success'
	ret


;-----------------------------------------------
	include "../ram.asm"
