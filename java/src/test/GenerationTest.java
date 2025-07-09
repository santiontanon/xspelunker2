/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import javax.imageio.ImageIO;
import javax.swing.JFrame;
import pcg.Area;
import pcg.MSXRandom;
import pcg.PCGArea;
import pcg.PCGWorld;
import pcg.RenderedArea;
import pcg.RoomChunk;
import pcg.Solver;
import pcg.World;

/**
 *
 * @author santi
 */
public class GenerationTest {
    public static int max_n_animations = 0;
    
    public static void main(String args[]) throws Exception
    {
        MSXRandom r = new MSXRandom(0, 0xaaaa);

        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2_jungle = new PCGArea(true, "jungle");
        PCGArea pcg2_pyramid = new PCGArea(true, "pyramid");
        
        int nPCGAreaErrors = 0;
        HashMap<String, Integer> chunkStats = new HashMap<>();
        int typeStats[] = new int[16];
        for(int i = 0;i<16;i++) {
            typeStats[i] = 0;
        }
        
//        for(int i = 0;i<1000;i++) {
////        for(int i = 0;i<65536;i++) {
////        for(int i = 0;i<5000;i++) {
//            r.setSeed1(i);
//            World w = pcg1.generate(r);
//            if (w == null) {
//                System.out.println("Cannot generate with seed " + i);
//                break;
//            } else {
//                System.out.println("PCG success with seed " + i);
//                if (!Solver.solveGame(w)) {
//                    System.out.println("Solver error with seed " + i);
//                } else {
//                    System.out.println("Solver success with seed " + i);
//                }
//                
//                for(int j = 0;j<w.areas.size();j++) {
//                    PCGArea pcg2 = null;
//                    switch(j) {
//                        case 0:
//                            pcg2 = pcg2_jungle;
//                            break;
//                        case 1:
//                        case 2:
//                        case 3:
//                        case 4:
//                        case 5:
//                        case 6:
//                        case 7:
//                        case 8:
//                        case 9:
//                        case 10:
//                        case 11:
//                            pcg2 = pcg2_pyramid;
//                            break;
//                    }                    
//                    RenderedArea ra = pcg2.generate(w.areas.get(j), w, r);
//                    if (ra == null) {
//                        System.out.println("PCGArea error with seed " + i + ", area " + j);
//                        nPCGAreaErrors++;
//                    } else {
//                        ra.stats(chunkStats, typeStats);
//                        checkNumAnimations(ra, pcg2);
//                    }
//                }
//            }
//        }
//        System.out.println("n_times_defaulting_to_safe_seed: " + pcg1.n_times_defaulting_to_safe_seed);
//        System.out.println("Generation stage stats: " + Arrays.toString(pcg1.n_times_reached_generation_stage));
////        System.out.println("Leaves in area 1: " + (pcg1.area_1_n_leaves_accum / (double)pcg1.area_1_n_leaves_count));
//        System.out.println("nPCGAreaErrors: " + nPCGAreaErrors);

        r.setSeed(0, 0xaaaa);
        World w = pcg1.generate(r);
        if (w != null) {
            if (!Solver.solveGame(w)) {
                System.err.println("Error: game cannot be solved!");
            }
            for(int j = 0;j<w.areas.size();j++) {
                PCGArea pcg2 = null;
                switch(j) {
                    case 0:
                        pcg2 = pcg2_jungle;
                        break;
                    case 1:
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                    case 6:
                    case 7:
                    case 8:
                    case 9:
                    case 10:
                    case 11:
                        pcg2 = pcg2_pyramid;
                        break;
                }
                RenderedArea ra = pcg2.generate(w.areas.get(j), w, r);
                if (ra != null) {
                    visualizeArea(ra, "tmp/area"+j+".png", pcg2);
                    ra.stats(chunkStats, typeStats);
                    checkNumAnimations(ra, pcg2);
                }
            }
            visualizeWorld(w);
        }

        
        System.out.println("Tile type stats:");
        for(int i = 0;i<16;i++) {
            System.out.println("  " + i + ": " + typeStats[i]);
        }
        System.out.println("Tile chunk stats:");
        List<String> chunkNames = new ArrayList<>();
        chunkNames.addAll(chunkStats.keySet());
        Collections.sort(chunkNames, new Comparator<String>() {
            @Override
            public int compare(String b1, String b2) {
                return -Integer.compare(chunkStats.get(b1), chunkStats.get(b2));
            }
        });
        for(String path:chunkNames) {
            System.out.println("  " + path + ": " + chunkStats.get(path));
        }
        
        System.out.println("Max tile animations: " + max_n_animations);
    }

    
    public static void visualizeWorld(World world) throws Exception
    {                
        JFrame w = new JFrame() {
            @Override
            public void paint(Graphics g) {
                Graphics2D g2d = (Graphics2D)g;
                g2d.setColor(Color.LIGHT_GRAY);
                world.draw(g2d);
            }
        };
        w.setSize(new Dimension(900, 800));
        w.setVisible(true);
        w.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }    
    
    
    public static void visualizeArea(RenderedArea ra, String path, PCGArea pcg) throws Exception
    {                
        BufferedImage img = new BufferedImage(ra.fg_chunks.length * 8 * RoomChunk.CHUNK_WIDTH + 80,
                                              ra.fg_chunks[0].length * 8 * RoomChunk.CHUNK_HEIGHT + 80,
                                              BufferedImage.TYPE_3BYTE_BGR);
        ra.draw((Graphics2D)img.getGraphics(), pcg, pcg.biome, true);
        ImageIO.write(img, "png", new File(path));
//        JFrame w = new JFrame() {
//            @Override
//            public void paint(Graphics g) {
//                Graphics2D g2d = (Graphics2D)g;
//                g2d.setColor(Color.LIGHT_GRAY);
//                ra.draw(g2d);
//            }
//        };
//        w.setSize(new Dimension(900, 800));
//        w.setVisible(true);
//        w.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }    
    
    
    public static void checkNumAnimations(RenderedArea ra, PCGArea pcg) throws Exception
    {
        Area a = ra.a;
        List<Integer> roomIDs = new ArrayList<>();
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] > 0 && !roomIDs.contains(a.rooms[j][i])) {
                    roomIDs.add(a.rooms[j][i]);
                }
            }
        }
        
        // System.out.println("RoomIDs for area " + a.ID + ": " + roomIDs);
//        for(int roomID:roomIDs) {
//            int n_animations = ra.getRoomAnimations(roomID, pcg).size();
//            max_n_animations = Math.max(max_n_animations, n_animations);
//            if (n_animations > RenderedArea.MAX_ANIMATIONS) {
//                throw new Exception("Room has more than " + RenderedArea.MAX_ANIMATIONS + " animations! -> " + n_animations);
//            }
//        }
    }
    
}
