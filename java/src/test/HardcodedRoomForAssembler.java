/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

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
//        generateAssemblerRoomData(3, w.areas.get(1), ra);  // size 2
        generateAssemblerRoomData(6, w.areas.get(1), ra);  // size 4, square
    }

    
    public static void generateAssemblerRoomData(int roomID, Area a, RenderedArea ra) throws Exception
    {
        int n_room_objects = 0;
        
        int room_x1 = -1, room_y1 = -1;
        int room_x2 = -1, room_y2 = -1;
        for(int i = 0;i<a.height;i++) {
            for(int j = 0;j<a.width;j++) {
                if (a.rooms[j][i] == roomID) {
                    if (room_x1 == -1 || j < room_x1) {
                        room_x1 = j;
                    }
                    if (room_y1 == -1 || i < room_y1) {
                        room_y1 = i;
                    }
                    if (room_x2 == -1 || j > room_x2) {
                        room_x2 = j;
                    }
                    if (room_y2 == -1 || i > room_y2) {
                        room_y2 = i;
                    }
                }
            }
        }
        int width = (1 + room_x2 - room_x1) * 32;
        int height = (1 + room_y2 - room_y1) * 24;
        
        int tile_map[] = new int[width * height];
        
        for(int i = room_y1;i<=room_y2;i++) {
            for(int j = room_x1;j<=room_x2;j++) {
                if (a.rooms[j][i] == roomID) {
                    addChunkToTileMap(ra, j*2,   i*2,   tile_map, (j - room_x1)*2,     (i - room_y1)*2, width);
                    addChunkToTileMap(ra, j*2+1, i*2,   tile_map, (j - room_x1)*2 + 1, (i - room_y1)*2, width);
                    addChunkToTileMap(ra, j*2,   i*2+1, tile_map, (j - room_x1)*2,     (i - room_y1)*2 + 1, width);
                    addChunkToTileMap(ra, j*2+1, i*2+1, tile_map, (j - room_x1)*2 + 1, (i - room_y1)*2 + 1, width);
                }
            }
        }
        
        System.out.println("hardcoded_room_data__width:");
        System.out.println("  db " + width);
        System.out.println("hardcoded_room_data__height:");
        System.out.println("  db " + height);
        
        System.out.println("hardcoded_room_data__tile_map:");
        for(int i = 0;i<height;i++) {
            String line = "  db ";
            for(int j = 0;j<width;j++) {
                if (j == 0) {
                    line += "" + tile_map[j + i*width];
                } else {
                    line += ", " + tile_map[j + i*width];
                }
            }
            System.out.println(line);
        }
        
        if (width*height < 64*48) {
            System.out.println("hardcoded_room_data__filler:");
            System.out.println("  ds " + (64*48 - width*height) + ", 0\n");
        }

        System.out.println("hardcoded_room_data__max_scroll_x:");
        System.out.println("  db " + (width - 32));
        System.out.println("hardcoded_room_data__max_scroll_y:");
        System.out.println("  db " + (height - 24));
        
        System.out.println("hardcoded_room_data__n_objects:");
        System.out.println("  db " + n_room_objects);
    }
    
    
    public static void addChunkToTileMap(RenderedArea ra, int chunkx, int chunky, int []tile_map, int targetx, int targety, int width)
    {
        for(int i = 0; i<RoomChunk.CHUNK_HEIGHT;i++) {            
            for(int j = 0; j<RoomChunk.CHUNK_WIDTH;j++) {
                int tile = ra.fg_chunks[chunkx][chunky].tiles[j][i];
                if (tile == 0) {
                    tile = ra.bg_chunks[chunkx][chunky].tiles[j][i];
                }
                int offset = targetx * RoomChunk.CHUNK_WIDTH + j +
                             (targety * RoomChunk.CHUNK_HEIGHT + i) * width;
                tile_map[offset] = tile;
            }
        }
    }
}
