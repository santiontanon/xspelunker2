/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author santi
 */
public class Solver {
    public static boolean solveGame(World w) throws Exception
    {
        System.out.println("Solver: start");
        AreaPoint p = getTagPosition("start", w);
        
        int lastNKeys = 0;
        List<String> keys = new ArrayList<>();
        while(true) {
            List<String> reachableTags = tagsReachableViaFloodFill(p, keys, w);
            if (reachableTags.contains("ending") &&
                reachableTags.contains("boss1") &&
                reachableTags.contains("boss2") &&
                reachableTags.contains("boss3") &&
                reachableTags.contains("boss4") &&
                reachableTags.contains("boss5")) {
                System.out.println("solved!");
                return true;
            }
            if (reachableTags.size() == lastNKeys) return false;
            lastNKeys = reachableTags.size();
            keys = reachableTags;
        }
    }
    
    
    public static List<String> tagsReachableViaFloodFill(AreaPoint start, List<String> keys, World w)
    {
        List<String> tags = new ArrayList<>();
        
        List<AreaPoint> closed = new ArrayList<>();
        List<AreaPoint> open = new ArrayList<>();
        open.add(start);
        while(!open.isEmpty()) {
//            System.out.println(closed.size() + " - " + open.size());
            AreaPoint p = open.remove(0);
            closed.add(p);
            if (p.a.tags[p.x][p.y] != null) {
                for(String tag:p.a.tags[p.x][p.y]) {
                    if (!tags.contains(tag)) {
                        tags.add(tag);
                    }
                }
            }
            
            // Find neighbors:
            int dx[] = {-1, 0, 1, 0};
            int dy[] = { 0,-1, 0, 1};
            int directions[] = {PCGWorld.DIRECTION_LEFT, PCGWorld.DIRECTION_UP, PCGWorld.DIRECTION_RIGHT, PCGWorld.DIRECTION_DOWN};
            for(int i = 0;i<4;i++) {
                int x2 = p.x + dx[i];
                int y2 = p.y + dy[i];
                AreaPoint p2 = null;
                if (x2 >= 0 && x2 < p.a.width &&
                    y2 >= 0 && y2 < p.a.height &&
                    p.a.rooms[x2][y2] >= 0) {
                    if (p.a.divisionIDs[x2][y2] != p.a.divisionIDs[p.x][p.y]) {
                        if ((p.a.connections[p.x][p.y] & directions[i]) != 0) {
                            // add only if it's not a lock, or if we have the key:
                            boolean canPass = false;
                            boolean anyLock = false;
                            if (p.a.tags[p.x][p.y] != null) {
                                for(String tag:p.a.tags[p.x][p.y]) {
                                    if (w.lockDirections.containsKey(tag) && 
                                        w.lockDirections.get(tag).equals(directions[i])) {
                                        anyLock = true;
                                        boolean haveAllKeys = true;
                                        for(String keyTag:w.lockKeys.get(tag)) {
                                            if (!keys.contains(keyTag)) {
                                                haveAllKeys = false;
                                            }
                                        }
                                        if (haveAllKeys) {
                                            canPass = true;
                                        }
                                    }
                                }
                            }
                            if (canPass || !anyLock) {
                                p2 = new AreaPoint(p.a, x2, y2);
                            }
                        }
                    } else {
                        p2 = new AreaPoint(p.a, x2, y2);
                    }
                }
                if (p2 != null && !closed.contains(p2) && !open.contains(p2)) {
                    open.add(p2);
                }                
            }
            for(InterAreaConnection c:w.interAreaconnections) {
                AreaPoint p2 = null;
                if (c.p1.equals(p) && (c.direction == InterAreaConnection.BIDIRECTIONAL || c.direction == InterAreaConnection.P1TOP2)) {
                    p2 = c.p2;
                }
                if (c.p2.equals(p) && (c.direction == InterAreaConnection.BIDIRECTIONAL || c.direction == InterAreaConnection.P2TOP1)) {
                    p2 = c.p1;
                }
                if (p2 != null && !closed.contains(p2) && !open.contains(p2)) {
                    open.add(p2);
                }
            }
        }
        
        System.out.println("tagsReachableViaFloodFill (with keys: "+onlyKeys(keys, w)+"): ");
        System.out.println("    keys: " + onlyNewKeys(tags, keys, w));
        System.out.println("    locks: " + onlyNewLocks(tags, keys, w));
        
        return tags;
    }
    
    
    public static AreaPoint getTagPosition(String tag, World w) throws Exception
    {
        List<AreaPoint> l = w.findTagLocations("start");
        if (l.size() != 1) throw new Exception("Solver: tag appears in != 1 locations: " + l);
        return l.get(0);
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
    
    
    public static List<String> onlyKeys(List<String> tags, World w) {
        List<String> keys = new ArrayList<>();
        for(String tag:tags) {
            if (isKey(tag, w)) {
                keys.add(tag);
            }
        }
        return keys;
    }

    
    public static List<String> onlyNewKeys(List<String> tags, List<String> oldKeys, World w) {
        List<String> keys = new ArrayList<>();
        for(String tag:tags) {
            if (isKey(tag, w) && !oldKeys.contains(tag)) {
                keys.add(tag);
            }
        }
        return keys;
    }
    

    public static List<String> onlyLocks(List<String> tags, World w) {
        List<String> locks = new ArrayList<>();
        for(String tag:tags) {
            if (isLock(tag, w)) {
                locks.add(tag);
            }
        }
        return locks;
    }

    
    public static List<String> onlyNewLocks(List<String> tags, List<String> oldLocks, World w) {
        List<String> locks = new ArrayList<>();
        for(String tag:tags) {
            if (isLock(tag, w) && !oldLocks.contains(tag)) {
                locks.add(tag);
            }
        }
        return locks;
    }
    
}
