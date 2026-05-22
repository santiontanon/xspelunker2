; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
moon_chunk_flags:
moon_standard_chunk_pool:
  db 0, #00, #00  ; data/moon/room0000-1.tmx (0)  
  dw #06ef
  db 1, #00, #01  ; data/moon/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 1, #00, #02  ; data/moon/room0001-2.tmx (2)  down: stairs, 
  dw #03bf
  db 2, #00, #04  ; data/moon/room0010-1.tmx (3)  right: hole, 
  dw #05df
  db 3, #00, #05  ; data/moon/room0011-1.tmx (4)  right: hole, down: hole, 
  dw #019f
  db 3, #00, #06  ; data/moon/room0011-2.tmx (5)  right: hole, down: stairs, 
  dw #019f
  db 4, #00, #10  ; data/moon/room0100-1.tmx (6)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/moon/room0100-2.tmx (7)  up: stairs, 
  dw #06ef
  db 5, #00, #11  ; data/moon/room0101-1.tmx (8)  up: hole, down: hole, 
  dw #02af
  db 5, #00, #12  ; data/moon/room0101-2.tmx (9)  up: hole, down: stairs, 
  dw #02af
  db 5, #00, #21  ; data/moon/room0101-3.tmx (10)  up: stairs, down: hole, 
  dw #02af
  db 6, #00, #14  ; data/moon/room0110-1.tmx (11)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #24  ; data/moon/room0110-2.tmx (12)  up: stairs, right: hole, 
  dw #04cf
  db 7, #00, #15  ; data/moon/room0111-1.tmx (13)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #16  ; data/moon/room0111-2.tmx (14)  up: hole, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #25  ; data/moon/room0111-3.tmx (15)  up: stairs, right: hole, down: hole, 
  dw #008f
  db 8, #00, #40  ; data/moon/room1000-1.tmx (16)  left: hole, 
  dw #0777
  db 9, #00, #41  ; data/moon/room1001-1.tmx (17)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/moon/room1001-2.tmx (18)  left: hole, down: stairs, 
  dw #0337
  db 10, #00, #44  ; data/moon/room1010-1.tmx (19)  left: hole, right: hole, 
  dw #0557
  db 11, #00, #45  ; data/moon/room1011-1.tmx (20)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #46  ; data/moon/room1011-2.tmx (21)  left: hole, right: hole, down: stairs, 
  dw #0117
  db 12, #00, #50  ; data/moon/room1100-1.tmx (22)  left: hole, up: hole, 
  dw #0667
  db 12, #00, #60  ; data/moon/room1100-2.tmx (23)  left: hole, up: stairs, 
  dw #0667
  db 13, #00, #51  ; data/moon/room1101-1.tmx (24)  left: hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #52  ; data/moon/room1101-2.tmx (25)  left: hole, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #61  ; data/moon/room1101-3.tmx (26)  left: hole, up: stairs, down: hole, 
  dw #0227
  db 14, #00, #54  ; data/moon/room1110-1.tmx (27)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #64  ; data/moon/room1110-2.tmx (28)  left: hole, up: stairs, right: hole, 
  dw #0447
  db 15, #00, #55  ; data/moon/room1111-1.tmx (29)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #56  ; data/moon/room1111-2.tmx (30)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #65  ; data/moon/room1111-3.tmx (31)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0007
