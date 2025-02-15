/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.util.Arrays;
import java.util.Random;
import pcg.Area;
import pcg.PCGArea;
import pcg.PCGWorld;
import pcg.RenderedArea;
import pcg.RoomChunk;
import pcg.World;

/**
 *
 * @author santi
 */
public class HardcodedRoomForAssembler {
    public static void main(String args[]) throws Exception
    {
        Random r = new Random();

        PCGWorld pcg1 = new PCGWorld();
        PCGArea pcg2 = new PCGArea();
        
        r.setSeed(0);
        World w = pcg1.generate(r);
        pcg2.generate(w.areas.get(0), w, r);
        RenderedArea ra = pcg2.generate(w.areas.get(1), w, r);
        
        generateAssemblerRoomData(5, w.areas.get(1), ra);
    }

    
    public static void generateAssemblerRoomData(int roomID, Area a, RenderedArea ra) throws Exception
    {
        int layout[] = new int[4*4];
        int tile_map[] = new int[32*24*4];
        int n_room_objects = 0;
        
        int room_x0 = -1, room_y0 = -1;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] == roomID) {
                    if (room_x0 == -1 || j < room_x0) {
                        room_x0 = j;
                    }
                    if (room_y0 == -1 || i < room_y0) {
                        room_y0 = i;
                    }
                }
            }
        }
        
        int screen_ID = 0;
        for(int j = 0;j<a.width;j++) {
            for(int i = 0;i<a.height;i++) {
                if (a.rooms[j][i] == roomID) {
                    addChunkToTileMap(ra, j, i, tile_map, 0, 0, screen_ID);
                    addChunkToTileMap(ra, j, i, tile_map, 1, 0, screen_ID);
                    addChunkToTileMap(ra, j, i, tile_map, 0, 1, screen_ID);
                    addChunkToTileMap(ra, j, i, tile_map, 1, 1, screen_ID);
                    screen_ID++;
                    layout[(j - room_x0) + (i - room_y0) * 4] = screen_ID;
                }
            }
        }
        
        System.out.println("hardcoded_room_data__layout:");
        for(int i = 0;i<4;i++) {
            String line = "  db ";
            for(int j = 0;j<4;j++) {
                if (j == 0) {
                    line += "" + layout[j + i*4];
                } else {
                    line += ", " + layout[j + i*4];
                }
            }
            System.out.println(line);
        }
        System.out.println("");

        System.out.println("hardcoded_room_data__tile_map:");
        for(int i = 0;i<4;i++) {
            for(int j = 0;j<24;j++) {
                String line = "  db ";
                for(int k = 0;k<32;k++) {
                    if (k == 0) {
                        line += "" + tile_map[k + j*32 + i*32*24];
                    } else {
                        line += ", " + tile_map[k + j*32 + i*32*24];
                    }
                }
                System.out.println(line);
            }
            System.out.println("");
        }
        System.out.println("hardcoded_room_data__n_objects:");
        System.out.println("  db " + n_room_objects);
    }
    
    
    public static void addChunkToTileMap(RenderedArea ra, int chunkx, int chunky, int []tile_map, int roomx, int roomy, int roomID)
    {
        for(int i = 0; i<RoomChunk.CHUNK_HEIGHT;i++) {            
            for(int j = 0; j<RoomChunk.CHUNK_WIDTH;j++) {
                int tile = ra.fg_chunks[chunkx*2 + roomx][chunky*2 + roomy].tiles[j][i];
                if (tile == 0) {
                    tile = ra.bg_chunks[chunkx*2 + roomx][chunky*2 + roomy].tiles[j][i];
                }
                int offset = roomx * RoomChunk.CHUNK_WIDTH + j + 
                         (roomy * RoomChunk.CHUNK_HEIGHT + i) * 32 +
                         roomID * 32 * 24;
//                System.out.println("offset: " + offset + ", chunkx: " + chunkx + ", chunky: " + chunky + ", roomx: " + roomx + ", roomy: " + roomy + ", roomID: " + roomID);
                tile_map[offset] = tile;
            }
        }
    }
}
