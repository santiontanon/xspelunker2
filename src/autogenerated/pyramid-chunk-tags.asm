; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
pyramid_chunk_flags:
pyramid_standard_chunk_pool:
  db 0, #00, #00  ; data/patterns/room0000-1.tmx (0)
  dw #02ef
  db 0, #00, #00  ; data/patterns/room0000-2.tmx (1)
  dw #006f
  db 1, #00, #01  ; data/patterns/room0001-1.tmx (2)
  dw #03bf
  db 1, #00, #01  ; data/patterns/room0001-2.tmx (3)
  dw #02ab
  db 1, #00, #02  ; data/patterns/room0001-3.tmx (4)
  dw #03bf
  db 2, #00, #00  ; data/patterns/room0010-1.tmx (5)
  dw #04cf
  db 2, #00, #00  ; data/patterns/room0010-2.tmx (6)
  dw #008f
  db 2, #00, #00  ; data/patterns/room0010-3.tmx (7)
  dw #05db
  db 2, #00, #00  ; data/patterns/room0010-4.tmx (8)
  dw #0ddf
  db 3, #00, #01  ; data/patterns/room0011-1.tmx (9)
  dw #008f
  db 3, #00, #01  ; data/patterns/room0011-2.tmx (10)
  dw #019f
  db 3, #00, #02  ; data/patterns/room0011-3.tmx (11)
  dw #091e
  db 3, #00, #02  ; data/patterns/room0011-4.tmx (12)
  dw #099e
  db 4, #00, #10  ; data/patterns/room0100-1.tmx (13)
  dw #06ef
  db 4, #00, #10  ; data/patterns/room0100-2.tmx (14)
  dw #06ef
  db 4, #00, #20  ; data/patterns/room0100-3.tmx (15)
  dw #06af
  db 4, #00, #10  ; data/patterns/room0100-4.tmx (16)
  dw #0287
  db 4, #00, #20  ; data/patterns/room0100-5.tmx (17)
  dw #06c7
  db 4, #00, #10  ; data/patterns/room0100-6.tmx (18)
  dw #02ab
  db 4, #00, #20  ; data/patterns/room0100-7.tmx (19)
  dw #02af
  db 5, #00, #11  ; data/patterns/room0101-1.tmx (20)
  dw #02ab
  db 5, #00, #11  ; data/patterns/room0101-2.tmx (21)
  dw #02af
  db 5, #00, #22  ; data/patterns/room0101-3.tmx (22)
  dw #02af
  db 5, #00, #11  ; data/patterns/room0101-4.tmx (23)
  dw #02ab
  db 5, #00, #11  ; data/patterns/room0101-5.tmx (24)
  dw #0aaf
  db 5, #00, #21  ; data/patterns/room0101-6.tmx (25)
  dw #02a7
  db 5, #00, #12  ; data/patterns/room0101-7.tmx (26)
  dw #0aaf
  db 5, #00, #22  ; data/patterns/room0101-8.tmx (27)
  dw #02af
  db 6, #00, #10  ; data/patterns/room0110-1.tmx (28)
  dw #04cf
  db 6, #00, #10  ; data/patterns/room0110-2.tmx (29)
  dw #0007
  db 6, #00, #20  ; data/patterns/room0110-3.tmx (30)
  dw #00cf
  db 6, #00, #20  ; data/patterns/room0110-4.tmx (31)
  dw #04cf
  db 7, #00, #11  ; data/patterns/room0111-1.tmx (32)
  dw #008f
  db 7, #00, #11  ; data/patterns/room0111-2.tmx (33)
  dw #000f
  db 7, #00, #21  ; data/patterns/room0111-3.tmx (34)
  dw #008f
  db 7, #00, #12  ; data/patterns/room0111-4.tmx (35)
  dw #008f
  db 7, #00, #21  ; data/patterns/room0111-5.tmx (36)
  dw #0007
  db 7, #00, #22  ; data/patterns/room0111-6.tmx (37)
  dw #008f
  db 8, #00, #00  ; data/patterns/room1000-1.tmx (38)
  dw #0667
  db 8, #00, #00  ; data/patterns/room1000-2.tmx (39)
  dw #0207
  db 8, #00, #00  ; data/patterns/room1000-3.tmx (40)
  dw #0207
  db 8, #00, #00  ; data/patterns/room1000-4.tmx (41)
  dw #0027
  db 8, #00, #00  ; data/patterns/room1000-5.tmx (42)
  dw #0577
  db 9, #00, #01  ; data/patterns/room1001-1.tmx (43)
  dw #0227
  db 9, #00, #01  ; data/patterns/room1001-2.tmx (44)
  dw #0137
  db 9, #00, #02  ; data/patterns/room1001-3.tmx (45)
  dw #0137
  db 9, #00, #02  ; data/patterns/room1001-4.tmx (46)
  dw #0b33
  db 10, #00, #00  ; data/patterns/room1010-1.tmx (47)
  dw #0447
  db 10, #00, #00  ; data/patterns/room1010-2.tmx (48)
  dw #0447
  db 10, #00, #00  ; data/patterns/room1010-3.tmx (49)
  dw #0001
  db 10, #00, #00  ; data/patterns/room1010-4.tmx (50)
  dw #0001
  db 10, #00, #00  ; data/patterns/room1010-5.tmx (51)
  dw #0d57
  db 10, #00, #00  ; data/patterns/room1010-6.tmx (52)
  dw #0443
  db 11, #00, #01  ; data/patterns/room1011-1.tmx (53)
  dw #0007
  db 11, #00, #01  ; data/patterns/room1011-2.tmx (54)
  dw #0017
  db 11, #00, #02  ; data/patterns/room1011-3.tmx (55)
  dw #0917
  db 11, #00, #02  ; data/patterns/room1011-4.tmx (56)
  dw #0007
  db 11, #00, #02  ; data/patterns/room1011-5.tmx (57)
  dw #0007
  db 11, #00, #01  ; data/patterns/room1011-6.tmx (58)
  dw #0007
  db 12, #00, #10  ; data/patterns/room1100-1.tmx (59)
  dw #0667
  db 12, #00, #10  ; data/patterns/room1100-2.tmx (60)
  dw #0807
  db 12, #00, #20  ; data/patterns/room1100-3.tmx (61)
  dw #0201
  db 12, #00, #10  ; data/patterns/room1100-4.tmx (62)
  dw #0001
  db 12, #00, #20  ; data/patterns/room1100-5.tmx (63)
  dw #0007
  db 12, #00, #20  ; data/patterns/room1100-6.tmx (64)
  dw #0667
  db 13, #00, #11  ; data/patterns/room1101-1.tmx (65)
  dw #0227
  db 13, #00, #11  ; data/patterns/room1101-2.tmx (66)
  dw #0a27
  db 13, #00, #21  ; data/patterns/room1101-3.tmx (67)
  dw #0227
  db 13, #00, #12  ; data/patterns/room1101-4.tmx (68)
  dw #0a27
  db 13, #00, #22  ; data/patterns/room1101-5.tmx (69)
  dw #0227
  db 14, #00, #10  ; data/patterns/room1110-1.tmx (70)
  dw #0447
  db 14, #00, #10  ; data/patterns/room1110-2.tmx (71)
  dw #0001
  db 14, #00, #20  ; data/patterns/room1110-3.tmx (72)
  dw #0447
  db 14, #00, #20  ; data/patterns/room1110-4.tmx (73)
  dw #0447
  db 15, #00, #11  ; data/patterns/room1111-1.tmx (74)
  dw #0007
  db 15, #00, #11  ; data/patterns/room1111-2.tmx (75)
  dw #0807
  db 15, #00, #21  ; data/patterns/room1111-3.tmx (76)
  dw #0007
  db 15, #00, #12  ; data/patterns/room1111-4.tmx (77)
  dw #0007
  db 15, #00, #22  ; data/patterns/room1111-5.tmx (78)
  dw #0007
