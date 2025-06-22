; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
pyramid_chunk_flags:
pyramid_standard_chunk_pool:
  db 0, #00, #00  ; data/pyramid/room0000-1.tmx (0)  
  dw #02ef
  db 0, #00, #00  ; data/pyramid/room0000-2.tmx (1)  
  dw #006f
  db 1, #00, #01  ; data/pyramid/room0001-1.tmx (2)  down: hole, 
  dw #03bf
  db 1, #00, #01  ; data/pyramid/room0001-2.tmx (3)  down: hole, 
  dw #02ab
  db 1, #00, #02  ; data/pyramid/room0001-3.tmx (4)  down: stairs, 
  dw #03bf
  db 2, #00, #00  ; data/pyramid/room0010-1.tmx (5)  
  dw #04cf
  db 2, #00, #00  ; data/pyramid/room0010-2.tmx (6)  
  dw #008f
  db 2, #00, #00  ; data/pyramid/room0010-3.tmx (7)  
  dw #05db
  db 2, #00, #00  ; data/pyramid/room0010-4.tmx (8)  
  dw #099f
  db 3, #00, #01  ; data/pyramid/room0011-1.tmx (9)  down: hole, 
  dw #008f
  db 3, #00, #01  ; data/pyramid/room0011-2.tmx (10)  down: hole, 
  dw #019f
  db 3, #00, #02  ; data/pyramid/room0011-3.tmx (11)  down: stairs, 
  dw #091f
  db 3, #00, #02  ; data/pyramid/room0011-4.tmx (12)  down: stairs, 
  dw #099f
  db 4, #00, #10  ; data/pyramid/room0100-1.tmx (13)  up: hole, 
  dw #06ef
  db 4, #00, #10  ; data/pyramid/room0100-2.tmx (14)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/pyramid/room0100-3.tmx (15)  up: stairs, 
  dw #06af
  db 4, #00, #10  ; data/pyramid/room0100-4.tmx (16)  up: hole, 
  dw #0287
  db 4, #00, #20  ; data/pyramid/room0100-5.tmx (17)  up: stairs, 
  dw #06c7
  db 4, #00, #10  ; data/pyramid/room0100-6.tmx (18)  up: hole, 
  dw #02ab
  db 4, #00, #20  ; data/pyramid/room0100-7.tmx (19)  up: stairs, 
  dw #02af
  db 5, #00, #11  ; data/pyramid/room0101-1.tmx (20)  up: hole, down: hole, 
  dw #02ab
  db 5, #00, #11  ; data/pyramid/room0101-2.tmx (21)  up: hole, down: hole, 
  dw #02af
  db 5, #00, #22  ; data/pyramid/room0101-3.tmx (22)  up: stairs, down: stairs, 
  dw #02af
  db 5, #00, #11  ; data/pyramid/room0101-4.tmx (23)  up: hole, down: hole, 
  dw #02ab
  db 5, #00, #11  ; data/pyramid/room0101-5.tmx (24)  up: hole, down: hole, 
  dw #0aaf
  db 5, #00, #21  ; data/pyramid/room0101-6.tmx (25)  up: stairs, down: hole, 
  dw #02af
  db 5, #00, #12  ; data/pyramid/room0101-7.tmx (26)  up: hole, down: stairs, 
  dw #0aaf
  db 5, #00, #22  ; data/pyramid/room0101-8.tmx (27)  up: stairs, down: stairs, 
  dw #02af
  db 6, #00, #10  ; data/pyramid/room0110-1.tmx (28)  up: hole, 
  dw #04cf
  db 6, #00, #10  ; data/pyramid/room0110-2.tmx (29)  up: hole, 
  dw #0007
  db 6, #00, #20  ; data/pyramid/room0110-3.tmx (30)  up: stairs, 
  dw #00cf
  db 6, #00, #20  ; data/pyramid/room0110-4.tmx (31)  up: stairs, 
  dw #04cf
  db 7, #00, #11  ; data/pyramid/room0111-1.tmx (32)  up: hole, down: hole, 
  dw #008f
  db 7, #00, #11  ; data/pyramid/room0111-2.tmx (33)  up: hole, down: hole, 
  dw #000f
  db 7, #00, #21  ; data/pyramid/room0111-3.tmx (34)  up: stairs, down: hole, 
  dw #008f
  db 7, #00, #12  ; data/pyramid/room0111-4.tmx (35)  up: hole, down: stairs, 
  dw #008f
  db 7, #00, #21  ; data/pyramid/room0111-5.tmx (36)  up: stairs, down: hole, 
  dw #0007
  db 7, #00, #22  ; data/pyramid/room0111-6.tmx (37)  up: stairs, down: stairs, 
  dw #008f
  db 8, #00, #00  ; data/pyramid/room1000-1.tmx (38)  
  dw #0667
  db 8, #00, #00  ; data/pyramid/room1000-2.tmx (39)  
  dw #0207
  db 8, #00, #00  ; data/pyramid/room1000-3.tmx (40)  
  dw #0207
  db 8, #00, #00  ; data/pyramid/room1000-4.tmx (41)  
  dw #0027
  db 8, #00, #00  ; data/pyramid/room1000-5.tmx (42)  
  dw #0577
  db 9, #00, #01  ; data/pyramid/room1001-1.tmx (43)  down: hole, 
  dw #0227
  db 9, #00, #01  ; data/pyramid/room1001-2.tmx (44)  down: hole, 
  dw #0137
  db 9, #00, #02  ; data/pyramid/room1001-3.tmx (45)  down: stairs, 
  dw #0137
  db 9, #00, #02  ; data/pyramid/room1001-4.tmx (46)  down: stairs, 
  dw #0b37
  db 10, #00, #00  ; data/pyramid/room1010-1.tmx (47)  
  dw #0447
  db 10, #00, #00  ; data/pyramid/room1010-2.tmx (48)  
  dw #0447
  db 10, #00, #00  ; data/pyramid/room1010-3.tmx (49)  
  dw #0001
  db 10, #00, #00  ; data/pyramid/room1010-4.tmx (50)  
  dw #0001
  db 10, #00, #00  ; data/pyramid/room1010-5.tmx (51)  
  dw #0d57
  db 10, #00, #00  ; data/pyramid/room1010-6.tmx (52)  
  dw #0443
  db 11, #00, #01  ; data/pyramid/room1011-1.tmx (53)  down: hole, 
  dw #0007
  db 11, #00, #01  ; data/pyramid/room1011-2.tmx (54)  down: hole, 
  dw #0017
  db 11, #00, #02  ; data/pyramid/room1011-3.tmx (55)  down: stairs, 
  dw #0917
  db 11, #00, #02  ; data/pyramid/room1011-4.tmx (56)  down: stairs, 
  dw #0007
  db 11, #00, #02  ; data/pyramid/room1011-5.tmx (57)  down: stairs, 
  dw #0007
  db 11, #00, #01  ; data/pyramid/room1011-6.tmx (58)  down: hole, 
  dw #0007
  db 12, #00, #10  ; data/pyramid/room1100-1.tmx (59)  up: hole, 
  dw #0667
  db 12, #00, #10  ; data/pyramid/room1100-2.tmx (60)  up: hole, 
  dw #0807
  db 12, #00, #20  ; data/pyramid/room1100-3.tmx (61)  up: stairs, 
  dw #0201
  db 12, #00, #10  ; data/pyramid/room1100-4.tmx (62)  up: hole, 
  dw #0001
  db 12, #00, #20  ; data/pyramid/room1100-5.tmx (63)  up: stairs, 
  dw #0007
  db 12, #00, #20  ; data/pyramid/room1100-6.tmx (64)  up: stairs, 
  dw #0667
  db 13, #00, #11  ; data/pyramid/room1101-1.tmx (65)  up: hole, down: hole, 
  dw #0227
  db 13, #00, #11  ; data/pyramid/room1101-2.tmx (66)  up: hole, down: hole, 
  dw #0a27
  db 13, #00, #21  ; data/pyramid/room1101-3.tmx (67)  up: stairs, down: hole, 
  dw #0227
  db 13, #00, #12  ; data/pyramid/room1101-4.tmx (68)  up: hole, down: stairs, 
  dw #0a27
  db 13, #00, #22  ; data/pyramid/room1101-5.tmx (69)  up: stairs, down: stairs, 
  dw #0227
  db 14, #00, #10  ; data/pyramid/room1110-1.tmx (70)  up: hole, 
  dw #0447
  db 14, #00, #10  ; data/pyramid/room1110-2.tmx (71)  up: hole, 
  dw #0001
  db 14, #00, #20  ; data/pyramid/room1110-3.tmx (72)  up: stairs, 
  dw #0447
  db 14, #00, #20  ; data/pyramid/room1110-4.tmx (73)  up: stairs, 
  dw #0447
  db 15, #00, #11  ; data/pyramid/room1111-1.tmx (74)  up: hole, down: hole, 
  dw #0007
  db 15, #00, #11  ; data/pyramid/room1111-2.tmx (75)  up: hole, down: hole, 
  dw #0807
  db 15, #00, #21  ; data/pyramid/room1111-3.tmx (76)  up: stairs, down: hole, 
  dw #0007
  db 15, #00, #12  ; data/pyramid/room1111-4.tmx (77)  up: hole, down: stairs, 
  dw #0007
  db 15, #00, #22  ; data/pyramid/room1111-5.tmx (78)  up: stairs, down: stairs, 
  dw #0007
