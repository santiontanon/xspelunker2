/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 *
 * @author santi
 */
public class RenderedArea {
    public RoomChunk bg_chunks[][];
    public RoomChunk fg_chunks[][];
    public List<GameObject> objects;
        
    public RenderedArea(int w, int h)
    {
        bg_chunks = new RoomChunk[w][h];
        fg_chunks = new RoomChunk[w][h];
        objects = new ArrayList<>();
    }
    
    public void draw(Graphics2D g)
    {
        for(int i = 0;i<fg_chunks[0].length;i++) {
            for(int j = 0;j<fg_chunks.length;j++) {
                if (bg_chunks[j][i] != null) {
                    bg_chunks[j][i].draw(j*RoomChunk.CHUNK_WIDTH*8,
                                         i*RoomChunk.CHUNK_HEIGHT*8, g);
                }
                if (fg_chunks[j][i] != null) {
                    fg_chunks[j][i].draw(j*RoomChunk.CHUNK_WIDTH*8,
                                         i*RoomChunk.CHUNK_HEIGHT*8, g);
                }
            }
        }
        
        for(GameObject o:objects) {
            o.draw(g);
        }
    }
    
    
    public void stats(HashMap<String, Integer> chunkStats, int typeStats[])
    {
        for(int i = 0;i<fg_chunks[0].length;i++) {
            for(int j = 0;j<fg_chunks.length;j++) {
                if (fg_chunks[j][i] != null) {
                    typeStats[fg_chunks[j][i].type]++;
                    if (!chunkStats.containsKey(fg_chunks[j][i].path)) {
                        chunkStats.put(fg_chunks[j][i].path, 0);
                    }
                    chunkStats.put(fg_chunks[j][i].path, chunkStats.get(fg_chunks[j][i].path) + 1);
                }
            }
        }        
    }
}
