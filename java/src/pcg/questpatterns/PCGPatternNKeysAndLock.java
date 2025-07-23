/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg.questpatterns;

import java.util.ArrayList;
import java.util.List;
import pcg.AreaDivision;
import pcg.AreaPoint;
import pcg.Quest;
import pcg.QuestSpec;
import pcg.World;
import pcg.PCGWorld;
import util.Pair;

/**
 *
 * @author santi
 */
public class PCGPatternNKeysAndLock extends PCGPattern {
    public Pair<Quest, List<QuestSpec>> generate(World w, QuestSpec qs, String keytags[], String locktag, List<AreaDivision> useable, List<AreaDivision> reachable, PCGWorld pcg)
    {
//        System.out.println("PCGPatternNKeysAndLock: " + qs.startTag + " -> " +  Arrays.toString(keytags) + " -> " + locktag + " -> " + qs.goalTag);
        int nKeys = keytags.length;
        Quest q = new Quest(nKeys + "-keys-and-lock: " + qs.start.divisionID + " -> " + qs.goal.divisionID);
        q.useable.addAll(useable);
        q.reachable.addAll(reachable);
        
        q.startDivision = qs.start;
        q.goalDivision = qs.goal;

        q.startPoint = (qs.startPoint == null ? q.startDivision.root:qs.startPoint);
        q.goalPoint = (qs.goalPoint == null ? q.goalDivision.root:qs.goalPoint);
        
        q.startTag = qs.startTag;
        q.goalTag = qs.goalTag;
        
        // Generate key and lock locations:
        // lock is the point that connects to the goal (in the parent area)
        q.lockDivision = q.goalDivision;
        while(true) {
            AreaDivision lockTargetDiv = q.lockDivision;
            q.lockDivision = q.lockDivision.parent;
            if (q.lockDivision == null) {
                return null;
            }
            if (q.lockDivision != null && q.lockDivision.root.a == lockTargetDiv.root.a) {
                switch(lockTargetDiv.root.direction) {
                    case PCGWorld.DIRECTION_RIGHT:
                        q.lockPoint = new AreaPoint(q.lockDivision.root.a, lockTargetDiv.root.x + 1, lockTargetDiv.root.y);
                        w.lockDirections.put(locktag, PCGWorld.DIRECTION_LEFT);
                        break;
                    case PCGWorld.DIRECTION_DOWN:
                        q.lockPoint = new AreaPoint(q.lockDivision.root.a, lockTargetDiv.root.x, lockTargetDiv.root.y + 1);
                        w.lockDirections.put(locktag, PCGWorld.DIRECTION_UP);
                        break;
                    case PCGWorld.DIRECTION_LEFT:
                        q.lockPoint = new AreaPoint(q.lockDivision.root.a, lockTargetDiv.root.x - 1, lockTargetDiv.root.y);
                        w.lockDirections.put(locktag, PCGWorld.DIRECTION_RIGHT);
                        break;
                    case PCGWorld.DIRECTION_UP:
                        q.lockPoint = new AreaPoint(q.lockDivision.root.a, lockTargetDiv.root.x, lockTargetDiv.root.y - 1);
                        w.lockDirections.put(locktag, PCGWorld.DIRECTION_DOWN);
                        break;
                    default:
                        System.err.println("root node of division " + lockTargetDiv.divisionID + " has no direction!");
                }
            } else {
                AreaPoint destination = getConnectionDestination(w, lockTargetDiv.root);
                if (destination == null) {
                    System.out.println("Cannot find connection destination starting at " + lockTargetDiv.root);
                } else {
                    q.lockPoint = destination;
                }
                w.lockDirections.put(locktag, getConnectionDirection(w, lockTargetDiv.root));
            }
            if (q.lockPoint == null) {
                System.out.println("PCGPatternNKeysAndLock: could not place the lock!");
                return null;
            }      
            q.lockTag = locktag;

            if (pcg.canPlaceTag(q.lockPoint, q.lockTag)) {
                break;
            }
        }
        

        if (q.lockDivision == null) {
            return null;
        }
        if (q.goalPoint == null) {
            return null;
        }

//        System.out.println("lock: " + q.lockDivision.divisionID + " -> " + q.goalDivision.divisionID);
//        if (!useable.contains(q.lockDivision)) {
//            System.out.println("!!!!! (keylock) " + q.lockDivision.divisionID);
//        }            
        
        if (q.lockPoint.a == q.goalPoint.a && 
            (Math.abs(q.lockPoint.x - q.goalPoint.x) + 
             Math.abs(q.lockPoint.y - q.goalPoint.y)) == 1 &&
            q.goalDivision.root == q.goalPoint) {
            q.lockToGoalPathType = Quest.PATH_ONE_STEP;
        } else {
            q.lockToGoalPathType = Quest.PATH_NORMAL;
        }
            
        
        // update "reachable" (remove "goal" and all its descendants):
        {
//            AreaDivision rootToRemove = qs.goal;
            AreaDivision rootToRemove = q.lockDivision;
            List<AreaDivision> toRemove = new ArrayList<>();
            for(AreaDivision d:reachable) {
//                if (pcg.treeParents(d).contains(qs.goal)) {
                if (pcg.treeParents(d).contains(rootToRemove)) {
                    toRemove.add(d);
                }
            }
            for(AreaDivision d:useable) {
                if (!toRemove.contains(d)) {
                    if (pcg.treeParents(d).contains(rootToRemove)) {
                        toRemove.add(d);
                    }
                }
            }
            for(AreaDivision d:toRemove) {
                reachable.remove(d);
                useable.remove(d);
            }
//            System.out.println("  PCGPatternNKeysAndLock: goal ("+qs.goalTag+") set to " + qs.goal + " with lock at "+q.lockDivision+". Removing: " + toRemove);
        }
        
        // Sample nodes in the reachable tree, with bias to leaves, and to leaves that are close to the goal:
        List<QuestSpec> subquests = new ArrayList<>();
        for(int i = 0;i<nKeys;i++) {
            int n_retries = 5;
            if (reachable.isEmpty()) {
                System.err.println("PCGPatternNKeysAndLock: no divisions left for more keys (we were spawning key " + i + ": " + keytags[i] + ")!");
                return null;
            }
            AreaDivision keyDivision = null;
            AreaPoint keyPoint = null;
            List<AreaDivision> candidates = new ArrayList<>();
            candidates.addAll(useable);
            while(n_retries > 0) {
                keyDivision = pcg.randomAreaDivisionFavoringLeaves(null, candidates, true);
                if (keyDivision == null) return null;
//                System.out.println("    keyDivision "+keytags[i]+": " + keyDivision);
                keyPoint = pcg.randomDivisionPoint(keyDivision, true);
                if (keyPoint != null) {
                    break;
                }
//                System.out.println("!!!!!!");
                candidates.remove(keyDivision);
                n_retries--;
            }
            if (keyPoint == null) {
//                System.err.println("PCGPatternNKeysAndLock: could not find key location, useable: " + useable);
                return null;
            }
            q.keyDivisions.add(keyDivision);
            q.keyPoints.add(keyPoint);
            q.keyTags.add(keytags[i]);
            subquests.add(new QuestSpec(qs.start, keyDivision, qs.nSubQuests - 1, q.startPoint, keyPoint, qs.startTag, keytags[i]));
        }
        
        return new Pair<>(q, subquests);
    }

}
