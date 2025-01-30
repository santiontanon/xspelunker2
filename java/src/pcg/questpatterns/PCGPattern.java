/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg.questpatterns;

import pcg.AreaConnection;
import pcg.AreaPoint;
import pcg.PCGWorld;
import pcg.World;

/**
 *
 * @author santi
 */
public class PCGPattern {
    
    
    public AreaPoint getConnectionDestination(World w, AreaPoint p)
    {
        for(AreaConnection c:w.connections) {
            if (c.p1.equals(p)) {
                return c.p2;
            }
            if (c.p2.equals(p)) {
                return c.p1;
            }
        }
        return null;
    }


    public int getConnectionDirection(World w, AreaPoint p)
    {
        for(AreaConnection c:w.connections) {
            if (c.p1.equals(p)) {
                return c.p2.direction;
            }
            if (c.p2.equals(p)) {
                return c.p1.direction;
            }
        }
        return PCGWorld.DIRECTION_NONE;
    }
    
}
