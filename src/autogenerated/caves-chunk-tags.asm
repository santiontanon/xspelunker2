; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
caves_chunk_flags:
caves_standard_chunk_pool:
  db 0, #00, #00  ; data/caves/room0000-1.tmx (0)  
  dw #02ef
  db 1, #00, #01  ; data/caves/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 1, #00, #02  ; data/caves/room0001-2.tmx (2)  down: stairs, 
  dw #03bf
  db 2, #00, #04  ; data/caves/room0010-1.tmx (3)  right: hole, 
  dw #04cf
  db 2, #00, #04  ; data/caves/room0010-2.tmx (4)  right: hole, 
  dw #05df
  db 2, #00, #04  ; data/caves/room0010-3.tmx (5)  right: hole, 
  dw #0111
  db 2, #00, #04  ; data/caves/room0010-4.tmx (6)  right: hole, 
  dw #0111
  db 2, #00, #08  ; data/caves/room0010-5.tmx (7)  right: lava, 
  dw #0111
  db 2, #00, #0c  ; data/caves/room0010-6.tmx (8)  right: half-hole, 
  dw #0111
  db 3, #00, #05  ; data/caves/room0011-1.tmx (9)  right: hole, down: hole, 
  dw #008f
  db 3, #00, #05  ; data/caves/room0011-2.tmx (10)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #06  ; data/caves/room0011-3.tmx (11)  right: hole, down: stairs, 
  dw #0999
  db 3, #00, #05  ; data/caves/room0011-4.tmx (12)  right: hole, down: hole, 
  dw #019f
  db 3, #00, #0d  ; data/caves/room0011-5.tmx (13)  right: half-hole, down: hole, 
  dw #008f
  db 3, #00, #0e  ; data/caves/room0011-6.tmx (14)  right: half-hole, down: stairs, 
  dw #008f
  db 4, #00, #10  ; data/caves/room0100-1.tmx (15)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/caves/room0100-2.tmx (16)  up: stairs, 
  dw #06ef
  db 4, #00, #20  ; data/caves/room0100-3.tmx (17)  up: stairs, 
  dw #0001
  db 4, #00, #20  ; data/caves/room0100-4.tmx (18)  up: stairs, 
  dw #0001
  db 4, #00, #10  ; data/caves/room0100-5.tmx (19)  up: hole, 
  dw #06ef
  db 4, #00, #10  ; data/caves/room0100-6.tmx (20)  up: hole, 
  dw #06ef
  db 5, #00, #11  ; data/caves/room0101-1.tmx (21)  up: hole, down: hole, 
  dw #02af
  db 5, #00, #22  ; data/caves/room0101-2.tmx (22)  up: stairs, down: stairs, 
  dw #02af
  db 5, #00, #12  ; data/caves/room0101-3.tmx (23)  up: hole, down: stairs, 
  dw #02af
  db 5, #00, #21  ; data/caves/room0101-4.tmx (24)  up: stairs, down: hole, 
  dw #02a9
  db 6, #00, #14  ; data/caves/room0110-1.tmx (25)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #24  ; data/caves/room0110-2.tmx (26)  up: stairs, right: hole, 
  dw #0087
  db 6, #00, #24  ; data/caves/room0110-3.tmx (27)  up: stairs, right: hole, 
  dw #04cf
  db 6, #00, #28  ; data/caves/room0110-4.tmx (28)  up: stairs, right: lava, 
  dw #0089
  db 6, #00, #24  ; data/caves/room0110-5.tmx (29)  up: stairs, right: hole, 
  dw #0089
  db 6, #00, #14  ; data/caves/room0110-6.tmx (30)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #1c  ; data/caves/room0110-7.tmx (31)  up: hole, right: half-hole, 
  dw #04cf
  db 7, #00, #15  ; data/caves/room0111-1.tmx (32)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #25  ; data/caves/room0111-2.tmx (33)  up: stairs, right: hole, down: hole, 
  dw #008f
  db 7, #00, #16  ; data/caves/room0111-3.tmx (34)  up: hole, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #26  ; data/caves/room0111-4.tmx (35)  up: stairs, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #25  ; data/caves/room0111-5.tmx (36)  up: stairs, right: hole, down: hole, 
  dw #0089
  db 7, #00, #1e  ; data/caves/room0111-6.tmx (37)  up: hole, right: half-hole, down: stairs, 
  dw #008f
  db 8, #00, #40  ; data/caves/room1000-1.tmx (38)  left: hole, 
  dw #0667
  db 8, #00, #40  ; data/caves/room1000-2.tmx (39)  left: hole, 
  dw #0777
  db 8, #00, #40  ; data/caves/room1000-3.tmx (40)  left: hole, 
  dw #0001
  db 8, #00, #40  ; data/caves/room1000-4.tmx (41)  left: hole, 
  dw #0331
  db 8, #00, #80  ; data/caves/room1000-5.tmx (42)  left: lava, 
  dw #0227
  db 8, #00, #80  ; data/caves/room1000-6.tmx (43)  left: lava, 
  dw #0667
  db 8, #00, #c0  ; data/caves/room1000-7.tmx (44)  left: half-hole, 
  dw #0337
  db 8, #00, #c0  ; data/caves/room1000-8.tmx (45)  left: half-hole, 
  dw #0667
  db 9, #00, #41  ; data/caves/room1001-1.tmx (46)  left: hole, down: hole, 
  dw #0227
  db 9, #00, #41  ; data/caves/room1001-2.tmx (47)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/caves/room1001-3.tmx (48)  left: hole, down: stairs, 
  dw #0337
  db 9, #00, #82  ; data/caves/room1001-4.tmx (49)  left: lava, down: stairs, 
  dw #0337
  db 9, #00, #81  ; data/caves/room1001-5.tmx (50)  left: lava, down: hole, 
  dw #0337
  db 9, #00, #c1  ; data/caves/room1001-6.tmx (51)  left: half-hole, down: hole, 
  dw #0337
  db 9, #00, #c2  ; data/caves/room1001-7.tmx (52)  left: half-hole, down: stairs, 
  dw #0337
  db 10, #00, #44  ; data/caves/room1010-1.tmx (53)  left: hole, right: hole, 
  dw #0447
  db 10, #00, #44  ; data/caves/room1010-2.tmx (54)  left: hole, right: hole, 
  dw #0917
  db 10, #00, #44  ; data/caves/room1010-3.tmx (55)  left: hole, right: hole, 
  dw #0001
  db 10, #00, #84  ; data/caves/room1010-4.tmx (56)  left: lava, right: hole, 
  dw #0447
  db 10, #00, #88  ; data/caves/room1010-5.tmx (57)  left: lava, right: lava, 
  dw #0001
  db 10, #00, #cc  ; data/caves/room1010-6.tmx (58)  left: half-hole, right: half-hole, 
  dw #0117
  db 10, #00, #cc  ; data/caves/room1010-7.tmx (59)  left: half-hole, right: half-hole, 
  dw #0447
  db 10, #00, #c4  ; data/caves/room1010-8.tmx (60)  left: half-hole, right: hole, 
  dw #0117
  db 10, #00, #c4  ; data/caves/room1010-9.tmx (61)  left: half-hole, right: hole, 
  dw #0447
  db 11, #00, #45  ; data/caves/room1011-1.tmx (62)  left: hole, right: hole, down: hole, 
  dw #0007
  db 11, #00, #45  ; data/caves/room1011-2.tmx (63)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #85  ; data/caves/room1011-3.tmx (64)  left: lava, right: hole, down: hole, 
  dw #0917
  db 11, #00, #46  ; data/caves/room1011-4.tmx (65)  left: hole, right: hole, down: stairs, 
  dw #0117
  db 11, #00, #c5  ; data/caves/room1011-5.tmx (66)  left: half-hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #c6  ; data/caves/room1011-6.tmx (67)  left: half-hole, right: hole, down: stairs, 
  dw #0917
  db 11, #00, #86  ; data/caves/room1011-7.tmx (68)  left: lava, right: hole, down: stairs, 
  dw #0917
  db 12, #00, #50  ; data/caves/room1100-1.tmx (69)  left: hole, up: hole, 
  dw #0667
  db 12, #00, #60  ; data/caves/room1100-2.tmx (70)  left: hole, up: stairs, 
  dw #0667
  db 12, #00, #a0  ; data/caves/room1100-3.tmx (71)  left: lava, up: stairs, 
  dw #0227
  db 12, #00, #90  ; data/caves/room1100-4.tmx (72)  left: lava, up: hole, 
  dw #0227
  db 12, #00, #50  ; data/caves/room1100-5.tmx (73)  left: hole, up: hole, 
  dw #0221
  db 12, #00, #e0  ; data/caves/room1100-6.tmx (74)  left: half-hole, up: stairs, 
  dw #0667
  db 12, #00, #d0  ; data/caves/room1100-7.tmx (75)  left: half-hole, up: hole, 
  dw #0667
  db 12, #00, #90  ; data/caves/room1100-8.tmx (76)  left: lava, up: hole, 
  dw #0667
  db 12, #00, #a0  ; data/caves/room1100-9.tmx (77)  left: lava, up: stairs, 
  dw #0667
  db 13, #00, #51  ; data/caves/room1101-1.tmx (78)  left: hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #52  ; data/caves/room1101-2.tmx (79)  left: hole, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #61  ; data/caves/room1101-3.tmx (80)  left: hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #62  ; data/caves/room1101-4.tmx (81)  left: hole, up: stairs, down: stairs, 
  dw #0227
  db 13, #00, #a2  ; data/caves/room1101-5.tmx (82)  left: lava, up: stairs, down: stairs, 
  dw #0227
  db 13, #00, #92  ; data/caves/room1101-6.tmx (83)  left: lava, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #91  ; data/caves/room1101-7.tmx (84)  left: lava, up: hole, down: hole, 
  dw #0227
  db 13, #00, #d1  ; data/caves/room1101-8.tmx (85)  left: half-hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #e1  ; data/caves/room1101-9.tmx (86)  left: half-hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #d2  ; data/caves/room1101-10.tmx (87)  left: half-hole, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #e2  ; data/caves/room1101-11.tmx (88)  left: half-hole, up: stairs, down: stairs, 
  dw #0227
  db 13, #00, #a1  ; data/caves/room1101-12.tmx (89)  left: lava, up: stairs, down: hole, 
  dw #0227
  db 14, #00, #54  ; data/caves/room1110-1.tmx (90)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #64  ; data/caves/room1110-2.tmx (91)  left: hole, up: stairs, right: hole, 
  dw #0447
  db 14, #00, #94  ; data/caves/room1110-3.tmx (92)  left: lava, up: hole, right: hole, 
  dw #0447
  db 14, #00, #98  ; data/caves/room1110-4.tmx (93)  left: lava, up: hole, right: lava, 
  dw #0001
  db 14, #00, #a4  ; data/caves/room1110-5.tmx (94)  left: lava, up: stairs, right: hole, 
  dw #0447
  db 14, #00, #e4  ; data/caves/room1110-6.tmx (95)  left: half-hole, up: stairs, right: hole, 
  dw #0447
  db 14, #00, #d4  ; data/caves/room1110-7.tmx (96)  left: half-hole, up: hole, right: hole, 
  dw #0447
  db 15, #00, #55  ; data/caves/room1111-1.tmx (97)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #65  ; data/caves/room1111-2.tmx (98)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #a5  ; data/caves/room1111-3.tmx (99)  left: lava, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #95  ; data/caves/room1111-4.tmx (100)  left: lava, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #56  ; data/caves/room1111-5.tmx (101)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #66  ; data/caves/room1111-6.tmx (102)  left: hole, up: stairs, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #96  ; data/caves/room1111-7.tmx (103)  left: lava, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #e5  ; data/caves/room1111-8.tmx (104)  left: half-hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #d5  ; data/caves/room1111-9.tmx (105)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #d6  ; data/caves/room1111-10.tmx (106)  left: half-hole, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #a6  ; data/caves/room1111-11.tmx (107)  left: lava, up: stairs, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #e6  ; data/caves/room1111-12.tmx (108)  left: half-hole, up: stairs, right: hole, down: stairs, 
  dw #0007
