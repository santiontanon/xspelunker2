;-----------------------------------------------

instrument_profile_table:
    dw square_wave_instrument_profile
    dw piano_instrument_profile
    dw soft_piano_instrument_profile
    dw pad_instrument_profile
    dw piano_staccato_instrument_profile
    dw major_arpeggio_instrument_profile
    dw major_arpeggio_2ndinv_instrument_profile
    dw minor_arpeggio_instrument_profile
    dw minor_arpeggio_2ndinv_instrument_profile
    dw major_arpeggio_fadein_instrument_profile
    dw minor_arpeggio_fadein_instrument_profile
    dw diminished_arpeggio_fadein_instrument_profile

instrument_profiles:
square_wave_instrument_profile:
    db 12, #ff
piano_instrument_profile:
major_arpeggio_instrument_profile:
major_arpeggio_2ndinv_instrument_profile:
minor_arpeggio_instrument_profile:
minor_arpeggio_2ndinv_instrument_profile:
    db 13, 13, 12, 11, 10, 10, 9, 9
    db 8, 8, 7, 7, 6, #ff
soft_piano_instrument_profile:
    db 11, 10, 9, 8, 8, 7, 7
    db 6, 6, 5, 5, 4, #ff
pad_instrument_profile:
    db  2,  6,  8, 12, 12, 12, 12, 12
    db 12, 11, 10,  9,  8,  7,  7,  6
    db  6,  6,  6,  5,  5,  5,  5,  5
    db  5,  5,  5,  4,  4,  4,  4,  4
    db  4,  4,  4,  3, #ff
piano_staccato_instrument_profile:
    db 12, 11, 9, 8, 7, 6, 5, 4
    db 3, 2, 1, 0, #ff
major_arpeggio_fadein_instrument_profile:
minor_arpeggio_fadein_instrument_profile
diminished_arpeggio_fadein_instrument_profile
    db 2, 2, 3, 3, 4, 4, 5, 5
    db 6, 6, 7, 7, 8, 8, 8, 8
    db 9, 9, 9, 9, 9, 9, 10, 10
    db 10, 10, 10, 10, 10, 10, 9, 9
    db 9, 9, 9, 9, 8, 8, 8, 8
    db 8, 8, 7, 7, 7, 7, 7, 7
    db 7, 7, 7, 7, 6, 6, 6, 6
    db 6, 6, 6, 6, 6, 6, 5, 5
    db 5, 5, 4, 4, 4, 4, 3, 3
    db 2, 2, 1, #ff


;-----------------------------------------------
major_arpeggio_pattern:
major_arpeggio_fadein_pattern:
    db 0, 7*2, 4*2, 7*2
major_arpeggio_2ndinv_pattern:
    db 0, 9*2, 5*2, 9*2
minor_arpeggio_pattern:
minor_arpeggio_fadein_pattern:
    db 0, 7*2, 3*2, 7*2
minor_arpeggio_2ndinv_pattern:
    db 0, 8*2, 5*2, 8*2
diminished_arpeggio_pattern:
    db 0, 6*2, 3*2, 6*2


;-----------------------------------------------
    ; make sure note_period_table is 2-aligned: 
    ds (((($-1)/#0002)+1)*#0002-$)

note_period_table:
  db 13,93,  12,156,  11,231,  11,60,  10,155,  10,2,  9,115,  8,235
  db 8,107,  7,242,  7,128,  7,20,  6,174,  6,78,  5,244,  5,158
  db 5,77,  5,1,  4,185,  4,117,  4,53,  3,249,  3,192,  3,138
  db 3,87,  3,39,  2,250,  2,207,  2,167,  2,129,  2,93,  2,59
  db 2,27,  1,252,  1,224,  1,197,  1,172,  1,148,  1,125,  1,104
  db 1,83,  1,64,  1,46,  1,29,  1,13,  0,254,  0,240,  0,226
  db 0,214,  0,202,  0,190,  0,180,  0,170,  0,160,  0,151,  0,143
  db 0,135,  0,127,  0,120,  0,113,  0,107,  0,101,  0,95,  0,90
  db 0,85,  0,80,  0,76,  0,71,  0,67,  0,64,  0,60,  0,57
  db 0,53,  0,50,  0,48,  0,45,  0,42,  0,40,  0,38,  0,36
  db 0,34,  0,32,  0,30,  0,28,  0,27
