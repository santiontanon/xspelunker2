/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

/**
 *
 * @author santi
 */
public class ChunkTileSwap {
    public static void main(String args[]) throws Exception
    {
        File directory = new File("data/patterns-old");
        for(File f:directory.listFiles()) {
            if (f.getName().endsWith("tmx")) {
                String path = "data/patterns/" + f.getName();
                System.out.println(path);
                updateTileOrder("data/patterns-old/" + f.getName(), path);
            }
        }
    }
    
    
    public static void updateTileOrder(String inputPath, String outputPath) throws Exception
    {
        BufferedReader br = new BufferedReader(new FileReader(inputPath));
        FileWriter fw = new FileWriter(outputPath);
        
        int state = 0;
        
        while(br.ready()) {
            String line = br.readLine();
            switch(state) {
                case 0:
                    if (line.contains("<data encoding=\"csv\">")) {
                        state = 1;
                    }
                    fw.write(line);
                    break;
                case 1:
                    if (line.contains("</data>")) {
                        state = 2;
                        fw.write(line);
                    } else {
                        String parts[] = line.split(",");
                        String outputLine = "";
                        for(String part:parts) {
                            Integer tile = Integer.parseInt(part) - 1;
                            tile = shiftDragonUp(tile);
                            tile = swapRopeTip(tile);
                            tile = swapPlatform(tile);
                            tile = swapThinBrick(tile);
                            tile = swapFlower(tile);
                            tile = swapLadderRight(tile);
                            tile = swapPushableBottom(tile);
                            tile = moveFacesUp(tile);
                            tile = moveFacesBricksLadderRubble(tile);
                            outputLine += (tile + 1) + ",";
                        }
                        if (!line.endsWith(",")) {
                            outputLine = outputLine.substring(0, outputLine.length() - 1);
                        }
                        fw.write(outputLine);
                    }
                    break;
                case 2:
                    fw.write(line);
                    break;
            }
        }
        
        fw.flush();
        fw.close();
    }
    
    
    public static int shiftDragonUp(int tile)
    {
        int row = tile/16;
        int column = tile%16;        
        if (column>=12) {
            if (row == 7) {
                row = 15;
            } else if (row > 7) {
                row--;
            }
        }
        return row * 16 + column;
    }
    
    
    public static int swapRopeTip(int tile)
    {
        if (tile == 8*16 + 5) {
            return 15*16 + 15;
        } else if (tile == 8*16 + 4) {
            return 8*16 + 3;
        } else if (tile == 15*16 + 15) {
            return 8*16 + 5;
        } else if (tile == 15*16 + 14) {
            return 8*16 + 4;
        } else {
            return tile;
        }
    }    


    public static int swapPlatform(int tile)
    {
        if (tile == 8*16 + 8) {
            return 15*16 + 14;
        } else {
            return tile;
        }
    }    
    
    
    public static int swapThinBrick(int tile)
    {
        if (tile == 8*16 + 13) {
            return 15*16 + 13;
        } else if (tile == 15*16 + 13) {
            return 8*16 + 13;
        } else {
            return tile;
        }
    }    

    
    public static int swapFlower(int tile)
    {
        if (tile == 12*16 + 5) {
            return 6*16 + 4;
        } else {
            return tile;
        }
    }    


    public static int swapLadderRight(int tile)
    {
        if (tile == 11*16 + 8) {
            return 9*16 + 8;
        } else {
            return tile;
        }
    }    

    
    public static int swapPushableBottom(int tile)
    {
        if (tile == 12*16 + 9) {
            return 11*16 + 6;
        } else if (tile == 12*16 + 10) {
            return 11*16 + 7;
        } else if (tile == 12*16 + 11) {
            return 11*16 + 8;
        } else {
            return tile;
        }
    }    
    

    public static int moveFacesUp(int tile)
    {
        int row = tile/16;
        int column = tile%16;
        if (column >= 5 && column < 12) {
            if (row == 15 || row == 14 || row == 13) {
                return (row - 1)*16 + column;
            }
        }
        return tile;
    }    

    
    public static int moveFacesBricksLadderRubble(int tile)
    {
        if (tile == 11*16 + 12) {
            return 15*16 + 11;
        } else if (tile == 12*16 + 8) {
            return 15*16 + 10;
        } else if (tile == 12*16 + 0) {
            return 15*16 + 9;
        } else if (tile == 10*16 + 6) {
            return 15*16 + 8;
        } else if (tile == 10*16 + 0) {
            return 15*16 + 7;
        } else if (tile == 9*16 + 5) {
            return 15*16 + 6;
        } else 
        return tile;
    }    
    
}
