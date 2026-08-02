/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package xspelunker2;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.imageio.ImageIO;
import util.ConvertPatternsToAssembler;
import util.Z80Assembler;
import util.ZX0Wrapper;

/**
 *
 * @author santi
 */
public class Bosses {
    static int pyramid_collision[] = GenerateChunkData.pyramid_tile_collision_types;
    public static int xibalba_collision[] = {  // modified as the boss tiles are a bit different
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0,
        0, 10, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        10, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 3, 5, 2, 2, 5, 6, 8, 1, 1, 1, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 6, 2, 7, 8, 1, 1, 1, 2, 2, 2, 0,
        0, 0, 0, 0, 0, 2, 2, 12, 2, 2, 12, 2, 2, 2, 2, 3,
        12, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2,
        2, 2, 2, 2, 2, 1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2            
    };     

    public static int atlantis_boss_collision[] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    };
    
    public static int mars_boss_collision[] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 2, 2, 2, 0, 0, 0,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        0, 0, 0, 0, 0, 0, 5, 0, 0, 1, 1, 1, 2, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 1, 5,
    };
    
    public static int moon_boss_collision[] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0,
        2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0,
        2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 0, 0, 2, 2,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 2, 2, 0, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2,
    };    
    
    public static int alien_boss_collision[] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    }; 

    
    public static void main(String args[]) throws Exception
    {
//        boss1Tiles();
//        boss1Sprites();
//
//        boss2Tiles();
//        boss2Sprites();
//
//        boss3Tiles();
//        boss3Sprites();
//
//        Boss4.main(args);
//        
//        boss5Tiles();
//        boss5Sprites();
//
//        boss6Tiles();
//        boss6Sprites();
//
//        boss7Tiles();
//        boss7Sprites();

        boss8Tiles();
        boss8Sprites();
    }
    
    
    public static void boss1Tiles() throws Exception
    {
        String boss1BaseTiles = "data/boss-pyramid-base-tiles.png";
        String boss1Tiles = "data/boss1.png";
                
        boolean availableTiles[] = new boolean[256];
        int collision[] = new int[256];
        findAvailableBossTiles(boss1BaseTiles, availableTiles, collision, pyramid_collision, true);
        BufferedImage baseImage = ImageIO.read(new File(boss1BaseTiles));        
        int nameTable[][] = addBossTilesInGaps(baseImage, boss1Tiles, availableTiles, collision, false);
        ImageIO.write(baseImage, "png", new File("data/boss1-tiles.png"));

        GenerateTiles.extractTiles("data/boss1-tiles.png", "src/autogenerated/boss1-tiles", 24, 128);

        List<Integer> nameTableData = new ArrayList<>();
        addNameTable(nameTable, 10, 0, 16, 9, nameTableData);  // stone version (0 + 6*9)
        addNameTable(nameTable, 4, 0, 10, 9, nameTableData);  // base position (54 + 6*9)
        addNameTable(nameTable, 16, 0, 22, 7, nameTableData);  // staff up (108 + 6*7)
        addNameTable(nameTable, 0, 7, 2, 9, nameTableData);  // face damage (150 + 2*2)
        addNameTable(nameTable, 0, 20, 4, 24, nameTableData);  // legs 0 (154 + 4*4)
        addNameTable(nameTable, 0, 9, 5, 13, nameTableData);  // legs 1 (170 + 5*4)
        addNameTable(nameTable, 5, 9, 9, 13, nameTableData);  // legs 2 (190 + 4*4)
        addNameTable(nameTable, 9, 9, 14, 13, nameTableData);  // legs 3 (206 + 5*4)
        addNameTable(nameTable, 0, 13, 3, 17, nameTableData);  // legs 4 (226 + 3*4)
        addNameTable(nameTable, 4, 20, 8, 23, nameTableData);  // legs 5 (crouch) (238 + 4*3)
        addNameTable(nameTable, 16, 7, 22, 16, nameTableData);  // left-hand attack (250 + 6*9)            
        addNameTable(nameTable, 11, 13, 16, 20, nameTableData);  // base position (no staff) (304 + 5*7)
        addNameTable(nameTable, 17, 16, 22, 22, nameTableData);  // left-hand attack (no staff) (339 + 5*6)
        addNameTable(nameTable, 3, 13, 11, 20, nameTableData);  // punch (369 + 8*7)
        addNameTable(nameTable, 22, 0, 28, 9, nameTableData);  // death-with-staff (425 + 6*9)
        addNameTable(nameTable, 23, 9, 28, 18, nameTableData);  // death-without-staff (479 + 5*9)
        addNameTable(nameTable, 0, 6, 2, 7, nameTableData);  // dust (524 + 2*1)

        System.out.println("name tables: " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss1-nametables.bin");
    }


    public static void boss1Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 0, 15));  // boss name
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 0, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 16, 15));

