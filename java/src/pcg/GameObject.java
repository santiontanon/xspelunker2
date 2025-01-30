/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class GameObject {
    public static BufferedImage gfx = null;

    public int x, y, dx, dy;
    public String type;    
    
    
    public GameObject(int a_x, int a_y, String a_type)
    {
        x = a_x;
        y = a_y;
        dx = 16;
        dy = 16;
        type = a_type;
    }
    
    
    public GameObject(int a_x, int a_y, int a_dx, int a_dy, String a_type)
    {
        x = a_x;
        y = a_y;
        dx = a_dx;
        dy = a_dy;
        type = a_type;
    }
    
    
    public void draw(Graphics2D g)
    {
        if (gfx == null) {
            File f = new File("data/objects.png");
            try {
                gfx = ImageIO.read(f);
            } catch (IOException ex) {
                return;
            }
        }
        
        int tx = 0;
        int ty = 0;
        int tdx = 16, tdy = 16;
        int offs_y = 0;
        boolean drawOutline = false;
        switch(type) {
            case "boss1-key":
                tx = 16; ty = 0;
                break;
            case "boss2-key":
                tx = 32; ty = 0;
                break;
            case "boss3-key":
                tx = 48; ty = 0;
                break;
            case "boss4-key":
                tx = 64; ty = 0;
                break;
            case "boss5-key":
                tx = 80; ty = 0;
                break;
                
            case "red-key":
                tx = 96; ty = 0;
                break;
            case "green-key":
                tx = 112; ty = 0;
                break;
            case "blue-key":
                tx = 128; ty = 0;
                break;
            case "yellow-key":
                tx = 144; ty = 0;
                break;
            case "purple-key":
                tx = 160; ty = 0;
                break;
            case "white-key":
                tx = 176; ty = 0;
                break;

            case "red-chest":
                tx = 96; ty = 16;
                break;
            case "green-chest":
                tx = 112; ty = 16;
                break;
            case "blue-chest":
                tx = 128; ty = 16;
                break;
            case "yellow-chest":
                tx = 144; ty = 16;
                break;
            case "purple-chest":
                tx = 160; ty = 16;
                break;
            case "white-chest":
                tx = 176; ty = 16;
                break;
            case "gear-key":
                tx = 0; ty = 32;
                break;
            case "ball-key":
                tx = 16; ty = 16;
                break;
            case "idol-key":
                tx = 32; ty = 16;
                break;
            case "astronaut-key":
                tx = 48; ty = 16;
                break;
            case "gear-lock":
                tx = 0; ty = 48;
                tdy = 24;
                tdx = 32;
                break;
            case "ball-lock":
                tx = 16; ty = 32;
                break;
            case "idol-lock":
                tx = 32; ty = 32;
                tdx = 32;
                offs_y = 8;
                break;
            case "astronaut-lock":
                tx = 64; ty = 16;
                break;                
            case "red-lock":
                tx = 96; ty = 48;
                break;
            case "green-lock":
                tx = 112; ty = 48;
                break;
            case "blue-lock":
                tx = 128; ty = 48;
                break;
            case "yellow-lock":
                tx = 144; ty = 48;
                break;
            case "purple-lock":
                tx = 160; ty = 48;
                break;
            case "white-lock":
                tx = 176; ty = 48;
                break;

            case "trial1-clue":
            case "trial2-clue":
            case "trial3-clue":
            case "trial4-clue":
            case "combination1-clue":
            case "combination2-clue":
            case "combination3-clue":
            case "combination4-clue":
                tx = 96; ty = 32;
                break;
                
            case "breakable-left":
            case "breakable-up":
            case "breakable-right":
            case "breakable-down":
                drawOutline = true;
                tdx = dx;
                tdy = dy;
                break;
                
            case "button1":
            case "button2":
            case "button3":
            case "button4":
                tx = 192; ty = 0;
                break;

            case "door-left":
                tx = 96; ty = 64; tdy = 24;
                break;
            case "door-up":
                tx = 112; ty = 72; tdx = 24;
                break;
            case "door-right":
                tx = 88; ty = 64; tdy = 24;
                break;
            case "door-down":
                tx = 112; ty = 64; tdx = 24;
                break;

            case "trial1-lock":
                tx = 0; ty = 72; tdx = 32; tdy = 32;
                break;
            case "trial2-lock":
                tx = 32; ty = 72; tdx = 32; tdy = 32;
                break;
            case "trial3-lock":
                tx = 0; ty = 104; tdx = 32; tdy = 32;
                break;
            case "trial4-lock":
                tx = 32; ty = 104; tdx = 32; tdy = 32;
                break;

            default:
                System.err.println("Cannot render placed object: " + type);
        }
        
        if (drawOutline) {
            g.setColor(Color.red);
            g.drawRect(RoomChunk.start_x + x, RoomChunk.start_y + y, tdx, tdy);
        } else {
            g.drawImage(gfx, RoomChunk.start_x + x,
                             RoomChunk.start_y + y + offs_y,
                             RoomChunk.start_x + x + tdx,
                             RoomChunk.start_y + y + offs_y + tdy,
                             tx, ty, tx + tdx, ty + tdy, null);
        }
        
    }

}
