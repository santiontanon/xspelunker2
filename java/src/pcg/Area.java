/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Color;
import java.util.ArrayList;
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
}