pyramid_boss_chunk_pool:
  db 1, #01, #01  ; data/patterns/boss0001-1.tmx (79)
  dw #0000
  db 1, #01, #02  ; data/patterns/boss0001-2.tmx (80)
  dw #0000
  db 2, #01, #00  ; data/patterns/boss0010-1.tmx (81)
  dw #0000
  db 3, #01, #01  ; data/patterns/boss0011-1.tmx (82)
  dw #0000
  db 4, #01, #10  ; data/patterns/boss0100-1.tmx (83)
  dw #0000
  db 4, #01, #20  ; data/patterns/boss0100-2.tmx (84)
  dw #0000
  db 5, #01, #11  ; data/patterns/boss0101-1.tmx (85)
  dw #0000
  db 5, #01, #21  ; data/patterns/boss0101-2.tmx (86)
  dw #0000
  db 5, #01, #12  ; data/patterns/boss0101-3.tmx (87)
  dw #0000
  db 5, #01, #22  ; data/patterns/boss0101-4.tmx (88)
  dw #0000
  db 6, #01, #10  ; data/patterns/boss0110-1.tmx (89)
  dw #0000
  db 6, #01, #20  ; data/patterns/boss0110-2.tmx (90)
  dw #0000
  db 7, #01, #11  ; data/patterns/boss0111-1.tmx (91)
  dw #0000
  db 7, #01, #21  ; data/patterns/boss0111-2.tmx (92)
  dw #0000
  db 7, #01, #12  ; data/patterns/boss0111-3.tmx (93)
  dw #0000
  db 8, #01, #00  ; data/patterns/boss1000-1.tmx (94)
  dw #0000
  db 9, #01, #01  ; data/patterns/boss1001-1.tmx (95)
  dw #0000
  db 9, #01, #02  ; data/patterns/boss1001-2.tmx (96)
  dw #0000
  db 10, #01, #00  ; data/patterns/boss1010-1.tmx (97)
  dw #0000
  db 11, #01, #01  ; data/patterns/boss1011-1.tmx (98)
  dw #0000
  db 12, #01, #10  ; data/patterns/boss1100-1.tmx (99)
  dw #0000
  db 12, #01, #20  ; data/patterns/boss1100-2.tmx (100)
  dw #0000
  db 13, #01, #11  ; data/patterns/boss1101-1.tmx (101)
  dw #0000
  db 13, #01, #21  ; data/patterns/boss1101-2.tmx (102)
  dw #0000
  db 14, #01, #10  ; data/patterns/boss1110-1.tmx (103)
  dw #0000
  db 14, #01, #20  ; data/patterns/boss1110-2.tmx (104)
  dw #0000
  db 15, #01, #11  ; data/patterns/boss1111-1.tmx (105)
  dw #0000
  db 15, #01, #21  ; data/patterns/boss1111-2.tmx (106)
  dw #0000
  db 15, #01, #22  ; data/patterns/boss1111-3.tmx (107)
  dw #0000
  db 15, #01, #12  ; data/patterns/boss1111-4.tmx (108)
  dw #0000
