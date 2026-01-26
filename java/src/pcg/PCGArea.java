/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import util.Pair;
import util.TMXObject;

/**
 *
 * @author santi
 */
public class PCGArea {
    
    public static final int ROOM_WIDTH = 2;
    public static final int ROOM_HEIGHT = 2;
    public static final int SPECIAL_ROOM_IDS_START = 100;
    public static final int CALENDAR_ROOM_ID = 100;  // some ID that is impossible to arise naturally
    public static final int TELEPORTER_ROOM_ID = 101;  // some ID that is impossible to arise naturally
    public static final int START_ROOM_ID = 102;  // some ID that is impossible to arise naturally
    public static final int n_connections_per_type[] = {
        0, 1, 1, 2, 1, 2, 2, 3,
        1, 2, 2, 3, 2, 3, 3, 4,
    };
    
    public String biome = null;
    public List<RoomChunk> bg_chunks = new ArrayList<>();
    public List<RoomChunk> all_fg_chunks = new ArrayList<>();
    public int first_boss_chunk = 0;
    public int first_block_chunk = 0;
    public int first_combination_chunk = 0;
    
    public HashMap<Integer, List<RoomChunk>> fg_chunks = new LinkedHashMap<>();
    public HashMap<Integer, List<RoomChunk>> boss_chunks = new LinkedHashMap<>();
    public HashMap<Integer, List<RoomChunk>> block_chunks = new LinkedHashMap<>();
    public HashMap<Integer, List<RoomChunk>> combination_chunks = new LinkedHashMap<>();
    
