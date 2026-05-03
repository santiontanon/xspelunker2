/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import pcg.questpatterns.PCGPatternAtoB;
import pcg.questpatterns.PCGPatternNKeysAndChestLock;
import pcg.questpatterns.PCGPatternNKeysAndLock;
import pcg.questpatterns.PCGPatternObstacle;
import util.Pair;
import util.Z80Assembler;

/**
 *
 * @author santi
 * 
 * - This class is an implementation of a key-and-lock procedural quest generation
 *   designed so that it can be translated to z80 assembler easily.
 * - Because of that, some routines do things in ways that are suboptimal, not
 *   very well principled, or convoluted, just because they are easier to
 *   translate to assembler this way.
 * - Also, the code is dirty and full of commented out code, print statements
 *   and other unnecessary things, since I used them a lot when translating
 *   to assembler, to ensure I got exactly the same behavior in Java than in 
 *   assembler.
 * - Why did I care that I got exactly the same behavior? Because in this way
 *   I can do extensive tests on the Java side, compute statistics, etc. and
 *   plan the game, in a way that would be very hard to do if only the
 *   assembler version was available.
 *   
 */
public class PCGWorld {
    public static final int MAX_ROOM_AREA = 4;

    public static final int DIRECTION_NONE = 0;
    public static final int DIRECTION_DOWN = 1;
    public static final int DIRECTION_RIGHT = 2;
    public static final int DIRECTION_UP = 4;
    public static final int DIRECTION_LEFT = 8;
    public static final int DIRECTION_IN = 16;  // connection that goes through a "gate"/"door", and not the edge of a room.
    
    public int n_areas = 12;
    public String areaNames[] = {
        "Jungle",
        "Temple of Inscriptions",
        "Hidden Temple",
        "Confluence",
        "Inverted Pyramid",
        "Fire Shaft",
        "Pacific Caves",
        "Atlantic Caves",
        "Xibalba",
        "Atlantis",  // 9
        "Mars Pyramid",  // 10
        "Moon Cave",  // 11
    };
    public int areaDebugPositions[][] = {
        {160, 40},
        {50, 100},
        {300, 100},
        {150, 230},
        {150, 300},
        {200, 450},
        {50, 450},
        {300, 450},
        {150, 600},
        {500, 450},
        {500, 40},
        {500, 200},
    };

    // Parameters for original level sizes (8*8): 1062 / 5000 fails
//    public int n_divisions = 134;
//    public int min_divisions_per_area[] = {6, 15, 15, 6, 15, 3, 12, 12, 13, 13, 12, 12};
//    public int areaSizes[][] = {
//        {8, 2}, {8, 8}, {8, 8}, {9, 3},
//        {8, 8}, {3, 3}, {6, 8}, {6, 8},
//        {8, 8}, {8, 8}, {8, 8}, {8, 8},
//    };
//    public String predefinedAreaLayouts[][] = {
//        null,
//        {"...xx...",
//         "...xx...",
//         "..xxxx..",
//         "..xxxx..",
//         ".xxxxxx.",
//         ".xxxxxx.",
//         "xxxxxxxx",
//         "xxxxxxxx",
//         },
//        {"...xx...",
//         "...xx...",
//         "..xxxx..",
//         "..xxxx..",
//         ".xxxxxx.",
//         ".xxxxxx.",
//         "xxxxxxxx",
//         "xxxxxxxx",
//         },
//        {"x..xxx..x",
//         "xxxxxxxxx",
//         "....x...."},
//        {"xxxxxxxx",
//         "xxxxxxxx",
//         ".xxxxxx.",
//         ".xxxxxx.",
//         "..xxxx..",
//         "..xxxx..",
//         "...xx...",
//         "...xx..."},
//        {".x.",
//         "xxx",
//         ".x."},
//        null,
//        null,
//        null,
//        null,
//        null,
//        null,
//        };


    // Slightly smaller sizes (7*7): 1031 / 5000 fails (hard / normal)
    public int n_divisions = 136;
    public int min_divisions_per_area[] = {6, 15, 15, 6, 15, 3, 12, 12, 13, 13, 12, 12};
    public int areaSizes[][] = {
        {7, 2}, {7, 7}, {7, 7}, {9, 3},
        {7, 7}, {3, 3}, {5, 7}, {5, 7},
        {7, 7}, {7, 7}, {7, 7}, {7, 7},
    };
    public String predefinedAreaLayouts[][] = {
        null,
        {"...x...",
         "..xxx..",
         "..xxx..",
         ".xxxxx.",
         ".xxxxx.",
         "xxxxxxx",
         "xxxxxxx",
         },
        {"...x...",
         "..xxx..",
         "..xxx..",
         ".xxxxx.",
         ".xxxxx.",
         "xxxxxxx",
         "xxxxxxx",
         },
        {"x..xxx..x",
         "xxxxxxxxx",
         "....x...."},
        {"xxxxxxx",
         "xxxxxxx",
         ".xxxxx.",
         ".xxxxx.",
         "..xxx..",
         "..xxx..",
         "...x..."},
        {".x.",
         "xxx",
         ".x."},
        null,
        null,
        null,
        null,
        null,
        null,
        };


//    // Smaller sizes (6*6): 913 / 5000 fails
//    public int n_divisions = 134;
//    public int min_divisions_per_area[] = {6, 15, 15, 6, 15, 3, 12, 12, 13, 13, 12, 12};
//    public int areaSizes[][] = {
//        {7, 2}, {6, 6}, {6, 6}, {9, 3},
//        {6, 6}, {3, 3}, {4, 6}, {4, 6},
//        {6, 6}, {6, 6}, {6, 6}, {6, 6},
//    };
//    public String predefinedAreaLayouts[][] = {
//        null,
//        {"..xx..",
//         "..xx..",
//         ".xxxx.",
//         ".xxxx.",
//         "xxxxxx",
//         "xxxxxx",
//         },
//        {"..xx..",
//         "..xx..",
//         ".xxxx.",
//         ".xxxx.",
//         "xxxxxx",
//         "xxxxxx",
//         },
//        {"x..xxx..x",
//         "xxxxxxxxx",
//         "....x...."},
//        {"xxxxxx",
//         "xxxxxx",
//         ".xxxx.",
//         ".xxxx.",
//         "..xx..",
//         "..xx.."},
//        {".x.",
//         "xxx",
//         ".x."},
//        null,
//        null,
//        null,
//        null,
//        null,
//        null,
//        };

    
    public double predefinedAreaLayouts_f[] = {
      0.0,
      0.95, 0.95,  // two pyramids only respect the pattern with chance 0.5
      1.0,  // confluence folow the exact pattern
      0.95,  // inverted pyramid follows the pattern with chance 0.5
      1.0,  // fire shaft
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0
    };
    public HashMap<String, String[]> availableLockKeysObstacles = new HashMap<>();
    public HashMap<String, String[]> availableLockKeysChests = new HashMap<>();
    public HashMap<String, String[]> availableLockKeys = new HashMap<>();
    public List<String> availableLockKeysObstaclesSorted = new ArrayList<>();
    public List<String> availableLockKeysChestsSorted = new ArrayList<>();
    public List<String> availableLockKeysSorted = new ArrayList<>();
    public List<String> remainingTriviaTabletFns = new ArrayList<>();


    public MSXRandom r;
    public int next_divisionID = 1;
    
    // Debugging stats:
    public int n_times_defaulting_to_safe_seed = 0;
    public int n_times_reached_generation_stage[] = {0, 0, 0, 0,
                                                     0, 0, 0, 0};
//    public int area_1_n_leaves_accum = 0;
//    public int area_1_n_leaves_count = 0;


