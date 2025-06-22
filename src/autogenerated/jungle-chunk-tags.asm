; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
jungle_chunk_flags:
jungle_standard_chunk_pool:
  db 0, #00, #00  ; data/jungle/room0000-1.tmx (0)  
  dw #02ef
  db 1, #00, #01  ; data/jungle/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 1, #00, #01  ; data/jungle/room0001-2.tmx (2)  down: hole, 
  dw #02af
  db 2, #00, #04  ; data/jungle/room0010-1.tmx (3)  right: hole, 
  dw #019f
  db 2, #00, #04  ; data/jungle/room0010-2.tmx (4)  right: hole, 
  dw #0d57
  db 2, #00, #08  ; data/jungle/room0010-3.tmx (5)  right: water, 
  dw #019f
  db 3, #00, #05  ; data/jungle/room0011-1.tmx (6)  right: hole, down: hole, 
  dw #008f
  db 3, #00, #06  ; data/jungle/room0011-2.tmx (7)  right: hole, down: stairs, 
  dw #008f
  db 3, #00, #05  ; data/jungle/room0011-3.tmx (8)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #05  ; data/jungle/room0011-4.tmx (9)  right: hole, down: hole, 
  dw #019f
  db 4, #00, #10  ; data/jungle/room0100-1.tmx (10)  up: hole, 
  dw #02af
  db 4, #00, #10  ; data/jungle/room0100-2.tmx (11)  up: hole, 
  dw #02af
  db 4, #00, #10  ; data/jungle/room0100-3.tmx (12)  up: hole, 
  dw #06ef
  db 5, #00, #11  ; data/jungle/room0101-1.tmx (13)  up: hole, down: hole, 
  dw #02af
  db 5, #00, #12  ; data/jungle/room0101-2.tmx (14)  up: hole, down: stairs, 
  dw #02af
  db 6, #00, #14  ; data/jungle/room0110-1.tmx (15)  up: hole, right: hole, 
  dw #0089
  db 6, #00, #14  ; data/jungle/room0110-2.tmx (16)  up: hole, right: hole, 
  dw #008f
  db 6, #00, #14  ; data/jungle/room0110-3.tmx (17)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #18  ; data/jungle/room0110-4.tmx (18)  up: hole, right: water, 
  dw #0089
  db 7, #00, #15  ; data/jungle/room0111-1.tmx (19)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #16  ; data/jungle/room0111-2.tmx (20)  up: hole, right: hole, down: stairs, 
  dw #008f
  db 8, #00, #40  ; data/jungle/room1000-1.tmx (21)  left: hole, 
  dw #0777
  db 8, #00, #40  ; data/jungle/room1000-2.tmx (22)  left: hole, 
  dw #0267
  db 8, #00, #40  ; data/jungle/room1000-3.tmx (23)  left: hole, 
  dw #0227
  db 8, #00, #80  ; data/jungle/room1000-4.tmx (24)  left: water, 
  dw #0227
  db 8, #00, #80  ; data/jungle/room1000-5.tmx (25)  left: water, 
  dw #0667
  db 9, #00, #41  ; data/jungle/room1001-1.tmx (26)  left: hole, down: hole, 
  dw #0227
  db 9, #00, #42  ; data/jungle/room1001-2.tmx (27)  left: hole, down: stairs, 
  dw #0227
  db 9, #00, #41  ; data/jungle/room1001-3.tmx (28)  left: hole, down: hole, 
  dw #0b37
  db 9, #00, #81  ; data/jungle/room1001-4.tmx (29)  left: water, down: hole, 
  dw #0227
  db 9, #00, #82  ; data/jungle/room1001-5.tmx (30)  left: water, down: stairs, 
  dw #0227
  db 10, #00, #44  ; data/jungle/room1010-1.tmx (31)  left: hole, right: hole, 
  dw #0047
  db 10, #00, #44  ; data/jungle/room1010-2.tmx (32)  left: hole, right: hole, 
  dw #0111
  db 10, #00, #44  ; data/jungle/room1010-3.tmx (33)  left: hole, right: hole, 
  dw #0557
  db 10, #00, #88  ; data/jungle/room1010-4.tmx (34)  left: water, right: water, 
  dw #0111
  db 10, #00, #84  ; data/jungle/room1010-5.tmx (35)  left: water, right: hole, 
  dw #0557
  db 11, #00, #45  ; data/jungle/room1011-1.tmx (36)  left: hole, right: hole, down: hole, 
  dw #0001
  db 11, #00, #45  ; data/jungle/room1011-2.tmx (37)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #46  ; data/jungle/room1011-3.tmx (38)  left: hole, right: hole, down: stairs, 
  dw #0007
  db 11, #00, #85  ; data/jungle/room1011-4.tmx (39)  left: water, right: hole, down: hole, 
  dw #0913
  db 11, #00, #86  ; data/jungle/room1011-5.tmx (40)  left: water, right: hole, down: stairs, 
  dw #0117
  db 11, #00, #45  ; data/jungle/room1011-6.tmx (41)  left: hole, right: hole, down: hole, 
  dw #0007
  db 12, #00, #50  ; data/jungle/room1100-1.tmx (42)  left: hole, up: hole, 
  dw #0e67
  db 12, #00, #50  ; data/jungle/room1100-2.tmx (43)  left: hole, up: hole, 
  dw #0221
  db 12, #00, #90  ; data/jungle/room1100-3.tmx (44)  left: water, up: hole, 
  dw #0227
  db 12, #00, #90  ; data/jungle/room1100-4.tmx (45)  left: water, up: hole, 
  dw #0667
  db 13, #00, #51  ; data/jungle/room1101-1.tmx (46)  left: hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #52  ; data/jungle/room1101-2.tmx (47)  left: hole, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #91  ; data/jungle/room1101-3.tmx (48)  left: water, up: hole, down: hole, 
  dw #0a27
  db 13, #00, #92  ; data/jungle/room1101-4.tmx (49)  left: water, up: hole, down: stairs, 
  dw #0227
  db 14, #00, #54  ; data/jungle/room1110-1.tmx (50)  left: hole, up: hole, right: hole, 
  dw #0007
  db 14, #00, #54  ; data/jungle/room1110-2.tmx (51)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #98  ; data/jungle/room1110-3.tmx (52)  left: water, up: hole, right: water, 
  dw #0001
  db 14, #00, #98  ; data/jungle/room1110-4.tmx (53)  left: water, up: hole, right: water, 
  dw #0447
  db 15, #00, #55  ; data/jungle/room1111-1.tmx (54)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #56  ; data/jungle/room1111-2.tmx (55)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #95  ; data/jungle/room1111-3.tmx (56)  left: water, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #96  ; data/jungle/room1111-4.tmx (57)  left: water, up: hole, right: hole, down: stairs, 
  dw #0007
