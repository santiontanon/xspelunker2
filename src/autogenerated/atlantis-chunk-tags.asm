; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
atlantis_chunk_flags:
atlantis_standard_chunk_pool:
  db 0, #00, #00  ; data/atlantis/room0000-1.tmx (0)  
  dw #02af
  db 1, #00, #01  ; data/atlantis/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 1, #00, #02  ; data/atlantis/room0001-2.tmx (2)  down: stairs, 
  dw #0bbf
  db 1, #00, #03  ; data/atlantis/room0001-3.tmx (3)  down: water, 
  dw #03b9
  db 2, #00, #04  ; data/atlantis/room0010-1.tmx (4)  right: hole, 
  dw #2ddf
  db 2, #00, #04  ; data/atlantis/room0010-2.tmx (5)  right: hole, 
  dw #25df
  db 3, #00, #05  ; data/atlantis/room0011-1.tmx (6)  right: hole, down: hole, 
  dw #019f
  db 3, #00, #06  ; data/atlantis/room0011-2.tmx (7)  right: hole, down: stairs, 
  dw #219f
  db 3, #00, #07  ; data/atlantis/room0011-3.tmx (8)  right: hole, down: water, 
  dw #019f
  db 3, #00, #05  ; data/atlantis/room0011-4.tmx (9)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #05  ; data/atlantis/room0011-5.tmx (10)  right: hole, down: hole, 
  dw #019f
  db 4, #00, #10  ; data/atlantis/room0100-1.tmx (11)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/atlantis/room0100-2.tmx (12)  up: stairs, 
  dw #0001
  db 4, #00, #20  ; data/atlantis/room0100-3.tmx (13)  up: stairs, 
  dw #06ef
  db 4, #00, #30  ; data/atlantis/room0100-4.tmx (14)  up: water, 
  dw #0001
  db 4, #00, #30  ; data/atlantis/room0100-5.tmx (15)  up: water, 
  dw #22af
  db 4, #00, #10  ; data/atlantis/room0100-6.tmx (16)  up: hole, 
  dw #06ef
  db 4, #00, #10  ; data/atlantis/room0100-7.tmx (17)  up: hole, 
  dw #0447
  db 4, #00, #10  ; data/atlantis/room0100-8.tmx (18)  up: hole, 
  dw #26ef
  db 5, #00, #11  ; data/atlantis/room0101-1.tmx (19)  up: hole, down: hole, 
  dw #22af
  db 5, #00, #21  ; data/atlantis/room0101-2.tmx (20)  up: stairs, down: hole, 
  dw #22af
  db 5, #00, #31  ; data/atlantis/room0101-3.tmx (21)  up: water, down: hole, 
  dw #02af
  db 5, #00, #11  ; data/atlantis/room0101-4.tmx (22)  up: hole, down: hole, 
  dw #02a9
  db 5, #00, #11  ; data/atlantis/room0101-5.tmx (23)  up: hole, down: hole, 
  dw #002f
  db 6, #00, #14  ; data/atlantis/room0110-1.tmx (24)  up: hole, right: hole, 
  dw #288f
  db 6, #00, #14  ; data/atlantis/room0110-2.tmx (25)  up: hole, right: hole, 
  dw #0007
  db 6, #00, #24  ; data/atlantis/room0110-3.tmx (26)  up: stairs, right: hole, 
  dw #208f
  db 6, #00, #34  ; data/atlantis/room0110-4.tmx (27)  up: water, right: hole, 
  dw #0007
  db 6, #00, #14  ; data/atlantis/room0110-5.tmx (28)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #34  ; data/atlantis/room0110-6.tmx (29)  up: water, right: hole, 
  dw #008f
  db 7, #00, #15  ; data/atlantis/room0111-1.tmx (30)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #25  ; data/atlantis/room0111-2.tmx (31)  up: stairs, right: hole, down: hole, 
  dw #208f
  db 7, #00, #26  ; data/atlantis/room0111-3.tmx (32)  up: stairs, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #36  ; data/atlantis/room0111-4.tmx (33)  up: water, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #35  ; data/atlantis/room0111-5.tmx (34)  up: water, right: hole, down: hole, 
  dw #008f
  db 7, #00, #15  ; data/atlantis/room0111-6.tmx (35)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #15  ; data/atlantis/room0111-7.tmx (36)  up: hole, right: hole, down: hole, 
  dw #008f
  db 8, #00, #40  ; data/atlantis/room1000-1.tmx (37)  left: hole, 
  dw #0777
  db 8, #00, #40  ; data/atlantis/room1000-2.tmx (38)  left: hole, 
  dw #0771
  db 8, #00, #40  ; data/atlantis/room1000-3.tmx (39)  left: hole, 
  dw #2667
  db 8, #00, #40  ; data/atlantis/room1000-4.tmx (40)  left: hole, 
  dw #0001
  db 8, #00, #40  ; data/atlantis/room1000-5.tmx (41)  left: hole, 
  dw #0221
  db 9, #00, #41  ; data/atlantis/room1001-1.tmx (42)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/atlantis/room1001-2.tmx (43)  left: hole, down: stairs, 
  dw #0337
  db 9, #00, #41  ; data/atlantis/room1001-3.tmx (44)  left: hole, down: hole, 
  dw #0337
  db 10, #00, #44  ; data/atlantis/room1010-1.tmx (45)  left: hole, right: hole, 
  dw #0551
  db 10, #00, #44  ; data/atlantis/room1010-2.tmx (46)  left: hole, right: hole, 
  dw #0117
  db 10, #00, #44  ; data/atlantis/room1010-3.tmx (47)  left: hole, right: hole, 
  dw #0551
  db 10, #00, #44  ; data/atlantis/room1010-4.tmx (48)  left: hole, right: hole, 
  dw #2441
  db 11, #00, #45  ; data/atlantis/room1011-1.tmx (49)  left: hole, right: hole, down: hole, 
  dw #2117
  db 11, #00, #46  ; data/atlantis/room1011-2.tmx (50)  left: hole, right: hole, down: stairs, 
  dw #2117
  db 11, #00, #45  ; data/atlantis/room1011-3.tmx (51)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #45  ; data/atlantis/room1011-4.tmx (52)  left: hole, right: hole, down: hole, 
  dw #0113
  db 12, #00, #50  ; data/atlantis/room1100-1.tmx (53)  left: hole, up: hole, 
  dw #2667
  db 12, #00, #60  ; data/atlantis/room1100-2.tmx (54)  left: hole, up: stairs, 
  dw #2667
  db 12, #00, #70  ; data/atlantis/room1100-3.tmx (55)  left: hole, up: water, 
  dw #0007
  db 12, #00, #70  ; data/atlantis/room1100-4.tmx (56)  left: hole, up: water, 
  dw #0667
  db 12, #00, #60  ; data/atlantis/room1100-5.tmx (57)  left: hole, up: stairs, 
  dw #0667
  db 12, #00, #50  ; data/atlantis/room1100-6.tmx (58)  left: hole, up: hole, 
  dw #2e67
  db 13, #00, #51  ; data/atlantis/room1101-1.tmx (59)  left: hole, up: hole, down: hole, 
  dw #2227
  db 13, #00, #61  ; data/atlantis/room1101-2.tmx (60)  left: hole, up: stairs, down: hole, 
  dw #2227
  db 13, #00, #62  ; data/atlantis/room1101-3.tmx (61)  left: hole, up: stairs, down: stairs, 
  dw #2007
  db 13, #00, #71  ; data/atlantis/room1101-4.tmx (62)  left: hole, up: water, down: hole, 
  dw #0007
  db 13, #00, #51  ; data/atlantis/room1101-5.tmx (63)  left: hole, up: hole, down: hole, 
  dw #0227
  db 14, #00, #54  ; data/atlantis/room1110-1.tmx (64)  left: hole, up: hole, right: hole, 
  dw #2447
  db 14, #00, #64  ; data/atlantis/room1110-2.tmx (65)  left: hole, up: stairs, right: hole, 
  dw #2447
  db 14, #00, #74  ; data/atlantis/room1110-3.tmx (66)  left: hole, up: water, right: hole, 
  dw #0001
  db 14, #00, #64  ; data/atlantis/room1110-4.tmx (67)  left: hole, up: stairs, right: hole, 
  dw #0443
  db 14, #00, #54  ; data/atlantis/room1110-5.tmx (68)  left: hole, up: hole, right: hole, 
  dw #0443
  db 14, #00, #74  ; data/atlantis/room1110-6.tmx (69)  left: hole, up: water, right: hole, 
  dw #0447
  db 15, #00, #55  ; data/atlantis/room1111-1.tmx (70)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #65  ; data/atlantis/room1111-2.tmx (71)  left: hole, up: stairs, right: hole, down: hole, 
  dw #2007
  db 15, #00, #75  ; data/atlantis/room1111-3.tmx (72)  left: hole, up: water, right: hole, down: hole, 
  dw #2007