    public PCGWorld()
    {
    }
    
    
    public void initKeysAndLocks()
    {
        availableLockKeysObstacles.clear();
        availableLockKeysChests.clear();
        availableLockKeys.clear();
        availableLockKeysObstaclesSorted.clear();
        availableLockKeysChestsSorted.clear();
        availableLockKeysSorted.clear();
        
        // Key lock combinations:
        // obstacles:
        availableLockKeysObstacles.put("button-door1", new String[]{"button1"});
        availableLockKeysObstacles.put("button-door2", new String[]{"button2"});
        availableLockKeysObstacles.put("button-door3", new String[]{"button3"});
        availableLockKeysObstacles.put("button-door4", new String[]{"button4"});
        availableLockKeysObstaclesSorted.add("button-door1");
        availableLockKeysObstaclesSorted.add("button-door2");
        availableLockKeysObstaclesSorted.add("button-door3");
        availableLockKeysObstaclesSorted.add("button-door4");

        availableLockKeysObstacles.put("breakable-wall1", new String[]{"none"});
        availableLockKeysObstacles.put("breakable-wall2", new String[]{"none"});
        availableLockKeysObstacles.put("breakable-wall3", new String[]{"none"});
        availableLockKeysObstacles.put("breakable-wall4", new String[]{"none"});
        availableLockKeysObstaclesSorted.add("breakable-wall1");
        availableLockKeysObstaclesSorted.add("breakable-wall2");
        availableLockKeysObstaclesSorted.add("breakable-wall3");
        availableLockKeysObstaclesSorted.add("breakable-wall4");

        availableLockKeysObstacles.put("block-puzzle1", new String[]{"none"});
        availableLockKeysObstacles.put("block-puzzle2", new String[]{"none"});
        availableLockKeysObstacles.put("block-puzzle3", new String[]{"none"});
        availableLockKeysObstacles.put("block-puzzle4", new String[]{"none"});
        availableLockKeysObstaclesSorted.add("block-puzzle1");
        availableLockKeysObstaclesSorted.add("block-puzzle2");
        availableLockKeysObstaclesSorted.add("block-puzzle3");
        availableLockKeysObstaclesSorted.add("block-puzzle4");

        // Chest locks:
        availableLockKeysChests.put("red-chest", new String[]{"red-key"});
        availableLockKeysChests.put("green-chest", new String[]{"green-key"});
        availableLockKeysChests.put("blue-chest", new String[]{"blue-key"});
        availableLockKeysChests.put("yellow-chest", new String[]{"yellow-key"});
        availableLockKeysChests.put("white-chest", new String[]{"white-key"});
        availableLockKeysChests.put("purple-chest", new String[]{"purple-key"});
        availableLockKeysChestsSorted.add("red-chest");
        availableLockKeysChestsSorted.add("green-chest");
        availableLockKeysChestsSorted.add("blue-chest");
        availableLockKeysChestsSorted.add("yellow-chest");
        availableLockKeysChestsSorted.add("white-chest");
        availableLockKeysChestsSorted.add("purple-chest");

        // locks:
        availableLockKeys.put("red-lock", new String[]{"red-key"});
        availableLockKeys.put("green-lock", new String[]{"green-key"});
        availableLockKeys.put("blue-lock", new String[]{"blue-key"});
        availableLockKeys.put("yellow-lock", new String[]{"yellow-key"});
        availableLockKeys.put("white-lock", new String[]{"white-key"});
        availableLockKeys.put("purple-lock", new String[]{"purple-key"});
        availableLockKeysSorted.add("red-lock");
        availableLockKeysSorted.add("green-lock");
        availableLockKeysSorted.add("blue-lock");
        availableLockKeysSorted.add("yellow-lock");
        availableLockKeysSorted.add("white-lock");
        availableLockKeysSorted.add("purple-lock");

        availableLockKeys.put("trial1-lock", new String[]{"trial1-clue"});
        availableLockKeys.put("trial2-lock", new String[]{"trial2-clue"});
        availableLockKeys.put("trial3-lock", new String[]{"trial3-clue"});
        availableLockKeys.put("trial4-lock", new String[]{"trial4-clue"});
        availableLockKeysSorted.add("trial1-lock");
        availableLockKeysSorted.add("trial2-lock");
        availableLockKeysSorted.add("trial3-lock");
        availableLockKeysSorted.add("trial4-lock");

        availableLockKeys.put("combination1-lock", new String[]{"combination1-clue"});
        availableLockKeys.put("combination2-lock", new String[]{"combination2-clue"});
        availableLockKeys.put("combination3-lock", new String[]{"combination3-clue"});
        availableLockKeys.put("combination4-lock", new String[]{"combination4-clue"});
        availableLockKeysSorted.add("combination1-lock");
        availableLockKeysSorted.add("combination2-lock");
        availableLockKeysSorted.add("combination3-lock");
        availableLockKeysSorted.add("combination4-lock");

        availableLockKeys.put("ball-lock", new String[]{"ball-key"});
        availableLockKeys.put("idol-lock", new String[]{"idol-key"});
        availableLockKeys.put("gear-lock", new String[]{"gear-key"});
        availableLockKeys.put("astronaut-lock", new String[]{"astronaut-key"});
        availableLockKeysSorted.add("ball-lock");
        availableLockKeysSorted.add("idol-lock");
        availableLockKeysSorted.add("gear-lock");
        availableLockKeysSorted.add("astronaut-lock");
        
        remainingTriviaTabletFns.clear();
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story1");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story2");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story3");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story4");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story5");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story6");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story7");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story8");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story9");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story10");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story11");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story12");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story13");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story14");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_story15");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_clue1");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_clue2");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_clue3");
        remainingTriviaTabletFns.add("story_trivia_tablet_fn_clue4");
    }

    public World generate(MSXRandom a_r) throws Exception
    {
        return generate(a_r, 2, true);
    }
    
    
    public World generate(MSXRandom a_r, int n_retries, boolean use_0_seed_on_last_try) throws Exception
    {
        r = a_r;
        World w;
                
        for(int i = 0; i<n_retries; i++) {
            this.initKeysAndLocks();
            List<String> usedKeysAndLocks = new ArrayList<>();

            if (i == n_retries - 1 && use_0_seed_on_last_try) {
                r.setSeed(0, 0x5555);  // we know this seed works
                n_times_defaulting_to_safe_seed++;
            }
            System.out.println("PCG.generate: ---- attempt " + i + " (seed "+r.rng_seed1 +"/"+r.rng_seed2+") ----");
            w = new World();
            if (!generateAreaLayouts(w)) continue;
            n_times_reached_generation_stage[0]++;
            if (!generateDivisions(w)) continue;
            n_times_reached_generation_stage[1]++;
            if (!generateInterAreaConnections(w)) continue;  // hardcoded connections
            n_times_reached_generation_stage[2]++;
            w.spanningTree = generateSpanningTree(w, 0);
            if (w.spanningTree == null) continue;
            List<AreaDivision> marsSpanningTree = generateSpanningTree(w, 10);
            List<AreaDivision> moonSpanningTree = generateSpanningTree(w, 11);
            n_times_reached_generation_stage[3]++;
            if (!generateMission(w, w.spanningTree, marsSpanningTree, moonSpanningTree, usedKeysAndLocks)) {
//                System.out.println("    generateMission failed");
                continue;
            }
            n_times_reached_generation_stage[7]++;
            List<AreaDivision> allAreas = new ArrayList<>();
            allAreas.addAll(w.spanningTree);
            allAreas.addAll(marsSpanningTree);
            allAreas.addAll(moonSpanningTree);
            if (!spawnAdditionalObjects(w, allAreas)) continue;
            
            // remove "none" tags:
            for(AreaDivision d:allAreas) {
                d.tags.remove("none");
            }
            for(Area a:w.areas) {
                a.removeTag("none");
            }
            
            // generate tablet contents:
//            System.out.println("Tablet contents seeds: " + r.rng_seed1 + ", " + r.rng_seed2);
            for(int j = 0;j<4;j++) {
                int type = r.nextInt(4);
                w.addTabletContent("combination"+(j + 1)+"-clue", "combination_tablet_type_"+(type+1)+"_fn");
            }
            w.addTabletContent("trial1-clue", "trial_tablet_fn");
            w.addTabletContent("trial2-clue", "trial_tablet_fn");
            w.addTabletContent("trial3-clue", "trial_tablet_fn");
            w.addTabletContent("trial4-clue", "trial_tablet_fn");
            w.addTabletContent("maya-riddle-clue1", "maya_clue1_tablet_fn");
            w.addTabletContent("maya-riddle-clue2", "maya_clue2_tablet_fn");
            w.addTabletContent("maya-riddle-clue3", "maya_clue3_tablet_fn");
            w.addTabletContent("maya-riddle-clue4", "maya_clue4_tablet_fn");
            w.addTabletContent("maya-riddle-clue5", "maya_clue5_tablet_fn");
            for(int j = 0;j<8;j++) {
                int idx = r.nextInt(remainingTriviaTabletFns.size());
                String tablet_fn = remainingTriviaTabletFns.get(idx);
//                System.out.println("trivia: " + idx + " / " + remainingTriviaTabletFns.size() + "  -> [" + tablet_fn + "]");
                w.addTabletContent("story-trivia"+(j+1), tablet_fn);
                remainingTriviaTabletFns.remove(tablet_fn);
            }
            w.addTabletContent("calendar-name-clue", "calendar_name_clue_tablet_fn");
//            for(Area a:w.areas) {
//                List<Pair<Integer, String>> tagList = a.getSortedTagList();
//                for(Pair<Integer, String> tag_position:tagList) {
//                    String tag = tag_position.right;
//                    if (tag.toLowerCase().contains("-clue") &&
//                        tag.toLowerCase().contains("combination")) {
//                        // combination clue:
//                        int type = r.nextInt(4);
//                        w.tabletContent.put(tag, "combination_tablet_type_"+(type+1)+"_fn");
//                    } else if (tag.toLowerCase().contains("-clue") &&
//                        tag.toLowerCase().contains("trial")) {
//                        // trial clue:
//                        w.tabletContent.put(tag, "trial_tablet_fn");
//                    } else if (tag.toLowerCase().contains("riddle-clue1")) {
//                        w.tabletContent.put(tag, "maya_clue1_tablet_fn");
//                    } else if (tag.toLowerCase().contains("riddle-clue2")) {
//                        w.tabletContent.put(tag, "maya_clue2_tablet_fn");
//                    } else if (tag.toLowerCase().contains("riddle-clue3")) {
//                        w.tabletContent.put(tag, "maya_clue3_tablet_fn");
//                    } else if (tag.toLowerCase().contains("riddle-clue4")) {
//                        w.tabletContent.put(tag, "maya_clue4_tablet_fn");
//                    } else if (tag.toLowerCase().contains("story-trivia")) {
//                        // story trivia:
//                        String tablet_fn = remainingTriviaTabletFns.get(r.nextInt(remainingTriviaTabletFns.size()));
//                        w.tabletContent.put(tag, tablet_fn);
//                        remainingTriviaTabletFns.remove(tablet_fn);
//                    } else if (tag.toLowerCase().contains("calendar-name-clue")) {
//                        // story trivia:
//                        w.tabletContent.put(tag, "calendar_name_clue_tablet_fn");
//                    }
//                }
//            }
            
            for(int j = 0;j<4;j++) {
                for(int k = 0;k<8;k++) {
                    w.combinationSolutions[j][k] = r.nextInt(3);
                }
            }

            for(int j = 0;j<4;j++) {
                w.trialTypes[j] = r.nextInt(8);
            }

            for(int j = 0;j<5;j++) {
                w.powerStoneNumbers[j] = r.nextInt(8) + 1;
            }
            
            boolean endingFound = false;
            for(Area a:w.areas) {
                for(int y = 0;y<a.height;y++) {
                    for(int x = 0;x<a.width;x++) {
                        List<String> l = a.tags[x][y];
                        if (l != null && l.contains("ending")) {
                            endingFound = true;
                        }
                    }
                }
            }
            if (!endingFound) {
                throw new Exception("Ending tag not found!");
            }
            
            return w;
        }        
        return null;
    }

    
    public boolean generateAreaLayouts(World w) throws Exception
    {
//        System.out.println("generateAreaLayouts seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        for(int i = 0;i<n_areas;i++) {
//            System.out.println("generateAreaLayouts " + i + " seed: " + r.rng_seed1 + ", " + r.rng_seed2);
            Area a;
            if (predefinedAreaLayouts[i] == null) {
                a = generateArea(i, areaSizes[i][0], areaSizes[i][1]);
            } else {
                a = generateArea(i, areaSizes[i][0], areaSizes[i][1], predefinedAreaLayouts[i], predefinedAreaLayouts_f[i]);
            }
            if (a == null) return false;
            a.areaX = areaDebugPositions[i][0];
            a.areaY = areaDebugPositions[i][1];
            w.areas.add(a);
        }
        return true;
    }

    
    public boolean generateDivisions(World w) throws Exception
    {
        System.out.println("---- generateDivisions seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Step 2: Generate the divisions:
        next_divisionID = 1;

        // Hardcoded divisions:
        int confluenceId1 = getNextDivisionID();
        int confluenceId2 = getNextDivisionID();
        w.areas.get(3).divisionIDs[3][0] = confluenceId1;
        w.areas.get(3).divisionIDs[4][0] = confluenceId1;
        w.areas.get(3).divisionIDs[5][0] = confluenceId1;
        w.areas.get(3).divisionIDs[3][1] = confluenceId2;
        w.areas.get(3).divisionIDs[4][1] = confluenceId2;
        w.areas.get(3).divisionIDs[5][1] = confluenceId2;
        w.areas.get(3).nDivisions += 2;

//        int n_divisions_left = n_divisions - 2;
        List<AreaPoint> divisionSeeds = new ArrayList<>();
        // Generate the minimum # of divisions requested in each area:
        for(int i = 0;i<n_areas;i++) {
//            System.out.println("generateDivisions area " + i + ", seed: " + r.rng_seed1 + ", " + r.rng_seed2);
            while(w.areas.get(i).nDivisions < min_divisions_per_area[i]) {
                AreaPoint seed = randomAreaPoint(w.areas.get(i), true);
                while (seed.a.divisionIDs[seed.x][seed.y] != 0) {
                    seed = randomAreaPoint(w.areas.get(i), true);
                }
                divisionSeeds.add(seed);
                addTag(seed, "seed", null);  // we mark them, so that we do not repeat any
                seed.a.divisionIDs[seed.x][seed.y] = getNextDivisionID();
//                System.out.println("  division: " + (seed.x + seed.y*seed.a.width) + ", " + seed.a.divisionIDs[seed.x][seed.y]);
                seed.a.nDivisions++;
//                n_divisions_left--;
            }
        }
        
//        for(int i = 0;i<n_divisions_left;i++) {
//            AreaPoint seed;
//            seed = randomAreaPoint(w, true);
//            while (seed.a.divisionIDs[seed.x][seed.y] != 0) {
//                seed = randomAreaPoint(w, true);
//            }            
//            divisionSeeds.add(seed);
//            addTag(seed, "seed", null);  // we mark them, so that we do not repeat any
//            seed.a.divisionIDs[seed.x][seed.y] = getNextDivisionID();
//            seed.a.nDivisions++;
//        }
        // remove the temporary tags, which were used only to ensure we have no repetition
        for(AreaPoint seed:divisionSeeds) {
            removeTag(seed, "seed", null);
        }
        floodFillDivisionIDs(w);
        
//        for(Area a:w.areas) {
//            System.out.println("Area " + a.ID + " divisions: " + a.nDivisions);
//        }
        return true;
    }
    
    
    public boolean generateInterAreaConnections(World w) throws Exception
    {
//        System.out.println("generateInterAreaConnections seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        // Hardcoded area connections:
        AreaPoint a0p1 = randomAreaBottomMostPoint(w.areas.get(0), true);
        if (a0p1 == null) return false;
        a0p1.direction = DIRECTION_DOWN;
        addTag(a0p1, "connection", null);
        AreaPoint a0p2 = randomAreaBottomMostPoint(w.areas.get(0), true);
        if (a0p2 == null) return false;
        a0p2.direction = DIRECTION_DOWN;
        addTag(a0p2, "connection", null);
        if (a0p2.x < a0p1.x) {
            // flip them:
            AreaPoint tmp = a0p2;
            a0p2 = a0p1;
            a0p1 = tmp;
        }
        AreaPoint a1p1 = randomAreaTopMostPoint(w.areas.get(1), true);
        if (a1p1 == null) return false;
        a1p1.direction = DIRECTION_UP;
        addTag(a1p1, "connection", null);
        w.interAreaconnections.add(new InterAreaConnection(a0p1, a1p1, InterAreaConnection.BIDIRECTIONAL, r));

        AreaPoint a2p1 = randomAreaTopMostPoint(w.areas.get(2), true);
        if (a2p1 == null) return false;
        a2p1.direction = DIRECTION_UP;
        addTag(a2p1, "connection", null);        
        w.interAreaconnections.add(new InterAreaConnection(a0p2, a2p1, InterAreaConnection.BIDIRECTIONAL, r));

        AreaPoint a1p2 = randomAreaBottomMostPoint(w.areas.get(1), true);
        if (a1p2 == null) return false;
        a1p2.direction = DIRECTION_DOWN;
        addTag(a1p2, "connection", null);
        
        AreaPoint a2p2 = randomAreaBottomMostPoint(w.areas.get(2), true);
        if (a2p2 == null) return false;
        a2p2.direction = DIRECTION_DOWN;
        addTag(a2p2, "connection", null);
        
        w.interAreaconnections.add(new InterAreaConnection(a1p2, new AreaPoint(w.areas.get(3), 0, 0, DIRECTION_UP), InterAreaConnection.BIDIRECTIONAL, r));
        w.interAreaconnections.add(new InterAreaConnection(a2p2, new AreaPoint(w.areas.get(3), 8, 0, DIRECTION_UP), InterAreaConnection.BIDIRECTIONAL, r));
        
        AreaPoint a4p1 = randomAreaTopMostPoint(w.areas.get(4), true);
        if (a4p1 == null) return false;
        a4p1.direction = DIRECTION_UP;
        addTag(a4p1, "connection", null);
        w.interAreaconnections.add(new InterAreaConnection(new AreaPoint(w.areas.get(3), 4, 2, DIRECTION_DOWN), a4p1, InterAreaConnection.BIDIRECTIONAL, r));

        AreaPoint a4p2 = randomAreaBottomMostPoint(w.areas.get(4), true);
        if (a4p2 == null) return false;
        a4p2.direction = DIRECTION_DOWN;
        addTag(a4p2, "connection", null);
        w.interAreaconnections.add(new InterAreaConnection(a4p2, new AreaPoint(w.areas.get(5), 1, 0, DIRECTION_UP), InterAreaConnection.BIDIRECTIONAL, r));
        
        AreaPoint a6p1 = randomAreaRightMostPoint(w.areas.get(6), true);
        if (a6p1 == null) return false;
        a6p1.direction = DIRECTION_RIGHT;
        addTag(a6p1, "connection", null);
        w.interAreaconnections.add(new InterAreaConnection(new AreaPoint(w.areas.get(5), 0, 1, DIRECTION_LEFT), a6p1, InterAreaConnection.BIDIRECTIONAL, r));

        AreaPoint a7p1 = randomAreaLeftMostPoint(w.areas.get(7), true, false);
        if (a7p1 == null) return false;
        a7p1.direction = DIRECTION_LEFT;
        addTag(a7p1, "connection", null);        
        w.interAreaconnections.add(new InterAreaConnection(new AreaPoint(w.areas.get(5), 2, 1, DIRECTION_RIGHT), a7p1, InterAreaConnection.BIDIRECTIONAL, r));
        
        AreaPoint a8p1 = randomAreaTopMostPoint(w.areas.get(8), true);
        if (a8p1 == null) return false;
        a8p1.direction = DIRECTION_UP;
        addTag(a8p1, "connection", null);
        w.interAreaconnections.add(new InterAreaConnection(new AreaPoint(w.areas.get(5), 1, 2, DIRECTION_DOWN), a8p1, InterAreaConnection.BIDIRECTIONAL, r));
        
        AreaPoint a7p3 = randomAreaRightMostPoint(w.areas.get(7), true);
        if (a7p3 == null) return false;
        a7p3.direction = DIRECTION_RIGHT;
        addTag(a7p3, "connection", null);    
        AreaPoint a9p1 = areaBottomLeftMostPoint(w.areas.get(9), true);
        if (a9p1 == null) return false;
        a9p1.direction = DIRECTION_LEFT;
        addTag(a9p1, "connection", null);        
        w.interAreaconnections.add(new InterAreaConnection(a7p3, a9p1, InterAreaConnection.BIDIRECTIONAL, r));
        
        AreaPoint a8p2 = randomAreaTopMostPoint(w.areas.get(8), true);
        if (a8p2 == null) return false;
        a8p2.direction = DIRECTION_UP;
        addTag(a8p2, "connection", null);
        AreaPoint a6p2 = null;
        AreaPoint a7p2 = null;
        if (r.nextBoolean()) {
            // connect caves left to fire temple:
            a6p2 = randomAreaBottomMostPoint(w.areas.get(6), true);
            if (a6p2 == null) return false;
            a6p2.direction = DIRECTION_DOWN;
        } else {
            // connect caves right to fire temple:
            a7p2 = randomAreaBottomMostPoint(w.areas.get(7), true);
            if (a7p2 == null) return false;
            a7p2.direction = DIRECTION_DOWN;
        }
        if (a6p2 != null) {
            w.interAreaconnections.add(new InterAreaConnection(a6p2, a8p2, InterAreaConnection.BIDIRECTIONAL, r));
        }
        if (a7p2 != null) {
            w.interAreaconnections.add(new InterAreaConnection(a7p2, a8p2, InterAreaConnection.BIDIRECTIONAL, r));
        }
        
        removeTag(a0p1, "connection", null);
        removeTag(a0p2, "connection", null);
        removeTag(a1p1, "connection", null);
        removeTag(a1p2, "connection", null);
        removeTag(a2p1, "connection", null);
        removeTag(a2p2, "connection", null);
        removeTag(a4p1, "connection", null);
        removeTag(a4p2, "connection", null);
        removeTag(a4p1, "connection", null);
        removeTag(a4p2, "connection", null);
        removeTag(a6p1, "connection", null);
        if (a6p2 != null) removeTag(a6p2, "connection", null);
        removeTag(a7p1, "connection", null);
        if (a7p2 != null) removeTag(a7p2, "connection", null);
        removeTag(a7p3, "connection", null);
        removeTag(a8p1, "connection", null);
        removeTag(a8p2, "connection", null);
        removeTag(a9p1, "connection", null);
        return true;
    }
    
    
    public List<AreaDivision> generateSpanningTree(World w, int startArea) throws Exception
    {
//        System.out.println("\n\nNEW TREE\n\n");
        List<AreaDivision> tree = new ArrayList<>();
        List<Integer> IDsInTree = new ArrayList<>();
        
        AreaPoint start = randomAreaLeftMostPoint(w.areas.get(startArea), true, startArea==0);
        AreaDivision div = new AreaDivision(start, start.a.divisionIDs[start.x][start.y], null);
        addDivisionToTree(tree, div);
        IDsInTree.add(div.divisionID);
        
        // Add the rest one by one:
        List<AreaDivision> open = new ArrayList<>();
        open.add(div);
        while(!open.isEmpty()) {
//            System.out.println("---- generateSpanningTree loop seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            if (open.size() == 1) {
                div = open.get(0);
            } else {                
                div = open.get(r.nextInt(open.size()));
            }
//            System.out.println("---- pop: " + div.divisionID + " (list size: " + open.size() + ")");
            open.remove(div);
            List<AreaPoint> neighborPoints = getDivisionNeighborPoints(w, div);
            while(!neighborPoints.isEmpty()) {
//                System.out.println("    neighborPoints: " + neighborPoints.size() + ", " + neighborPoints);
                AreaPoint p;
                if (neighborPoints.size() == 1) {
                    p = neighborPoints.remove(0);
                } else {
                    p = neighborPoints.remove(r.nextInt(neighborPoints.size()));
                }

                int id = p.a.divisionIDs[p.x][p.y];
                if (!IDsInTree.contains(id)) {
//                    System.out.println("    child: " + p.x + ", " + p.y);
                    IDsInTree.add(id);
                    AreaDivision div2 = new AreaDivision(p, id, div);
                    p.a.divisionRoot[p.x][p.y] = true;
                    addDivisionToTree(tree, div2);
                    open.add(div2);
                }
            }
        }
        
        // Connect each root with its parent:
        for(AreaDivision d:tree) {
            if (d.parent == null) continue;
            Area a = d.root.a;
            if (d.root.interAreaConnection != null) {
//                a.connections[d.root.x][d.root.y] |= d.root.direction;
//                if (d.root.interAreaConnection.p1 == d.root) {
//                    d.root.interAreaConnection.p2.a.connections[d.root.interAreaConnection.p2.x][d.root.interAreaConnection.p2.y] |= d.root.interAreaConnection.p2.direction;
//                } else {
//                    d.root.interAreaConnection.p1.a.connections[d.root.interAreaConnection.p1.x][d.root.interAreaConnection.p1.y] |= d.root.interAreaConnection.p1.direction;
//                }
            } else {
                a.connections[d.root.x][d.root.y] |= d.root.direction;
//                System.out.println("connection ("+d.divisionID+"->"+d.parent.divisionID+"): " + a.ID + ", " + d.root.direction + ", " + (d.root.x + d.root.y*a.width));
                switch(d.root.direction) {
                    case DIRECTION_LEFT:
                        a.connections[d.root.x - 1][d.root.y] |= DIRECTION_RIGHT;
                        break;
                    case DIRECTION_UP:
                        a.connections[d.root.x][d.root.y - 1] |= DIRECTION_DOWN;
                        break;
                    case DIRECTION_RIGHT:
                        a.connections[d.root.x + 1][d.root.y] |= DIRECTION_LEFT;
                        break;
                    case DIRECTION_DOWN:
                        a.connections[d.root.x][d.root.y + 1] |= DIRECTION_UP;
                        break;
                }
            }
        }
        
        // Count leaves per area:
//        {
//            HashMap<Integer, Integer> leavesPerArea = new HashMap<>();
//            for(AreaDivision d:tree) {
//                if (d.nDescendants == 0) {
//                    if (!leavesPerArea.containsKey(d.root.a.ID)) {
//                        leavesPerArea.put(d.root.a.ID, 1);
//                    } else {
//                        leavesPerArea.put(d.root.a.ID, leavesPerArea.get(d.root.a.ID) + 1);
//                    }
//                }
//            }
//            System.out.println("leavesPerArea: " + leavesPerArea);
//            if (!leavesPerArea.containsKey(1)) {
//                System.out.println("    Area 1 has no leaves!");
//            } else {
//                area_1_n_leaves_accum += leavesPerArea.get(1);
//            }
//            area_1_n_leaves_count ++;
//        }

        // debug visualization of the tree:
//        {
//            w.connections.clear();
//            for(AreaDivision div2:tree) {
//                if (div2.parent == null) continue;
//                w.connections.add(new AreaConnection(div2.parent.root, div2.root, AreaConnection.BIDIRECTIONAL));
////                System.out.println("    ST: " + div2.divisionID + " -> " + div2.parent.divisionID);
//            }
//        }
        
        return tree;
    }
    
    
    public void addDivisionToTree(List<AreaDivision> tree, AreaDivision div)
    {
//        System.out.println("addDivisionToTree: " + div.root.a.ID + ", " + div.root.x + ", " + div.root.y + ", " + (div.root.x + div.root.y*div.root.a.width) + ", " + div.root.direction);
//        System.out.println("    divisionID: " + div.divisionID);
        tree.add(div);
        while(div.parent != null) {
            div = div.parent;
            div.nDescendants ++;
        }
    }
    
    
    public boolean generateMission(World w, List<AreaDivision> tree, 
                                   List<AreaDivision> marsSpanningTree,
                                   List<AreaDivision> moonSpanningTree,
                                   List<String> usedKeysAndLocks) throws Exception
    {
//        System.out.println("generateMission seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        
        // Pick important divisions:
        AreaDivision start = tree.get(0);
        addTag(start.root, "start", start);
        
        AreaPoint teleporter_atlantis_p = randomAreaTopMostPoint(w.areas.get(9), true);
        AreaDivision teleporter_atlantis = getDivisionByID(teleporter_atlantis_p.a.divisionIDs[teleporter_atlantis_p.x][teleporter_atlantis_p.y], tree);
        addTag(randomDivisionPoint(teleporter_atlantis, true), "teleporter-atlantis", teleporter_atlantis);
        AreaDivision teleporter_mars = marsSpanningTree.get(0);
        AreaDivision teleporter_moon = moonSpanningTree.get(0);
//        System.out.println("teleporter-mars");
        addTag(randomDivisionPoint(teleporter_mars, true), "teleporter-mars", teleporter_mars);
//        System.out.println("teleporter-moon");
        addTag(randomDivisionPoint(teleporter_moon, true), "teleporter-moon", teleporter_moon);
        
//        System.out.println("just before boss locations seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));

        AreaDivision boss1 = randomAreaDivisionOnlyLeaves(w.areas.get(1), tree, true);
        if (boss1 == null) {
            return false;
        }
        AreaDivision boss2 = randomAreaDivisionOnlyLeaves(w.areas.get(2), tree, true);
        if (boss2 == null) {
            return false;
        }
        AreaDivision boss3 = randomAreaDivisionOnlyLeaves(w.areas.get(4), tree, true);
        if (boss3 == null) {
            return false;
        }
        AreaDivision boss4 = randomAreaDivisionOnlyLeaves(w.areas.get(8), tree, true);
        if (boss4 == null) {
            return false;
        }
//        System.out.println("boss4 division: " + boss4);
        AreaDivision boss5 = randomAreaDivisionOnlyLeaves(w.areas.get(9), tree, true);
        if (boss5 == null) {
            return false;
        }
//        System.out.println("boss5 division: " + boss5);
        
        AreaDivision boss6 = randomAreaDivisionOnlyLeaves(w.areas.get(10), marsSpanningTree, true);
        if (boss6 == null) {
            return false;
        }
        AreaDivision boss7 = randomAreaDivisionOnlyLeaves(w.areas.get(11), moonSpanningTree, true);
        if (boss7 == null) {
            return false;
        }
        addTag(boss1.root, "boss1-chestlock", boss1);
        addTag(boss2.root, "boss2-chestlock", boss2);
        addTag(boss3.root, "boss3-chestlock", boss3);
        addTag(boss4.root, "boss4-chestlock", boss4);
        addTag(boss5.root, "boss5-chestlock", boss5);
        addTag(boss6.root, "boss6-chestlock", boss6);
        addTag(boss7.root, "boss7-chestlock", boss7);
//        System.out.println("Boss divisions: " +
//                           boss1.divisionID + ", " +
//                           boss2.divisionID + ", " +
//                           boss3.divisionID + ", " +
//                           boss4.divisionID + ", " +
//                           boss5.divisionID + ", " +
//                           boss6.divisionID + ", " +
//                           boss7.divisionID);
        
//        AreaDivision midpoint = randomAreaDivisionFavoringLeaves(w.areas.get(5), tree, true);
        AreaDivision midpoint = getDivisionByID(w.areas.get(5).divisionIDs[1][0], tree);
        w.lockDirections.put("midpoint", DIRECTION_DOWN);
        w.lockKeys.put("midpoint", new ArrayList<>());
        w.lockKeys.get("midpoint").add("boss1");
        w.lockKeys.get("midpoint").add("boss2");
        w.lockKeys.get("midpoint").add("boss3");
        AreaDivision ending = getDivisionByID(w.areas.get(3).divisionIDs[3][0], tree);
        addTag(new AreaPoint(w.areas.get(3), 3, 0), "ending", ending);
        
        // 8-bridge room:
        AreaPoint eightBridgeRoom_p = randomAreaLeftMostNoVerticalConnectionPoint(w.areas.get(6), true);
        if (eightBridgeRoom_p == null) {
            eightBridgeRoom_p = randomAreaLeftMostNoVerticalConnectionPoint(w.areas.get(7), true);
        }
        if (eightBridgeRoom_p != null) {
            // Spawn 8 bridge room:
            AreaDivision eightBridgeRoom = getDivisionByID(eightBridgeRoom_p.a.divisionIDs[eightBridgeRoom_p.x][eightBridgeRoom_p.y], tree);
            addTag(eightBridgeRoom_p, "8-bridge-room", eightBridgeRoom);
            System.out.println("8-bridge-room placed at " + eightBridgeRoom_p);
        } else {
            System.out.println("Cannot place 8-bridge-room!");
        }

//        System.out.println("Key division depths: " +
//                           divisionTreeDepth(boss1) + ", " + 
//                           divisionTreeDepth(boss2) + ", " + 
//                           divisionTreeDepth(boss3) + ", " + 
//                           divisionTreeDepth(boss4) + ", " + 
//                           divisionTreeDepth(boss5) + ", " + 
//                           divisionTreeDepth(midpoint) + ", " + 
//                           divisionTreeDepth(ending));
        
        List<Quest> quests = new ArrayList<>();
//        List<InterAreaConnection> usedConnections = new ArrayList<>();
                
        n_times_reached_generation_stage[4]++;
        
        // for the first 3 bosses, create "current reachable area" up to midpoint, and start process of sub-puzzles:
        List<AreaDivision> useable = reachableArea(tree, start, midpoint);
        List<AreaDivision> reachable = reachableArea(tree, start, midpoint);
        reachable.add(midpoint);

        int n_subquests_per_boss = 3;
        int n_subquests_for_midpoint = 2;
        int n_subquests_for_ending = 2;
        List<QuestSpec> open = new ArrayList<>();
        open.add(new QuestSpec(start, boss1, n_subquests_per_boss, null, null, null, "boss1"));
        open.add(new QuestSpec(start, boss2, n_subquests_per_boss, null, null, null, "boss2"));
        open.add(new QuestSpec(start, boss3, n_subquests_per_boss, null, null, null, "boss3"));
        open.add(new QuestSpec(start, midpoint, n_subquests_for_midpoint, null, null, "start", "midpoint"));
//        open.add(new QuestSpec(start, ending, n_subquests_for_ending, null, null, null, "ending"));
        open.add(new QuestSpec(start, ending, n_subquests_for_ending, null, null, null, null));
        List<Quest> quests1 = generateSubquests(w, tree, open, useable, reachable);
        if (quests1 == null) {
            return false;
        }
        quests.addAll(quests1);
        
        n_times_reached_generation_stage[5]++;
        
        // path to midpoint:
//        QuestSpec q1b = new QuestSpec(boss1, midpoint, 0, null, null, null, null);
//        open = new ArrayList<>();
//        open.add(q1b);
//        List<Quest> quests2 = generateSubquests(w, tree, open, useable, reachable);
//        if (quests2 == null) {
//            return false;
//        }
//        quests.addAll(quests2);
        
        // for the bosses 4 and 5, create "current reachable area" (from midpoint on), and do the same
        QuestSpec q4 = new QuestSpec(midpoint, boss4, n_subquests_per_boss, null, null, null, "boss4");
        QuestSpec q5 = new QuestSpec(midpoint, boss5, n_subquests_per_boss, null, null, null, "boss5");
        useable = reachableArea(tree, midpoint, null);
        reachable = reachableArea(tree, start, null);
        open = new ArrayList<>();
        open.add(q4);
        open.add(q5);
        List<Quest> quests3 = generateSubquests(w, tree, open, useable, reachable);
        if (quests3 == null) return false;
        quests.addAll(quests3);

        // for the bosses 6 and 7, create "current reachable area" from some point in areas 10 and 11, and do the same:
        QuestSpec q6 = new QuestSpec(teleporter_mars, boss6, 2, null, null, null, "boss6");
        useable = reachableArea(marsSpanningTree, teleporter_mars, null);
        reachable = reachableArea(marsSpanningTree, teleporter_mars, null);
        open = new ArrayList<>();
        open.add(q6);
        List<Quest> quests4 = generateSubquests(w, marsSpanningTree, open, useable, reachable);
        if (quests4 == null) return false;
        quests.addAll(quests4);
        
        QuestSpec q7 = new QuestSpec(teleporter_moon, boss7, 2, null, null, null, "boss7");
        useable = reachableArea(moonSpanningTree, teleporter_moon, null);
        reachable = reachableArea(moonSpanningTree, teleporter_moon, null);
        open = new ArrayList<>();
        open.add(q7);
        List<Quest> quests5 = generateSubquests(w, moonSpanningTree, open, useable, reachable);
        if (quests5 == null) return false;
        quests.addAll(quests5);
        
        n_times_reached_generation_stage[6]++;
        
        for(Quest q:quests) {
            if (q.lockPoint != null) {
                List<String> keys = new ArrayList<>();
                keys.addAll(q.keyTags);
                w.lockKeys.put(q.lockTag, keys);
            }
        }
        
        // Delete unused connections:
//        {
//            List<AreaConnection> roDelete = new ArrayList<>();
//            for (AreaConnection c:w.connections) {
//                if (!usedConnections.contains(c)) {
//                    roDelete.add(c);
//                }
//            }
//            w.connections.removeAll(roDelete);
//        }

        return true;
    }
    
    
    public boolean spawnAdditionalObjects(World w, List<AreaDivision> allAreas) throws Exception
    {
        /*
        "Jungle",
        "Temple of Inscriptions",
        "Hidden Temple",
        "Confluence",
        "Inverted Pyramid",
        "Fire Shaft",
        "Pacific Caves",
        "Atlantic Caves",
        "Temple of Fire",
        "Atlantis",
        "Mars Pyramid",
        "Moon Cave",        
        */
        int weaponAreas[] = {
          1, 2, 4, // hammer in inscriptions, macuahuitl in pyramid 2, shield in inverted pyramid
          0, 4, 6, 9, // sling in jungle, blowgun in inverted, atlatl in caves, raygun in atlantis
          7, 8, 9, // obsidian knive in caves, fire hammer in fire temple, ice macuahuitl in atlantis
        };
        String weaponTags[] = {
            "WEAPON_HAMMER",
            "WEAPON_MACUAHUITL",
            "WEAPON_SHIELD",
            "WEAPON_SLING",
            "WEAPON_BLOWGUN",
            "WEAPON_ATLATL",
            "WEAPON_RAYGUN",
            "WEAPON_OBSIDIAN_KNIVE",
            "WEAPON_FIRE_HAMMER",
            "WEAPON_ICE_MACUAHUITL",            
        };
        int mapPieceAreas[] = {
            2, 4,  // hidden / inverted+confluence
            6, 8, 9,  // fireshaft+pacific+atlantic, temple of fire, atlantis
            10, 11,  // mars, moon
        };
        int teleporterAreas[] = {
          0, 1, 2, 4,
          6, 7, 8, 9,
        };
        String teleporterTags[] = {
            "teleporter1",  // jungle
            "teleporter2",  // pyramid 1
            "teleporter3",  // pyramid 2
            "teleporter4",  // inverted pyramid
            "teleporter5",  // caves left
            "teleporter6",  // caves right
            "teleporter7",  // xibalba
            "teleporter8",  // atlantis
        };        
        String optionalItemTags[] = {
          "item-sandals",
          "item-gloves",
          "item-warrior-hat",
          "item-armor",
          "item-chaac",
          "item-seashell",
          "item-belt",
          "item-ice-cape",
        };
        
        String optionalArea8ItemsTags[] = {
            "XIBALBA_CLUE",
            "XIBALBA_STORY1",
            "XIBALBA_STORY2",
            "XIBALBA_STORY3",
            "XIBALBA_STORY4",
            "XIBALBA_STORY5",
            "XIBALBA_LORDS1",
            "XIBALBA_LORDS2",
            "XIBALBA_LORDS3",
            "XIBALBA_LORDS4",
            "XIBALBA_LORDS5",
            "XIBALBA_LORDS6",
            "XIBALBA_LORDS7",
        };
        
        String optionalArea9ItemsTags[] = {
            "ATLANTIS_TABLET2",
            "ATLANTIS_TABLET3",
            "ATLANTIS_TABLET4",
            "ATLANTIS_TABLET5",
        };
        
        List<AreaDivision> tagLess = new ArrayList<>();
        for(AreaDivision d: allAreas) {
            if (d.tags.isEmpty()) {
                tagLess.add(d);
//                System.out.println("    " + d + " tagless");
//            } else {
//                System.out.println("    " + d + ": " + d.tags);
            }
        }
        
        // tagLess divisions per area:
//        {
//            for(int i = 0;i<12;i++) {
//                int n = 0;
//                for(AreaDivision d: allAreas) {
//                    if (d.root.a.ID == i && d.tags.isEmpty()) n++;
//                }
//                System.out.println("tagLess in area " + i + ": " + n);
//            }
//        }
        
//        System.out.println("spawnAdditionalObjects seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
//        System.out.println("tagLess divisions (before): " + tagLess.size() + " / " + allAreas.size());
     
        // lost vendor:
        {
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d:tagLess) {
                if (d.root.a.ID == 2) {  // hidden temple
                    candidates.add(d);
                }
            }
            if (candidates.isEmpty()) {
                System.err.println("No division available for the lost vendor!");
                return false;
            } else {
                int idx = r.nextInt(candidates.size());
//                System.out.println("lost vendor candidates: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
//                System.out.println("lost vendor div / area / offset: " + d.divisionID + ", " + d.root.a.ID + ", " + p.offset());
                addTag(p, "lost-vendor", d);
                tagLess.remove(d);
            }            
        }
                
        // spawn maya secret puzzle clues:
        for(int i = 0;i<5;i++) {
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d:tagLess) {
                if (d.root.a.ID != 10 && d.root.a.ID != 11) {
                    candidates.add(d);
                }
            }
            if (!candidates.isEmpty()) {
                int idx = r.nextInt(candidates.size());
//                System.out.println("maya riddle clue candidates: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
//                System.out.println("maya-riddle-clue "+(i+1)+" div / offset: " + d.divisionID + ", " + p.offset());
                addTag(p, "maya-riddle-clue" + (i+1), d);
                tagLess.remove(d);
            }            
        }
        
        int n_small_keys = 0;
        
        // Spawn weapons (1/16th chance that one is not there):
        for(int i = 0;i<10;i++) {
//            System.out.println("weapon seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
//            System.out.println("weapon seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d:tagLess) {
                if (d.root.a.ID == weaponAreas[i]) {
                    candidates.add(d);
//                    if (d.divisionID == 17) {
//                        System.out.println("   " + d + ": " + d.root.a.ID);
//                    }
                } else {
//                    if (d.divisionID == 17) {
//                        System.out.println("   " + d + ": " + d.root.a.ID);
//                    }
                }
            }
            if (r.nextInt(256) <= 239 && !candidates.isEmpty()) {
                int idx = r.nextInt(candidates.size());
//                System.out.println("weapon candidates: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                if (n_small_keys < 4 && r.nextInt(256) < 63) {
                    // place in a small key chest!
                    n_small_keys++;
                    addTag(p, "small-key-chest" + n_small_keys, d);
//                    System.out.println("weapon (with small key chest) "+weaponTags[i]+" div / offset: " + d.divisionID + ", " + p.offset());
                    w.addChestContent("small-key-chest" + n_small_keys, weaponTags[i]);
                    w.withinChestTag.add(weaponTags[i]);
                } else {
                    addTag(p, weaponTags[i], d);
//                    System.out.println("weapon "+weaponTags[i]+" div / offset: " + d.divisionID + ", " + p.offset());
                }
                tagLess.remove(d);
            }
        }
