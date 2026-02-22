/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import pcg.MSXRandom;
import pcg.PCGArea;
import pcg.RoomChunk;
import util.TMXObject;

/**
 *
 * @author santi
 */
public class PatternVerification {
    public static void main(String args[]) throws Exception
    {
        MSXRandom r = new MSXRandom(0, 0xaaaa);
//        PCGArea pcg2 = new PCGArea(true, "pyramid");
//        PCGArea pcg2 = new PCGArea(true, "jungle");
//        PCGArea pcg2 = new PCGArea(true, "caves");
//        PCGArea pcg2 = new PCGArea(true, "xibalba");
        PCGArea pcg2 = new PCGArea(true, "atlantis");
        
        for(int i = 0;i<16;i++) {
            for(RoomChunk c:pcg2.fg_chunks.get(i)) {
                TMXObject o = c.randomObject("item", r);
                if (o == null) {
                    throw new Exception("No item locations! in " + c.path);
                }
                o = c.randomObject("big-item", r);
                if (o == null) {
                    System.out.println(c.path + ": " + false);
                } else {
                    System.out.println(c.path + ": " + true);
                }
                for(TMXObject o2:c.locations) {
                    if (o2.type.equals("breakable-down") && (o2.y + o2.dy) != 96) {
                        System.err.println("Wrong breakable-down in " + c.path);
                    }
                    if (o2.type.equals("breakable-up") && o2.y != 0) {
                        System.err.println("Wrong breakable-up in " + c.path);
                    }
                    if (o2.type.equals("breakable-left") && o2.x != 0) {
                        System.err.println("Wrong breakable-left in " + c.path);
                    }
                    if (o2.type.equals("breakable-right") && (o2.x + o2.dx) != 128) {
                        System.err.println("Wrong breakable-right in " + c.path);
                    }
                    if (o2.type.equals("door-down") && (o2.y + o2.dy) != 96) {
                        System.err.println("Wrong door-down in " + c.path);
                    }
                    if (o2.type.equals("door-up") && o2.y != 0) {
                        System.err.println("Wrong door-up in " + c.path);
                    }
                    if (o2.type.equals("door-left") && o2.x != 0) {
                        System.err.println("Wrong door-left in " + c.path);
                    }
                    if (o2.type.equals("door-right") && (o2.x + o2.dx) != 128) {
                        System.err.println("Wrong door-right in " + c.path);
                    }
                }

//                if (o == null) {
//                    throw new Exception("No big item locations in " + c.path);
//                }
            }
        }
    }
}
