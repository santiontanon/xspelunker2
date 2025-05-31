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
            case "pushable-block":
                tx = 208; ty = 16;
                break;

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
            case "boss6-key":
                tx = 96; ty = 0;
                break;
            case "boss7-key":
                tx = 112; ty = 0;
                break;
                
            case "red-key":
                tx = 96; ty = 16;
                break;
            case "green-key":
                tx = 112; ty = 16;
                break;
            case "blue-key":
                tx = 128; ty = 16;
                break;
            case "yellow-key":
                tx = 144; ty = 16;
                break;
            case "white-key":
                tx = 160; ty = 16;
                break;
            case "purple-key":
                tx = 176; ty = 16;
                break;

            case "red-chest":
                tx = 96; ty = 32;
                break;
            case "green-chest":
                tx = 112; ty = 32;
                break;
            case "blue-chest":
                tx = 128; ty = 32;
                break;
            case "yellow-chest":
                tx = 144; ty = 32;
                break;
            case "white-chest":
                tx = 160; ty = 32;
                break;
            case "purple-chest":
                tx = 176; ty = 32;
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
                tx = 96; ty = 64;
                break;
            case "green-lock":
                tx = 112; ty = 64;
                break;
            case "blue-lock":
                tx = 128; ty = 64;
                break;
            case "yellow-lock":
                tx = 144; ty = 64;
                break;
            case "white-lock":
                tx = 160; ty = 64;
                break;
            case "purple-lock":
                tx = 176; ty = 64;
                break;

            case "trial1-clue":
            case "trial2-clue":
            case "trial3-clue":
            case "trial4-clue":
            case "combination1-clue":
            case "combination2-clue":
            case "combination3-clue":
            case "combination4-clue":
            case "maya-riddle-clue1":
            case "maya-riddle-clue2":
            case "maya-riddle-clue3":
            case "maya-riddle-clue4":
            case "story-trivia1":
            case "story-trivia2":
            case "story-trivia3":
            case "story-trivia4":
            case "story-trivia5":
            case "story-trivia6":
            case "story-trivia7":
            case "story-trivia8":       
            case "calendar-name-clue":
                tx = 96; ty = 48;
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
                tx = 192; ty = 16;
                break;

            case "door-left":
                tx = 96; ty = 80; tdy = 24;
                break;
            case "door-up":
                tx = 112; ty = 88; tdx = 32;
                break;
            case "door-right":
                tx = 96; ty = 80; tdy = 24;
                break;
            case "door-down":
                tx = 112; ty = 80; tdx = 32;
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
                
            case "heart1":
            case "heart2":
            case "heart3":
            case "heart4":
            case "heart5":
                tx = 200; ty = 0;
                break;
            case "map-piece1":
            case "map-piece2":
            case "map-piece3":
            case "map-piece4":
            case "map-piece5":
            case "map-piece6":
            case "map-piece7":
            case "map-piece8":
                tx = 80; ty = 128;
                break;
            case "WEAPON_HAMMER":
                tx = 96; ty = 128;
                break;
            case "WEAPON_MACUAHUITL":
                tx = 96; ty = 144;
                break;                
            case "WEAPON_SHIELD":
                tx = 96; ty = 160;
                break;
            case "WEAPON_SLING":
                tx = 96; ty = 176;
                break;
            case "WEAPON_BLOWGUN":
                tx = 112; ty = 176;
                break;
            case "WEAPON_ATLATL":
                tx = 128; ty = 176;
                break;
            case "WEAPON_RAYGUN":
                tx = 128; ty = 176;
                break;
            case "WEAPON_OBSIDIAN_KNIVE":
                tx = 136; ty = 112;
                break;
            case "WEAPON_FIRE_HAMMER":
                tx = 136; ty = 128;
                break;
            case "WEAPON_ICE_MACUAHUITL":
                tx = 136; ty = 144;
                break;
            case "small-key-chest1":
            case "small-key-chest2":
            case "small-key-chest3":
            case "small-key-chest4":
                tx = 232; ty = 0;
                break;
            case "small-key1":
            case "small-key2":
            case "small-key3":
            case "small-key4":
                tx = 216; ty = 0;
                break;
            case "item-sandals":
                tx = 80; ty = 16;
                break;
            case "item-gloves":
                tx = 80; ty = 32;
                break;
            case "item-hurakan":
                tx = 80; ty = 48;
                break;
            case "item-armor":
                tx = 80; ty = 64;
                break;
            case "item-chaac":
                tx = 48; ty = 48;
                break;
            case "item-seashell":
                tx = 80; ty = 80;
                break;
            case "item-belt":
                tx = 80; ty = 96;
                break;
            case "item-ice-cape":
                tx = 80; ty = 112;
                break;
            case "lever":
                tx = 224; ty = 32;
                break;
            case "boss-lock":
                tx = 192; ty = 48;
                break;
            case "boss-door":
                tx = 96; ty = 208; tdx = 32; tdy = 32;
                break;
            case "teleporter1":
            case "teleporter2":
            case "teleporter3":
            case "teleporter4":
            case "teleporter5":
            case "teleporter6":
            case "teleporter7":
            case "teleporter8":
            case "teleporter-mars":
            case "teleporter-moon":
                tx = 224; ty = 40; tdx = 32; tdy = 24;
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