//        System.out.println("tagLess divisions (after weapons): " + tagLess.size() + " / " + allAreas.size());
        
        // Spawn map pieces: (all are always there)
        for(int i = 0;i<mapPieceAreas.length;i++) {
//            System.out.println("map piece seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d:tagLess) {
                if (d.root.a.ID == mapPieceAreas[i]) {
                    candidates.add(d);
                }
            }
            if (!candidates.isEmpty()) {
                int idx = r.nextInt(candidates.size());
//                System.out.println("map piece: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                addTag(p, "map-piece" + (i+1), d);
//                System.out.println("map piece div / offset: " + d.divisionID + ", " + p.offset());
                tagLess.remove(d);
            }
        }
        
//        System.out.println("tagLess divisions (after mappieces): " + tagLess.size() + " / " + allAreas.size());
        
        // Spawn hearts: (1/16th chance that one is not there)
        for(int i = 0;i<5;i++) {
//            System.out.println("heart seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            if (r.nextInt(256) <= 239 && !tagLess.isEmpty()) {
                int idx = r.nextInt(tagLess.size());
//                System.out.println("heart candidates: " + idx + " / " + tagLess.size() + "  ->  " + tagLess);
                AreaDivision d = tagLess.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                if (n_small_keys < 4 && r.nextInt(256) < 63) {
                    // place in a small key chest!
                    n_small_keys++;
                    addTag(p, "small-key-chest" + n_small_keys, d);
//                    System.out.println("heart"+(i+1)+" (with small key chest) div / offset: " + d.divisionID + ", " + p.offset());
                    w.addChestContent("small-key-chest" + n_small_keys, "heart" + (i+1));
                    w.withinChestTag.add("heart" + (i+1));
                } else {
                    addTag(p, "heart" + (i+1), d);
//                    System.out.println("heart"+(i+1)+" div / offset: " + d.divisionID + ", " + p.offset());
                }
                tagLess.remove(d);
            }            
        }
        
