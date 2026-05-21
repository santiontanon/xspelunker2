/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.imageio.ImageIO;
import util.TMXObject;
import util.Tiled;

/**
 *
 * @author santi
 */
public class RoomChunk {
    public static int MAX_LOCATIONS = 12;
    
    public static int start_x = 20;
    public static int start_y = 40;
    
    public static final int CHUNK_WIDTH = 16;
    public static final int CHUNK_HEIGHT = 12;
    
    public int type;
    String biome = null;
    
    public int tiles[][];
    public HashMap<String, String> tags;
    public List<TMXObject> locations;
    public BufferedImage gfx = null;
    public String path;
    
    
    public RoomChunk()
    {
    }
    
    
    public RoomChunk(String tmxPath, int a_type, String a_biome) throws Exception {
        biome = a_biome;
        path = tmxPath;
        type = a_type;
        
        // load the tmx file and generate the image:
        tiles = Tiled.loadTMXtileData(tmxPath);
        tags = Tiled.loadTMXProperties(tmxPath);
        locations = Tiled.loadTMXObjects(tmxPath, "objects");
    }
    
    
    @Override
    public RoomChunk clone()
    {
        RoomChunk c = new RoomChunk();
        c.biome = biome;
        c.type = type;
        c.tiles = new int[tiles.length][tiles[0].length];
        for(int j = 0;j<tiles.length;j++) {
            for(int i = 0;i<tiles[j].length;i++) {
                c.tiles[j][i] = tiles[j][i];
            }        
        }
        c.tags = new HashMap<>();
        c.tags.putAll(tags);
        c.locations = new ArrayList<>();
        if (locations != null) {
            c.locations.addAll(locations);
        }
        c.gfx = gfx;
        c.path = path;
        return c;
    }
    
    
    public RoomChunk simplifyTiles(String biome) throws Exception
    {        
        switch(biome) {
            case "jungle": return simplifyTilesJungle(biome);
            case "pyramid": return simplifyTilesPyramid(biome);
            case "caves": return simplifyTilesCaves(biome);
            case "xibalba": return simplifyTilesXibalba(biome);
            case "atlantis": return simplifyTilesAtlantis(biome);
            case "mars": return simplifyTilesMars(biome);
            case "moon": return simplifyTilesMoon(biome);
            default:
                throw new Exception("Undefined biome " + biome);
        }
    }

    
    public RoomChunk simplifyTilesJungle(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // ropes:
                    case 8*16 + 3:
                    case 8*16 + 6:
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // tree-left:
                    case 9*16 + 0:
                    case 10*16 + 0:
                        tile = 9*16 + 0;
                        break;
                    // tree-center:
                    case 9*16 + 1:
                    case 10*16 + 1:
                        tile = 9*16 + 1;
                        break;
                    // tree-right:
                    case 9*16 + 2:
                    case 10*16 + 2:
                        tile = 9*16 + 2;
                        break;
                    // branch:
                    case 9*16 + 4:
                    case 9*16 + 5:
                        tile = 9*16 + 4;
                        break;
                    // rubble:
                    case 10*16 + 9:
                    case 10*16 + 10:
                    case 10*16 + 11:
                    case 15*16 + 14:
                        tile = 15*16 + 14;
                        break;
                    // floor:
                    case 12*16 + 6:
                    case 12*16 + 7:
                    case 12*16 + 9:
                    case 13*16 + 9:
                        tile = 12*16 + 6;
                        break;
                    // wall:
                    case 13*16 + 6:
                    case 13*16 + 7:
                        tile = 13*16 + 6;  // center
                        break;
                    case 13*16 + 5:
                    case 15*16 + 6:
                        tile = 13*16 + 5;  // left
                        break;
                    case 13*16 + 8:
                    case 15*16 + 5:
                        tile = 13*16 + 8;  // right
                        break;
                    case 14*16 + 6:
                    case 14*16 + 7:
                        tile = 14*16 + 6;  // bottom
                        break;
                    // foliage:
                    case 14*16 + 9:
                    case 14*16 + 10:
                    case 14*16 + 11:
                        tile = 14*16 + 9;
                        break;
                    // foliage bottom:
                    case 13*16 + 10:
                    case 13*16 + 11:
                    case 13*16 + 12:
                        tile = 13*16 + 10;
                        break;
                    // background foliage:
//                    case 6*16 + 6:
//                    case 6*16 + 7:
//                    case 7*16 + 6:
//                    case 7*16 + 7:
//                        tile = 7*16 + 6;
//                        break;
                }
                chunk.tiles[j][i] = tile;                
            }
        }
        return chunk;
    }


    public RoomChunk simplifyTilesPyramid(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // spikes:
                    case 15*16 + 12:
                    case 8*16 + 13:
                        tile = 15*16 + 12;
                        break;
                    case 8*16 + 4:
                    case 8*16 + 5:
                        tile = 0;
                        break;
                    // ropes:
                    case 8*16 + 3:
                    case 8*16 + 6:
//                            tile = 8*16 + 4;
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // platforms:
                    case 15*16 + 14:
                    case 8*16 + 9:
                        tile = 15*16 + 14;
                        break;
                    // bricks top:
                    case 15*16 + 6:
                    case 9*16 + 6:
                    case 9*16 + 11:
                        tile = 15*16 + 6;
//                            if (tiles[j][i + 1] != 9*16 + 7 &&
//                                tiles[j][i + 1] != 9*16 + 8) {
//                                throw new Exception("Malformed chunk! brick top is not on top of a brick bottom tile!");
//                            }
                        break;
                    // bricks bottom:
                    case 9*16 + 7:
                    case 9*16 + 8:
//                            tile = 9*16 + 7;
                        tile = 0;
                        break;
                    // thin bricks:
                    case 15*16 + 13:
                    case 8*16 + 14:
                    case 8*16 + 15:
                        tile = 15*16 + 13;
                        break;
                    // rubble:
                    case 15*16 + 7:
                    case 10*16 + 1:
                    case 10*16 + 2:
                    case 10*16 + 3:
                        tile = 15*16 + 7;
                        break;
                    // stairs (leave only the bottom piece):
                    case 15*16 + 8:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
                            tile = 0;
                        }
                        break;
                    case 10*16 + 7:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16+7) {
                            tile = 0;
                        }
                        break;
                    // face 1 pattern:
                    case 12*16 + 1:
                    case 12*16 + 2:
                    case 13*16 + 0:
                    case 13*16 + 1:
                    case 13*16 + 2:
                    case 14*16 + 0:
                    case 14*16 + 1:
                    case 14*16 + 2:
                    case 15*16 + 0:
                    case 15*16 + 1:
                    case 15*16 + 2:
                        tile = 0;
                        break;                            
                    // face 2 pattern:
                    case 12*16 + 9:
                    case 12*16 + 10:
                    case 12*16 + 11:
                    case 13*16 + 8:
                    case 13*16 + 9:
                    case 13*16 + 10:
                    case 13*16 + 11:
                    case 14*16 + 8:
                    case 14*16 + 9:
                    case 14*16 + 10:
                    case 14*16 + 11:
                        tile = 0;
                        break;
                    // dragon pattern:
                    case 11*16 + 13:
                    case 11*16 + 14:
                    case 11*16 + 15:
                    case 12*16 + 12:
                    case 12*16 + 13:
                    case 12*16 + 14:
                    case 12*16 + 15:
                    case 13*16 + 12:
                    case 13*16 + 13:
                    case 13*16 + 14:
                    case 13*16 + 15:
