/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg.questpatterns;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import pcg.InterAreaConnection;
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
public class PCGPatternNKeysAndChestLock extends PCGPattern {
    public Pair<Quest, List<QuestSpec>> generate(World w, QuestSpec qs, String keytags[], String locktag, List<AreaDivision> useable, List<AreaDivision> reachable, PCGWorld pcg)
    {
//        if (locktag.equals("white-chest")) {
//            System.out.println("!!!!");
//        }
//        System.out.println("PCGPatternNKeysAndChestLock: " + qs.startTag + " -> " +  Arrays.toString(keytags) + " -> " + locktag + " -> " + qs.goalTag);
        int nKeys = keytags.length;
        Quest q = new Quest(nKeys + "-keys-and-chestlock: " + qs.start.divisionID + " -> " + qs.goal.divisionID);
        q.useable.addAll(useable);
        q.reachable.addAll(reachable);
        
        q.startDivision = qs.start;
        q.goalDivision = qs.goal;

        q.startPoint = (qs.startPoint == null ? q.startDivision.root:qs.startPoint);
        q.goalPoint = (qs.goalPoint == null ? q.goalDivision.root:qs.goalPoint);
        
        q.startTag = qs.startTag;
        q.goalTag = qs.goalTag;
        
        // Generate key and lock locations:
        q.lockDivision = q.goalDivision;
        q.lockPoint = q.goalPoint;
        q.lockTag = locktag;
        q.lockToGoalPathType = Quest.PATH_NONE;
        
        List<String> allowedTags = new ArrayList<>();
        allowedTags.add(q.goalTag);
        if (!pcg.canPlaceTag(q.lockPoint, q.lockTag, allowedTags)) {
            System.out.println("!!! -> cannot place " + q.lockTag + " since we have " + q.lockPoint.a.tags[q.lockPoint.x][q.lockPoint.y] + " (allowed tags: " + allowedTags + ")");
        }
        
        // update "reachable" (remove "goal" and all its descendants):
//        {
//            List<AreaDivision> toRemove = new ArrayList<>();
//            for(AreaDivision d:reachable) {
//                if (pcg.treeParents(d).contains(qs.goal)) {
//                    toRemove.add(d);
//                }
//            }
//            for(AreaDivision d:useable) {
//                if (!toRemove.contains(d)) {
//                    if (pcg.treeParents(d).contains(qs.goal)) {
//                        toRemove.add(d);
//                    }
//                }
//            }
//            for(AreaDivision d:toRemove) {
//                reachable.remove(d);
//                useable.remove(d);
//            }
////            System.out.println("    remove reachable/useable under " + qs.goal.divisionID + " (leaving us with " + reachable.size() + ", " + useable.size() + ")");
////            System.out.println("  PCGPatternNKeysAndChestLock: goal ("+qs.goalTag+") set to " + qs.goal + " with lock at "+q.lockDivision+". Removing: " + toRemove);
//        }
        
//        System.out.println("    key tags: " + Arrays.toString(keytags));
        
        // Sample nodes in the reachable tree, with bias to leaves, and to leaves that are close to the goal:
        List<QuestSpec> subquests = new ArrayList<>();
        for(int i = 0;i<nKeys;i++) {
            int n_retries = 5;
            if (reachable.isEmpty()) {
//                System.out.println("PCGPatternNKeysAndChestLock: no divisions left for more keys!");
                break;
            }
            AreaDivision keyDivision = null;
            AreaPoint keyPoint = null;
            List<AreaDivision> candidates = new ArrayList<>();
            candidates.addAll(useable);
            while(n_retries > 0) {
                keyDivision = pcg.randomAreaDivisionFavoringLeaves(null, candidates, true);
                if (keyDivision == null) return null;
//                System.out.println("    chest keyDivision "+keytags[i]+": " + keyDivision);
                keyPoint = pcg.randomDivisionPoint(keyDivision, true);
                if (keyPoint != null) break;
//                System.out.println("!!!!!!");
                n_retries--;
                candidates.remove(keyDivision);
            }
            if (keyPoint == null) {
//                System.err.println("PCGPatternNKeysAndLock: could not find key location, useable: " + useable);
                return null;
            }
//            System.out.println("    key division: " + keyDivision.divisionID);
            q.keyDivisions.add(keyDivision);
            q.keyPoints.add(keyPoint);
            q.keyTags.add(keytags[i]);
            QuestSpec q2 = new QuestSpec(qs.start, keyDivision, qs.nSubQuests - 1, q.startPoint, keyPoint, qs.startTag, keytags[i]);
//            System.out.println("   new subquest (from key-chest): " + q2);
            subquests.add(q2);
        }
        
        return new Pair<>(q, subquests);
    }
    
}