caves_boss_chunk_pool:
caves_block_chunk_pool:
  db 3, #00, #05  ; data/caves/block0011-1.tmx (109)  right: hole, down: hole, 
  dw #099f
  db 3, #00, #06  ; data/caves/block0011-2.tmx (110)  right: hole, down: stairs, 
  dw #099f
  db 5, #00, #11  ; data/caves/block0101-1.tmx (111)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/caves/block0101-2.tmx (112)  up: stairs, down: hole, 
  dw #0829
  db 5, #00, #12  ; data/caves/block0101-3.tmx (113)  up: hole, down: stairs, 
  dw #0aa9
  db 5, #00, #22  ; data/caves/block0101-4.tmx (114)  up: stairs, down: stairs, 
  dw #0aa9
  db 6, #00, #14  ; data/caves/block0110-1.tmx (115)  up: hole, right: hole, 
  dw #0849
  db 6, #00, #24  ; data/caves/block0110-2.tmx (116)  up: stairs, right: hole, 
  dw #0849
  db 7, #00, #15  ; data/caves/block0011-1.tmx + up (117)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #16  ; data/caves/block0011-2.tmx + up (118)  up: hole, right: hole, down: stairs, 
  dw #088f
  db 7, #00, #15  ; data/caves/block0101-1.tmx + right (119)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/caves/block0101-2.tmx + right (120)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 7, #00, #16  ; data/caves/block0101-3.tmx + right (121)  up: hole, right: hole, down: stairs, 
  dw #0889
  db 7, #00, #26  ; data/caves/block0101-4.tmx + right (122)  up: stairs, right: hole, down: stairs, 
  dw #0889
  db 7, #00, #15  ; data/caves/block0110-1.tmx + down (123)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/caves/block0110-2.tmx + down (124)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 7, #00, #16  ; data/caves/block0111-1.tmx (125)  up: hole, right: hole, down: stairs, 
  dw #0809
  db 9, #00, #41  ; data/caves/block1001-1.tmx (126)  left: hole, down: hole, 
  dw #0a31
  db 9, #00, #42  ; data/caves/block1001-2.tmx (127)  left: hole, down: stairs, 
  dw #0a31
  db 9, #00, #c1  ; data/caves/block1001-3.tmx (128)  left: half-hole, down: hole, 
  dw #0a31
  db 9, #00, #81  ; data/caves/block1001-4.tmx (129)  left: lava, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/caves/block1010-1.tmx (130)  left: hole, right: hole, 
  dw #0d51
  db 10, #00, #84  ; data/caves/block1010-2.tmx (131)  left: lava, right: hole, 
  dw #0d51
  db 10, #00, #c4  ; data/caves/block1010-3.tmx (132)  left: half-hole, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/caves/block0011-1.tmx + left (133)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #46  ; data/caves/block0011-2.tmx + left (134)  left: hole, right: hole, down: stairs, 
  dw #0917
  db 11, #00, #45  ; data/caves/block1001-1.tmx + right (135)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #46  ; data/caves/block1001-2.tmx + right (136)  left: hole, right: hole, down: stairs, 
  dw #0811
  db 11, #00, #c5  ; data/caves/block1001-3.tmx + right (137)  left: half-hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #85  ; data/caves/block1001-4.tmx + right (138)  left: lava, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/caves/block1010-1.tmx + down (139)  left: hole, right: hole, down: hole, 
  dw #0911
  db 11, #00, #85  ; data/caves/block1010-2.tmx + down (140)  left: lava, right: hole, down: hole, 
  dw #0911
  db 11, #00, #c5  ; data/caves/block1010-3.tmx + down (141)  left: half-hole, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/caves/block1100-1.tmx (142)  left: hole, up: hole, 
  dw #0a20
  db 12, #00, #60  ; data/caves/block1100-2.tmx (143)  left: hole, up: stairs, 
  dw #0a20
  db 12, #00, #d0  ; data/caves/block1100-3.tmx (144)  left: half-hole, up: hole, 
  dw #0a20
  db 12, #00, #e0  ; data/caves/block1100-4.tmx (145)  left: half-hole, up: stairs, 
  dw #0a20
  db 12, #00, #a0  ; data/caves/block1100-5.tmx (146)  left: lava, up: stairs, 
  dw #0a20
  db 13, #00, #51  ; data/caves/block0101-1.tmx + left (147)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #61  ; data/caves/block0101-2.tmx + left (148)  left: hole, up: stairs, down: hole, 
  dw #0821
  db 13, #00, #52  ; data/caves/block0101-3.tmx + left (149)  left: hole, up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #62  ; data/caves/block0101-4.tmx + left (150)  left: hole, up: stairs, down: stairs, 
  dw #0a21
  db 13, #00, #51  ; data/caves/block1001-1.tmx + up (151)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #52  ; data/caves/block1001-2.tmx + up (152)  left: hole, up: hole, down: stairs, 
  dw #0a21
  db 13, #00, #d1  ; data/caves/block1001-3.tmx + up (153)  left: half-hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #91  ; data/caves/block1001-4.tmx + up (154)  left: lava, up: hole, down: hole, 
  dw #0a21
  db 14, #00, #54  ; data/caves/block0110-1.tmx + left (155)  left: hole, up: hole, right: hole, 
  dw #0841
  db 14, #00, #64  ; data/caves/block0110-2.tmx + left (156)  left: hole, up: stairs, right: hole, 
  dw #0841
  db 14, #00, #54  ; data/caves/block1010-1.tmx + up (157)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #94  ; data/caves/block1010-2.tmx + up (158)  left: lava, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #d4  ; data/caves/block1010-3.tmx + up (159)  left: half-hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/caves/block1100-1.tmx + right (160)  left: hole, up: hole, right: hole, 
  dw #0800
  db 14, #00, #64  ; data/caves/block1100-2.tmx + right (161)  left: hole, up: stairs, right: hole, 
  dw #0800
  db 14, #00, #d4  ; data/caves/block1100-3.tmx + right (162)  left: half-hole, up: hole, right: hole, 
  dw #0800
  db 14, #00, #e4  ; data/caves/block1100-4.tmx + right (163)  left: half-hole, up: stairs, right: hole, 
  dw #0800
  db 14, #00, #a4  ; data/caves/block1100-5.tmx + right (164)  left: lava, up: stairs, right: hole, 
  dw #0800
  db 15, #00, #55  ; data/caves/block0011-1.tmx + left + up (165)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #56  ; data/caves/block0011-2.tmx + left + up (166)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0807
  db 15, #00, #55  ; data/caves/block0101-1.tmx + left + right (167)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/caves/block0101-2.tmx + left + right (168)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/caves/block0101-3.tmx + left + right (169)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #66  ; data/caves/block0101-4.tmx + left + right (170)  left: hole, up: stairs, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #55  ; data/caves/block0110-1.tmx + left + down (171)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/caves/block0110-2.tmx + left + down (172)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/caves/block0111-1.tmx + left (173)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #55  ; data/caves/block1001-1.tmx + up + right (174)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #56  ; data/caves/block1001-2.tmx + up + right (175)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0801
  db 15, #00, #d5  ; data/caves/block1001-3.tmx + up + right (176)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #95  ; data/caves/block1001-4.tmx + up + right (177)  left: lava, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/caves/block1010-1.tmx + up + down (178)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #95  ; data/caves/block1010-2.tmx + up + down (179)  left: lava, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #d5  ; data/caves/block1010-3.tmx + up + down (180)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0801
