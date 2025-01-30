/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author santi
 */
public class TMXObject {
    public int x, y, dx, dy;
    public String name;
    public String type;
    
    
    public TMXObject(int a_x, int a_y, int a_dx, int a_dy, String a_name, String a_type)
    {
        x = a_x;
        y = a_y;
        dx = a_dx;
        dy = a_dy;
        name = a_name;
        type = a_type;
    }
}