    public PCGArea(boolean simplifyChunks, String a_biome) throws Exception
    {
        biome = a_biome;
        switch(biome) {
            case "jungle":
                loadJungleChunks(simplifyChunks);
                break;
            case "pyramid":
                loadPyramidChunks(simplifyChunks);
                break;
            case "caves":
                loadCaveChunks(simplifyChunks);
                break;
            case "xibalba":
                loadXibalbaChunks(simplifyChunks);
                break;
            default:
                throw new Exception("Unsupported biome: " + biome);
        }
        
        // List all the fg chunks in a single list:
        for(int i = 0;i<16;i++) {
            if (fg_chunks.containsKey(i)) {
                if (simplifyChunks) {
                    List<RoomChunk> simplified = new ArrayList<>();
                    for(RoomChunk c:fg_chunks.get(i)) {
                        if (c.type != i) {
                            throw new Exception("Chunk was placed in the wrong type group! " + c.path);
                        }
                        simplified.add(c.simplifyTiles(biome));
                    }
                    fg_chunks.put(i, simplified);
                    all_fg_chunks.addAll(simplified);
                } else {
                    all_fg_chunks.addAll(fg_chunks.get(i));
                }
            }
        }
        first_boss_chunk = all_fg_chunks.size();
        for(int i = 0;i<16;i++) {
            if (boss_chunks.containsKey(i)) {
                if (simplifyChunks) {
                    List<RoomChunk> simplified = new ArrayList<>();
                    for(RoomChunk c:boss_chunks.get(i)) {
                        c.tags.put("boss", "true");
                        simplified.add(c.simplifyTiles(biome));
                    }
                    boss_chunks.put(i, simplified);
                    all_fg_chunks.addAll(simplified);
                } else {
                    all_fg_chunks.addAll(boss_chunks.get(i));                    
                }
            }
        }
        first_block_chunk = all_fg_chunks.size();
        for(int i = 0;i<16;i++) {
            if (block_chunks.containsKey(i)) {
                if (simplifyChunks) {
                    List<RoomChunk> simplified = new ArrayList<>();
                    for(RoomChunk c:block_chunks.get(i)) {
                        simplified.add(c.simplifyTiles(biome));
                    }
                    block_chunks.put(i, simplified);
                    all_fg_chunks.addAll(simplified);
                } else {
                    all_fg_chunks.addAll(block_chunks.get(i));
                }
            }
        }
        first_combination_chunk = all_fg_chunks.size();
        for(int i = 0;i<16;i++) {
            if (combination_chunks.containsKey(i)) {
                if (simplifyChunks) {
                    List<RoomChunk> simplified = new ArrayList<>();
                    for(RoomChunk c:combination_chunks.get(i)) {
                        simplified.add(c.simplifyTiles(biome));
                    }
                    combination_chunks.put(i, simplified);
                    all_fg_chunks.addAll(simplified);
                } else {
                    all_fg_chunks.addAll(combination_chunks.get(i));
                }
            }
        }        
    }

    
    public void loadJungleChunks(boolean simplifyChunks) throws Exception
    {
        // background:
        bg_chunks.add(new RoomChunk("data/jungle/bg-1.tmx", 0, "jungle"));

        // foreground:
        for(int i = 0;i<16;i++) {
            fg_chunks.put(i, new ArrayList<>());
        }
        fg_chunks.get(0x0).add(new RoomChunk("data/jungle/room0000-1.tmx", 0x0, "jungle"));
        
        fg_chunks.get(0x1).add(new RoomChunk("data/jungle/room0001-1.tmx", 0x1, "jungle"));
        fg_chunks.get(0x1).add(new RoomChunk("data/jungle/room0001-2.tmx", 0x1, "jungle"));

        fg_chunks.get(0x2).add(new RoomChunk("data/jungle/room0010-1.tmx", 0x2, "jungle"));
        fg_chunks.get(0x2).add(new RoomChunk("data/jungle/room0010-2.tmx", 0x2, "jungle"));
        fg_chunks.get(0x2).add(new RoomChunk("data/jungle/room0010-3.tmx", 0x2, "jungle"));

        fg_chunks.get(0x3).add(new RoomChunk("data/jungle/room0011-1.tmx", 0x3, "jungle"));
        fg_chunks.get(0x3).add(new RoomChunk("data/jungle/room0011-2.tmx", 0x3, "jungle"));
        fg_chunks.get(0x3).add(new RoomChunk("data/jungle/room0011-3.tmx", 0x3, "jungle"));
        fg_chunks.get(0x3).add(new RoomChunk("data/jungle/room0011-4.tmx", 0x3, "jungle"));

        fg_chunks.get(0x4).add(new RoomChunk("data/jungle/room0100-1.tmx", 0x4, "jungle"));
        fg_chunks.get(0x4).add(new RoomChunk("data/jungle/room0100-2.tmx", 0x4, "jungle"));
        fg_chunks.get(0x4).add(new RoomChunk("data/jungle/room0100-3.tmx", 0x4, "jungle"));

        fg_chunks.get(0x5).add(new RoomChunk("data/jungle/room0101-1.tmx", 0x5, "jungle"));
        fg_chunks.get(0x5).add(new RoomChunk("data/jungle/room0101-2.tmx", 0x5, "jungle"));

        fg_chunks.get(0x6).add(new RoomChunk("data/jungle/room0110-1.tmx", 0x6, "jungle"));
        fg_chunks.get(0x6).add(new RoomChunk("data/jungle/room0110-2.tmx", 0x6, "jungle"));
        fg_chunks.get(0x6).add(new RoomChunk("data/jungle/room0110-3.tmx", 0x6, "jungle"));
        fg_chunks.get(0x6).add(new RoomChunk("data/jungle/room0110-4.tmx", 0x6, "jungle"));

        fg_chunks.get(0x7).add(new RoomChunk("data/jungle/room0111-1.tmx", 0x7, "jungle"));
        fg_chunks.get(0x7).add(new RoomChunk("data/jungle/room0111-2.tmx", 0x7, "jungle"));

        fg_chunks.get(0x8).add(new RoomChunk("data/jungle/room1000-1.tmx", 0x8, "jungle"));
        fg_chunks.get(0x8).add(new RoomChunk("data/jungle/room1000-2.tmx", 0x8, "jungle"));
        fg_chunks.get(0x8).add(new RoomChunk("data/jungle/room1000-3.tmx", 0x8, "jungle"));
        fg_chunks.get(0x8).add(new RoomChunk("data/jungle/room1000-4.tmx", 0x8, "jungle"));
        fg_chunks.get(0x8).add(new RoomChunk("data/jungle/room1000-5.tmx", 0x8, "jungle"));

        fg_chunks.get(0x9).add(new RoomChunk("data/jungle/room1001-1.tmx", 0x9, "jungle"));
        fg_chunks.get(0x9).add(new RoomChunk("data/jungle/room1001-2.tmx", 0x9, "jungle"));
        fg_chunks.get(0x9).add(new RoomChunk("data/jungle/room1001-3.tmx", 0x9, "jungle"));
        fg_chunks.get(0x9).add(new RoomChunk("data/jungle/room1001-4.tmx", 0x9, "jungle"));
        fg_chunks.get(0x9).add(new RoomChunk("data/jungle/room1001-5.tmx", 0x9, "jungle"));

        fg_chunks.get(0xa).add(new RoomChunk("data/jungle/room1010-1.tmx", 0xa, "jungle"));
        fg_chunks.get(0xa).add(new RoomChunk("data/jungle/room1010-2.tmx", 0xa, "jungle"));
        fg_chunks.get(0xa).add(new RoomChunk("data/jungle/room1010-3.tmx", 0xa, "jungle"));
        fg_chunks.get(0xa).add(new RoomChunk("data/jungle/room1010-4.tmx", 0xa, "jungle"));
        fg_chunks.get(0xa).add(new RoomChunk("data/jungle/room1010-5.tmx", 0xa, "jungle"));

        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-1.tmx", 0xb, "jungle"));
        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-2.tmx", 0xb, "jungle"));
        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-3.tmx", 0xb, "jungle"));
        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-4.tmx", 0xb, "jungle"));
        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-5.tmx", 0xb, "jungle"));
        fg_chunks.get(0xb).add(new RoomChunk("data/jungle/room1011-6.tmx", 0xb, "jungle"));

        fg_chunks.get(0xc).add(new RoomChunk("data/jungle/room1100-1.tmx", 0xc, "jungle"));
        fg_chunks.get(0xc).add(new RoomChunk("data/jungle/room1100-2.tmx", 0xc, "jungle"));
        fg_chunks.get(0xc).add(new RoomChunk("data/jungle/room1100-3.tmx", 0xc, "jungle"));
        fg_chunks.get(0xc).add(new RoomChunk("data/jungle/room1100-4.tmx", 0xc, "jungle"));

        fg_chunks.get(0xd).add(new RoomChunk("data/jungle/room1101-1.tmx", 0xd, "jungle"));
        fg_chunks.get(0xd).add(new RoomChunk("data/jungle/room1101-2.tmx", 0xd, "jungle"));
        fg_chunks.get(0xd).add(new RoomChunk("data/jungle/room1101-3.tmx", 0xd, "jungle"));
        fg_chunks.get(0xd).add(new RoomChunk("data/jungle/room1101-4.tmx", 0xd, "jungle"));

        fg_chunks.get(0xe).add(new RoomChunk("data/jungle/room1110-1.tmx", 0xe, "jungle"));
        fg_chunks.get(0xe).add(new RoomChunk("data/jungle/room1110-2.tmx", 0xe, "jungle"));
        fg_chunks.get(0xe).add(new RoomChunk("data/jungle/room1110-3.tmx", 0xe, "jungle"));
        fg_chunks.get(0xe).add(new RoomChunk("data/jungle/room1110-4.tmx", 0xe, "jungle"));

        fg_chunks.get(0xf).add(new RoomChunk("data/jungle/room1111-1.tmx", 0xf, "jungle"));
        fg_chunks.get(0xf).add(new RoomChunk("data/jungle/room1111-2.tmx", 0xf, "jungle"));
        fg_chunks.get(0xf).add(new RoomChunk("data/jungle/room1111-3.tmx", 0xf, "jungle"));
        fg_chunks.get(0xf).add(new RoomChunk("data/jungle/room1111-4.tmx", 0xf, "jungle"));
        
        // boss:
        for(int i = 0;i<16;i++) {
            boss_chunks.put(i, new ArrayList<>());
        }

        // block puzzles:
        for(int i = 0;i<16;i++) {
            block_chunks.put(i, new ArrayList<>());
        }
        {
            List<RoomChunk> l = new ArrayList<>();
            l.add(new RoomChunk("data/jungle/block0011-1.tmx", 0x3, "jungle"));
            l.add(new RoomChunk("data/jungle/block0011-2.tmx", 0x3, "jungle"));
            l.add(new RoomChunk("data/jungle/block0101-1.tmx", 0x5, "jungle"));
            l.add(new RoomChunk("data/jungle/block0101-2.tmx", 0x5, "jungle"));
            l.add(new RoomChunk("data/jungle/block0110-1.tmx", 0x6, "jungle"));
            l.add(new RoomChunk("data/jungle/block0111-1.tmx", 0x7, "jungle"));
            l.add(new RoomChunk("data/jungle/block1001-1.tmx", 0x9, "jungle"));
            l.add(new RoomChunk("data/jungle/block1001-2.tmx", 0x9, "jungle"));
            l.add(new RoomChunk("data/jungle/block1001-3.tmx", 0x9, "jungle"));
            l.add(new RoomChunk("data/jungle/block1001-4.tmx", 0x9, "jungle"));
            l.add(new RoomChunk("data/jungle/block1010-1.tmx", 0xa, "jungle"));
            l.add(new RoomChunk("data/jungle/block1010-2.tmx", 0xa, "jungle"));
            l.add(new RoomChunk("data/jungle/block1100-1.tmx", 0xc, "jungle"));
            l.add(new RoomChunk("data/jungle/block1100-2.tmx", 0xc, "jungle"));

            for(RoomChunk c2:l) {
                block_chunks.get(c2.type).add(c2);
                List<RoomChunk> current = new ArrayList<>();
                List<RoomChunk> current2 = new ArrayList<>();
                current.add(c2);
                current2.add(c2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_LEFT) == 0) {
                        TMXObject o = c.firstObject("breakable-left");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_LEFT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-left");
                            chunk2.removeObjectTypes("door-left");
                            chunk2.path += " + left";
                            chunk2.tags.put("left", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_UP) == 0) {
                        TMXObject o = c.firstObject("breakable-up");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_UP;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-up");
                            chunk2.removeObjectTypes("door-up");
                            chunk2.path += " + up";
                            chunk2.tags.put("up", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                        TMXObject o = c.firstObject("breakable-right");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_RIGHT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-right");
                            chunk2.removeObjectTypes("door-right");
                            chunk2.path += " + right";
                            chunk2.tags.put("right", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }   
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_DOWN) == 0) {
                        TMXObject o = c.firstObject("breakable-down");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_DOWN;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-down");
                            chunk2.removeObjectTypes("door-down");
                            chunk2.path += " + down";
                            chunk2.tags.put("down", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                        }
                    }
                }
            }
        }
        
        // combination locks:
        for(int i = 0;i<16;i++) {
            combination_chunks.put(i, new ArrayList<>());
        }
        List<RoomChunk> combination_raw_chunks = new ArrayList<>();
        combination_raw_chunks.add(new RoomChunk("data/jungle/combination0000-1.tmx", 0, "jungle"));
        combination_raw_chunks.add(new RoomChunk("data/jungle/combination0001-1.tmx", 1, "jungle"));
        combination_raw_chunks.add(new RoomChunk("data/jungle/combination1000-1.tmx", 0x8, "jungle"));
        combination_raw_chunks.add(new RoomChunk("data/jungle/combination1001-1.tmx", 0x9, "jungle"));
        for(int type = 0;type<16;type++) {
            for(RoomChunk chunk:combination_raw_chunks) {
                if ((type & PCGWorld.DIRECTION_LEFT) == 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_UP) == 0 && (chunk.type & PCGWorld.DIRECTION_UP) != 0) continue;
                if ((type & PCGWorld.DIRECTION_RIGHT) == 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_DOWN) == 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) != 0) continue;

                RoomChunk chunk2 = chunk.clone();
                chunk2.type = type;

                if ((type & PCGWorld.DIRECTION_LEFT) != 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) == 0) {
                    // open a path to the left:
                    for(int i = 8;i<10;i++) {
                        for(int j = 0;j<2;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-left");
                    chunk2.removeObjectTypes("breakable-left");
                    chunk2.path += " + left";
                    chunk2.tags.put("left", "hole");
                }
                if ((type & PCGWorld.DIRECTION_UP) != 0 && (chunk.type & PCGWorld.DIRECTION_UP) == 0) {
                    // open a path up:
                    for(int i = 0;i<1;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-up");
                    chunk2.removeObjectTypes("breakable-up");
                    chunk2.tags.put("up", "hole");
                    chunk2.path += " + up";
                }
                if ((type & PCGWorld.DIRECTION_RIGHT) != 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                    // open a path right:
                    for(int i = 8;i<10;i++) {
                        for(int j = 14;j<16;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-right");
                    chunk2.removeObjectTypes("breakable-right");
                    chunk2.path += " + right";
                    chunk2.tags.put("right", "hole");
                }
                if ((type & PCGWorld.DIRECTION_DOWN) != 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) == 0) {
                    // open a path down:
                    for(int i = 10;i<12;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-down");
                    chunk2.removeObjectTypes("breakable-down");
                    chunk2.tags.put("down", "hole");
                    chunk2.path += " + down";
                }
                combination_chunks.get(type).add(chunk2);
            }
        }
    }    
        

    public void loadPyramidChunks(boolean simplifyChunks) throws Exception
    {
        // background:
        bg_chunks.add(new RoomChunk("data/pyramid/bg-1.tmx", 0, "pyramid"));
        bg_chunks.add(new RoomChunk("data/pyramid/bg-2.tmx", 0, "pyramid"));
        bg_chunks.add(new RoomChunk("data/pyramid/bg-3.tmx", 0, "pyramid"));

        // foreground:
        for(int i = 0;i<16;i++) {
            fg_chunks.put(i, new ArrayList<>());
        }
        fg_chunks.get(0x0).add(new RoomChunk("data/pyramid/room0000-1.tmx", 0x0, "pyramid"));
        fg_chunks.get(0x0).add(new RoomChunk("data/pyramid/room0000-2.tmx", 0x0, "pyramid"));
        
        fg_chunks.get(0x1).add(new RoomChunk("data/pyramid/room0001-1.tmx", 0x1, "pyramid"));
        fg_chunks.get(0x1).add(new RoomChunk("data/pyramid/room0001-2.tmx", 0x1, "pyramid"));
        fg_chunks.get(0x1).add(new RoomChunk("data/pyramid/room0001-3.tmx", 0x1, "pyramid"));
        
        fg_chunks.get(0x2).add(new RoomChunk("data/pyramid/room0010-1.tmx", 0x2, "pyramid"));
        fg_chunks.get(0x2).add(new RoomChunk("data/pyramid/room0010-2.tmx", 0x2, "pyramid"));
        fg_chunks.get(0x2).add(new RoomChunk("data/pyramid/room0010-3.tmx", 0x2, "pyramid"));
        fg_chunks.get(0x2).add(new RoomChunk("data/pyramid/room0010-4.tmx", 0x2, "pyramid"));
        
        fg_chunks.get(0x3).add(new RoomChunk("data/pyramid/room0011-1.tmx", 0x3, "pyramid"));
        fg_chunks.get(0x3).add(new RoomChunk("data/pyramid/room0011-2.tmx", 0x3, "pyramid"));
        fg_chunks.get(0x3).add(new RoomChunk("data/pyramid/room0011-3.tmx", 0x3, "pyramid"));
        fg_chunks.get(0x3).add(new RoomChunk("data/pyramid/room0011-4.tmx", 0x3, "pyramid"));
        
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-1.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-2.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-3.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-4.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-5.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-6.tmx", 0x4, "pyramid"));
        fg_chunks.get(0x4).add(new RoomChunk("data/pyramid/room0100-7.tmx", 0x4, "pyramid"));
        
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-1.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-2.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-3.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-4.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-5.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-6.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-7.tmx", 0x5, "pyramid"));
        fg_chunks.get(0x5).add(new RoomChunk("data/pyramid/room0101-8.tmx", 0x5, "pyramid"));
        
        fg_chunks.get(0x6).add(new RoomChunk("data/pyramid/room0110-1.tmx", 0x6, "pyramid"));
        fg_chunks.get(0x6).add(new RoomChunk("data/pyramid/room0110-2.tmx", 0x6, "pyramid"));
        fg_chunks.get(0x6).add(new RoomChunk("data/pyramid/room0110-3.tmx", 0x6, "pyramid"));
        fg_chunks.get(0x6).add(new RoomChunk("data/pyramid/room0110-4.tmx", 0x6, "pyramid"));
        
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-1.tmx", 0x7, "pyramid"));
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-2.tmx", 0x7, "pyramid"));
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-3.tmx", 0x7, "pyramid"));
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-4.tmx", 0x7, "pyramid"));
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-5.tmx", 0x7, "pyramid"));
        fg_chunks.get(0x7).add(new RoomChunk("data/pyramid/room0111-6.tmx", 0x7, "pyramid"));

        fg_chunks.get(0x8).add(new RoomChunk("data/pyramid/room1000-1.tmx", 0x8, "pyramid"));
        fg_chunks.get(0x8).add(new RoomChunk("data/pyramid/room1000-2.tmx", 0x8, "pyramid"));
        fg_chunks.get(0x8).add(new RoomChunk("data/pyramid/room1000-3.tmx", 0x8, "pyramid"));
        fg_chunks.get(0x8).add(new RoomChunk("data/pyramid/room1000-4.tmx", 0x8, "pyramid"));
        fg_chunks.get(0x8).add(new RoomChunk("data/pyramid/room1000-5.tmx", 0x8, "pyramid"));

        fg_chunks.get(0x9).add(new RoomChunk("data/pyramid/room1001-1.tmx", 0x9, "pyramid"));
        fg_chunks.get(0x9).add(new RoomChunk("data/pyramid/room1001-2.tmx", 0x9, "pyramid"));
        fg_chunks.get(0x9).add(new RoomChunk("data/pyramid/room1001-3.tmx", 0x9, "pyramid"));
        fg_chunks.get(0x9).add(new RoomChunk("data/pyramid/room1001-4.tmx", 0x9, "pyramid"));

        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-1.tmx", 0xa, "pyramid"));
        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-2.tmx", 0xa, "pyramid"));
        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-3.tmx", 0xa, "pyramid"));
        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-4.tmx", 0xa, "pyramid"));
        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-5.tmx", 0xa, "pyramid"));
        fg_chunks.get(0xa).add(new RoomChunk("data/pyramid/room1010-6.tmx", 0xa, "pyramid"));

        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-1.tmx", 0xb, "pyramid"));
        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-2.tmx", 0xb, "pyramid"));
        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-3.tmx", 0xb, "pyramid"));
        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-4.tmx", 0xb, "pyramid"));
        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-5.tmx", 0xb, "pyramid"));
        fg_chunks.get(0xb).add(new RoomChunk("data/pyramid/room1011-6.tmx", 0xb, "pyramid"));
        
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-1.tmx", 0xc, "pyramid"));
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-2.tmx", 0xc, "pyramid"));
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-3.tmx", 0xc, "pyramid"));
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-4.tmx", 0xc, "pyramid"));
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-5.tmx", 0xc, "pyramid"));
        fg_chunks.get(0xc).add(new RoomChunk("data/pyramid/room1100-6.tmx", 0xc, "pyramid"));

        fg_chunks.get(0xd).add(new RoomChunk("data/pyramid/room1101-1.tmx", 0xd, "pyramid"));
        fg_chunks.get(0xd).add(new RoomChunk("data/pyramid/room1101-2.tmx", 0xd, "pyramid"));
        fg_chunks.get(0xd).add(new RoomChunk("data/pyramid/room1101-3.tmx", 0xd, "pyramid"));
        fg_chunks.get(0xd).add(new RoomChunk("data/pyramid/room1101-4.tmx", 0xd, "pyramid"));
        fg_chunks.get(0xd).add(new RoomChunk("data/pyramid/room1101-5.tmx", 0xd, "pyramid"));

        fg_chunks.get(0xe).add(new RoomChunk("data/pyramid/room1110-1.tmx", 0xe, "pyramid"));
        fg_chunks.get(0xe).add(new RoomChunk("data/pyramid/room1110-2.tmx", 0xe, "pyramid"));
        fg_chunks.get(0xe).add(new RoomChunk("data/pyramid/room1110-3.tmx", 0xe, "pyramid"));
        fg_chunks.get(0xe).add(new RoomChunk("data/pyramid/room1110-4.tmx", 0xe, "pyramid"));

        fg_chunks.get(0xf).add(new RoomChunk("data/pyramid/room1111-1.tmx", 0xf, "pyramid"));
        fg_chunks.get(0xf).add(new RoomChunk("data/pyramid/room1111-2.tmx", 0xf, "pyramid"));
        fg_chunks.get(0xf).add(new RoomChunk("data/pyramid/room1111-3.tmx", 0xf, "pyramid"));
        fg_chunks.get(0xf).add(new RoomChunk("data/pyramid/room1111-4.tmx", 0xf, "pyramid"));
        fg_chunks.get(0xf).add(new RoomChunk("data/pyramid/room1111-5.tmx", 0xf, "pyramid"));
        
        // boss:
        for(int i = 0;i<16;i++) {
            boss_chunks.put(i, new ArrayList<>());
        }
        boss_chunks.get(0x1).add(new RoomChunk("data/pyramid/boss0001-1.tmx", 0x1, "pyramid"));
        boss_chunks.get(0x1).add(new RoomChunk("data/pyramid/boss0001-2.tmx", 0x1, "pyramid"));
        boss_chunks.get(0x2).add(new RoomChunk("data/pyramid/boss0010-1.tmx", 0x2, "pyramid"));
        boss_chunks.get(0x3).add(new RoomChunk("data/pyramid/boss0011-1.tmx", 0x3, "pyramid"));
        boss_chunks.get(0x3).add(new RoomChunk("data/pyramid/boss0011-2.tmx", 0x3, "pyramid"));
        boss_chunks.get(0x4).add(new RoomChunk("data/pyramid/boss0100-1.tmx", 0x4, "pyramid"));
        boss_chunks.get(0x4).add(new RoomChunk("data/pyramid/boss0100-2.tmx", 0x4, "pyramid"));
        boss_chunks.get(0x5).add(new RoomChunk("data/pyramid/boss0101-1.tmx", 0x5, "pyramid"));
        boss_chunks.get(0x5).add(new RoomChunk("data/pyramid/boss0101-2.tmx", 0x5, "pyramid")); 
        boss_chunks.get(0x5).add(new RoomChunk("data/pyramid/boss0101-3.tmx", 0x5, "pyramid"));
        boss_chunks.get(0x5).add(new RoomChunk("data/pyramid/boss0101-4.tmx", 0x5, "pyramid"));
        boss_chunks.get(0x6).add(new RoomChunk("data/pyramid/boss0110-1.tmx", 0x6, "pyramid"));
        boss_chunks.get(0x6).add(new RoomChunk("data/pyramid/boss0110-2.tmx", 0x6, "pyramid"));
        boss_chunks.get(0x7).add(new RoomChunk("data/pyramid/boss0111-1.tmx", 0x7, "pyramid"));
        boss_chunks.get(0x7).add(new RoomChunk("data/pyramid/boss0111-2.tmx", 0x7, "pyramid"));
        boss_chunks.get(0x7).add(new RoomChunk("data/pyramid/boss0111-3.tmx", 0x7, "pyramid"));
        boss_chunks.get(0x7).add(new RoomChunk("data/pyramid/boss0111-4.tmx", 0x7, "pyramid"));
        boss_chunks.get(0x8).add(new RoomChunk("data/pyramid/boss1000-1.tmx", 0x8, "pyramid"));
        boss_chunks.get(0x9).add(new RoomChunk("data/pyramid/boss1001-1.tmx", 0x9, "pyramid"));
        boss_chunks.get(0x9).add(new RoomChunk("data/pyramid/boss1001-2.tmx", 0x9, "pyramid"));
        boss_chunks.get(0xa).add(new RoomChunk("data/pyramid/boss1010-1.tmx", 0xa, "pyramid"));
        boss_chunks.get(0xb).add(new RoomChunk("data/pyramid/boss1011-1.tmx", 0xb, "pyramid"));
        boss_chunks.get(0xc).add(new RoomChunk("data/pyramid/boss1100-1.tmx", 0xc, "pyramid"));
        boss_chunks.get(0xc).add(new RoomChunk("data/pyramid/boss1100-2.tmx", 0xc, "pyramid"));
        boss_chunks.get(0xd).add(new RoomChunk("data/pyramid/boss1101-1.tmx", 0xd, "pyramid"));
        boss_chunks.get(0xd).add(new RoomChunk("data/pyramid/boss1101-2.tmx", 0xd, "pyramid"));
        boss_chunks.get(0xd).add(new RoomChunk("data/pyramid/boss1101-3.tmx", 0xd, "pyramid"));
        boss_chunks.get(0xe).add(new RoomChunk("data/pyramid/boss1110-1.tmx", 0xe, "pyramid"));
        boss_chunks.get(0xe).add(new RoomChunk("data/pyramid/boss1110-2.tmx", 0xe, "pyramid"));
        boss_chunks.get(0xf).add(new RoomChunk("data/pyramid/boss1111-1.tmx", 0xf, "pyramid"));
        boss_chunks.get(0xf).add(new RoomChunk("data/pyramid/boss1111-2.tmx", 0xf, "pyramid"));
        boss_chunks.get(0xf).add(new RoomChunk("data/pyramid/boss1111-3.tmx", 0xf, "pyramid"));
        boss_chunks.get(0xf).add(new RoomChunk("data/pyramid/boss1111-4.tmx", 0xf, "pyramid"));
        
        // block puzzles:
        for(int i = 0;i<16;i++) {
            block_chunks.put(i, new ArrayList<>());
        }
        {
            List<RoomChunk> l = new ArrayList<>();
            l.add(new RoomChunk("data/pyramid/block0011-1.tmx", 0x3, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0011-2.tmx", 0x3, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0101-1.tmx", 0x5, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0101-2.tmx", 0x5, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0101-3.tmx", 0x5, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0101-4.tmx", 0x5, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0110-1.tmx", 0x6, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0110-2.tmx", 0x6, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block0111-1.tmx", 0x7, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block1001-1.tmx", 0x9, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block1001-2.tmx", 0x9, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block1010-1.tmx", 0xa, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block1100-1.tmx", 0xc, "pyramid"));
            l.add(new RoomChunk("data/pyramid/block1100-2.tmx", 0xc, "pyramid"));

            for(RoomChunk c2:l) {
                block_chunks.get(c2.type).add(c2);
                List<RoomChunk> current = new ArrayList<>();
                List<RoomChunk> current2 = new ArrayList<>();
                current.add(c2);
                current2.add(c2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_LEFT) == 0) {
                        TMXObject o = c.firstObject("breakable-left");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_LEFT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-left");
                            chunk2.removeObjectTypes("door-left");
                            chunk2.path += " + left";
                            chunk2.tags.put("left", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_UP) == 0) {
                        TMXObject o = c.firstObject("breakable-up");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_UP;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-up");
                            chunk2.removeObjectTypes("door-up");
                            chunk2.path += " + up";
                            chunk2.tags.put("up", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                        TMXObject o = c.firstObject("breakable-right");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_RIGHT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-right");
                            chunk2.removeObjectTypes("door-right");
                            chunk2.path += " + right";
                            chunk2.tags.put("right", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }   
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_DOWN) == 0) {
                        TMXObject o = c.firstObject("breakable-down");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_DOWN;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-down");
                            chunk2.removeObjectTypes("door-down");
                            chunk2.path += " + down";
                            chunk2.tags.put("down", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                        }
                    }
                }
            }
        }
        
        // combination locks:
        for(int i = 0;i<16;i++) {
            combination_chunks.put(i, new ArrayList<>());
        }
        
        List<RoomChunk> combination_raw_chunks = new ArrayList<>();
        combination_raw_chunks.add(new RoomChunk("data/pyramid/combination0000-1.tmx", 0, "pyramid"));
        combination_raw_chunks.add(new RoomChunk("data/pyramid/combination0001-1.tmx", 0x1, "pyramid"));
        combination_raw_chunks.add(new RoomChunk("data/pyramid/combination0100-1.tmx", 0x4, "pyramid"));
        combination_raw_chunks.add(new RoomChunk("data/pyramid/combination0101-1.tmx", 0x5, "pyramid"));
        for(int type = 0;type<16;type++) {
            for(RoomChunk chunk:combination_raw_chunks) {
                if ((type & PCGWorld.DIRECTION_LEFT) == 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_UP) == 0 && (chunk.type & PCGWorld.DIRECTION_UP) != 0) continue;
                if ((type & PCGWorld.DIRECTION_RIGHT) == 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_DOWN) == 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) != 0) continue;

                RoomChunk chunk2 = chunk.clone();
                chunk2.type = type;

                if ((type & PCGWorld.DIRECTION_LEFT) != 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) == 0) {
                    // open a path to the left:
                    for(int i = 7;i<10;i++) {
                        for(int j = 0;j<3;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-left");
                    chunk2.removeObjectTypes("breakable-left");
                    chunk2.path += " + left";
                    chunk2.tags.put("left", "hole");
                }
                if ((type & PCGWorld.DIRECTION_UP) != 0 && (chunk.type & PCGWorld.DIRECTION_UP) == 0) {
                    // open a path up:
                    for(int i = 0;i<1;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-up");
                    chunk2.removeObjectTypes("breakable-up");
                    chunk2.tags.put("up", "hole");
                    chunk2.path += " + up";
                }
                if ((type & PCGWorld.DIRECTION_RIGHT) != 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                    // open a path right:
                    for(int i = 7;i<10;i++) {
                        for(int j = 13;j<16;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-right");
                    chunk2.removeObjectTypes("breakable-right");
                    chunk2.path += " + right";
                    chunk2.tags.put("right", "hole");
                }
                if ((type & PCGWorld.DIRECTION_DOWN) != 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) == 0) {
                    // open a path down:
                    for(int i = 10;i<12;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-down");
                    chunk2.removeObjectTypes("breakable-down");
                    chunk2.tags.put("down", "hole");
                    chunk2.path += " + down";
                }
                combination_chunks.get(type).add(chunk2);
            }
        }
    }

    
    public void loadCaveChunks(boolean simplifyChunks) throws Exception
    {
        // background:
        bg_chunks.add(new RoomChunk("data/caves/bg-1.tmx", 0, "caves"));
        bg_chunks.add(new RoomChunk("data/caves/bg-2.tmx", 0, "caves"));
        bg_chunks.add(new RoomChunk("data/caves/bg-3.tmx", 0, "caves"));

        // foreground:
        for(int i = 0;i<16;i++) {
            fg_chunks.put(i, new ArrayList<>());
        }
        fg_chunks.get(0x0).add(new RoomChunk("data/caves/room0000-1.tmx", 0x0, "caves"));

        fg_chunks.get(0x1).add(new RoomChunk("data/caves/room0001-1.tmx", 0x1, "caves"));
        fg_chunks.get(0x1).add(new RoomChunk("data/caves/room0001-2.tmx", 0x1, "caves"));

        fg_chunks.get(0x2).add(new RoomChunk("data/caves/room0010-1.tmx", 0x2, "caves"));
        fg_chunks.get(0x2).add(new RoomChunk("data/caves/room0010-2.tmx", 0x2, "caves"));
        fg_chunks.get(0x2).add(new RoomChunk("data/caves/room0010-3.tmx", 0x2, "caves"));
        fg_chunks.get(0x2).add(new RoomChunk("data/caves/room0010-4.tmx", 0x2, "caves"));
        fg_chunks.get(0x2).add(new RoomChunk("data/caves/room0010-5.tmx", 0x2, "caves"));

        fg_chunks.get(0x3).add(new RoomChunk("data/caves/room0011-1.tmx", 0x3, "caves"));
        fg_chunks.get(0x3).add(new RoomChunk("data/caves/room0011-2.tmx", 0x3, "caves"));
        fg_chunks.get(0x3).add(new RoomChunk("data/caves/room0011-3.tmx", 0x3, "caves"));
        fg_chunks.get(0x3).add(new RoomChunk("data/caves/room0011-4.tmx", 0x3, "caves"));

        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-1.tmx", 0x4, "caves"));
        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-2.tmx", 0x4, "caves"));
        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-3.tmx", 0x4, "caves"));
        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-4.tmx", 0x4, "caves"));
        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-5.tmx", 0x4, "caves"));
        fg_chunks.get(0x4).add(new RoomChunk("data/caves/room0100-6.tmx", 0x4, "caves"));

        fg_chunks.get(0x5).add(new RoomChunk("data/caves/room0101-1.tmx", 0x5, "caves"));
        fg_chunks.get(0x5).add(new RoomChunk("data/caves/room0101-2.tmx", 0x5, "caves"));
        fg_chunks.get(0x5).add(new RoomChunk("data/caves/room0101-3.tmx", 0x5, "caves"));
        fg_chunks.get(0x5).add(new RoomChunk("data/caves/room0101-4.tmx", 0x5, "caves"));

        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-1.tmx", 0x6, "caves"));
        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-2.tmx", 0x6, "caves"));
        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-3.tmx", 0x6, "caves"));
        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-4.tmx", 0x6, "caves"));
        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-5.tmx", 0x6, "caves"));
        fg_chunks.get(0x6).add(new RoomChunk("data/caves/room0110-6.tmx", 0x6, "caves"));

        fg_chunks.get(0x7).add(new RoomChunk("data/caves/room0111-1.tmx", 0x7, "caves"));
        fg_chunks.get(0x7).add(new RoomChunk("data/caves/room0111-2.tmx", 0x7, "caves"));
        fg_chunks.get(0x7).add(new RoomChunk("data/caves/room0111-3.tmx", 0x7, "caves"));
        fg_chunks.get(0x7).add(new RoomChunk("data/caves/room0111-4.tmx", 0x7, "caves"));
        fg_chunks.get(0x7).add(new RoomChunk("data/caves/room0111-5.tmx", 0x7, "caves"));

        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-1.tmx", 0x8, "caves"));
        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-2.tmx", 0x8, "caves"));
        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-3.tmx", 0x8, "caves"));
        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-4.tmx", 0x8, "caves"));
        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-5.tmx", 0x8, "caves"));
        fg_chunks.get(0x8).add(new RoomChunk("data/caves/room1000-6.tmx", 0x8, "caves"));

        fg_chunks.get(0x9).add(new RoomChunk("data/caves/room1001-1.tmx", 0x9, "caves"));
        fg_chunks.get(0x9).add(new RoomChunk("data/caves/room1001-2.tmx", 0x9, "caves"));
        fg_chunks.get(0x9).add(new RoomChunk("data/caves/room1001-3.tmx", 0x9, "caves"));
        fg_chunks.get(0x9).add(new RoomChunk("data/caves/room1001-4.tmx", 0x9, "caves"));
        fg_chunks.get(0x9).add(new RoomChunk("data/caves/room1001-5.tmx", 0x9, "caves"));

        fg_chunks.get(0xa).add(new RoomChunk("data/caves/room1010-1.tmx", 0xa, "caves"));
        fg_chunks.get(0xa).add(new RoomChunk("data/caves/room1010-2.tmx", 0xa, "caves"));
        fg_chunks.get(0xa).add(new RoomChunk("data/caves/room1010-3.tmx", 0xa, "caves"));
        fg_chunks.get(0xa).add(new RoomChunk("data/caves/room1010-4.tmx", 0xa, "caves"));
        fg_chunks.get(0xa).add(new RoomChunk("data/caves/room1010-5.tmx", 0xa, "caves"));

        fg_chunks.get(0xb).add(new RoomChunk("data/caves/room1011-1.tmx", 0xb, "caves"));
        fg_chunks.get(0xb).add(new RoomChunk("data/caves/room1011-2.tmx", 0xb, "caves"));
        fg_chunks.get(0xb).add(new RoomChunk("data/caves/room1011-3.tmx", 0xb, "caves"));
        fg_chunks.get(0xb).add(new RoomChunk("data/caves/room1011-4.tmx", 0xb, "caves"));

        fg_chunks.get(0xc).add(new RoomChunk("data/caves/room1100-1.tmx", 0xc, "caves"));
        fg_chunks.get(0xc).add(new RoomChunk("data/caves/room1100-2.tmx", 0xc, "caves"));
        fg_chunks.get(0xc).add(new RoomChunk("data/caves/room1100-3.tmx", 0xc, "caves"));
        fg_chunks.get(0xc).add(new RoomChunk("data/caves/room1100-4.tmx", 0xc, "caves"));
        fg_chunks.get(0xc).add(new RoomChunk("data/caves/room1100-5.tmx", 0xc, "caves"));

        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-1.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-2.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-3.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-4.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-5.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-6.tmx", 0xd, "caves"));
        fg_chunks.get(0xd).add(new RoomChunk("data/caves/room1101-7.tmx", 0xd, "caves"));

        fg_chunks.get(0xe).add(new RoomChunk("data/caves/room1110-1.tmx", 0xe, "caves"));
        fg_chunks.get(0xe).add(new RoomChunk("data/caves/room1110-2.tmx", 0xe, "caves"));
        fg_chunks.get(0xe).add(new RoomChunk("data/caves/room1110-3.tmx", 0xe, "caves"));
        fg_chunks.get(0xe).add(new RoomChunk("data/caves/room1110-4.tmx", 0xe, "caves"));
        fg_chunks.get(0xe).add(new RoomChunk("data/caves/room1110-5.tmx", 0xe, "caves"));

        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-1.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-2.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-3.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-4.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-5.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-6.tmx", 0xf, "caves"));
        fg_chunks.get(0xf).add(new RoomChunk("data/caves/room1111-7.tmx", 0xf, "caves"));

        // boss:
        for(int i = 0;i<16;i++) {
            boss_chunks.put(i, new ArrayList<>());
        }

        // block puzzles:
        for(int i = 0;i<16;i++) {
            block_chunks.put(i, new ArrayList<>());
        }
        {
            List<RoomChunk> l = new ArrayList<>();
            l.add(new RoomChunk("data/caves/block0011-1.tmx", 0x3, "caves"));
            l.add(new RoomChunk("data/caves/block0011-2.tmx", 0x3, "caves"));
            l.add(new RoomChunk("data/caves/block0101-1.tmx", 0x5, "caves"));
            l.add(new RoomChunk("data/caves/block0101-2.tmx", 0x5, "caves"));
            l.add(new RoomChunk("data/caves/block0101-3.tmx", 0x5, "caves"));
            l.add(new RoomChunk("data/caves/block0101-4.tmx", 0x5, "caves"));
            l.add(new RoomChunk("data/caves/block0110-1.tmx", 0x6, "caves"));
            l.add(new RoomChunk("data/caves/block0110-2.tmx", 0x6, "caves"));
            l.add(new RoomChunk("data/caves/block0111-1.tmx", 0x7, "caves"));
            l.add(new RoomChunk("data/caves/block1001-1.tmx", 0x9, "caves"));
            l.add(new RoomChunk("data/caves/block1001-2.tmx", 0x9, "caves"));
            l.add(new RoomChunk("data/caves/block1010-1.tmx", 0xa, "caves"));
            l.add(new RoomChunk("data/caves/block1010-2.tmx", 0xa, "caves"));
            l.add(new RoomChunk("data/caves/block1100-1.tmx", 0xc, "caves"));
            l.add(new RoomChunk("data/caves/block1100-2.tmx", 0xc, "caves"));
//
            for(RoomChunk c2:l) {
                block_chunks.get(c2.type).add(c2);
                List<RoomChunk> current = new ArrayList<>();
                List<RoomChunk> current2 = new ArrayList<>();
                current.add(c2);
                current2.add(c2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_LEFT) == 0) {
                        TMXObject o = c.firstObject("breakable-left");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_LEFT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-left");
                            chunk2.removeObjectTypes("door-left");
                            chunk2.path += " + left";
                            chunk2.tags.put("left", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_UP) == 0) {
                        TMXObject o = c.firstObject("breakable-up");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_UP;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-up");
                            chunk2.removeObjectTypes("door-up");
                            chunk2.path += " + up";
                            chunk2.tags.put("up", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                        TMXObject o = c.firstObject("breakable-right");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_RIGHT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-right");
                            chunk2.removeObjectTypes("door-right");
                            chunk2.path += " + right";
                            chunk2.tags.put("right", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }   
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_DOWN) == 0) {
                        TMXObject o = c.firstObject("breakable-down");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_DOWN;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-down");
                            chunk2.removeObjectTypes("door-down");
                            chunk2.path += " + down";
                            chunk2.tags.put("down", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                        }
                    }
                }
            }
        }
        
        // combination locks:
        for(int i = 0;i<16;i++) {
            combination_chunks.put(i, new ArrayList<>());
        }
        
        List<RoomChunk> combination_raw_chunks = new ArrayList<>();
        combination_raw_chunks.add(new RoomChunk("data/caves/combination0000-1.tmx", 0, "caves"));
        combination_raw_chunks.add(new RoomChunk("data/caves/combination0001-1.tmx", 0x1, "caves"));
        combination_raw_chunks.add(new RoomChunk("data/caves/combination0100-1.tmx", 0x4, "caves"));
        combination_raw_chunks.add(new RoomChunk("data/caves/combination0101-1.tmx", 0x5, "caves"));
        for(int type = 0;type<16;type++) {
            for(RoomChunk chunk:combination_raw_chunks) {
                if ((type & PCGWorld.DIRECTION_LEFT) == 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_UP) == 0 && (chunk.type & PCGWorld.DIRECTION_UP) != 0) continue;
                if ((type & PCGWorld.DIRECTION_RIGHT) == 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_DOWN) == 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) != 0) continue;

                RoomChunk chunk2 = chunk.clone();
                chunk2.type = type;

                if ((type & PCGWorld.DIRECTION_LEFT) != 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) == 0) {
                    // open a path to the left:
                    for(int i = 7;i<10;i++) {
                        for(int j = 0;j<3;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-left");
                    chunk2.removeObjectTypes("breakable-left");
                    chunk2.path += " + left";
                    chunk2.tags.put("left", "hole");
                }
                if ((type & PCGWorld.DIRECTION_UP) != 0 && (chunk.type & PCGWorld.DIRECTION_UP) == 0) {
                    // open a path up:
                    for(int i = 0;i<1;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-up");
                    chunk2.removeObjectTypes("breakable-up");
                    chunk2.tags.put("up", "hole");
                    chunk2.path += " + up";
                }
                if ((type & PCGWorld.DIRECTION_RIGHT) != 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                    // open a path right:
                    for(int i = 7;i<10;i++) {
                        for(int j = 13;j<16;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-right");
                    chunk2.removeObjectTypes("breakable-right");
                    chunk2.path += " + right";
                    chunk2.tags.put("right", "hole");
                }
                if ((type & PCGWorld.DIRECTION_DOWN) != 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) == 0) {
                    // open a path down:
                    for(int i = 10;i<12;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-down");
                    chunk2.removeObjectTypes("breakable-down");
                    chunk2.tags.put("down", "hole");
                    chunk2.path += " + down";
                }
                combination_chunks.get(type).add(chunk2);
            }
        }
    }
    
    
    public void loadXibalbaChunks(boolean simplifyChunks) throws Exception
    {
        // background:
        bg_chunks.add(new RoomChunk("data/pyramid/bg-1.tmx", 0, "pyramid"));
        bg_chunks.add(new RoomChunk("data/pyramid/bg-2.tmx", 0, "pyramid"));
        bg_chunks.add(new RoomChunk("data/pyramid/bg-3.tmx", 0, "pyramid"));

        // foreground:
        for(int i = 0;i<16;i++) {
            fg_chunks.put(i, new ArrayList<>());
        }
        fg_chunks.get(0x0).add(new RoomChunk("data/xibalba/room0000-1.tmx", 0x0, "xibalba"));
        
        fg_chunks.get(0x1).add(new RoomChunk("data/xibalba/room0001-1.tmx", 0x1, "xibalba"));
        
        fg_chunks.get(0x2).add(new RoomChunk("data/xibalba/room0010-1.tmx", 0x2, "xibalba"));
        
        fg_chunks.get(0x3).add(new RoomChunk("data/xibalba/room0011-1.tmx", 0x3, "xibalba"));
        
        fg_chunks.get(0x4).add(new RoomChunk("data/xibalba/room0100-1.tmx", 0x4, "xibalba"));
        
        fg_chunks.get(0x5).add(new RoomChunk("data/xibalba/room0101-1.tmx", 0x5, "xibalba"));
        
        fg_chunks.get(0x6).add(new RoomChunk("data/xibalba/room0110-1.tmx", 0x6, "xibalba"));
        
        fg_chunks.get(0x7).add(new RoomChunk("data/xibalba/room0111-1.tmx", 0x7, "xibalba"));

        fg_chunks.get(0x8).add(new RoomChunk("data/xibalba/room1000-1.tmx", 0x8, "xibalba"));

        fg_chunks.get(0x9).add(new RoomChunk("data/xibalba/room1001-1.tmx", 0x9, "xibalba"));

        fg_chunks.get(0xa).add(new RoomChunk("data/xibalba/room1010-1.tmx", 0xa, "xibalba"));

        fg_chunks.get(0xb).add(new RoomChunk("data/xibalba/room1011-1.tmx", 0xb, "xibalba"));
        
        fg_chunks.get(0xc).add(new RoomChunk("data/xibalba/room1100-1.tmx", 0xc, "xibalba"));

        fg_chunks.get(0xd).add(new RoomChunk("data/xibalba/room1101-1.tmx", 0xd, "xibalba"));

        fg_chunks.get(0xe).add(new RoomChunk("data/xibalba/room1110-1.tmx", 0xe, "xibalba"));

        fg_chunks.get(0xf).add(new RoomChunk("data/xibalba/room1111-1.tmx", 0xf, "xibalba"));
        
        // boss:
        for(int i = 0;i<16;i++) {
            boss_chunks.put(i, new ArrayList<>());
        }
//        boss_chunks.get(0x1).add(new RoomChunk("data/xibalba/boss0001-1.tmx", 0x1, "xibalba"));
//        boss_chunks.get(0x1).add(new RoomChunk("data/xibalba/boss0001-2.tmx", 0x1, "xibalba"));
//        boss_chunks.get(0x2).add(new RoomChunk("data/xibalba/boss0010-1.tmx", 0x2, "xibalba"));
//        boss_chunks.get(0x3).add(new RoomChunk("data/xibalba/boss0011-1.tmx", 0x3, "xibalba"));
//        boss_chunks.get(0x3).add(new RoomChunk("data/xibalba/boss0011-2.tmx", 0x3, "xibalba"));
//        boss_chunks.get(0x4).add(new RoomChunk("data/xibalba/boss0100-1.tmx", 0x4, "xibalba"));
//        boss_chunks.get(0x4).add(new RoomChunk("data/xibalba/boss0100-2.tmx", 0x4, "xibalba"));
//        boss_chunks.get(0x5).add(new RoomChunk("data/xibalba/boss0101-1.tmx", 0x5, "xibalba"));
//        boss_chunks.get(0x5).add(new RoomChunk("data/xibalba/boss0101-2.tmx", 0x5, "xibalba")); 
//        boss_chunks.get(0x5).add(new RoomChunk("data/xibalba/boss0101-3.tmx", 0x5, "xibalba"));
//        boss_chunks.get(0x5).add(new RoomChunk("data/xibalba/boss0101-4.tmx", 0x5, "xibalba"));
//        boss_chunks.get(0x6).add(new RoomChunk("data/xibalba/boss0110-1.tmx", 0x6, "xibalba"));
//        boss_chunks.get(0x6).add(new RoomChunk("data/xibalba/boss0110-2.tmx", 0x6, "xibalba"));
//        boss_chunks.get(0x7).add(new RoomChunk("data/xibalba/boss0111-1.tmx", 0x7, "xibalba"));
//        boss_chunks.get(0x7).add(new RoomChunk("data/xibalba/boss0111-2.tmx", 0x7, "xibalba"));
//        boss_chunks.get(0x7).add(new RoomChunk("data/xibalba/boss0111-3.tmx", 0x7, "xibalba"));
//        boss_chunks.get(0x7).add(new RoomChunk("data/xibalba/boss0111-4.tmx", 0x7, "xibalba"));
//        boss_chunks.get(0x8).add(new RoomChunk("data/xibalba/boss1000-1.tmx", 0x8, "xibalba"));
//        boss_chunks.get(0x9).add(new RoomChunk("data/xibalba/boss1001-1.tmx", 0x9, "xibalba"));
//        boss_chunks.get(0x9).add(new RoomChunk("data/xibalba/boss1001-2.tmx", 0x9, "xibalba"));
//        boss_chunks.get(0xa).add(new RoomChunk("data/xibalba/boss1010-1.tmx", 0xa, "xibalba"));
//        boss_chunks.get(0xb).add(new RoomChunk("data/xibalba/boss1011-1.tmx", 0xb, "xibalba"));
//        boss_chunks.get(0xc).add(new RoomChunk("data/xibalba/boss1100-1.tmx", 0xc, "xibalba"));
//        boss_chunks.get(0xc).add(new RoomChunk("data/xibalba/boss1100-2.tmx", 0xc, "xibalba"));
//        boss_chunks.get(0xd).add(new RoomChunk("data/xibalba/boss1101-1.tmx", 0xd, "xibalba"));
//        boss_chunks.get(0xd).add(new RoomChunk("data/xibalba/boss1101-2.tmx", 0xd, "xibalba"));
//        boss_chunks.get(0xd).add(new RoomChunk("data/xibalba/boss1101-3.tmx", 0xd, "xibalba"));
//        boss_chunks.get(0xe).add(new RoomChunk("data/xibalba/boss1110-1.tmx", 0xe, "xibalba"));
//        boss_chunks.get(0xe).add(new RoomChunk("data/xibalba/boss1110-2.tmx", 0xe, "xibalba"));
//        boss_chunks.get(0xf).add(new RoomChunk("data/xibalba/boss1111-1.tmx", 0xf, "xibalba"));
//        boss_chunks.get(0xf).add(new RoomChunk("data/xibalba/boss1111-2.tmx", 0xf, "xibalba"));
//        boss_chunks.get(0xf).add(new RoomChunk("data/xibalba/boss1111-3.tmx", 0xf, "xibalba"));
//        boss_chunks.get(0xf).add(new RoomChunk("data/xibalba/boss1111-4.tmx", 0xf, "xibalba"));
        
        // block puzzles:
        for(int i = 0;i<16;i++) {
            block_chunks.put(i, new ArrayList<>());
        }
        {
            List<RoomChunk> l = new ArrayList<>();
//            l.add(new RoomChunk("data/xibalba/block0011-1.tmx", 0x3, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0011-2.tmx", 0x3, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0101-1.tmx", 0x5, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0101-2.tmx", 0x5, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0101-3.tmx", 0x5, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0101-4.tmx", 0x5, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0110-1.tmx", 0x6, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0110-2.tmx", 0x6, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block0111-1.tmx", 0x7, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block1001-1.tmx", 0x9, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block1001-2.tmx", 0x9, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block1010-1.tmx", 0xa, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block1100-1.tmx", 0xc, "xibalba"));
//            l.add(new RoomChunk("data/xibalba/block1100-2.tmx", 0xc, "xibalba"));

            for(RoomChunk c2:l) {
                block_chunks.get(c2.type).add(c2);
                List<RoomChunk> current = new ArrayList<>();
                List<RoomChunk> current2 = new ArrayList<>();
                current.add(c2);
                current2.add(c2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_LEFT) == 0) {
                        TMXObject o = c.firstObject("breakable-left");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_LEFT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-left");
                            chunk2.removeObjectTypes("door-left");
                            chunk2.path += " + left";
                            chunk2.tags.put("left", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_UP) == 0) {
                        TMXObject o = c.firstObject("breakable-up");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_UP;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-up");
                            chunk2.removeObjectTypes("door-up");
                            chunk2.path += " + up";
                            chunk2.tags.put("up", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                        TMXObject o = c.firstObject("breakable-right");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_RIGHT;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-right");
                            chunk2.removeObjectTypes("door-right");
                            chunk2.path += " + right";
                            chunk2.tags.put("right", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                            current2.add(chunk2);
                        }
                    }
                }   
                current.clear();
                current.addAll(current2);
                for(RoomChunk c:current) {
                    if ((c.type & PCGWorld.DIRECTION_DOWN) == 0) {
                        TMXObject o = c.firstObject("breakable-down");
                        if (o != null) {
                            RoomChunk chunk2 = c.clone();
                            chunk2.type |= PCGWorld.DIRECTION_DOWN;
                            for(int i = 0;i<o.dy/8;i++) {
                                for(int j = 0;j<o.dx/8;j++) {
                                    chunk2.tiles[(o.x/8) + j][(o.y/8) + i] = 0;
                                }
                            }
                            chunk2.removeObjectTypes("breakable-down");
                            chunk2.removeObjectTypes("door-down");
                            chunk2.path += " + down";
                            chunk2.tags.put("down", "hole");
                            block_chunks.get(chunk2.type).add(chunk2);
                        }
                    }
                }
            }
        }
        
        // combination locks:
        for(int i = 0;i<16;i++) {
            combination_chunks.put(i, new ArrayList<>());
        }
        
        List<RoomChunk> combination_raw_chunks = new ArrayList<>();
//        combination_raw_chunks.add(new RoomChunk("data/xibalba/combination0000-1.tmx", 0, "xibalba"));
//        combination_raw_chunks.add(new RoomChunk("data/xibalba/combination0001-1.tmx", 0x1, "xibalba"));
//        combination_raw_chunks.add(new RoomChunk("data/xibalba/combination0100-1.tmx", 0x4, "xibalba"));
//        combination_raw_chunks.add(new RoomChunk("data/xibalba/combination0101-1.tmx", 0x5, "xibalba"));
        for(int type = 0;type<16;type++) {
            for(RoomChunk chunk:combination_raw_chunks) {
                if ((type & PCGWorld.DIRECTION_LEFT) == 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_UP) == 0 && (chunk.type & PCGWorld.DIRECTION_UP) != 0) continue;
                if ((type & PCGWorld.DIRECTION_RIGHT) == 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) != 0) continue;
                if ((type & PCGWorld.DIRECTION_DOWN) == 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) != 0) continue;

                RoomChunk chunk2 = chunk.clone();
                chunk2.type = type;

                if ((type & PCGWorld.DIRECTION_LEFT) != 0 && (chunk.type & PCGWorld.DIRECTION_LEFT) == 0) {
                    // open a path to the left:
                    for(int i = 7;i<10;i++) {
                        for(int j = 0;j<3;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-left");
                    chunk2.removeObjectTypes("breakable-left");
                    chunk2.path += " + left";
                    chunk2.tags.put("left", "hole");
                }
                if ((type & PCGWorld.DIRECTION_UP) != 0 && (chunk.type & PCGWorld.DIRECTION_UP) == 0) {
                    // open a path up:
                    for(int i = 0;i<1;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-up");
                    chunk2.removeObjectTypes("breakable-up");
                    chunk2.tags.put("up", "hole");
                    chunk2.path += " + up";
                }
                if ((type & PCGWorld.DIRECTION_RIGHT) != 0 && (chunk.type & PCGWorld.DIRECTION_RIGHT) == 0) {
                    // open a path right:
                    for(int i = 7;i<10;i++) {
                        for(int j = 13;j<16;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-right");
                    chunk2.removeObjectTypes("breakable-right");
                    chunk2.path += " + right";
                    chunk2.tags.put("right", "hole");
                }
                if ((type & PCGWorld.DIRECTION_DOWN) != 0 && (chunk.type & PCGWorld.DIRECTION_DOWN) == 0) {
                    // open a path down:
                    for(int i = 10;i<12;i++) {
                        for(int j = 6;j<10;j++) {
                            chunk2.tiles[j][i] = 0;
                        }
                    }
                    chunk2.removeObjectTypes("door-down");
                    chunk2.removeObjectTypes("breakable-down");
                    chunk2.tags.put("down", "hole");
                    chunk2.path += " + down";
                }
                combination_chunks.get(type).add(chunk2);
            }
        }
    }    
    

    public boolean mergeAreaRooms(Area a, MSXRandom r)
    {
        int w = a.width;
        int h = a.height;
                
        // Ensure that the "calendar stone" and "teleporter" rooms is not merged with anything:
        if (a.ID == 0) {  // "the jungle"
            for(int i = 0;i<h;i++) {
                for(int j = 0;j<w;j++) {
                    if (a.tags[j][i] != null && a.tags[j][i].contains("start")) {
                        if (a.tags[j][i].size() > 1) {
                            System.err.println("More than one tag on the start room! " + a.tags[j][i]);
                            return false;
                        }
                        a.rooms[j][i] = START_ROOM_ID;
                    }
                }
            }
        }        
        if (a.ID == 3) {  // "the confluence"
            for(int i = 0;i<h;i++) {
                for(int j = 0;j<w;j++) {
                    if (a.tags[j][i] != null && a.tags[j][i].contains("ending")) {
                        if (a.tags[j][i].size() > 1) {
                            System.err.println("More than one tag on the ending room! " + a.tags[j][i]);
                            return false;
                        }
                        a.rooms[j][i] = CALENDAR_ROOM_ID;
                    }
                }
            }
        }
        if (a.ID == 9) {  // "atlantis"
            for(int i = 0;i<h;i++) {
                for(int j = 0;j<w;j++) {
                    if (a.tags[j][i] != null && a.tags[j][i].contains("teleporter-atlantis")) {
                        if (a.tags[j][i].size() > 1) {
                            System.err.println("More than one tag on the teleporter room! " + a.tags[j][i]);
                            return false;
                        }
                        a.rooms[j][i] = TELEPORTER_ROOM_ID;
                    }
                }
            }
        }

        // reset room IDs:
        int newID = 0;
        boolean processed[][] = new boolean[w][h];
        for(int i = 0;i<h;i++) {
            for(int j = 0;j<w;j++) {
                if (a.divisionIDs[j][i] != 0 && a.rooms[j][i] < SPECIAL_ROOM_IDS_START) {
                    a.rooms[j][i] = newID;
                    newID++;
                    processed[j][i] = false;
                } else if (a.rooms[j][i] < SPECIAL_ROOM_IDS_START) {
                    a.rooms[j][i] = -1;
                    processed[j][i] = false;
                } else {
                    processed[j][i] = true;
                }
            }
        }
        for(int i = 0;i<h;i++) {
            for(int j = 0;j<w;j++) {
                if ( a.rooms[j][i] >= SPECIAL_ROOM_IDS_START) {
                    processed[j][i] = true;
                } else if (a.rooms[j][i] >= 0 && a.rooms[j][i] < SPECIAL_ROOM_IDS_START && !processed[j][i]) {
                    processed[j][i] = true;
                    // Try merging to the right:
                    if (j + 1 < w && a.rooms[j + 1][i] < SPECIAL_ROOM_IDS_START) {
                        if (a.divisionIDs[j][i] == a.divisionIDs[j + 1][i] &&
                            !processed[j + 1][i]) {
                            // we can make a 2x1:
                            a.rooms[j + 1][i] =  a.rooms[j][i];
                            processed[j + 1][i] = true;
                            
                            // Try doing a 2x2 room:
                            if (i + 1 < h && a.rooms[j][i + 1] < SPECIAL_ROOM_IDS_START) {
                                if (a.divisionIDs[j][i] == a.divisionIDs[j][i + 1] &&
                                    a.divisionIDs[j][i] == a.divisionIDs[j + 1][i + 1] &&
                                    !processed[j][i + 1] &&
                                    !processed[j + 1][i + 1]) {
                                    // We can make a 2x2 room!
                                    a.rooms[j][i + 1] =  a.rooms[j][i];
                                    a.rooms[j + 1][i + 1] =  a.rooms[j][i];
                                    processed[j][i + 1] = true;
                                    processed[j + 1][i + 1] = true;
                                    continue;
                                }                                
                            }
                            
                            // Try doing a 3x1 room:
                            if (j + 2 < w && a.rooms[j + 2][i] < SPECIAL_ROOM_IDS_START) {
                                if (a.divisionIDs[j][i] == a.divisionIDs[j + 2][i] &&
                                    !processed[j + 2][i]) {
                                    // we can make a 3x1:
                                    a.rooms[j + 2][i] =  a.rooms[j][i];
                                    processed[j + 2][i] = true;
                                    if (j + 3 < w && a.rooms[j + 3][i] < SPECIAL_ROOM_IDS_START) {
                                        if (a.divisionIDs[j][i] == a.divisionIDs[j + 3][i] &&
                                            !processed[j + 3][i]) {
                                            // we can make a 4x1:
                                            a.rooms[j + 3][i] =  a.rooms[j][i];
                                            processed[j + 3][i] = true;

                                        }
                                    }
                                }
                            }
                            continue;
                        }
                    }
                    // Try to merge down:
                    if (i + 1 < h && a.rooms[j][i + 1] < SPECIAL_ROOM_IDS_START) {
                        if (a.divisionIDs[j][i] == a.divisionIDs[j][i + 1] &&
                            !processed[j][i + 1]) {
                            // we can make a 1x2:
                            a.rooms[j][i + 1] =  a.rooms[j][i];
                            processed[j][i + 1] = true;
                            
                            // Try doing a 1x3 room:
                            if (i + 2 < h && a.rooms[j][i + 2] < SPECIAL_ROOM_IDS_START) {
                                if (a.divisionIDs[j][i] == a.divisionIDs[j][i + 2] &&
                                    !processed[j][i + 2]) {
                                    // we can make a 1x3:
                                    a.rooms[j][i + 2] =  a.rooms[j][i];
                                    processed[j][i + 2] = true;
                                    if (i + 3 < h && a.rooms[j][i + 3] < SPECIAL_ROOM_IDS_START) {
                                        if (a.divisionIDs[j][i] == a.divisionIDs[j][i + 3] &&
                                            !processed[j][i + 3]) {
                                            // we can make a 4x1:
                                            a.rooms[j][i + 3] =  a.rooms[j][i];
                                            processed[j][i + 3] = true;

                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return true;
    }
        
    
    public RenderedArea generate(Area a, World w, MSXRandom r) throws Exception
    {
        int nextObjectID = 1;
        int dx[] = {-1, 0, 1, 0};
        int dy[] = { 0,-1, 0, 1};
        int direction[] = {PCGWorld.DIRECTION_LEFT, PCGWorld.DIRECTION_UP,
                           PCGWorld.DIRECTION_RIGHT, PCGWorld.DIRECTION_DOWN};
        int direction_inverse[] = {PCGWorld.DIRECTION_RIGHT, PCGWorld.DIRECTION_DOWN,
                                   PCGWorld.DIRECTION_LEFT, PCGWorld.DIRECTION_UP};
        
        int p_of_path = 8;  // probability is 1 / 8

//        System.out.println("PCGArea.generate -----------------------------------");
        r.setSeed(a.rng_seed1, a.rng_seed2);
//        System.out.println("initial seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        if (!mergeAreaRooms(a, r)) return null;
        
        RenderedArea ra = new RenderedArea(a, a.width * ROOM_WIDTH, a.height * ROOM_HEIGHT);
        for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
            for(int j = 0;j<a.width * ROOM_WIDTH;j++) {
                ra.pieceTypes[j][i] = -1;
            }
        }

        // - Generate spanning trees for each division, so each position in a
        //   division is reachable from any other.
//        System.out.println("seed before: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        List<Integer> closed = new ArrayList<>();
        for(int i = 0;i<a.height*2;i++) {
            for(int j = 0;j<a.width*2;j++) {
                if (a.divisionIDs[j/ROOM_WIDTH][i/ROOM_HEIGHT] != 0 &&
                    !closed.contains(j + i * ra.pieceTypes.length)) {
                    int divisionID = a.divisionIDs[j/ROOM_WIDTH][i/ROOM_HEIGHT];
                    List<Integer> open = new ArrayList<>();
                    open.add(j + i * ra.pieceTypes.length);
//                    System.out.println("Starting to fill " +divisionID+ " at " + open.get(0) + ":");
                    while(!open.isEmpty()) {
//                        System.out.println(open);
                        int idx = r.nextInt(64) % open.size();
                        int point = open.remove(idx);
//                        System.out.println("point: " + point + " (open: " + open.size() + ")");
                        closed.add(point);
                        int x = point % ra.pieceTypes.length;
                        int y = point / ra.pieceTypes.length;
                        if (ra.pieceTypes[x][y] == -1) ra.pieceTypes[x][y] = 0;
                        for(int k = 0;k<4;k++) {
                            int x2 = x + dx[k];
                            int y2 = y + dy[k];
                            if (x2 >= 0 && x2 < a.width * ROOM_WIDTH &&
                                y2 >= 0 && y2 < a.height * ROOM_HEIGHT &&
                                a.divisionIDs[x2/ROOM_WIDTH][y2/ROOM_HEIGHT] == divisionID) {
                                int point2 = x2 + y2 * ra.pieceTypes.length;
                                if (!open.contains(point2) && !closed.contains(point2)) {
                                    open.add(point2);
                                    if (ra.pieceTypes[x2][y2] == -1) ra.pieceTypes[x2][y2] = 0;
                                    ra.pieceTypes[x][y] |= direction[k];
                                    ra.pieceTypes[x2][y2] |= direction_inverse[k];
                                }
                            }
                        }
                    }
                }
            }
        }
                
        // Print the spanning trees to make sure it matches the MSX side:
//        System.out.println("pieceTypes: area " + a.ID);
//        for(int i = 0;i<a.height*2;i++) {
//            String line = "";
//            for(int j = 0;j<a.width*2;j++) {
//                line +=  Z80Assembler.toHex8bit(ra.pieceTypes[j][i]) + "\t";
//            }
//            System.out.println(line);
//        }
//        System.out.println("seed afterwards: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        

        // Ensure the marked paths exist:
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0) {
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_LEFT) != 0) {
                        int x = j * ROOM_WIDTH;
                        int y = i * ROOM_HEIGHT + r.nextInt(ROOM_HEIGHT);
                        ra.pieceTypes[x][y] |= PCGWorld.DIRECTION_LEFT;
                        if (x > 0) {
                            ra.pieceTypes[x - 1][y] |= PCGWorld.DIRECTION_RIGHT;
                        }
                    }
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_UP) != 0) {
                        int x = j * ROOM_WIDTH + r.nextInt(ROOM_WIDTH);
                        int y = i * ROOM_HEIGHT;
                        ra.pieceTypes[x][y] |= PCGWorld.DIRECTION_UP;
                        if (y > 0) {
                            ra.pieceTypes[x][y - 1] |= PCGWorld.DIRECTION_DOWN;
                        }
                    }                
                }
            }
        }

        // Print the spanning trees to make sure it matches the MSX side:
//        System.out.println("pieceTypes: area " + a.ID + " (after connections)");
//        for(int i = 0;i<a.height*2;i++) {
//            String line = "";
//            for(int j = 0;j<a.width*2;j++) {
//                line +=  Z80Assembler.toHex8bit(ra.pieceTypes[j][i]) + "\t";
//            }
//            System.out.println(line);
//        }
//        System.out.println("seed afterwards 2: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Add random paths:
//        System.out.println("pieceTypes: area " + a.ID + " (random)");
//        System.out.println("seed before: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
            for(int j = 0;j<a.width * ROOM_WIDTH;j++) {
                if (ra.pieceTypes[j][i] >= 0) {
                    if (j > 0 && 
                        a.divisionIDs[j / ROOM_WIDTH][i / ROOM_HEIGHT] == a.divisionIDs[(j - 1) / ROOM_WIDTH][i / ROOM_HEIGHT]) {
                        if (r.nextInt(p_of_path) == 0) {
//                            System.out.println("    horizontal at " + Z80Assembler.toHex16bit(0xc102 + j + i*a.height * ROOM_HEIGHT, true));
                            ra.pieceTypes[j][i] |= PCGWorld.DIRECTION_LEFT;
                            ra.pieceTypes[j - 1][i] |= PCGWorld.DIRECTION_RIGHT;
                        }
                    }
                    if (i>0 &&
                        a.divisionIDs[j / ROOM_WIDTH][i / ROOM_HEIGHT] == a.divisionIDs[j / ROOM_WIDTH][(i - 1) / ROOM_HEIGHT]) {
                        if (r.nextInt(p_of_path) == 0) {
//                            System.out.println("    vertical at " + Z80Assembler.toHex16bit(0xc102 + j + i*a.height * ROOM_HEIGHT, true));
                            ra.pieceTypes[j][i] |= PCGWorld.DIRECTION_UP;
                            ra.pieceTypes[j][i - 1] |= PCGWorld.DIRECTION_DOWN;
                        }
                    }
                }
            }
        }       
//        System.out.println("seed afterwards 3: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Add connection directions: (not needed as this is already done in the a.connectinos above)
        for(InterAreaConnection c:w.interAreaconnections) {
            if (c.p1.a == a) {
                ra.pieceTypes[c.p1.x * ROOM_WIDTH + c.p1_x_chunk_offs][c.p1.y * ROOM_WIDTH +  + c.p1_y_chunk_offs] |= c.p1.direction;
//                if (c.p1.direction == PCGWorld.DIRECTION_LEFT) {
//                    ra.pieceTypes[c.p1.x * ROOM_WIDTH][c.p1.y * ROOM_WIDTH + r.nextInt(ROOM_HEIGHT)] |= c.p1.direction;
//                } else if (c.p1.direction == PCGWorld.DIRECTION_UP) {
//                    ra.pieceTypes[c.p1.x * ROOM_WIDTH + r.nextInt(ROOM_WIDTH)][c.p1.y * ROOM_HEIGHT] |= c.p1.direction;
//                } else if (c.p1.direction == PCGWorld.DIRECTION_RIGHT) {
//                    ra.pieceTypes[c.p1.x * ROOM_WIDTH + ROOM_WIDTH - 1][c.p1.y * ROOM_HEIGHT + r.nextInt(ROOM_HEIGHT)] |= c.p1.direction;
//                } else if (c.p1.direction == PCGWorld.DIRECTION_DOWN) {
//                    ra.pieceTypes[c.p1.x * ROOM_WIDTH + r.nextInt(ROOM_WIDTH)][c.p1.y * ROOM_HEIGHT + ROOM_HEIGHT - 1] |= c.p1.direction;
//                }
            }
            if (c.p2.a == a) {
                ra.pieceTypes[c.p2.x * ROOM_WIDTH + c.p2_x_chunk_offs][c.p2.y * ROOM_WIDTH +  + c.p2_y_chunk_offs] |= c.p2.direction;
//                if (c.p2.direction == PCGWorld.DIRECTION_LEFT) {
//                    ra.pieceTypes[c.p2.x * ROOM_WIDTH][c.p2.y * ROOM_WIDTH + r.nextInt(ROOM_HEIGHT)] |= c.p2.direction;
//                } else if (c.p2.direction == PCGWorld.DIRECTION_UP) {
//                    ra.pieceTypes[c.p2.x * ROOM_WIDTH + r.nextInt(ROOM_WIDTH)][c.p2.y * ROOM_HEIGHT] |= c.p2.direction;
//                } else if (c.p2.direction == PCGWorld.DIRECTION_RIGHT) {
//                    ra.pieceTypes[c.p2.x * ROOM_WIDTH + ROOM_WIDTH - 1][c.p2.y * ROOM_HEIGHT + r.nextInt(ROOM_HEIGHT)] |= c.p2.direction;
//                } else if (c.p2.direction == PCGWorld.DIRECTION_DOWN) {
//                    ra.pieceTypes[c.p2.x * ROOM_WIDTH + r.nextInt(ROOM_WIDTH)][c.p2.y * ROOM_HEIGHT + ROOM_HEIGHT - 1] |= c.p2.direction;
//                }
            }
        }

        // Print the spanning trees to make sure it matches the MSX side:
//        System.out.println("pieceTypes: area " + a.ID + " (after interarea connections)");
//        for(int i = 0;i<a.height*2;i++) {
//            String line = "";
//            for(int j = 0;j<a.width*2;j++) {
//                line +=  Z80Assembler.toHex8bit(ra.pieceTypes[j][i]) + "\t";
//            }
//            System.out.println(line);
//        }
//        System.out.println("seed afterwards 4: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Place tags into chunks:
        String placedTags[][] = new String[a.width * ROOM_WIDTH][a.height * ROOM_HEIGHT];
        for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
            for(int j = 0;j<a.width * ROOM_WIDTH;j++) {
                placedTags[j][i] = null;
            }
        }

        // Get all tags:
        List<Pair<Integer, String>> tagList = a.getSortedTagList();
     
//        System.out.println("---- placing tags for area " + a.ID + " ----");
//        System.out.println("seed before: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        for(Pair<Integer, String> tag_location:tagList) {
            int j = (tag_location.left % a.width) * ROOM_WIDTH;
            int i = (tag_location.left / a.width) * ROOM_HEIGHT;
            String tag = tag_location.right;
//            System.out.println("    seed ("+tag+": "+Z80Assembler.toHex8bit(AssemblerTags.assemblerID(tag))+"): " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
//            System.out.println("Placing tag:" + tag + ", " + j + ", " + i);

            if (w.withinChestTag.contains(tag)) {
                continue;
            }
            String tagToPlace = null;
            boolean requireAtLeast2Exits = false;
            int connectionToClose = 0;  // for breakable walls
            switch(tag) {
                case "start":
                case "ending":
                    // ignore
                    break;

                case "wall1-key":
                case "wall2-key":
                case "wall3-key":
                case "wall4-key":
                case "block-key1":
                case "block-key2":
                case "block-key3":
                case "block-key4":
                    // ignore
                    break;

                case "boss1-chestlock":
                case "boss2-chestlock":
                case "boss3-chestlock":
                case "boss4-chestlock":
                case "boss5-chestlock":
                case "boss6-chestlock":
                case "boss7-chestlock":
//                    tagToPlace = "boss";
//                    break;                    
                case "boss1-key":
                case "boss2-key":
                case "boss3-key":
                case "boss4-key":
                case "boss5-key":
                case "boss6-key":
                case "boss7-key":
                case "red-key":
                case "green-key":
                case "blue-key":
                case "yellow-key":
                case "purple-key":
                case "white-key":
                case "red-chest":
                case "green-chest":
                case "blue-chest":
                case "yellow-chest":
                case "purple-chest":
                case "white-chest":
                case "gear-key":
                case "ball-key":
                case "idol-key":
                case "astronaut-key":
                case "trial1-clue":
                case "trial2-clue":
                case "trial3-clue":
                case "trial4-clue":
                case "combination1-clue":
                case "combination2-clue":
                case "combination3-clue":
                case "combination4-clue":
                case "button1":
                case "button2":
                case "button3":
                case "button4":
                case "heart1":
                case "heart2":
                case "heart3":
                case "heart4":
                case "heart5":
                case "small-key-chest1":
                case "small-key-chest2":
                case "small-key-chest3":
                case "small-key-chest4":
                case "small-key1":
                case "small-key2":
                case "small-key3":
                case "small-key4":
                case "map-piece1":
                case "map-piece2":
                case "map-piece3":
                case "map-piece4":
                case "map-piece5":
                case "map-piece6":
                case "map-piece7":
                case "map-piece8":
                case "WEAPON_HAMMER":
                case "WEAPON_MACUAHUITL":
                case "WEAPON_SHIELD":
                case "WEAPON_SLING":
                case "WEAPON_BLOWGUN":
                case "WEAPON_ATLATL":
                case "WEAPON_RAYGUN":
                case "WEAPON_OBSIDIAN_KNIVE":
                case "WEAPON_FIRE_HAMMER":
                case "WEAPON_ICE_MACUAHUITL":
                case "item-sandals":
                case "item-gloves":
                case "item-warrior-hat":
                case "item-armor":
                case "item-chaac":
                case "item-seashell":
                case "item-belt":
                case "item-ice-cape":
                case "maya-riddle-clue1":
                case "maya-riddle-clue2":
                case "maya-riddle-clue3":
                case "maya-riddle-clue4":
                case "story-trivia1":
                case "story-trivia2":
                case "story-trivia3":
                case "story-trivia4":
                case "story-trivia5":
                case "story-trivia6":
                case "story-trivia7":
                case "story-trivia8":
                case "teleporter1":
                case "teleporter2":
                case "teleporter3":
                case "teleporter4":
                case "teleporter5":
                case "teleporter6":
                case "teleporter7":
                case "teleporter8":
                case "teleporter-atlantis":
                case "teleporter-moon":
                case "teleporter-mars":
                case "calendar-name-clue":
                case "lost-vendor":
                    tagToPlace = tag;
                    break;

                case "block-puzzle1":
                case "block-puzzle2":
                case "block-puzzle3":
                case "block-puzzle4":
                    requireAtLeast2Exits = true;
                    tagToPlace = tag;
                    break;

                case "breakable-wall1":
                case "breakable-wall2":
                case "breakable-wall3":
                case "breakable-wall4":
                case "red-lock":
                case "green-lock":
                case "blue-lock":
                case "yellow-lock":
                case "purple-lock":
                case "white-lock":
                case "gear-lock":
                case "ball-lock":
                case "idol-lock":
                case "astronaut-lock":
                case "button-door1":
                case "button-door2":
                case "button-door3":
                case "button-door4":
                case "trial1-lock":
                case "trial2-lock":
                case "trial3-lock":
                case "trial4-lock":
                case "combination1-lock":
                case "combination2-lock":
                case "combination3-lock":
                case "combination4-lock":
                case "midpoint":
                {
                    if (!w.lockDirections.containsKey(tag)) {
                        System.err.println("lockDirections does not contain " + tag + "!!!");
                        return null;
                    }
                    int lockDirection = w.lockDirections.get(tag);
                    switch(lockDirection) {
                        case PCGWorld.DIRECTION_LEFT: 
                            connectionToClose = PCGWorld.DIRECTION_LEFT;
                            tagToPlace = tag;
                            break;
                        case PCGWorld.DIRECTION_UP:
                            connectionToClose = PCGWorld.DIRECTION_UP;
                            tagToPlace = tag;
                            break;
                        case PCGWorld.DIRECTION_RIGHT:
                            connectionToClose = PCGWorld.DIRECTION_RIGHT;
                            tagToPlace = tag;
                            break;
                        case PCGWorld.DIRECTION_DOWN:
                            connectionToClose = PCGWorld.DIRECTION_DOWN;
                            tagToPlace = tag;
                            break;
                    }
                    break;                                        
                }

                default:
                    System.err.println("Unsupported tag: " + tag);
            }

            if (tagToPlace != null) {
//                System.out.println("  tag: " + tag + ", requireAtLeast2Exits: " + requireAtLeast2Exits + ", connectionToClose: " + connectionToClose);
                
                int position = r.nextInt(ROOM_WIDTH * ROOM_HEIGHT);
//                System.out.println("  random start: " + position);
                // Find the position with the least outgoing connections that can fit the tag:
                // This is so that we favor cul-de-sacs for items.
                int best_n_connections = 5;
                int best_x = -1, best_y = -1;
                for(int k = 0;k<ROOM_WIDTH * ROOM_HEIGHT;k++) {
//                    System.out.println("  ----");
                    int x = j + position%ROOM_WIDTH;
                    int y = i + position/ROOM_WIDTH;
                    position = (position + 1) % (ROOM_WIDTH * ROOM_HEIGHT);
                    if (requireAtLeast2Exits) {
                        if (
                            ra.pieceTypes[x][y] == 0x0 ||
                            ra.pieceTypes[x][y] == 0x1 ||
                            ra.pieceTypes[x][y] == 0x2 ||
                            ra.pieceTypes[x][y] == 0x4 ||
                            ra.pieceTypes[x][y] == 0x8
                            ) {
                            continue;
                        }
                    }
                    if (connectionToClose == PCGWorld.DIRECTION_LEFT) {
                        if ((x % ROOM_WIDTH) != 0) continue;
                        if ((ra.pieceTypes[x][y] & connectionToClose) == 0) continue;
                    }
                    if (connectionToClose == PCGWorld.DIRECTION_UP) {
                        if ((y % ROOM_HEIGHT) != 0) continue;
                        if ((ra.pieceTypes[x][y] & connectionToClose) == 0) continue;
                    }
                    if (connectionToClose == PCGWorld.DIRECTION_RIGHT) {
                        if ((x % ROOM_WIDTH) != ROOM_WIDTH - 1) continue;
                        if ((ra.pieceTypes[x][y] & connectionToClose) == 0) continue;
                    }
                    if (connectionToClose == PCGWorld.DIRECTION_DOWN) {
                        if ((y % ROOM_HEIGHT) != ROOM_HEIGHT - 1) continue;
                        if ((ra.pieceTypes[x][y] & connectionToClose) == 0) continue;
                    }

                    if (placedTags[x][y] == null) {
                        int n_connections = n_connections_per_type[ra.pieceTypes[x][y]];
                        if (n_connections < best_n_connections) {
                            best_x = x;
                            best_y = y;
                            best_n_connections = n_connections;
//                            System.out.println("  new best: " + (x % ROOM_WIDTH) + ", " + (y % ROOM_HEIGHT));
                        }
                    }
                }
                if (best_n_connections < 5) {
//                    System.out.println("  tag placed at: " + best_x + ", " + best_y);
                    placedTags[best_x][best_y] = tagToPlace;
                    if (connectionToClose != 0) {                        
                        // Close the connection for breakable walls:
                        // pieceTypes[x][y] |= connectionToClose;
                        ra.pieceTypes[best_x][best_y] ^= connectionToClose;
                    }
                    tagToPlace = null;
                }
            }
            if (tagToPlace != null) {
                if (w.lockDirections.containsKey(tagToPlace)) {
                    System.err.println("lock direction " + tagToPlace + ": " + w.lockDirections.get(tagToPlace));
                }
                System.err.println("Could not place tag " + tag + " at " + j + ", " + i + "(area " + a.ID + ") " + 
                                   ", limitTo2ExitTypes = " + requireAtLeast2Exits +
                                   ", connectionToClose = " + connectionToClose + 
                                   ", placedTags[x][y] = " + placedTags[j][i] + ", " + placedTags[j+1][i] + ", " + placedTags[j][i + 1] + ", " + placedTags[j + 1][i + 1] +
                                   ", pieceTypes[x][y] = " + ra.pieceTypes[j][i] + ", " + ra.pieceTypes[j+1][i] + ", " + ra.pieceTypes[j][i + 1] + ", " + ra.pieceTypes[j + 1][i + 1]);
                return null;
            }
        }
              
//        System.out.println("seed afterwards 5: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Choose chunks:
        for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
            for(int j = 0;j<a.width * ROOM_WIDTH;j++) {                
                if (ra.pieceTypes[j][i] >= 0) {
                    RoomChunk above = null, left = null;
                    List<String> necessaryObjectTypes = new ArrayList<>();
                    String upTag = null, downTag = null, leftTag = null, rightTag = null;
                    String chunkPoolName = "standard";
                    HashMap<Integer, List<RoomChunk>> chunkPool = fg_chunks;
                    if (placedTags[j][i] != null) {
                        switch(placedTags[j][i]) {
                            case "boss1-chestlock":
                            case "boss2-chestlock":
                            case "boss3-chestlock":
                            case "boss4-chestlock":
                            case "boss5-chestlock":
                            case "boss6-chestlock":
                            case "boss7-chestlock":
                                chunkPoolName = "boss";
                                chunkPool = boss_chunks;
                                break;
                                
                            case "block-puzzle1":
                            case "block-puzzle2":
                            case "block-puzzle3":
                            case "block-puzzle4":
                                chunkPoolName = "block";
                                chunkPool = block_chunks;
                                break;

                            case "breakable-wall1":
                            case "breakable-wall2":
                            case "breakable-wall3":
                            case "breakable-wall4":
                            {
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("breakable-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("breakable-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("breakable-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("breakable-down"); break;
                                }
                                break;
                            }

                            case "gear-lock":
                            case "idol-lock":
                            case "astronaut-lock":
                            {
                                necessaryObjectTypes.add("big-item");
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }
                                break;
                            }
                            
                            case "button-door1":
                            case "button-door2":
                            case "button-door3":
                            case "button-door4":
                            {
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }
                                break;
                            }

                            case "red-lock":
                            case "green-lock":
                            case "blue-lock":
                            case "yellow-lock":
                            case "purple-lock":
                            case "white-lock":
                            case "ball-lock":
                            {
                                necessaryObjectTypes.add("item");
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }
                                break;
                            }
                            
                            case "midpoint":
                            {
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }
                                break;
                            }

                            case "boss1-key":
                            case "boss2-key":
                            case "boss3-key":
                            case "boss4-key":
                            case "boss5-key":
                            case "boss6-key":
                            case "boss7-key":
                            case "red-key":
                            case "green-key":
                            case "blue-key":
                            case "yellow-key":
                            case "purple-key":
                            case "white-key":
                            case "red-chest":
                            case "green-chest":
                            case "blue-chest":
                            case "yellow-chest":
                            case "purple-chest":
                            case "white-chest":
                            case "gear-key":
                            case "ball-key":
                            case "idol-key":
                            case "astronaut-key":
                            case "trial1-clue":
                            case "trial2-clue":
                            case "trial3-clue":
                            case "trial4-clue":
                            case "combination1-clue":
                            case "combination2-clue":
                            case "combination3-clue":
                            case "combination4-clue":
                            case "button1":
                            case "button2":
                            case "button3":
                            case "button4":    
                            case "heart1":
                            case "heart2":
                            case "heart3":
                            case "heart4":
                            case "heart5":
                            case "small-key-chest1":
                            case "small-key-chest2":
                            case "small-key-chest3":
                            case "small-key-chest4":
                            case "small-key1":
                            case "small-key2":
                            case "small-key3":
                            case "small-key4":
                            case "map-piece1":
                            case "map-piece2":
                            case "map-piece3":
                            case "map-piece4":
                            case "map-piece5":
                            case "map-piece6":
                            case "map-piece7":
                            case "map-piece8":
                            case "WEAPON_HAMMER":
                            case "WEAPON_MACUAHUITL":
                            case "WEAPON_SHIELD":
                            case "WEAPON_SLING":
                            case "WEAPON_BLOWGUN":
                            case "WEAPON_ATLATL":
                            case "WEAPON_RAYGUN":
                            case "WEAPON_OBSIDIAN_KNIVE":
                            case "WEAPON_FIRE_HAMMER":
                            case "WEAPON_ICE_MACUAHUITL":
                            case "item-sandals":
                            case "item-gloves":
                            case "item-hurakan":
                            case "item-armor":
                            case "item-chaac":
                            case "item-seashell":
                            case "item-belt":
                            case "item-ice-cape":
                            case "maya-riddle-clue1":
                            case "maya-riddle-clue2":
                            case "maya-riddle-clue3":
                            case "maya-riddle-clue4":
                            case "story-trivia1":
                            case "story-trivia2":
                            case "story-trivia3":
                            case "story-trivia4":
                            case "story-trivia5":
                            case "story-trivia6":
                            case "story-trivia7":
                            case "story-trivia8":
                            case "calendar-name-clue":
                                necessaryObjectTypes.add("item");
                                break;

                            case "teleporter1":
                            case "teleporter2":
                            case "teleporter3":
                            case "teleporter4":
                            case "teleporter5":
                            case "teleporter6":
                            case "teleporter7":
                            case "teleporter8":
                            case "teleporter-atlantis":
                            case "teleporter-mars":
                            case "teleporter-moon":
                                necessaryObjectTypes.add("big-item");
                                break;
                                
                            case "trial1-lock":
                            case "trial2-lock":
                            case "trial3-lock":
                            case "trial4-lock":
                            {
                                necessaryObjectTypes.add("4x4-item");
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }
                                break;
                            }
                                
                            case "combination1-lock":
                            case "combination2-lock":
                            case "combination3-lock":
                            case "combination4-lock":
                            {
                                chunkPoolName = "combination";
                                chunkPool = combination_chunks;
                                int lockDirection = w.lockDirections.get(placedTags[j][i]);
                                switch(lockDirection) {
                                    case PCGWorld.DIRECTION_LEFT: necessaryObjectTypes.add("door-left"); break;
                                    case PCGWorld.DIRECTION_UP: necessaryObjectTypes.add("door-up"); break;
                                    case PCGWorld.DIRECTION_RIGHT: necessaryObjectTypes.add("door-right"); break;
                                    case PCGWorld.DIRECTION_DOWN: necessaryObjectTypes.add("door-down"); break;
                                }                                
                                break;
                            }
                        }
                    }
                     
                    if (i > 0) above = ra.fg_chunks[j][i-1];
                    if (j > 0) left = ra.fg_chunks[j-1][i];
                    if (above == null) {
                        // top of the map:
                        if ((ra.pieceTypes[j][i] & PCGWorld.DIRECTION_UP) != 0) {
                            upTag = "stairs";  // up/down connections from outside the map always via stairs
                        }
                    } else if (a.rooms[j/2][(i-1)/2] >= SPECIAL_ROOM_IDS_START && (ra.pieceTypes[j][i] & PCGWorld.DIRECTION_UP) != 0) {
                        upTag = "hole";
                    } else {
                        if ((ra.pieceTypes[j][i] & PCGWorld.DIRECTION_UP) != 0) {
                            if ((ra.pieceTypes[j][i - 1] & PCGWorld.DIRECTION_DOWN) != 0) {
                                if (above.tags.containsKey("down")) {
                                    upTag = above.tags.get("down");
                                }
                            } else {
                                upTag = "hole";
                            }
                        } else {
                            // ignore the above tag, as we have a breakable wall/door above here
                        }
                    }
                    if (left != null) {
                        if (a.rooms[(j-1)/2][i/2] >= SPECIAL_ROOM_IDS_START && (ra.pieceTypes[j][i] & PCGWorld.DIRECTION_LEFT) != 0) {
                            leftTag = "hole";
                        } else {
                            if ((ra.pieceTypes[j][i] & PCGWorld.DIRECTION_LEFT) != 0) {
                                if ((ra.pieceTypes[j - 1][i] & PCGWorld.DIRECTION_RIGHT) != 0) {
                                    if (left.tags.containsKey("right")) {
                                        leftTag = left.tags.get("right");
                                    }
                                } else {
                                    // breakable wall/door, we need a hole:
                                    leftTag = "hole";
                                }
                            } else {
                            }
                        }
                    } else {
                        leftTag = null;
                    }
                    if ((ra.pieceTypes[j][i] & PCGWorld.DIRECTION_DOWN) != 0) {
                        if (i == a.height * ROOM_HEIGHT - 1 || ra.pieceTypes[j][i+1] < 0) {
                            downTag = "stairs";  // up/down connections from outside the map always via stairs
                        } else {
                            if ((ra.pieceTypes[j][i+1] & PCGWorld.DIRECTION_UP) == 0) {
                                downTag = "hole";  // prevent stairs when there is a door/breakable wall below
                            }
                        }
                    }

