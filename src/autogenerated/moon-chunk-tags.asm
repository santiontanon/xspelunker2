; Each chunk is 5 bytes: type, chunkFlags, left/up/right/down tags, locationTypeFlags (word)
moon_chunk_flags:
moon_standard_chunk_pool:
  db 0, #00, #00  ; data/moon/room0000-1.tmx (0)  
  dw #06ef
  db 1, #00, #01  ; data/moon/room0001-1.tmx (1)  down: hole, 
  dw #03bf
  db 1, #00, #02  ; data/moon/room0001-2.tmx (2)  down: stairs, 
  dw #03bf
  db 1, #00, #01  ; data/moon/room0001-3.tmx (3)  down: hole, 
  dw #03bf
  db 2, #00, #04  ; data/moon/room0010-1.tmx (4)  right: hole, 
  dw #05df
  db 2, #00, #04  ; data/moon/room0010-2.tmx (5)  right: hole, 
  dw #019b
  db 2, #00, #04  ; data/moon/room0010-3.tmx (6)  right: hole, 
  dw #0007
  db 3, #00, #05  ; data/moon/room0011-1.tmx (7)  right: hole, down: hole, 
  dw #019f
  db 3, #00, #06  ; data/moon/room0011-2.tmx (8)  right: hole, down: stairs, 
  dw #019f
  db 3, #00, #05  ; data/moon/room0011-3.tmx (9)  right: hole, down: hole, 
  dw #0117
  db 3, #00, #05  ; data/moon/room0011-4.tmx (10)  right: hole, down: hole, 
  dw #008f
  db 4, #00, #10  ; data/moon/room0100-1.tmx (11)  up: hole, 
  dw #06ef
  db 4, #00, #20  ; data/moon/room0100-2.tmx (12)  up: stairs, 
  dw #06ef
  db 4, #00, #10  ; data/moon/room0100-3.tmx (13)  up: hole, 
  dw #0007
  db 5, #00, #11  ; data/moon/room0101-1.tmx (14)  up: hole, down: hole, 
  dw #02af
  db 5, #00, #12  ; data/moon/room0101-2.tmx (15)  up: hole, down: stairs, 
  dw #02af
  db 5, #00, #21  ; data/moon/room0101-3.tmx (16)  up: stairs, down: hole, 
  dw #02af
  db 5, #00, #11  ; data/moon/room0101-4.tmx (17)  up: hole, down: hole, 
  dw #0007
  db 6, #00, #14  ; data/moon/room0110-1.tmx (18)  up: hole, right: hole, 
  dw #04cf
  db 6, #00, #24  ; data/moon/room0110-2.tmx (19)  up: stairs, right: hole, 
  dw #04cf
  db 6, #00, #14  ; data/moon/room0110-3.tmx (20)  up: hole, right: hole, 
  dw #0007
  db 6, #00, #14  ; data/moon/room0110-4.tmx (21)  up: hole, right: hole, 
  dw #0001
  db 7, #00, #15  ; data/moon/room0111-1.tmx (22)  up: hole, right: hole, down: hole, 
  dw #008f
  db 7, #00, #16  ; data/moon/room0111-2.tmx (23)  up: hole, right: hole, down: stairs, 
  dw #008f
  db 7, #00, #25  ; data/moon/room0111-3.tmx (24)  up: stairs, right: hole, down: hole, 
  dw #008f
  db 7, #00, #15  ; data/moon/room0111-4.tmx (25)  up: hole, right: hole, down: hole, 
  dw #0007
  db 8, #00, #40  ; data/moon/room1000-1.tmx (26)  left: hole, 
  dw #0777
  db 8, #00, #40  ; data/moon/room1000-2.tmx (27)  left: hole, 
  dw #0117
  db 8, #00, #40  ; data/moon/room1000-3.tmx (28)  left: hole, 
  dw #0333
  db 8, #00, #40  ; data/moon/room1000-4.tmx (29)  left: hole, 
  dw #0667
  db 9, #00, #41  ; data/moon/room1001-1.tmx (30)  left: hole, down: hole, 
  dw #0337
  db 9, #00, #42  ; data/moon/room1001-2.tmx (31)  left: hole, down: stairs, 
  dw #0337
  db 9, #00, #41  ; data/moon/room1001-3.tmx (32)  left: hole, down: hole, 
  dw #0227
  db 9, #00, #41  ; data/moon/room1001-4.tmx (33)  left: hole, down: hole, 
  dw #0333
  db 10, #00, #44  ; data/moon/room1010-1.tmx (34)  left: hole, right: hole, 
  dw #0557
  db 10, #00, #44  ; data/moon/room1010-2.tmx (35)  left: hole, right: hole, 
  dw #0447
  db 10, #00, #44  ; data/moon/room1010-3.tmx (36)  left: hole, right: hole, 
  dw #0007
  db 11, #00, #45  ; data/moon/room1011-1.tmx (37)  left: hole, right: hole, down: hole, 
  dw #0117
  db 11, #00, #46  ; data/moon/room1011-2.tmx (38)  left: hole, right: hole, down: stairs, 
  dw #0117
  db 11, #00, #45  ; data/moon/room1011-3.tmx (39)  left: hole, right: hole, down: hole, 
  dw #0007
  db 12, #00, #50  ; data/moon/room1100-1.tmx (40)  left: hole, up: hole, 
  dw #0667
  db 12, #00, #60  ; data/moon/room1100-2.tmx (41)  left: hole, up: stairs, 
  dw #0667
  db 12, #00, #50  ; data/moon/room1100-3.tmx (42)  left: hole, up: hole, 
  dw #0001
  db 13, #00, #51  ; data/moon/room1101-1.tmx (43)  left: hole, up: hole, down: hole, 
  dw #0227
  db 13, #00, #52  ; data/moon/room1101-2.tmx (44)  left: hole, up: hole, down: stairs, 
  dw #0227
  db 13, #00, #61  ; data/moon/room1101-3.tmx (45)  left: hole, up: stairs, down: hole, 
  dw #0227
  db 13, #00, #51  ; data/moon/room1101-4.tmx (46)  left: hole, up: hole, down: hole, 
  dw #0227
  db 14, #00, #54  ; data/moon/room1110-1.tmx (47)  left: hole, up: hole, right: hole, 
  dw #0447
  db 14, #00, #64  ; data/moon/room1110-2.tmx (48)  left: hole, up: stairs, right: hole, 
  dw #0447
  db 14, #00, #54  ; data/moon/room1110-3.tmx (49)  left: hole, up: hole, right: hole, 
  dw #0007
  db 15, #00, #55  ; data/moon/room1111-1.tmx (50)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
  db 15, #00, #56  ; data/moon/room1111-2.tmx (51)  left: hole, up: hole, right: hole, down: stairs, 
  dw #0007
  db 15, #00, #65  ; data/moon/room1111-3.tmx (52)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0007
  db 15, #00, #55  ; data/moon/room1111-4.tmx (53)  left: hole, up: hole, right: hole, down: hole, 
  dw #0007