pyramid_block_chunk_pool:
  db 3, #00, #01  ; data/patterns/block0011-1.tmx (109)
  dw #099f
  db 3, #00, #02  ; data/patterns/block0011-2.tmx (110)
  dw #099f
  db 5, #00, #11  ; data/patterns/block0101-1.tmx (111)
  dw #0829
  db 5, #00, #21  ; data/patterns/block0101-2.tmx (112)
  dw #0829
  db 5, #00, #12  ; data/patterns/block0101-3.tmx (113)
  dw #0829
  db 5, #00, #22  ; data/patterns/block0101-4.tmx (114)
  dw #0829
  db 6, #00, #10  ; data/patterns/block0110-1.tmx (115)
  dw #0849
  db 6, #00, #20  ; data/patterns/block0110-2.tmx (116)
  dw #0849
  db 7, #00, #11  ; data/patterns/block0011-1.tmx + up (117)
  dw #088f
  db 7, #00, #12  ; data/patterns/block0011-2.tmx + up (118)
  dw #088f
  db 7, #00, #11  ; data/patterns/block0101-1.tmx + right (119)
  dw #0809
  db 7, #00, #21  ; data/patterns/block0101-2.tmx + right (120)
  dw #0809
  db 7, #00, #12  ; data/patterns/block0101-3.tmx + right (121)
  dw #0809
  db 7, #00, #22  ; data/patterns/block0101-4.tmx + right (122)
  dw #0809
  db 7, #00, #11  ; data/patterns/block0110-1.tmx + down (123)
  dw #0809
  db 7, #00, #21  ; data/patterns/block0110-2.tmx + down (124)
  dw #0809
  db 7, #00, #12  ; data/patterns/block0111-1.tmx (125)
  dw #0809
  db 9, #00, #01  ; data/patterns/block1001-1.tmx (126)
  dw #0a31
  db 9, #00, #02  ; data/patterns/block1001-2.tmx (127)
  dw #0a31
  db 10, #00, #00  ; data/patterns/block1010-1.tmx (128)
  dw #0d51
  db 11, #00, #01  ; data/patterns/block0011-1.tmx + left (129)
  dw #0917
  db 11, #00, #02  ; data/patterns/block0011-2.tmx + left (130)
  dw #0917
  db 11, #00, #01  ; data/patterns/block1001-1.tmx + right (131)
  dw #0811
  db 11, #00, #02  ; data/patterns/block1001-2.tmx + right (132)
  dw #0811
  db 11, #00, #01  ; data/patterns/block1010-1.tmx + down (133)
  dw #0911
  db 12, #00, #10  ; data/patterns/block1100-1.tmx (134)
  dw #0a60
  db 12, #00, #20  ; data/patterns/block1100-2.tmx (135)
  dw #0a60
  db 13, #00, #11  ; data/patterns/block0101-1.tmx + left (136)
  dw #0821
  db 13, #00, #21  ; data/patterns/block0101-2.tmx + left (137)
  dw #0821
  db 13, #00, #12  ; data/patterns/block0101-3.tmx + left (138)
  dw #0821
  db 13, #00, #22  ; data/patterns/block0101-4.tmx + left (139)
  dw #0821
  db 13, #00, #11  ; data/patterns/block1001-1.tmx + up (140)
  dw #0a21
  db 13, #00, #12  ; data/patterns/block1001-2.tmx + up (141)
  dw #0a21
  db 13, #00, #11  ; data/patterns/block1100-1.tmx + down (142)
  dw #0a20
  db 13, #00, #21  ; data/patterns/block1100-2.tmx + down (143)
  dw #0a20
  db 14, #00, #10  ; data/patterns/block0110-1.tmx + left (144)
  dw #0841
  db 14, #00, #20  ; data/patterns/block0110-2.tmx + left (145)
  dw #0841
  db 14, #00, #10  ; data/patterns/block1010-1.tmx + up (146)
  dw #0c41
  db 14, #00, #10  ; data/patterns/block1100-1.tmx + right (147)
  dw #0840
  db 14, #00, #20  ; data/patterns/block1100-2.tmx + right (148)
  dw #0840
  db 15, #00, #11  ; data/patterns/block0011-1.tmx + left + up (149)
  dw #0807
  db 15, #00, #12  ; data/patterns/block0011-2.tmx + left + up (150)
  dw #0807
  db 15, #00, #11  ; data/patterns/block0101-1.tmx + left + right (151)
  dw #0801
  db 15, #00, #21  ; data/patterns/block0101-2.tmx + left + right (152)
  dw #0801
  db 15, #00, #12  ; data/patterns/block0101-3.tmx + left + right (153)
  dw #0801
  db 15, #00, #22  ; data/patterns/block0101-4.tmx + left + right (154)
  dw #0801
  db 15, #00, #11  ; data/patterns/block0110-1.tmx + left + down (155)
  dw #0801
  db 15, #00, #21  ; data/patterns/block0110-2.tmx + left + down (156)
  dw #0801
  db 15, #00, #12  ; data/patterns/block0111-1.tmx + left (157)
  dw #0801
  db 15, #00, #11  ; data/patterns/block1001-1.tmx + up + right (158)
  dw #0801
  db 15, #00, #12  ; data/patterns/block1001-2.tmx + up + right (159)
  dw #0801
  db 15, #00, #11  ; data/patterns/block1010-1.tmx + up + down (160)
  dw #0801
  db 15, #00, #11  ; data/patterns/block1100-1.tmx + right + down (161)
  dw #0800
  db 15, #00, #21  ; data/patterns/block1100-2.tmx + right + down (162)
  dw #0800
