/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class QuestSpec {
    public AreaDivision start, goal;
    public AreaPoint startPoint, goalPoint;
    public String startTag, goalTag;
    public int nSubQuests;


    public QuestSpec(AreaDivision a_start, AreaDivision a_goal, int a_n, AreaPoint a_startPoint, AreaPoint a_goalPoint, String a_startTag, String a_goalTag)
    {
        start = a_start;
        goal = a_goal;
        startPoint = a_startPoint;
        goalPoint = a_goalPoint;
        startTag = a_startTag;
        goalTag = a_goalTag;
        nSubQuests = a_n;
    }
}
