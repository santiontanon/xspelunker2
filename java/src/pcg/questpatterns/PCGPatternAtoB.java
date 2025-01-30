/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg.questpatterns;

import java.util.ArrayList;
import java.util.List;
import pcg.AreaDivision;
import pcg.Quest;
import pcg.QuestSpec;
import pcg.World;
import util.Pair;

/**
 *
 * @author santi
 */
public class PCGPatternAtoB extends PCGPattern {
    public Pair<Quest, List<QuestSpec>> generate(World w, QuestSpec qs, List<AreaDivision> useable, List<AreaDivision> reachable)
    {
//        System.out.println("PCGPatternAtoB: " + qs.startTag + " -> " + qs.goalTag);
        Quest q = new Quest("AtoB: " + qs.start.divisionID + " -> " + qs.goal.divisionID);
        q.useable.addAll(useable);
        q.reachable.addAll(reachable);
        
        q.startDivision = qs.start;
        q.goalDivision = qs.goal;

        q.startPoint = (qs.startPoint == null ? q.startDivision.root:qs.startPoint);
        q.goalPoint = (qs.goalPoint == null ? q.goalDivision.root:qs.goalPoint);
        
        q.startTag = qs.startTag;
        q.goalTag = qs.goalTag;
        
        // We set a key at the start, so that a path from start -> goal is created.
        q.keyDivisions.add(q.startDivision);
        q.keyPoints.add(q.startPoint);
        q.keyTags.add(q.startTag);
                        
        return new Pair<>(q, new ArrayList<>());
    }
}
