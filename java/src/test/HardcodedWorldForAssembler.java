/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.util.List;
import pcg.Area;
import pcg.InterAreaConnection;
import pcg.AssemblerTags;
import pcg.MSXRandom;
import pcg.PCGArea;
import pcg.PCGWorld;
import pcg.RenderedArea;
import pcg.World;
import util.Pair;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class HardcodedWorldForAssembler {
    public static final int MAX_AREA_WIDTH = 8;
    public static final int MAX_AREA_HEIGHT = 8;
    public static final int MAX_N_TAGS = 32;
    public static final int MAX_CONNECTIONS = 12;
    
    public static void main(String args[]) throws Exception
    {
        MSXRandom r = new MSXRandom(0, 0xaaaa);


        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2 = new PCGArea(true);
        
        World w = pcg1.generate(r);
        for(int i = 0;i<10;i++) {
            generateAssemblerAreaData(w, i, pcg2);
        }
        generateAssemblerWorldData(w);
        
        
//        pcg1.mergeAreaRooms(w.areas.get(0));
//        pcg2.generate(w.areas.get(0), w, r);
//        pcg1.mergeAreaRooms(w.areas.get(1));
//        RenderedArea ra = pcg2.generate(w.areas.get(1), w, r);
//        
//        generateAssemblerRenderedAreaData(ra, w.areas.get(1), pcg2);
//        GenerationTest.visualizeArea(ra, "tmp/area"+1+".png", pcg2);
    }
    
    
    public static void generateAssemblerWorldData(World w) throws Exception
    {
        // Connections:
        System.out.println("hardcoded_world_data__interarea_connections:");
        System.out.println("  ; each connection is 8 bytes: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2");
        for(InterAreaConnection c:w.interAreaconnections) {
            System.out.println("  db " + c.p1.a.ID + ", " + c.p2.a.ID + ", " +
                               (c.p1.x * 2 + c.p1_x_chunk_offs) + ", " + (c.p1.y * 2 + c.p1_y_chunk_offs) + ", " + c.p1.direction + ", " +
                               (c.p2.x * 2 + c.p2_x_chunk_offs) + ", " + (c.p2.y * 2 + c.p2_y_chunk_offs) + ", " + c.p2.direction);
        }
        if (w.interAreaconnections.size() < MAX_CONNECTIONS) {
            System.out.println("  ds " + (MAX_CONNECTIONS - w.interAreaconnections.size()) * 8 + ", #ff");
        }
        System.out.println("  db #ff  ; sentinel");
    }
    
    
    public static void generateAssemblerAreaData(World w, int areaIndex, PCGArea pcg2) throws Exception
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
        List<Pair<Integer, String>> tagList = pcg2.getSortedTagList(a);
        for(Pair<Integer, String> tag_position:tagList) {
            int offset = tag_position.left;
            String tag = tag_position.right;
            int lockDirection = 0;
            if (w.lockDirections.containsKey(tag)) {
                lockDirection = w.lockDirections.get(tag);
            }
            System.out.println("  db " + AssemblerTags.tagToAssembler(tag) + ", " + offset + ", " + lockDirection);
        }
        if (tagList.size() > MAX_N_TAGS) {
            throw new Exception("Too many tags!");
        }
        if (tagList.size() < MAX_N_TAGS) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_N_TAGS - tagList.size())*3 + ", 0");            
        }    
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
