/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg.questpatterns;

import java.util.ArrayList;
import java.util.List;
import pcg.AreaConnection;
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
 * 
 * This pattern is like the "NKeysAndLock", but only generates one key, at the same room as the lock:
 * - it is used for things like "breakable walls", "traversable walls", "block puzzles", etc. that can
 *   be solved within the same lock room.
 * 
 */
public class PCGPatternObstacle extends PCGPattern {
    public Pair<Quest, List<QuestSpec>> generate(World w, QuestSpec qs, String keytag, String locktag, List<AreaDivision> useable, List<AreaDivision> reachable, PCGWorld pcg)
    {
//        System.out.println("PCGPatternObstacle: " + qs.startTag + " -> " +  keytag + " / " + locktag + " -> " + qs.goalTag);
        Quest q = new Quest("obstacle: " + qs.start.divisionID + " -> " + qs.goal.divisionID);
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
        q.lockDivision = q.goalDivision.parent;
        if (q.lockDivision == null) return null;
        if (q.goalDivision.parent != null && q.goalDivision.root.a == q.goalDivision.parent.root.a) {
            switch(q.goalDivision.root.direction) {
                case PCGWorld.DIRECTION_RIGHT:
                    q.lockPoint = new AreaPoint(q.lockDivision.root.a, q.goalDivision.root.x + 1, q.goalDivision.root.y);
                    w.lockDirections.put(locktag, PCGWorld.DIRECTION_LEFT);
                    break;
                case PCGWorld.DIRECTION_DOWN:
                    q.lockPoint = new AreaPoint(q.lockDivision.root.a, q.goalDivision.root.x, q.goalDivision.root.y + 1);
                    w.lockDirections.put(locktag, PCGWorld.DIRECTION_UP);
                    break;
                case PCGWorld.DIRECTION_LEFT:
                    q.lockPoint = new AreaPoint(q.lockDivision.root.a, q.goalDivision.root.x - 1, q.goalDivision.root.y);
                    w.lockDirections.put(locktag, PCGWorld.DIRECTION_RIGHT);
                    break;
                case PCGWorld.DIRECTION_UP:
                    q.lockPoint = new AreaPoint(q.lockDivision.root.a, q.goalDivision.root.x, q.goalDivision.root.y - 1);
                    w.lockDirections.put(locktag, PCGWorld.DIRECTION_DOWN);
                    break;
                default:
                    System.err.println("root node of division " + q.goalDivision.divisionID + " has no direction!");
            }
        } else {
            AreaPoint destination = getConnectionDestination(w, q.goalDivision.root);
            if (destination == null) {
                System.err.println("Cannot find connection destination starting at " + q.goalDivision.root);
            } else {
                q.lockPoint = destination;
            }
            w.lockDirections.put(locktag, getConnectionDirection(w, q.goalDivision.root));
        }
        if (q.lockPoint == null) {
            System.err.println("PCGPatternObstacle: could not place the lock!");
            return null;
        }

        q.lockTag = locktag;
        if (q.goalPoint == q.goalDivision.root) {
            q.lockToGoalPathType = Quest.PATH_ONE_STEP;
        } else {
            q.lockToGoalPathType = Quest.PATH_NORMAL;
        }
        
        // update "reachable" (remove "goal" and all its descendants):
        {
            List<AreaDivision> toRemove = new ArrayList<>();
            for(AreaDivision d:reachable) {
                if (pcg.treeParents(d).contains(qs.goal)) {
                    toRemove.add(d);
                }
            }
            for(AreaDivision d:useable) {
                if (!toRemove.contains(d)) {
                    if (pcg.treeParents(d).contains(qs.goal)) {
                        toRemove.add(d);
                    }
                }
            }
            for(AreaDivision d:toRemove) {
                reachable.remove(d);
                useable.remove(d);
            }
//            System.out.println("  PCGPatternObstacle: goal ("+qs.goalTag+") set to " + qs.goal + " with lock at "+q.lockDivision+". Removing: " + toRemove);
        }
        
        AreaDivision keyDivision = q.lockDivision;
        AreaPoint keyPoint = q.lockPoint;
        q.keyDivisions.add(keyDivision);
        q.keyPoints.add(keyPoint);
        q.keyTags.add(keytag);
        List<QuestSpec> subquests = new ArrayList<>();
        subquests.add(new QuestSpec(qs.start, keyDivision, qs.nSubQuests - 1, q.startPoint, keyPoint, qs.startTag, keytag));
        
        return new Pair<>(q, subquests);
    }
}
