/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class AreaConnection {
    public static final int BIDIRECTIONAL = 0;
    public static final int P1TOP2 = 1;
    public static final int P2TOP1 = 2;
    public AreaPoint p1, p2;
    public int direction;
    
    
    public AreaConnection(AreaPoint a_p1, AreaPoint a_p2, int a_d)
    {
        p1 = a_p1;
        p2 = a_p2;
        direction = a_d;
    }
}
