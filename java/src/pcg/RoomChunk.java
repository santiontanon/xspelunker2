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
import java.util.Random;
import javax.imageio.ImageIO;
import util.TMXObject;
import util.Tiled;

/**
 *
 * @author santi
 */
public class RoomChunk {
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
        c.locations.addAll(locations);
        c.gfx = gfx;
        c.path = path;
        return c;
    }
    
    
    public TMXObject randomObject(String type, Random r)
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
