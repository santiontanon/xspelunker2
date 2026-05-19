; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
mars_chunk_flags:
mars_standard_chunk_pool:
  db 0, #00, #00  ; data/mars/room0000-1.tmx (0)  
  dw #06ef
  db 1, #00, #01  ; data/mars/room0001-1.tmx (1)  down: hole, 
  dw #03bb
  db 1, #00, #02  ; data/mars/room0001-2.tmx (2)  down: stairs, 
  dw #63bf
  db 1, #00, #01  ; data/mars/room0001-3.tmx (3)  down: hole, 
  dw #03bf
  db 1, #00, #02  ; data/mars/room0001-4.tmx (4)  down: stairs, 
  dw #03b9
  db 2, #00, #04  ; data/mars/room0010-1.tmx (5)  right: hole, 
  dw #25df
  db 2, #00, #08  ; data/mars/room0010-2.tmx (6)  right: lava, 
  dw #219f
  db 2, #00, #04  ; data/mars/room0010-3.tmx (7)  right: hole, 
  dw #24cf
  db 2, #00, #08  ; data/mars/room0010-4.tmx (8)  right: lava, 
  dw #008f
  db 3, #00, #05  ; data/mars/room0011-1.tmx (9)  right: hole, down: hole, 
  dw #019f
  db 3, #00, #06  ; data/mars/room0011-2.tmx (10)  right: hole, down: stairs, 
  dw #019f
  db 3, #00, #05  ; data/mars/room0011-3.tmx (11)  right: hole, down: hole, 
  dw #0113
  db 3, #00, #06  ; data/mars/room0011-4.tmx (12)  right: hole, down: stairs, 
  dw #0199
  db 4, #00, #10  ; data/mars/room0100-1.tmx (13)  up: hole, 
  dw #0447
  db 4, #00, #10  ; data/mars/room0100-2.tmx (14)  up: hole, 
  dw #02af
  db 4, #00, #20  ; data/mars/room0100-3.tmx (15)  up: stairs, 
  dw #06ef
  db 4, #00, #10  ; data/mars/room0100-4.tmx (16)  up: hole, 
  dw #0007
  db 5, #00, #11  ; data/mars/room0101-1.tmx (17)  up: hole, down: hole, 
  dw #62af
  db 5, #00, #21  ; data/mars/room0101-2.tmx (18)  up: stairs, down: hole, 
  dw #02af
  db 5, #00, #12  ; data/mars/room0101-3.tmx (19)  up: hole, down: stairs, 
  dw #62af
  db 6, #00, #14  ; data/mars/room0110-1.tmx (20)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #24  ; data/mars/room0110-2.tmx (21)  up: stairs, right: hole, 
  dw #24cf
  db 6, #00, #18  ; data/mars/room0110-3.tmx (22)  up: hole, right: lava, 
  dw #0007
  db 7, #00, #15  ; data/mars/room0111-1.tmx (23)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #25  ; data/mars/room0111-2.tmx (24)  up: stairs, right: hole, down: hole, 
  dw #008f
  db 7, #00, #15  ; data/mars/room0111-3.tmx (25)  up: hole, right: hole, down: hole, 
  dw #008f
  db 8, #00, #40  ; data/mars/room1000-1.tmx (26)  left: hole, 
  dw #0777
  db 8, #00, #80  ; data/mars/room1000-2.tmx (27)  left: lava, 
  dw #0557
  db 8, #00, #40  ; data/mars/room1000-3.tmx (28)  left: hole, 
  dw #0667
  db 8, #00, #40  ; data/mars/room1000-4.tmx (29)  left: hole, 
  dw #0331
  db 8, #00, #40  ; data/mars/room1000-5.tmx (30)  left: hole, 
  dw #4663
  db 8, #00, #40  ; data/mars/room1000-6.tmx (31)  left: hole, 
  dw #4777
  db 9, #00, #41  ; data/mars/room1001-1.tmx (32)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/mars/room1001-2.tmx (33)  left: hole, down: stairs, 
  dw #0337
  db 9, #00, #81  ; data/mars/room1001-3.tmx (34)  left: lava, down: hole, 
  dw #0337
  db 9, #00, #41  ; data/mars/room1001-4.tmx (35)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/mars/room1001-5.tmx (36)  left: hole, down: stairs, 
  dw #0223
  db 10, #00, #44  ; data/mars/room1010-1.tmx (37)  left: hole, right: hole, 
  dw #0551
  db 10, #00, #44  ; data/mars/room1010-2.tmx (38)  left: hole, right: hole, 
  dw #4557
  db 10, #00, #84  ; data/mars/room1010-3.tmx (39)  left: lava, right: hole, 
  dw #0557
  db 10, #00, #88  ; data/mars/room1010-4.tmx (40)  left: lava, right: lava, 
  dw #0001
  db 10, #00, #44  ; data/mars/room1010-5.tmx (41)  left: hole, right: hole, 
  dw #0111
  db 10, #00, #44  ; data/mars/room1010-6.tmx (42)  left: hole, right: hole, 
  dw #6001
  db 11, #00, #45  ; data/mars/room1011-1.tmx (43)  left: hole, right: hole, down: hole, 
  dw #6117
  db 11, #00, #46  ; data/mars/room1011-2.tmx (44)  left: hole, right: hole, down: stairs, 
  dw #6117
  db 11, #00, #85  ; data/mars/room1011-3.tmx (45)  left: lava, right: hole, down: hole, 
  dw #2117
  db 11, #00, #45  ; data/mars/room1011-4.tmx (46)  left: hole, right: hole, down: hole, 
  dw #0117
  db 12, #00, #50  ; data/mars/room1100-1.tmx (47)  left: hole, up: hole, 
  dw #0667
  db 12, #00, #60  ; data/mars/room1100-2.tmx (48)  left: hole, up: stairs, 
  dw #4667
  db 12, #00, #90  ; data/mars/room1100-3.tmx (49)  left: lava, up: hole, 
  dw #4667
  db 12, #00, #a0  ; data/mars/room1100-4.tmx (50)  left: lava, up: stairs, 
  dw #0227
  db 12, #00, #50  ; data/mars/room1100-5.tmx (51)  left: hole, up: hole, 
  dw #0001
  db 13, #00, #51  ; data/mars/room1101-1.tmx (52)  left: hole, up: hole, down: hole, 
  dw #4227
  db 13, #00, #61  ; data/mars/room1101-2.tmx (53)  left: hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #a1  ; data/mars/room1101-3.tmx (54)  left: lava, up: stairs, down: hole, 
  dw #0221
  db 13, #00, #91  ; data/mars/room1101-4.tmx (55)  left: lava, up: hole, down: hole, 
  dw #0227
  db 13, #00, #51  ; data/mars/room1101-5.tmx (56)  left: hole, up: hole, down: hole, 
  dw #0227
  db 14, #00, #54  ; data/mars/room1110-1.tmx (57)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #64  ; data/mars/room1110-2.tmx (58)  left: hole, up: stairs, right: hole, 
  dw #2447
  db 14, #00, #a4  ; data/mars/room1110-3.tmx (59)  left: lava, up: stairs, right: hole, 
  dw #0007
  db 14, #00, #94  ; data/mars/room1110-4.tmx (60)  left: lava, up: hole, right: hole, 
  dw #0447
  db 14, #00, #54  ; data/mars/room1110-5.tmx (61)  left: hole, up: hole, right: hole, 
  dw #0001
  db 15, #00, #55  ; data/mars/room1111-1.tmx (62)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #65  ; data/mars/room1111-2.tmx (63)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #95  ; data/mars/room1111-3.tmx (64)  left: lava, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #a5  ; data/mars/room1111-4.tmx (65)  left: lava, up: stairs, right: hole, down: hole, 
  dw #0007