moon_boss_chunk_pool:
  db 1, #01, #01  ; data/moon/boss0001-1.tmx (32)  down: hole, 
  dw #0007
  db 2, #01, #04  ; data/moon/boss0010-1.tmx (33)  right: hole, 
  dw #0005
  db 3, #01, #05  ; data/moon/boss0011-1.tmx (34)  right: hole, down: hole, 
  dw #0005
  db 4, #01, #10  ; data/moon/boss0100-1.tmx (35)  up: hole, 
  dw #0005
  db 4, #01, #20  ; data/moon/boss0100-2.tmx (36)  up: stairs, 
  dw #0005
  db 5, #01, #11  ; data/moon/boss0101-1.tmx (37)  up: hole, down: hole, 
  dw #0005
  db 5, #01, #21  ; data/moon/boss0101-2.tmx (38)  up: stairs, down: hole, 
  dw #0005
  db 6, #01, #14  ; data/moon/boss0110-1.tmx (39)  up: hole, right: hole, 
  dw #0005
  db 6, #01, #24  ; data/moon/boss0110-2.tmx (40)  up: stairs, right: hole, 
  dw #0005
  db 7, #01, #15  ; data/moon/boss0111-1.tmx (41)  up: hole, right: hole, down: hole, 
  dw #0005
  db 7, #01, #25  ; data/moon/boss0111-2.tmx (42)  up: stairs, right: hole, down: hole, 
  dw #0005
  db 8, #01, #40  ; data/moon/boss1000-1.tmx (43)  left: hole, 
  dw #0005
  db 9, #01, #41  ; data/moon/boss1001-1.tmx (44)  left: hole, down: hole, 
  dw #0005
  db 10, #01, #44  ; data/moon/boss1010-1.tmx (45)  left: hole, right: hole, 
  dw #0005
  db 11, #01, #45  ; data/moon/boss1011-1.tmx (46)  left: hole, right: hole, down: hole, 
  dw #0005
  db 12, #01, #50  ; data/moon/boss1100-1.tmx (47)  left: hole, up: hole, 
  dw #0005
  db 12, #01, #60  ; data/moon/boss1100-2.tmx (48)  left: hole, up: stairs, 
  dw #0005
  db 13, #01, #51  ; data/moon/boss1101-1.tmx (49)  left: hole, up: hole, down: hole, 
  dw #0005
  db 13, #01, #61  ; data/moon/boss1101-2.tmx (50)  left: hole, up: stairs, down: hole, 
  dw #0005
  db 14, #01, #54  ; data/moon/boss1110-1.tmx (51)  left: hole, up: hole, right: hole, 
  dw #0005
  db 14, #01, #64  ; data/moon/boss1110-2.tmx (52)  left: hole, up: stairs, right: hole, 
  dw #0005
  db 15, #01, #55  ; data/moon/boss1111-1.tmx (53)  left: hole, up: hole, right: hole, down: hole, 
  dw #0005
  db 15, #01, #65  ; data/moon/boss1111-2.tmx (54)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0005