//        System.out.println("tagLess divisions (after hearts): " + tagLess.size() + " / " + allAreas.size());
        
        // Spawn teleporters (1/16th chance that one is not there):
        for(int i = 0;i<8;i++) {
//            System.out.println("teleporter seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d:tagLess) {
                if (d.root.a.ID == teleporterAreas[i]) {
                    candidates.add(d);
                }
            }
            if (r.nextInt(256) <= 239 && !candidates.isEmpty()) {
                int idx = r.nextInt(candidates.size());
//                System.out.println("teleporter candidates (area "+teleporterAreas[i]+"): " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                addTag(p, teleporterTags[i], d);
//                System.out.println("teleporter div / offset: " + d.divisionID + ", " + p.offset());
                tagLess.remove(d);
            }
        }
        
//        System.out.println("tagLess divisions (after teleporters): " + tagLess.size() + " / " + allAreas.size());
        
        // Spawn optional items: (1/16th chance that one is not there)
        for(int i = 0;i<optionalItemTags.length;i++) {
//            System.out.println("optional item seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            List<AreaDivision> candidates = tagLess;
            if (i == 0) {
                // must be spawned in one of the pyramid areas:
                candidates = new ArrayList<>();
                for(AreaDivision d:tagLess) {
                    if (d.root.a.ID == 1 ||
                        d.root.a.ID == 2 ||
                        d.root.a.ID == 3 ||
                        d.root.a.ID == 4) {
                        candidates.add(d);
                    }
                }
            }
            // sandals (i == 0) are always spawned (if possible):
            if ((i == 0 || r.nextInt(256) <= 239) && !candidates.isEmpty()) {
                int idx = r.nextInt(candidates.size());
//                System.out.println("optional candidates: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                if (i != 0 && n_small_keys < 4 && r.nextInt(256) < 63) {
                    // place in a small key chest!
                    n_small_keys++;
                    addTag(p, "small-key-chest" + n_small_keys, d);
//                    System.out.println("optional (within chest) div / offset: " + d.divisionID + ", " + p.offset());
                    w.addChestContent("small-key-chest" + n_small_keys, optionalItemTags[i]);
                    w.withinChestTag.add(optionalItemTags[i]);
                } else {
                    addTag(p, optionalItemTags[i], d);
//                    System.out.println("optional div / offset: " + d.divisionID + ", " + p.offset());
                }
                tagLess.remove(d);
            } else {
//                System.out.println("    skip");
            }
        }
        
