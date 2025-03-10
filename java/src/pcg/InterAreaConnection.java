/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class InterAreaConnection {
    public static final int BIDIRECTIONAL = 0;
    public static final int P1TOP2 = 1;
    public static final int P2TOP1 = 2;
    public AreaPoint p1, p2;
    public int p1_x_chunk_offs, p1_y_chunk_offs;
    public int p2_x_chunk_offs, p2_y_chunk_offs;
    public int direction;
    
    
    public InterAreaConnection(AreaPoint a_p1, AreaPoint a_p2, int a_d, MSXRandom r)
    {
        p1 = a_p1;
        p2 = a_p2;
        p1_x_chunk_offs = 0;
        p1_y_chunk_offs = 0;
        p2_x_chunk_offs = 0;
        p2_y_chunk_offs = 0;
        switch(p1.direction) {
            case PCGWorld.DIRECTION_LEFT: p1_y_chunk_offs = r.nextInt(2); break;
            case PCGWorld.DIRECTION_UP: p1_x_chunk_offs = r.nextInt(2); break;
            case PCGWorld.DIRECTION_RIGHT: p1_y_chunk_offs = r.nextInt(2); p1_x_chunk_offs = 1; break;
            case PCGWorld.DIRECTION_DOWN: p1_x_chunk_offs = r.nextInt(2); p1_y_chunk_offs = 1; break;                
        }
        switch(p2.direction) {
            case PCGWorld.DIRECTION_LEFT: p2_y_chunk_offs = r.nextInt(2); break;
            case PCGWorld.DIRECTION_UP: p2_x_chunk_offs = r.nextInt(2); break;
            case PCGWorld.DIRECTION_RIGHT: p2_y_chunk_offs = r.nextInt(2); p2_x_chunk_offs = 1; break;
            case PCGWorld.DIRECTION_DOWN: p2_x_chunk_offs = r.nextInt(2); p2_y_chunk_offs = 1; break;                
        }
        direction = a_d;
        p1.interAreaConnection = this;
        p2.interAreaConnection = this;
    }
}