mars_boss_chunk_pool:
  db 1, #01, #01  ; data/mars/boss0001-1.tmx (66)  down: hole, 
  dw #0005
  db 2, #01, #04  ; data/mars/boss0010-1.tmx (67)  right: hole, 
  dw #0005
  db 3, #01, #05  ; data/mars/boss0011-1.tmx (68)  right: hole, down: hole, 
  dw #0005
  db 4, #01, #10  ; data/mars/boss0100-1.tmx (69)  up: hole, 
  dw #0005
  db 4, #01, #20  ; data/mars/boss0100-2.tmx (70)  up: stairs, 
  dw #0005
  db 5, #01, #11  ; data/mars/boss0101-1.tmx (71)  up: hole, down: hole, 
  dw #0005
  db 5, #01, #21  ; data/mars/boss0101-2.tmx (72)  up: stairs, down: hole, 
  dw #0005
  db 6, #01, #14  ; data/mars/boss0110-1.tmx (73)  up: hole, right: hole, 
  dw #0005
  db 6, #01, #24  ; data/mars/boss0110-2.tmx (74)  up: stairs, right: hole, 
  dw #0005
  db 7, #01, #15  ; data/mars/boss0111-1.tmx (75)  up: hole, right: hole, down: hole, 
  dw #0005
  db 7, #01, #25  ; data/mars/boss0111-2.tmx (76)  up: stairs, right: hole, down: hole, 
  dw #0005
  db 8, #01, #40  ; data/mars/boss1000-1.tmx (77)  left: hole, 
  dw #0005
  db 8, #01, #80  ; data/mars/boss1000-2.tmx (78)  left: lava, 
  dw #0005
  db 9, #01, #41  ; data/mars/boss1001-1.tmx (79)  left: hole, down: hole, 
  dw #0337
  db 10, #01, #44  ; data/mars/boss1010-1.tmx (80)  left: hole, right: hole, 
  dw #0005
  db 10, #01, #84  ; data/mars/boss1010-2.tmx (81)  left: lava, right: hole, 
  dw #0005
  db 11, #01, #45  ; data/mars/boss1011-1.tmx (82)  left: hole, right: hole, down: hole, 
  dw #0005
  db 12, #01, #50  ; data/mars/boss1100-1.tmx (83)  left: hole, up: hole, 
  dw #0005
  db 12, #01, #60  ; data/mars/boss1100-2.tmx (84)  left: hole, up: stairs, 
  dw #0005
  db 12, #01, #a0  ; data/mars/boss1100-3.tmx (85)  left: lava, up: stairs, 
  dw #0005
  db 13, #01, #51  ; data/mars/boss1101-1.tmx (86)  left: hole, up: hole, down: hole, 
  dw #0005
  db 13, #01, #41  ; data/mars/boss1101-2.tmx (87)  left: hole, up: ladder, down: hole, 
  dw #0005
  db 14, #01, #54  ; data/mars/boss1110-1.tmx (88)  left: hole, up: hole, right: hole, 
  dw #0005
  db 14, #01, #64  ; data/mars/boss1110-2.tmx (89)  left: hole, up: stairs, right: hole, 
  dw #0005
  db 15, #01, #55  ; data/mars/boss1111-1.tmx (90)  left: hole, up: hole, right: hole, down: hole, 
  dw #0005
  db 15, #01, #65  ; data/mars/boss1111-2.tmx (91)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0005