//        System.out.println("tagLess divisions (after optional): " + tagLess.size() + " / " + allAreas.size());
        
        // spawn small keys:
        for(int i = 0;i<n_small_keys;i++) {
//            System.out.println("small key seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            if (!tagLess.isEmpty()) {
//                System.out.println("small keys seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
                int idx = r.nextInt(tagLess.size());
//                System.out.println("small key candidates: " + idx + " / " + tagLess.size() + "  ->  " + tagLess);
                AreaDivision d = tagLess.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                addTag(p, "small-key" + (i+1), d);
//                System.out.println("small key div / offset: " + d.divisionID + ", " + p.offset());
                tagLess.remove(d);
            }            
        }
        
//        System.out.println("tagLess divisions (after small keys): " + tagLess.size() + " / " + allAreas.size());
        
        // spawn random trivia:
        for(int i = 0;i<8;i++) {
//            System.out.println("trivia seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            if (r.nextInt(256) <= 239 && !tagLess.isEmpty()) {
                int idx = r.nextInt(tagLess.size());
//                System.out.println("trivia candidates: " + idx + " / " + tagLess.size() + "  ->  " + tagLess);
                AreaDivision d = tagLess.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                addTag(p, "story-trivia" + (i+1), d);
//                System.out.println("trivia div / offset: " + d.divisionID + ", " + p.offset());
                tagLess.remove(d);
            }            
        }
        
//        System.out.println("tagLess divisions (after trivia): " + tagLess.size() + " / " + allAreas.size());
        
        // Spawn calendar name clue (in mars/moon):
        {
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d: tagLess) {
                if (d.root.a.ID == 10 || d.root.a.ID == 11) {
                    candidates.add(d);
                }
            }
            if (!candidates.isEmpty()) {
//                System.out.println("calendar name clue seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
                int idx = r.nextInt(candidates.size());
//                System.out.println("calendar name clue candidates: " + idx + " / " + candidates.size() + "  ->  " + candidates);
                AreaDivision d = candidates.get(idx);
                AreaPoint p = randomDivisionPoint(d, true);
                addTag(p, "calendar-name-clue", d);
//                System.out.println("calendar name clue div / offset: " + d.divisionID + ", " + p.offset());
                tagLess.remove(d);
            }
        }
        
//        System.out.println("tagLess divisions (after calendar clue): " + tagLess.size() + " / " + allAreas.size());
        
        // spawn xibalba objects:
        for(int i = 0;i<optionalArea8ItemsTags.length;i++) {
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d: tagLess) {
                if (d.root.a.ID == 8) {
                    candidates.add(d);
                }
            }
            if (i==0 || r.nextInt(256) <= 80) {
                if (!candidates.isEmpty()) {
                    int idx = r.nextInt(candidates.size());
                    AreaDivision d = candidates.get(idx);
                    AreaPoint p = randomDivisionPoint(d, true);
                    addTag(p, optionalArea8ItemsTags[i], d);
                    tagLess.remove(d);
                }
            }            
        }

//        System.out.println("tagLess divisions (after xibalba): " + tagLess.size() + " / " + allAreas.size());
        
        // spawn atlantis objects:
        for(int i = 0;i<optionalArea9ItemsTags.length;i++) {
//            System.out.println("Atlantis objects seeds: " + r.rng_seed1 + ", " + r.rng_seed2);
            List<AreaDivision> candidates = new ArrayList<>();
            for(AreaDivision d: tagLess) {
                if (d.root.a.ID == 9) {
                    candidates.add(d);
                }
            }
//            System.out.println("  candidates: " + candidates.size());
            if (i==0 || r.nextInt(256) <= 192) {
                if (!candidates.isEmpty()) {
                    int idx = r.nextInt(candidates.size());
                    AreaDivision d = candidates.get(idx);
                    AreaPoint p = randomDivisionPoint(d, true);
                    addTag(p, optionalArea9ItemsTags[i], d);
                    tagLess.remove(d);
                }
            }            
        }        
