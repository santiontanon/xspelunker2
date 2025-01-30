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
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import javax.imageio.ImageIO;
import javax.swing.JFrame;
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
    public static void main(String args[]) throws Exception
    {
        Random r = new Random();

        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2 = new PCGArea();
        
        int nPCGAreaErrors = 0;
        HashMap<String, Integer> chunkStats = new HashMap<>();
        int typeStats[] = new int[16];
        for(int i = 0;i<16;i++) {
            typeStats[i] = 0;
        }
        
        for(int i = 0;i<1000;i++) {
//        for(int i = 0;i<65536;i++) {
//        for(int i = 0;i<5000;i++) {
            r.setSeed(i);
            World w = pcg1.generate(r);
            if (w == null) {
                System.out.println("Cannot generate with seed " + i);
                break;
            } else {
                System.out.println("PCG success with seed " + i);
                if (!Solver.solveGame(w)) {
                    System.out.println("Solver error with seed " + i);
                } else {
                    System.out.println("Solver success with seed " + i);
                }
                
                for(int j = 0;j<w.areas.size();j++) {
                    RenderedArea ra = pcg2.generate(w.areas.get(j), w, r);
                    if (ra == null) {
                        System.out.println("PCGArea error with seed " + i + ", area " + j);
                        nPCGAreaErrors++;
                    } else {
                        ra.stats(chunkStats, typeStats);
                    }
                }
            }
        }
        System.out.println("n_times_defaulting_to_safe_seed: " + pcg1.n_times_defaulting_to_safe_seed);
        System.out.println("nPCGAreaErrors: " + nPCGAreaErrors);

//        r.setSeed(17841);
//        World w = pcg1.generate(r);
//        if (w != null) {
//            visualizeWorld(w);
//            if (!Solver.solveGame(w)) {
//                System.err.println("Error: game cannot be solved!");
//            }
//            for(int j = 0;j<w.areas.size();j++) {
//                RenderedArea ra = pcg2.generate(w.areas.get(j), w, r);
//                if (ra != null) {
//                    visualizeArea(ra, "tmp/area"+j+".png");
//                    ra.stats(chunkStats, typeStats);
//                }
//            }
//        }
        
        
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
    
    
    public static void visualizeArea(RenderedArea ra, String path) throws Exception
    {                
        BufferedImage img = new BufferedImage(ra.fg_chunks.length * 8 * RoomChunk.CHUNK_WIDTH + 80,
                                              ra.fg_chunks[0].length * 8 * RoomChunk.CHUNK_HEIGHT + 80,
                                              BufferedImage.TYPE_3BYTE_BGR);
        ra.draw((Graphics2D)img.getGraphics());
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
    
}