//                        case 15*16 + 12:
//                        case 15*16 + 13:
//                        case 15*16 + 14:
//                        case 15*16 + 15:
                        tile = 0;
                        break;
                    // figure pattern:
//                        case 12*16 + 6:
//                        case 12*16 + 7:
//                        case 13*16 + 5:
//                        case 13*16 + 6:
//                        case 13*16 + 7:
//                        case 14*16 + 5:
//                        case 14*16 + 6:
//                        case 14*16 + 7:
//                            tile = 0;
//                            break;  
//                        // columns:
//                        case 12*16 + 4:
//                        case 13*16 + 4:
//                        case 14*16 + 4:
//                        case 15*16 + 4:
//                            tile = 0;
//                            break;
                    default:
                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }
    
    
    public RoomChunk simplifyTilesCaves(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // spikes:
                    case 15*16 + 12:
                    case 8*16 + 13:
                        tile = 15*16 + 12;
                        break;
                    case 8*16 + 4:
                    case 8*16 + 5:
                        tile = 0;
                        break;
                    // ropes:
                    case 8*16 + 3:
                    case 8*16 + 6:
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // floor:
                    case 15*16+6:
                    case 7*16+6:
                    case 7*16+7:
                        tile = 15*16+6;
                        break;
                    // ceiling:
                    case 15*16+13:
                    case 9*16+2:
                    case 9*16+3:
                        tile = 15*16+13;
                        break;
                    // walls:
                    case 15*16+10:
                    case 7*16+10:
                    case 7*16+11:
                        tile = 15*16+10;
                        break;
                    case 15*16+11:
                    case 7*16+13:
                    case 7*16+14:
                        tile = 15*16+11;
                        break;
                    // platforms:
                    case 15*16 + 14:
                    case 8*16 + 9:
                        tile = 15*16 + 14;
                        break;
                    // rubble:
                    case 15*16 + 7:
                    case 10*16 + 1:
                    case 10*16 + 2:
                    case 10*16 + 3:
                        tile = 15*16 + 7;
                        break;
                    // stairs (leave only the bottom piece):
                    case 15*16 + 8:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
                            tile = 0;
                        }
                        break;
                    case 10*16 + 7:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16+7) {
                            tile = 0;
                        }
                        break;
                    // face 1 pattern:
                    case 12*16 + 1:
                    case 12*16 + 2:
                    case 13*16 + 0:
                    case 13*16 + 1:
                    case 13*16 + 2:
                    case 14*16 + 0:
                    case 14*16 + 1:
                    case 14*16 + 2:
                    case 15*16 + 0:
                    case 15*16 + 1:
                    case 15*16 + 2:
                        tile = 0;
                        break;
                    default:
                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }
    
    
    public RoomChunk simplifyTilesXibalba(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // spikes:
                    case 15*16 + 12:
                    case 8*16 + 2:
                        tile = 15*16 + 12;
                        break;
                    case 8*16 + 4:
                    case 8*16 + 5:
                        tile = 0;
                        break;
                    // ropes:
                    case 8*16 + 3:
                    case 8*16 + 6:
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // platforms 1:
                    case 15*16 + 14:
                    case 8*16 + 9:
                        tile = 15*16 + 14;
                        break;
                    // platforms 2:
                    case 15*16 + 5:
                    case 10*16 + 9:
                        tile = 15*16 + 5;
                        break;
                    // glyphs:
                    case 12*16+9:
                    case 12*16+10:
                    case 13*16+9:
                    case 13*16+10:
                    case 14*16+9:
                    case 14*16+10:
                        tile = 12*16+9;
                        break;
                    // left wall:
                    case 15*16 + 6:
                    case 9*16 + 4:
                    case 9*16 + 5:
                        tile = 15*16 + 6;
                        break;
                    // right wall:
                    case 15*16 + 10:
                    case 9*16 + 2:
                    case 9*16 + 3:
                        tile = 15*16 + 10;
                        break;
                    // up wall:
                    case 15*16 + 13:
                    case 8*16 + 12:
                    case 8*16 + 13:
                        tile = 15*16 + 13;
                        break;
                    // down wall:
                    case 15*16 + 11:
                    case 8*16 + 14:
                    case 8*16 + 15:
                        tile = 15*16 + 11;
                        break;
                    // rubble:
                    case 15*16 + 7:
                    case 10*16 + 1:
                    case 10*16 + 2:
                    case 10*16 + 3:
                        tile = 15*16 + 7;
                        break;
                    // stairs (leave only the bottom piece):
                    case 15*16 + 8:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
                            tile = 0;
                        }
                        break;
                    case 10*16 + 7:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16+7) {
                            tile = 0;
                        }
                        break;
                    // face 1 pattern:
                    case 12*16 + 1:
                    case 12*16 + 2:
                    case 13*16 + 0:
                    case 13*16 + 1:
                    case 13*16 + 2:
                    case 14*16 + 0:
                    case 14*16 + 1:
                    case 14*16 + 2:
                    case 15*16 + 0:
                    case 15*16 + 1:
                    case 15*16 + 2:
                        tile = 0;
                        break;
                    default:
                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }

    
    public RoomChunk simplifyTilesAtlantis(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // spikes:
                    case 15*16 + 12:
                    case 8*16 + 2:
                        tile = 15*16 + 12;
                        break;
                    case 8*16 + 4:
                    case 8*16 + 5:
                        tile = 0;
                        break;
                    // ropes:
                    case 8*16 + 3:
                    case 8*16 + 6:
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // platforms 1:
                    case 15*16 + 14:
                    case 8*16 + 9:
                        tile = 15*16 + 14;
                        break;
                    // small bricks:
                    case 15*16 + 13:
                    case 9*16 + 15:
                    case 9*16 + 14:
                        tile = 15*16 + 13;
                        break;
                    // medium bricks:
                    case 15*16 + 11:
                    case 7*16 + 6:
                        tile = 15*16 + 11;
                        break;
                    case 15*16 + 10:
                    case 7*16 + 5:
                        tile = 15*16 + 10;
                        break;
                    // gold bricks:
                    case 12*16 + 5:
                    case 12*16 + 6:
                        tile = 12*16 + 5;
                        break;
                    // stairs (leave only the bottom piece):
                    case 15*16 + 8:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
                            tile = 0;
                        }
                        break;
                    case 10*16 + 7:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16+7) {
                            tile = 0;
                        }
                        break;