//        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 32, 15));  // danger mark

        // 5
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 0, 15));  // whirlwind
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 0, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 0, 15));

        // 8
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 16, 15));  // lightning
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 16, 15));
        
        System.out.println("boss1Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss1-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }
    
    
    public static void boss2Tiles() throws Exception
    {
        String bossBaseTiles = "data/boss-pyramid-base-tiles.png";
        
        List<Integer> nameTableData = new ArrayList<>();
        List<int [][]> nametables_left = new ArrayList<>();
        List<int [][]> nametables_right = new ArrayList<>();
        List<int [][]> nametables_flying = new ArrayList<>();
        
        BufferedImage baseImage_left;
        BufferedImage baseImage_right;
        BufferedImage baseImage_flying;
                
        // facing left:
        {
            String boss2Tiles = "data/boss2-land.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, pyramid_collision, true);
            baseImage_left = ImageIO.read(new File(bossBaseTiles));        
            int nameTable[][] = addBossTilesInGaps(baseImage_left, boss2Tiles, availableTiles, collision, false);
            nametables_left.add(nameTable);            
        }

        // facing right:
        {
            String boss2Tiles = "data/boss2-land.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, pyramid_collision, false);
            baseImage_right = ImageIO.read(new File(bossBaseTiles));        
            int nameTable[][] = addBossTilesInGaps(baseImage_right, boss2Tiles, availableTiles, collision, true);
            nametables_right.add(nameTable);
        }
        
        // flying:
        {
            String boss2Tiles = "data/boss2-air.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, pyramid_collision, false);        
            baseImage_flying = ImageIO.read(new File(bossBaseTiles));        
            int nameTable[][] = addBossTilesInGaps(baseImage_flying, boss2Tiles, availableTiles, collision, false);
            nametables_flying.add(nameTable);                        
        }        
        
        // There is no point on this, as there are no shared tiles:
//        reorganizeTilesForBankTransition(baseImage_left, baseImage_flying, nametables_left, nametables_flying);
//        reorganizeTilesForBankTransition(baseImage_right, baseImage_flying, nametables_right, nametables_flying);
        
        int nameTable[][] = nametables_left.get(0);
        addNameTable(nameTable, 17, 0, 26, 4, nameTableData);  // appearing 1 (0 + 9*4)
        addNameTable(nameTable, 16, 4, 26, 9, nameTableData);  // appearing 2 (36 + 10*5)
        addNameTable(nameTable, 15, 9, 26, 14, nameTableData);  // appearing 3 (86 + 11*5)
        addNameTable(nameTable, 15, 14, 26, 19, nameTableData);  // idle left (141 + 11*5)
        addNameTable(nameTable, 15, 19, 27, 24, nameTableData);  // walk left 1 (196 + 12*5)
        addNameTable(nameTable, 15, 24, 27, 29, nameTableData);  // walk left 2 (256 + 12*5)
        addNameTable(nameTable, 3, 19, 14, 24, nameTableData);  // walk left 3 (316 + 11*5)
        addNameTable(nameTable, 2, 24, 14, 29, nameTableData);  // walk left 4 (371 + 12*5)
        addNameTable(nameTable, 3, 14, 14, 19, nameTableData);  // claw attack 1 (431 + 11*5)
        addNameTable(nameTable, 2, 9, 15, 14, nameTableData);  // claw attack 2 (486 + 13*5)
        addNameTable(nameTable, 4, 4, 15, 9, nameTableData);  // sonic wave attack (551 + 11*5)
        
        nameTable = nametables_flying.get(0);
        // flying:
        addNameTable(nameTable, 2, 0, 15, 8, nameTableData);  // appearing 1 (606 + 13*8)            
        addNameTable(nameTable, 1, 9, 16, 16, nameTableData);  // appearing 1 (710 + 15*7)            
        addNameTable(nameTable, 1, 16, 16, 23, nameTableData);  // appearing 1 (815 + 15*7)            
        // taking off:
        addNameTable(nameTable, 19, 0, 29, 8, nameTableData);  // appearing 1 (920 + 10*8)
        addNameTable(nameTable, 19, 8, 29, 16, nameTableData);  // appearing 1 (1000 + 10*8)
        
        
        ImageIO.write(baseImage_left, "png", new File("data/boss2-tiles.png"));
        GenerateTiles.extractTiles("data/boss2-tiles.png", "src/autogenerated/boss2-tiles", 24, 128);

        ImageIO.write(baseImage_right, "png", new File("data/boss2-tiles-right.png"));
        GenerateTiles.extractTiles("data/boss2-tiles-right.png", "src/autogenerated/boss2-tiles-right", 24, 128);            
        
        ImageIO.write(baseImage_flying, "png", new File("data/boss2-tiles-air.png"));
        GenerateTiles.extractTiles("data/boss2-tiles-air.png", "src/autogenerated/boss2-tiles-air", 24, 128);            

        System.out.println("name tables: " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss2-nametables.bin");        
    }
    
    
    public static void boss2Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 32, 15));  // boss name
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 32, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 48, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 48, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 32, 15));  // eye
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 32, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 48, 15));  // sonic boom
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 48, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 48, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 32, 15));  // eyes front

        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 48, 15));  // spikes
        
        // filler until reaching the bat sprite:
        for(int i = 12;i<16;i++) {
            for(int j = 0;j<32;j++) data.add(0);
        }
        
        // bats (16):
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 64, 15));  // bat right
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 64, 15));
        data.addAll(GenerateSprites.extractSpriteFlipped(sourceImage, 0, 64, 15));  // bat left
        data.addAll(GenerateSprites.extractSpriteFlipped(sourceImage, 16, 64, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 64, 15));  // bat hanging
        
        System.out.println("boss2Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss2-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }

    
    public static void boss3Tiles() throws Exception
    {
        String bossBaseTiles = "data/boss-pyramid-base-tiles.png";
        
        List<Integer> nameTableData = new ArrayList<>();
        {
            // Walking:
            String boss3Tiles = "data/boss3-walk.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, pyramid_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        
            int nameTable[][] = addBossTilesInGaps(baseImage, boss3Tiles, availableTiles, collision, false);
            ImageIO.write(baseImage, "png", new File("data/boss3-tiles-walk.png"));

            GenerateTiles.extractTiles("data/boss3-tiles-walk.png", "src/autogenerated/boss3-tiles-walk", 24, 128);

            addNameTable(nameTable, 27, 0, 30, 4, nameTableData);  // head (0 + 3*4)
            addNameTable(nameTable, 21, 0, 24, 4, nameTableData);  // head on body (36 + 3*4)
            addNameTable(nameTable, 24, 0, 27, 4, nameTableData);  // head on body (24 + 3*4)
            addNameTable(nameTable, 18, 0, 21, 4, nameTableData);  // head (12 + 3*4)
            
            addNameTable(nameTable, 0, 4, 7, 12, nameTableData);  // still (48 + 7*8)

            addNameTable(nameTable, 0, 12, 10, 20, nameTableData);  // walk (104 + 10*8)
            addNameTable(nameTable, 10, 12, 20, 20, nameTableData);  // walk (184 + 10*8)
            addNameTable(nameTable, 0, 20, 8, 28, nameTableData);  // walk (264 + 8*8)
            addNameTable(nameTable, 8, 20, 16, 28, nameTableData);  // walk (328 + 8*8)
        }

        {
            // stomp:
            String boss3Tiles = "data/boss3-stomp.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, pyramid_collision, false);        
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        
            int nameTable[][] = addBossTilesInGaps(baseImage, boss3Tiles, availableTiles, collision, false);
            ImageIO.write(baseImage, "png", new File("data/boss3-tiles-stomp.png"));

            GenerateTiles.extractTiles("data/boss3-tiles-stomp.png", "src/autogenerated/boss3-tiles-stomp", 24, 128);            
            
            addNameTable(nameTable, 13, 17, 20, 28, nameTableData);  // stomp up (368 + 7*11)
            addNameTable(nameTable, 0, 17, 11, 22, nameTableData);  // stomp down (445 + 11*5)
            addNameTable(nameTable, 0, 22, 11, 28, nameTableData);  // stomp down head (500 + 11*6)            
        }
        
        System.out.println("name tables: " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss3-nametables.bin");        
    }

    
    public static void boss3Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 64, 15));  // boss name
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 64, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 80, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 80, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 80, 15));  // eye

        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 80, 15));  // debris
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 80, 15));  // debris

        System.out.println("boss3Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss3-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }

    
    public static void boss5Tiles() throws Exception
    {
        List<Integer> nameTableDataShared = new ArrayList<>();        
        List<Integer> nameTableDataCharybdis = new ArrayList<>();        
        List<Integer> nameTableDataScylla = new ArrayList<>();        
        
        {
            // Create a base image that just has the crab tiles:
            // Charybdis body:
            String bossBaseTiles = "data/boss5-base-tiles.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{0, 320, 128, 360});  // crab body basic position
            nameTableBoxes.add(new int[]{0, 448, 16, 456});  // mouth
            nameTableBoxes.add(new int[]{128, 320, 192, 368});  // basic claws
            nameTableBoxes.add(new int[]{72, 440, 168, 464});  // arm stumps
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, false);

            int nameTable[][] = nametables.get(0);
            addNameTable(nameTable, 0, 0, 16, 5, nameTableDataCharybdis);  // body base 16*5
            nameTable = nametables.get(1);
            addNameTable(nameTable, 0, 0, 2, 1, nameTableDataCharybdis);  // mouth 2*1
            nameTable = nametables.get(2);
            addNameTable(nameTable, 0, 0, 4, 3, nameTableDataCharybdis);  // left claw open (4x3)
            addNameTable(nameTable, 4, 0, 8, 3, nameTableDataCharybdis);  // right claw open (4x3)
            addNameTable(nameTable, 0, 3, 4, 6, nameTableDataCharybdis);  // left claw closed (4x3)
            addNameTable(nameTable, 4, 3, 8, 6, nameTableDataCharybdis);  // right claw closed (4x3)

            nameTable = nametables.get(3);
            addNameTable(nameTable, 0, 0, 2, 3, nameTableDataCharybdis);  // left stump (2x3)
            addNameTable(nameTable, 2, 0, 4, 3, nameTableDataCharybdis);  // right stump (2x3)
            addNameTable(nameTable, 4, 0, 6, 2, nameTableDataCharybdis);  // left stump rising (2x2)
            addNameTable(nameTable, 6, 0, 8, 2, nameTableDataCharybdis);  // right stump rising (2x2)
            addNameTable(nameTable, 8, 0, 10, 3, nameTableDataCharybdis);  // left stump up (2x3)
            addNameTable(nameTable, 10, 0, 12, 3, nameTableDataCharybdis);  // right stump up (2x3)
            
            ImageIO.write(baseImage, "png", new File("data/boss5-base-tiles-charybdis.png"));        
        }
        
        {
            // Charybdis + walk + island:
            String bossBaseTiles = "data/boss5-base-tiles-charybdis.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{0, 320, 128, 560});  // crab walk
            nameTableBoxes.add(new int[]{0, 464, 128, 512});  // crab jump
            nameTableBoxes.add(new int[]{192, 320, 256, 448});  // island
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, true);

            ImageIO.write(baseImage, "png", new File("data/boss5-tiles-charybdis1.png"));

            GenerateTiles.extractTiles("data/boss5-tiles-charybdis1.png", "src/autogenerated/boss5-tiles-charybdis1", 24, 128);

            int nameTable[][] = nametables.get(2);
            addNameTable(nameTable, 0, 0, 8, 7, nameTableDataShared);  // island (0)
            addNameTable(nameTable, 0, 7, 8, 12, nameTableDataShared);  // island damage 1 (0 + 8*7)
            addNameTable(nameTable, 0, 12, 8, 16, nameTableDataShared);  // island damage 2 (56 + 8*5)

            nameTable = nametables.get(1);
            addNameTable(nameTable, 1, 0, 15, 6, nameTableDataCharybdis);  // body jump 14*6
            
            nameTable = nametables.get(0);
            addNameTable(nameTable, 0, 5, 16, 10, nameTableDataCharybdis);  // body walk 1 16*5
            addNameTable(nameTable, 0, 10, 16, 15, nameTableDataCharybdis);  // body walk 2 16*5
        }

        {
            // Charybdis + walk + brain:
            String bossBaseTiles = "data/boss5-base-tiles-charybdis.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{0, 320, 128, 560});  // crab walk
            nameTableBoxes.add(new int[]{192, 448, 256, 512});  // brain
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, true);

            ImageIO.write(baseImage, "png", new File("data/boss5-tiles-charybdis2.png"));

            int nameTable[][] = nametables.get(1);
            addNameTable(nameTable, 0, 0, 6, 4, nameTableDataShared);  // vat (0)
            addNameTable(nameTable, 0, 4, 6, 7, nameTableDataShared);  // brain 1 (0 + 8*7)
            
            List<Integer> data = GenerateTiles.extractTiles("data/boss5-tiles-charybdis2.png", "src/autogenerated/boss5-tiles-charybdis2", 24, 128);
            
            // Generate a patch to be used to go from charybdis3 to this:
            {
                List<Integer> patch_data = new ArrayList<>();
                int attributes_start = data.size() / 2;
                // patterns:
                for(int i = (7*16 + 2) * 8; i< (10*16 + 4) * 8;i++) {
                    patch_data.add(data.get(i));
                }
                // attributes:
                for(int i = (7*16 + 2) * 8; i< (10*16 + 4) * 8;i++) {
                    patch_data.add(data.get(i + attributes_start));
                }
                // 3*16 + 2 = 50 tiles
                Z80Assembler.dataToBinary(patch_data, "src/autogenerated/boss5-tiles-charybdis2-patch.bin");
                ZX0Wrapper.main("src/autogenerated/boss5-tiles-charybdis2-patch.bin",
                                "src/autogenerated/boss5-tiles-charybdis2-patch.zx0", true, false);            
            }
        }
        
        {
            // Charybdis + brain + claw attack:
            String bossBaseTiles = "data/boss5-base-tiles-charybdis.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{128, 368, 192, 440});  // claws attack
            nameTableBoxes.add(new int[]{128, 464, 192, 560});  // flying claws
            nameTableBoxes.add(new int[]{192, 448, 256, 512});  // brain
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, true);

            ImageIO.write(baseImage, "png", new File("data/boss5-tiles-charybdis3.png"));

            int nameTable[][] = nametables.get(0);
            addNameTable(nameTable, 0, 0, 4, 3, nameTableDataCharybdis);  // left claw rising (4x3)
            addNameTable(nameTable, 4, 0, 8, 3, nameTableDataCharybdis);  // right claw rising (4x3)
            addNameTable(nameTable, 0, 3, 3, 9, nameTableDataCharybdis);  // left claw up (3x6)
            addNameTable(nameTable, 3, 3, 6, 9, nameTableDataCharybdis);  // right claw up (3x6)
            
            nameTable = nametables.get(1);
            addNameTable(nameTable, 0, 0, 5, 3, nameTableDataCharybdis);  // flying claw right 1 (5x3)
            addNameTable(nameTable, 0, 3, 5, 6, nameTableDataCharybdis);  // flying claw right 2 (5x3)
            addNameTable(nameTable, 0, 6, 5, 9, nameTableDataCharybdis);  // flying claw left 1 (5x3)
            addNameTable(nameTable, 0, 9, 5, 12, nameTableDataCharybdis);  // flying claw left 2 (5x3)
            
            List<Integer> data = GenerateTiles.extractTiles("data/boss5-tiles-charybdis3.png", "src/autogenerated/boss5-tiles-charybdis3", 24, 128);
            // Generate a patch to be used to go from charybdis2 to this:
            {
                List<Integer> patch_data = new ArrayList<>();
                int attributes_start = data.size() / 2;
                // patterns:
                for(int i = (7*16 + 2) * 8; i< (11*16 + 4) * 8;i++) {
                    patch_data.add(data.get(i));
                }
                // attributes:
                for(int i = (7*16 + 2) * 8; i< (11*16 + 4) * 8;i++) {
                    patch_data.add(data.get(i + attributes_start));
                }
                // 4*16 + 2 = 66 tiles
                Z80Assembler.dataToBinary(patch_data, "src/autogenerated/boss5-tiles-charybdis3-patch.bin");
                ZX0Wrapper.main("src/autogenerated/boss5-tiles-charybdis3-patch.bin",
                                "src/autogenerated/boss5-tiles-charybdis3-patch.zx0", true, false);            
            }            
        }        
        {
            // Scylla body:
            String bossBaseTiles = "data/boss5-base-tiles.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{256, 320, 560, 584});  // octopus body and tentacles
            nameTableBoxes.add(new int[]{560, 504, 640, 584});  // additional tentacles l/r
            nameTableBoxes.add(new int[]{560, 320, 640, 432});  // additional tentacles f
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, false);

            int nameTable[][] = nametables.get(0);
            addNameTable(nameTable, 0, 0, 6, 6, nameTableDataScylla);  // body (6x6)
            addNameTable(nameTable, 0, 6, 6, 12, nameTableDataScylla);  // body blink (6x6)
            addNameTable(nameTable, 6, 0, 12, 6, nameTableDataScylla);  // body mouth open (6x6)

            addNameTable(nameTable, 32, 0, 38, 9, nameTableDataScylla);  // front arm -5 (6x9)
            nameTable = nametables.get(2);
            addNameTable(nameTable, 0, 7, 6, 14, nameTableDataScylla);  // front arm -4 (6x7)
            nameTable = nametables.get(0);
            addNameTable(nameTable, 20, 10, 26, 15, nameTableDataScylla);  // front arm -3 (6x5)
            addNameTable(nameTable, 23, 0, 32, 5, nameTableDataScylla);   // front arm -2 (9x5)
            addNameTable(nameTable, 12, 0, 16, 8, nameTableDataScylla);   // front arm -1 (4x8)
            addNameTable(nameTable, 16, 0, 18, 11, nameTableDataScylla);  // front arm  0 (2x11)
            addNameTable(nameTable, 18, 0, 23, 8, nameTableDataScylla);   // front arm  1 (5x8)
            addNameTable(nameTable, 23, 5, 32, 10, nameTableDataScylla);  // front arm  2 (9x5)
            addNameTable(nameTable, 26, 10, 32, 15, nameTableDataScylla);  // front arm  3 (6x5)
            nameTable = nametables.get(2);
            addNameTable(nameTable, 0, 0, 5, 7, nameTableDataScylla);  // front arm 4 (5x7)
            nameTable = nametables.get(0);
            addNameTable(nameTable, 33, 9, 38, 18, nameTableDataScylla);  // front arm  5 (5x9)

            addNameTable(nameTable, 0, 12, 2, 22, nameTableDataScylla);  // right arm  0 (2x10)
            addNameTable(nameTable, 6, 12, 11, 19, nameTableDataScylla);   // right arm  1 (5x7)
            addNameTable(nameTable, 11, 16, 17, 21, nameTableDataScylla);  // right arm  2 (6x5)
            addNameTable(nameTable, 12, 26, 18, 31, nameTableDataScylla);  // right arm  3 (6x5)
            addNameTable(nameTable, 6, 22, 11, 30, nameTableDataScylla);  // right arm  4 (5x8)
            nameTable = nametables.get(1);
            addNameTable(nameTable, 5, 0, 9, 10, nameTableDataScylla);  // right arm  5 (4x10)

            addNameTable(nameTable, 0, 0, 5, 10, nameTableDataScylla);  // left arm  -5 (5x10)
            nameTable = nametables.get(0);
            addNameTable(nameTable, 0, 22, 6, 30, nameTableDataScylla);  // left arm  -4 (6x8)
            addNameTable(nameTable, 12, 21, 18, 26, nameTableDataScylla);  // left arm  -3 (6x5)
            addNameTable(nameTable, 13, 11, 19, 16, nameTableDataScylla);  // left arm  -2 (6x5)
            addNameTable(nameTable, 2, 12, 6, 19, nameTableDataScylla);   // left arm  -1 (4x7)
            addNameTable(nameTable, 19, 15, 21, 25, nameTableDataScylla);  // left arm  0 (2x10)
            
            addNameTable(nameTable, 29, 23, 31, 33, nameTableDataScylla);  // right back arm  0 (2x10)
            addNameTable(nameTable, 26, 15, 30, 21, nameTableDataScylla);  // right back arm  1 (4x6)
            addNameTable(nameTable, 21, 23, 27, 28, nameTableDataScylla);  // right back arm  2 (6x5)
            addNameTable(nameTable, 31, 19, 36, 23, nameTableDataScylla);  // right back arm  3 (5x4)

            addNameTable(nameTable, 32, 26, 37, 30, nameTableDataScylla);  // left back arm  -3 (5x4)
            addNameTable(nameTable, 21, 28, 27, 33, nameTableDataScylla);  // left back arm  -2 (6x5)
            addNameTable(nameTable, 23, 15, 26, 21, nameTableDataScylla);  // left back arm  -1 (3x6)
            addNameTable(nameTable, 27, 23, 29, 33, nameTableDataScylla);  // left back arm  0 (2x10)
            

            ImageIO.write(baseImage, "png", new File("data/boss5-base-tiles-scylla.png"));        
        }

        {
            // Scylla body + island:
            String bossBaseTiles = "data/boss5-base-tiles-scylla.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{192, 320, 256, 448});  // island
            addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, true);
            ImageIO.write(baseImage, "png", new File("data/boss5-tiles-scylla1.png"));
            GenerateTiles.extractTiles("data/boss5-tiles-scylla1.png", "src/autogenerated/boss5-tiles-scylla1", 24, 128);
        }
        
        {
            // Scylla body + brain:
            String bossBaseTiles = "data/boss5-base-tiles-scylla.png";
            String boss5Tiles = "data/boss5.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, atlantis_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.add(new int[]{264, 584, 328, 616});  // dettaching tentacle attack
            nameTableBoxes.add(new int[]{192, 448, 256, 512});  // brain
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, true);
            
            int nameTable[][] = nametables.get(0);
            addNameTable(nameTable, 1, 0, 2, 3, nameTableDataScylla);  // dettached tip  (1x3)
            addNameTable(nameTable, 7, 0, 8, 4, nameTableDataScylla);  // dettached big tip  (1x4)
            addNameTable(nameTable, 4, 0, 7, 1, nameTableDataScylla);  // dettached tip right  (3x1)
            addNameTable(nameTable, 3, 2, 6, 3, nameTableDataScylla);  // dettached tip left  (3x1)

            System.out.println("BOSS_5_SCYLLA_THREAD_V_TILE: equ " + nameTable[0][0]);
            System.out.println("BOSS_5_SCYLLA_THREAD_V_TILE_START: equ " + nameTable[0][1]);
            System.out.println("BOSS_5_SCYLLA_THREAD_V_WIDE_TILE_START: equ " + nameTable[2][1]);
            System.out.println("BOSS_5_SCYLLA_THREAD_H_TILE: equ " + nameTable[3][0]);
            System.out.println("BOSS_5_SCYLLA_THREAD_L_HINGE: equ " + nameTable[6][2]);
            System.out.println("BOSS_5_SCYLLA_THREAD_R_HINGE: equ " + nameTable[2][0]);
            
            ImageIO.write(baseImage, "png", new File("data/boss5-tiles-scylla2.png"));
            GenerateTiles.extractTiles("data/boss5-tiles-scylla2.png", "src/autogenerated/boss5-tiles-scylla2", 24, 128);
        }

        System.out.println("name tables: " + nameTableDataShared.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableDataShared, "src/autogenerated/boss5-nametables-shared.bin");
        System.out.println("name tables: " + nameTableDataCharybdis.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableDataCharybdis, "src/autogenerated/boss5-nametables-charybdis.bin");
        System.out.println("name tables: " + nameTableDataScylla.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableDataScylla, "src/autogenerated/boss5-nametables-scylla.bin");

    }
    
    
    public static void boss5Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet (0)

        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 0, 15));  // charybdis boss name (1)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 0, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 16, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 32, 15));  // scylla boss name (5)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 32, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 48, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 48, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 144, 15));  // eyes (9)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 144, 15));
        
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 144, 15));  // bubbles (11)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 144, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 144, 15));

        System.out.println("boss5Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss5-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }
    
    
    public static void boss6Tiles() throws Exception
    {
        List<Integer> nameTableData = new ArrayList<>();        
        
        {
            // base face:
            String bossBaseTiles = "data/boss6-base-tiles.png";
            String boss5Tiles = "data/boss6.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, mars_boss_collision, true);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
//            nameTableBoxes.add(new int[]{0, 32, 168, 256});  // base face
            nameTableBoxes.add(new int[]{0, 32, 256, 256});  // base face
            List<int[][]> nametables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss5Tiles, availableTiles, collision, false, false);

            int nameTable[][] = nametables.get(0);
            addNameTable(nameTable, 1, 1, 9, 13, nameTableData);  // face off  8x12
            addNameTable(nameTable, 10, 1, 18, 13, nameTableData);  // face on  8x12
            addNameTable(nameTable, 22, 1, 30, 13, nameTableData);  // face robot  8x12

            addNameTable(nameTable, 0, 10, 3, 15, nameTableData);  // mouth closed  3x5
            addNameTable(nameTable, 9, 10, 12, 15, nameTableData);  // mouth open  3x5

            addNameTable(nameTable, 5, 4, 6, 5, nameTableData);  // eyes empty 1x1
            addNameTable(nameTable, 19, 1, 20, 2, nameTableData);  // eyes appearing 1x1
            addNameTable(nameTable, 19, 2, 20, 3, nameTableData);  // eyes appearing 2 1x1
            addNameTable(nameTable, 19, 3, 20, 4, nameTableData);  // eyes on 1x1
            addNameTable(nameTable, 19, 4, 20, 5, nameTableData);  // eyes turret appearing 1 1x1
            addNameTable(nameTable, 19, 5, 20, 6, nameTableData);  // eyes turret appearing 2 1x1
            addNameTable(nameTable, 19, 6, 20, 7, nameTableData);  // eyes turret appearing 3 1x1
            addNameTable(nameTable, 19, 7, 20, 8, nameTableData);  // eyes turret 1x1
            addNameTable(nameTable, 19, 8, 20, 9, nameTableData);  // eyes turret up 1x1
            addNameTable(nameTable, 19, 9, 20, 10, nameTableData);  // eyes turret down 1x1

            addNameTable(nameTable, 19, 10, 20, 11, nameTableData);  // face turret 1x1
            addNameTable(nameTable, 19, 11, 20, 12, nameTableData);  // face turret up 1x1
            addNameTable(nameTable, 19, 12, 20, 13, nameTableData);  // face turret down 1x1

            addNameTable(nameTable, 0, 19, 4, 23, nameTableData);  // fist (4x4)
            addNameTable(nameTable, 1, 15, 3, 19, nameTableData);  // arm (2x4)

            ImageIO.write(baseImage, "png", new File("data/boss6-tiles.png"));
            GenerateTiles.extractTiles("data/boss6-tiles.png", "src/autogenerated/boss6-tiles", 24, 128);
        }        
                
        System.out.println("name tables: " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss6-nametables.bin");
    }
    
    
    public static void boss6Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 64, 15));  // boss name (1)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 64, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 80, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 80, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 160, 15));  // stone (5)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 160, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 160, 15));  // eye laser (9)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 160, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 144, 160, 15));

        // filler (15)
        for(int i = 0;i<32 * 12;i++) {
            data.add(0);
        }
        
        // drone (27):
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 176, 15));  // drone
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 192, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 192, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 192, 15));
        
        
        System.out.println("boss6Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss6-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }

    
    public static void boss7Tiles() throws Exception
    {
        List<Integer> nameTableData = new ArrayList<>();        
        List<Integer> nameTableData_snake = new ArrayList<>();        
        int lastBodyTile = 0;
        
        // Phase 1:
        {
            String bossBaseTiles = "data/boss7-base-tiles.png";
            String boss7Tiles = "data/boss7.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, moon_boss_collision, false);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{0, 96, 64, 320});  // statue
            List<int[][]> nametables_statue = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, true);
            // mark statue tiles with "2":
            for(int i = 0;i<256;i++) {
                if (collision[i] == 9 && !availableTiles[i]) {
                    collision[i] = 2;
                }
            }            
            // phase 1 snake tiles:
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{0, 32, 256, 96});  // snake
            List<int[][]> nametables_phase1 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, false);
            
            // phase 2 tiles:
//            nameTableBoxes.clear();
//            nameTableBoxes.add(new int[]{88, 104, 232, 232});  // phase 2 snake
//            List<int[][]> nametables3 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, false);
            
            // statue:
            int nameTable[][] = nametables_statue.get(0);
            addNameTable(nameTable, 0, 12, 8, 28, nameTableData);  // statue full  8x16

            // snake within statue phase 1:
            nameTable = nametables_phase1.get(0);
            addNameTable(nameTable, 3, 1, 4, 2, nameTableData);  // appearing 1 1x1
            addNameTable(nameTable, 6, 0, 8, 2, nameTableData);  // appearing 2 2x2
            addNameTable(nameTable, 9, 0, 12, 3, nameTableData);  // appearing 3 3x3
            addNameTable(nameTable, 12, 0, 16, 3, nameTableData);  // appearing 4 4x3
            addNameTable(nameTable, 16, 0, 21, 3, nameTableData);  // appearing 5 5x3

            addNameTable(nameTable, 0, 4, 6, 7, nameTableData);  // out 6x3
            addNameTable(nameTable, 6, 4, 12, 8, nameTableData);  // out mouth open 6x4
            addNameTable(nameTable, 12, 4, 18, 7, nameTableData);  // out up 6x3
            addNameTable(nameTable, 18, 4, 24, 8, nameTableData);  // out up mouth open 6x4
            
            for(int i = 0;i<16;i++) {
                String line = "    db ";
                for(int j = 0;j<16;j++) {
                    line += collision[j + i*16] + ", ";
                }
                System.out.println(line.substring(0, line.length() - 2));
            }
            
            
            ImageIO.write(baseImage, "png", new File("data/boss7-tiles.png"));
            GenerateTiles.extractTiles("data/boss7-tiles.png", "src/autogenerated/boss7-tiles", 24, 128);
        }
        
        // Phase 2:
        {
            String bossBaseTiles = "data/boss7-base-tiles.png";
            String boss7Tiles = "data/boss7.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, moon_boss_collision, false);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{0, 96, 64, 192});  // statue
            List<int[][]> nametables_statue = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, true);
            // mark statue tiles with "2":
            for(int i = 0;i<256;i++) {
                if (collision[i] == 9 && !availableTiles[i]) {
                    collision[i] = 2;
                }
            }            
            // phase 2 snake tiles:
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{88, 104, 320, 224});
            List<int[][]> nametables_phase2 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, false);
            
            // broken statue:
            int nameTable[][] = nametables_statue.get(0);
            addNameTable(nameTable, 2, 5, 8, 12, nameTableData);  // statue broken  6x7

            // snake pieces
            nameTable = nametables_phase2.get(0);
            addNameTable(nameTable, 0, 0, 4, 5, nameTableData_snake);  // d-r / r-d
            addNameTable(nameTable, 4, 0, 8, 5, nameTableData_snake);  // l-r / r-l (1)
            addNameTable(nameTable, 8, 0, 12, 5, nameTableData_snake);  // l-d / d-l
            addNameTable(nameTable, 12, 0, 16, 5, nameTableData_snake);  // u-r / r-u
            addNameTable(nameTable, 24, 5, 28, 10, nameTableData_snake);  // u-d / d-u (1)
            addNameTable(nameTable, 20, 0, 24, 5, nameTableData_snake);  // l-u / u-l

            // l-r / r-l variations:
            addNameTable(nameTable, 0, 5, 4, 10, nameTableData_snake);  // l-r / r-l (2)
            addNameTable(nameTable, 4, 5, 8, 10, nameTableData_snake);  // l-r / r-l (3)
            addNameTable(nameTable, 8, 5, 12, 10, nameTableData_snake);  // l-r / r-l (4)

            // u-d / d-u variations:
            addNameTable(nameTable, 20, 5, 24, 10, nameTableData_snake);  // u-d / d-u (2)
            addNameTable(nameTable, 16, 5, 20, 10, nameTableData_snake);  // u-d / d-u (4)
            addNameTable(nameTable, 12, 5, 16, 10, nameTableData_snake);  // u-d / d-u (4)
            addNameTable(nameTable, 16, 0, 20, 5, nameTableData_snake);  // u-d / d-u (5)
            
            // find the first tile of the head:
            for(int i = 0;i<nameTableData_snake.size();i++) {
                lastBodyTile = Math.max(lastBodyTile, nameTableData_snake.get(i));
            }            
 
            addNameTable(nameTable, 0, 10, 4, 15, nameTableData_snake);  // head left
            addNameTable(nameTable, 4, 10, 8, 15, nameTableData_snake);  // head left mouth
            addNameTable(nameTable, 8, 10, 12, 15, nameTableData_snake);  // head right
            addNameTable(nameTable, 12, 10, 16, 15, nameTableData_snake);  // head right mouth
            addNameTable(nameTable, 16, 10, 20, 15, nameTableData_snake);  // head up
            addNameTable(nameTable, 20, 10, 24, 15, nameTableData_snake);  // head down
            
            for(int i = 0;i<16;i++) {
                String line = "    db ";
                for(int j = 0;j<16;j++) {
                    line += collision[j + i*16] + ", ";
                }
                System.out.println(line.substring(0, line.length() - 2));
            }
            
            ImageIO.write(baseImage, "png", new File("data/boss7-tiles-phase2.png"));
            GenerateTiles.extractTiles("data/boss7-tiles-phase2.png", "src/autogenerated/boss7-tiles-phase2", 24, 128);
        }
        
        // Phase 3/4:
        {
            String bossBaseTiles = "data/boss7-base-tiles.png";
            String boss7Tiles = "data/boss7.png";
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            findAvailableBossTiles(bossBaseTiles, availableTiles, collision, moon_boss_collision, false);
            BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

            List<int[]> nameTableBoxes = new ArrayList<>();
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{24, 96, 48, 136});  // statue
            List<int[][]> nametables_statue = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, true);
            // mark statue tiles with "2":
            for(int i = 0;i<256;i++) {
                if (collision[i] == 9 && !availableTiles[i]) {
                    collision[i] = 2;
                }
            }            
            // phase 3/4 snake tiles:
            nameTableBoxes.clear();
            nameTableBoxes.add(new int[]{88, 104, 320, 304});
            List<int[][]> nametables_phase2 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss7Tiles, availableTiles, collision, false, false);
            
            // final broken statue:
            int nameTable[][] = nametables_statue.get(0);
            addNameTable(nameTable, 0, 0, 3, 5, nameTableData);  // final broken statue 3x5
             
            // dead head:
            nameTable = nametables_phase2.get(0);
            addNameTable(nameTable, 0, 15, 4, 20, nameTableData_snake);  // dead head left
            addNameTable(nameTable, 8, 15, 12, 20, nameTableData_snake);  // dead head right
            addNameTable(nameTable, 16, 15, 20, 20, nameTableData_snake);  // dead head up
            addNameTable(nameTable, 20, 15, 24, 20, nameTableData_snake);  // dead head down
            
            // broken midsection:
            addNameTable(nameTable, 0, 20, 4, 25, nameTableData_snake);  // left
            addNameTable(nameTable, 8, 20, 12, 25, nameTableData_snake);  // right
            addNameTable(nameTable, 16, 20, 20, 25, nameTableData_snake);  // up
            addNameTable(nameTable, 20, 20, 24, 25, nameTableData_snake);  // down
            
            for(int i = 0;i<16;i++) {
                String line = "    db ";
                for(int j = 0;j<16;j++) {
                    line += collision[j + i*16] + ", ";
                }
                System.out.println(line.substring(0, line.length() - 2));
            }
            
            ImageIO.write(baseImage, "png", new File("data/boss7-tiles-phase3.png"));
            GenerateTiles.extractTiles("data/boss7-tiles-phase3.png", "src/autogenerated/boss7-tiles-phase3", 24, 128);
        }
        
        FileWriter fw = new FileWriter("src/autogenerated/boss7-constants.asm");
        fw.write("BOSS7_PHASE2_FIRST_HEAD_TILE: equ " + (lastBodyTile + 1) + "\n");
        fw.close();
                
        
        System.out.println("name tables (for bosses page): " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss7-nametables.bin");
        System.out.println("name tables (for boss7 page): " + nameTableData_snake.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData_snake, "src/autogenerated/boss7-nametables-snake.bin");
    }

    
    public static void boss7Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 96, 15));  // boss name (1)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 96, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 112, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 112, 15));
        
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 112, 15));  // poison ball (5)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 112, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 176, 15));  // poison pool (7)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 176, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 176, 15));

        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 192, 15));  // vertical eye sprite (11)
        
        System.out.println("boss7Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss7-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }

    
    
    public static void boss8Tiles() throws Exception
    {
        List<Integer> nameTableData = new ArrayList<>();        

        
        String bossBaseTilesPath = "data/boss8-base-tiles.png";
        String boss5TilesPath = "data/boss8.png";
        boolean availableTiles_phase1[] = new boolean[256];
        boolean availableTiles_phase1b_12[] = new boolean[256];
//        boolean availableTiles_phase1b_3[] = new boolean[256];
        boolean availableTiles_phase2_12a[] = new boolean[256];
        boolean availableTiles_phase2_12b[] = new boolean[256];
        boolean availableTiles_phase2_3[] = new boolean[256];
        int collision_phase1[] = new int[256];
        int collision_phase1b_12[] = new int[256];
//        int collision_phase1b_3[] = new int[256];
        int collision_phase2_12a[] = new int[256];
        int collision_phase2_12b[] = new int[256];
        int collision_phase2_3[] = new int[256];
        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase1, collision_phase1, alien_boss_collision, true);
        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase1b_12, collision_phase1b_12, alien_boss_collision, true);
