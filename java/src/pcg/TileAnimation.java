/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class TileAnimation {
    public int x, y, width, type;
    
    
    public TileAnimation(int a_x, int a_y, int a_width, int a_type) {
        x = a_x;
        y = a_y;
        width = a_width;
        type = a_type;
    }
    
    
    public String assemblerString()
    {
        return "  db " + type + ", " + x + ", " + y + ", " + width;
    }
}