//                    case 12*16 + 12:
//                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 12*16 + 12) {
//                            tile = 0;
//                        }
//                        break;
//                    case 12*16 + 13:
//                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 12*16+13) {
//                            tile = 0;
//                        }
//                        break;
                    default:
                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }


    public RoomChunk simplifyTilesMars(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
                switch(tile) {
                    // ropes (cables):
                    case 8*16 + 3:
                    case 8*16 + 6:
                        tile = 0;  // remove ropes, they will be reconstructed
                        break;
                    // platforms:
                    case 15*16 + 14:
                    case 8*16 + 10:
                        tile = 15*16 + 14;
                        break;
                    // wall top:
                    case 6*16 + 0:
                    case 6*16 + 1:
                    case 6*16 + 2:
                    case 6*16 + 3:
                    case 15*16 + 13:
                        tile = 15*16 + 13;
                        break;
                    // spikes:
                    case 8*16 + 13:
                    case 15*16 + 12:
                        tile = 15*16 + 12;
                        break;
                    case 8*16 + 4:
                    case 8*16 + 5:
                        tile = 0;
                        break;
                    // wall right:
                    case 7*16 + 5:
                    case 7*16 + 6:
                    case 15*16 + 11:
                        tile = 15*16 + 11;
                        break;
                    // wall left:
                    case 7*16 + 3:
                    case 7*16 + 4:
                    case 15*16 + 10:
                        tile = 15*16 + 10;
                        break;
                    // wall bottom:
                    case 7*16 + 13:
                    case 7*16 + 14:
                    case 15*16 + 9:
                        tile = 15*16 + 9;
                        break;
                    // stairs (leave only the bottom piece):
                    case 15*16 + 8:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
                            tile = 0;
                        }
                        break;
                    case 10*16 + 7:
                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16 + 7) {
                            tile = 0;
                        }
                        break;
                    // rubble:
                    case 9*16 + 2:
                    case 9*16 + 3:
                    case 9*16 + 4:
                    case 15*16 + 7:
                        tile = 15*16 + 7;
                        break;
                    // medium bricks:
                    // ...
                    // dragon:
                    case 11*16 + 13:
                    case 11*16 + 14:
                    case 11*16 + 15:
                    case 12*16 + 12:
                    case 12*16 + 13:
                    case 12*16 + 14:
                    case 12*16 + 15:
                    case 13*16 + 12:
                    case 13*16 + 13:
                    case 13*16 + 14:
                    case 13*16 + 15:
                    case 14*16 + 12:
                    case 14*16 + 13:
                    case 14*16 + 14:
                    case 14*16 + 15:
                        tile = 0;
                        break;
                    // small bricks:
                    case 8*16 + 14:
                    case 8*16 + 15:
                    case 15*16 + 6:
                        tile = 15*16 + 4;
                        break;
                    // wall center:
                    case 7*16 + 0:
                    case 7*16 + 1:
                    case 7*16 + 2:
                    case 15*16 + 3:
                        tile = 15*16 + 3;
                        break;
                    default:
                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }

    
    public RoomChunk simplifyTilesMoon(String biome) throws Exception
    {
        RoomChunk chunk = this.clone();
        for(int i = 0;i<chunk.tiles[0].length;i++) {
            for(int j = 0;j<chunk.tiles.length;j++) {
                int tile = tiles[j][i];
//                switch(tile) {
//                    // ropes (cables):
//                    case 8*16 + 3:
//                    case 8*16 + 6:
//                        tile = 0;  // remove ropes, they will be reconstructed
//                        break;
//                    // platforms:
//                    case 15*16 + 14:
//                    case 8*16 + 10:
//                        tile = 15*16 + 14;
//                        break;
//                    // wall top:
//                    case 6*16 + 0:
//                    case 6*16 + 1:
//                    case 6*16 + 2:
//                    case 6*16 + 3:
//                    case 15*16 + 13:
//                        tile = 15*16 + 13;
//                        break;
//                    // spikes:
//                    case 8*16 + 13:
//                    case 15*16 + 12:
//                        tile = 15*16 + 12;
//                        break;
//                    case 8*16 + 4:
//                    case 8*16 + 5:
//                        tile = 0;
//                        break;
//                    // wall right:
//                    case 7*16 + 5:
//                    case 7*16 + 6:
//                    case 15*16 + 11:
//                        tile = 15*16 + 11;
//                        break;
//                    // wall left:
//                    case 7*16 + 3:
//                    case 7*16 + 4:
//                    case 15*16 + 10:
//                        tile = 15*16 + 10;
//                        break;
//                    // wall bottom:
//                    case 7*16 + 13:
//                    case 7*16 + 14:
//                    case 15*16 + 9:
//                        tile = 15*16 + 9;
//                        break;
//                    // stairs (leave only the bottom piece):
//                    case 15*16 + 8:
//                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 15*16 + 8) {
//                            tile = 0;
//                        }
//                        break;
//                    case 10*16 + 7:
//                        if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16 + 7) {
//                            tile = 0;
//                        }
//                        break;
//                    // rubble:
//                    case 9*16 + 2:
//                    case 9*16 + 3:
//                    case 9*16 + 4:
//                    case 15*16 + 7:
//                        tile = 15*16 + 7;
//                        break;
//                    // medium bricks:
//                    // ...
//                    // dragon:
//                    case 11*16 + 13:
//                    case 11*16 + 14:
//                    case 11*16 + 15:
//                    case 12*16 + 12:
//                    case 12*16 + 13:
//                    case 12*16 + 14:
//                    case 12*16 + 15:
//                    case 13*16 + 12:
//                    case 13*16 + 13:
//                    case 13*16 + 14:
//                    case 13*16 + 15:
//                    case 14*16 + 12:
//                    case 14*16 + 13:
//                    case 14*16 + 14:
//                    case 14*16 + 15:
//                        tile = 0;
//                        break;
//                    // small bricks:
//                    case 8*16 + 14:
//                    case 8*16 + 15:
//                    case 15*16 + 6:
//                        tile = 15*16 + 4;
//                        break;
//                    // wall center:
//                    case 7*16 + 0:
//                    case 7*16 + 1:
//                    case 7*16 + 2:
//                    case 15*16 + 3:
//                        tile = 15*16 + 3;
//                        break;
//                    default:
//                }
                chunk.tiles[j][i] = tile;
            }
        }
        
        return chunk;
    }
    
    
    public TMXObject randomObject(String type, MSXRandom r)
    {
        List<TMXObject> candidates = new ArrayList<>();
        for(TMXObject o:locations) {
            if (o.type.equals(type)) {
                candidates.add(o);
            }
        }
        if (candidates.isEmpty()) return null;
        return candidates.get(r.nextInt(candidates.size()));
    }
    
    
    public TMXObject firstObject(String type)
    {
        for(TMXObject o:locations) {
            if (o.type.equals(type)) {
                return o;
            }
        }
        return null;
    }
        
    
    public void removeObjectTypes(String type)
    {
        List<TMXObject> toDelete = new ArrayList<>();
        for(TMXObject o:locations) {
            if (o.type.equals(type)) {
                toDelete.add(o);
            }
        }
        locations.removeAll(toDelete);
    }
    
    
    public boolean hasObjectType(String type)
    {
        for(TMXObject o:locations) {
            if (o.type.equals(type)) {
                return true;
            }
        }
        return false;
    }
    
    
    public void loadGfx(String path) throws Exception
    {
        File f = new File(path);
        gfx = ImageIO.read(f);
    }
    
    
    public void draw(int x, int y, Graphics2D g) throws Exception
    {
        float scale = 1.0f;
        if (gfx == null) {
            String path = null;
            if (biome == null) throw new Exception("null biome!");
            switch(biome) {
                case "jungle":
                    path = "data/jungle/tiles.png";
                    break;
                case "pyramid":
                    path = "data/pyramid/tiles.png";
                    break;
                case "caves":
                    path = "data/caves/tiles.png";
                    break;
                case "xibalba":
                    path = "data/xibalba/tiles.png";
                    break;
                case "atlantis":
                    path = "data/atlantis/tiles.png";
                    break;
                case "mars":
                    path = "data/mars/tiles.png";
                    break;
                case "moon":
                    path = "data/moon/tiles.png";
                    break;
                default:
                    throw new Exception("Unsupported biome: " + biome);
            }
            File f = new File(path);
            try {
                gfx = ImageIO.read(f);
            } catch (IOException ex) {
                return;
            }
        }
        
        for(int i = 0;i<tiles[0].length;i++) {
            for(int j = 0;j<tiles.length;j++) {
                if (tiles[j][i] >= 1) {
                    int tx = ((tiles[j][i]) % 16) * 8;
                    int ty = ((tiles[j][i]) / 16) * 8;
                    g.drawImage(gfx, start_x + (int)((x + j*8)*scale), start_y + (int)((y + i*8)*scale),
                                     start_x + (int)((x + (j + 1)*8)*scale), start_y + (int)((y + (i + 1)*8)*scale),
                                     tx, ty, tx + 8, ty + 8, null);
                } else {
                     // do not render the "black" bg, so that we can see the background chunks
//                    g.setColor(Color.BLACK);
//                    g.fillRect(x + j*8, y + i*8, 8, 8);
                }
            }
        }        
    }
    
    
    public void clearTiles(int x0, int y0, int x1, int y1)
    {
        for(int i = y0;i<y1;i++) {
            for(int j = x0;j<x1;j++) {
                tiles[j][i] = 0;
            }
        }
    }
}