pyramid_boss_chunk_pool:
  db 1, #01, #01  ; data/pyramid/boss0001-1.tmx (79)  down: hole, 
  dw #0005
  db 1, #01, #02  ; data/pyramid/boss0001-2.tmx (80)  down: stairs, 
  dw #0005
  db 2, #01, #00  ; data/pyramid/boss0010-1.tmx (81)  
  dw #0005
  db 3, #01, #01  ; data/pyramid/boss0011-1.tmx (82)  down: hole, 
  dw #0005
  db 3, #01, #02  ; data/pyramid/boss0011-2.tmx (83)  down: stairs, 
  dw #0005
  db 4, #01, #10  ; data/pyramid/boss0100-1.tmx (84)  up: hole, 
  dw #0005
  db 4, #01, #20  ; data/pyramid/boss0100-2.tmx (85)  up: stairs, 
  dw #0005
  db 5, #01, #11  ; data/pyramid/boss0101-1.tmx (86)  up: hole, down: hole, 
  dw #0005
  db 5, #01, #21  ; data/pyramid/boss0101-2.tmx (87)  up: stairs, down: hole, 
  dw #0005
  db 5, #01, #12  ; data/pyramid/boss0101-3.tmx (88)  up: hole, down: stairs, 
  dw #0005
  db 5, #01, #22  ; data/pyramid/boss0101-4.tmx (89)  up: stairs, down: stairs, 
  dw #0005
  db 6, #01, #10  ; data/pyramid/boss0110-1.tmx (90)  up: hole, 
  dw #0005
  db 6, #01, #20  ; data/pyramid/boss0110-2.tmx (91)  up: stairs, 
  dw #0005
  db 7, #01, #11  ; data/pyramid/boss0111-1.tmx (92)  up: hole, down: hole, 
  dw #0005
  db 7, #01, #21  ; data/pyramid/boss0111-2.tmx (93)  up: stairs, down: hole, 
  dw #0005
  db 7, #01, #12  ; data/pyramid/boss0111-3.tmx (94)  up: hole, down: stairs, 
  dw #0005
  db 8, #01, #00  ; data/pyramid/boss1000-1.tmx (95)  
  dw #0005
  db 9, #01, #01  ; data/pyramid/boss1001-1.tmx (96)  down: hole, 
  dw #0005
  db 9, #01, #02  ; data/pyramid/boss1001-2.tmx (97)  down: stairs, 
  dw #0005
  db 10, #01, #00  ; data/pyramid/boss1010-1.tmx (98)  
  dw #0005
  db 11, #01, #01  ; data/pyramid/boss1011-1.tmx (99)  down: hole, 
  dw #0005
  db 12, #01, #10  ; data/pyramid/boss1100-1.tmx (100)  up: hole, 
  dw #0005
  db 12, #01, #20  ; data/pyramid/boss1100-2.tmx (101)  up: stairs, 
  dw #0005
  db 13, #01, #11  ; data/pyramid/boss1101-1.tmx (102)  up: hole, down: hole, 
  dw #0005
  db 13, #01, #21  ; data/pyramid/boss1101-2.tmx (103)  up: stairs, down: hole, 
  dw #0005
  db 13, #01, #12  ; data/pyramid/boss1101-3.tmx (104)  up: hole, down: stairs, 
  dw #0005
  db 14, #01, #10  ; data/pyramid/boss1110-1.tmx (105)  up: hole, 
  dw #0005
  db 14, #01, #20  ; data/pyramid/boss1110-2.tmx (106)  up: stairs, 
  dw #0005
  db 15, #01, #11  ; data/pyramid/boss1111-1.tmx (107)  up: hole, down: hole, 
  dw #0005
  db 15, #01, #21  ; data/pyramid/boss1111-2.tmx (108)  up: stairs, down: hole, 
  dw #0005
  db 15, #01, #22  ; data/pyramid/boss1111-3.tmx (109)  up: stairs, down: stairs, 
  dw #0005
  db 15, #01, #12  ; data/pyramid/boss1111-4.tmx (110)  up: hole, down: stairs, 
  dw #0005