moon_block_chunk_pool:
  db 3, #00, #05  ; data/moon/block0011-1.tmx (55)  right: hole, down: hole, 
  dw #099f
  db 5, #00, #11  ; data/moon/block0101-1.tmx (56)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/moon/block0101-2.tmx (57)  up: stairs, down: hole, 
  dw #0828
  db 6, #00, #14  ; data/moon/block0110-1.tmx (58)  up: hole, right: hole, 
  dw #0849
  db 6, #00, #24  ; data/moon/block0110-2.tmx (59)  up: stairs, right: hole, 
  dw #0849
  db 7, #00, #15  ; data/moon/block0011-1.tmx + up (60)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/moon/block0101-1.tmx + right (61)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/moon/block0101-2.tmx + right (62)  up: stairs, right: hole, down: hole, 
  dw #0808
  db 7, #00, #15  ; data/moon/block0110-1.tmx + down (63)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/moon/block0110-2.tmx + down (64)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 9, #00, #41  ; data/moon/block1001-1.tmx (65)  left: hole, down: hole, 
  dw #0a31
  db 9, #00, #41  ; data/moon/block1001-2.tmx (66)  left: hole, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/moon/block1010-1.tmx (67)  left: hole, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/moon/block0011-1.tmx + left (68)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/moon/block1001-1.tmx + right (69)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/moon/block1001-2.tmx + right (70)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/moon/block1010-1.tmx + down (71)  left: hole, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/moon/block1100-1.tmx (72)  left: hole, up: hole, 
  dw #0a60
  db 12, #00, #60  ; data/moon/block1100-2.tmx (73)  left: hole, up: stairs, 
  dw #0a60
  db 13, #00, #51  ; data/moon/block0101-1.tmx + left (74)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #61  ; data/moon/block0101-2.tmx + left (75)  left: hole, up: stairs, down: hole, 
  dw #0820
  db 13, #00, #51  ; data/moon/block1001-1.tmx + up (76)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/moon/block1001-2.tmx + up (77)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/moon/block1100-1.tmx + down (78)  left: hole, up: hole, down: hole, 
  dw #0a20
  db 13, #00, #61  ; data/moon/block1100-2.tmx + down (79)  left: hole, up: stairs, down: hole, 
  dw #0a20
  db 14, #00, #54  ; data/moon/block0110-1.tmx + left (80)  left: hole, up: hole, right: hole, 
  dw #0841
  db 14, #00, #64  ; data/moon/block0110-2.tmx + left (81)  left: hole, up: stairs, right: hole, 
  dw #0841
  db 14, #00, #54  ; data/moon/block1010-1.tmx + up (82)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/moon/block1100-1.tmx + right (83)  left: hole, up: hole, right: hole, 
  dw #0840
  db 14, #00, #64  ; data/moon/block1100-2.tmx + right (84)  left: hole, up: stairs, right: hole, 
  dw #0840
  db 15, #00, #55  ; data/moon/block0011-1.tmx + left + up (85)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/moon/block0101-1.tmx + left + right (86)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/moon/block0101-2.tmx + left + right (87)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
  db 15, #00, #55  ; data/moon/block0110-1.tmx + left + down (88)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/moon/block0110-2.tmx + left + down (89)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1001-1.tmx + up + right (90)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1001-2.tmx + up + right (91)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1010-1.tmx + up + down (92)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1100-1.tmx + right + down (93)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #65  ; data/moon/block1100-2.tmx + right + down (94)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
moon_combination_chunk_pool:
  db 0, #00, #00  ; data/moon/combination0000-1.tmx (95)  
  dw #0781
  db 1, #00, #01  ; data/moon/combination0000-1.tmx + down (96)  down: hole, 
  dw #0381
  db 2, #00, #04  ; data/moon/combination0000-1.tmx + right (97)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/moon/combination0000-1.tmx + right + down (98)  right: hole, down: hole, 
  dw #0181
  db 4, #00, #10  ; data/moon/combination0000-1.tmx + up (99)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/moon/combination0100-1.tmx (100)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/moon/combination0000-1.tmx + up + down (101)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #21  ; data/moon/combination0100-1.tmx + down (102)  up: stairs, down: hole, 
  dw #0281
  db 6, #00, #14  ; data/moon/combination0000-1.tmx + up + right (103)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/moon/combination0100-1.tmx + right (104)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/moon/combination0000-1.tmx + up + right + down (105)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #25  ; data/moon/combination0100-1.tmx + right + down (106)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 8, #00, #40  ; data/moon/combination0000-1.tmx + left (107)  left: hole, 
  dw #0701
  db 9, #00, #41  ; data/moon/combination0000-1.tmx + left + down (108)  left: hole, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/moon/combination0000-1.tmx + left + right (109)  left: hole, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/moon/combination0000-1.tmx + left + right + down (110)  left: hole, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/moon/combination0000-1.tmx + left + up (111)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/moon/combination0100-1.tmx + left (112)  left: hole, up: stairs, 
  dw #0601
  db 13, #00, #51  ; data/moon/combination0000-1.tmx + left + up + down (113)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #61  ; data/moon/combination0100-1.tmx + left + down (114)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/moon/combination0000-1.tmx + left + up + right (115)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/moon/combination0100-1.tmx + left + right (116)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/moon/combination0000-1.tmx + left + up + right + down (117)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #65  ; data/moon/combination0100-1.tmx + left + right + down (118)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
