/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.io.FileWriter;
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
        int seeds[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 18, 19, 21, 22};
//        int seeds[] = {7};
        for(int seed: seeds) {
            String worldStr = generateWorldStr(seed);
            FileWriter fw = new FileWriter("src/unittests/hardcoded-world-seed" + seed + ".asm");
            fw.write(worldStr);
            fw.flush();
            fw.close();
        }
    }


    public static String generateWorldStr(int seed1) throws Exception
    {
        MSXRandom r = new MSXRandom(seed1, 0x5555);

        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2_jungle = new PCGArea(true, "jungle");
        PCGArea pcg2_pyramid = new PCGArea(true, "pyramid");
        
        String worldStr = "";
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
            worldStr += generateAssemblerAreaData(w, i, pcg2);
        }
        worldStr += generateAssemblerWorldData(w);
        
        
//        pcg1.mergeAreaRooms(w.areas.get(0));
//        pcg2.generate(w.areas.get(0), w, r);
//        pcg1.mergeAreaRooms(w.areas.get(1));
//        RenderedArea ra = pcg2.generate(w.areas.get(1), w, r);
//        
//        generateAssemblerRenderedAreaData(ra, w.areas.get(1), pcg2);
//        GenerationTest.visualizeArea(ra, "tmp/area"+1+".png", pcg2);

        return worldStr;
    }
    
    
    public static String generateAssemblerWorldData(World w) throws Exception
    {
        // Connections:
        String worldStr = "hardcoded_world_data__interarea_connections:\n";
        worldStr += "  ; each connection is 8 bytes: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)\n";
        for(InterAreaConnection c:w.interAreaconnections) {
            worldStr += "  db " + c.p1.a.ID + ", " + c.p2.a.ID + ", " +
                               (c.p1.x * 2 + c.p1_x_chunk_offs) + ", " + (c.p1.y * 2 + c.p1_y_chunk_offs) + ", " + c.p1.direction + ", " +
                               (c.p2.x * 2 + c.p2_x_chunk_offs) + ", " + (c.p2.y * 2 + c.p2_y_chunk_offs) + ", " + c.p2.direction + "\n";
        }
        if (w.interAreaconnections.size() > MAX_CONNECTIONS) {
            throw new Exception("More connections than supported: " + w.interAreaconnections.size());
        }
        if (w.interAreaconnections.size() < MAX_CONNECTIONS) {
            worldStr += "  ds " + (MAX_CONNECTIONS - w.interAreaconnections.size()) * 8 + ", #ff\n";
        }
        worldStr += "  db #ff  ; sentinel\n";

        // Chest content:
        int n_chests = 0;
        worldStr += "hardcoded_world_data__chest_content:\n";
        worldStr += "  ; each entry is 2 bytes: chest_id, content_id\n";
        for(String chest:w.chestContentSorted) {
            if (chest.contains("boss")) continue;
            worldStr += "  db " + AssemblerTags.tagToAssembler(chest) + ", " + AssemblerTags.tagToAssembler(w.chestContentMap.get(chest)) + "\n";
            n_chests++;
        }
        if (n_chests > MAX_CHESTS) {
            System.err.println(w.chestContentMap);
            throw new Exception("More chests than supported: " + n_chests);
        }
        if (n_chests < MAX_CHESTS) {
            worldStr += "  ds " + (MAX_CHESTS - n_chests) * 2 + ", #ff\n";
        }
        worldStr += "  db #ff  ; sentinel\n";
        
        // Tablet content:
        int n_tablets = 0;
        worldStr += "hardcoded_world_data__tablet_content:\n";
        worldStr += "  ; each entry is 3 bytes: tablet_id, content_ptr\n";
        for(String tablet:w.tabletContentSorted) {
            worldStr += "  db " + AssemblerTags.tagToAssembler(tablet) + "\n";
            worldStr += "  dw " + w.tabletContentMap.get(tablet) + "\n";
            n_tablets++;
        }
        if (n_tablets > MAX_TABLETS) {
            throw new Exception("More tablets than supported: " + n_tablets);
        }
        if (n_tablets < MAX_TABLETS) {
            worldStr += "  ds " + (MAX_TABLETS - n_tablets) * 3 + ", #ff\n";
        }
        worldStr += "  db #ff  ; sentinel\n";
        
        worldStr += "hardcoded_world_data__combination_solutions:\n";
        for(int i = 0;i<4;i++) {
            worldStr += "  db " + w.combinationSolutions[i][0] + ", " +
                                         w.combinationSolutions[i][1] + ", " +
                                         w.combinationSolutions[i][2] + ", " +
                                         w.combinationSolutions[i][3] + ", " +
                                         w.combinationSolutions[i][4] + ", " +
                                         w.combinationSolutions[i][5] + ", " +
                                         w.combinationSolutions[i][6] + ", " +
                                         w.combinationSolutions[i][7] + "\n";
        }
        worldStr += "hardcoded_world_data__trial_types:\n";
        worldStr += "  db " + w.trialTypes[0] + ", " +
                                     w.trialTypes[1] + ", " +
                                     w.trialTypes[2] + ", " +
                                     w.trialTypes[3] + "\n";
        worldStr += "hardcoded_world_data__power_stone_numbers:\n";
        worldStr += "  db " + w.powerStoneNumbers[0] + ", " +
                                     w.powerStoneNumbers[1] + ", " +
                                     w.powerStoneNumbers[2] + ", " +
                                     w.powerStoneNumbers[3] + ", " +
                                     w.powerStoneNumbers[4] + "\n";
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
        worldStr += "hardcoded_world_data__shop_extra_items:\n";
        for(int i = 0;i<2;i++) {
            String tag = "0";
            if (itemsForShop.size() > i) {
                tag = AssemblerTags.tagToAssembler(itemsForShop.get(i));
            }
            worldStr += "  db " + tag + "\n";
        }
        
        return worldStr;
    }
    
    
    public static String generateAssemblerAreaData(World w, int areaIndex, PCGArea pcg2) throws Exception
    {
        String areaStr = "";
        Area a = w.areas.get(areaIndex);
            
        areaStr += "hardcoded_area_data_"+areaIndex+"__seed:\n";
        areaStr += "  dw " + Z80Assembler.toHex16bit(a.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(a.rng_seed2, true) + "\n";
        areaStr += "hardcoded_area_data_"+areaIndex+"__id:\n";
        areaStr += "  db " + a.ID + "\n";
        areaStr += "hardcoded_area_data_"+areaIndex+"__width:\n";
        areaStr += "  db " + a.width + "\n";
        areaStr += "hardcoded_area_data_"+areaIndex+"__height:\n";
        areaStr += "  db " + a.height + "\n";

        areaStr += "hardcoded_area_data_"+areaIndex+"__connections:\n";
        for(int i = 0;i<a.height;i++) {
            String line = "  db ";
            for(int j = 0;j<a.width;j++) {
                if (j == 0) {
                    line += a.connections[j][i];
                } else {
                    line += ", " + a.connections[j][i];
                }
            }
            areaStr += line + "\n";
        }
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            areaStr += "  ; filler\n";
            areaStr += "  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", 0\n";
        }
        
        areaStr += "hardcoded_area_data_"+areaIndex+"__divisionIDs:\n";
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
            areaStr += line + "\n";
        }
        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
            areaStr += "  ; filler\n";
            areaStr += "  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", #ff\n";
        }
        
        areaStr += "hardcoded_area_data_"+areaIndex+"__tags:\n";
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
            areaStr += "  db " + AssemblerTags.tagToAssembler(tag) + ", " + offset + ", " + lockDirection + "\n";
        }
        if (n_tags > MAX_N_TAGS) {
            throw new Exception("Too many tags!");
        }
        if (n_tags < MAX_N_TAGS) {
            areaStr += "  ; filler\n";
            areaStr += "  ds " + (MAX_N_TAGS - n_tags)*3 + ", 0\n";
        }
        return areaStr;
    }
    
    