atlantis_boss_chunk_pool:
atlantis_block_chunk_pool:
  db 3, #00, #05  ; data/atlantis/block0011-1.tmx (73)  right: hole, down: hole, 
  dw #099f
  db 5, #00, #11  ; data/atlantis/block0101-1.tmx (74)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/atlantis/block0101-2.tmx (75)  up: stairs, down: hole, 
  dw #0829
  db 6, #00, #14  ; data/atlantis/block0110-1.tmx (76)  up: hole, right: hole, 
  dw #0849
  db 6, #00, #24  ; data/atlantis/block0110-2.tmx (77)  up: stairs, right: hole, 
  dw #0849
  db 7, #00, #15  ; data/atlantis/block0011-1.tmx + up (78)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/atlantis/block0101-1.tmx + right (79)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/atlantis/block0101-2.tmx + right (80)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 7, #00, #15  ; data/atlantis/block0110-1.tmx + down (81)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/atlantis/block0110-2.tmx + down (82)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 9, #00, #41  ; data/atlantis/block1001-1.tmx (83)  left: hole, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/atlantis/block1010-1.tmx (84)  left: hole, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/atlantis/block0011-1.tmx + left (85)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/atlantis/block1001-1.tmx + right (86)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/atlantis/block1010-1.tmx + down (87)  left: hole, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/atlantis/block1100-1.tmx (88)  left: hole, up: hole, 
  dw #0a60
  db 12, #00, #60  ; data/atlantis/block1100-2.tmx (89)  left: hole, up: stairs, 
  dw #0a60
  db 13, #00, #51  ; data/atlantis/block0101-1.tmx + left (90)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #61  ; data/atlantis/block0101-2.tmx + left (91)  left: hole, up: stairs, down: hole, 
  dw #0821
  db 13, #00, #51  ; data/atlantis/block1001-1.tmx + up (92)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/atlantis/block1100-1.tmx + down (93)  left: hole, up: hole, down: hole, 
  dw #0a20
  db 13, #00, #61  ; data/atlantis/block1100-2.tmx + down (94)  left: hole, up: stairs, down: hole, 
  dw #0a20
  db 14, #00, #54  ; data/atlantis/block0110-1.tmx + left (95)  left: hole, up: hole, right: hole, 
  dw #0841
  db 14, #00, #64  ; data/atlantis/block0110-2.tmx + left (96)  left: hole, up: stairs, right: hole, 
  dw #0841
  db 14, #00, #54  ; data/atlantis/block1010-1.tmx + up (97)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/atlantis/block1100-1.tmx + right (98)  left: hole, up: hole, right: hole, 
  dw #0840
  db 14, #00, #64  ; data/atlantis/block1100-2.tmx + right (99)  left: hole, up: stairs, right: hole, 
  dw #0840
  db 15, #00, #55  ; data/atlantis/block0011-1.tmx + left + up (100)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/atlantis/block0101-1.tmx + left + right (101)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/atlantis/block0101-2.tmx + left + right (102)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/atlantis/block0110-1.tmx + left + down (103)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/atlantis/block0110-2.tmx + left + down (104)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/atlantis/block1001-1.tmx + up + right (105)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/atlantis/block1010-1.tmx + up + down (106)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/atlantis/block1100-1.tmx + right + down (107)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #65  ; data/atlantis/block1100-2.tmx + right + down (108)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