jungle_boss_chunk_pool:
jungle_block_chunk_pool:
  db 3, #00, #05  ; data/jungle/block0011-1.tmx (58)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #06  ; data/jungle/block0011-2.tmx (59)  right: hole, down: stairs, 
  dw #099f
  db 5, #00, #11  ; data/jungle/block0101-1.tmx (60)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #12  ; data/jungle/block0101-2.tmx (61)  up: hole, down: stairs, 
  dw #0829
  db 6, #00, #14  ; data/jungle/block0110-1.tmx (62)  up: hole, right: hole, 
  dw #0809
  db 7, #00, #15  ; data/jungle/block0011-1.tmx + up (63)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #16  ; data/jungle/block0011-2.tmx + up (64)  up: hole, right: hole, down: stairs, 
  dw #088f
  db 7, #00, #15  ; data/jungle/block0101-1.tmx + right (65)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #16  ; data/jungle/block0101-2.tmx + right (66)  up: hole, right: hole, down: stairs, 
  dw #0809
  db 7, #00, #16  ; data/jungle/block0111-1.tmx (67)  up: hole, right: hole, down: stairs, 
  dw #0809
  db 9, #00, #41  ; data/jungle/block1001-1.tmx (68)  left: hole, down: hole, 
  dw #0a31
  db 9, #00, #42  ; data/jungle/block1001-2.tmx (69)  left: hole, down: stairs, 
  dw #0a31
  db 9, #00, #82  ; data/jungle/block1001-3.tmx (70)  left: water, down: stairs, 
  dw #0a31
  db 9, #00, #81  ; data/jungle/block1001-4.tmx (71)  left: water, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/jungle/block1010-1.tmx (72)  left: hole, right: hole, 
  dw #0d50
  db 10, #00, #84  ; data/jungle/block1010-2.tmx (73)  left: water, right: hole, 
  dw #0d50
  db 11, #00, #45  ; data/jungle/block0011-1.tmx + left (74)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #46  ; data/jungle/block0011-2.tmx + left (75)  left: hole, right: hole, down: stairs, 
  dw #0917
  db 11, #00, #45  ; data/jungle/block1001-1.tmx + right (76)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #46  ; data/jungle/block1001-2.tmx + right (77)  left: hole, right: hole, down: stairs, 
  dw #0811
  db 11, #00, #86  ; data/jungle/block1001-3.tmx + right (78)  left: water, right: hole, down: stairs, 
  dw #0811
  db 11, #00, #85  ; data/jungle/block1001-4.tmx + right (79)  left: water, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/jungle/block1010-1.tmx + down (80)  left: hole, right: hole, down: hole, 
  dw #0910
  db 11, #00, #85  ; data/jungle/block1010-2.tmx + down (81)  left: water, right: hole, down: hole, 
  dw #0910
  db 12, #00, #50  ; data/jungle/block1100-1.tmx (82)  left: hole, up: hole, 
  dw #0a60
  db 12, #00, #90  ; data/jungle/block1100-2.tmx (83)  left: water, up: hole, 
  dw #0a60
  db 13, #00, #51  ; data/jungle/block0101-1.tmx + left (84)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #52  ; data/jungle/block0101-2.tmx + left (85)  left: hole, up: hole, down: stairs, 
  dw #0821
  db 13, #00, #51  ; data/jungle/block1001-1.tmx + up (86)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #52  ; data/jungle/block1001-2.tmx + up (87)  left: hole, up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #92  ; data/jungle/block1001-3.tmx + up (88)  left: water, up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #91  ; data/jungle/block1001-4.tmx + up (89)  left: water, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/jungle/block1100-1.tmx + down (90)  left: hole, up: hole, down: hole, 
  dw #0a20
  db 13, #00, #91  ; data/jungle/block1100-2.tmx + down (91)  left: water, up: hole, down: hole, 
  dw #0a20
  db 14, #00, #54  ; data/jungle/block0110-1.tmx + left (92)  left: hole, up: hole, right: hole, 
  dw #0801
  db 14, #00, #54  ; data/jungle/block1010-1.tmx + up (93)  left: hole, up: hole, right: hole, 
  dw #0c40
  db 14, #00, #94  ; data/jungle/block1010-2.tmx + up (94)  left: water, up: hole, right: hole, 
  dw #0c40
  db 14, #00, #54  ; data/jungle/block1100-1.tmx + right (95)  left: hole, up: hole, right: hole, 
  dw #0840
  db 14, #00, #94  ; data/jungle/block1100-2.tmx + right (96)  left: water, up: hole, right: hole, 
  dw #0840
  db 15, #00, #55  ; data/jungle/block0011-1.tmx + left + up (97)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #56  ; data/jungle/block0011-2.tmx + left + up (98)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0807
  db 15, #00, #55  ; data/jungle/block0101-1.tmx + left + right (99)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/jungle/block0101-2.tmx + left + right (100)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #56  ; data/jungle/block0111-1.tmx + left (101)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #55  ; data/jungle/block1001-1.tmx + up + right (102)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/jungle/block1001-2.tmx + up + right (103)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #96  ; data/jungle/block1001-3.tmx + up + right (104)  left: water, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #95  ; data/jungle/block1001-4.tmx + up + right (105)  left: water, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/jungle/block1010-1.tmx + up + down (106)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #95  ; data/jungle/block1010-2.tmx + up + down (107)  left: water, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #55  ; data/jungle/block1100-1.tmx + right + down (108)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #95  ; data/jungle/block1100-2.tmx + right + down (109)  left: water, up: hole, right: hole, down: hole, 
  dw #0800
