; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
xibalba_chunk_flags:
xibalba_standard_chunk_pool:
  db 0, #00, #00  ; data/xibalba/room0000-1.tmx (0)  
  dw #02ef
  db 1, #00, #01  ; data/xibalba/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 2, #00, #04  ; data/xibalba/room0010-1.tmx (2)  right: hole, 
  dw #05df
  db 2, #00, #0c  ; data/xibalba/room0010-2.tmx (3)  right: half-hole, 
  dw #04cf
  db 2, #00, #08  ; data/xibalba/room0010-3.tmx (4)  right: lava, 
  dw #14cf
  db 3, #00, #05  ; data/xibalba/room0011-1.tmx (5)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #0d  ; data/xibalba/room0011-2.tmx (6)  right: half-hole, down: hole, 
  dw #008f
  db 3, #00, #05  ; data/xibalba/room0011-3.tmx (7)  right: hole, down: hole, 
  dw #088f
  db 3, #00, #05  ; data/xibalba/room0011-4.tmx (8)  right: hole, down: hole, 
  dw #099f
  db 4, #00, #10  ; data/xibalba/room0100-1.tmx (9)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/xibalba/room0100-2.tmx (10)  up: stairs, 
  dw #06ef
  db 4, #00, #10  ; data/xibalba/room0100-3.tmx (11)  up: hole, 
  dw #0001
  db 4, #00, #10  ; data/xibalba/room0100-4.tmx (12)  up: hole, 
  dw #0007
  db 4, #00, #10  ; data/xibalba/room0100-5.tmx (13)  up: hole, 
  dw #06ef
  db 5, #00, #11  ; data/xibalba/room0101-1.tmx (14)  up: hole, down: hole, 
  dw #0aaf
  db 5, #00, #21  ; data/xibalba/room0101-2.tmx (15)  up: stairs, down: hole, 
  dw #02af
  db 5, #00, #11  ; data/xibalba/room0101-3.tmx (16)  up: hole, down: hole, 
  dw #0003
  db 5, #00, #11  ; data/xibalba/room0101-4.tmx (17)  up: hole, down: hole, 
  dw #02a9
  db 6, #00, #14  ; data/xibalba/room0110-1.tmx (18)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #1c  ; data/xibalba/room0110-2.tmx (19)  up: hole, right: half-hole, 
  dw #0007
  db 6, #00, #24  ; data/xibalba/room0110-3.tmx (20)  up: stairs, right: hole, 
  dw #008f
  db 6, #00, #18  ; data/xibalba/room0110-4.tmx (21)  up: hole, right: lava, 
  dw #108f
  db 7, #00, #15  ; data/xibalba/room0111-1.tmx (22)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #1d  ; data/xibalba/room0111-2.tmx (23)  up: hole, right: half-hole, down: hole, 
  dw #008f
  db 7, #00, #25  ; data/xibalba/room0111-3.tmx (24)  up: stairs, right: hole, down: hole, 
  dw #008f
  db 7, #00, #15  ; data/xibalba/room0111-4.tmx (25)  up: hole, right: hole, down: hole, 
  dw #008f
  db 8, #00, #40  ; data/xibalba/room1000-1.tmx (26)  left: hole, 
  dw #0667
  db 8, #00, #c0  ; data/xibalba/room1000-2.tmx (27)  left: half-hole, 
  dw #1667
  db 8, #00, #c0  ; data/xibalba/room1000-3.tmx (28)  left: half-hole, 
  dw #1777
  db 8, #00, #40  ; data/xibalba/room1000-4.tmx (29)  left: hole, 
  dw #0777
  db 8, #00, #80  ; data/xibalba/room1000-5.tmx (30)  left: lava, 
  dw #1667
  db 9, #00, #41  ; data/xibalba/room1001-1.tmx (31)  left: hole, down: hole, 
  dw #0227
  db 9, #00, #c1  ; data/xibalba/room1001-2.tmx (32)  left: half-hole, down: hole, 
  dw #0333
  db 9, #00, #81  ; data/xibalba/room1001-3.tmx (33)  left: lava, down: hole, 
  dw #0227
  db 9, #00, #41  ; data/xibalba/room1001-4.tmx (34)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #c1  ; data/xibalba/room1001-5.tmx (35)  left: half-hole, down: hole, 
  dw #0337
  db 10, #00, #44  ; data/xibalba/room1010-1.tmx (36)  left: hole, right: hole, 
  dw #0557
  db 10, #00, #4c  ; data/xibalba/room1010-2.tmx (37)  left: hole, right: half-hole, 
  dw #0447
  db 10, #00, #cc  ; data/xibalba/room1010-3.tmx (38)  left: half-hole, right: half-hole, 
  dw #0117
  db 10, #00, #c4  ; data/xibalba/room1010-4.tmx (39)  left: half-hole, right: hole, 
  dw #1447
  db 10, #00, #48  ; data/xibalba/room1010-5.tmx (40)  left: hole, right: lava, 
  dw #1447
  db 10, #00, #84  ; data/xibalba/room1010-6.tmx (41)  left: lava, right: hole, 
  dw #0557
  db 10, #00, #88  ; data/xibalba/room1010-7.tmx (42)  left: lava, right: lava, 
  dw #1007
  db 10, #00, #88  ; data/xibalba/room1010-8.tmx (43)  left: lava, right: lava, 
  dw #0447
  db 11, #00, #45  ; data/xibalba/room1011-1.tmx (44)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #4d  ; data/xibalba/room1011-2.tmx (45)  left: hole, right: half-hole, down: hole, 
  dw #0117
  db 11, #00, #c5  ; data/xibalba/room1011-3.tmx (46)  left: half-hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #85  ; data/xibalba/room1011-4.tmx (47)  left: lava, right: hole, down: hole, 
  dw #0117
  db 12, #00, #50  ; data/xibalba/room1100-1.tmx (48)  left: hole, up: hole, 
  dw #0667
  db 12, #00, #d0  ; data/xibalba/room1100-2.tmx (49)  left: half-hole, up: hole, 
  dw #1221
  db 12, #00, #60  ; data/xibalba/room1100-3.tmx (50)  left: hole, up: stairs, 
  dw #0667
  db 12, #00, #e0  ; data/xibalba/room1100-4.tmx (51)  left: half-hole, up: stairs, 
  dw #1223
  db 12, #00, #d0  ; data/xibalba/room1100-5.tmx (52)  left: half-hole, up: hole, 
  dw #0667
  db 12, #00, #90  ; data/xibalba/room1100-6.tmx (53)  left: lava, up: hole, 
  dw #1667
  db 12, #00, #a0  ; data/xibalba/room1100-7.tmx (54)  left: lava, up: stairs, 
  dw #1667
  db 13, #00, #51  ; data/xibalba/room1101-1.tmx (55)  left: hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #d1  ; data/xibalba/room1101-2.tmx (56)  left: half-hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #61  ; data/xibalba/room1101-3.tmx (57)  left: hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #e1  ; data/xibalba/room1101-4.tmx (58)  left: half-hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #91  ; data/xibalba/room1101-5.tmx (59)  left: lava, up: hole, down: hole, 
  dw #1227
  db 13, #00, #a1  ; data/xibalba/room1101-6.tmx (60)  left: lava, up: stairs, down: hole, 
  dw #1227
  db 14, #00, #54  ; data/xibalba/room1110-1.tmx (61)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #5c  ; data/xibalba/room1110-2.tmx (62)  left: hole, up: hole, right: half-hole, 
  dw #0447
  db 14, #00, #d4  ; data/xibalba/room1110-3.tmx (63)  left: half-hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #64  ; data/xibalba/room1110-4.tmx (64)  left: hole, up: stairs, right: hole, 
  dw #0007
  db 14, #00, #e4  ; data/xibalba/room1110-5.tmx (65)  left: half-hole, up: stairs, right: hole, 
  dw #0007
  db 14, #00, #58  ; data/xibalba/room1110-6.tmx (66)  left: hole, up: hole, right: lava, 
  dw #1447
  db 14, #00, #98  ; data/xibalba/room1110-7.tmx (67)  left: lava, up: hole, right: lava, 
  dw #1001
  db 14, #00, #94  ; data/xibalba/room1110-8.tmx (68)  left: lava, up: hole, right: hole, 
  dw #1447
  db 14, #00, #a4  ; data/xibalba/room1110-9.tmx (69)  left: lava, up: stairs, right: hole, 
  dw #1447
  db 15, #00, #55  ; data/xibalba/room1111-1.tmx (70)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #5d  ; data/xibalba/room1111-2.tmx (71)  left: hole, up: hole, right: half-hole, down: hole, 
  dw #0007
  db 15, #00, #d5  ; data/xibalba/room1111-3.tmx (72)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #65  ; data/xibalba/room1111-4.tmx (73)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #e5  ; data/xibalba/room1111-5.tmx (74)  left: half-hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #95  ; data/xibalba/room1111-6.tmx (75)  left: lava, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #a5  ; data/xibalba/room1111-7.tmx (76)  left: lava, up: stairs, right: hole, down: hole, 
  dw #0007