pyramid_combination_chunk_pool:
  db 0, #00, #00  ; data/patterns/combination0000-1.tmx (163)
  dw #07f9
  db 1, #00, #01  ; data/patterns/combination0000-1.tmx + down (164)
  dw #03b9
  db 1, #00, #02  ; data/patterns/combination0001-1.tmx (165)
  dw #03b9
  db 2, #00, #00  ; data/patterns/combination0000-1.tmx + right (166)
  dw #05d9
  db 3, #00, #01  ; data/patterns/combination0000-1.tmx + right + down (167)
  dw #0199
  db 3, #00, #02  ; data/patterns/combination0001-1.tmx + right (168)
  dw #0199
  db 4, #00, #10  ; data/patterns/combination0000-1.tmx + up (169)
  dw #06e9
  db 4, #00, #20  ; data/patterns/combination0100-1.tmx (170)
  dw #06e9
  db 5, #00, #11  ; data/patterns/combination0000-1.tmx + up + down (171)
  dw #02a9
  db 5, #00, #12  ; data/patterns/combination0001-1.tmx + up (172)
  dw #02a9
  db 5, #00, #21  ; data/patterns/combination0100-1.tmx + down (173)
  dw #02a9
  db 5, #00, #22  ; data/patterns/combination0101-1.tmx (174)
  dw #02a9
  db 6, #00, #10  ; data/patterns/combination0000-1.tmx + up + right (175)
  dw #04c9
  db 6, #00, #20  ; data/patterns/combination0100-1.tmx + right (176)
  dw #04c9
  db 7, #00, #11  ; data/patterns/combination0000-1.tmx + up + right + down (177)
  dw #0089
  db 7, #00, #12  ; data/patterns/combination0001-1.tmx + up + right (178)
  dw #0089
  db 7, #00, #21  ; data/patterns/combination0100-1.tmx + right + down (179)
  dw #0089
  db 7, #00, #22  ; data/patterns/combination0101-1.tmx + right (180)
  dw #0089
  db 8, #00, #00  ; data/patterns/combination0000-1.tmx + left (181)
  dw #0771
  db 9, #00, #01  ; data/patterns/combination0000-1.tmx + left + down (182)
  dw #0331
  db 9, #00, #02  ; data/patterns/combination0001-1.tmx + left (183)
  dw #0331
  db 10, #00, #00  ; data/patterns/combination0000-1.tmx + left + right (184)
  dw #0551
  db 11, #00, #01  ; data/patterns/combination0000-1.tmx + left + right + down (185)
  dw #0111
  db 11, #00, #02  ; data/patterns/combination0001-1.tmx + left + right (186)
  dw #0111
  db 12, #00, #10  ; data/patterns/combination0000-1.tmx + left + up (187)
  dw #0661
  db 12, #00, #20  ; data/patterns/combination0100-1.tmx + left (188)
  dw #0661
  db 13, #00, #11  ; data/patterns/combination0000-1.tmx + left + up + down (189)
  dw #0221
  db 13, #00, #12  ; data/patterns/combination0001-1.tmx + left + up (190)
  dw #0221
  db 13, #00, #21  ; data/patterns/combination0100-1.tmx + left + down (191)
  dw #0221
  db 13, #00, #22  ; data/patterns/combination0101-1.tmx + left (192)
  dw #0221
  db 14, #00, #10  ; data/patterns/combination0000-1.tmx + left + up + right (193)
  dw #0441
  db 14, #00, #20  ; data/patterns/combination0100-1.tmx + left + right (194)
  dw #0441
  db 15, #00, #11  ; data/patterns/combination0000-1.tmx + left + up + right + down (195)
  dw #0001
  db 15, #00, #12  ; data/patterns/combination0001-1.tmx + left + up + right (196)
  dw #0001
  db 15, #00, #21  ; data/patterns/combination0100-1.tmx + left + right + down (197)
  dw #0001
  db 15, #00, #22  ; data/patterns/combination0101-1.tmx + left + right (198)
  dw #0001