jungle_combination_chunk_pool:
  db 0, #00, #00  ; data/jungle/combination0000-1.tmx (110)  
  dw #0781
  db 1, #00, #01  ; data/jungle/combination0000-1.tmx + down (111)  down: hole, 
  dw #0381
  db 1, #00, #02  ; data/jungle/combination0001-1.tmx (112)  down: stairs, 
  dw #0381
  db 2, #00, #04  ; data/jungle/combination0000-1.tmx + right (113)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/jungle/combination0000-1.tmx + right + down (114)  right: hole, down: hole, 
  dw #0181
  db 3, #00, #06  ; data/jungle/combination0001-1.tmx + right (115)  right: hole, down: stairs, 
  dw #0181
  db 4, #00, #10  ; data/jungle/combination0000-1.tmx + up (116)  up: hole, 
  dw #0681
  db 5, #00, #11  ; data/jungle/combination0000-1.tmx + up + down (117)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #12  ; data/jungle/combination0001-1.tmx + up (118)  up: hole, down: stairs, 
  dw #0281
  db 6, #00, #14  ; data/jungle/combination0000-1.tmx + up + right (119)  up: hole, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/jungle/combination0000-1.tmx + up + right + down (120)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #16  ; data/jungle/combination0001-1.tmx + up + right (121)  up: hole, right: hole, down: stairs, 
  dw #0081
  db 8, #00, #40  ; data/jungle/combination0000-1.tmx + left (122)  left: hole, 
  dw #0701
  db 8, #00, #80  ; data/jungle/combination1000-1.tmx (123)  left: water, 
  dw #0701
  db 9, #00, #41  ; data/jungle/combination0000-1.tmx + left + down (124)  left: hole, down: hole, 
  dw #0301
  db 9, #00, #42  ; data/jungle/combination0001-1.tmx + left (125)  left: hole, down: stairs, 
  dw #0301
  db 9, #00, #81  ; data/jungle/combination1000-1.tmx + down (126)  left: water, down: hole, 
  dw #0301
  db 9, #00, #82  ; data/jungle/combination1001-1.tmx (127)  left: water, down: stairs, 
  dw #0301
  db 10, #00, #44  ; data/jungle/combination0000-1.tmx + left + right (128)  left: hole, right: hole, 
  dw #0501
  db 10, #00, #84  ; data/jungle/combination1000-1.tmx + right (129)  left: water, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/jungle/combination0000-1.tmx + left + right + down (130)  left: hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #46  ; data/jungle/combination0001-1.tmx + left + right (131)  left: hole, right: hole, down: stairs, 
  dw #0101
  db 11, #00, #85  ; data/jungle/combination1000-1.tmx + right + down (132)  left: water, right: hole, down: hole, 
  dw #0101
  db 11, #00, #86  ; data/jungle/combination1001-1.tmx + right (133)  left: water, right: hole, down: stairs, 
  dw #0101
  db 12, #00, #50  ; data/jungle/combination0000-1.tmx + left + up (134)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #90  ; data/jungle/combination1000-1.tmx + up (135)  left: water, up: hole, 
  dw #0601
  db 13, #00, #51  ; data/jungle/combination0000-1.tmx + left + up + down (136)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #52  ; data/jungle/combination0001-1.tmx + left + up (137)  left: hole, up: hole, down: stairs, 
  dw #0201
  db 13, #00, #91  ; data/jungle/combination1000-1.tmx + up + down (138)  left: water, up: hole, down: hole, 
  dw #0201
  db 13, #00, #92  ; data/jungle/combination1001-1.tmx + up (139)  left: water, up: hole, down: stairs, 
  dw #0201
  db 14, #00, #54  ; data/jungle/combination0000-1.tmx + left + up + right (140)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #94  ; data/jungle/combination1000-1.tmx + up + right (141)  left: water, up: hole, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/jungle/combination0000-1.tmx + left + up + right + down (142)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #56  ; data/jungle/combination0001-1.tmx + left + up + right (143)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0001
  db 15, #00, #95  ; data/jungle/combination1000-1.tmx + up + right + down (144)  left: water, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #96  ; data/jungle/combination1001-1.tmx + up + right (145)  left: water, up: hole, right: hole, down: stairs, 
  dw #0001