//        System.out.println("tagLess divisions (after): " + tagLess.size());
            
        return true;
    }
    
    
    /*
    - useable: divisions that can be used to place new tags (keys, locks, etc.).
    - reachable: divisions that the player can reach (and can be used for pathfinding).
    */
    public List<Quest> generateSubquests(World w, List<AreaDivision> tree, List<QuestSpec> open,
                                         List<AreaDivision> useable, List<AreaDivision> reachable) throws Exception
    {
//        System.out.println("-------- generateSubquests --------");
//        System.out.println("    seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        PCGPatternAtoB pat_a2b = new PCGPatternAtoB();
        PCGPatternObstacle pat_o = new PCGPatternObstacle();
        PCGPatternNKeysAndChestLock pat_kcl = new PCGPatternNKeysAndChestLock();
        PCGPatternNKeysAndLock pat_kl = new PCGPatternNKeysAndLock();
        
        List<Quest> quests = new ArrayList<>();

        while(!open.isEmpty()) {
//            System.out.println("open: " + open.size() + ", useable: " + useable.size() + ", reachable: " + reachable.size());
//            System.out.println("    seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
//            System.out.println("    useable: " + useable);
            QuestSpec qs = open.remove(0);
            Pair<Quest, List<QuestSpec>> tmp = null;
//            System.out.println("    QuestSpec: " + qs);
            // Choose quest:
            if (qs.nSubQuests == 0) {
//                System.out.println("    quest_type: a_to_b");
                // Just a path, no subquests:
                tmp = pat_a2b.generate(w, qs, useable, reachable);
                if (tmp == null) {
//                    System.out.println("    generateSubquests failed a-to-b pattern");
                    return null;
                }            
            } else {
                // choose between quests that require a separate key, or those that do not:
                int quest_type = r.nextInt(3);
//                System.out.println("    initial quest_type: " + quest_type);
                String key_tags[] = null;
                String lock_tag = null;
                if (qs.goalTag != null) {
                    switch(qs.goalTag) {
                        case "boss1":
                        case "boss2":
                        case "boss3":
                        case "boss4":
                        case "boss5":
                        case "boss6":
                        case "boss7":
                            lock_tag = qs.goalTag + "-chestlock";
                            key_tags = new String[]{qs.goalTag + "-key"};
                            quest_type = 1;
                            break;
                        case "midpoint":
                        case "ending":
                        case "none":
                        case "button1":
                        case "button2":
                        case "button3":
                        case "button4":
                            // midpoint or ending cannot be inside a chest!
                            if (quest_type == 1) {
                                quest_type = r.nextInt(2) * 2;  // 0 or 2
    //                            System.out.println("        new quest_type ("+qs.goalTag+"): " + quest_type);
                            }
                            break;
                        default:
                    }
                } else {
                    if (quest_type == 1) {
                        quest_type = r.nextInt(2) * 2;  // 0 or 2
//                            System.out.println("        new quest_type ("+qs.goalTag+"): " + quest_type);
                    }                    
                }

                if (availableLockKeysChestsSorted.isEmpty() && quest_type == 1 && lock_tag == null) {
                    // if we are out of chests, just use key/lock:
                    quest_type = 2;
                }
                
//                System.out.println("key_tags: " + Arrays.toString(key_tags));
                
//                System.out.println("locks left: " + availableLockKeysObstacles.size() + ", " + availableLockKeysChests.size() + ", " + availableLockKeys.size());
    
//                System.out.println("    quest_type: " + quest_type);

                switch(quest_type) {
                    case 0:
                        if (lock_tag == null) {
                            lock_tag = randomLock(availableLockKeysObstaclesSorted);
                            if (lock_tag == null) {
//                                System.out.println("    generateSubquests failed obstacle: no more locks available");
                                return null;
                            }
                            key_tags = availableLockKeysObstacles.get(lock_tag);
                            availableLockKeysObstaclesSorted.remove(lock_tag);
                        }
                        tmp = pat_o.generate(w, qs, key_tags[0], lock_tag, useable, reachable, this);
                        if (tmp == null) {
//                            System.out.println("    generateSubquests failed obstacle pattern");
                            return null;
                        }            
                        break;

                    case 1:
                        if (lock_tag == null) {
                            lock_tag = randomLock(availableLockKeysChestsSorted);
                            if (lock_tag == null) {
//                                System.out.println("    generateSubquests failed key-chest: no more locks available");
                                return null;
                            }
                            key_tags = availableLockKeysChests.get(lock_tag);
                            availableLockKeysChestsSorted.remove(lock_tag);
                        }
                        w.addChestContent(lock_tag, qs.goalTag);
                        w.withinChestTag.add(qs.goalTag);
                        tmp = pat_kcl.generate(w, qs, key_tags, lock_tag, useable, reachable, this);
                        if (tmp == null) {
//                            System.out.println("    generateSubquests failed key-chest pattern");
                            return null;
                        }            
                        break;

                    case 2:
                        if (lock_tag == null) {
                            lock_tag = randomLock(availableLockKeysSorted);
                            if (lock_tag == null) {
//                                System.out.println("    generateSubquests failed key-lock: no more locks available");
                                return null;
                            }
                            key_tags = availableLockKeys.get(lock_tag);
                            availableLockKeysSorted.remove(lock_tag);
                        }
                        tmp = pat_kl.generate(w, qs, key_tags, lock_tag, useable, reachable, this);
                        if (tmp == null) {
//                            System.out.println("    generateSubquests failed key-lock pattern");
                            return null;
                        }            
                        break;
                }
                
                // Remove lock options that use a key that was already used:
                // (this only happens for locks that have a single key)
                if (key_tags != null && key_tags.length == 1) {
                    List<String> toDelete = new ArrayList<>();
                    for(String lock:availableLockKeys.keySet()) {
                        if (availableLockKeys.get(lock)[0].equals(key_tags[0])) {
                            toDelete.add(lock);
                        }
                    }
                    for(String lock:availableLockKeysChests.keySet()) {
                        if (availableLockKeysChests.get(lock)[0].equals(key_tags[0])) {
                            toDelete.add(lock);
                        }
                    }
                    for(String lock:toDelete) {
                        availableLockKeysSorted.remove(lock);
                        availableLockKeysChestsSorted.remove(lock);
                    }
                }
            }
            if (tmp == null) {
//                System.out.println("    generateSubquests failed tmp = null");
                return null;
            }
            
            if (!connectedTree(reachable)) {
                System.err.println("Reachable area became disconnected!");
            }
            
            
            Quest q = tmp.left;
            List<QuestSpec> nextSubquests = tmp.right;
            open.addAll(nextSubquests);
            quests.add(q);
//            if (!q.addTags(w, this)) {
////                System.out.println("    generateSubquests failed adding tags");
//                return null;
//            }
//            if (!q.addPaths(w, this, usedConnections)) {
//                return null;
//            }
        }
        
        return quests;
    }
    
    
    public String randomLock(List<String> sortedLocks) throws Exception
    {
        if (sortedLocks.isEmpty()) return null;
//        System.out.println("        randomLock seeds: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        int n = r.nextInt(sortedLocks.size());
//        System.out.println("        randomLock: " + n + " / " + sortedLocks.size() + "  [" + sortedLocks.get(n) + " = "+AssemblerTags.assemblerID(sortedLocks.get(n))+"]");
        return sortedLocks.get(n);
    }
    
    
    public boolean connectedTree(List<AreaDivision> reachable)
    {
        for(AreaDivision d:reachable) {
            while(d != null) {
                if (!reachable.contains(d)) return false;
                d = d.parent;
            }
        }
        return true;
    }
    
    
    public AreaDivision getDivisionByID(int id, List<AreaDivision> tree)
    {
        for(AreaDivision d:tree) {
            if (d.divisionID == id) return d;
        }
        return null;
    }
    
    
    public List<AreaDivision> reachableArea(List<AreaDivision> tree, AreaDivision start, AreaDivision block)
    {
//        System.out.println("reachableArea:");
        List<AreaDivision> reachable = new ArrayList<>();
        for(AreaDivision d:tree) {
            boolean blocked = false;
            List<AreaDivision> parents = treeParents(d);
            for(AreaDivision d2:parents) {
                if (block != null && block == d2) {
                    blocked = true;
                    break;
                }
            }
            if (!blocked) {
                if (parents.contains(start)) {
                    reachable.add(d);
//                    System.out.println("Reachable: " + d.divisionID);
                }
            }
        }
        return reachable;
    }
    
    
    public List<AreaDivision> treeParents(AreaDivision d)
    {
        List<AreaDivision> parents = new ArrayList<>();
        while(d != null) {
            parents.add(d);
            d = d.parent;
        }
        return parents;
    }
    
    
    public AreaDivision randomAreaDivisionOnlyLeaves(Area a, List<AreaDivision> tree, boolean preferDeeper) throws Exception
    {
        List<AreaDivision> leafCandidates = new ArrayList<>();
        
        int currentDepth = -1;
        for(AreaDivision d:tree) {
            if (a == null || d.root.a.ID == a.ID) {
                if (d.tags == null || d.tags.isEmpty()) {
                    if (d.nDescendants == 0) {
                        if (preferDeeper) {
                            int depth = d.depth();
                            if (depth > currentDepth) {
                                currentDepth = depth;
                                leafCandidates.clear();
                                leafCandidates.add(d);
                            } else if (depth == currentDepth) {
                                leafCandidates.add(d);
                            }
                        } else {
                            leafCandidates.add(d);
                        }
                    }
                }
            }
        }

        if (!leafCandidates.isEmpty()) {
//            System.out.println("randomAreaDivisionOnlyLeaves seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            int idx = r.nextInt(leafCandidates.size());
//            System.out.println("randomAreaDivisionOnlyLeaves: " + idx + " / " + leafCandidates.size() + ": " + leafCandidates);
            return leafCandidates.get(idx);
        }
        // System.err.println("randomAreaDivisionOnlyLeaves: no leaf divisions left in area " + a.ID);
        return null;
    }
    
    
    public AreaDivision randomAreaDivisionFavoringLeaves(Area a, List<AreaDivision> tree, boolean excludeRoot)
    {
//        List<AreaDivision> leafCandidates = new ArrayList<>();
//        List<AreaDivision> otherCandidates = new ArrayList<>();
//        for(AreaDivision d:tree) {
//            if (excludeRoot && d.parent == null) continue;
//            if (d.tags != null && !d.tags.isEmpty()) continue;
//            if (a == null || d.root.a.ID == a.ID) {
//                if (d.nDescendants == 0) {
//                    leafCandidates.add(d);                    
//                } else {
//                    otherCandidates.add(d);                    
//                }
//            }
//        }
//
//        if (!leafCandidates.isEmpty()) {
////            System.out.println("        randomAreaDivisionFavoringLeaves candidate list size (leaf): " + leafCandidates.size());
//            return leafCandidates.get(r.nextInt(leafCandidates.size()));
//        } else if (!otherCandidates.isEmpty()) {
////            System.out.println("        randomAreaDivisionFavoringLeaves candidate list size (non leaf): " + otherCandidates.size());
//            return otherCandidates.get(r.nextInt(otherCandidates.size()));            
//        }
//        return null;
        
        // Alternate implementation, which favors nodes with fewer descendants instead
        // (to prevent blocking lots of tree nodes):
        List<AreaDivision> candidates = new ArrayList<>();
        int best_n_descendants = 255;
        for(AreaDivision d:tree) {
            if (excludeRoot && d.parent == null) continue;
            if (d.tags != null && !d.tags.isEmpty()) continue;
            if (a == null || d.root.a.ID == a.ID) {
                if (d.nDescendants < best_n_descendants) {
//                    System.out.println("" + d.nDescendants);
                    candidates.clear();
                    best_n_descendants = d.nDescendants;
                }
                if (d.nDescendants == best_n_descendants) {
                    candidates.add(d);
                }
            }
        }        
        
        if (!candidates.isEmpty()) {
//            System.out.println("        randomAreaDivisionFavoringLeaves candidate list size ("+best_n_descendants+"): " + candidates.size());
            return candidates.get(r.nextInt(candidates.size()));
        }
        return null;
    }
    
    
    public List<AreaDivision> getDivisionNeighborDivisions(World w, AreaDivision div, List<AreaDivision> tree)
    {
        List<Integer> neighborindDivisionIDs = new ArrayList<>();
        List<AreaPoint> l = getDivisionNeighborPoints(w, div);
        for(AreaPoint p:l) {
            if (!neighborindDivisionIDs.contains(p.a.divisionIDs[p.x][p.y])) {
                neighborindDivisionIDs.add(p.a.divisionIDs[p.x][p.y]);
            }
        }
        
        List<AreaDivision> neighbors = new ArrayList<>();
        for(Integer id:neighborindDivisionIDs) {
            neighbors.add(getDivisionByID(id, tree));
        }
        return neighbors;
    }
    
    
    public List<AreaPoint> getDivisionNeighborPoints(World w, AreaDivision div)
    {
//        int dx[] = {-1, 0, 1, 0};
//        int dy[] = { 0,-1, 0, 1};
//        int direction[] = {DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_LEFT, DIRECTION_UP};
//        List<Integer> neighborIDs = new ArrayList<>();
//        List<AreaPoint> neighbors = new ArrayList<>();
//        Area a = div.root.a;
//        List<Integer> closed = new ArrayList<>();
//        List<Integer> open = new ArrayList<>();
//        open.add(div.root.x + div.root.y * a.width);
//        while(!open.isEmpty()) {
//            int tmp = open.remove(0);
//            closed.add(tmp);
//            int x = tmp % a.width;
//            int y = tmp / a.width;
//            for(int i = 0;i<4;i++) {
//                int x2 = x + dx[i];
//                int y2 = y + dy[i];
//                if (x2 >= 0 && x2 < a.width &&
//                    y2 >= 0 && y2 < a.height &&
//                    a.rooms[x2][y2] >= 0) {
//                    if (a.divisionIDs[x2][y2] == div.divisionID) {
//                        int tmp2 = x2 + y2 * a.width;
//                        if (!open.contains(tmp2) && !closed.contains(tmp2)) {
//                            open.add(tmp2);
//                        }
//                    } else {
//                        int id2 = a.divisionIDs[x2][y2];
//                        if (!neighborIDs.contains(id2)) {
//                            neighborIDs.add(id2);
//                            neighbors.add(new AreaPoint(a, x2, y2, direction[i]));
//                        }
//                    }
//                }
//            }
//        }
        
        // Alternative method, easier to implement in assembler:
        Area a = div.root.a;
        List<AreaPoint> neighbors = new ArrayList<>(); 
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] < 0) continue;
                if (j > 0 &&
                    a.divisionIDs[j - 1][i] == div.divisionID &&
                    a.divisionIDs[j][i] != div.divisionID) {
                    neighbors.add(new AreaPoint(a, j, i, DIRECTION_LEFT));
                    continue;
                }
                if (j < a.width - 1 &&
                    a.divisionIDs[j + 1][i] == div.divisionID &&
                    a.divisionIDs[j][i] != div.divisionID) {
                    neighbors.add(new AreaPoint(a, j, i, DIRECTION_RIGHT));
                    continue;
                }
                if (i > 0 &&
                    a.divisionIDs[j][i - 1] == div.divisionID &&
                    a.divisionIDs[j][i] != div.divisionID) {
                    neighbors.add(new AreaPoint(a, j, i, DIRECTION_UP));
                    continue;
                }
                if (i < a.height - 1 &&
                    a.divisionIDs[j][i + 1] == div.divisionID &&
                    a.divisionIDs[j][i] != div.divisionID) {
                    neighbors.add(new AreaPoint(a, j, i, DIRECTION_DOWN));
                }
            }
        }

//        System.out.println("division: " + div.divisionID);
//        System.out.println("neighbors:");
//        for(AreaPoint p:neighbors) {
//            System.out.println("    " + p + ", divisionID: " + p.a.divisionIDs[p.x][p.y]);
//        }

