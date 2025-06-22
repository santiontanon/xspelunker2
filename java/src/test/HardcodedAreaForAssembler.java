/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import pcg.Area;
import pcg.AssemblerTags;
import pcg.GameObjectPlaceholder;
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
public class HardcodedAreaForAssembler {
    public static final int MAX_AREA_WIDTH = 8;
    public static final int MAX_AREA_HEIGHT = 8;
    public static final int MAX_N_TAGS = 32;
    
    public static void main(String args[]) throws Exception
    {
        boolean include_pcg_area__debug_data = true;
        MSXRandom r = new MSXRandom(0, 0xaaaa);


        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2_jungle = new PCGArea(true, "jungle");
        PCGArea pcg2_pyramid = new PCGArea(true, "pyramid");
        
        World w = pcg1.generate(r);        
        RenderedArea ra0 = pcg2_jungle.generate(w.areas.get(0), w, r);
//        RenderedArea ra1 = pcg2.generate(w.areas.get(1), w, r);
//        RenderedArea ra2 = pcg2.generate(w.areas.get(2), w, r);
//        RenderedArea ra3 = pcg2.generate(w.areas.get(3), w, r);
//        RenderedArea ra4 = pcg2.generate(w.areas.get(4), w, r);
//        RenderedArea ra5 = pcg2.generate(w.areas.get(5), w, r);
//        RenderedArea ra6 = pcg2.generate(w.areas.get(6), w, r);
//        RenderedArea ra7 = pcg2.generate(w.areas.get(7), w, r);
//        RenderedArea ra8 = pcg2.generate(w.areas.get(8), w, r);
//        RenderedArea ra9 = pcg2.generate(w.areas.get(9), w, r);
        generateAssemblerRenderedAreaData(ra0, w.areas.get(0), pcg2_jungle, include_pcg_area__debug_data);
//        generateAssemblerRenderedAreaData(ra1, w.areas.get(9), pcg2);
        GenerationTest.visualizeArea(ra0, "tmp/area"+0+".png", pcg2_jungle);
//        GenerationTest.visualizeArea(ra1, "tmp/area"+1+".png", pcg2);
//        GenerationTest.visualizeArea(ra2, "tmp/area"+2+".png", pcg2);
//        GenerationTest.visualizeArea(ra3, "tmp/area"+3+".png", pcg2);
//        GenerationTest.visualizeArea(ra4, "tmp/area"+4+".png", pcg2);
//        GenerationTest.visualizeArea(ra5, "tmp/area"+5+".png", pcg2);
//        GenerationTest.visualizeArea(ra6, "tmp/area"+6+".png", pcg2);
//        GenerationTest.visualizeArea(ra7, "tmp/area"+7+".png", pcg2);
//        GenerationTest.visualizeArea(ra8, "tmp/area"+8+".png", pcg2);
//        GenerationTest.visualizeArea(ra9, "tmp/area"+9+".png", pcg2);
    }
    
    
    public static void generateAssemblerRenderedAreaData(RenderedArea ra, Area a, PCGArea pcg, boolean include_pcg_area__debug_data) throws Exception
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
                    line += Z80Assembler.toHex8bit(idx);
                } else {
                    line += ", " + Z80Assembler.toHex8bit(idx);
                }
            }
            System.out.println(line);
        }
        
        System.out.println("hardcoded_area_data__objects:");
        for(GameObjectPlaceholder go:ra.objectPlaceholders) {
            int offset = go.x + go.y * a.width*2;
            System.out.println("  db " + AssemblerTags.tagToAssembler(go.type) + ", " + offset + ", " + go.ID + ", " + go.extra);
        }
        
        if (include_pcg_area__debug_data) {
            System.out.println("hardcoded_area_data__tmp_pcg_area__piece_types:");
            for(int i = 0;i<a.height * 2;i++) {
                String line = "  db ";
                for(int j = 0;j<a.width * 2;j++) {
                    int type = ra.pieceTypes[j][i];
                    if (j == 0) {
                        line += Z80Assembler.toHex8bit(type);
                    } else {
                        line += ", " + Z80Assembler.toHex8bit(type);
                    }
                }
                System.out.println(line);
            }
            
            System.out.println("hardcoded_area_data__tmp_pcg_area__piece_choose_rng_seeds:");
            for(int i = 0;i<a.height * 2;i++) {
                String line = "  db ";
                for(int j = 0;j<a.width * 2;j++) {
                    int seed1 = ra.pieceChoosingRNGSeed1[j][i];
                    if (j == 0) {
                        line += Z80Assembler.toHex16bit(seed1, true);
                    } else {
                        line += ", " + Z80Assembler.toHex16bit(seed1, true);
                    }
                    int seed2 = ra.pieceChoosingRNGSeed2[j][i];
                    line += ", " + Z80Assembler.toHex16bit(seed2, true) + "    ";
                }
                System.out.println(line);
            }            

            System.out.println("hardcoded_area_data__tmp_pcg_area__piece_choose_pool_size:");
            for(int i = 0;i<a.height * 2;i++) {
                String line = "  db ";
                for(int j = 0;j<a.width * 2;j++) {
                    int size = ra.pieceChoosingChoicesSize[j][i];
                    if (j == 0) {
                        line += size;
                    } else {
                        line += ", " + size;
                    }
                }
                System.out.println(line);
            }            

        }
    }
}
