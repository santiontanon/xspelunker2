/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class MSXRandom {
    public int rng_seed1, rng_seed2;
    
    public MSXRandom(int seed1, int seed2)
    {
        rng_seed1 = seed1;
        rng_seed2 = seed2;
    }
    
    
    public void setSeed1(int seed1)
    {
        rng_seed1 = seed1;
        rng_seed2 = 0xaaaa;
    }
    

    public void setSeed(int seed1, int seed2)
    {
        rng_seed1 = seed1;
        rng_seed2 = seed2;
    }

    
    public int random()
    {
        int hl = rng_seed1;
        int bc = hl;
        hl = (hl * 4) & 0xffff;
        
        int l = hl & 0xff;
        l = (l + 1) & 0xff;
        hl = (hl & 0xff00) + l;
        hl = (hl + bc) & 0xffff;
        rng_seed1 = hl;
        hl = rng_seed2;
        hl = hl * 2;
        int carry = (hl > 0xffff ? 1:0);
        hl = hl & 0xffff;
        int a = carry * 255;
        a = a & 0x2d;
        l = hl & 0xff;
        l = a ^ l;
        hl = (hl & 0xff00) + l;
        rng_seed2 = hl;
        hl = (hl + bc) & 0xffff;
        return hl;
    }
    
    
    public boolean nextBoolean()
    {
        return (random() & 0x0001) == 0;
    }
    
    
    public int nextInt(int limit)
    {
        return random() % limit;
    }
}
