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
public class Quest {
    public static final int PATH_NONE = 0;
    public static final int PATH_NORMAL = 1;
    public static final int PATH_ONE_STEP = 2;
    
    public String name = null;
    public AreaDivision startDivision = null, goalDivision = null, lockDivision = null;
    public AreaPoint startPoint = null, goalPoint = null, lockPoint = null;
    public String startTag = null, goalTag = null, lockTag = null;
    public int lockToGoalPathType = PATH_NONE;
    public List<AreaDivision> keyDivisions = new ArrayList<>();
    public List<AreaPoint> keyPoints = new ArrayList<>();
    public List<String> keyTags = new ArrayList<>();    
    
    // "reachable" are the divisions that can be used for pathfinding.
    // "useable" are the divisions that can be used for placing locks/keys/etc.
    public List<AreaDivision> reachable = new ArrayList<>();
    public List<AreaDivision> useable = new ArrayList<>();
    
    public Quest(String a_name)
    {
        name = a_name;
    }
    
    
//    public boolean addTags(World w, PCGWorld pcg) throws Exception
//    {
//        if (startTag != null) {
//            if (!pcg.addTag(startPoint, startTag, startDivision)) return false;
//        }
//        if (goalTag != null) {
//            if (!pcg.addTag(goalPoint, goalTag, goalDivision)) return false;
//        }
//        if (lockTag != null) {
//            if (!pcg.addTag(lockPoint, lockTag, lockDivision)) return false;
//        }
//        
//        for(int i = 0;i<keyPoints.size();i++) {
//            if (keyTags.get(i) != null) {
//                if (!pcg.addTag(keyPoints.get(i), keyTags.get(i), keyDivisions.get(i))) return false;
//            }
//        }
//
//        return true;
//    }
    
