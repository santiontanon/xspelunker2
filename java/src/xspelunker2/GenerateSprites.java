/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package xspelunker2;

import java.awt.image.BufferedImage;
import java.io.File;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class GenerateSprites {
    public static void main(String args[]) throws Exception
    {
        extractPlayerSprites();
    }

    
    private static void extractPlayerSprites() throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/player.png"));
    }
}