//                    System.out.println(j + ", " + i + ", upTag: " + upTag + ", leftTag: " + leftTag);
                    
                    if (necessaryObjectTypes.contains("breakable-up") ||
                        necessaryObjectTypes.contains("door-up")) {
                        upTag = null;  // should never happen though
                    }
                    List<RoomChunk> choices = chunkPool.get(ra.pieceTypes[j][i]);
                    if (upTag != null || downTag != null || leftTag != null || rightTag != null || 
                        !necessaryObjectTypes.isEmpty()) {
                        List<RoomChunk> choicesWithTag = new ArrayList<>();
                        for(RoomChunk c:choices) {
                            boolean found = true;
                            for(String necessaryObjectType:necessaryObjectTypes) {
                                if (!c.hasObjectType(necessaryObjectType)) {
                                    found = false;
                                }
                            }
                            if (!found) continue;
                            if (upTag != null && 
                                (!c.tags.containsKey("up") || !c.tags.get("up").equals(upTag))) {
                                continue;
                            }
                            if (downTag != null && 
                                (!c.tags.containsKey("down") || !c.tags.get("down").equals(downTag))) {
                                continue;
                            }                            
                            if (leftTag != null && 
                                (!c.tags.containsKey("left") || !c.tags.get("left").equals(leftTag))) {
                                continue;
                            }
                            if (rightTag != null && 
                                (!c.tags.containsKey("right") || !c.tags.get("right").equals(rightTag))) {
                                continue;
                            }
                            choicesWithTag.add(c);
                        }
                        if (!choicesWithTag.isEmpty()) {
                            choices = choicesWithTag;
                        } else {
                            throw new Exception("No " +chunkPoolName+ " chunks with up/down tags: " + upTag + "/" + downTag + ", left/right tags: " + leftTag + "/" + rightTag + ", objects " + necessaryObjectTypes + ", and type: " + ra.pieceTypes[j][i] + " (at " + j + ", " + i + " area " + a.ID + ", placed tags: "+placedTags[j][i]+")");
//                            System.err.println("No " +chunkPoolName+ " chunks with up/down tags: " + upTag + "/" + downTag + ", objects " + necessaryObjectTypes + ", and type: " + ra.pieceTypes[j][i] + " (at " + j + ", " + i + " area " + a.ID + ", placed tags: "+placedTags[j][i]+")");
//                            return null;
                        }
                    }
                    if (biome.equals("jungle")) {
                        // stairs only used for inter-area connections
                        List<RoomChunk> choices2 = new ArrayList<>();
                        for(RoomChunk c:choices) {
                            if (downTag == null && c.tags.containsKey("down") && c.tags.get("down").equals("stairs")) {
                                // Not allowed!
                            } else {
                                choices2.add(c);
                            }
                        }
                        if (choices2.isEmpty() && !choices.isEmpty()) {
                            throw new Exception("All " +chunkPoolName+ " chunks eliminated since they had stairs for up/down tags: " + upTag + "/" + downTag + ", left/right tags: " + leftTag + "/" + rightTag + ", objects " + necessaryObjectTypes + ", and type: " + ra.pieceTypes[j][i] + " (at " + j + ", " + i + " area " + a.ID + ", placed tags: "+placedTags[j][i]+")");
//                            System.err.println("All " +chunkPoolName+ " chunks eliminated since they had stairs for up/down tags: " + upTag + "/" + downTag + ", objects " + necessaryObjectTypes + ", and type: " + ra.pieceTypes[j][i] + " (at " + j + ", " + i + " area " + a.ID + ", placed tags: "+placedTags[j][i]+")");
//                            return null;
                        }
                        choices = choices2;
                    }
                    
                    if (choices.isEmpty()) {
                        throw new Exception("No " +chunkPoolName+ " chunks for type " + ra.pieceTypes[j][i]);
//                        System.err.println("No " +chunkPoolName+ " chunks for type " + ra.pieceTypes[j][i]);
//                        return null;
                    }
                    
                    {
//                        List<Integer> choiceIds = new ArrayList<>();
//                        for(RoomChunk c:choices) {
//                            choiceIds.add(all_fg_chunks.indexOf(c));
//                        }
//                        System.out.println("constraints: type: " + ra.pieceTypes[j][i] + ", upTag: " + upTag + ", downTag: " + downTag + ", necessaryObjectTypes: " + necessaryObjectTypes + ", chunkPool: " + chunkPoolName);
//                        System.out.println("    seed before: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
//                        System.out.println("    chunk choices: " + j + ", " + i + ": " + choiceIds);
                        ra.pieceChoosingRNGSeed1[j][i] = r.rng_seed1;
                        ra.pieceChoosingRNGSeed2[j][i] = r.rng_seed2;
                        ra.pieceChoosingChoicesSize[j][i] = choices.size();
                        int idx = r.nextInt(8) % choices.size();
                        ra.fg_chunks[j][i] = choices.get(idx);
//                        System.out.println("    chosen: " + all_fg_chunks.indexOf(ra.fg_chunks[j][i]) + ", " + ra.fg_chunks[j][i].tags);
                    }
                    if (placedTags[j][i] != null) {
                        int extra = 0;
                        if (w.lockDirections.containsKey(placedTags[j][i])) {
                            extra = w.lockDirections.get(placedTags[j][i]);
                        }
                        ra.objectPlaceholders.add(new GameObjectPlaceholder(placedTags[j][i], j, i, nextObjectID, extra));
                        nextObjectID++;
                    }
                    
                } else {
                    ra.fg_chunks[j][i] = null;
                }
            }
        }
        
        int rng_seed1 = r.rng_seed1, rng_seed2 = r.rng_seed2;
        if (!spawnObjects(ra, w, placedTags, r)) return null;
        r.setSeed(rng_seed1, rng_seed2);
        
        return ra;
    }
    
    
    public RoomChunk[][] getBGChunksLikeInMSX(RenderedArea ra)
    {
        Area a = ra.a;
        RoomChunk ra_bg_chunks[][] = new RoomChunk[ra.fg_chunks.length][ra.fg_chunks[0].length];
        
        // background (follow the same random procedure as used in assembler):
        List<Integer> roomIDs = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {                
                if (a.rooms[j][i] >= 0 && !roomIDs.contains(a.rooms[j][i])) {
                    roomIDs.add(a.rooms[j][i]);
                }
            }
        }

        int p_of_non_first_bg = 4;  // probability is 1 / 4
        for(int roomID:roomIDs) {
            // set the random number generator in the same state as it will be 
            // on the MSX side:
            MSXRandom r = new MSXRandom(a.rng_seed1, a.rng_seed2);
            for(int i = 0;i<roomID;i++) {
                r.nextBoolean();
            }
            for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
                for(int j = 0;j<a.width * ROOM_WIDTH;j++) {                
                    if (a.rooms[j/2][i/2] == roomID &&
                        ra.pieceTypes[j][i] >= 0 &&
                        !ra.fg_chunks[j][i].tags.containsKey("boss")) {
                        if (r.nextInt(p_of_non_first_bg) == 0 && bg_chunks.size() > 1) {
                            ra_bg_chunks[j][i] = bg_chunks.get(1 + r.nextInt(bg_chunks.size() - 1));
                        } else {
                            ra_bg_chunks[j][i] = bg_chunks.get(0);
                        }
                    }
                }
            }
        }
        return ra_bg_chunks;
    }
    
    
    public boolean spawnObjects(RenderedArea ra, World w, String placedTags[][], MSXRandom r)
    {
        Area a = ra.a;
        
        // Spawn pushable blocks:
        for(int i = 0;i<a.height * ROOM_HEIGHT;i++) {
            for(int j = 0;j<a.width * ROOM_WIDTH;j++) {                
                if (ra.fg_chunks[j][i] == null) continue;
                for(TMXObject place:ra.fg_chunks[j][i].locations) {
                    if (place.type.equals("pushable-block")) {
                        ra.objects.add(new GameObject(j*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      i*RoomChunk.CHUNK_HEIGHT*8 + place.y, "pushable-block"));
                    }
                }
            }
        }
        
        
        // Note, this does not respect the RNG state of the MSX version:
        for(GameObjectPlaceholder go:ra.objectPlaceholders) {
            switch(go.type) {
                case "block-puzzle1":
                case "block-puzzle2":
                case "block-puzzle3":
                case "block-puzzle4":
                    break;
                case "boss1-key":
                case "boss2-key":
                case "boss3-key":
                case "boss4-key":
                case "boss5-key":
                case "boss6-key":
                case "boss7-key":
                case "red-key":
                case "green-key":
                case "blue-key":
                case "yellow-key":
                case "purple-key":
                case "white-key":
                case "red-chest":
                case "green-chest":
                case "blue-chest":
                case "yellow-chest":
                case "purple-chest":
                case "white-chest":
                case "gear-key":
                case "ball-key":
                case "idol-key":
                case "astronaut-key":
                case "trial1-clue":
                case "trial2-clue":
                case "trial3-clue":
                case "trial4-clue":
                case "combination1-clue":
                case "combination2-clue":
                case "combination3-clue":
                case "combination4-clue":
                case "button1":
                case "button2":
                case "button3":
                case "button4":    
                case "heart1":
                case "heart2":
                case "heart3":
                case "heart4":
                case "heart5":
                case "small-key-chest1":
                case "small-key-chest2":
                case "small-key-chest3":
                case "small-key-chest4":
                case "small-key1":
                case "small-key2":
                case "small-key3":
                case "small-key4":
                case "map-piece1":
                case "map-piece2":
                case "map-piece3":
                case "map-piece4":
                case "map-piece5":
                case "map-piece6":
                case "map-piece7":
                case "map-piece8":
                case "WEAPON_HAMMER":
                case "WEAPON_MACUAHUITL":
                case "WEAPON_SHIELD":
                case "WEAPON_SLING":
                case "WEAPON_BLOWGUN":
                case "WEAPON_ATLATL":
                case "WEAPON_RAYGUN":
                case "WEAPON_OBSIDIAN_KNIVE":
                case "WEAPON_FIRE_HAMMER":
                case "WEAPON_ICE_MACUAHUITL":
                case "item-sandals":
                case "item-gloves":
                case "item-warrior-hat":
                case "item-armor":
                case "item-chaac":
                case "item-seashell":
                case "item-belt":
                case "item-ice-cape":
                case "maya-riddle-clue1":
                case "maya-riddle-clue2":
                case "maya-riddle-clue3":
                case "maya-riddle-clue4":
                case "story-trivia1":
                case "story-trivia2":
                case "story-trivia3":
                case "story-trivia4":
                case "story-trivia5":
                case "story-trivia6":
                case "story-trivia7":
                case "story-trivia8":
                case "calendar-name-clue":
                case "lost-vendor":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("item", r);
                    if (place == null) {
                        return false;
                    }
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, go.type));
                    break;
                }
                case "teleporter1":
                case "teleporter2":
                case "teleporter3":
                case "teleporter4":
                case "teleporter5":
                case "teleporter6":
                case "teleporter7":
                case "teleporter8":
                case "teleporter-atlantis":
                case "teleporter-mars":
                case "teleporter-moon":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("big-item", r);
                    if (place == null) {
                        return false;
                    }
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, go.type));
                    break;
                }
                case "boss1-chestlock":
                case "boss2-chestlock":
                case "boss3-chestlock":
                case "boss4-chestlock":
                case "boss5-chestlock":
                case "boss6-chestlock":
                case "boss7-chestlock":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("item", r);
                    if (place == null) return false;
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "boss-lock"));
                    place = ra.fg_chunks[go.x][go.y].randomObject("4x4-item", r);
                    if (place == null) return false;
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "boss-door"));
                    break;
                }
                
                case "gear-lock":
                case "idol-lock":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("big-item", r);
                    if (place == null) {
                        return false;
                    }
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, placedTags[go.x][go.y]));
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    switch(lockDirection) {
                        case PCGWorld.DIRECTION_LEFT:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-left", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-left"));
                            break;
                        case PCGWorld.DIRECTION_UP:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-up", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-up"));
                            break;
                        case PCGWorld.DIRECTION_RIGHT:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-right", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-right"));
                            break;
                        case PCGWorld.DIRECTION_DOWN:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-down", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-down"));
                            break;
                    }
                    break;
                }

                case "red-lock":
                case "green-lock":
                case "blue-lock":
                case "yellow-lock":
                case "purple-lock":
                case "white-lock":
                case "ball-lock":
                case "astronaut-lock":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("item", r);
                    if (place == null) return false;
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, placedTags[go.x][go.y]));
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    switch(lockDirection) {
                        case PCGWorld.DIRECTION_LEFT:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-left", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-left"));
                            break;
                        case PCGWorld.DIRECTION_UP:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-up", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-up"));
                            break;
                        case PCGWorld.DIRECTION_RIGHT:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-right", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-right"));
                            break;
                        case PCGWorld.DIRECTION_DOWN:
                            place = ra.fg_chunks[go.x][go.y].randomObject("door-down", r);
                            if (place == null) return false;
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-down"));
                            break;
                    }
                    break;
                }

                case "breakable-wall1":
                case "breakable-wall2":
                case "breakable-wall3":
                case "breakable-wall4":                        
                {
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    if (lockDirection == PCGWorld.DIRECTION_LEFT) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("breakable-left", r);
                        if (place == null) {
                            return false;
                        }
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y,
                                                      place.dx, place.dy, "breakable-left"));
                    } else if (lockDirection == PCGWorld.DIRECTION_UP) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("breakable-up", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y,
                                                      place.dx, place.dy, "breakable-up"));
                    } else if (lockDirection == PCGWorld.DIRECTION_RIGHT) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("breakable-right", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y,
                                                      place.dx, place.dy, "breakable-right"));
                    } else if (lockDirection == PCGWorld.DIRECTION_DOWN) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("breakable-down", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y,
                                                      place.dx, place.dy, "breakable-down"));
                    }
                    break;
                }

                case "button-door1":
                case "button-door2":
                case "button-door3":
                case "button-door4":
                case "midpoint":
                {
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    if (lockDirection == PCGWorld.DIRECTION_LEFT) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("door-left", r);
                        if (place == null) {
                            return false;
                        }
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-left"));
                    } else if (lockDirection == PCGWorld.DIRECTION_UP) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("door-up", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-up"));
                    } else if (lockDirection == PCGWorld.DIRECTION_RIGHT) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("door-right", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-right"));
                    } else if (lockDirection == PCGWorld.DIRECTION_DOWN) {
                        TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("door-down", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-down"));
                    }                            
                    break;
                }        

                case "trial1-lock":
                case "trial2-lock":
                case "trial3-lock":
                case "trial4-lock":
                {
                    TMXObject place = ra.fg_chunks[go.x][go.y].randomObject("4x4-item", r);
                    if (place == null) {
                        return false;
                    }
                    ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                  go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, placedTags[go.x][go.y]));
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    if (lockDirection == PCGWorld.DIRECTION_LEFT) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-left", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-left"));
                    } else if (lockDirection == PCGWorld.DIRECTION_UP) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-up", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-up"));
                    } else if (lockDirection == PCGWorld.DIRECTION_RIGHT) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-right", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-right"));
                    } else if (lockDirection == PCGWorld.DIRECTION_DOWN) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-down", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-down"));
                    }                            
                    break;                                
                }

                case "combination1-lock":
                case "combination2-lock":
                case "combination3-lock":
                case "combination4-lock":
                {
                    TMXObject place;
                    int lockDirection = w.lockDirections.get(placedTags[go.x][go.y]);
                    if (lockDirection == PCGWorld.DIRECTION_LEFT) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-left", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-left"));
                    } else if (lockDirection == PCGWorld.DIRECTION_UP) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-up", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-up"));
                    } else if (lockDirection == PCGWorld.DIRECTION_RIGHT) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-right", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-right"));
                    } else if (lockDirection == PCGWorld.DIRECTION_DOWN) {
                        place = ra.fg_chunks[go.x][go.y].randomObject("door-down", r);
                        if (place == null) return false;
                        ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place.x,
                                                      go.y*RoomChunk.CHUNK_HEIGHT*8 + place.y, "door-down"));
                    }
                    // spawn the 8 switches:
                    int n_switches_spawned = 0;
                    for(TMXObject place2:ra.fg_chunks[go.x][go.y].locations) {
                        if (place2.type.equals("item")) {
                            ra.objects.add(new GameObject(go.x*RoomChunk.CHUNK_WIDTH*8 + place2.x,
                                                          go.y*RoomChunk.CHUNK_HEIGHT*8 + place2.y, "lever"));
                            n_switches_spawned++;
                            if (n_switches_spawned >= 8) break;
                        }
                    }
                    break;                                
                }         

                default:
                    System.err.println("Don't know how to draw object type: " + go.type);
            }
        }
        return true;
    }
        
}
