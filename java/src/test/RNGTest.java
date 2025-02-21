/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import pcg.MSXRandom;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class RNGTest {
    public static void main(String args[]) throws Exception
    {
        MSXRandom rng = new MSXRandom(0xaaaa, 0xaaaa);
        
        for(int i = 0;i<16;i++) {
            int v = rng.random();
            System.out.println(Z80Assembler.toHex16bit(v, true));
        }
    }
}