    /*
    public boolean addPaths(World w, PCGWorld pcg, List<AreaConnection> usedConnections)
    {
        AreaPoint pathToPoint = null;
        AreaDivision pathToPointDivision = null;
//        String pathToTag = null;

        if (lockPoint == null) {
//            if (startPoint != null && goalPoint != null) {
//                if (!addPath(startPoint, goalPoint, startDivision, goalDivision, w, pcg, false)) return false;
//            }    
            pathToPoint = goalPoint;
            pathToPointDivision = goalDivision;
//            pathToTag = goalTag;
        } else {
            pathToPoint = lockPoint;
            pathToPointDivision = lockDivision;
//            pathToTag = lockTag;
//            if (!addPath(startPoint, lockPoint, startDivision, lockDivision, w, pcg, false)) return false;
            if (goalPoint != null) {
                switch(lockToGoalPathType) {
                    case PATH_NONE:
                        break;
                    case PATH_NORMAL:
                        // System.err.println("path (lock->goal): " + lockTag + " -> " + goalTag);
                        if (!addPath(lockPoint, goalPoint, lockDivision, goalDivision, w, pcg, usedConnections, true)) return false;
                        break;
                    case PATH_ONE_STEP:
                    {
                        List<AreaPoint> path = new ArrayList<>();
                        path.add(lockPoint);
                        path.add(goalPoint);
                        pcg.markOpenPath(path, w, false);
                        break;
                    }
                    default:
                        System.err.println("Unsupported 'lockToGoalPathType': " + lockToGoalPathType);
                }
            }
        }
        
//        if (startPoint != null) {
            for(int i = 0;i<keyPoints.size();i++) {
                AreaPoint keyPoint = keyPoints.get(i);
                if (keyPoint != null) {
//                    if (!addPath(startPoint, keyPoint, startDivision, keyDivisions.get(i), w, pcg, false)) return false;
                    // System.err.println("path (key->lock/goal): " + keyTags.get(i) + " ("+keyDivisions.get(i)+")" + " -> " + pathToTag + " ("+pathToPointDivision+")");
                    if (!addPath(keyPoint, pathToPoint, keyDivisions.get(i), pathToPointDivision, w, pcg, usedConnections, false)) return false;
                }
            }
//        }
        
        return true;
    }
    

    public boolean addPath(AreaPoint p1, AreaPoint p2,
                           AreaDivision d1, AreaDivision d2,
                           World w,
                           PCGWorld pcg,
                           List<AreaConnection> usedConnections,
                           boolean optimal)
    {
        List<AreaDivision> d_path = new ArrayList<>();
        List<AreaDivision> dl1 = pcg.treeParents(d1);
        List<AreaDivision> dl2 = pcg.treeParents(d2);
        
        // System.out.println("dl1: " + dl1);
        // System.out.println("dl2: " + dl2);
        
        if (d1.divisionID == d2.divisionID) {
            d_path.add(d1);

        } else if (dl2.contains(d1)) {
            AreaDivision d = d2;
            while(d != d1) {
                d_path.add(d);
                d = d.parent;
            }
            d_path.add(d);
            Collections.reverse(d_path);
            
        } else if (dl1.contains(d2)) {
            AreaDivision d = d1;
            while(d != d2) {
                d_path.add(d);
                d = d.parent;
            }
            d_path.add(d);
        } else {
            AreaDivision d = d1;
            while(!dl2.contains(d)) {
                d_path.add(d);
                d = d.parent;
            }
            Collections.reverse(dl2);
            while(dl2.get(0) != d) {
                dl2.remove(0);
            }
            d_path.addAll(dl2);
        }
        
        //System.out.println("    d path: " + d1.divisionID + " -> " + d2.divisionID + ": " + d_path);
        
        // Verify reachability: (we do not check the last area, since that might be unreachable)
//        for(int i = 0;i<d_path.size()-1;i++) {
//            AreaDivision d = d_path.get(i);
//            if (!reachable.contains(d)) {
//                System.out.println("Quest: '" +name+ "'. Path ("+d_path+") goes through an unrechable area: " + d.divisionID + " (reachable: " + reachable + ")");
//            }
//        }
        
        List<AreaPoint> path = null;
        if (d_path.size() == 1) {
            path = pcg.withinAreaPathfinding(p1.a, p1.x, p1.y, p2.x, p2.y, d_path.get(0), d_path.get(0), optimal);
        } else {
            path = pcg.withinAreaPathfinding(p1.a, p1.x, p1.y, d_path.get(0).root.x, d_path.get(0).root.y, d_path.get(0), d_path.get(0), optimal);
            if (path == null) {
//                System.err.println("Could not find initial part of a path ("+d_path+") within division " + d_path.get(0));
                return false;                
            }
            for(int i = 0;i<d_path.size()-1;i++) {
                AreaPoint pp1 = d_path.get(i).root;
                AreaPoint pp2 = d_path.get(i + 1).root;
                if (pp1.a != pp2.a) {
                    // Going through an area connection:
                    // Find the connection we want to use:
                    AreaPoint cp1 = null;
                    AreaPoint cp2 = null;
                    AreaConnection used_c = null;
                    for(AreaConnection c:w.connections) {
                        int cd1 = c.p1.a.divisionIDs[c.p1.x][c.p1.y];
                        int cd2 = c.p2.a.divisionIDs[c.p2.x][c.p2.y];
                        if (cd1 == d_path.get(i).divisionID && cd2 == d_path.get(i + 1).divisionID && c.direction == AreaConnection.BIDIRECTIONAL || c.direction == AreaConnection.P1TOP2) {
                            cp1 = c.p1;
                            cp2 = c.p2;
                            used_c = c;
                        }
                        if (cd2 == d_path.get(i).divisionID && cd1 == d_path.get(i + 1).divisionID && c.direction == AreaConnection.BIDIRECTIONAL || c.direction == AreaConnection.P1TOP2) {
                            cp1 = c.p2;
                            cp2 = c.p1;
                            used_c = c;
                        }
                        if (cp1 != null) break;
                    }
                    if (cp1 == null || cp2 == null) {
                        System.err.println("No connection between division " + d_path.get(i).divisionID + " and " + d_path.get(i + 1).divisionID);
                        return false;
                    }
                    
                    if (!usedConnections.contains(used_c)) {
                        usedConnections.add(used_c);
                    }
                    
                    // Path to entrance:
                    List<AreaPoint> path2 = pcg.withinAreaPathfinding(pp1.a, pp1.x, pp1.y, cp1.x, cp1.y, d_path.get(i), d_path.get(i), optimal);
                    if (path2 == null) {
                        return false;
                    }
                    path.addAll(path2);
                    
                    // Path from exit to target point:
                    path2 = pcg.withinAreaPathfinding(pp2.a, cp2.x, cp2.y, pp2.x, pp2.y, d_path.get(i + 1), d_path.get(i + 1), optimal);
                    if (path2 == null) {
                        return false;
                    }
                    path.addAll(path2);

                } else {
                    List<AreaPoint> path2 = pcg.withinAreaPathfinding(pp1.a, pp1.x, pp1.y, pp2.x, pp2.y, d_path.get(i), d_path.get(i + 1), optimal);
                    if (path2 == null) {
                        path2 = pcg.withinAreaPathfinding(pp1.a, pp2.x, pp2.y, pp1.x, pp1.y, d_path.get(i+1), d_path.get(i), optimal);
                        if (path2 != null) {
                            Collections.reverse(path2);
                        } else {
                            System.err.println("Cannot find path (2) from: " + pp2 + " -> " + pp1 + " (divisions: " + d_path.get(i).divisionID + " -> " + d_path.get(i + 1).divisionID + ")");
                        } 
                    }
                    if (path2 != null) path.addAll(path2);
                }
            }
            int l = d_path.size() - 1;
            List<AreaPoint> path2 = pcg.withinAreaPathfinding(p2.a, d_path.get(l).root.x, d_path.get(l).root.y, p2.x, p2.y, d_path.get(l), d_path.get(l), optimal);
            if (path2 == null) {
                System.err.println("Could not find final part of a path ("+d_path+") within division " + d_path.get(l));
                return false;
            } else {
                path.addAll(path2);
            }
        }
        
        if (path != null) {
            pcg.markOpenPath(path, w, false);
//            w.debugPaths.add(path);
        }
        
        return true;
    }
    */
}