pyramid_block_chunk_pool:
  db 3, #00, #01  ; data/pyramid/block0011-1.tmx (111)  down: hole, 
  dw #099f
  db 3, #00, #02  ; data/pyramid/block0011-2.tmx (112)  down: stairs, 
  dw #099f
  db 5, #00, #11  ; data/pyramid/block0101-1.tmx (113)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/pyramid/block0101-2.tmx (114)  up: stairs, down: hole, 
  dw #0829
  db 5, #00, #12  ; data/pyramid/block0101-3.tmx (115)  up: hole, down: stairs, 
  dw #0829
  db 5, #00, #22  ; data/pyramid/block0101-4.tmx (116)  up: stairs, down: stairs, 
  dw #0829
  db 6, #00, #10  ; data/pyramid/block0110-1.tmx (117)  up: hole, 
  dw #0849
  db 6, #00, #20  ; data/pyramid/block0110-2.tmx (118)  up: stairs, 
  dw #0849
  db 7, #00, #11  ; data/pyramid/block0011-1.tmx + up (119)  up: hole, down: hole, 
  dw #088f
  db 7, #00, #12  ; data/pyramid/block0011-2.tmx + up (120)  up: hole, down: stairs, 
  dw #088f
  db 7, #00, #11  ; data/pyramid/block0101-1.tmx + right (121)  up: hole, down: hole, 
  dw #0809
  db 7, #00, #21  ; data/pyramid/block0101-2.tmx + right (122)  up: stairs, down: hole, 
  dw #0809
  db 7, #00, #12  ; data/pyramid/block0101-3.tmx + right (123)  up: hole, down: stairs, 
  dw #0809
  db 7, #00, #22  ; data/pyramid/block0101-4.tmx + right (124)  up: stairs, down: stairs, 
  dw #0809
  db 7, #00, #11  ; data/pyramid/block0110-1.tmx + down (125)  up: hole, down: hole, 
  dw #0809
  db 7, #00, #21  ; data/pyramid/block0110-2.tmx + down (126)  up: stairs, down: hole, 
  dw #0809
  db 7, #00, #12  ; data/pyramid/block0111-1.tmx (127)  up: hole, down: stairs, 
  dw #0809
  db 9, #00, #01  ; data/pyramid/block1001-1.tmx (128)  down: hole, 
  dw #0a31
  db 9, #00, #02  ; data/pyramid/block1001-2.tmx (129)  down: stairs, 
  dw #0a31
  db 10, #00, #00  ; data/pyramid/block1010-1.tmx (130)  
  dw #0d51
  db 11, #00, #01  ; data/pyramid/block0011-1.tmx + left (131)  down: hole, 
  dw #0917
  db 11, #00, #02  ; data/pyramid/block0011-2.tmx + left (132)  down: stairs, 
  dw #0917
  db 11, #00, #01  ; data/pyramid/block1001-1.tmx + right (133)  down: hole, 
  dw #0811
  db 11, #00, #02  ; data/pyramid/block1001-2.tmx + right (134)  down: stairs, 
  dw #0811
  db 11, #00, #01  ; data/pyramid/block1010-1.tmx + down (135)  down: hole, 
  dw #0911
  db 12, #00, #10  ; data/pyramid/block1100-1.tmx (136)  up: hole, 
  dw #0a60
  db 12, #00, #20  ; data/pyramid/block1100-2.tmx (137)  up: stairs, 
  dw #0a60
  db 13, #00, #11  ; data/pyramid/block0101-1.tmx + left (138)  up: hole, down: hole, 
  dw #0821
  db 13, #00, #21  ; data/pyramid/block0101-2.tmx + left (139)  up: stairs, down: hole, 
  dw #0821
  db 13, #00, #12  ; data/pyramid/block0101-3.tmx + left (140)  up: hole, down: stairs, 
  dw #0821
  db 13, #00, #22  ; data/pyramid/block0101-4.tmx + left (141)  up: stairs, down: stairs, 
  dw #0821
  db 13, #00, #11  ; data/pyramid/block1001-1.tmx + up (142)  up: hole, down: hole, 
  dw #0a21
  db 13, #00, #12  ; data/pyramid/block1001-2.tmx + up (143)  up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #11  ; data/pyramid/block1100-1.tmx + down (144)  up: hole, down: hole, 
  dw #0a20
  db 13, #00, #21  ; data/pyramid/block1100-2.tmx + down (145)  up: stairs, down: hole, 
  dw #0a20
  db 14, #00, #10  ; data/pyramid/block0110-1.tmx + left (146)  up: hole, 
  dw #0841
  db 14, #00, #20  ; data/pyramid/block0110-2.tmx + left (147)  up: stairs, 
  dw #0841
  db 14, #00, #10  ; data/pyramid/block1010-1.tmx + up (148)  up: hole, 
  dw #0c41
  db 14, #00, #10  ; data/pyramid/block1100-1.tmx + right (149)  up: hole, 
  dw #0840
  db 14, #00, #20  ; data/pyramid/block1100-2.tmx + right (150)  up: stairs, 
  dw #0840
  db 15, #00, #11  ; data/pyramid/block0011-1.tmx + left + up (151)  up: hole, down: hole, 
  dw #0807
  db 15, #00, #12  ; data/pyramid/block0011-2.tmx + left + up (152)  up: hole, down: stairs, 
  dw #0807
  db 15, #00, #11  ; data/pyramid/block0101-1.tmx + left + right (153)  up: hole, down: hole, 
  dw #0801
  db 15, #00, #21  ; data/pyramid/block0101-2.tmx + left + right (154)  up: stairs, down: hole, 
  dw #0801
  db 15, #00, #12  ; data/pyramid/block0101-3.tmx + left + right (155)  up: hole, down: stairs, 
  dw #0801
  db 15, #00, #22  ; data/pyramid/block0101-4.tmx + left + right (156)  up: stairs, down: stairs, 
  dw #0801
  db 15, #00, #11  ; data/pyramid/block0110-1.tmx + left + down (157)  up: hole, down: hole, 
  dw #0801
  db 15, #00, #21  ; data/pyramid/block0110-2.tmx + left + down (158)  up: stairs, down: hole, 
  dw #0801
  db 15, #00, #12  ; data/pyramid/block0111-1.tmx + left (159)  up: hole, down: stairs, 
  dw #0801
  db 15, #00, #11  ; data/pyramid/block1001-1.tmx + up + right (160)  up: hole, down: hole, 
  dw #0801
  db 15, #00, #12  ; data/pyramid/block1001-2.tmx + up + right (161)  up: hole, down: stairs, 
  dw #0801
  db 15, #00, #11  ; data/pyramid/block1010-1.tmx + up + down (162)  up: hole, down: hole, 
  dw #0801
  db 15, #00, #11  ; data/pyramid/block1100-1.tmx + right + down (163)  up: hole, down: hole, 
  dw #0800
  db 15, #00, #21  ; data/pyramid/block1100-2.tmx + right + down (164)  up: stairs, down: hole, 
  dw #0800
