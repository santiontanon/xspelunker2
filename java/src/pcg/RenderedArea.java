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
    public static int MAX_ANIMATIONS = 20;

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
    
    
    public List<TileAnimation> getRoomAnimations(int roomID, Area a)
    {
        List<TileAnimation> animations = new ArrayList<>();

        int room_x1 = -1;
        int room_y1 = -1;
        
        // Find the top left:
        for(int i = 0; i < a.height; i++) {
            for(int j = 0; j < a.width; j++) {
                if (a.rooms[j][i] == roomID) {
                    if (room_x1 == -1 || room_x1 > j) {
                        room_x1 = j;
                    }
                    if (room_y1 == -1 || room_y1 > i) {
                        room_y1 = i;
                    }
                }
            }
        }
        
        if (room_x1 == -1) return animations;
        
        // find animations:
        for(int i = 0; i < a.height; i++) {
            for(int j = 0; j < a.width; j++) {
                if (a.rooms[j][i] == roomID) {
                    for(int i2 = 0; i2 < PCGArea.ROOM_HEIGHT; i2++) {
                        for(int i3 = 0; i3 < RoomChunk.CHUNK_HEIGHT; i3++) {
                            int animation_start = 0;
                            int previous_animation_type = 0;
                            for(int j2 = 0; j2 < PCGArea.ROOM_WIDTH; j2++) {
                                for(int j3 = 0; j3 < RoomChunk.CHUNK_WIDTH; j3++) {
                                    int tile = 0;
//                                    if (fg_chunks[j*PCGArea.ROOM_WIDTH + j2][i*PCGArea.ROOM_HEIGHT + i2] != null) {
                                        tile = fg_chunks[j*PCGArea.ROOM_WIDTH + j2][i*PCGArea.ROOM_HEIGHT + i2].tiles[j3][i3];
//                                    } else {
//                                        if (i3 == 0 && j3 == 0) {
//                                            System.out.println("Null room chunk: " + (j*2 + j2) + ", " + (i*2+ i2) + ", area " + a.ID);
//                                        }
//                                    }
                                    if (tile <= 0) {
                                        if (bg_chunks[j*PCGArea.ROOM_WIDTH + j2][i*PCGArea.ROOM_HEIGHT + i2] != null) {
                                            tile = bg_chunks[j*PCGArea.ROOM_WIDTH + j2][i*PCGArea.ROOM_HEIGHT + i2].tiles[j3][i3];                                        
                                        }
                                    }
                                    int animation_type = 0;
                                    switch(tile) {
                                        case 6*16+2:
                                        case 6*16+3:
                                        case 6*16+4:
                                            // torch flame:
                                            animation_type = 1;
                                            break;
                                        case 8*16+1:
                                        case 8*16+2:
                                        case 8*16+3:
                                        case 200:
                                            // water top:
                                            animation_type = 2;
                                            break;
                                        default:
                                    }
                                    if (animation_type != previous_animation_type) {
                                        int x = j3 + (j2 + (j - room_x1) * PCGArea.ROOM_WIDTH) * RoomChunk.CHUNK_WIDTH;
                                        int y = i3 + (i2 + (i - room_y1) * PCGArea.ROOM_HEIGHT) * RoomChunk.CHUNK_HEIGHT;
                                        if (previous_animation_type != 0) {
                                            // close the previous animation:
                                            animations.add(new TileAnimation(animation_start, y, x - animation_start, previous_animation_type));
                                            previous_animation_type = 0;
                                        }
                                        if (animation_type != 0) {
                                            // start a new animation:
                                            animation_start = x;
                                            previous_animation_type = animation_type;
                                        }
                                    }
                                }
                            }
                            if (previous_animation_type != 0) {
                                int x = RoomChunk.CHUNK_WIDTH + (PCGArea.ROOM_WIDTH + (j - room_x1) * PCGArea.ROOM_WIDTH) * RoomChunk.CHUNK_WIDTH;
                                int y = i3 + (i2 + (i - room_y1) * PCGArea.ROOM_HEIGHT) * RoomChunk.CHUNK_HEIGHT;
                                // close the previous animation:
                                animations.add(new TileAnimation(animation_start, y, x - animation_start, previous_animation_type));
                                previous_animation_type = 0;
                            }
                        }
                    }
                }
            }
        }
        
        return animations;
    }
}