moon_boss_chunk_pool:
  db 1, #01, #01  ; data/moon/boss0001-1.tmx (54)  down: hole, 
  dw #0007
  db 2, #01, #04  ; data/moon/boss0010-1.tmx (55)  right: hole, 
  dw #0005
  db 3, #01, #05  ; data/moon/boss0011-1.tmx (56)  right: hole, down: hole, 
  dw #0005
  db 4, #01, #10  ; data/moon/boss0100-1.tmx (57)  up: hole, 
  dw #0005
  db 4, #01, #20  ; data/moon/boss0100-2.tmx (58)  up: stairs, 
  dw #0005
  db 5, #01, #11  ; data/moon/boss0101-1.tmx (59)  up: hole, down: hole, 
  dw #0005
  db 5, #01, #21  ; data/moon/boss0101-2.tmx (60)  up: stairs, down: hole, 
  dw #0005
  db 6, #01, #14  ; data/moon/boss0110-1.tmx (61)  up: hole, right: hole, 
  dw #0005
  db 6, #01, #24  ; data/moon/boss0110-2.tmx (62)  up: stairs, right: hole, 
  dw #0005
  db 7, #01, #15  ; data/moon/boss0111-1.tmx (63)  up: hole, right: hole, down: hole, 
  dw #0005
  db 7, #01, #25  ; data/moon/boss0111-2.tmx (64)  up: stairs, right: hole, down: hole, 
  dw #0005
  db 8, #01, #40  ; data/moon/boss1000-1.tmx (65)  left: hole, 
  dw #0005
  db 9, #01, #41  ; data/moon/boss1001-1.tmx (66)  left: hole, down: hole, 
  dw #0005
  db 10, #01, #44  ; data/moon/boss1010-1.tmx (67)  left: hole, right: hole, 
  dw #0005
  db 11, #01, #45  ; data/moon/boss1011-1.tmx (68)  left: hole, right: hole, down: hole, 
  dw #0005
  db 12, #01, #50  ; data/moon/boss1100-1.tmx (69)  left: hole, up: hole, 
  dw #0005
  db 12, #01, #60  ; data/moon/boss1100-2.tmx (70)  left: hole, up: stairs, 
  dw #0005
  db 13, #01, #51  ; data/moon/boss1101-1.tmx (71)  left: hole, up: hole, down: hole, 
  dw #0005
  db 13, #01, #61  ; data/moon/boss1101-2.tmx (72)  left: hole, up: stairs, down: hole, 
  dw #0005
  db 14, #01, #54  ; data/moon/boss1110-1.tmx (73)  left: hole, up: hole, right: hole, 
  dw #0005
  db 14, #01, #64  ; data/moon/boss1110-2.tmx (74)  left: hole, up: stairs, right: hole, 
  dw #0005
  db 15, #01, #55  ; data/moon/boss1111-1.tmx (75)  left: hole, up: hole, right: hole, down: hole, 
  dw #0005
  db 15, #01, #65  ; data/moon/boss1111-2.tmx (76)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0005