mars_block_chunk_pool:
  db 3, #00, #05  ; data/mars/block0011-1.tmx (92)  right: hole, down: hole, 
  dw #099f
  db 5, #00, #11  ; data/mars/block0101-1.tmx (93)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/mars/block0101-2.tmx (94)  up: stairs, down: hole, 
  dw #0828
  db 6, #00, #14  ; data/mars/block0110-1.tmx (95)  up: hole, right: hole, 
  dw #0849
  db 6, #00, #24  ; data/mars/block0110-2.tmx (96)  up: stairs, right: hole, 
  dw #0849
  db 7, #00, #15  ; data/mars/block0011-1.tmx + up (97)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/mars/block0101-1.tmx + right (98)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/mars/block0101-2.tmx + right (99)  up: stairs, right: hole, down: hole, 
  dw #0808
  db 7, #00, #15  ; data/mars/block0110-1.tmx + down (100)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/mars/block0110-2.tmx + down (101)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 9, #00, #41  ; data/mars/block1001-1.tmx (102)  left: hole, down: hole, 
  dw #0a31
  db 9, #00, #41  ; data/mars/block1001-2.tmx (103)  left: hole, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/mars/block1010-1.tmx (104)  left: hole, right: hole, 
  dw #0d51
  db 10, #00, #84  ; data/mars/block1010-2.tmx (105)  left: lava, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/mars/block0011-1.tmx + left (106)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/mars/block1001-1.tmx + right (107)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/mars/block1001-2.tmx + right (108)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/mars/block1010-1.tmx + down (109)  left: hole, right: hole, down: hole, 
  dw #0911
  db 11, #00, #85  ; data/mars/block1010-2.tmx + down (110)  left: lava, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/mars/block1100-1.tmx (111)  left: hole, up: hole, 
  dw #0a60
  db 12, #00, #60  ; data/mars/block1100-2.tmx (112)  left: hole, up: stairs, 
  dw #0a60
  db 12, #00, #90  ; data/mars/block1100-3.tmx (113)  left: lava, up: hole, 
  dw #0a60
  db 13, #00, #51  ; data/mars/block0101-1.tmx + left (114)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #61  ; data/mars/block0101-2.tmx + left (115)  left: hole, up: stairs, down: hole, 
  dw #0820
  db 13, #00, #51  ; data/mars/block1001-1.tmx + up (116)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/mars/block1001-2.tmx + up (117)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/mars/block1100-1.tmx + down (118)  left: hole, up: hole, down: hole, 
  dw #0a20
  db 13, #00, #61  ; data/mars/block1100-2.tmx + down (119)  left: hole, up: stairs, down: hole, 
  dw #0a20
  db 13, #00, #91  ; data/mars/block1100-3.tmx + down (120)  left: lava, up: hole, down: hole, 
  dw #0a20
  db 14, #00, #54  ; data/mars/block0110-1.tmx + left (121)  left: hole, up: hole, right: hole, 
  dw #0841
  db 14, #00, #64  ; data/mars/block0110-2.tmx + left (122)  left: hole, up: stairs, right: hole, 
  dw #0841
  db 14, #00, #54  ; data/mars/block1010-1.tmx + up (123)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #94  ; data/mars/block1010-2.tmx + up (124)  left: lava, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/mars/block1100-1.tmx + right (125)  left: hole, up: hole, right: hole, 
  dw #0840
  db 14, #00, #64  ; data/mars/block1100-2.tmx + right (126)  left: hole, up: stairs, right: hole, 
  dw #0840
  db 14, #00, #94  ; data/mars/block1100-3.tmx + right (127)  left: lava, up: hole, right: hole, 
  dw #0840
  db 15, #00, #55  ; data/mars/block0011-1.tmx + left + up (128)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/mars/block0101-1.tmx + left + right (129)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/mars/block0101-2.tmx + left + right (130)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
  db 15, #00, #55  ; data/mars/block0110-1.tmx + left + down (131)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/mars/block0110-2.tmx + left + down (132)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/mars/block1001-1.tmx + up + right (133)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/mars/block1001-2.tmx + up + right (134)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/mars/block1010-1.tmx + up + down (135)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #95  ; data/mars/block1010-2.tmx + up + down (136)  left: lava, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/mars/block1100-1.tmx + right + down (137)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #65  ; data/mars/block1100-2.tmx + right + down (138)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
  db 15, #00, #95  ; data/mars/block1100-3.tmx + right + down (139)  left: lava, up: hole, right: hole, down: hole, 
  dw #0800