atlantis_combination_chunk_pool:
  db 0, #00, #00  ; data/atlantis/combination0000-1.tmx (109)  
  dw #0781
  db 1, #00, #01  ; data/atlantis/combination0000-1.tmx + down (110)  down: hole, 
  dw #0381
  db 2, #00, #04  ; data/atlantis/combination0000-1.tmx + right (111)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/atlantis/combination0000-1.tmx + right + down (112)  right: hole, down: hole, 
  dw #0181
  db 4, #00, #10  ; data/atlantis/combination0000-1.tmx + up (113)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/atlantis/combination0100-1.tmx (114)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/atlantis/combination0000-1.tmx + up + down (115)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #21  ; data/atlantis/combination0100-1.tmx + down (116)  up: stairs, down: hole, 
  dw #0281
  db 6, #00, #14  ; data/atlantis/combination0000-1.tmx + up + right (117)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/atlantis/combination0100-1.tmx + right (118)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/atlantis/combination0000-1.tmx + up + right + down (119)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #25  ; data/atlantis/combination0100-1.tmx + right + down (120)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 8, #00, #40  ; data/atlantis/combination0000-1.tmx + left (121)  left: hole, 
  dw #0701
  db 8, #00, #c0  ; data/atlantis/combination1000-1.tmx (122)  left: half-hole, 
  dw #0701
  db 8, #00, #80  ; data/atlantis/combination1000-2.tmx (123)  left: water, 
  dw #0701
  db 9, #00, #41  ; data/atlantis/combination0000-1.tmx + left + down (124)  left: hole, down: hole, 
  dw #0301
  db 9, #00, #c1  ; data/atlantis/combination1000-1.tmx + down (125)  left: half-hole, down: hole, 
  dw #0301
  db 9, #00, #81  ; data/atlantis/combination1000-2.tmx + down (126)  left: water, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/atlantis/combination0000-1.tmx + left + right (127)  left: hole, right: hole, 
  dw #0501
  db 10, #00, #c4  ; data/atlantis/combination1000-1.tmx + right (128)  left: half-hole, right: hole, 
  dw #0501
  db 10, #00, #84  ; data/atlantis/combination1000-2.tmx + right (129)  left: water, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/atlantis/combination0000-1.tmx + left + right + down (130)  left: hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #c5  ; data/atlantis/combination1000-1.tmx + right + down (131)  left: half-hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #85  ; data/atlantis/combination1000-2.tmx + right + down (132)  left: water, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/atlantis/combination0000-1.tmx + left + up (133)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/atlantis/combination0100-1.tmx + left (134)  left: hole, up: stairs, 
  dw #0601
  db 12, #00, #d0  ; data/atlantis/combination1000-1.tmx + up (135)  left: half-hole, up: hole, 
  dw #0601
  db 12, #00, #90  ; data/atlantis/combination1000-2.tmx + up (136)  left: water, up: hole, 
  dw #0601
  db 13, #00, #51  ; data/atlantis/combination0000-1.tmx + left + up + down (137)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #61  ; data/atlantis/combination0100-1.tmx + left + down (138)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 13, #00, #d1  ; data/atlantis/combination1000-1.tmx + up + down (139)  left: half-hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #91  ; data/atlantis/combination1000-2.tmx + up + down (140)  left: water, up: hole, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/atlantis/combination0000-1.tmx + left + up + right (141)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/atlantis/combination0100-1.tmx + left + right (142)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 14, #00, #d4  ; data/atlantis/combination1000-1.tmx + up + right (143)  left: half-hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #94  ; data/atlantis/combination1000-2.tmx + up + right (144)  left: water, up: hole, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/atlantis/combination0000-1.tmx + left + up + right + down (145)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #65  ; data/atlantis/combination0100-1.tmx + left + right + down (146)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
  db 15, #00, #d5  ; data/atlantis/combination1000-1.tmx + up + right + down (147)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #95  ; data/atlantis/combination1000-2.tmx + up + right + down (148)  left: water, up: hole, right: hole, down: hole, 
  dw #0001