moon_block_chunk_pool:
  db 3, #00, #05  ; data/moon/block0011-1.tmx (77)  right: hole, down: hole, 
  dw #099f
  db 5, #00, #11  ; data/moon/block0101-1.tmx (78)  up: hole, down: hole, 
  dw #0829
  db 5, #00, #21  ; data/moon/block0101-2.tmx (79)  up: stairs, down: hole, 
  dw #0828
  db 6, #00, #14  ; data/moon/block0110-1.tmx (80)  up: hole, right: hole, 
  dw #0849
  db 6, #00, #24  ; data/moon/block0110-2.tmx (81)  up: stairs, right: hole, 
  dw #0849
  db 7, #00, #15  ; data/moon/block0011-1.tmx + up (82)  up: hole, right: hole, down: hole, 
  dw #088f
  db 7, #00, #15  ; data/moon/block0101-1.tmx + right (83)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/moon/block0101-2.tmx + right (84)  up: stairs, right: hole, down: hole, 
  dw #0808
  db 7, #00, #15  ; data/moon/block0110-1.tmx + down (85)  up: hole, right: hole, down: hole, 
  dw #0809
  db 7, #00, #25  ; data/moon/block0110-2.tmx + down (86)  up: stairs, right: hole, down: hole, 
  dw #0809
  db 9, #00, #41  ; data/moon/block1001-1.tmx (87)  left: hole, down: hole, 
  dw #0a31
  db 9, #00, #41  ; data/moon/block1001-2.tmx (88)  left: hole, down: hole, 
  dw #0a31
  db 10, #00, #44  ; data/moon/block1010-1.tmx (89)  left: hole, right: hole, 
  dw #0d51
  db 11, #00, #45  ; data/moon/block0011-1.tmx + left (90)  left: hole, right: hole, down: hole, 
  dw #0917
  db 11, #00, #45  ; data/moon/block1001-1.tmx + right (91)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/moon/block1001-2.tmx + right (92)  left: hole, right: hole, down: hole, 
  dw #0811
  db 11, #00, #45  ; data/moon/block1010-1.tmx + down (93)  left: hole, right: hole, down: hole, 
  dw #0911
  db 12, #00, #50  ; data/moon/block1100-1.tmx (94)  left: hole, up: hole, 
  dw #0a60
  db 12, #00, #60  ; data/moon/block1100-2.tmx (95)  left: hole, up: stairs, 
  dw #0a60
  db 13, #00, #51  ; data/moon/block0101-1.tmx + left (96)  left: hole, up: hole, down: hole, 
  dw #0821
  db 13, #00, #61  ; data/moon/block0101-2.tmx + left (97)  left: hole, up: stairs, down: hole, 
  dw #0820
  db 13, #00, #51  ; data/moon/block1001-1.tmx + up (98)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/moon/block1001-2.tmx + up (99)  left: hole, up: hole, down: hole, 
  dw #0a21
  db 13, #00, #51  ; data/moon/block1100-1.tmx + down (100)  left: hole, up: hole, down: hole, 
  dw #0a20
  db 13, #00, #61  ; data/moon/block1100-2.tmx + down (101)  left: hole, up: stairs, down: hole, 
  dw #0a20
  db 14, #00, #54  ; data/moon/block0110-1.tmx + left (102)  left: hole, up: hole, right: hole, 
  dw #0841
  db 14, #00, #64  ; data/moon/block0110-2.tmx + left (103)  left: hole, up: stairs, right: hole, 
  dw #0841
  db 14, #00, #54  ; data/moon/block1010-1.tmx + up (104)  left: hole, up: hole, right: hole, 
  dw #0c41
  db 14, #00, #54  ; data/moon/block1100-1.tmx + right (105)  left: hole, up: hole, right: hole, 
  dw #0840
  db 14, #00, #64  ; data/moon/block1100-2.tmx + right (106)  left: hole, up: stairs, right: hole, 
  dw #0840
  db 15, #00, #55  ; data/moon/block0011-1.tmx + left + up (107)  left: hole, up: hole, right: hole, down: hole, 
  dw #0807
  db 15, #00, #55  ; data/moon/block0101-1.tmx + left + right (108)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/moon/block0101-2.tmx + left + right (109)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
  db 15, #00, #55  ; data/moon/block0110-1.tmx + left + down (110)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #65  ; data/moon/block0110-2.tmx + left + down (111)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1001-1.tmx + up + right (112)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1001-2.tmx + up + right (113)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1010-1.tmx + up + down (114)  left: hole, up: hole, right: hole, down: hole, 
  dw #0801
  db 15, #00, #55  ; data/moon/block1100-1.tmx + right + down (115)  left: hole, up: hole, right: hole, down: hole, 
  dw #0800
  db 15, #00, #65  ; data/moon/block1100-2.tmx + right + down (116)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0800
