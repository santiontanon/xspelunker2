/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import pcg.Area;
import pcg.MSXRandom;
import pcg.PCGArea;
import pcg.PCGWorld;
import pcg.RenderedArea;
import pcg.World;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class HardcodedRenderedAreaForAssembler {
    public static final int MAX_AREA_WIDTH = 8;
    public static final int MAX_AREA_HEIGHT = 8;
    public static final int MAX_N_TAGS = 32;
    
    public static void main(String args[]) throws Exception
    {
        MSXRandom r = new MSXRandom(0, 0xaaaa);


        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2 = new PCGArea(true);
        
        World w = pcg1.generate(r);        
        pcg2.generate(w.areas.get(0), w, r);
        RenderedArea ra = pcg2.generate(w.areas.get(1), w, r);
        generateAssemblerRenderedAreaData(ra, w.areas.get(1), pcg2);
        GenerationTest.visualizeArea(ra, "tmp/area"+1+".png", pcg2);
    }
    
    
    public static void generateAssemblerAreaData(World w, int areaIndex) throws Exception
    {
        Area a = w.areas.get(areaIndex);
            
        System.out.println("hardcoded_area_data_"+areaIndex+"__seed:");
        System.out.println("  dw " + Z80Assembler.toHex16bit(a.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(a.rng_seed2, true));
        System.out.println("hardcoded_area_data_"+areaIndex+"__id:");
        System.out.println("  db " + a.ID);
        System.out.println("hardcoded_area_data_"+areaIndex+"__width:");
        System.out.println("  db " + a.width);
        System.out.println("hardcoded_area_data_"+areaIndex+"__height:");
        System.out.println("  db " + a.height);

        System.out.println("hardcoded_area_data_"+areaIndex+"__connections:");
        for(int i = 0;i<a.height;i++) {
            String line = "  db ";
            for(int j = 0;j<a.width;j++) {
                if (j == 0) {
                    line += a.connections[j][i];
                } else {
                    line += ", " + a.connections[j][i];
                }
            }
            System.out.println(line);
        }
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", 0");
        }
        
        System.out.println("hardcoded_area_data_"+areaIndex+"__divisionIDs:");
        for(int i = 0;i<a.height;i++) {
            String line = "  db ";
            for(int j = 0;j<a.width;j++) {
                if (j == 0) {
                    line += a.divisionIDs[j][i];
                } else {
                    line += ", " + a.divisionIDs[j][i];
                }
            }
            System.out.println(line);
        }
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", 0");
        }
        
        System.out.println("hardcoded_area_data_"+areaIndex+"__tags:");
        int n_tags = 0;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.tags[j][i] != null) {
                    for(String tag:a.tags[j][i]) {
                        System.out.println("  db " + (j+i*a.width) + ", " + tagToAssembler(tag));
                        n_tags++;
                    }
                }
            }
        }
        if (n_tags > MAX_N_TAGS) {
            throw new Exception("Too many tags!");
        }
        if (n_tags < MAX_N_TAGS) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_N_TAGS - n_tags)*2 + ", #ff");            
        }    
    }
    
    
    public static String tagToAssembler(String tag)
    {
        String tag2 = "TAG_" + tag;
        tag2 = tag2.replace("-", "_");
        tag2 = tag2.toUpperCase();
        if (tag2.startsWith("TAG_WALL")) {
            tag2 = tag2.replace("TAG_WALL", "TAG_BREAKABLE_WALL");
        }
        if (tag2.startsWith("TAG_BLOCK") && !tag2.startsWith("TAG_BLOCK_PUZZLE")) {
            tag2 = tag2.replace("TAG_BLOCK", "TAG_BLOCK_PUZZLE");
        }
        return tag2;
    }
    
    
    public static void generateAssemblerRenderedAreaData(RenderedArea ra, Area a, PCGArea pcg) throws Exception
    {
        System.out.println("hardcoded_area_data__seed:");
        System.out.println("  dw " + Z80Assembler.toHex16bit(a.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(a.rng_seed2, true));
        System.out.println("hardcoded_area_data__id:");
        System.out.println("  db " + a.ID);
        System.out.println("hardcoded_area_data__width:");
        System.out.println("  db " + a.width);
        System.out.println("hardcoded_area_data__height:");
        System.out.println("  db " + a.height);

        System.out.println("hardcoded_area_data__room_ids:");
        for(int i = 0;i<a.height;i++) {
            String line = "  db ";
            for(int j = 0;j<a.width;j++) {
                if (j == 0) {
                    line += a.rooms[j][i];
                } else {
                    line += ", " + a.rooms[j][i];
                }
            }
            System.out.println(line);
        }
        
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", 0");
        }

        System.out.println("hardcoded_area_data__chunk_ids:");
        for(int i = 0;i<a.height * 2;i++) {
            String line = "  db ";
            for(int j = 0;j<a.width * 2;j++) {
                int idx = pcg.all_fg_chunks.indexOf(ra.fg_chunks[j][i]);
                if (j == 0) {
                    line += idx;
                } else {
                    line += ", " + idx;
                }
            }
            System.out.println(line);
        }
    }
}