xibalba_boss_chunk_pool:
  db 1, #01, #01  ; data/xibalba/boss0001-1.tmx (77)  down: hole, 
  dw #03bf
  db 2, #01, #04  ; data/xibalba/boss0010-1.tmx (78)  right: hole, 
  dw #008d
  db 3, #01, #05  ; data/xibalba/boss0011-1.tmx (79)  right: hole, down: hole, 
  dw #008d
  db 4, #01, #10  ; data/xibalba/boss0100-1.tmx (80)  up: hole, 
  dw #02ad
  db 5, #01, #11  ; data/xibalba/boss0101-1.tmx (81)  up: hole, down: hole, 
  dw #02ad
  db 6, #01, #14  ; data/xibalba/boss0110-1.tmx (82)  up: hole, right: hole, 
  dw #008d
  db 7, #01, #15  ; data/xibalba/boss0111-1.tmx (83)  up: hole, right: hole, down: hole, 
  dw #008d
  db 8, #01, #c0  ; data/xibalba/boss1000-1.tmx (84)  left: half-hole, 
  dw #0005
  db 8, #01, #40  ; data/xibalba/boss1000-2.tmx (85)  left: hole, 
  dw #0005
  db 8, #01, #80  ; data/xibalba/boss1000-3.tmx (86)  left: lava, 
  dw #0005
  db 9, #01, #41  ; data/xibalba/boss1001-1.tmx (87)  left: hole, down: hole, 
  dw #0225
  db 9, #01, #c1  ; data/xibalba/boss1001-2.tmx (88)  left: half-hole, down: hole, 
  dw #0225
  db 10, #01, #44  ; data/xibalba/boss1010-1.tmx (89)  left: hole, right: hole, 
  dw #0005
  db 10, #01, #c4  ; data/xibalba/boss1010-2.tmx (90)  left: half-hole, right: hole, 
  dw #0005
  db 11, #01, #45  ; data/xibalba/boss1011-1.tmx (91)  left: hole, right: hole, down: hole, 
  dw #0005
  db 12, #01, #50  ; data/xibalba/boss1100-1.tmx (92)  left: hole, up: hole, 
  dw #0225
  db 12, #01, #d0  ; data/xibalba/boss1100-2.tmx (93)  left: half-hole, up: hole, 
  dw #0225
  db 12, #01, #90  ; data/xibalba/boss1100-3.tmx (94)  left: lava, up: hole, 
  dw #0225
  db 13, #01, #51  ; data/xibalba/boss1101-1.tmx (95)  left: hole, up: hole, down: hole, 
  dw #0225
  db 14, #01, #54  ; data/xibalba/boss1110-1.tmx (96)  left: hole, up: hole, right: hole, 
  dw #0005
  db 15, #01, #55  ; data/xibalba/boss1111-1.tmx (97)  left: hole, up: hole, right: hole, down: hole, 
  dw #0005