pyramid_combination_chunk_pool:
  db 0, #00, #00  ; data/pyramid/combination0000-1.tmx (165)  
  dw #0781
  db 1, #00, #01  ; data/pyramid/combination0000-1.tmx + down (166)  down: hole, 
  dw #0381
  db 1, #00, #02  ; data/pyramid/combination0001-1.tmx (167)  down: stairs, 
  dw #0381
  db 2, #00, #00  ; data/pyramid/combination0000-1.tmx + right (168)  
  dw #0581
  db 3, #00, #01  ; data/pyramid/combination0000-1.tmx + right + down (169)  down: hole, 
  dw #0181
  db 3, #00, #02  ; data/pyramid/combination0001-1.tmx + right (170)  down: stairs, 
  dw #0181
  db 4, #00, #10  ; data/pyramid/combination0000-1.tmx + up (171)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/pyramid/combination0100-1.tmx (172)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/pyramid/combination0000-1.tmx + up + down (173)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #12  ; data/pyramid/combination0001-1.tmx + up (174)  up: hole, down: stairs, 
  dw #0281
  db 5, #00, #21  ; data/pyramid/combination0100-1.tmx + down (175)  up: stairs, down: hole, 
  dw #0281
  db 5, #00, #22  ; data/pyramid/combination0101-1.tmx (176)  up: stairs, down: stairs, 
  dw #0281
  db 6, #00, #10  ; data/pyramid/combination0000-1.tmx + up + right (177)  up: hole, 
  dw #0481
  db 6, #00, #20  ; data/pyramid/combination0100-1.tmx + right (178)  up: stairs, 
  dw #0481
  db 7, #00, #11  ; data/pyramid/combination0000-1.tmx + up + right + down (179)  up: hole, down: hole, 
  dw #0081
  db 7, #00, #12  ; data/pyramid/combination0001-1.tmx + up + right (180)  up: hole, down: stairs, 
  dw #0081
  db 7, #00, #21  ; data/pyramid/combination0100-1.tmx + right + down (181)  up: stairs, down: hole, 
  dw #0081
  db 7, #00, #22  ; data/pyramid/combination0101-1.tmx + right (182)  up: stairs, down: stairs, 
  dw #0081
  db 8, #00, #00  ; data/pyramid/combination0000-1.tmx + left (183)  
  dw #0701
  db 9, #00, #01  ; data/pyramid/combination0000-1.tmx + left + down (184)  down: hole, 
  dw #0301
  db 9, #00, #02  ; data/pyramid/combination0001-1.tmx + left (185)  down: stairs, 
  dw #0301
  db 10, #00, #00  ; data/pyramid/combination0000-1.tmx + left + right (186)  
  dw #0501
  db 11, #00, #01  ; data/pyramid/combination0000-1.tmx + left + right + down (187)  down: hole, 
  dw #0101
  db 11, #00, #02  ; data/pyramid/combination0001-1.tmx + left + right (188)  down: stairs, 
  dw #0101
  db 12, #00, #10  ; data/pyramid/combination0000-1.tmx + left + up (189)  up: hole, 
  dw #0601
  db 12, #00, #20  ; data/pyramid/combination0100-1.tmx + left (190)  up: stairs, 
  dw #0601
  db 13, #00, #11  ; data/pyramid/combination0000-1.tmx + left + up + down (191)  up: hole, down: hole, 
  dw #0201
  db 13, #00, #12  ; data/pyramid/combination0001-1.tmx + left + up (192)  up: hole, down: stairs, 
  dw #0201
  db 13, #00, #21  ; data/pyramid/combination0100-1.tmx + left + down (193)  up: stairs, down: hole, 
  dw #0201
  db 13, #00, #22  ; data/pyramid/combination0101-1.tmx + left (194)  up: stairs, down: stairs, 
  dw #0201
  db 14, #00, #10  ; data/pyramid/combination0000-1.tmx + left + up + right (195)  up: hole, 
  dw #0401
  db 14, #00, #20  ; data/pyramid/combination0100-1.tmx + left + right (196)  up: stairs, 
  dw #0401
  db 15, #00, #11  ; data/pyramid/combination0000-1.tmx + left + up + right + down (197)  up: hole, down: hole, 
  dw #0001
  db 15, #00, #12  ; data/pyramid/combination0001-1.tmx + left + up + right (198)  up: hole, down: stairs, 
  dw #0001
  db 15, #00, #21  ; data/pyramid/combination0100-1.tmx + left + right + down (199)  up: stairs, down: hole, 
  dw #0001
  db 15, #00, #22  ; data/pyramid/combination0101-1.tmx + left + right (200)  up: stairs, down: stairs, 
  dw #0001
