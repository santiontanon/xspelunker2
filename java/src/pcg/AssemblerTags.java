/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

/**
 *
 * @author santi
 */
public class AssemblerTags {
    // IDs correspond to the order in this array:
    public static String tags[] = {
        "TAG_NONE",
        // priority 0:
        "TAG_BLOCK_PUZZLE1",
        "TAG_BLOCK_PUZZLE2",
        "TAG_BLOCK_PUZZLE3",
        "TAG_BLOCK_PUZZLE4",
        // priority 1:
        "TAG_BUTTON_DOOR1",
        "TAG_BUTTON_DOOR2",
        "TAG_BUTTON_DOOR3",
        "TAG_BUTTON_DOOR4",
        "TAG_BREAKABLE_WALL1",
        "TAG_BREAKABLE_WALL2",
        "TAG_BREAKABLE_WALL3",
        "TAG_BREAKABLE_WALL4",
        "TAG_RED_LOCK",
        "TAG_GREEN_LOCK",
        "TAG_BLUE_LOCK",
        "TAG_YELLOW_LOCK",
        "TAG_WHITE_LOCK",
        "TAG_PURPLE_LOCK",
        "TAG_TRIAL1_LOCK",
        "TAG_TRIAL2_LOCK",
        "TAG_TRIAL3_LOCK",
        "TAG_TRIAL4_LOCK",
        "TAG_COMBINATION1_LOCK",
        "TAG_COMBINATION2_LOCK",
        "TAG_COMBINATION3_LOCK",
        "TAG_BALL_LOCK",
        "TAG_IDOL_LOCK",
        "TAG_GEAR_LOCK",
        "TAG_ASTRONAUT_LOCK",
        // priority 2:
        "TAG_START",
        "TAG_ENDING",
        "TAG_MIDPOINT",
        "TAG_BUTTON1",
        "TAG_BUTTON2",
        "TAG_BUTTON3",
        "TAG_BUTTON4",
        "TAG_BREAKABLE_WALL1_KEY",
        "TAG_BREAKABLE_WALL2_KEY",
        "TAG_BREAKABLE_WALL3_KEY",
        "TAG_BREAKABLE_WALL4_KEY",
        "TAG_BLOCK_PUZZLE_KEY1",
        "TAG_BLOCK_PUZZLE_KEY2",
        "TAG_BLOCK_PUZZLE_KEY3",
        "TAG_BLOCK_PUZZLE_KEY4",
        // Chest locks:
        "FIRST_CHEST_LOCK_TAG",
        "TAG_RED_KEY",
        "TAG_GREEN_KEY",
        "TAG_BLUE_KEY",
        "TAG_YELLOW_KEY",
        "TAG_WHITE_KEY",
        "TAG_PURPLE_KEY",
        "TAG_RED_CHEST",
        "TAG_GREEN_CHEST",
        "TAG_BLUE_CHEST",
        "TAG_YELLOW_CHEST",
        "TAG_WHITE_CHEST",
        "TAG_PURPLE_CHEST",
        // locks:
        "TAG_TRIAL1_CLUE",
        "TAG_TRIAL2_CLUE",
        "TAG_TRIAL3_CLUE",
        "TAG_TRIAL4_CLUE",
        "TAG_COMBINATION1_CLUE",
        "TAG_COMBINATION2_CLUE",
        "TAG_COMBINATION3_CLUE",
        "TAG_BALL_KEY",
        "TAG_IDOL_KEY",
        "TAG_GEAR_KEY",
        "TAG_ASTRONAUT_KEY",
        // bosses
        "FIRST_BOSS_TAG",
        "TAG_BOSS1",
        "TAG_BOSS1_KEY",
        "TAG_BOSS1_CHESTLOCK",
        "TAG_BOSS2",
        "TAG_BOSS2_KEY",
        "TAG_BOSS2_CHESTLOCK",
        "TAG_BOSS3",
        "TAG_BOSS3_KEY",
        "TAG_BOSS3_CHESTLOCK",
        "TAG_BOSS4",
        "TAG_BOSS4_KEY",
        "TAG_BOSS4_CHESTLOCK",
        "TAG_BOSS5",
        "TAG_BOSS5_KEY",
        "TAG_BOSS5_CHESTLOCK",
    };
    
    
    public static String tagToAssembler(String tag)
    {
        String tag2 = "TAG_" + tag;
        tag2 = tag2.replace("-", "_");
        tag2 = tag2.toUpperCase();
        if (tag2.startsWith("TAG_WALL")) {
            tag2 = tag2.replace("TAG_WALL", "TAG_BREAKABLE_WALL");
        }
        if (tag2.startsWith("TAG_BLOCK") && !tag2.startsWith("TAG_BLOCK_PUZZLE")) {
            tag2 = tag2.replace("TAG_BLOCK", "TAG_BLOCK_PUZZLE");
        }
        return tag2;
    }

    
    public static int assemblerID(String tag) throws Exception
    {
        tag = tagToAssembler(tag);
        for(int i = 0;i<tags.length;i++) {
            if (tag.equals(tags[i])) return i;
        }
        throw new Exception("Unknown tag " + tag);
    }
    
    
    public static void generateAssemblerEnum()
    {
        for(int i = 0;i<tags.length;i++) {
            System.out.println(tags[i] + ": equ " + i);
        }
    }
    
    
    public static void main(String args[]) throws Exception
    {
        generateAssemblerEnum();
    }
}