xibalba_block_chunk_pool:
  db 3, #00, #05  ; data/xibalba/block0011-1.tmx (98)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #05  ; data/xibalba/block0011-2.tmx (99)  right: hole, down: hole, 
  dw #099f
  db 5, #00, #11  ; data/xibalba/block0101-1.tmx (100)  up: hole, down: hole, 
  dw #0aa9
  db 5, #00, #21  ; data/xibalba/block0101-2.tmx (101)  up: stairs, down: hole, 
  dw #0aa9
  db 5, #00, #12  ; data/xibalba/block0101-3.tmx (102)  up: hole, down: stairs, 
  dw #0aa9
  db 5, #00, #22  ; data/xibalba/block0101-4.tmx (103)  up: stairs, down: stairs, 
  dw #0aa9
  db 6, #00, #14  ; data/xibalba/block0110-1.tmx (104)  up: hole, right: hole, 
  dw #0889
  db 7, #00, #15  ; data/xibalba/block0011-1.tmx + up (105)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/xibalba/block0011-2.tmx + up (106)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/xibalba/block0101-1.tmx + right (107)  up: hole, right: hole, down: hole, 
  dw #0889
  db 7, #00, #25  ; data/xibalba/block0101-2.tmx + right (108)  up: stairs, right: hole, down: hole, 
  dw #0889
  db 7, #00, #16  ; data/xibalba/block0101-3.tmx + right (109)  up: hole, right: hole, down: stairs, 
  dw #0889
  db 7, #00, #26  ; data/xibalba/block0101-4.tmx + right (110)  up: stairs, right: hole, down: stairs, 
  dw #0889
  db 9, #00, #41  ; data/xibalba/block1001-1.tmx (111)  left: hole, down: hole, 
  dw #0a21
  db 9, #00, #c1  ; data/xibalba/block1001-2.tmx (112)  left: half-hole, down: hole, 
  dw #0a21
  db 10, #00, #44  ; data/xibalba/block1010-1.tmx (113)  left: hole, right: hole, 
  dw #0d51
  db 10, #00, #c4  ; data/xibalba/block1010-2.tmx (114)  left: half-hole, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/xibalba/block0011-1.tmx + left (115)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/xibalba/block0011-2.tmx + left (116)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/xibalba/block1001-1.tmx + right (117)  left: hole, right: hole, down: hole, 
  dw #0801
  db 11, #00, #c5  ; data/xibalba/block1001-2.tmx + right (118)  left: half-hole, right: hole, down: hole, 
  dw #0801
  db 11, #00, #45  ; data/xibalba/block1010-1.tmx + down (119)  left: hole, right: hole, down: hole, 
  dw #0911
  db 11, #00, #c5  ; data/xibalba/block1010-2.tmx + down (120)  left: half-hole, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/xibalba/block1100-1.tmx (121)  left: hole, up: hole, 
  dw #0a20
  db 12, #00, #d0  ; data/xibalba/block1100-2.tmx (122)  left: half-hole, up: hole, 
  dw #0a20
  db 12, #00, #e0  ; data/xibalba/block1100-3.tmx (123)  left: half-hole, up: stairs, 
  dw #0a20
  db 12, #00, #60  ; data/xibalba/block1100-4.tmx (124)  left: hole, up: stairs, 
  dw #0a20
  db 12, #00, #a0  ; data/xibalba/block1100-5.tmx (125)  left: lava, up: stairs, 
  dw #0a20
  db 12, #00, #90  ; data/xibalba/block1100-6.tmx (126)  left: lava, up: hole, 
  dw #0a20
  db 13, #00, #51  ; data/xibalba/block0101-1.tmx + left (127)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #61  ; data/xibalba/block0101-2.tmx + left (128)  left: hole, up: stairs, down: hole, 
  dw #0a21
  db 13, #00, #52  ; data/xibalba/block0101-3.tmx + left (129)  left: hole, up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #62  ; data/xibalba/block0101-4.tmx + left (130)  left: hole, up: stairs, down: stairs, 
  dw #0a21
  db 14, #00, #54  ; data/xibalba/block0110-1.tmx + left (131)  left: hole, up: hole, right: hole, 
  dw #0801
  db 14, #00, #54  ; data/xibalba/block1010-1.tmx + up (132)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #d4  ; data/xibalba/block1010-2.tmx + up (133)  left: half-hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/xibalba/block1100-1.tmx + right (134)  left: hole, up: hole, right: hole, 
  dw #0800
  db 14, #00, #d4  ; data/xibalba/block1100-2.tmx + right (135)  left: half-hole, up: hole, right: hole, 
  dw #0800
  db 14, #00, #e4  ; data/xibalba/block1100-3.tmx + right (136)  left: half-hole, up: stairs, right: hole, 
  dw #0800
  db 14, #00, #64  ; data/xibalba/block1100-4.tmx + right (137)  left: hole, up: stairs, right: hole, 
  dw #0800
  db 14, #00, #a4  ; data/xibalba/block1100-5.tmx + right (138)  left: lava, up: stairs, right: hole, 
  dw #0800
  db 14, #00, #94  ; data/xibalba/block1100-6.tmx + right (139)  left: lava, up: hole, right: hole, 
  dw #0800
  db 15, #00, #55  ; data/xibalba/block0011-1.tmx + left + up (140)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/xibalba/block0011-2.tmx + left + up (141)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/xibalba/block0101-1.tmx + left + right (142)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/xibalba/block0101-2.tmx + left + right (143)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/xibalba/block0101-3.tmx + left + right (144)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #66  ; data/xibalba/block0101-4.tmx + left + right (145)  left: hole, up: stairs, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #55  ; data/xibalba/block1010-1.tmx + up + down (146)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #d5  ; data/xibalba/block1010-2.tmx + up + down (147)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0801
