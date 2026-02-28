/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Color;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import util.Pair;


/**
 *
 * @author santi
 */
public class Area {    
    public int ID;
    public int rng_seed1 = 0, rng_seed2 = 0xaaaa;
    public int width, height;
    public int rooms[][];  // different numbers correspond to different rooms
    public int connections[][];
    public int[][] divisionIDs;  // different IDs mean that there cannot be a path between them
    public List<String>[][] tags;
    public int nRooms = 0;
    public int nDivisions = 0;
        
    
    // Map decorations (just for debugging):
    public int areaX = 0, areaY = 0;  // position where are will be drawn in the debug window
    public List<Pair<AreaPoint, Color>> debugPoints = new ArrayList<>();
    public List<Pair<List<Pair<Integer, Integer>>, Color>> debugPaths = new ArrayList<>();
    public boolean[][] divisionRoot;  // only used for debugging
    
    
    public Area(int a_ID, int a_w, int a_h, int a_seed1, int a_seed2)
    {
        ID = a_ID;
        width = a_w;
        height = a_h;
        rng_seed1 = a_seed1;
        rng_seed2 = a_seed2;
        
        rooms = new int[width][height];
        connections = new int[width][height];
        tags = new List[width][height];
        divisionIDs = new int[width][height];
        divisionRoot = new boolean[width][height];
        
        for(int i = 0;i<height;i++) {
            for(int j = 0;j<width;j++) {
                rooms[j][i] = -1;
                connections[j][i] = 0;
                tags[j][i] = null;
                divisionIDs[j][i] = 0;
                divisionRoot[j][i] = false;
            }
        }
    }
    
    
    public void addTag(AreaPoint p, String tag)
    {
        if (tags[p.x][p.y] == null) {
            tags[p.x][p.y] = new ArrayList<>();
        }
        tags[p.x][p.y].add(tag);
    }


    public void removeTag(AreaPoint p, String tag)
    {
        tags[p.x][p.y].remove(tag);
        if (tags[p.x][p.y].isEmpty()) {
            tags[p.x][p.y] = null;
        }
    }


    public void removeTag(String tag)
    {
        for(int j = 0;j<tags.length;j++) {
            for(int i=0;i<tags[0].length;i++) {
                if (tags[j][i] == null) continue;
                tags[j][i].remove(tag);
                if (tags[j][i].isEmpty()) {
                    tags[j][i] = null;
                }
            }
        }
    }
    
    
    public List<Pair<Integer, String>> getSortedTagList()
    {
        List<Pair<Integer, String>> tagList = new ArrayList<>();        
        for(int i = 0;i<height;i++) {
            for(int j = 0;j<width;j++) {
                if (tags[j][i] != null) {
                    for(String tag:tags[j][i]) {
                        tagList.add(new Pair<>(j+i*width, tag));
                    }
                }
            }
        }
        Collections.sort(tagList, new Comparator<Pair<Integer, String>>(){
            @Override
            public int compare(Pair<Integer, String> o1, Pair<Integer, String> o2) {
                try {
                    int tag1 = AssemblerTags.assemblerID(o1.right);
                    int tag2 = AssemblerTags.assemblerID(o2.right);
                    return Integer.compare(tag1, tag2);
                } catch(Exception e) {
                    e.printStackTrace();
                    System.exit(0);
                    return 0;
                }
            }
        });
        return tagList;
    }                
}
