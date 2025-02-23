/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import pcg.PCGArea;
import pcg.RoomChunk;

/**
 *
 * @author santi
 */
public class TileUsageStats {
    public static void main(String args[]) throws Exception
    {
        PCGArea pcg = new PCGArea(false);
        
        int tileCounts[] = new int[256];
        for(RoomChunk c:pcg.bg_chunks) {
            updateChunkTileStats(c, tileCounts);
        }
        for(RoomChunk c:pcg.all_fg_chunks) {
            updateChunkTileStats(c, tileCounts);
        }
        
        for(int i = 0;i<16;i++) {
            String line = "";
            for(int j = 0;j<16;j++) {
                line += tileCounts[i*16 + j] + "\t";
            }
            System.out.println(line);
        }
    }

    private static void updateChunkTileStats(RoomChunk c, int[] tileCounts)
    {
        for(int i = 0;i<12;i++) {
            for(int j = 0;j<16;j++) {
                tileCounts[c.tiles[j][i]]++;
            }
        }
    }
}
