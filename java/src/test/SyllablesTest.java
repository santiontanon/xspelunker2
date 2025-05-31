/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package test;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.imageio.ImageIO;
import javax.swing.JFrame;
import pcg.MSXRandom;
import pcg.PCGWorld;
import util.Pair;

/**
 *
 * @author santi
 */
public class SyllablesTest {
    public static MSXRandom r = new MSXRandom(1000, 1000);
    public static List<Syllable> syllables = new ArrayList<>();
    public static int NAMETABLE_WIDTH = 64;
    
    
//    public static HashMap<String, Integer> byRuleStats = new HashMap<>();
    public static HashMap<String, Integer> syllableStats = new HashMap<>();

    
    public static class Syllable
    {
        public int type, connections;
        public int tiles[];
        public String text;
        
        public Syllable(int a_type, int a_connections, int a_tiles[], String a_text)
        {
            type = a_type;
            connections = a_connections;
            tiles = a_tiles;
            text = a_text;
        }
    }
    
    
    public static void main(String args[]) throws Exception
    {
        BufferedImage sourceImage = ImageIO.read(new File("data/maya-syllables-tiles.png"));
        int nameTable[] = new int[NAMETABLE_WIDTH*48];
        for(int i = 0;i<NAMETABLE_WIDTH*48;i++) nameTable[i] = 0;
        
        syllables.add(new Syllable(0x33, 0x0c, new int[]{38, 39, 40, 54, 55, 56, 70, 71, 72}, "ke"));
        syllables.add(new Syllable(0x33, 0x0d, new int[]{83, 84, 85, 99, 100, 101, 115, 116, 117}, "ja"));
        syllables.add(new Syllable(0x33, 0x0f, new int[]{86, 87, 88, 102, 103, 104, 118, 119, 120}, "chu"));
        syllables.add(new Syllable(0x33, 0x07, new int[]{90, 91, 92, 106, 107, 108, 122, 123, 124}, "e"));
        syllables.add(new Syllable(0x33, 0x07, new int[]{128, 129, 130, 144, 145, 146, 160, 161, 162}, "pe"));
        syllables.add(new Syllable(0x33, 0x0d, new int[]{131, 132, 133, 147, 148, 149, 163, 164, 165}, "lu"));        

        syllables.add(new Syllable(0x32, 0x0d, new int[]{57, 58, 59, 73, 74, 75}, "se"));        
        syllables.add(new Syllable(0x32, 0x0d, new int[]{44, 45, 46, 60, 61, 62}, "cha"));        
        syllables.add(new Syllable(0x32, 0x0d, new int[]{96, 97, 98, 112, 113, 114}, "ka"));        

        syllables.add(new Syllable(0x31, 0x01, new int[]{41, 42, 43}, "ki"));        
        syllables.add(new Syllable(0x31, 0x05, new int[]{134, 135, 136}, "le"));        
        syllables.add(new Syllable(0x31, 0x05, new int[]{150, 151, 152}, "ne"));        
        syllables.add(new Syllable(0x31, 0x05, new int[]{166, 167, 168}, "ya"));        
        syllables.add(new Syllable(0x31, 0x05, new int[]{76, 77, 78}, "na"));        
        syllables.add(new Syllable(0x31, 0x05, new int[]{80, 81, 82}, "ko"));

        syllables.add(new Syllable(0x23, 0x0a, new int[]{32, 33, 48, 49, 64, 65}, "ba"));

        syllables.add(new Syllable(0x22, 0x0d, new int[]{34, 35, 50, 51}, "la"));
        syllables.add(new Syllable(0x22, 0x0d, new int[]{36, 37, 52, 53}, "pu"));
        syllables.add(new Syllable(0x22, 0x0f, new int[]{110, 111, 126, 127}, "ba"));

        syllables.add(new Syllable(0x21, 0x04, new int[]{66, 67}, "ma"));
        syllables.add(new Syllable(0x21, 0x05, new int[]{68, 69}, "wa"));
        syllables.add(new Syllable(0x21, 0x05, new int[]{94, 95}, "t'a"));
        
        syllables.add(new Syllable(0x13, 0x02, new int[]{47, 63, 79}, "a"));
        syllables.add(new Syllable(0x13, 0x08, new int[]{89, 105, 121}, "mu"));
        syllables.add(new Syllable(0x13, 0x08, new int[]{93, 109, 125}, "bu"));

        
        // render to the name table:
        for(int i = 0;i<16;i++) {        
            for(int j = 0;j<8;j++) {
                System.out.println(generateSyllableWordMinLength(nameTable, j*8, i * 3, 5).left);
            }
        }

        // render the name table:
        JFrame w = new JFrame() {
            @Override
            public void paint(Graphics g) {
                Graphics2D g2d = (Graphics2D)g;
                g2d.setColor(Color.LIGHT_GRAY);
                for(int i = 0;i<48;i++) {
                    for(int j = 0;j<NAMETABLE_WIDTH;j++) {
                        int tile = nameTable[j + i*NAMETABLE_WIDTH];
                        int x = (tile%16) * 8;
                        int y = (tile/16) * 8;
                        g2d.drawImage(sourceImage, 32 + j*8, 32 + i*8,
                                                   32 + j*8 + 8, 32 + i*8 + 8,
                                                   x, y, x + 8, y + 8, null);
                    }
                }
            }
        };
        w.setSize(new Dimension(640, 512));
        w.setVisible(true);
        w.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        
        int maxWidth = 0;
        int maxWord = 0;
        for(int i = 0;i<10000;i++) {
            int nameTable2[] = new int[NAMETABLE_WIDTH*24];
            Pair<String, Integer> tmp = generateSyllableWordMinLength(nameTable2, 0, 0, 5);
            if (tmp.left.length() > maxWord) {
                maxWord = tmp.left.length();
            }
            if (tmp.right > maxWidth) {
                maxWidth = tmp.right;
            }
        }
        System.out.println("maxWidth: " + maxWidth);
        System.out.println("maxWord: " + maxWord);
        
        System.out.println("-------------");
        for(String s:syllableStats.keySet()) {
            System.out.println(s + ": " + syllableStats.get(s));
        }
    }
    
    
    public static Pair<String, Integer> generateSyllableWordMinLength(int nameTable[], int x, int y, int minLength)
    {
        String word = "";
//        int startx = x;
//        while(word.length() < minLength) {
//        while(x - startx < minLength) {
//            Pair<String, Integer> output = sampleFromGrammar(nameTable, x, y);
//            System.out.println("  " + x + ": " + output.left);
//            word += output.left;
//            x = output.right;
//        }

        // just sample twice:
        Pair<String, Integer> output = sampleFromGrammar(nameTable, x, y);
        word += output.left;
        x = output.right;
        output = sampleFromGrammar(nameTable, x, y);
        word += output.left;
        x = output.right;

        return new Pair<>(word, x);
    }

    
    public static Pair<String, Integer> generateSyllableWord(int nameTable[], int x, int y)
    {
        String word = "";
        
        Pair<String, Integer> output = sampleFromGrammar(nameTable, x, y);
        word += output.left;
        x = output.right;
        
        return new Pair<>(word, x);
    }
    
    
    public static Pair<String, Integer> sampleFromGrammar(int nameTable[], int x, int y)
    {
        // Can generate glyphs between 2 - 5 tiles wide

        String word = "";
        
        int constraint = 0;
        if (r.nextInt(16) == 0) {
            // sample a prefix:
            Syllable s = sampleSyllable(0x13, PCGWorld.DIRECTION_RIGHT);
            if (s != null) {
                word += s.text;
                renderSyllable(nameTable, x, y, s);
                constraint |= PCGWorld.DIRECTION_LEFT;
                x += 1;
            }
        }
        
        int ruleWeights[] = new int[]{4, 4, 4, 2, 3, 3};
        int rule = sampleFromDistribution(ruleWeights);
        Pair<String, Integer> output = null;
        switch(rule) {
            case 0: // rule 1: 3x3 [-R-> 3x1]
                output = sampleFromGrammarRule1(nameTable, x, y, constraint);  // 3 - 4
                break;
            case 1: // rule 2: 3x2 -D-> 3x1 [-R-> 3x1]
                output = sampleFromGrammarRule2(nameTable, x, y, constraint);  // 3 - 4
                break;
            case 2: // rule 3: 3x1 -D-> 3x2 [-R-> 1x3]
                output = sampleFromGrammarRule3(nameTable, x, y, constraint);  // 3 - 4
                break;
            case 3: // rule 4: 2x3 [-R-> 3x1]
                output = sampleFromGrammarRule4(nameTable, x, y, constraint);  // 2 - 3
                break;
            case 4: // rule 5: 2x2 -D-> 2x1 [-R-> 3x1]
                output = sampleFromGrammarRule5(nameTable, x, y, constraint);  // 2 - 3
                break;
            case 5: // rule 6: 2x1 -D-> 2x2 [-R-> 3x1]
                output = sampleFromGrammarRule6(nameTable, x, y, constraint);  // 2 - 3
                break;
            default:
                System.err.println("sampleFromGrammar: We should not be here!");
        }
        if (output != null) {
            word += output.left;
            x = output.right;
        }        
        return new Pair<>(word, x);
    }
    
    
    public static Pair<String, Integer> sampleFromGrammarRule1(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 1");
        // [1x3 -R->] 3x3 [-R-> 3x1]
        String word = "";
        // add a 3x3:
        Syllable s = sampleSyllable(0x33, constraint);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        x += 3;
        if (r.nextInt(4) == 0 && (s.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            if (s != null) {
                word += s.text;
                renderSyllable(nameTable, x, y, s);
                x += 1;
            }
        }
        return new Pair<>(word, x);
    }


    public static Pair<String, Integer> sampleFromGrammarRule2(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 2");
        // [1x3 -R->] 3x2 -D-> 3x1 [-R-> 3x1]
        String word = "";
        // add a 3x2:
        Syllable s1 = sampleSyllable(0x32, constraint | PCGWorld.DIRECTION_DOWN);
        word += s1.text;
        renderSyllable(nameTable, x, y, s1);
        y += 2;
        // add a 3x1:
        Syllable s = sampleSyllable(0x31, PCGWorld.DIRECTION_UP);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        y -= 2;
        x += 3;
        if (r.nextInt(4) == 0 && (s1.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            word += s.text;
            renderSyllable(nameTable, x, y, s);
            x += 1;
        }
        return new Pair<>(word, x);
    }
    
    
    public static Pair<String, Integer> sampleFromGrammarRule3(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 3");
        // [1x3 -R->] 3x2 -D-> 3x1 [-R-> 3x1]
        String word = "";
        // add a 3x1:
        Syllable  s = sampleSyllable(0x31, PCGWorld.DIRECTION_DOWN);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        y += 1;
        // add a 3x2:
        Syllable s1 = sampleSyllable(0x32, constraint | PCGWorld.DIRECTION_UP);
        word += s1.text;
        renderSyllable(nameTable, x, y, s1);
        y -= 1;
        x += 3;
        if (r.nextInt(4) == 0 && (s1.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            word += s.text;
            renderSyllable(nameTable, x, y, s);
            x += 1;
        }
        return new Pair<>(word, x);
    }    
    
    
    public static Pair<String, Integer> sampleFromGrammarRule4(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 4");
        // [1x3 -R->] 2x3 [-R-> 3x1]
        String word = "";
        // add a 2x3:
        Syllable s = sampleSyllable(0x23, constraint);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        x += 2;
        if (r.nextInt(4) == 0 && (s.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            word += s.text;
            renderSyllable(nameTable, x, y, s);
            x += 1;
        }
        return new Pair<>(word, x);
    }
    
    
    public static Pair<String, Integer> sampleFromGrammarRule5(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 5");
        // [1x3 -R->] 2x2 -D-> 2x1 [-R-> 3x1]
        String word = "";
        // add a 2x2:
        Syllable s1 = sampleSyllable(0x22, constraint);
        word += s1.text;
        renderSyllable(nameTable, x, y, s1);
        y += 2;
        // add a 2x1:
        Syllable s = sampleSyllable(0x21, PCGWorld.DIRECTION_UP);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        y -= 2;
        x += 2;
        if (r.nextInt(4) == 0 && (s1.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            word += s.text;
            renderSyllable(nameTable, x, y, s);
            x += 1;
        }
        return new Pair<>(word, x);
    }
    
    
    public static Pair<String, Integer> sampleFromGrammarRule6(int nameTable[], int x, int y, int constraint)
    {
//        System.out.println("rule 6");
        // [1x3 -R->] 2x1 -D-> 2x2 [-R-> 3x1]
        String word = "";
        // add a 2x1:
        Syllable s = sampleSyllable(0x21, PCGWorld.DIRECTION_DOWN);
        word += s.text;
        renderSyllable(nameTable, x, y, s);
        y += 1;
        // add a 2x2:
        Syllable s1 = sampleSyllable(0x22, PCGWorld.DIRECTION_UP | constraint);
        word += s1.text;
        renderSyllable(nameTable, x, y, s1);
        y -= 1;
        x += 2;
        if (r.nextInt(4) == 0 && (s1.connections & PCGWorld.DIRECTION_RIGHT) != 0) {
            // sample a postfix:
            s = sampleSyllable(0x13, PCGWorld.DIRECTION_LEFT);
            word += s.text;
            renderSyllable(nameTable, x, y, s);
            x += 1;
        }
        return new Pair<>(word, x);
    }
    
    
    public static Syllable sampleSyllable(int type, int constraint)
    {
        List<Syllable> candidates = new ArrayList<>();
        for(Syllable s:syllables) {
            if (s.type == type && (s.connections & constraint) == constraint) {
                candidates.add(s);
            }
        }
        if (candidates.isEmpty()) {
            System.err.println("no candidates!");
            return null;
        }
        int choice = r.nextInt(candidates.size());
        Syllable s = candidates.get(choice);
        if (!syllableStats.containsKey(s.text)) {
            syllableStats.put(s.text, 0);
        }
        syllableStats.put(s.text, syllableStats.get(s.text) + 1);
        return s;
    }
    
    
    public static void renderSyllable(int nameTable[], int x, int y, Syllable s)
    {
        int h = s.type&0x0f;
        int w = (s.type&0xf0) >> 4;
        for(int i = 0;i<h;i++) {
            for(int j = 0;j<w;j++) {
                nameTable[x+j + (y+i) * NAMETABLE_WIDTH] = s.tiles[j+i*w];
            }
        }
    }
    
        
    public static int sampleFromDistribution(int []weights)
    {
        int total = 0;
        for(int i = 0;i<weights.length;i++) {
            total += weights[i];
        }
        int point = r.nextInt(total);
        for(int i = 0;i<weights.length;i++) {
            if (point < weights[i]) return i;
            point -= weights[i];
        }
        return weights.length - 1;
    }
    

}