//        if (neighbors.size() != neighbors2.size()) {
//            System.out.println("n1: " + neighbors.size() + "\tn2: " + neighbors2.size());
//            System.out.println("division: " + div.divisionID);
//            System.out.println("neighbors:");
//            for(AreaPoint p:neighbors) {
//                System.out.println("    " + p + ", divisionID: " + p.a.divisionIDs[p.x][p.y]);
//            }
//            System.out.println("neighbors2:");
//            for(AreaPoint p:neighbors2) {
//                System.out.println("    " + p + ", divisionID: " + p.a.divisionIDs[p.x][p.y]);
//            }
//        }
        
        // Only use bidirectional connections:
        for(InterAreaConnection c:w.interAreaconnections) {
            if (c.p1.a.divisionIDs[c.p1.x][c.p1.y] == div.divisionID &&
                c.direction == InterAreaConnection.BIDIRECTIONAL) {
//                int id2 = c.p2.a.divisionIDs[c.p2.x][c.p2.y];
//                if (!neighborIDs.contains(id2)) {
//                    neighborIDs.add(id2);
                neighbors.add(c.p2);
//                    System.out.println("connection 1: " + c.p1.a.divisionIDs[c.p1.x][c.p1.y] + " -> " + c.p2.a.divisionIDs[c.p2.x][c.p2.y]);
//                }
            }
            if (c.p2.a.divisionIDs[c.p2.x][c.p2.y] == div.divisionID &&
                c.direction == InterAreaConnection.BIDIRECTIONAL) {
//                int id2 = c.p1.a.divisionIDs[c.p1.x][c.p1.y];
//                if (!neighborIDs.contains(id2)) {
//                    neighborIDs.add(id2);
                neighbors.add(c.p1);
//                    System.out.println("connection 2: " + c.p1.a.divisionIDs[c.p1.x][c.p1.y] + " -> " + c.p2.a.divisionIDs[c.p2.x][c.p2.y]);
//                }
            }
        }
        
        return neighbors;
    }
    
    
    public int getNextDivisionID()
    {
        int id = next_divisionID;
        next_divisionID++;
        return id;
    }


    public Area generateArea(int ID, int w, int h) throws Exception
    {
        return generateArea(ID, w, h, null, 0.0);
    }

    
    public Area generateArea(int ID, int w, int h, String layout[], double layoutAdherence) throws Exception
    {
        Area a = new Area(ID, w, h, r.rng_seed1, r.rng_seed2);
        
        if (layout != null && layoutAdherence == 1.0) {
//            System.out.println("generateArea: " + ID + " exact layout");
            // use layout:
            if (layout.length != h || layout[0].length() != w) {
                System.err.println("Area layout does not match expected size!");
                return null;
            }
            a.nRooms = 0;
            for(int i = 0;i<h;i++) {
                for(int j = 0;j<w;j++) {
                    if (layout[i].charAt(j) != '.') {
                        a.rooms[j][i] = a.nRooms;
                        a.nRooms++;                        
                    }
                }
            }
        } else {
//            System.out.println("generateArea: " + ID + " approximate layout");
            // use the layout as a guideline:
            // Grow the area from the center, with a chance of rejecting if the
            // dows not follow the layout:
//            System.out.println("----------------");
//            System.out.println("seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
            a.nRooms = 1;
            a.rooms[w/2][h/2] = 0;
            int target_n_rooms = (w * (h/2));
//            System.out.println("Target number of rooms: " + target_n_rooms);
            while(a.nRooms < target_n_rooms) {
                // pick a random spot in the map:
//                System.out.println("seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
                int y = r.nextInt(h);
                int x = r.nextInt(w);
//                System.out.println("  x, y: " + x + ", " + y);
                if (a.rooms[x][y] == -1 &&
                    ((x > 0 && a.rooms[x - 1][y] >= 0) ||
                     (x < w - 1 && a.rooms[x + 1][y] >= 0) ||
                     (y > 0 && a.rooms[x][y - 1] >= 0) ||
                     (y < h - 1 && a.rooms[x][y + 1] >= 0))) {
                    boolean accept = true;
                    if (layout != null && layout[y].charAt(x) == '.') {
                        int tmp = r.nextInt(256);
//                        System.out.println("        " + tmp + " <= " + (256*layoutAdherence));
                        if (tmp < 256*layoutAdherence)  {
                            accept = false;
                        }
                    }
                    if (accept) {
                       a.rooms[x][y] = a.nRooms;
//                       System.out.println("  room " + x + ", " + y + "  <-  " + a.nRooms);
                       a.nRooms++;
                    }
                }
            }            
        }
        
        return a;
    }
    
    
    public int getRoomArea(Area a, int x, int y)
    {
        int area = 0;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] == a.rooms[x][y]) {
                    area++;
                }
            }
        }
        return area;
    }
    

    public AreaPoint randomAreaLeftMostNoVerticalConnectionPoint(Area a, boolean tagLess) throws Exception
    {
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0 && (j == 0 || a.rooms[j-1][i] < 0)) {
                    if (i > 0 && a.rooms[j][i-1] >= 0) continue;
                    if (i < a.height - 1 && a.rooms[j][i+1] >= 0) continue;
                    if (a.tags[j][i] == null || a.tags[j][i].isEmpty() || !tagLess) {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
       
        if (candidates.isEmpty()) {
            return null;
        }
        int choice = r.nextInt(candidates.size());
        return candidates.get(choice);
    }
    
    
    public AreaPoint randomAreaLeftMostPoint(Area a, boolean tagLess, boolean topMost) throws Exception
    {
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0 && (j == 0 || a.rooms[j-1][i] < 0)) {
                    if (topMost && i > 0 && a.rooms[j][i-1] >= 0) continue;
                    if (a.tags[j][i] == null || a.tags[j][i].isEmpty() || !tagLess) {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
       
        if (candidates.isEmpty()) {
            return null;
        }
        int choice = r.nextInt(candidates.size());
        return candidates.get(choice);
    }
    
    
    public AreaPoint areaBottomLeftMostPoint(Area a, boolean tagLess) throws Exception
    {
        for(int y = a.height-1;y>=0;y--) {
            for(int x = 0;x<a.width;x++) {
                if ((x == 0 || a.rooms[x - 1][y] < 0) &&
                    a.rooms[x][y] >= 0) {
                    if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                        return new AreaPoint(a, x, y);
                    } else {
                        break;
                    }
                }
            }
        }
        
        return null;
    }    
    

    public AreaPoint randomAreaRightMostPoint(Area a, boolean tagLess) throws Exception
    {
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0 && (j == a.width-1 || a.rooms[j+1][i] < 0)) {
                    if (a.tags[j][i] == null || a.tags[j][i].isEmpty() || !tagLess) {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
       
        if (candidates.isEmpty()) {
            return null;
        }
//        System.out.println("randomAreaRightMostPoint: " + candidates);
//        System.out.println("  seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        int choice = r.nextInt(candidates.size());
//        System.out.println("  choice: " + choice);
//        System.out.println("  randomAreaRightMostPoint: " + candidates.get(choice));
        return candidates.get(choice);        
    }


    public AreaPoint randomAreaTopMostPoint(Area a, boolean tagLess) throws Exception
    {
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0 && (i == 0 || a.rooms[j][i-1] < 0)) {
                    if (a.tags[j][i] == null || a.tags[j][i].isEmpty() || !tagLess) {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
       
        if (candidates.isEmpty()) {
            return null;
        }
//        System.out.println("randomAreaTopMostPoint ("+a.ID+"): " + candidates);
//        System.out.println("  seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        int choice = r.nextInt(candidates.size());
//        System.out.println("  choice: " + choice);
//        System.out.println("  randomAreaTopMostPoint: " + candidates.get(choice));
        return candidates.get(choice);        
    }
    

    public AreaPoint randomAreaBottomMostPoint(Area a, boolean tagLess) throws Exception
    {
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0 && (i == a.height - 1 || a.rooms[j][i+1] < 0)) {
                    if (a.tags[j][i] == null || a.tags[j][i].isEmpty() || !tagLess) {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
       
        if (candidates.isEmpty()) {
            return null;
        }
//        System.out.println("randomAreaBottomMostPoint: " + candidates);
//        System.out.println("  seed: " + Z80Assembler.toHex16bit(r.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(r.rng_seed2, true));
        int choice = r.nextInt(candidates.size());
//        System.out.println("  choice: " + choice);
//        System.out.println("  randomAreaBottomMostPoint: " + candidates.get(choice));
        return candidates.get(choice);
    }
    
    
    // If tagLess == true: only points that have no tags can be selected
    public AreaPoint randomDivisionPoint(AreaDivision d, boolean tagLess)
    {
        Area a = d.root.a;
        List<AreaPoint> candidates = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.divisionIDs[j][i] == d.divisionID) {
                    if (tagLess) {
                        if (a.tags[j][i] == null || a.tags[j][i].isEmpty()) {
                            candidates.add(new AreaPoint(a, j, i));
//                        } else {
//                            System.out.println("        randomDivisionPoint: found tags!" + a.tags[j][i]);
                        }
                    } else {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
//        System.out.println("    randomDivisionPoint from "+d.divisionID+", candidates: " + candidates.size());
        if (candidates.isEmpty()) {
            return null;
        }
        int idx = r.nextInt(candidates.size());
//        System.out.println("randomDivisionPoint: " + idx + " / " + candidates.size() + "  ["+candidates.get(idx).offset()+"]  " + candidates);
        return candidates.get(idx);
    }

    
    // If tagLess == true: only points that have no tags can be selected
    public AreaPoint randomAreaPoint(Area a, boolean tagLess)
    {
        while(true) {
            int p = r.nextInt(a.width * a.height);
//            System.out.println("division rng: " + p);
            int x = p % a.width;
            int y = p / a.width;
            if (a.rooms[x][y] >= 0) {
                if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                    return new AreaPoint(a, x, y);
                }
            }
        }
    }


    // If tagLess == true: only points that have no tags can be selected
    public AreaPoint randomAreaPoint(World w, boolean tagLess)
    {
        while(true) {
            Area a = randomAreaWeightedByArea(w);
            int x = r.nextInt(a.width);
            int y = r.nextInt(a.height);
            if (a.rooms[x][y] >= 0) {
                if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                    return new AreaPoint(a, x, y);
                }
            }
        }
    }
    
    
    public Area randomAreaWeightedByArea(World w)
    {
        int totalRooms = 0;
        for(Area a:w.areas) {
            totalRooms += a.nRooms;
        }
        int tmp = r.nextInt(totalRooms);
        for(Area a:w.areas) {
            if (tmp <= a.nRooms) {
                return a;
            }
            tmp -= a.nRooms;
        }
        System.err.println("We should not be here!");
        return w.areas.get(w.areas.size()-1);
    }
    
    
    // If they "collide", we cannot have them in the same location:
    public boolean tagsCollide(String tag, String tag2) throws Exception
    {
//        System.out.println("tagsCollide: " + tag + " vs " + tag2 + " (" + AssemblerTags.assemblerID(tag) + " vs " + AssemblerTags.assemblerID(tag2) + ")");
        if (tag.contains("-lock") || tag.contains("-door") || tag.contains("breakable-wall") || tag.contains("block-puzzle") || (tag.contains("combination") && tag.contains("lock"))) {
            if (tag2.contains("-lock") || tag2.contains("-door") || tag2.contains("breakable-wall") || tag2.contains("block-puzzle") || (tag2.contains("combination") && tag2.contains("lock"))) {
//                System.out.println("    collision!");
                return true;
            }
        }
        return false;
    }
    
    
    public boolean canPlaceTag(AreaPoint p, String tag, List<String> allowedTags) throws Exception
    {
        List<String> l = p.a.tags[p.x][p.y];
        if (l == null) return true;
        if (l.size() > 1) return false;
        for(String tag2:l) {
            if (tag.equals(tag2)) continue;
            if (tagsCollide(tag, tag2)) {
//                    System.out.println("addTag: two locks/doors in one point!!! " + tag + ", " + tag2);
                return false;
            }
        }
        return true;

//        List<String> l = p.a.tags[p.x][p.y];
//        if (l == null) return true;
//        for(String tag2:l) {
//            if (tag2.equals(tag)) continue;
//            if (allowedTags.contains(tag2)) continue;
//            return false;
//        }
//        return true;
        
//        if (!l.contains(tag)) {
//            for(String tag2:l) {
//                if (tagsCollide(tag, tag2)) {
//                    return false;
//                }
//            }
//        }
//        return true;
    }
    
    
    public boolean canPlaceTag(String tag, AreaDivision div) throws Exception
    {
        List<String> l = div.tags;
        if (l == null) return true;
        if (l.size() > 1) return false;
        for(String tag2:l) {
            if (tag.equals(tag2)) continue;
            if (tagsCollide(tag, tag2)) {
//                    System.out.println("addTag: two locks/doors in one point!!! " + tag + ", " + tag2);
                return false;
            }
        }
        return true;

    }    
    
    
    public boolean addTag(AreaPoint p, String tag, AreaDivision d) throws Exception
    {
        if (tag == null) {
            return false;
        }
        if (tag.equals("none")) {
            return true;
        }
        
//        if (tag.equals("boss6-key")) {
//            System.out.println("!!");
//        }

//        if (d != null) {
//            System.out.println("addTag: " + tag + " (div: "+d.divisionID+", area "+p.a.ID+", offset: " + (p.x + p.y*p.a.width) + ")");
//        } else {
//            System.out.println("addTag: " + tag + " (area "+p.a.ID+", offset: " + (p.x + p.y*p.a.width) + ")");
//        }
        
        List<String> l = p.a.tags[p.x][p.y];
        if (l == null) {
            l = new ArrayList<>();
            p.a.tags[p.x][p.y] = l;
        }
        
//        a.tags[j][i].contains("ending")
        if (!tag.equals("ending") && l.contains("ending")) {
            System.err.println("Adding " + tag + " to ending room! (WorldPCG failed)");
            return false;
        }
        if (!tag.equals("start") && l.contains("start")) {
            System.err.println("Adding " + tag + " to start room! (WorldPCG failed)");
            return false;
        }
        if (!tag.equals("teleporter-atlantis") && l.contains("teleporter-atlantis")) {
            System.err.println("Adding " + tag + " to teleporter-atlantis room! (WorldPCG failed)");
            return false;
        }
                
        if (!l.contains(tag)) {
            if (l.size() > 1) {
                return false;
            }

            for(String tag2:l) {
                if (tag.equals(tag2)) continue;
                if (tagsCollide(tag, tag2)) {
//                    System.out.println("addTag: two locks/doors in one point!!! " + tag + ", " + tag2);
                    return false;
                }
            }
            l.add(tag);
        }

        if (d != null && !d.tags.contains(tag)) {
            if (d.tags.size() > 1) {
                return false;
            }
            for(String tag2:d.tags) {
                if (tag.equals(tag2)) continue;
                if (tagsCollide(tag, tag2)) {
//                    System.out.println("addTag: two locks/doors in one point!!! " + tag + ", " + tag2);
                    return false;
                }
            }

            d.tags.add(tag);
//            System.out.println("    added! " + l + "  --  " + d.tags);
//        } else {
//            System.out.println("    added! " + l);
        }
        
//        if (d != null) {
//            System.out.println("addTag: " + tag + " to division " + d.divisionID + " (area "+d.root.a.ID+", offset: " + (p.x + p.y*p.a.width) + ")");
//        }
        
        return true;
    }
    
    
    public void removeTag(AreaPoint p, String tag, AreaDivision d)
    {
        if (tag == null) return;
        if (d != null) d.tags.remove(tag);
        List<String> l = p.a.tags[p.x][p.y];
        if (l == null) return;
        p.a.tags[p.x][p.y].remove(tag);
    }    
     
    
    public void floodFillDivisionIDs(World w)
    {
        for(Area a:w.areas) {
            floodFillDivisionIDs(a);
        }
    }
    
    
    public void floodFillDivisionIDs(Area a)
    {
        List<AreaPoint> open = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.divisionIDs[j][i] != 0) {
                    open.add(new AreaPoint(a, j, i));
                }
            }
        }
        
        while(!open.isEmpty()) {
//            AreaPoint p = open.remove(r.nextInt(open.size()));
            AreaPoint p = open.remove(0);
            
            if (p.x > 0 &&
                a.rooms[p.x - 1][p.y] >= 0 &&
                a.divisionIDs[p.x - 1][p.y] == 0) {
                a.divisionIDs[p.x - 1][p.y] = a.divisionIDs[p.x][p.y];
                open.add(new AreaPoint(a, p.x - 1, p.y));
            }
            if (p.x < a.width - 1 &&
                a.rooms[p.x + 1][p.y] >= 0 &&
                a.divisionIDs[p.x + 1][p.y] == 0) {
                a.divisionIDs[p.x + 1][p.y] = a.divisionIDs[p.x][p.y];
                open.add(new AreaPoint(a, p.x + 1, p.y));
            }
            if (p.y > 0 &&
                a.rooms[p.x][p.y - 1] >= 0 &&
                a.divisionIDs[p.x][p.y - 1] == 0) {
                a.divisionIDs[p.x][p.y - 1] = a.divisionIDs[p.x][p.y];
                open.add(new AreaPoint(a, p.x, p.y - 1));
            }
            if (p.y < a.height - 1 &&
                a.rooms[p.x][p.y + 1] >= 0 &&
                a.divisionIDs[p.x][p.y + 1] == 0) {
                a.divisionIDs[p.x][p.y + 1] = a.divisionIDs[p.x][p.y];
                open.add(new AreaPoint(a, p.x, p.y + 1));
            }
        }
    }

    
