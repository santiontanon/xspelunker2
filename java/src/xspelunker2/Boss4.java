/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package xspelunker2;

import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
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
public class Boss4 {
    public static void main(String args[]) throws Exception
    {
        boss4Tiles();
        boss4Sprites();
    }

    
    public static void boss4Tiles() throws Exception
    {
        List<List<Integer>> tiles = new ArrayList<>();
        List<Integer> tile = new ArrayList<>();
        for(int i = 0;i<8*8;i++) tile.add(0);
        tiles.add(tile);
     
        // Get the name tables for all the parts and lords:
        int [][]nameTableMouth = getTilesFromImageRectangle("data/boss4.png", 96, 0, 192, 24, tiles);
        System.out.println("number of tiles ater misc: " + tiles.size());  
        int n_mouth_tiles = tiles.size() - 1;
        getTilesFromImageRectangle("data/boss4.png", 0, 0, 96, 24, tiles);
        System.out.println("number of tiles ater rise: " + tiles.size());  
        int n_rise_tiles = (tiles.size() - 1) - n_mouth_tiles;
        int [][]nameTableLord1 = getTilesFromImageRectangle("data/boss4.png", 0, 24, 408, 96, tiles);
        System.out.println("number of tiles after lord 1: " + tiles.size());  
        int [][]nameTableLord2 = getTilesFromImageRectangle("data/boss4.png", 0, 96, 408, 168, tiles);
        System.out.println("number of tiles after lord 2: " + tiles.size());  
        int [][]nameTableLord3 = getTilesFromImageRectangle("data/boss4.png", 0, 168, 408, 232, tiles);
        System.out.println("number of tiles after lord 3: " + tiles.size());  
        int [][]nameTableLord4 = getTilesFromImageRectangle("data/boss4.png", 0, 232, 408, 296, tiles);
        System.out.println("number of tiles after lord 4: " + tiles.size());  
        int [][]nameTableLord5 = getTilesFromImageRectangle("data/boss4.png", 0, 296, 408, 360, tiles);
        System.out.println("number of tiles after lord 5: " + tiles.size());  
        int [][]nameTableLord6 = getTilesFromImageRectangle("data/boss4.png", 0, 360, 408, 424, tiles);
        System.out.println("number of tiles after lord 6: " + tiles.size());  
        int [][]nameTableLord7 = getTilesFromImageRectangle("data/boss4.png", 0, 424, 408, 480, tiles);
        System.out.println("number of tiles after lord 7: " + tiles.size());  
        int [][]nameTableLord8 = getTilesFromImageRectangle("data/boss4.png", 0, 480, 408, 544, tiles);
        System.out.println("number of tiles after lord 8: " + tiles.size());  
        int [][]nameTableLord9 = getTilesFromImageRectangle("data/boss4.png", 0, 544, 408, 608, tiles);
        System.out.println("number of tiles after lord 9: " + tiles.size());  
        int [][]nameTableLord10 = getTilesFromImageRectangle("data/boss4.png", 0, 608, 408, 672, tiles);
        System.out.println("number of tiles after lord 10: " + tiles.size());  
        int [][]nameTableLord11 = getTilesFromImageRectangle("data/boss4.png", 0, 672, 408, 728, tiles);
        System.out.println("number of tiles after lord 11: " + tiles.size());  
        int [][]nameTableLord12 = getTilesFromImageRectangle("data/boss4.png", 0, 728, 408, 784, tiles);
        System.out.println("number of tiles after lord 12: " + tiles.size()); 
        
        // Identify the pieces that are shared across at least 6 lords, this will form the "core tiles":
        List<int[][]> lordNameTables = new ArrayList<>();
        lordNameTables.add(nameTableLord1);
        lordNameTables.add(nameTableLord2);
        lordNameTables.add(nameTableLord3);
        lordNameTables.add(nameTableLord4);
        lordNameTables.add(nameTableLord5);
        lordNameTables.add(nameTableLord6);
        lordNameTables.add(nameTableLord7);
        lordNameTables.add(nameTableLord8);
        lordNameTables.add(nameTableLord9);
        lordNameTables.add(nameTableLord10);
        lordNameTables.add(nameTableLord11);
        lordNameTables.add(nameTableLord12);
        
        HashMap<Integer, Integer> tileCounts = new HashMap<>();
        for(int [][]nametable: lordNameTables) {
            for(int i = 1;i<tiles.size();i++) {
                if (tileAppearsInNameTable(i, nametable)) {
                    if (!tileCounts.containsKey(i)) {
                        tileCounts.put(i, 0);
                    }
                    tileCounts.put(i, tileCounts.get(i) + 1);
                }
            }
        }
        
        // Tile appearance profile:
        for(int i = 0;i<=lordNameTables.size();i++) {
            int n = 0;
            for(int j = 0;j<tiles.size();j++) {
                if (tileCounts.containsKey(j) && tileCounts.get(j).equals(i)) {
                    n++;
                }
            }
            System.out.println("" + n + " tiles appear in " + i + " nametables");
        }
        
        
        // Construct the individual tile sets:
        int minimum_n_to_be_in_base_tiles = 6;
        List<Integer> base_tiles = new ArrayList<>();
        System.out.println("Tileset 'rise': " + n_rise_tiles);
        
        // Creating base tileset:
        for(int i = 1;i<tiles.size();i++) {
            if (tileAppearsInNameTable(i, nameTableMouth) ||
                tileCounts.containsKey(i) && tileCounts.get(i) >= minimum_n_to_be_in_base_tiles) {
                if (!base_tiles.contains(i)) {
                    base_tiles.add(i);
                }
            }
        }
        System.out.println("Tileset 'base': " + base_tiles.size());
        List<List<Integer>> lords_tiles = new ArrayList<>();
        List<Integer> lord_tiles_sizes = new ArrayList<>();
        for(int i = 0;i<lordNameTables.size();i++) {
            List<Integer> lord_tiles = new ArrayList<>();
            for(int j = 1;j<tiles.size();j++) {
                if (base_tiles.contains(j)) continue;
                if (tileAppearsInNameTable(j, lordNameTables.get(i))) {
                    lord_tiles.add(j);
                }
            }
            lords_tiles.add(lord_tiles);
            System.out.println("Tileset 'lord "+(i+1)+"': " + lord_tiles.size());
            lord_tiles_sizes.add(lord_tiles.size());
        }
        Collections.sort(lord_tiles_sizes);
        int max_pair_size = lord_tiles_sizes.get(10) + lord_tiles_sizes.get(11);
        System.out.println("Max combined size of two lords: " + max_pair_size);
        
        // "common":
        // - generate tileset (starting at 'max_pair_size')
        {
            System.out.println("Number of tiles in 'base_tiles' = " + base_tiles.size());
            BufferedImage baseImage = ImageIO.read(new File("data/boss4-tiles-base.png"));
            boolean availableTiles[] = new boolean[256];
            int collision[] = new int[256];
            Bosses.findAvailableBossTiles("data/boss4-tiles-base.png", availableTiles, collision, Bosses.xibalba_collision, true);
            HashMap<Integer, Integer> map = new HashMap<>();
            map.put(0, 0);
            Bosses.addTilesInGapsInternal(tiles, base_tiles, map, baseImage, availableTiles, false, max_pair_size);
            ImageIO.write(baseImage, "png", new File("data/boss4-common-tiles.png"));
            GenerateTiles.extractTiles("data/boss4-common-tiles.png", "src/autogenerated/boss4-common-tiles", 24, 128);
        }
                
        // Create the actual tilesets:
        // "rise":
        {
            List<int[]> boxes = new ArrayList<>();
            boxes.add(new int[]{0, 0, 8, 8});  // hand sticking out frames (right)
            boxes.add(new int[]{0, 0, 8, 16});
            boxes.add(new int[]{0, 0, 8, 24});
            boxes.add(new int[]{88, 0, 96, 8});  // hand sticking out frames (left)
            boxes.add(new int[]{88, 0, 96, 16});
            boxes.add(new int[]{88, 0, 96, 24});
            boxes.add(new int[]{8, 0, 32, 8});  // right hand
            boxes.add(new int[]{8, 8, 32, 16});  // left hand
            boxes.add(new int[]{64, 16, 80, 24});  // left hand retracting
            boxes.add(new int[]{16, 16, 32, 24});  // right hand retracting
            boss4Tiles(boxes, "data/boss4-common-tiles.png", "rise");
            saveBoss4TilesAsPatch("data/boss4-rise-tiles.png", "src/autogenerated/boss4-rise-tiles");
        }
        
        // "individual lords":
        // - generate tileset (just the new tiles that will be patched-in)
        // - add individual lord at the beginning, and then the base one starting at 'max_pair_size'
        // - generate name tables
        for(int i = 0;i<lords_tiles.size();i++) {
            List<int[]> boxes = new ArrayList<>();
            switch(i) {
                case 0:  // hun-came
                    boxes.add(new int[]{0, 24, 40, 96});  // idle
                    boxes.add(new int[]{40, 24, 80, 96});
                    boxes.add(new int[]{80, 24, 136, 96});  // point-up
                    boxes.add(new int[]{136, 24, 184, 96});
                    boxes.add(new int[]{184, 24, 224, 96});  // point-forward
                    boxes.add(new int[]{224, 24, 280, 96});
                    boxes.add(new int[]{280, 24, 344, 96});  // hands-open
                    boxes.add(new int[]{344, 24, 408, 96});
                    
                    boxes.add(new int[]{96, 8, 120, 16});  // mouth closed (here, but shared with all other lords)
                    boxes.add(new int[]{120, 8, 144, 16});  
                    break;
                case 1:  // vucub-came
                    boxes.add(new int[]{0, 96, 40, 168});  // idle
                    boxes.add(new int[]{40, 96, 80, 168});
                    boxes.add(new int[]{80, 96, 136, 168});  // point-up
                    boxes.add(new int[]{136, 96, 184, 168});
                    boxes.add(new int[]{184, 96, 224, 168});  // point-forward
                    boxes.add(new int[]{224, 96, 280, 168});
                    boxes.add(new int[]{280, 96, 344, 168});  // hands-open
                    boxes.add(new int[]{344, 96, 408, 168});
                    break;
                case 2:  // Xiquiripat
                    boxes.add(new int[]{0, 168, 32, 232});  // idle
                    boxes.add(new int[]{32, 168, 64, 232});
                    boxes.add(new int[]{64, 168, 112, 232});  // point-up
                    boxes.add(new int[]{112, 168, 160, 232});
                    boxes.add(new int[]{160, 168, 192, 232});  // point-forward
                    boxes.add(new int[]{192, 168, 248, 232});
                    boxes.add(new int[]{248, 168, 312, 232});  // hands-open
                    boxes.add(new int[]{312, 168, 376, 232});
                    break;
                case 3:  // Cuchumaquic
                    boxes.add(new int[]{0, 232, 32, 296});  // idle
                    boxes.add(new int[]{32, 232, 64, 296});
                    boxes.add(new int[]{64, 232, 112, 296});  // point-up
                    boxes.add(new int[]{112, 232, 160, 296});
                    boxes.add(new int[]{160, 232, 192, 296});  // point-forward
                    boxes.add(new int[]{192, 232, 248, 296});
                    boxes.add(new int[]{248, 232, 312, 296});  // hands-open
                    boxes.add(new int[]{312, 232, 376, 296});
                    break;
                case 4:  // Chamiabac
                    boxes.add(new int[]{0, 304, 48, 360});  // idle
                    boxes.add(new int[]{48, 304, 96, 360});
                    boxes.add(new int[]{96, 296, 144, 360});  // utensil up
                    boxes.add(new int[]{144, 296, 192, 360});
                    boxes.add(new int[]{192, 304, 256, 360});  // hands-open
                    boxes.add(new int[]{256, 304, 320, 360});
                    break;
                case 5:  // Chamiaholom
                    boxes.add(new int[]{0, 368, 48, 424});  // idle
                    boxes.add(new int[]{48, 368, 96, 424});
                    boxes.add(new int[]{96, 360, 144, 424});  // utensil up
                    boxes.add(new int[]{144, 360, 192, 424});
                    boxes.add(new int[]{192, 368, 256, 424});  // hands-open
                    boxes.add(new int[]{256, 368, 320, 424});
                    break;
                case 6:  // Ahalgana
                    boxes.add(new int[]{0, 424, 32, 480});  // idle
                    boxes.add(new int[]{32, 424, 64, 480});
                    boxes.add(new int[]{64, 424, 112, 480});  // point-up
                    boxes.add(new int[]{112, 424, 160, 480});
                    boxes.add(new int[]{160, 424, 192, 480});  // point-forward
                    boxes.add(new int[]{192, 424, 248, 480});
                    boxes.add(new int[]{248, 424, 312, 480});  // hands-open
                    boxes.add(new int[]{312, 424, 376, 480});                    
                    break;
                case 7:  // Ahalpuh
                    boxes.add(new int[]{0, 480, 32, 544});  // idle
                    boxes.add(new int[]{32, 480, 64, 544});
                    boxes.add(new int[]{64, 480, 112, 544});  // point-up
                    boxes.add(new int[]{112, 480, 160, 544});
                    boxes.add(new int[]{160, 480, 192, 544});  // point-forward
                    boxes.add(new int[]{192, 480, 248, 544});
                    boxes.add(new int[]{248, 480, 312, 544});  // hands-open
                    boxes.add(new int[]{312, 480, 376, 544});                    
                    break;
                case 8:  // Ahalmez
                    boxes.add(new int[]{0, 552, 48, 608});  // idle
                    boxes.add(new int[]{48, 552, 96, 608});
                    boxes.add(new int[]{96, 544, 144, 608});  // utensil up
                    boxes.add(new int[]{144, 544, 192, 608});
                    boxes.add(new int[]{192, 552, 256, 608});  // hands-open
                    boxes.add(new int[]{256, 552, 320, 608});
                    break;
                case 9:  // Ahaltocob
                    boxes.add(new int[]{0, 616, 48, 672});  // idle
                    boxes.add(new int[]{48, 616, 96, 672});
                    boxes.add(new int[]{96, 608, 144, 672});  // utensil up
                    boxes.add(new int[]{144, 608, 192, 672});
                    boxes.add(new int[]{192, 616, 256, 672});  // hands-open
                    boxes.add(new int[]{256, 616, 320, 672});
                    break;
                case 10:  // Quicxic
                    boxes.add(new int[]{0, 672, 56, 728});  // idle
                    boxes.add(new int[]{56, 672, 112, 728});
                    boxes.add(new int[]{112, 672, 168, 728});  // utensil up
                    boxes.add(new int[]{168, 672, 224, 728});
                    boxes.add(new int[]{224, 672, 296, 728});  // hands-open
                    boxes.add(new int[]{296, 672, 368, 728});
                    break;
                case 11:  // Patan
                    boxes.add(new int[]{0, 728, 32, 784});  // idle
                    boxes.add(new int[]{32, 728, 64, 784});
                    boxes.add(new int[]{64, 728, 112, 784});  // point-up
                    boxes.add(new int[]{112, 728, 160, 784});
                    boxes.add(new int[]{160, 728, 192, 784});  // point-forward
                    boxes.add(new int[]{192, 728, 248, 784});
                    boxes.add(new int[]{248, 728, 312, 784});  // hands-open
                    boxes.add(new int[]{312, 728, 376, 784});  

                    boxes.add(new int[]{376, 736, 400, 744});  // mouth closed
                    boxes.add(new int[]{376, 752, 400, 760});  
                    break;
            }
            boss4Tiles(boxes, "data/boss4-common-tiles.png", "lord" + (i + 1));
            saveBoss4TilesAsPatch("data/boss4-lord"+(i+1)+"-tiles.png", "src/autogenerated/boss4-lord"+(i+1)+"-tiles");
        }
    }
    
    
    public static void saveBoss4TilesAsPatch(String baseFilePath, String outputPath) throws Exception
    {
        BufferedImage baseImage = ImageIO.read(new File(baseFilePath));
        boolean isEmpty = true;
        
        List<Integer> bitmap_data = new ArrayList<>();
        List<Integer> color_data = new ArrayList<>();
        
        for(int i = 3;i<16;i++) {
            for(int j = 0;j<16;j++) {
                isEmpty = true;
                List<Integer> pattern = ConvertPatternsToAssembler.generateAssemblerPatternBitmap(j, i, baseImage, 0);
                List<Integer> attributes = ConvertPatternsToAssembler.generateAssemblerPatternAttributes(j, i, baseImage, 0);
                for(Integer a:attributes) {
                    if (a != 0) {
                        isEmpty = false;
                    }
                }
                if (isEmpty) {
                    System.out.println(j + ", " + i + " of " + baseFilePath + " is empty, stopping.");
                    break;
                }
                bitmap_data.addAll(pattern);
                color_data.addAll(attributes);
            }
            if (isEmpty) break;
        }

        List<Integer> data = new ArrayList<>();
        data.addAll(bitmap_data);
        data.addAll(color_data);
        System.out.println("Tile patch for " + outputPath + " has " + color_data.size()/8 + " tiles.");
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath+".bin", outputPath+".zx0", true, false);        
    }
    
    
    public static List<Integer> boss4Tiles(List<int[]> nameTableBoxes, String bossBaseTiles, String name) throws Exception
    {
        List<Integer> nameTableData = new ArrayList<>();
        
        String boss4Tiles = "data/boss4.png";
        boolean availableTiles[] = new boolean[256];
        int collision[] = new int[256];
        Bosses.findAvailableBossTiles(bossBaseTiles, availableTiles, collision, Bosses.xibalba_collision, false);
        BufferedImage baseImage = ImageIO.read(new File(bossBaseTiles));        

        // Add all the new tiles:
        List<int[][]> nameTables = Bosses.addBossTilesInGapsForBoxes(nameTableBoxes, baseImage, boss4Tiles, availableTiles, collision, false);
        for(int nameTable[][]:nameTables) {
            for(int i = 0;i<nameTable[0].length;i++) {
                for(int j = 0;j<nameTable.length;j++) {
                    nameTableData.add(nameTable[j][i]);
                }
            }
        }

        ImageIO.write(baseImage, "png", new File("data/boss4-"+name+"-tiles.png"));
        GenerateTiles.extractTiles("data/boss4-"+name+"-tiles.png", "src/autogenerated/boss4-"+name+"-tiles", 24, 128);

        System.out.println("name tables for '"+name+"': " + nameTableData.size() + " bytes");
        Z80Assembler.dataToBinary(nameTableData, "src/autogenerated/boss4-"+name+"-nametables.bin");        
        return nameTableData;
    }
    
    
    
    public static boolean tileAppearsInNameTable(int tile, int nametable[][]) {
        for(int i = 0;i<nametable.length;i++) {
            for(int j = 0;j<nametable[i].length;j++) {
                if (nametable[i][j] == tile) return true;
            }
        }
        return false;
    }
    
    
    public static int[][] getTilesFromImageRectangle(
            String bossImagePath,
            int x1, int y1, int x2, int y2,
            List<List<Integer>> tiles) throws Exception
    {
        int nameTable[][] = new int[(x2 - x1)/8][(y2-y1)/8];
        BufferedImage sourceImage = ImageIO.read(new File(bossImagePath));        
        
        for(int i = y1;i<y2;i+=8) {
            for(int j = x1;j<x2;j+=8) {
                List<Integer> tile = new ArrayList<>();
                for(int ii = 0;ii<8;ii++) {
                    for(int jj = 0;jj<8;jj++) {
                        int color = util.ConvertPatternsToAssembler.findMSXColor(j+jj, i+ii, sourceImage, 0);
                        if (color == -1) throw new Exception("Unknown color at " + (j+jj) + ", " + (i+ii));
                        tile.add(color);
                    }
                }

                int found = -1;
                for(int tileIndex = 0;tileIndex<tiles.size();tileIndex++) {
                    List<Integer> tile2 = tiles.get(tileIndex);
                    boolean match = true;
                    for(int k = 0;k<8*8;k++) {
                        if (!tile.get(k).equals(tile2.get(k))) {
                            match = false;
                            break;
                        }
                    }
                    if (match) {
                        found = tileIndex;
                        break;
                    }
                }
                if (found == -1) {
                    nameTable[(j - x1)/8][(i - y1)/8] = tiles.size();
                    tiles.add(tile);
                } else {
                    nameTable[(j - x1)/8][(i - y1)/8] = found;
                }                    
            }
        }
        return nameTable;
    }
    
    
    public static void boss4Sprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/boss-sprites.png"));
        BufferedImage enemiesImage = ImageIO.read(new File("data/enemies.png"));
        List<Integer> data = new ArrayList<>();

        // bullet must be the first sprite:
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 0, 15));  // bullet
        
        // sleeping skeleton (1):
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 96, 48, 15));  // sleeping
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 112, 48, 15));  //
        
        // 3
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 112, 15));  // boss name bottom
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 112, 15));

        // 5
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 96, 15));  // eyes
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 96, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 96, 15));
        
        // 8
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 16, 15));  // lightning
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 16, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 16, 15));
        
        // 13
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 112, 15));  // ghost bottom
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 96, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 112, 15));            

        // bats (16):
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 64, 15));  // bat right
        data.addAll(GenerateSprites.extractSprite(sourceImage, 16, 64, 15));
        data.addAll(GenerateSprites.extractSpriteFlipped(sourceImage, 0, 64, 15));  // bat left
        data.addAll(GenerateSprites.extractSpriteFlipped(sourceImage, 16, 64, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 64, 15));  // bat hanging
        // skeletons (21):
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 0, 48, 15));  // right walk
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 16, 48, 15));  // 
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 32, 48, 15));  // right shoot
        data.addAll(GenerateSprites.extractSprite(enemiesImage, 48, 48, 15));  // 
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 0, 48, 15));  // left walk
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 16, 48, 15));  // 
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 32, 48, 15));  // left shoot
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 48, 48, 15));  // 
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 64, 48, 15));  // right idle
        data.addAll(GenerateSprites.extractSpriteFlipped(enemiesImage, 64, 48, 15));  // left idle
        
        // 31
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 128, 15));  // blade
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 128, 15));
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 128, 15));

        // 34
        data.addAll(GenerateSprites.extractSprite(sourceImage, 48, 112, 15));  // big blood drop
        data.addAll(GenerateSprites.extractSprite(sourceImage, 64, 112, 15));

        // 36
        data.addAll(GenerateSprites.extractSprite(sourceImage, 80, 96, 15));  // boss name top
        data.addAll(GenerateSprites.extractSprite(sourceImage, 96, 96, 15));
        
        // 38
        data.addAll(GenerateSprites.extractSprite(sourceImage, 0, 96, 15));  // ghost top
        
        // 39
        data.addAll(GenerateSprites.extractSprite(sourceImage, 32, 112, 15));  // blood drop
        
        System.out.println("boss4Sprites: " + data.size());
        String outputPath = "src/autogenerated/boss4-sprites";
        Z80Assembler.dataToBinary(data, outputPath + ".bin");
        ZX0Wrapper.main(outputPath + ".bin", outputPath + ".zx0", true, false);
    }    
}
