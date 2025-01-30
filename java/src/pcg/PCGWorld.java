/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import pcg.questpatterns.PCGPatternAtoB;
import pcg.questpatterns.PCGPatternNKeysAndChestLock;
import pcg.questpatterns.PCGPatternNKeysAndLock;
import pcg.questpatterns.PCGPatternObstacle;
import util.Pair;

/**
 *
 * @author santi
 * 
 * This class is an implementation of a key-and-lock procedural quest generation
 * that tries to make things as simple as possible, so that it can be translated
 * to z80 assembler easily. Because of that, some routines do things in ways
 * that are suboptimal, or not very well principled, just because they are 
 * easier to translate to assembler this way.
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

    public int n_areas = 10;
    public int n_divisions = 60;
    public String areaNames[] = {
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
    };
    public int areaSizes[][] = {
        {8, 2},
        {8, 8},
        {8, 8},
        {9, 3},
        {10, 8},
        {3, 3},
        {6, 8},
        {6, 8},
        {8, 10},
        {10, 10},
    };
    public String predefinedAreaLayouts[][] = {
        null,
        null,
        null,
        {"x..xxx..x",
         "xxxxxxxxx",
         "....x...."},
        null,
        {".x.",
         "xxx",
         ".x."},
        null,
        null,
        null,
        null,
        };    
    public HashMap<String, String[]> availableLockKeysObstacles = new HashMap<>();
    public HashMap<String, String[]> availableLockKeysChests = new HashMap<>();
    public HashMap<String, String[]> availableLockKeys = new HashMap<>();

    /*
    - to do:        
    ***- Finish generator v1:    
        ***- constrain rooms to division borders
        ***- put on GitHub in case I want to look at something while in London
   
    - Refactor/simplify:
        - draw a diagram of the steps the code goes through, and reorganize/simplify
        - I don't like those endless switch statements. How can I make it easier to add things, and
          easier to translate to assembler? 
        - once I have this, reduce n_times_defaulting_to_safe_seed: 72 (for 0 - 999 seeds)
    
    - to do (optional treasure):
        - sample random rooms that have no tags (ideally in divisions with no tags), and add optional treasure/story trivia labels
             (might or might not be reachable)
            - add "small keys" and some of the objects above are chest_locked with small keys
        - dictionary with puzzles/riddles/hints/story
        - draw them (weapons, supplies, extra HP)
        - add them to the map

    - other ideas for items:
        - pottery, obsidian blade, corn kernels, jade beads, feathers,
          stone tool (e.g. axe head), jade mask, scepter/staff, codices (maya books), human skulls
        - fragments of a calendar stone (maybe this is what you get from the bosses)
    
    - remove decorations like vines, skeletons and flowers, and add them randomly procedurally
    - randomize wall tiles

    - to do (renderer):
        - add enemies (xspelunker enemies for now) (like in xspelunker, each enemy
          has a custom function of where can it be spawned)
    
    - to do (secret quest):
        - distribute a series of k clues needed to unlock something in atlantis
        - ensure there is path to those clues (how? ideally from the nearest path)
        - place the secret goal location (teleporter to mars/moon, clues for each of them are separate), 
          and also ensure path to it
        - mars/moon are generated separately, with their own quests (they are independent)
        - once solved, the same ending room can be used to reach the true ending    
    
    */

    public Random r;
    public int next_divisionID = 1;
    public int n_times_defaulting_to_safe_seed = 0;


    public PCGWorld()
    {
    }
    
    
    public void initKeysAndLocks()
    {
        availableLockKeysObstacles.clear();
        availableLockKeysChests.clear();
        availableLockKeys.clear();
        
        // Key lock combinations:
        // obstacles:
        availableLockKeysObstacles.put("button-door1", new String[]{"button1"});
        availableLockKeysObstacles.put("button-door2", new String[]{"button2"});
        availableLockKeysObstacles.put("button-door3", new String[]{"button3"});
        availableLockKeysObstacles.put("button-door4", new String[]{"button4"});

        availableLockKeysObstacles.put("breakable-wall1", new String[]{"wall1-key"});
        availableLockKeysObstacles.put("breakable-wall2", new String[]{"wall2-key"});
        availableLockKeysObstacles.put("breakable-wall3", new String[]{"wall3-key"});
        availableLockKeysObstacles.put("breakable-wall4", new String[]{"wall4-key"});

        availableLockKeysObstacles.put("block-puzzle1", new String[]{"block-key1"});
        availableLockKeysObstacles.put("block-puzzle2", new String[]{"block-key2"});
        availableLockKeysObstacles.put("block-puzzle3", new String[]{"block-key3"});
        availableLockKeysObstacles.put("block-puzzle4", new String[]{"block-key4"});

        // Chest locks:
        availableLockKeysChests.put("red-chest", new String[]{"red-key"});
        availableLockKeysChests.put("green-chest", new String[]{"green-key"});
        availableLockKeysChests.put("blue-chest", new String[]{"blue-key"});
        availableLockKeysChests.put("yellow-chest", new String[]{"yellow-key"});
        availableLockKeysChests.put("white-chest", new String[]{"white-key"});
        availableLockKeysChests.put("purple-chest", new String[]{"purple-key"});

        // locks:
        availableLockKeys.put("red-lock", new String[]{"red-key"});
        availableLockKeys.put("green-lock", new String[]{"green-key"});
        availableLockKeys.put("blue-lock", new String[]{"blue-key"});
        availableLockKeys.put("yellow-lock", new String[]{"yellow-key"});
        availableLockKeys.put("white-lock", new String[]{"white-key"});
        availableLockKeys.put("purple-lock", new String[]{"purple-key"});

        availableLockKeys.put("trial1-lock", new String[]{"trial1-clue"});
        availableLockKeys.put("trial2-lock", new String[]{"trial2-clue"});
        availableLockKeys.put("trial3-lock", new String[]{"trial3-clue"});
        availableLockKeys.put("trial4-lock", new String[]{"trial4-clue"});

        availableLockKeys.put("combination1-lock", new String[]{"combination1-clue"});
        availableLockKeys.put("combination2-lock", new String[]{"combination2-clue"});
        availableLockKeys.put("combination3-lock", new String[]{"combination3-clue"});

        availableLockKeys.put("ball-lock", new String[]{"ball-key"});
        availableLockKeys.put("idol-lock", new String[]{"idol-key"});
        availableLockKeys.put("gear-lock", new String[]{"gear-key"});
        availableLockKeys.put("astronaut-lock", new String[]{"astronaut-key"});
    }


    public World generate(Random a_r) throws Exception
    {
        r = a_r;
        World w;
                
        // 5 retries:
        int n_retries = 6;
        for(int i = 0; i<n_retries; i++) {
            this.initKeysAndLocks();
            List<String> usedKeysAndLocks = new ArrayList<>();

            if (i == n_retries - 1) {
                r.setSeed(0);  // we know this seed works
                n_times_defaulting_to_safe_seed++;
            }
            System.out.println("PCG.generate: ---- attempt " + i + " ----");
            w = new World();
            if (!generateAreaLayouts(w)) continue;
            if (!generateDivisions(w)) continue;
            if (!generateAreaConnections(w)) continue;  // hardcoded connections
            w.spanningTree = generateSpanningTree(w);
            if (w.spanningTree == null) continue;
            if (!generateMission(w, w.spanningTree, usedKeysAndLocks)) continue;
//            if (!createLoopConnections(w, w.spanningTree)) continue;
            return w;
        }
        return null;
    }

    
    public boolean generateAreaLayouts(World w)
    {
        for(int i = 0;i<n_areas;i++) {
            Area a;
            if (predefinedAreaLayouts[i] == null) {
                a = generateArea(i, areaSizes[i][0], areaSizes[i][1]);
            } else {
                a = generateArea(i, areaSizes[i][0], areaSizes[i][1], predefinedAreaLayouts[i]);
            }
            if (a == null) return false;
            a.areaX = areaDebugPositions[i][0];
            a.areaY = areaDebugPositions[i][1];
            w.areas.add(a);
        }
        return true;
    }

    
    public boolean generateDivisions(World w)
    {
        // Step 2: Generate the divisions:
        
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
        
        List<AreaPoint> divisionSeeds = new ArrayList<>();
        for(int i = 0;i<n_divisions - 2;i++) {
            AreaPoint seed;
            if (i<w.areas.size()) {
                // ensure each area has at least one point:
                seed = randomAreaPoint(w.areas.get(i), true);
            } else {
                seed = randomAreaPoint(w, true);
            }
            
            divisionSeeds.add(seed);
            addTag(seed, "seed");  // we mark them, so that we do not repeat any
            seed.a.divisionIDs[seed.x][seed.y] = getNextDivisionID();
            seed.a.nDivisions++;
        }
        // remove the temporary tags, which were used only to ensure we have no repetition
        for(AreaPoint seed:divisionSeeds) {
            removeTag(seed, "seed");
        }
        floodFillDivisionIDs(w);
        
//        for(Area a:w.areas) {
//            System.out.println("Area " + a.ID + " divisions: " + a.nDivisions);
//        }
        return true;
    }
    
    
    public boolean generateAreaConnections(World w) throws Exception
    {
        // Hardcoded area connections:
        AreaPoint a0p1 = randomAreaBottomMostPoint(w.areas.get(0), true);
        if (a0p1 == null) return false;
        a0p1.direction = DIRECTION_DOWN;
        addTag(a0p1, "connection");
        AreaPoint a0p2 = randomAreaBottomMostPoint(w.areas.get(0), true);
        if (a0p2 == null) return false;
        a0p2.direction = DIRECTION_DOWN;
        addTag(a0p2, "connection");
        if (a0p2.x < a0p1.x) {
            // flip them:
            AreaPoint tmp = a0p2;
            a0p2 = a0p1;
            a0p1 = tmp;
        }
        AreaPoint a1p1 = randomAreaTopMostPoint(w.areas.get(1), true);
        if (a1p1 == null) return false;
        a1p1.direction = DIRECTION_UP;
        addTag(a1p1, "connection");
        AreaPoint a1p2 = randomAreaBottomMostPoint(w.areas.get(1), true);
        if (a1p2 == null) return false;
        a1p2.direction = DIRECTION_DOWN;
        addTag(a1p2, "connection");
        
        AreaPoint a2p1 = randomAreaTopMostPoint(w.areas.get(2), true);
        if (a2p1 == null) return false;
        a2p1.direction = DIRECTION_UP;
        addTag(a2p1, "connection");
        AreaPoint a2p2 = randomAreaBottomMostPoint(w.areas.get(2), true);
        if (a2p2 == null) return false;
        a2p2.direction = DIRECTION_DOWN;
        addTag(a2p2, "connection");

        AreaPoint a4p1 = randomAreaTopMostPoint(w.areas.get(4), true);
        if (a4p1 == null) return false;
        a4p1.direction = DIRECTION_UP;
        addTag(a4p1, "connection");
        AreaPoint a4p2 = randomAreaBottomMostPoint(w.areas.get(4), true);
        if (a4p2 == null) return false;
        a4p2.direction = DIRECTION_DOWN;
        addTag(a4p2, "connection");

        AreaPoint a6p1 = randomAreaRightMostPoint(w.areas.get(6), true);
        if (a6p1 == null) return false;
        a6p1.direction = DIRECTION_RIGHT;
        addTag(a6p1, "connection");
        AreaPoint a6p2 = null;

        AreaPoint a7p1 = randomAreaLeftMostPoint(w.areas.get(7), true);
        if (a7p1 == null) return false;
        a7p1.direction = DIRECTION_LEFT;
        addTag(a7p1, "connection");
        AreaPoint a7p2 = null;
        AreaPoint a7p3 = randomAreaRightMostPoint(w.areas.get(7), true);
        if (a7p3 == null) return false;
        a7p3.direction = DIRECTION_RIGHT;
        addTag(a7p3, "connection");

        AreaPoint a8p1 = randomAreaTopMostPoint(w.areas.get(8), true);
        if (a8p1 == null) return false;
        a8p1.direction = DIRECTION_UP;
        addTag(a8p1, "connection");
        AreaPoint a8p2 = randomAreaTopMostPoint(w.areas.get(8), true);
        if (a8p2 == null) return false;
        a8p2.direction = DIRECTION_UP;
        addTag(a8p2, "connection");
        
        AreaPoint a9p1 = randomAreaLeftMostPoint(w.areas.get(9), true);
        if (a9p1 == null) return false;
        a9p1.direction = DIRECTION_LEFT;
        addTag(a9p1, "connection");
        
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
        
        w.connections.add(new AreaConnection(a0p1, a1p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(a0p2, a2p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(a1p2, new AreaPoint(w.areas.get(3), 0, 0, DIRECTION_UP), AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(a2p2, new AreaPoint(w.areas.get(3), 8, 0, DIRECTION_UP), AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(new AreaPoint(w.areas.get(3), 4, 2, DIRECTION_DOWN), a4p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(a4p2, new AreaPoint(w.areas.get(5), 1, 0, DIRECTION_UP), AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(new AreaPoint(w.areas.get(5), 0, 1, DIRECTION_LEFT), a6p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(new AreaPoint(w.areas.get(5), 2, 1, DIRECTION_RIGHT), a7p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(new AreaPoint(w.areas.get(5), 1, 2, DIRECTION_DOWN), a8p1, AreaConnection.BIDIRECTIONAL));
        w.connections.add(new AreaConnection(a7p3, a9p1, AreaConnection.BIDIRECTIONAL));
        if (a6p2 != null) {
            w.connections.add(new AreaConnection(a6p2, a8p2, AreaConnection.BIDIRECTIONAL));
        }
        if (a7p2 != null) {
            w.connections.add(new AreaConnection(a7p2, a8p2, AreaConnection.BIDIRECTIONAL));
        }
        
        removeTag(a0p1, "connection");
        removeTag(a0p2, "connection");
        removeTag(a1p1, "connection");
        removeTag(a1p2, "connection");
        removeTag(a2p1, "connection");
        removeTag(a2p2, "connection");
        removeTag(a4p1, "connection");
        removeTag(a4p2, "connection");
        removeTag(a4p1, "connection");
        removeTag(a4p2, "connection");
        removeTag(a6p1, "connection");
        if (a6p2 != null) removeTag(a6p2, "connection");
        removeTag(a7p1, "connection");
        if (a7p2 != null) removeTag(a7p2, "connection");
        removeTag(a7p3, "connection");
        removeTag(a8p1, "connection");
        removeTag(a8p2, "connection");
        removeTag(a9p1, "connection");
        return true;
    }
    
    
    public List<AreaDivision> generateSpanningTree(World w) throws Exception
    {
        List<AreaDivision> tree = new ArrayList<>();
        List<Integer> IDsInTree = new ArrayList<>();
        
        AreaPoint start = randomAreaLeftMostPoint(w.areas.get(0), true);
        AreaDivision div = new AreaDivision(start, start.a.divisionIDs[start.x][start.y], null);
        tree.add(div);
        IDsInTree.add(div.divisionID);
        
        // Add the rest one by one:
        List<AreaDivision> open = new ArrayList<>();
        open.add(div);
        while(!open.isEmpty()) {
            div = open.remove(0);
            List<AreaPoint> neighborPoints = getDivisionNeighborPoints(w, div);
            while(!neighborPoints.isEmpty()) {
                AreaPoint p = neighborPoints.remove(r.nextInt(neighborPoints.size()));
                int id = p.a.divisionIDs[p.x][p.y];
                if (!IDsInTree.contains(id)) {
                    IDsInTree.add(id);
                    AreaDivision div2 = new AreaDivision(p, id, div);
                    p.a.divisionRoot[p.x][p.y] = true;
                    addDivisionToTree(tree, div2);
                    open.add(div2);
                }
            }
        }

        // debug visualization of the tree:
//        {
//            w.connections.clear();
//            for(AreaDivision div2:tree) {
//                if (div2.parent == null) continue;
//                w.connections.add(new AreaConnection(div2.parent.root, div2.root, AreaConnection.BIDIRECTIONAL));
//            }
//        }
        
        return tree;
    }
    
    
    public void addDivisionToTree(List<AreaDivision> tree, AreaDivision div)
    {
        tree.add(div);
        while(div.parent != null) {
            div = div.parent;
            div.nDescendants ++;
        }
    }
    
    
    public boolean generateMission(World w, List<AreaDivision> tree, List<String> usedKeysAndLocks)
    {
        // Pick important divisions:
        AreaDivision start = tree.get(0);
        AreaDivision boss1 = randomAreaDivisionOnlyLeaves(w.areas.get(1), tree);
        if (boss1 == null) return false;
        AreaDivision boss2 = randomAreaDivisionOnlyLeaves(w.areas.get(2), tree);
        if (boss2 == null) return false;
        AreaDivision boss3 = randomAreaDivisionOnlyLeaves(w.areas.get(4), tree);
        if (boss3 == null) return false;
        AreaDivision boss4 = randomAreaDivisionOnlyLeaves(w.areas.get(8), tree);
        if (boss4 == null) return false;
        AreaDivision boss5 = randomAreaDivisionOnlyLeaves(w.areas.get(9), tree);
        if (boss5 == null) return false;
        AreaDivision midpoint = randomAreaDivisionFavoringLeaves(w.areas.get(5), tree);
        AreaDivision ending = getDivisionByID(w.areas.get(3).divisionIDs[3][0], tree);

        List<Quest> quests = new ArrayList<>();
        List<AreaConnection> usedConnections = new ArrayList<>();
                
        // for the first 3 bosses, create "current reachable area" up to midpoint, and start process of sub-puzzles:
//        int n_subquests_per_boss = 3;
//        int n_subquests_for_midpoint = 2;
//        int n_subquests_for_ending = 2;
        int n_subquests_per_boss = 3;
        int n_subquests_for_midpoint = 2;
        int n_subquests_for_ending = 2;
        QuestSpec q1 = new QuestSpec(start, boss1, n_subquests_per_boss, null, null, null, "boss1");
        QuestSpec q2 = new QuestSpec(start, boss2, n_subquests_per_boss, null, null, null, "boss2");
        QuestSpec q3 = new QuestSpec(start, boss3, n_subquests_per_boss, null, null, null, "boss3");
         QuestSpec q_m = new QuestSpec(start, midpoint, n_subquests_for_midpoint, null, null, "start", "midpoint");
        QuestSpec q_e = new QuestSpec(start, ending, n_subquests_for_ending, null, null, null, "ending");
        List<AreaDivision> blocks1 = new ArrayList<>();
        blocks1.add(midpoint);
        List<AreaDivision> useable = reachableArea(tree, start, blocks1);
        List<AreaDivision> reachable = reachableArea(tree, start, blocks1);
        reachable.add(midpoint);
        List<QuestSpec> open = new ArrayList<>();
        open.add(q1);
        open.add(q2);
        open.add(q3);
        open.add(q_m);
        open.add(q_e);
        List<Quest> quests1 = generateSubquests(w, tree, open, useable, reachable, usedConnections);
        if (quests1 == null) {
            return false;
        }
        quests.addAll(quests1);
        
        // path to midpoint:
        QuestSpec q1b = new QuestSpec(boss1, midpoint, 0, null, null, null, null);
        open = new ArrayList<>();
        open.add(q1b);
        List<Quest> quests2 = generateSubquests(w, tree, open, useable, reachable, usedConnections);
        if (quests2 == null) {
            return false;
        }
        quests.addAll(quests2);
        
        // for the last 2 bosses, create "current reachable area" (from midpoint on), and do the same
        QuestSpec q4 = new QuestSpec(midpoint, boss4, n_subquests_per_boss, null, null, null, "boss4");
        QuestSpec q5 = new QuestSpec(midpoint, boss5, n_subquests_per_boss, null, null, null, "boss5");
        List<AreaDivision> blocks2 = new ArrayList<>();
        useable = reachableArea(tree, midpoint, blocks2);
        reachable = reachableArea(tree, start, blocks2);
        open = new ArrayList<>();
        open.add(q4);
        open.add(q5);
        List<Quest> quests3 = generateSubquests(w, tree, open, useable, reachable, usedConnections);
        if (quests3 == null) return false;
        quests.addAll(quests3);
        
        
        for(Quest q:quests) {
            if (q.lockPoint != null) {
                List<String> keys = new ArrayList<>();
                keys.addAll(q.keyTags);
                w.lockKeys.put(q.lockTag, keys);
            }
        }
        
        {
            List<AreaConnection> roDelete = new ArrayList<>();
            for (AreaConnection c:w.connections) {
                if (!usedConnections.contains(c)) {
                    roDelete.add(c);
                }
            }
            w.connections.removeAll(roDelete);
        }

        return true;
    }
    
    
    /*
    public boolean createLoopConnections(World w, List<AreaDivision> tree)
    {
        List<Pair<AreaDivision, AreaDivision>> oneWayConnections = new ArrayList<>();
        for(Area a:w.areas) {
            for(int i = 0;i<a.height;i++) {
                for(int j = 0;j<a.width;j++) {
                    if (a.tags[j][i] != null) {
                        for(String tag:a.tags[j][i]) {
                            if (isLock(tag, w)) {
                                AreaDivision d = getDivisionByID(a.divisionIDs[j][i], tree);
                                AreaDivision d2 = getDestinationDivisionOfLock(tag, new AreaPoint(a, j, i), w, tree);
                                
                                if (d2 == null) {
                                    // probably the lock goes through an inter-area connection
                                    continue;
                                }
                                
                                // See if d2 touches with any division with one of its keys:
                                System.out.println("createLoopConnections (2): lock " + tag + " in " + d2);
                                List<AreaDivision> neighbors = getDivisionNeighborDivisions(w, d2, tree);
                                // See if any of these neighbors has one of the necessary keys:
                                for(AreaDivision d3:neighbors) {
                                    if (d3 == d2) continue;
                                    if (d3.parent == d2) continue;
                                    if (d2.parent == d3) continue;
                                    
                                    boolean connect = false;
                                    List<String> keys = getKeysInDivision(w, d3);
                                    System.out.println("    " + d2 + " - " + d3 + "  " + keys);
                                    for(String key:w.lockKeys.get(tag)) {
                                        if (keys.contains(key)) {
                                            connect = true;
                                        }
                                    }
                                    if (connect) {
                                        oneWayConnections.add(new Pair<>(d3, d2));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        System.out.println("createLoopConnections: " + oneWayConnections);
        
        return true;
    }
    
    
    public List<String> getKeysInDivision(World w, AreaDivision d)
    {
        List<String> keys = new ArrayList<>();
        Area a = d.root.a;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.divisionIDs[j][i] == d.divisionID &&
                    a.tags[j][i] != null) {
                    for(String tag:a.tags[j][i]) {
                        if (isKey(tag, w)) {
                            keys.add(tag);
                        }
                    }
                }
            }
        }
        return keys;
    }
    
    
    public List<String> getLocksInDivision(World w, AreaDivision d)
    {
        List<String> locks = new ArrayList<>();
        Area a = d.root.a;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.divisionIDs[j][i] == d.divisionID &&
                    a.tags[j][i] != null) {
                    for(String tag:a.tags[j][i]) {
                        if (isLock(tag, w)) {
                            locks.add(tag);
                        }
                    }
                }
            }
        }
        return locks;
    }    
    
    
    public static boolean isLock(String tag, World w)
    {
        for(String lockTag:w.lockKeys.keySet()) {
            if (tag.equals(lockTag)) {
                return true;
            }
        }
        return false;
    }


    public static boolean isKey(String tag, World w)
    {
        for(String lockTag:w.lockKeys.keySet()) {
            if (w.lockKeys.get(lockTag).contains(tag)) {
                return true;
            }
        }
        return false;
    }

    
    public AreaDivision getDestinationDivisionOfLock(String lock, AreaPoint lock_p, World w, List<AreaDivision> tree)
    {
        if (!w.lockDirections.containsKey(lock)) return null;
        int direction = w.lockDirections.get(lock);
        AreaPoint destination = null;
        switch(direction) {
            case DIRECTION_RIGHT:
                if (lock_p.x < lock_p.a.width - 1) {
                    destination = new AreaPoint(lock_p.a, lock_p.x + 1, lock_p.y);
                }
                break;
            case DIRECTION_LEFT:
                if (lock_p.x > 0) {
                    destination = new AreaPoint(lock_p.a, lock_p.x - 1, lock_p.y);
                }
                break;
            case DIRECTION_DOWN:
                if (lock_p.y < lock_p.a.height - 1) {
                    destination = new AreaPoint(lock_p.a, lock_p.x, lock_p.y + 1);
                }
                break;
            case DIRECTION_UP:
                if (lock_p.y > 0) {
                    destination = new AreaPoint(lock_p.a, lock_p.x, lock_p.y - 1);
                }
                break;

            default:
                return null;
        }
        if (destination == null) return null;
        if (lock_p.a.rooms[destination.x][destination.y] >= 0) {
            return getDivisionByID(lock_p.a.divisionIDs[destination.x][destination.y], tree);
        }
        return null;
    }
    */

    
    /*
    - useable: divisions that can be used to place new tags (keys, locks, etc.).
    - reachable: divisions that the player can reach (and can be used for pathfinding).
    */
    public List<Quest> generateSubquests(World w, List<AreaDivision> tree, List<QuestSpec> open,
                                         List<AreaDivision> useable, List<AreaDivision> reachable,
                                         List<AreaConnection> usedConnections)
    {
        PCGPatternAtoB pat_a2b = new PCGPatternAtoB();
        PCGPatternObstacle pat_o = new PCGPatternObstacle();
        PCGPatternNKeysAndChestLock pat_kcl = new PCGPatternNKeysAndChestLock();
        PCGPatternNKeysAndLock pat_kl = new PCGPatternNKeysAndLock();
        
        List<Quest> quests = new ArrayList<>();

        while(!open.isEmpty()) {
            // System.out.println("open: " + open.size() + ", useable: " + useable.size() + ", reachable: " + reachable.size());
            QuestSpec qs = open.remove(0);
            Pair<Quest, List<QuestSpec>> tmp = null;
            // Choose quest:
            if (qs.nSubQuests == 0) {
                // Just a path, no subquests:
                tmp = pat_a2b.generate(w, qs, useable, reachable);
                if (tmp == null) {
                    return null;
                }            
            } else {
                // choose between quests that require a separate key, or those that do not:
                int quest_type = r.nextInt(3);
                String key_tags[] = null;
                String lock_tag = null;
                switch(qs.goalTag) {
                    case "boss1":
                    case "boss2":
                    case "boss3":
                    case "boss4":
                    case "boss5":
                        lock_tag = qs.goalTag + "-chestlock";
                        key_tags = new String[]{qs.goalTag + "-key"};
                        quest_type = 1;
                        break;
                    default:
                }
                
                if (availableLockKeysChests.isEmpty() && quest_type == 1 && lock_tag == null) {
                    // if we are out of chests, just use key/lock:
                    quest_type = 2;
                }
                
//                System.out.println("locks left: " + availableLockKeysObstacles.size() + ", " + availableLockKeysChests.size() + ", " + availableLockKeys.size());
                
                switch(quest_type) {
                    case 0:
                        if (lock_tag == null) {
                            lock_tag = random_lock(availableLockKeysObstacles);
                            if (lock_tag == null) return null;
                            key_tags = availableLockKeysObstacles.get(lock_tag);
                            availableLockKeysObstacles.remove(lock_tag);
                        }
                        tmp = pat_o.generate(w, qs, key_tags[0], lock_tag, useable, reachable, this);
                        if (tmp == null) {
                            return null;
                        }            
                        break;

                    case 1:
                        if (lock_tag == null) {
                            lock_tag = random_lock(availableLockKeysChests);
                            if (lock_tag == null) return null;
                            key_tags = availableLockKeysChests.get(lock_tag);
                            availableLockKeysChests.remove(lock_tag);
                        }
                        w.chestContent.put(lock_tag, qs.goalTag);
                        w.withinChestTag.add(qs.goalTag);
                        tmp = pat_kcl.generate(w, qs, key_tags, lock_tag, useable, reachable, this);
                        if (tmp == null) {
                            return null;
                        }            
                        break;

                    case 2:
                        if (lock_tag == null) {
                            lock_tag = random_lock(availableLockKeys);
                            if (lock_tag == null) {
                                return null;
                            }
                            key_tags = availableLockKeys.get(lock_tag);
                            availableLockKeys.remove(lock_tag);
                        }
                        tmp = pat_kl.generate(w, qs, key_tags, lock_tag, useable, reachable, this);
                        if (tmp == null) {
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
                        availableLockKeys.remove(lock);
                        availableLockKeysChests.remove(lock);
                    }
                }
                
            }
            if (tmp == null) {
                return null;
            }            
            
            if (!connectedTree(reachable)) {
                System.err.println("Reachable area became disconnected!");
            }
            
            
            Quest q = tmp.left;
            List<QuestSpec> nextSubquests = tmp.right;
            open.addAll(nextSubquests);
            quests.add(q);
            if (!q.addTags(w, this)) {
                return null;
            }
            if (!q.addPaths(w, this, usedConnections)) {
                return null;
            }
        }
        
        return quests;
    }
    
    
    public String random_lock(HashMap<String, String[]> locks)
    {
        int n = r.nextInt(locks.keySet().size());
        for(String lock:locks.keySet()) {
            if (n == 0) return lock;
            n--;
        }
        return null;
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
    
    
    public List<AreaDivision> reachableArea(List<AreaDivision> tree, AreaDivision start, List<AreaDivision> blocks)
    {
        List<AreaDivision> reachable = new ArrayList<>();
        for(AreaDivision d:tree) {
            boolean blocked = false;
            List<AreaDivision> parents = treeParents(d);
            for(AreaDivision d2:parents) {
                if (blocks.contains(d2)) {
                    blocked = true;
                    break;
                }
            }
            if (!blocked) {
                if (parents.contains(start)) {
                    reachable.add(d);
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
    
    
    public AreaDivision randomAreaDivisionOnlyLeaves(Area a, List<AreaDivision> tree)
    {
        List<AreaDivision> leafCandidates = new ArrayList<>();
        for(AreaDivision d:tree) {
            if (a == null || d.root.a.ID == a.ID) {
                if (d.nDescendants == 0) {
                    leafCandidates.add(d);                    
                }
            }
        }

        if (!leafCandidates.isEmpty()) {
            return leafCandidates.get(r.nextInt(leafCandidates.size()));
        }
//        System.err.println("randomAreaDivisionOnlyLeaves: no leaf divisions left in area " + a.ID);
        return null;
    }
    
    
    public AreaDivision randomAreaDivisionFavoringLeaves(Area a, List<AreaDivision> tree)
    {
        List<AreaDivision> leafCandidates = new ArrayList<>();
        List<AreaDivision> otherCandidates = new ArrayList<>();
        for(AreaDivision d:tree) {
            if (a == null || d.root.a.ID == a.ID) {
                if (d.nDescendants == 0) {
                    leafCandidates.add(d);                    
                } else {
                    otherCandidates.add(d);                    
                }
            }
        }

        if (!leafCandidates.isEmpty()) {
            return leafCandidates.get(r.nextInt(leafCandidates.size()));
        } else if (!otherCandidates.isEmpty()) {
            return otherCandidates.get(r.nextInt(otherCandidates.size()));            
        }
        if (a == null) {
            System.out.println("randomAreaDivisionFavoringLeaves: no divisions left!!");
        } else {
            System.out.println("randomAreaDivisionFavoringLeaves: Area " + a.ID + " does not have divisions!!");
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
        int dx[] = {-1, 0, 1, 0};
        int dy[] = { 0,-1, 0, 1};
        int direction[] = {DIRECTION_RIGHT, DIRECTION_DOWN, DIRECTION_LEFT, DIRECTION_UP};
        List<Integer> neighborIDs = new ArrayList<>();
        List<AreaPoint> neighbors = new ArrayList<>();
        Area a = div.root.a;
        List<Integer> closed = new ArrayList<>();
        List<Integer> open = new ArrayList<>();
        open.add(div.root.x + div.root.y * a.width);
        while(!open.isEmpty()) {
            int tmp = open.remove(0);
            closed.add(tmp);
            int x = tmp % a.width;
            int y = tmp / a.width;
            for(int i = 0;i<4;i++) {
                int x2 = x + dx[i];
                int y2 = y + dy[i];
                if (x2 >= 0 && x2 < a.width &&
                    y2 >= 0 && y2 < a.height &&
                    a.rooms[x2][y2] >= 0) {
                    if (a.divisionIDs[x2][y2] == div.divisionID) {
                        int tmp2 = x2 + y2 * a.width;
                        if (!open.contains(tmp2) && !closed.contains(tmp2)) {
                            open.add(tmp2);
                        }
                    } else {
                        int id2 = a.divisionIDs[x2][y2];
                        if (!neighborIDs.contains(id2)) {
                            neighborIDs.add(id2);
                            neighbors.add(new AreaPoint(a, x2, y2, direction[i]));
                        }
                    }
                }
            }
        }
        
        // Only use bidirectional connections:
        for(AreaConnection c:w.connections) {
            if (c.p1.a.divisionIDs[c.p1.x][c.p1.y] == div.divisionID &&
                c.direction == AreaConnection.BIDIRECTIONAL) {
                int id2 = c.p2.a.divisionIDs[c.p2.x][c.p2.y];
                if (!neighborIDs.contains(id2)) {
                    neighborIDs.add(id2);
                    neighbors.add(c.p2);
                }
            }
            if (c.p2.a.divisionIDs[c.p2.x][c.p2.y] == div.divisionID &&
                c.direction == AreaConnection.BIDIRECTIONAL) {
                int id2 = c.p1.a.divisionIDs[c.p1.x][c.p1.y];
                if (!neighborIDs.contains(id2)) {
                    neighborIDs.add(id2);
                    neighbors.add(c.p1);
                }
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


    public Area generateArea(int ID, int w, int h)
    {
        return generateArea(ID, w, h, null);
    }

    
    public Area generateArea(int ID, int w, int h, String layout[])
    {
        Area a = new Area(ID, w, h);

        if (layout == null) {
            // Grow the area from the center:
            a.nRooms = 1;
            a.rooms[w/2][h/2] = 0;
            while(a.nRooms < w * h * 0.5) {
                // pick a random spot in the map:
                int x = r.nextInt(w);
                int y = r.nextInt(h);
                if (a.rooms[x][y] == -1 &&
                    ((x > 0 && a.rooms[x - 1][y] >= 0) ||
                     (x < w - 1 && a.rooms[x + 1][y] >= 0) ||
                     (y > 0 && a.rooms[x][y - 1] >= 0) ||
                     (y < h - 1 && a.rooms[x][y + 1] >= 0))) {
                    a.rooms[x][y] = a.nRooms;
                    a.nRooms++;
                }
            }
        } else {
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
        }
        
        // Merge rooms to make rooms larger:
        for(int i = 0;i<h;i++) {
            for(int j = 0;j<w;j++) {
                if (a.rooms[j][i] >= 0) {
                    int oldRoom = a.rooms[j][i];
                    
                    // try to merge room:
                    if (j > 0 && a.rooms[j - 1][i] >= 0 && a.rooms[j - 1][i] != a.rooms[j][i] && r.nextDouble() < 0.25) {
                        a.rooms[j][i] = a.rooms[j - 1][i];
                        int area = getRoomArea(a, j, i);
                        if (area <= MAX_ROOM_AREA) continue;
                        a.rooms[j][i] = oldRoom;  // undo
                    }
                    if (j < w - 1 && a.rooms[j + 1][i] >= 0 && a.rooms[j + 1][i] != a.rooms[j][i] && r.nextDouble() < 0.25) {
                        a.rooms[j][i] = a.rooms[j + 1][i];
                        int area = getRoomArea(a, j, i);
                        if (area <= MAX_ROOM_AREA) continue;
                        a.rooms[j][i] = oldRoom;  // undo
                    }
                    if (i > 0 && a.rooms[j][i - 1] >= 0 && a.rooms[j][i - 1] != a.rooms[j][i] && r.nextDouble() < 0.25) {
                        a.rooms[j][i] = a.rooms[j][i - 1];
                        int area = getRoomArea(a, j, i);
                        if (area <= MAX_ROOM_AREA) continue;
                        a.rooms[j][i] = oldRoom;  // undo
                    }
                    if (i < h - 1 && a.rooms[j][i + 1] >= 0 && a.rooms[j][i + 1] != a.rooms[j][i] && r.nextDouble() < 0.25) {
                        a.rooms[j][i] = a.rooms[j][i + 1];
                        int area = getRoomArea(a, j, i);
                        if (area <= MAX_ROOM_AREA) continue;
                        a.rooms[j][i] = oldRoom;  // undo
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
    
    
    public AreaPoint randomAreaLeftMostPoint(Area a, boolean tagLess) throws Exception
    {
        int attempts = 100;
        while(attempts > 0) {
            int y = r.nextInt(a.height);
            for(int x = 0;x<a.width ;x++) {
                if (a.rooms[x][y] >= 0) {
                    if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                        return new AreaPoint(a, x, y);
                    } else {
                        break;
                    }
                }
            }
            attempts--;
        }
        return null;
    }
    

    public AreaPoint randomAreaRightMostPoint(Area a, boolean tagLess) throws Exception
    {
        int attempts = 100;
        while(attempts > 0) {
            int y = r.nextInt(a.height);
            for(int x = a.width - 1;x>0;x--) {
                if (a.rooms[x][y] >= 0) {
                    if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                        return new AreaPoint(a, x, y);
                    } else {
                        break;
                    }
                }
            }
            attempts--;
        }
        return null;
    }


    public AreaPoint randomAreaTopMostPoint(Area a, boolean tagLess) throws Exception
    {
        int attempts = 100;
        while(attempts > 0) {
            int x = r.nextInt(a.width);
            for(int y = 0;y<a.height ;y++) {
                if (a.rooms[x][y] >= 0) {
                    if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                        return new AreaPoint(a, x, y);
                    } else {
                        break;
                    }
                }
            }
            attempts--;
        }
        return null;
    }
    

    public AreaPoint randomAreaBottomMostPoint(Area a, boolean tagLess) throws Exception
    {
        int attempts = 100;
        while(attempts > 0) {
            int x = r.nextInt(a.width);
            for(int y = a.height - 1;y>0;y--) {
                if (a.rooms[x][y] >= 0) {
                    if (!tagLess || (a.tags[x][y] == null || a.tags[x][y].isEmpty())) {
                        return new AreaPoint(a, x, y);
                    } else {
                        break;
                    }
                }
            }
            attempts--;
        }
        return null;
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
                        }
                    } else {
                        candidates.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
        if (candidates.isEmpty()) {
            return null;
        }
        return candidates.get(r.nextInt(candidates.size()));
    }

    
    // If tagLess == true: only points that have no tags can be selected
    public AreaPoint randomAreaPoint(Area a, boolean tagLess)
    {
        while(true) {
            int x = r.nextInt(a.width);
            int y = r.nextInt(a.height);
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
    
    
    public boolean addTag(AreaPoint p, String tag)
    {
        if (tag == null) {
            return false;
        }
        List<String> l = p.a.tags[p.x][p.y];
        if (l == null) {
            l = new ArrayList<>();
            p.a.tags[p.x][p.y] = l;
        }
        
        if (!l.contains(tag)) {
            if (tag.contains("-lock") || tag.contains("-door") || tag.contains("breakable-wall") || tag.contains("block-puzzle") || tag.contains("combination")) {
                for(String tag2:l) {
                    if (tag2.contains("-lock") || tag2.contains("-door") || tag2.contains("breakable-wall") || tag2.contains("block-puzzle") || tag2.contains("combination")) {
                        System.out.println("addTag: two locks/doors in one point!!! " + tag + ", " + tag2);
                        return false;
                    }
                }
            }
            l.add(tag);
        }
        
        return true;
    }
    
    
    public void removeTag(AreaPoint p, String tag)
    {
        if (tag == null) return;
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
            AreaPoint p = open.remove(r.nextInt(open.size()));
            
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

    
    public List<AreaPoint> withinAreaPathfinding(Area a, int x1, int y1, int x2, int y2, AreaDivision d1, AreaDivision d2, boolean optimal)
    {
        // Path must stay in divisions d1 and d2 (start in d1, and end in d2)
        int pathDivisionID1 = d1.divisionID;
        int pathDivisionID2 = d2.divisionID;
        List<Integer> open = new ArrayList<>();
        HashMap<Integer, Integer> parent = new HashMap<>();
        
        if (a.rooms[x1][y1] < 0) return null;
        if (a.rooms[x2][y2] < 0) return null;
//        if (pathareaID != a.areaIDs[x2][y2] && a.areaIDs[x2][y2] != 0) {
//            System.err.println("Attempting path between areas " + pathareaID + " and " + a.areaIDs[x2][y2]);
//            return null;
//        }
        
        if (x1 == x2 && y1 == y2) {
            List<AreaPoint> path = new ArrayList<>();
            path.add(new AreaPoint(a, x1, y1));
            return path;
        }

        int start = x1 + y1*a.width;
        open.add(start);
        while(!open.isEmpty()) {
            int tmp;
            if (optimal) {
                tmp = open.remove(0);  // shortest path
            } else {
                tmp = open.remove(r.nextInt(open.size()));  // not necessarily the shortest path
            }
            int x = tmp % a.width;
            int y = tmp / a.width;
            
            if (x == x2 && y == y2) {
                // We reached the goal:
                break;
            }
            if (x > 0 && a.rooms[x-1][y] >= 0 && (a.divisionIDs[x-1][y] == pathDivisionID1 || a.divisionIDs[x-1][y] == pathDivisionID2)) {
                boolean canPass = true;
                if (a.divisionIDs[x-1][y] != a.divisionIDs[x][y]) {
                    // only allow passing to/from a root in the predefined direction
                    canPass = false;
                    if (d2.root.x == x-1 && d2.root.y == y &&
                        d2.root.direction == DIRECTION_RIGHT) {
                        canPass = true;
                    }
                    if (d1.root.x == x && d1.root.y == y &&
                        d1.root.direction == DIRECTION_LEFT) {
                        canPass = true;
                    }                    
                }
                if (canPass) {
                    int next = tmp - 1;
                    if (!parent.containsKey(next)) {
                        open.add(next);
                        parent.put(next, tmp);
                    }
                }
            }
            if (x < a.width - 1 && a.rooms[x+1][y] >= 0 && (a.divisionIDs[x+1][y] == pathDivisionID1 || a.divisionIDs[x+1][y] == pathDivisionID2)) {
                boolean canPass = true;
                if (a.divisionIDs[x+1][y] != a.divisionIDs[x][y]) {
                    // only allow passing to/from a root in the predefined direction
                    canPass = false;
                    if (d2.root.x == x+1 && d2.root.y == y &&
                        d2.root.direction == DIRECTION_LEFT) {
                        canPass = true;
                    }
                    if (d1.root.x == x && d1.root.y == y &&
                        d1.root.direction == DIRECTION_RIGHT) {
                        canPass = true;
                    }                    
                }
                if (canPass) {
                    int next = tmp + 1;
                    if (!parent.containsKey(next)) {
                        open.add(next);
                        parent.put(next, tmp);
                    }
                }
            }
            if (y > 0 && a.rooms[x][y-1] >= 0 && (a.divisionIDs[x][y-1] == pathDivisionID1 || a.divisionIDs[x][y-1] == pathDivisionID2)) {
                boolean canPass = true;
                if (a.divisionIDs[x][y-1] != a.divisionIDs[x][y]) {
                    // only allow passing to/from a root in the predefined direction
                    canPass = false;
                    if (d2.root.x == x && d2.root.y == y-1 &&
                        d2.root.direction == DIRECTION_DOWN) {
                        canPass = true;
                    }
                    if (d1.root.x == x && d1.root.y == y &&
                        d1.root.direction == DIRECTION_UP) {
                        canPass = true;
                    }                    
                }
                if (canPass) {
                    int next = tmp - a.width;
                    if (!parent.containsKey(next)) {
                        open.add(next);
                        parent.put(next, tmp);
                    }
                }
            }
            if (y < a.height - 1 && a.rooms[x][y+1] >= 0 && (a.divisionIDs[x][y+1] == pathDivisionID1 || a.divisionIDs[x][y+1] == pathDivisionID2)) {
                boolean canPass = true;
                if (a.divisionIDs[x][y+1] != a.divisionIDs[x][y]) {
                    // only allow passing to/from a root in the predefined direction
                    canPass = false;
                    if (d2.root.x == x && d2.root.y == y+1 &&
                        d2.root.direction == DIRECTION_UP) {
                        canPass = true;
                    }
                    if (d1.root.x == x && d1.root.y == y &&
                        d1.root.direction == DIRECTION_DOWN) {
                        canPass = true;
                    }                    
                }
                if (canPass) {
                    int next = tmp + a.width;
                    if (!parent.containsKey(next)) {
                        open.add(next);
                        parent.put(next, tmp);
                    }
                }
            }
        }
        
        if (parent.containsKey(x2 + y2*a.width)) {
            List<AreaPoint> path = new ArrayList<>();
            int tmp = x2 + y2*a.width;
            while(tmp != start) {
                int x = tmp % a.width;
                int y = tmp / a.width;
                path.add(0, new AreaPoint(a, x, y));
                tmp = parent.get(tmp);
            }
            path.add(0, new AreaPoint(a, x1, y1));
            return path;
        }

//        System.err.println("withinAreaPathfinding: cannot find path from " + x1 + ", " + y1 + " -> " + x2 + ", " + y2 + " (in area " + a.ID + ")");
        return null;
    }    
    
    
    public void markOpenPath(List<AreaPoint> path, World w, boolean createInterAreaConnections)
    {
        for(int i = 0;i<path.size()-1;i++) {
            AreaPoint p1 = path.get(i);
            AreaPoint p2 = path.get(i + 1);
            Area a1 = p1.a;
            Area a2 = p2.a;
            if (a1 == a2) {
                if (p2.x == p1.x + 1 && p2.y == p1.y) {
                    a1.connections[p1.x][p1.y] |= DIRECTION_RIGHT;
                    a1.connections[p2.x][p2.y] |= DIRECTION_LEFT;
                } else if (p2.x == p1.x - 1 && p2.y == p1.y) {
                    a1.connections[p1.x][p1.y] |= DIRECTION_LEFT;
                    a1.connections[p2.x][p2.y] |= DIRECTION_RIGHT;
                } else if (p2.x == p1.x && p2.y == p1.y - 1) {
                    a1.connections[p1.x][p1.y] |= DIRECTION_UP;
                    a1.connections[p2.x][p2.y] |= DIRECTION_DOWN;
                } else if (p2.x == p1.x && p2.y == p1.y + 1) {
                    a1.connections[p1.x][p1.y] |= DIRECTION_DOWN;
                    a1.connections[p2.x][p2.y] |= DIRECTION_UP;
                }
            } else if (createInterAreaConnections) {
                // inter-area connection:
                w.connections.add(new AreaConnection(p1, p2, AreaConnection.BIDIRECTIONAL));
            }
        }
    }
        
}
