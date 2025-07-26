/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class AreaPoint {
    public Area a;
    public int x, y;

    public int direction;  // not considered for equality check
    public InterAreaConnection interAreaConnection = null;  // if the direction is through an area connection

    
    public AreaPoint(Area a_a, int a_x, int a_y)
    {
        a = a_a;
        x = a_x;
        y = a_y;
        direction = PCGWorld.DIRECTION_NONE;
    }


    public AreaPoint(Area a_a, int a_x, int a_y, int a_direction)
    {
        a = a_a;
        x = a_x;
        y = a_y;
        direction = a_direction;
    }
    
    
    public int offset()
    {
        return x + y * a.width;
    }
    
    
    @Override
    public String toString()
    {
        return "AreaPoint(" + a.ID + ", " + x + ", " + y + ")";
    }
    
    
    @Override
    public boolean equals(Object o)
    {
        AreaPoint p = (AreaPoint)o;
        return p.a == a && p.x == x && p.y == y;
    }
}