//        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase1b_3, collision_phase1b_3, alien_boss_collision, true);
        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase2_12a, collision_phase2_12a, alien_boss_collision, true);
        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase2_12b, collision_phase2_12b, alien_boss_collision, true);
        findAvailableBossTiles(bossBaseTilesPath, availableTiles_phase2_3, collision_phase2_3, alien_boss_collision, true);
        BufferedImage baseImage_phase1 = ImageIO.read(new File(bossBaseTilesPath));        
        BufferedImage baseImage_phase1b_12 = ImageIO.read(new File(bossBaseTilesPath));        
//        BufferedImage baseImage_phase1b_3 = ImageIO.read(new File(bossBaseTilesPath));        
        BufferedImage baseImage_phase2_12a = ImageIO.read(new File(bossBaseTilesPath));        
        BufferedImage baseImage_phase2_12b = ImageIO.read(new File(bossBaseTilesPath));        
        BufferedImage baseImage_phase2_3 = ImageIO.read(new File(bossBaseTilesPath));        

        List<int[]> nameTableBoxes = new ArrayList<>();
        nameTableBoxes.add(new int[]{0, 0, 672, 176});  // brain in a vat
        List<int[][]> nametables_phase1 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage_phase1, boss5TilesPath, availableTiles_phase1, collision_phase1, false, false);
        nameTableBoxes.clear();
        nameTableBoxes.add(new int[]{0, 184, 8, 200});  // eye
        nameTableBoxes.add(new int[]{16, 184, 520, 184 + 72});  // suit (banks 1-2) (common)
        nameTableBoxes.add(new int[]{576, 184, 1024, 280});  // lowering brain into suit
        nameTableBoxes.add(new int[]{0, 72, 32, 96});  // teleporter
        List<int[][]> nametables_phase1b_12 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage_phase1b_12, boss5TilesPath, availableTiles_phase1b_12, collision_phase1b_12, false, false);
        nameTableBoxes.clear();
        nameTableBoxes.add(new int[]{0, 184, 520, 184 + 72});  // suit (banks 1-2) (common)
        nameTableBoxes.add(new int[]{0, 312, 520, 312 + 72});  // suit (banks 1-2) (left arm)
        nameTableBoxes.add(new int[]{0, 72, 32, 96});  // teleporter
        List<int[][]> nametables_phase2_12a = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage_phase2_12a, boss5TilesPath, availableTiles_phase2_12a, collision_phase2_12a, false, false);
        nameTableBoxes.clear();
        nameTableBoxes.add(new int[]{0, 184, 520, 184 + 72});  // suit (banks 1-2) (common)
        nameTableBoxes.add(new int[]{0, 400, 520, 400 + 72});  // suit (banks 1-2) (right arm)
        nameTableBoxes.add(new int[]{0, 72, 32, 96});  // teleporter
        List<int[][]> nametables_phase2_12b = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage_phase2_12b, boss5TilesPath, availableTiles_phase2_12b, collision_phase2_12b, false, false);
        nameTableBoxes.clear();
        nameTableBoxes.add(new int[]{0, 184 + 72, 520, 312});  // suit (banks 3)
        nameTableBoxes.add(new int[]{0, 312 + 72, 520, 400});  // suit (banks 3)
        nameTableBoxes.add(new int[]{0, 400 + 72, 520, 488});  // suit (banks 3)
        List<int[][]> nametables_phase2_3 = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage_phase2_3, boss5TilesPath, availableTiles_phase2_3, collision_phase2_3, false, false);

        // Reorganize tiles so that shareed tiles appear in the same locations:
        // baseImage_phase1 -> baseImage_phase1b_12
        // baseImage_phase1 -> baseImage_phase2_3
        // baseImage_phase1b_12 -> baseImage_phase2_12a
        // baseImage_phase2_12a -> baseImage_phase2_12b
        reorganizeTilesForBankTransition(baseImage_phase1, baseImage_phase1b_12, nametables_phase1, nametables_phase1b_12);
        reorganizeTilesForBankTransition(baseImage_phase1, baseImage_phase2_3, nametables_phase1, nametables_phase2_3);
        reorganizeTilesForBankTransition(baseImage_phase1b_12, baseImage_phase2_12a, nametables_phase1b_12, nametables_phase2_12a);
        reorganizeTilesForBankTransition(baseImage_phase2_12a, baseImage_phase2_12b, nametables_phase2_12a, nametables_phase2_12b);
        
        ImageIO.write(baseImage_phase1, "png", new File("data/boss8-phase1-tiles.png"));
        GenerateTiles.extractTiles("data/boss8-phase1-tiles.png", "src/autogenerated/boss8-phase1-tiles", 24, 128);
        ImageIO.write(baseImage_phase1b_12, "png", new File("data/boss8-phase1b-12-tiles.png"));
        GenerateTiles.extractTiles("data/boss8-phase1b-12-tiles.png", "src/autogenerated/boss8-phase1b-12-tiles", 24, 128);
        ImageIO.write(baseImage_phase2_12a, "png", new File("data/boss8-phase2-bank1-tiles.png"));
        GenerateTiles.extractTiles("data/boss8-phase2-bank1-tiles.png", "src/autogenerated/boss8-phase2-bank1-tiles", 24, 128);
        ImageIO.write(baseImage_phase2_12b, "png", new File("data/boss8-phase2-bank1b-tiles.png"));
        GenerateTiles.extractTiles("data/boss8-phase2-bank1b-tiles.png", "src/autogenerated/boss8-phase2-bank1b-tiles", 24, 128);
        ImageIO.write(baseImage_phase2_3, "png", new File("data/boss8-phase2-bank3-tiles.png"));
        GenerateTiles.extractTiles("data/boss8-phase2-bank3-tiles.png", "src/autogenerated/boss8-phase2-bank3-tiles", 24, 128);        
        
        int nameTable[][] = nametables_phase1.get(0);
        addNameTable(nameTable, 0, 9, 4, 12, nameTableData);  // teleporter
        addNameTable(nameTable, 4, 8, 14, 22, nameTableData);  // brain in the vat

        addNameTable(nameTable, 0, 12, 1, 14, nameTableData);  // eye open
        addNameTable(nameTable, 1, 12, 2, 14, nameTableData);  // eye closing
        addNameTable(nameTable, 2, 12, 3, 14, nameTableData);  // eye closed
        addNameTable(nameTable, 3, 12, 4, 14, nameTableData);  // eye down
        addNameTable(nameTable, 0, 14, 1, 16, nameTableData);  // eye up

        addNameTable(nameTable, 16, 7, 22, 19, nameTableData);  // lifting brain from bat (6x12)
        addNameTable(nameTable, 26, 6, 32, 18, nameTableData);  // (6x12)
        addNameTable(nameTable, 36, 5, 42, 17, nameTableData);  // (6x12)
        addNameTable(nameTable, 46, 4, 52, 16, nameTableData);  // (6x12)
        addNameTable(nameTable, 56, 3, 62, 15, nameTableData);  // (6x12)
        addNameTable(nameTable, 66, 2, 72, 14, nameTableData);  // (6x12)
        addNameTable(nameTable, 76, 1, 82, 13, nameTableData);  // (6x12)
        addNameTable(nameTable, 76, 1, 82, 12, nameTableData);  // (6x11) [this and the one below form a single frame]
        addNameTable(nameTable, 76, 0, 82, 1, nameTableData);  // (6x1)

        addNameTable(nameTable, 76, 0, 80, 1, nameTableData);  // (4x1) (4 additional empty tiles to make a full row of emptiness for the frame below)
        addNameTable(nameTable, 74, 12, 84, 22, nameTableData);  // empty vat (10x10)

        nameTable = nametables_phase1b_12.get(2);
        addNameTable(nameTable, 1, 0, 7, 12, nameTableData);  // lowering brain into suit (6x12)
        addNameTable(nameTable, 7, 1, 13, 12, nameTableData);  // lowering brain into suit (6x11)
        addNameTable(nameTable, 13, 2, 19, 12, nameTableData);  // lowering brain into suit (6x10)
        addNameTable(nameTable, 19, 3, 25, 12, nameTableData);  // lowering brain into suit (6x9)
        addNameTable(nameTable, 25, 4, 31, 12, nameTableData);  // lowering brain into suit (6x8)
        addNameTable(nameTable, 31, 5, 37, 12, nameTableData);  // lowering brain into suit (6x7)
        addNameTable(nameTable, 37, 5, 43, 12, nameTableData);  // lowering brain into suit (6x7)
        addNameTable(nameTable, 43, 4, 49, 12, nameTableData);  // lowering brain into suit (6x8)

        addNameTable(nameTable, 43, 4, 49, 10, nameTableData);  // lowering brain into suit (6x6)
        addNameTable(nameTable, 43, 0, 49, 1, nameTableData);  // (just an empty row)
        
        // Suit:
        // eyes:
        nameTable = nametables_phase1b_12.get(0);
        addNameTable(nameTable, 0, 0, 1, 2, nameTableData);  // eye open
        nameTable = nametables_phase2_12a.get(0);
        addNameTable(nameTable, 1, 0, 2, 2, nameTableData);  // eye closing
        addNameTable(nameTable, 0, 2, 1, 4, nameTableData);  // eye closed
        addNameTable(nameTable, 1, 2, 2, 4, nameTableData);  // eye down
        addNameTable(nameTable, 0, 4, 1, 6, nameTableData);  // eye up
        // core:
        addNameTable(nametables_phase1b_12.get(1), 0, 0, 8, 8, nameTableData);
        // legs:
        addNameTable(nametables_phase1b_12.get(1), 8, 8, 17, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 10, 0, 19, 7, nameTableData);  // frame 1 (9x8) [two parts]
        addNameTable(nametables_phase1b_12.get(1), 17, 8, 25, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 19, 0, 27, 7, nameTableData);  // frame 2 (8x8) [two parts]
        addNameTable(nametables_phase1b_12.get(1), 25, 8, 31, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 27, 0, 33, 7, nameTableData);  // frame 3 (6x8) [two parts]
        addNameTable(nametables_phase1b_12.get(1), 32, 8, 38, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 34, 0, 40, 7, nameTableData);  // frame 4 (6x8) [two parts]
        addNameTable(nametables_phase1b_12.get(1), 38, 8, 44, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 40, 0, 46, 7, nameTableData);  // frame 5 (6x8) [two parts]
        addNameTable(nametables_phase1b_12.get(1), 44, 8, 53, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 46, 0, 55, 7, nameTableData);  // frame 6 (9x8) [two parts]        
        // left arm:
        addNameTable(nametables_phase1b_12.get(1), 53, 0, 59, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 55, 0, 61, 2, nameTableData);  // base position (6x11) [two parts]        
        // ...
        // right arm:
        addNameTable(nametables_phase1b_12.get(1), 59, 0, 63, 9, nameTableData);
        addNameTable(nametables_phase2_3.get(0), 61, 0, 65, 2, nameTableData);  // base position (4x11) [two parts]        
        // ...
        
        
        System.out.println("name tables: " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss8-nametables.bin");
    }

    
    public static void boss8Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet

        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 128, 15));  // boss name (1)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 128, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 144, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 144, 15));

        // aliens (5):
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 212, 2));  // idle
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 216, 13));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 212, 2));  // walking
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 216, 13));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 212, 2));  // mouth open
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 216, 13));

        // turrents (11):
        data.addAll(GenerateSprites.extractSprite(sourceImage, 144, 208, 15));  // turret appearing 1
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 208, 15));  // turret appearing 2
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 208, 15));  // turret appearing 3
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 192, 15));  // turret left (14)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 192, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 192, 15));  // turret left-down (16)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 192, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 192, 15));  // turret down (18)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 144, 192, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 208, 15));  // turret right-down (20)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 208, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 208, 15));  // right (22)
        
        // plasma vall (23)
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 224, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 224, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 112, 224, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 128, 224, 15));
        
        System.out.println("boss8Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss8-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }
    
    
    public static void reorganizeTilesForBankTransition(
            BufferedImage tileset1,
            BufferedImage tileset2,
            List<int[][]> nametables1,
            List<int[][]> nametables2) throws Exception {
        for(int i = 0;i<256;i++) {
            List<Integer> tile1 = getTile(tileset1, (i%16) * 8, (i/16) * 8);
            boolean isEmpty = true;
            for(Integer v: tile1) {
                if (!v.equals(0)) {
                    isEmpty = false;
                    break;
                }
            }
            if (isEmpty) continue;
            for(int j = 0;j<256;j++) {
                if (i == j) continue;
                List<Integer> tile2 = getTile(tileset2, (j%16) * 8, (j/16) * 8);
                boolean match = true;
                for(int k = 0;k<8*8;k++) {
                    if (!tile1.get(k).equals(tile2.get(k))) {
                        match = false;
                        break;
                    }
                }
                if (match) {
                    // tiles match, swap them in tileset2:
                    List<Integer> tile2b = getTile(tileset2, (i%16) * 8, (i/16) * 8);
                    // - draw tile2 to position i
                    for(int ii = 0;ii<8;ii++) {
                        for(int jj = 0;jj<8;jj++) {
                            tileset2.setRGB((i%16) * 8 + jj, (i/16) * 8 + ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2.get(jj+ii*8)));
                        }
                    }
                    // - draw tile2b to position j
                    for(int ii = 0;ii<8;ii++) {
                        for(int jj = 0;jj<8;jj++) {
                            tileset2.setRGB((j%16) * 8 + jj, (j/16) * 8 + ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2b.get(jj+ii*8)));
                        }
                    }
                    
                    // swap tile ids in nametables:
                    for(int nametable[][]: nametables2) {
                        for(int ii = 0;ii<nametable.length;ii++) {
                            for(int jj = 0;jj<nametable[ii].length;jj++) {
                                if (nametable[ii][jj] == i) {
                                    nametable[ii][jj] = j;
                                } else if (nametable[ii][jj] == j) {
                                    nametable[ii][jj] = i;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public static List<Integer> getTile(BufferedImage sourceImage, int j, int i) throws Exception
    {
        List<Integer> tile = new ArrayList<>();
        for(int ii = 0;ii<8;ii++) {
            for(int jj = 0;jj<8;jj++) {
                int color = ConvertPatternsToAssembler.findMSXColor(j+jj, i+ii, sourceImage, 0);
                if (color == -1) throw new Exception("Unknown color at " + (j+jj) + ", " + (i+ii));
                tile.add(color);
            }
        }
        return tile;
    }
    
    
    public static void addNameTable(int nameTable[][], int x1, int y1, int x2, int y2, List<Integer> data)
    {
        for(int i = y1;i<y2;i++) {
            for(int j = x1; j<x2; j++) {
                data.add(nameTable[j][i]);
            }
        }
    }


    public static void addFlippedNameTable(int nameTable[][], int x1, int y1, int x2, int y2, List<Integer> data)
    {
        for(int i = y1;i<y2;i++) {
            for(int j = x2 - 1; j>=x1; j--) {
                data.add(nameTable[j][i]);
            }
        }
    }
    
    
    public static boolean tileIsEmpty(int j, int i, BufferedImage img) throws Exception
    {
        List<Integer> attributes = ConvertPatternsToAssembler.generateAssemblerPatternAttributes(j, i, img, 0);
        for(int v:attributes) {
            if (v != 0) return false;
        }
        return true;
    }
    
    
    public static void findAvailableBossTiles(String bossBaseTiles, boolean availableTiles[], int collision[], int base_collision[], boolean print) throws Exception
    {
        BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        
        int n_availableTiles = 0;
        if (print) System.out.println("Collision table:");
        for(int i = 0;i<16;i++) {
            String line = "    db ";
            for(int j = 0;j<16;j++) {
                boolean empty = tileIsEmpty(j, i, baseImage);
                if (i<3) empty = false;  // protect the top 3 rows
                availableTiles[j + i*16] = empty;
                if (empty) {
                    n_availableTiles++;
                    collision[j + i*16] = 9;
                } else {
                    collision[j + i*16] = base_collision[j + i*16];
                }
                line += collision[j + i*16] + ", ";
            }
            if (print) System.out.println(line.substring(0, line.length() - 2));
        }
        System.out.println("boss: available tiles " + n_availableTiles);
    }


    public static int[][] addBossTilesInGaps(BufferedImage baseImage, String bossTiles, boolean availableTiles[], int collision[], boolean flipTiles) throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File(bossTiles));
        List<int[]> nameTableBoxes = new ArrayList<>();
        nameTableBoxes.add(new int[]{0, 0, sourceImage.getWidth(), sourceImage.getHeight()});
        List<int[][]> nameTables = addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, bossTiles, availableTiles, collision, flipTiles, false);
        return nameTables.get(0);
    }   
    
    
    public static List<int[][]> addBossTilesInGapsForBoxes(List<int[]> nameTableBoxes, BufferedImage baseImage, String bossTiles, boolean availableTiles[], int collision[], boolean flipTiles, boolean addLastBBoxStartingFromTheEnd) throws Exception
    {
        // Extract all tiles from the boss file and add in the gaps:
        BufferedImage sourceImage = ImageIO.read(new File(bossTiles));
        List<List<Integer>> tiles = new ArrayList<>();
        List<Integer> tile = new ArrayList<>();
        List<int[][]> nameTables = new ArrayList<>();
        int firstTileToAddAtTheEnd = 1;
        for(int i = 0;i<8*8;i++) tile.add(0);
        tiles.add(tile);
        for(int bbox_idx = 0;bbox_idx<nameTableBoxes.size();bbox_idx++) {
            int box[] = nameTableBoxes.get(bbox_idx);
            int nameTable[][] = new int[(box[2] - box[0])/8][(box[3] - box[1])/8];
            for(int i = box[1];i<box[3];i+=8) {
                for(int j = box[0];j<box[2];j+=8) {
                    tile = new ArrayList<>();
                    for(int ii = 0;ii<8;ii++) {
                        for(int jj = 0;jj<8;jj++) {
                            int color = ConvertPatternsToAssembler.findMSXColor(j+jj, i+ii, sourceImage, 0);
                            if (color == -1) throw new Exception("Unknown color at " + (j+jj) + ", " + (i+ii));
                            tile.add(color);
                        }
                    }
                    
                    int found = -1;
                    for(int tileIndex = 0;tileIndex<tiles.size();tileIndex++) {
                        List<Integer> tile2 = tiles.get(tileIndex);
                        if (tilesMatch(tile, tile2)) {
                            found = tileIndex;
                            break;
                        }
                    }
                    if (found == -1) {
                        nameTable[(j - box[0])/8][(i - box[1])/8] = tiles.size();
                        tiles.add(tile);
                    } else {
                        nameTable[(j - box[0])/8][(i - box[1])/8] = found;
                    }                    
                }
            }
            nameTables.add(nameTable);
            if (bbox_idx == nameTableBoxes.size() - 2) {
                firstTileToAddAtTheEnd = tiles.size();
            }
        }
        System.out.println("number of tiles of the boss: " + tiles.size());            
//            for(int i = 0;i<nameTable[0].length;i++) {
//                for(int j = 0;j<nameTable.length;j++) {
//                    System.out.print(nameTable[j][i] + ", ");
//                }
//                System.out.println("");
//            }

        // Add all the new tiles:
        HashMap<Integer, Integer> map = new HashMap<>();
        map.put(0, 0);
        if (addLastBBoxStartingFromTheEnd) {
            List<Integer> tiles_beginning = new ArrayList<>();
            List<Integer> tiles_end = new ArrayList<>();
            for(int i = 0;i<tiles.size();i++) {
                if (i < firstTileToAddAtTheEnd) {
                    tiles_beginning.add(i);
                } else {
                    tiles_end.add(i);
                }
            }
            System.out.println("total tiles: " + tiles.size() + ", beginning: " + tiles_beginning.size() + ", end: " + tiles_end.size());
            addTilesInGapsInternal(tiles, tiles_beginning, map, baseImage, availableTiles, flipTiles, 0, false);
            addTilesInGapsInternal(tiles, tiles_end, map, baseImage, availableTiles, flipTiles, 0, true);
        } else {
            addTilesInGapsInternal(tiles, null, map, baseImage, availableTiles, flipTiles, 0, false);
        }

        // Generate the name tables:
        for(int[][] nameTable:nameTables) {
            for(int i = 0;i<nameTable[0].length;i++) {
                for(int j = 0;j<nameTable.length;j++) {
                    nameTable[j][i] = map.get(nameTable[j][i]);
                }
            }
        }
        
        return nameTables;
    }
    
    
    public static boolean tilesMatch(List<Integer> tile, List<Integer> tile2)
    {
        for(int k = 0;k<8*8;k++) {
            if (!tile.get(k).equals(tile2.get(k))) {
                return false;
            }
        }        
        return true;
    }
    
    
    public static void addTilesInGapsInternal(List<List<Integer>> tiles, List<Integer> tileIndexesToAdd, HashMap<Integer, Integer> map, BufferedImage baseImage, boolean availableTiles[], boolean flipTiles, int firstUseableGap, boolean addAtTheEnd) throws Exception
    {
        if (tileIndexesToAdd == null) {
            // Add them all:
            tileIndexesToAdd = new ArrayList<>();
            for(int i = 1;i<tiles.size();i++) {
                tileIndexesToAdd.add(i);
            }
        }

        int indexOfFirstUseableGap = 0;
        for(int i = 0;i<16;i++) {
            for(int j = 0;j<16;j++) {
                if (firstUseableGap <= 0) break;
                if (availableTiles[j+i*16]) {
                    firstUseableGap--;
                }
                indexOfFirstUseableGap++;
            }
            if (firstUseableGap <= 0) break;
        }
        
        for(int tileID:tileIndexesToAdd) {
            List<Integer> tile2 = tiles.get(tileID);
            if (!flipTiles) {
                // first check if the tile already exists:
//                System.out.println("Checking if " + tileID + " is already there...");
                boolean alreadyThere = false;
                for(int i = 0;i<16;i++) {
                    for(int j = 0;j<16;j++) {
                        List<Integer> tile = new ArrayList<>();
                        for(int ii = 0;ii<8;ii++) {
                            for(int jj = 0;jj<8;jj++) {
                                int color = ConvertPatternsToAssembler.findMSXColor(j*8+jj, i*8+ii, baseImage, 0);
                                if (color == -1) throw new Exception("Unknown color at " + (j*8+jj) + ", " + (i*8+ii));
                                tile.add(color);
                            }
                        }
                        if (tilesMatch(tile, tile2)) {
                            map.put(tileID, j + i*16);
    //                        System.out.println("    already there!!!!");
                            alreadyThere = true;
                            break;
                        }
                    }
                    if (alreadyThere) break;
                }
                if (alreadyThere) continue;
            }
            int found = -1;
            for(int i = 3;i<16;i++) {
                for(int j = 0;j<16;j++) {
                    if (availableTiles[j+i*16]) {
                        if (j+i*16 < indexOfFirstUseableGap) continue;
                        found = j+i*16;
                        if (!addAtTheEnd) {
                            for(int ii = 0;ii<8;ii++) {
                                for(int jj = 0;jj<8;jj++) {
                                    if (flipTiles) {
                                        baseImage.setRGB(j*8+(7 - jj), i*8+ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2.get(jj+ii*8)));
                                    } else {
                                        baseImage.setRGB(j*8+jj, i*8+ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2.get(jj+ii*8)));
                                    }
                                }
                            }
                            availableTiles[j+i*16] = false;
                            map.put(tileID, j + i*16);
                            break;
                        }
                    }
                }
                if (found != -1 && !addAtTheEnd) break;
            }
            if (found == -1) throw new Exception("Cannot find a gap for tile " + tileIndexesToAdd.indexOf(tileID) + " / " + tileIndexesToAdd.size()); 
            if (addAtTheEnd) {
                int i = found / 16;
                int j = found % 16;
                for(int ii = 0;ii<8;ii++) {
                    for(int jj = 0;jj<8;jj++) {
                        if (flipTiles) {
                            baseImage.setRGB(j*8+(7 - jj), i*8+ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2.get(jj+ii*8)));
                        } else {
                            baseImage.setRGB(j*8+jj, i*8+ii, ConvertPatternsToAssembler.MSXColorToRGB(tile2.get(jj+ii*8)));
                        }
                    }
                }
                availableTiles[found] = false;
                map.put(tileID, found);
            }
        }        
    }
}