xibalba_combination_chunk_pool:
  db 0, #00, #00  ; data/xibalba/combination0000-1.tmx (148)  
  dw #0781
  db 1, #00, #01  ; data/xibalba/combination0000-1.tmx + down (149)  down: hole, 
  dw #0381
  db 1, #00, #02  ; data/xibalba/combination0001-1.tmx (150)  down: stairs, 
  dw #0381
  db 2, #00, #04  ; data/xibalba/combination0000-1.tmx + right (151)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/xibalba/combination0000-1.tmx + right + down (152)  right: hole, down: hole, 
  dw #0181
  db 3, #00, #06  ; data/xibalba/combination0001-1.tmx + right (153)  right: hole, down: stairs, 
  dw #0181
  db 4, #00, #10  ; data/xibalba/combination0000-1.tmx + up (154)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/xibalba/combination0100-1.tmx (155)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/xibalba/combination0000-1.tmx + up + down (156)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #12  ; data/xibalba/combination0001-1.tmx + up (157)  up: hole, down: stairs, 
  dw #0281
  db 5, #00, #21  ; data/xibalba/combination0100-1.tmx + down (158)  up: stairs, down: hole, 
  dw #0281
  db 5, #00, #22  ; data/xibalba/combination0101-1.tmx (159)  up: stairs, down: stairs, 
  dw #0281
  db 6, #00, #14  ; data/xibalba/combination0000-1.tmx + up + right (160)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/xibalba/combination0100-1.tmx + right (161)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/xibalba/combination0000-1.tmx + up + right + down (162)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #16  ; data/xibalba/combination0001-1.tmx + up + right (163)  up: hole, right: hole, down: stairs, 
  dw #0081
  db 7, #00, #25  ; data/xibalba/combination0100-1.tmx + right + down (164)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 7, #00, #26  ; data/xibalba/combination0101-1.tmx + right (165)  up: stairs, right: hole, down: stairs, 
  dw #0081
  db 8, #00, #40  ; data/xibalba/combination0000-1.tmx + left (166)  left: hole, 
  dw #0701
  db 8, #00, #c0  ; data/xibalba/combination1000-1.tmx (167)  left: half-hole, 
  dw #0701
  db 8, #00, #80  ; data/xibalba/combination1000-2.tmx (168)  left: lava, 
  dw #0701
  db 9, #00, #41  ; data/xibalba/combination0000-1.tmx + left + down (169)  left: hole, down: hole, 
  dw #0301
  db 9, #00, #42  ; data/xibalba/combination0001-1.tmx + left (170)  left: hole, down: stairs, 
  dw #0301
  db 9, #00, #c1  ; data/xibalba/combination1000-1.tmx + down (171)  left: half-hole, down: hole, 
  dw #0301
  db 9, #00, #81  ; data/xibalba/combination1000-2.tmx + down (172)  left: lava, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/xibalba/combination0000-1.tmx + left + right (173)  left: hole, right: hole, 
  dw #0501
  db 10, #00, #c4  ; data/xibalba/combination1000-1.tmx + right (174)  left: half-hole, right: hole, 
  dw #0501
  db 10, #00, #84  ; data/xibalba/combination1000-2.tmx + right (175)  left: lava, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/xibalba/combination0000-1.tmx + left + right + down (176)  left: hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #46  ; data/xibalba/combination0001-1.tmx + left + right (177)  left: hole, right: hole, down: stairs, 
  dw #0101
  db 11, #00, #c5  ; data/xibalba/combination1000-1.tmx + right + down (178)  left: half-hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #85  ; data/xibalba/combination1000-2.tmx + right + down (179)  left: lava, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/xibalba/combination0000-1.tmx + left + up (180)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/xibalba/combination0100-1.tmx + left (181)  left: hole, up: stairs, 
  dw #0601
  db 12, #00, #d0  ; data/xibalba/combination1000-1.tmx + up (182)  left: half-hole, up: hole, 
  dw #0601
  db 12, #00, #90  ; data/xibalba/combination1000-2.tmx + up (183)  left: lava, up: hole, 
  dw #0601
  db 12, #00, #e0  ; data/xibalba/combination1100-1.tmx (184)  left: half-hole, up: stairs, 
  dw #0601
  db 13, #00, #51  ; data/xibalba/combination0000-1.tmx + left + up + down (185)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #52  ; data/xibalba/combination0001-1.tmx + left + up (186)  left: hole, up: hole, down: stairs, 
  dw #0201
  db 13, #00, #61  ; data/xibalba/combination0100-1.tmx + left + down (187)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 13, #00, #62  ; data/xibalba/combination0101-1.tmx + left (188)  left: hole, up: stairs, down: stairs, 
  dw #0201
  db 13, #00, #d1  ; data/xibalba/combination1000-1.tmx + up + down (189)  left: half-hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #91  ; data/xibalba/combination1000-2.tmx + up + down (190)  left: lava, up: hole, down: hole, 
  dw #0201
  db 13, #00, #e1  ; data/xibalba/combination1100-1.tmx + down (191)  left: half-hole, up: stairs, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/xibalba/combination0000-1.tmx + left + up + right (192)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/xibalba/combination0100-1.tmx + left + right (193)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 14, #00, #d4  ; data/xibalba/combination1000-1.tmx + up + right (194)  left: half-hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #94  ; data/xibalba/combination1000-2.tmx + up + right (195)  left: lava, up: hole, right: hole, 
  dw #0401
  db 14, #00, #e4  ; data/xibalba/combination1100-1.tmx + right (196)  left: half-hole, up: stairs, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/xibalba/combination0000-1.tmx + left + up + right + down (197)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #56  ; data/xibalba/combination0001-1.tmx + left + up + right (198)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0001
  db 15, #00, #65  ; data/xibalba/combination0100-1.tmx + left + right + down (199)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
  db 15, #00, #66  ; data/xibalba/combination0101-1.tmx + left + right (200)  left: hole, up: stairs, right: hole, down: stairs, 
  dw #0001
  db 15, #00, #d5  ; data/xibalba/combination1000-1.tmx + up + right + down (201)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #95  ; data/xibalba/combination1000-2.tmx + up + right + down (202)  left: lava, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #e5  ; data/xibalba/combination1100-1.tmx + right + down (203)  left: half-hole, up: stairs, right: hole, down: hole, 
  dw #0001
