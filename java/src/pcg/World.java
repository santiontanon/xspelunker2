/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import util.Pair;

/**
 *
 * @author santi
 */
public class World {

    public int seed1, seed2;
    public List<Area> areas = new ArrayList<>();
    public List<InterAreaConnection> interAreaconnections = new ArrayList<>();
    public HashMap<String, Integer> lockDirections = new HashMap<>();
    public HashMap<String, String> chestContentMap = new HashMap<>();
    public List<String> chestContentSorted = new ArrayList<>();
    public HashMap<String, String> tabletContentMap = new HashMap<>();
    public List<String> tabletContentSorted = new ArrayList<>();
    public List<String> withinChestTag = new ArrayList<>();
    public List<AreaDivision> spanningTree;
    public int[][] combinationSolutions = new int[4][8];
    public int[] trialTypes = new int[4];
    public int[] powerStoneNumbers = new int[5];
    
    // Used for verifying if game is solveable:
    public HashMap<String, List<String>> lockKeys = new HashMap<>();  
    
    // debug:
    public static int roomSizeX = 18;
    public static int roomSizeY = 12;
    public static Font tagFont = new Font("times", Font.PLAIN, 8);
    public static Font divFont = new Font("times", Font.PLAIN, 6);
    Random color_r = new Random();  // use only for things that do not affect PCG!
    public List<List<AreaPoint>> debugPaths = new ArrayList<>();
    public List<Color> divisionColors = new ArrayList<>();

    
    public World(int a_seed1, int a_seed2)
    {
        seed1 = a_seed1;
        seed2 = a_seed2;
        color_r.setSeed(0);
    }
    
    
    public void draw(Graphics2D g)
    {
        List<String> tagList = new ArrayList<>();

        for(Area a:areas) {
            drawArea(a, g, a.areaX, a.areaY, tagList);
        }
        
        for(InterAreaConnection c:interAreaconnections) {
            int x1 = c.p1.a.areaX + c.p1.x * roomSizeX + roomSizeX/2;
            int y1 = c.p1.a.areaY + c.p1.y * roomSizeY + roomSizeY/2;
            int x2 = c.p2.a.areaX + c.p2.x * roomSizeX + roomSizeX/2;
            int y2 = c.p2.a.areaY + c.p2.y * roomSizeY + roomSizeY/2;
            g.setColor(Color.BLUE);
            g.drawLine(x1, y1, x2, y2);
        }
        
        // Draw spanning tree:
        for(AreaDivision d:spanningTree) {
            if (d.parent != null) {
                // draw connection:
                int x1 = d.root.a.areaX + d.root.x * roomSizeX + roomSizeX/2;
                int y1 = d.root.a.areaY + d.root.y * roomSizeY + roomSizeY/2;
                int x2 = d.parent.root.a.areaX + d.parent.root.x * roomSizeX + roomSizeX/2;
                int y2 = d.parent.root.a.areaY + d.parent.root.y * roomSizeY + roomSizeY/2;
                g.setColor(Color.WHITE);
                g.drawLine(x1, y1, x2, y2);
//                System.out.println("tree: " + d.parent.divisionID + " -> " + d.divisionID);
            }
        }

//        for(List<AreaPoint> path:debugPaths) {
//            AreaPoint previous_p = null;
//            for(AreaPoint p:path) {
//                g.setColor(Color.WHITE);
//                g.fillRect(p.a.areaX + p.x*roomSizeX + 2,
//                           p.a.areaY + p.y*roomSizeY + 2, roomSizeX - 5, roomSizeY - 5);
//                if (previous_p != null && previous_p.a.ID != p.a.ID) {
//                    // draw connection:
//                    int x1 = previous_p.a.areaX + previous_p.x * roomSizeX + roomSizeX/2;
//                    int y1 = previous_p.a.areaY + previous_p.y * roomSizeY + roomSizeY/2;
//                    int x2 = p.a.areaX + p.x * roomSizeX + roomSizeX/2;
//                    int y2 = p.a.areaY + p.y * roomSizeY + roomSizeY/2;
//                    g.setColor(Color.WHITE);
//                    g.drawLine(x1, y1, x2, y2);
//                }
//                previous_p = p;
//            }
//        }
        
        int legend_x = 725;
        int legend_y = 40;
        
        g.setColor(Color.BLACK);
        g.setFont(tagFont);
        g.drawString("Tag list:", legend_x, legend_y);
        legend_y += 8;
//        System.out.println("Tag list:");
        for(int i = 0;i<tagList.size();i++) {
            String tag = tagList.get(i);
            List<AreaPoint> locations = findTagLocations(tag);
//            System.out.println((i+1) + ": " + tag + " (" + locations.size() + " times)");
//            System.out.println((i+1) + ": " + tag + " (" + locations + ")");
//            g.drawString((i+1) + ": " + tag + " (" + locations + ")", legend_x, legend_y);
            g.drawString((i+1) + ": " + tag, legend_x, legend_y);
            if (locations.size() > 1) {
                System.err.println("Tag '" + tag + "' is in more than one location: " + locations);
            }
            legend_y += 8;
        }
    }
    
    
    public List<AreaPoint> findTagLocations(String tag)
    {
        List<AreaPoint> l = new ArrayList<>();
        for(Area a:areas) {
            for(int i = 0;i<a.height;i++) {
                for(int j = 0;j<a.width;j++) {
                    if (a.tags[j][i] != null && a.tags[j][i].contains(tag)) {
                        l.add(new AreaPoint(a, j, i));
                    }
                }
            }
        }
        return l;
    }
    
    
    public void drawArea(Area a, Graphics2D g, int x, int y, List<String> tagList)
    {
        g.setColor(Color.LIGHT_GRAY);
        g.fillRect(x, y, a.width*roomSizeX, a.height*roomSizeY);
        
        // draw rooms:
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0) {
                    int w = roomSizeX - 1;
                    int h = roomSizeY - 1;
                    while(divisionColors.size() <= a.divisionIDs[j][i]) {
                        divisionColors.add(newDivisionColor());
                    }
                    g.setColor(divisionColors.get(a.divisionIDs[j][i]));
                    if (j < a.width - 1 && a.rooms[j + 1][i] == a.rooms[j][i]) w++;
                    if (i < a.height - 1 && a.rooms[j][i + 1] == a.rooms[j][i]) h++;
                    g.fillRect(x + j*roomSizeX, y + i*roomSizeY, w, h);
                    
                    // Visualize connections:
                    int lockDirection = 0;
                    if (a.tags[j][i] != null) {
                        for(String tag:a.tags[j][i]) {
                            if (lockDirections.containsKey(tag)) {
                                lockDirection |= lockDirections.get(tag);
                            }
                        }
                    }
//                    if (lockDirection != 0) {
//                        System.out.println(a.ID + " lockDirection " + j + ", " + i + ": " + lockDirection);
//                        System.out.println(lockDirections);
//                    }
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_RIGHT) != 0) {
                        g.setColor(Color.GREEN);
                        if ((lockDirection & PCGWorld.DIRECTION_RIGHT) != 0) g.setColor(Color.RED);
                        g.fillRect(x + j*roomSizeX + roomSizeX/2, y + i*roomSizeY + roomSizeY/2, roomSizeX/2, 1);
                    }
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_LEFT) != 0) {
                        g.setColor(Color.GREEN);
                        if ((lockDirection & PCGWorld.DIRECTION_LEFT) != 0) g.setColor(Color.RED);
                        g.fillRect(x + j*roomSizeX, y + i*roomSizeY + roomSizeY/2, roomSizeX/2, 1);
                    }
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_UP) != 0) {
                        g.setColor(Color.GREEN);
                        if ((lockDirection & PCGWorld.DIRECTION_UP) != 0) g.setColor(Color.RED);
                        g.fillRect(x + j*roomSizeX + roomSizeX/2, y + i*roomSizeY, 1, roomSizeY/2);
                    }
                    if ((a.connections[j][i] & PCGWorld.DIRECTION_DOWN) != 0) {
                        g.setColor(Color.GREEN);
                        if ((lockDirection & PCGWorld.DIRECTION_DOWN) != 0) g.setColor(Color.RED);
                        g.fillRect(x + j*roomSizeX + roomSizeX/2, y + i*roomSizeY + roomSizeY/2, 1, roomSizeY/2);
                    }
                }
            }
        }
        
        for(Pair<List<Pair<Integer, Integer>>, Color> path:a.debugPaths) {
            g.setColor(path.right);
            for(Pair<Integer, Integer> point:path.left) {
                g.fillRect(x + point.left*roomSizeX + 2, y + point.right*roomSizeY + 2, roomSizeX - 5, roomSizeY - 5);
            }
        }
        for(Pair<AreaPoint, Color> point:a.debugPoints) {
            g.setColor(point.right);
            int px = point.left.x;
            int py = point.left.y;
            g.fillRect(x + px*roomSizeX, y + py*roomSizeY, roomSizeX - 1, roomSizeY - 1);
        }
        
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] >= 0) {
                    g.setFont(divFont);
                    g.setColor(Color.YELLOW);
                    if (a.divisionRoot[j][i]) {
                        g.drawString("(" + a.divisionIDs[j][i] + ")", x + j*roomSizeX, y + (i + 1)*roomSizeY - 8);
                    } else {
                        g.drawString("" + a.divisionIDs[j][i], x + j*roomSizeX, y + (i + 1)*roomSizeY - 8);
                    }
                }
                if (a.tags[j][i] != null) {
                    String tagString = null;
                    for(String tag:a.tags[j][i]) {
                        if (!tagList.contains(tag)) {
                            tagList.add(tag);
                        }
//                        if (tagString == null) {
//                            tagString = tag;
//                        } else {
//                            tagString = tagString + "," + tag;
//                        }
                        if (tagString == null) {
                            tagString = (tagList.indexOf(tag) + 1) + "";
                        } else {
                            tagString = tagString + "," + (tagList.indexOf(tag) + 1);
                        }
                    }
                    if (tagString != null) {
                        g.setFont(tagFont);
                        g.setColor(Color.WHITE);
                        g.drawString(tagString, x + j*roomSizeX, y + (i + 1)*roomSizeY);
                    }
                }
            }
        }
    }
    
    
    public Color newDivisionColor()
    {
        double r = color_r.nextDouble(1.0f);
        double g = color_r.nextDouble(1.0f);
        double b = color_r.nextDouble(1.0f);
        double norm = Math.sqrt(r*r + g*g + b*b);
        r /= norm;
        g /= norm;
        b /= norm;
        float factor = 0.75f;
        return new Color((float)r*factor, (float)g*factor, (float)b*factor);
    }
    
    
    public List<String> getUnspawnedItemTags()
    {
        String candidates[] = {
            "WEAPON_HAMMER",
            "WEAPON_MACUAHUITL",
            "WEAPON_SHIELD",
            "WEAPON_SLING",
            "WEAPON_BLOWGUN",
            "WEAPON_ATLATL",
            "WEAPON_RAYGUN",
            "WEAPON_OBSIDIAN_KNIVE",
            "WEAPON_FIRE_HAMMER",
            "WEAPON_ICE_MACUAHUITL",
            "item-sandals",
            "item-gloves",
            "item-warrior-hat",
            "item-armor",
            "item-chaac",
            "item-seashell",
            "item-belt",
            "item-ice-cape",
        };
        
        List<String> notSpawned = new ArrayList<>();
        
        for(String candidate:candidates) {
            List<AreaPoint> l = findTagLocations(candidate);
            if (l != null && !l.isEmpty()) {
                continue;
            }
            if (withinChestTag.contains(candidate)) {
                continue;
            }
            notSpawned.add(candidate);
        }
        
        return notSpawned;
    }
    
    
    public void addChestContent(String k, String v)
    {
        chestContentMap.put(k, v);
        if (!chestContentSorted.contains(k)) {
            chestContentSorted.add(k);
        }
    }


    public void addTabletContent(String k, String v)
    {
        tabletContentMap.put(k, v);
        if (!tabletContentSorted.contains(k)) {
            tabletContentSorted.add(k);
        }
    }

}