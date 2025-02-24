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
    
    public int tiles[][];
    public HashMap<String, String> tags;
    public List<TMXObject> locations;
    public BufferedImage gfx = null;
    public String path;
    
    
    public RoomChunk()
    {
    }
    
    
    public RoomChunk(String tmxPath, int a_type) throws Exception {
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
        RoomChunk chunk = this.clone();
        
        for(int i = 0;i<CHUNK_HEIGHT;i++) {
            for(int j = 0;j<CHUNK_WIDTH;j++) {
                if (biome.equals("pyramid")) {
                    int tile = tiles[j][i];
                    switch(tile) {
                        // torch:
//                        case 6*16 + 2:
//                        case 6*16 + 3:
//                        case 6*16 + 4:
//                            tile = 6*16 + 2;
//                            break;
                        // spikes:
                        case 7*16 + 12:
                        case 7*16 + 13:
                            tile = 7*16 + 12;
                            break;
                        case 7*16 + 14:
                        case 7*16 + 15:
//                            tile = 7*16 + 14;
                            tile = 0;
                            break;
                        // water:
//                        case 8*16 + 1:
//                        case 8*16 + 2:
//                        case 8*16 + 3:
//                        case 12*16 + 8:
//                            tile = 8*16 + 1;
//                            break;
                        // ropes:
                        case 8*16 + 4:
                        case 8*16 + 6:
//                            tile = 8*16 + 4;
                            tile = 0;  // remove ropes, they will be reconstructed
                            break;
                        // platforms:
                        case 8*16 + 8:
                        case 8*16 + 9:
                            tile = 8*16 + 8;
                            break;
                        // bricks top:
                        case 9*16 + 5:
                        case 9*16 + 6:
                        case 9*16 + 11:
                            tile = 9*16 + 5;
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
                        case 9*16 + 13:
                        case 9*16 + 14:
                        case 9*16 + 15:
                            tile = 9*16 + 13;
                            break;
                        // rubble:
                        case 10*16 + 0:
                        case 10*16 + 1:
                        case 10*16 + 2:
                        case 10*16 + 3:
                            tile = 10*16 + 0;
                            break;
                        // stairs (leave only the bottom piece):
                        case 10*16 + 6:
                            if (i<CHUNK_HEIGHT-1 && tiles[j][i+1] == 10*16+6) {
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
                        case 13*16 + 9:
                        case 13*16 + 10:
                        case 13*16 + 11:
                        case 14*16 + 8:
                        case 14*16 + 9:
                        case 14*16 + 10:
                        case 14*16 + 11:
                        case 15*16 + 8:
                        case 15*16 + 9:
                        case 15*16 + 10:
                        case 15*16 + 11:
                            tile = 0;
                            break;
                        // dragon pattern:
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
    
    
    public void draw(int x, int y, Graphics2D g)
    {
        float scale = 1.0f;
        if (gfx == null) {
            File f = new File("data/patterns/tiles.png");
            try {
                gfx = ImageIO.read(f);
            } catch (IOException ex) {
                return;
            }
        }
        
        for(int i = 0;i<CHUNK_HEIGHT;i++) {
            for(int j = 0;j<CHUNK_WIDTH;j++) {
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
}