moon_combination_chunk_pool:
  db 0, #00, #00  ; data/moon/combination0000-1.tmx (117)  
  dw #0781
  db 1, #00, #01  ; data/moon/combination0000-1.tmx + down (118)  down: hole, 
  dw #0381
  db 2, #00, #04  ; data/moon/combination0000-1.tmx + right (119)  right: hole, 
  dw #0581
  db 3, #00, #05  ; data/moon/combination0000-1.tmx + right + down (120)  right: hole, down: hole, 
  dw #0181
  db 4, #00, #10  ; data/moon/combination0000-1.tmx + up (121)  up: hole, 
  dw #0681
  db 4, #00, #20  ; data/moon/combination0100-1.tmx (122)  up: stairs, 
  dw #0681
  db 5, #00, #11  ; data/moon/combination0000-1.tmx + up + down (123)  up: hole, down: hole, 
  dw #0281
  db 5, #00, #21  ; data/moon/combination0100-1.tmx + down (124)  up: stairs, down: hole, 
  dw #0281
  db 6, #00, #14  ; data/moon/combination0000-1.tmx + up + right (125)  up: hole, right: hole, 
  dw #0481
  db 6, #00, #24  ; data/moon/combination0100-1.tmx + right (126)  up: stairs, right: hole, 
  dw #0481
  db 7, #00, #15  ; data/moon/combination0000-1.tmx + up + right + down (127)  up: hole, right: hole, down: hole, 
  dw #0081
  db 7, #00, #25  ; data/moon/combination0100-1.tmx + right + down (128)  up: stairs, right: hole, down: hole, 
  dw #0081
  db 8, #00, #40  ; data/moon/combination0000-1.tmx + left (129)  left: hole, 
  dw #0701
  db 9, #00, #41  ; data/moon/combination0000-1.tmx + left + down (130)  left: hole, down: hole, 
  dw #0301
  db 10, #00, #44  ; data/moon/combination0000-1.tmx + left + right (131)  left: hole, right: hole, 
  dw #0501
  db 11, #00, #45  ; data/moon/combination0000-1.tmx + left + right + down (132)  left: hole, right: hole, down: hole, 
  dw #0101
  db 12, #00, #50  ; data/moon/combination0000-1.tmx + left + up (133)  left: hole, up: hole, 
  dw #0601
  db 12, #00, #60  ; data/moon/combination0100-1.tmx + left (134)  left: hole, up: stairs, 
  dw #0601
  db 13, #00, #51  ; data/moon/combination0000-1.tmx + left + up + down (135)  left: hole, up: hole, down: hole, 
  dw #0201
  db 13, #00, #61  ; data/moon/combination0100-1.tmx + left + down (136)  left: hole, up: stairs, down: hole, 
  dw #0201
  db 14, #00, #54  ; data/moon/combination0000-1.tmx + left + up + right (137)  left: hole, up: hole, right: hole, 
  dw #0401
  db 14, #00, #64  ; data/moon/combination0100-1.tmx + left + right (138)  left: hole, up: stairs, right: hole, 
  dw #0401
  db 15, #00, #55  ; data/moon/combination0000-1.tmx + left + up + right + down (139)  left: hole, up: hole, right: hole, down: hole, 
  dw #0001
  db 15, #00, #65  ; data/moon/combination0100-1.tmx + left + right + down (140)  left: hole, up: stairs, right: hole, down: hole, 
  dw #0001