//    public List<AreaPoint> withinAreaPathfinding(Area a, int x1, int y1, int x2, int y2, AreaDivision d1, AreaDivision d2, boolean optimal)
//    {
//        // Path must stay in divisions d1 and d2 (start in d1, and end in d2)
//        int pathDivisionID1 = d1.divisionID;
//        int pathDivisionID2 = d2.divisionID;
//        List<Integer> open = new ArrayList<>();
//        HashMap<Integer, Integer> parent = new HashMap<>();
//        
//        if (a.rooms[x1][y1] < 0) return null;
//        if (a.rooms[x2][y2] < 0) return null;
////        if (pathareaID != a.areaIDs[x2][y2] && a.areaIDs[x2][y2] != 0) {
////            System.err.println("Attempting path between areas " + pathareaID + " and " + a.areaIDs[x2][y2]);
////            return null;
////        }
//        
//        if (x1 == x2 && y1 == y2) {
//            List<AreaPoint> path = new ArrayList<>();
//            path.add(new AreaPoint(a, x1, y1));
//            return path;
//        }
//
//        int start = x1 + y1*a.width;
//        open.add(start);
//        while(!open.isEmpty()) {
//            int tmp;
//            if (optimal) {
//                tmp = open.remove(0);  // shortest path
//            } else {
//                tmp = open.remove(r.nextInt(open.size()));  // not necessarily the shortest path
//            }
//            int x = tmp % a.width;
//            int y = tmp / a.width;
//            
//            if (x == x2 && y == y2) {
//                // We reached the goal:
//                break;
//            }
//            if (x > 0 && a.rooms[x-1][y] >= 0 && (a.divisionIDs[x-1][y] == pathDivisionID1 || a.divisionIDs[x-1][y] == pathDivisionID2)) {
//                boolean canPass = true;
//                if (a.divisionIDs[x-1][y] != a.divisionIDs[x][y]) {
//                    // only allow passing to/from a root in the predefined direction
//                    canPass = false;
//                    if (d2.root.x == x-1 && d2.root.y == y &&
//                        d2.root.direction == DIRECTION_RIGHT) {
//                        canPass = true;
//                    }
//                    if (d1.root.x == x && d1.root.y == y &&
//                        d1.root.direction == DIRECTION_LEFT) {
//                        canPass = true;
//                    }                    
//                }
//                if (canPass) {
//                    int next = tmp - 1;
//                    if (!parent.containsKey(next)) {
//                        open.add(next);
//                        parent.put(next, tmp);
//                    }
//                }
//            }
//            if (x < a.width - 1 && a.rooms[x+1][y] >= 0 && (a.divisionIDs[x+1][y] == pathDivisionID1 || a.divisionIDs[x+1][y] == pathDivisionID2)) {
//                boolean canPass = true;
//                if (a.divisionIDs[x+1][y] != a.divisionIDs[x][y]) {
//                    // only allow passing to/from a root in the predefined direction
//                    canPass = false;
//                    if (d2.root.x == x+1 && d2.root.y == y &&
//                        d2.root.direction == DIRECTION_LEFT) {
//                        canPass = true;
//                    }
//                    if (d1.root.x == x && d1.root.y == y &&
//                        d1.root.direction == DIRECTION_RIGHT) {
//                        canPass = true;
//                    }                    
//                }
//                if (canPass) {
//                    int next = tmp + 1;
//                    if (!parent.containsKey(next)) {
//                        open.add(next);
//                        parent.put(next, tmp);
//                    }
//                }
//            }
//            if (y > 0 && a.rooms[x][y-1] >= 0 && (a.divisionIDs[x][y-1] == pathDivisionID1 || a.divisionIDs[x][y-1] == pathDivisionID2)) {
//                boolean canPass = true;
//                if (a.divisionIDs[x][y-1] != a.divisionIDs[x][y]) {
//                    // only allow passing to/from a root in the predefined direction
//                    canPass = false;
//                    if (d2.root.x == x && d2.root.y == y-1 &&
//                        d2.root.direction == DIRECTION_DOWN) {
//                        canPass = true;
//                    }
//                    if (d1.root.x == x && d1.root.y == y &&
//                        d1.root.direction == DIRECTION_UP) {
//                        canPass = true;
//                    }                    
//                }
//                if (canPass) {
//                    int next = tmp - a.width;
//                    if (!parent.containsKey(next)) {
//                        open.add(next);
//                        parent.put(next, tmp);
//                    }
//                }
//            }
//            if (y < a.height - 1 && a.rooms[x][y+1] >= 0 && (a.divisionIDs[x][y+1] == pathDivisionID1 || a.divisionIDs[x][y+1] == pathDivisionID2)) {
//                boolean canPass = true;
//                if (a.divisionIDs[x][y+1] != a.divisionIDs[x][y]) {
//                    // only allow passing to/from a root in the predefined direction
//                    canPass = false;
//                    if (d2.root.x == x && d2.root.y == y+1 &&
//                        d2.root.direction == DIRECTION_UP) {
//                        canPass = true;
//                    }
//                    if (d1.root.x == x && d1.root.y == y &&
//                        d1.root.direction == DIRECTION_DOWN) {
//                        canPass = true;
//                    }                    
//                }
//                if (canPass) {
//                    int next = tmp + a.width;
//                    if (!parent.containsKey(next)) {
//                        open.add(next);
//                        parent.put(next, tmp);
//                    }
//                }
//            }
//        }
//        
//        if (parent.containsKey(x2 + y2*a.width)) {
//            List<AreaPoint> path = new ArrayList<>();
//            int tmp = x2 + y2*a.width;
//            while(tmp != start) {
//                int x = tmp % a.width;
//                int y = tmp / a.width;
//                path.add(0, new AreaPoint(a, x, y));
//                tmp = parent.get(tmp);
//            }
//            path.add(0, new AreaPoint(a, x1, y1));
//            return path;
//        }
//
////        System.err.println("withinAreaPathfinding: cannot find path from " + x1 + ", " + y1 + " -> " + x2 + ", " + y2 + " (in area " + a.ID + ")");
//        return null;
//    }    
//    
//    
//    public void markOpenPath(List<AreaPoint> path, World w, boolean createInterAreaConnections)
//    {
//        for(int i = 0;i<path.size()-1;i++) {
//            AreaPoint p1 = path.get(i);
//            AreaPoint p2 = path.get(i + 1);
//            Area a1 = p1.a;
//            Area a2 = p2.a;
//            if (a1 == a2) {
//                if (p2.x == p1.x + 1 && p2.y == p1.y) {
//                    a1.connections[p1.x][p1.y] |= DIRECTION_RIGHT;
//                    a1.connections[p2.x][p2.y] |= DIRECTION_LEFT;
//                } else if (p2.x == p1.x - 1 && p2.y == p1.y) {
//                    a1.connections[p1.x][p1.y] |= DIRECTION_LEFT;
//                    a1.connections[p2.x][p2.y] |= DIRECTION_RIGHT;
//                } else if (p2.x == p1.x && p2.y == p1.y - 1) {
//                    a1.connections[p1.x][p1.y] |= DIRECTION_UP;
//                    a1.connections[p2.x][p2.y] |= DIRECTION_DOWN;
//                } else if (p2.x == p1.x && p2.y == p1.y + 1) {
//                    a1.connections[p1.x][p1.y] |= DIRECTION_DOWN;
//                    a1.connections[p2.x][p2.y] |= DIRECTION_UP;
//                }
//            } else if (createInterAreaConnections) {
//                // inter-area connection:
//                w.connections.add(new AreaConnection(p1, p2, AreaConnection.BIDIRECTIONAL));
//            }
//        }
//    }
        
}
