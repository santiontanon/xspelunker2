/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.util.ArrayList;
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
    public static final int MAX_CHESTS = 10;
    public static final int MAX_TABLETS = 21;
    
    public static void main(String args[]) throws Exception
    {
        MSXRandom r = new MSXRandom(0, 0x5555);


        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2_jungle = new PCGArea(true, "jungle");
        PCGArea pcg2_pyramid = new PCGArea(true, "pyramid");
        
        World w = pcg1.generate(r);
        for(int i = 0;i<pcg1.n_areas;i++) {
            PCGArea pcg2 = null;
            switch(i) {
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
        System.out.println("  ; each connection is 8 bytes: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)");
        for(InterAreaConnection c:w.interAreaconnections) {
            System.out.println("  db " + c.p1.a.ID + ", " + c.p2.a.ID + ", " +
                               (c.p1.x * 2 + c.p1_x_chunk_offs) + ", " + (c.p1.y * 2 + c.p1_y_chunk_offs) + ", " + c.p1.direction + ", " +
                               (c.p2.x * 2 + c.p2_x_chunk_offs) + ", " + (c.p2.y * 2 + c.p2_y_chunk_offs) + ", " + c.p2.direction);
        }
        if (w.interAreaconnections.size() > MAX_CONNECTIONS) {
            throw new Exception("More connections than supported: " + w.interAreaconnections.size());
        }
        if (w.interAreaconnections.size() < MAX_CONNECTIONS) {
            System.out.println("  ds " + (MAX_CONNECTIONS - w.interAreaconnections.size()) * 8 + ", #ff");
        }
        System.out.println("  db #ff  ; sentinel");

        // Chest content:
        int n_chests = 0;
        System.out.println("hardcoded_world_data__chest_content:");
        System.out.println("  ; each entry is 2 bytes: chest_id, content_id");
        for(String chest:w.chestContentSorted) {
            if (chest.contains("boss")) continue;
            System.out.println("  db " + AssemblerTags.tagToAssembler(chest) + ", " + AssemblerTags.tagToAssembler(w.chestContentMap.get(chest)));
            n_chests++;
        }
        if (n_chests > MAX_CHESTS) {
            System.err.println(w.chestContentMap);
            throw new Exception("More chests than supported: " + n_chests);
        }
        if (n_chests < MAX_CHESTS) {
            System.out.println("  ds " + (MAX_CHESTS - n_chests) * 2 + ", #ff");
        }
        System.out.println("  db #ff  ; sentinel");
        
        // Tablet content:
        int n_tablets = 0;
        System.out.println("hardcoded_world_data__tablet_content:");
        System.out.println("  ; each entry is 3 bytes: tablet_id, content_ptr");
        for(String tablet:w.tabletContentSorted) {
            System.out.println("  db " + AssemblerTags.tagToAssembler(tablet));
            System.out.println("  dw " + w.tabletContentMap.get(tablet));
            n_tablets++;
        }
        if (n_tablets > MAX_TABLETS) {
            throw new Exception("More tablets than supported: " + n_tablets);
        }
        if (n_tablets < MAX_TABLETS) {
            System.out.println("  ds " + (MAX_TABLETS - n_tablets) * 3 + ", #ff");
        }
        System.out.println("  db #ff  ; sentinel");
        
        System.out.println("hardcoded_world_data__combination_solutions:");
        for(int i = 0;i<4;i++) {
            System.out.println("  db " + w.combinationSolutions[i][0] + ", " +
                                         w.combinationSolutions[i][1] + ", " +
                                         w.combinationSolutions[i][2] + ", " +
                                         w.combinationSolutions[i][3] + ", " +
                                         w.combinationSolutions[i][4] + ", " +
                                         w.combinationSolutions[i][5] + ", " +
                                         w.combinationSolutions[i][6] + ", " +
                                         w.combinationSolutions[i][7]);
        }
        System.out.println("hardcoded_world_data__trial_types:");
        System.out.println("  db " + w.trialTypes[0] + ", " +
                                     w.trialTypes[1] + ", " +
                                     w.trialTypes[2] + ", " +
                                     w.trialTypes[3]);
        System.out.println("hardcoded_world_data__power_stone_numbers:");
        System.out.println("  db " + w.powerStoneNumbers[0] + ", " +
                                     w.powerStoneNumbers[1] + ", " +
                                     w.powerStoneNumbers[2] + ", " +
                                     w.powerStoneNumbers[3] + ", " +
                                     w.powerStoneNumbers[4]);
        List<String> itemsForShop = new ArrayList<>();
        List<String> notSpawned = w.getUnspawnedItemTags();
        if (notSpawned.contains("WEAPON_BLOWGUN")) {
            itemsForShop.add("WEAPON_BLOWGUN");
            notSpawned.remove("WEAPON_BLOWGUN");
        }
        while(!notSpawned.isEmpty() && itemsForShop.size()<2) {
            itemsForShop.add(notSpawned.get(0));
            notSpawned.remove(0);
        }
        System.out.println("hardcoded_world_data__shop_extra_items:");
        for(int i = 0;i<2;i++) {
            String tag = "0";
            if (itemsForShop.size() > i) {
                tag = AssemblerTags.tagToAssembler(itemsForShop.get(i));
            }
            System.out.println("  db " + tag);
        }
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
                int ID = a.divisionIDs[j][i];
                if (ID > 255) {
                    throw new Exception("Division ID is larger than 255!");
                }
                if (ID == 0) {
                    ID = 255;
                }
                if (j == 0) {
                    line += ID;
                } else {
                    line += ", " + ID;
                }
            }
            System.out.println(line);
        }
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", #ff");
        }
        
        System.out.println("hardcoded_area_data_"+areaIndex+"__tags:");
        List<Pair<Integer, String>> tagList = a.getSortedTagList();
        int n_tags = tagList.size();
        for(Pair<Integer, String> tag_position:tagList) {
            int offset = tag_position.left;
            String tag = tag_position.right;
            int lockDirection = 0;
            if (w.withinChestTag.contains(tag)) {
                n_tags--;
                continue;
            }
            if (w.lockDirections.containsKey(tag)) {
                lockDirection = w.lockDirections.get(tag);
            }
            System.out.println("  db " + AssemblerTags.tagToAssembler(tag) + ", " + offset + ", " + lockDirection);
        }
        if (n_tags > MAX_N_TAGS) {
            throw new Exception("Too many tags!");
        }
        if (n_tags < MAX_N_TAGS) {
            System.out.println("  ; filler");
            System.out.println("  ds " + (MAX_N_TAGS - n_tags)*3 + ", 0");            
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