//    public static void generateAssemblerRenderedAreaData(RenderedArea ra, Area a, PCGArea pcg) throws Exception
//    {
//        System.out.println("hardcoded_area_data__seed:");
//        System.out.println("  dw " + Z80Assembler.toHex16bit(a.rng_seed1, true) + ", " + Z80Assembler.toHex16bit(a.rng_seed2, true));
//        System.out.println("hardcoded_area_data__id:");
//        System.out.println("  db " + a.ID);
//        System.out.println("hardcoded_area_data__width:");
//        System.out.println("  db " + a.width);
//        System.out.println("hardcoded_area_data__height:");
//        System.out.println("  db " + a.height);
//
//        System.out.println("hardcoded_area_data__room_ids:");
//        for(int i = 0;i<a.height;i++) {
//            String line = "  db ";
//            for(int j = 0;j<a.width;j++) {
//                if (j == 0) {
//                    line += a.rooms[j][i];
//                } else {
//                    line += ", " + a.rooms[j][i];
//                }
//            }
//            System.out.println(line);
//        }
//        
//        if (a.height * a.width < MAX_AREA_WIDTH * MAX_AREA_HEIGHT) {
//            System.out.println("  ; filler");
//            System.out.println("  ds " + (MAX_AREA_WIDTH * MAX_AREA_HEIGHT - a.height * a.width) + ", 0");
//        }
//
//        System.out.println("hardcoded_area_data__chunk_ids:");
//        for(int i = 0;i<a.height * 2;i++) {
//            String line = "  db ";
//            for(int j = 0;j<a.width * 2;j++) {
//                int idx = pcg.all_fg_chunks.indexOf(ra.fg_chunks[j][i]);
//                if (j == 0) {
//                    line += idx;
//                } else {
//                    line += ", " + idx;
//                }
//            }
//            System.out.println(line);
//        }
//    }
}