mars_combination_chunk_pool:
  db 0, #00, #00  ; data/mars/combination0000-1.tmx (140)  
  dw #0781
  db 1, #00, #01  ; data/mars/combination0000-1.tmx + down (141)  down: hole, 
  dw #0381
  db 2, #00, #04  ; data/mars/combination0000-1.tmx + right (142)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/mars/combination0000-1.tmx + right + down (143)  right: hole, down: hole, 
  dw #0181
  db 4, #00, #10  ; data/mars/combination0000-1.tmx + up (144)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/mars/combination0100-1.tmx (145)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/mars/combination0000-1.tmx + up + down (146)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #21  ; data/mars/combination0100-1.tmx + down (147)  up: stairs, down: hole, 
  dw #0281
  db 6, #00, #14  ; data/mars/combination0000-1.tmx + up + right (148)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/mars/combination0100-1.tmx + right (149)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/mars/combination0000-1.tmx + up + right + down (150)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #25  ; data/mars/combination0100-1.tmx + right + down (151)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 8, #00, #40  ; data/mars/combination0000-1.tmx + left (152)  left: hole, 
  dw #0701
  db 8, #00, #80  ; data/mars/combination1000-1.tmx (153)  left: lava, 
  dw #0701
  db 9, #00, #41  ; data/mars/combination0000-1.tmx + left + down (154)  left: hole, down: hole, 
  dw #0301
  db 9, #00, #81  ; data/mars/combination1000-1.tmx + down (155)  left: lava, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/mars/combination0000-1.tmx + left + right (156)  left: hole, right: hole, 
  dw #0501
  db 10, #00, #84  ; data/mars/combination1000-1.tmx + right (157)  left: lava, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/mars/combination0000-1.tmx + left + right + down (158)  left: hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #85  ; data/mars/combination1000-1.tmx + right + down (159)  left: lava, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/mars/combination0000-1.tmx + left + up (160)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/mars/combination0100-1.tmx + left (161)  left: hole, up: stairs, 
  dw #0601
  db 12, #00, #90  ; data/mars/combination1000-1.tmx + up (162)  left: lava, up: hole, 
  dw #0601
  db 12, #00, #a0  ; data/mars/combination1100-1.tmx (163)  left: lava, up: stairs, 
  dw #0601
  db 13, #00, #51  ; data/mars/combination0000-1.tmx + left + up + down (164)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #61  ; data/mars/combination0100-1.tmx + left + down (165)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 13, #00, #91  ; data/mars/combination1000-1.tmx + up + down (166)  left: lava, up: hole, down: hole, 
  dw #0201
  db 13, #00, #a1  ; data/mars/combination1100-1.tmx + down (167)  left: lava, up: stairs, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/mars/combination0000-1.tmx + left + up + right (168)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/mars/combination0100-1.tmx + left + right (169)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 14, #00, #94  ; data/mars/combination1000-1.tmx + up + right (170)  left: lava, up: hole, right: hole, 
  dw #0401
  db 14, #00, #a4  ; data/mars/combination1100-1.tmx + right (171)  left: lava, up: stairs, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/mars/combination0000-1.tmx + left + up + right + down (172)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #65  ; data/mars/combination0100-1.tmx + left + right + down (173)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
  db 15, #00, #95  ; data/mars/combination1000-1.tmx + up + right + down (174)  left: lava, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #a5  ; data/mars/combination1100-1.tmx + right + down (175)  left: lava, up: stairs, right: hole, down: hole, 
  dw #0001