caves_combination_chunk_pool:
  db 0, #00, #00  ; data/caves/combination0000-1.tmx (181)  
  dw #0781
  db 1, #00, #01  ; data/caves/combination0000-1.tmx + down (182)  down: hole, 
  dw #0381
  db 1, #00, #02  ; data/caves/combination0001-1.tmx (183)  down: stairs, 
  dw #0381
  db 2, #00, #04  ; data/caves/combination0000-1.tmx + right (184)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/caves/combination0000-1.tmx + right + down (185)  right: hole, down: hole, 
  dw #0181
  db 3, #00, #06  ; data/caves/combination0001-1.tmx + right (186)  right: hole, down: stairs, 
  dw #0181
  db 4, #00, #10  ; data/caves/combination0000-1.tmx + up (187)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/caves/combination0100-1.tmx (188)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/caves/combination0000-1.tmx + up + down (189)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #12  ; data/caves/combination0001-1.tmx + up (190)  up: hole, down: stairs, 
  dw #0281
  db 5, #00, #21  ; data/caves/combination0100-1.tmx + down (191)  up: stairs, down: hole, 
  dw #0281
  db 5, #00, #22  ; data/caves/combination0101-1.tmx (192)  up: stairs, down: stairs, 
  dw #0281
  db 6, #00, #14  ; data/caves/combination0000-1.tmx + up + right (193)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/caves/combination0100-1.tmx + right (194)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/caves/combination0000-1.tmx + up + right + down (195)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #16  ; data/caves/combination0001-1.tmx + up + right (196)  up: hole, right: hole, down: stairs, 
  dw #0081
  db 7, #00, #25  ; data/caves/combination0100-1.tmx + right + down (197)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 7, #00, #26  ; data/caves/combination0101-1.tmx + right (198)  up: stairs, right: hole, down: stairs, 
  dw #0081
  db 8, #00, #40  ; data/caves/combination0000-1.tmx + left (199)  left: hole, 
  dw #0701
  db 8, #00, #c0  ; data/caves/combination1000-1.tmx (200)  left: half-hole, 
  dw #0701
  db 8, #00, #80  ; data/caves/combination1000-2.tmx (201)  left: lava, 
  dw #0701
  db 9, #00, #41  ; data/caves/combination0000-1.tmx + left + down (202)  left: hole, down: hole, 
  dw #0301
  db 9, #00, #42  ; data/caves/combination0001-1.tmx + left (203)  left: hole, down: stairs, 
  dw #0301
  db 9, #00, #c1  ; data/caves/combination1000-1.tmx + down (204)  left: half-hole, down: hole, 
  dw #0301
  db 9, #00, #81  ; data/caves/combination1000-2.tmx + down (205)  left: lava, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/caves/combination0000-1.tmx + left + right (206)  left: hole, right: hole, 
  dw #0501
  db 10, #00, #c4  ; data/caves/combination1000-1.tmx + right (207)  left: half-hole, right: hole, 
  dw #0501
  db 10, #00, #84  ; data/caves/combination1000-2.tmx + right (208)  left: lava, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/caves/combination0000-1.tmx + left + right + down (209)  left: hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #46  ; data/caves/combination0001-1.tmx + left + right (210)  left: hole, right: hole, down: stairs, 
  dw #0101
  db 11, #00, #c5  ; data/caves/combination1000-1.tmx + right + down (211)  left: half-hole, right: hole, down: hole, 
  dw #0101
  db 11, #00, #85  ; data/caves/combination1000-2.tmx + right + down (212)  left: lava, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/caves/combination0000-1.tmx + left + up (213)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/caves/combination0100-1.tmx + left (214)  left: hole, up: stairs, 
  dw #0601
  db 12, #00, #d0  ; data/caves/combination1000-1.tmx + up (215)  left: half-hole, up: hole, 
  dw #0601
  db 12, #00, #90  ; data/caves/combination1000-2.tmx + up (216)  left: lava, up: hole, 
  dw #0601
  db 12, #00, #e0  ; data/caves/combination1100-1.tmx (217)  left: half-hole, up: stairs, 
  dw #0601
  db 12, #00, #a0  ; data/caves/combination1100-2.tmx (218)  left: lava, up: stairs, 
  dw #0601
  db 13, #00, #51  ; data/caves/combination0000-1.tmx + left + up + down (219)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #52  ; data/caves/combination0001-1.tmx + left + up (220)  left: hole, up: hole, down: stairs, 
  dw #0201
  db 13, #00, #61  ; data/caves/combination0100-1.tmx + left + down (221)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 13, #00, #62  ; data/caves/combination0101-1.tmx + left (222)  left: hole, up: stairs, down: stairs, 
  dw #0201
  db 13, #00, #d1  ; data/caves/combination1000-1.tmx + up + down (223)  left: half-hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #91  ; data/caves/combination1000-2.tmx + up + down (224)  left: lava, up: hole, down: hole, 
  dw #0201
  db 13, #00, #e1  ; data/caves/combination1100-1.tmx + down (225)  left: half-hole, up: stairs, down: hole, 
  dw #0201
  db 13, #00, #a1  ; data/caves/combination1100-2.tmx + down (226)  left: lava, up: stairs, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/caves/combination0000-1.tmx + left + up + right (227)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/caves/combination0100-1.tmx + left + right (228)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 14, #00, #d4  ; data/caves/combination1000-1.tmx + up + right (229)  left: half-hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #94  ; data/caves/combination1000-2.tmx + up + right (230)  left: lava, up: hole, right: hole, 
  dw #0401
  db 14, #00, #e4  ; data/caves/combination1100-1.tmx + right (231)  left: half-hole, up: stairs, right: hole, 
  dw #0401
  db 14, #00, #a4  ; data/caves/combination1100-2.tmx + right (232)  left: lava, up: stairs, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/caves/combination0000-1.tmx + left + up + right + down (233)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #56  ; data/caves/combination0001-1.tmx + left + up + right (234)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0001
  db 15, #00, #65  ; data/caves/combination0100-1.tmx + left + right + down (235)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
  db 15, #00, #66  ; data/caves/combination0101-1.tmx + left + right (236)  left: hole, up: stairs, right: hole, down: stairs, 
  dw #0001
  db 15, #00, #d5  ; data/caves/combination1000-1.tmx + up + right + down (237)  left: half-hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #95  ; data/caves/combination1000-2.tmx + up + right + down (238)  left: lava, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #e5  ; data/caves/combination1100-1.tmx + right + down (239)  left: half-hole, up: stairs, right: hole, down: hole, 
  dw #0001
  db 15, #00, #a5  ; data/caves/combination1100-2.tmx + right + down (240)  left: lava, up: stairs, right: hole, down: hole, 
  dw #0001
