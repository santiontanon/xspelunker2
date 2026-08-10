/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package pcg;

import java.io.FileWriter;

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
        "TAG_COMBINATION4_LOCK",
        "TAG_BALL_LOCK",
        "TAG_IDOL_LOCK",
        "TAG_GEAR_LOCK",
        "TAG_ASTRONAUT_LOCK",
        // priority 2:
        "TAG_START",
        "TAG_ENDING",
        "TAG_MIDPOINT",
        "TAG_TELEPORTER_ATLANTIS",
        "TAG_TELEPORTER_MARS",
        "TAG_TELEPORTER_MOON",
        "TAG_BUTTON1",
        "TAG_BUTTON2",
        "TAG_BUTTON3",
        "TAG_BUTTON4",
//        "TAG_BREAKABLE_WALL1_KEY",
//        "TAG_BREAKABLE_WALL2_KEY",
//        "TAG_BREAKABLE_WALL3_KEY",
//        "TAG_BREAKABLE_WALL4_KEY",
//        "TAG_BLOCK_PUZZLE_KEY1",
//        "TAG_BLOCK_PUZZLE_KEY2",
//        "TAG_BLOCK_PUZZLE_KEY3",
//        "TAG_BLOCK_PUZZLE_KEY4",
        // Chest locks:
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
        "TAG_COMBINATION4_CLUE",
        "TAG_BALL_KEY",
        "TAG_IDOL_KEY",
        "TAG_GEAR_KEY",
        "TAG_ASTRONAUT_KEY",
        // bosses
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
        "TAG_BOSS6",
        "TAG_BOSS6_KEY",
        "TAG_BOSS6_CHESTLOCK",
        "TAG_BOSS7",
        "TAG_BOSS7_KEY",
        "TAG_BOSS7_CHESTLOCK",
        // weapons:
        "TAG_WEAPON_HAMMER",
        "TAG_WEAPON_MACUAHUITL",
        "TAG_WEAPON_SHIELD",
        "TAG_WEAPON_SLING",
        "TAG_WEAPON_BLOWGUN",
        "TAG_WEAPON_ATLATL",
        "TAG_WEAPON_RAYGUN",
        "TAG_WEAPON_OBSIDIAN_KNIVE",
        "TAG_WEAPON_FIRE_HAMMER",
        "TAG_WEAPON_ICE_MACUAHUITL",
        // map pieces:
        "TAG_MAP_PIECE1",  // pyramid 2
        "TAG_MAP_PIECE2",  // pyramid 3 + confluence
        "TAG_MAP_PIECE3",  // fire shaft + both caves
        "TAG_MAP_PIECE4",  // fire temple
        "TAG_MAP_PIECE5",  // atlantis
        "TAG_MAP_PIECE6",  // mars
        "TAG_MAP_PIECE7",  // moon
        // hearts:
        "TAG_HEART1",
        "TAG_HEART2",
        "TAG_HEART3",
        "TAG_HEART4",
        "TAG_HEART5",
        // clues/story:
        "TAG_MAYA_RIDDLE_CLUE1",
        "TAG_MAYA_RIDDLE_CLUE2",
        "TAG_MAYA_RIDDLE_CLUE3",
        "TAG_MAYA_RIDDLE_CLUE4",
        "TAG_MAYA_RIDDLE_CLUE5",
        "TAG_MAYA_RIDDLE_CLUE6",
        "TAG_MAYA_RIDDLE_CLUE7",
        "TAG_STORY_TRIVIA1",
        "TAG_STORY_TRIVIA2",
        "TAG_STORY_TRIVIA3",
        "TAG_STORY_TRIVIA4",
        "TAG_STORY_TRIVIA5",
        "TAG_STORY_TRIVIA6",
        "TAG_STORY_TRIVIA7",
        "TAG_STORY_TRIVIA8",
        // optional items:
        "TAG_ITEM_SANDALS",
        "TAG_ITEM_GLOVES",
        "TAG_ITEM_WARRIOR_HAT",
        "TAG_ITEM_ARMOR",
        "TAG_ITEM_CHAAC",
        "TAG_ITEM_SEASHELL",
        "TAG_ITEM_BELT",
        "TAG_ITEM_ICE_CAPE",        
        // small keys:
        "TAG_SMALL_KEY1",
        "TAG_SMALL_KEY2",
        "TAG_SMALL_KEY3",
        "TAG_SMALL_KEY4",
        "TAG_SMALL_KEY_CHEST1",
        "TAG_SMALL_KEY_CHEST2",
        "TAG_SMALL_KEY_CHEST3",
        "TAG_SMALL_KEY_CHEST4",
        // Teleporters:
        "TAG_TELEPORTER1",
        "TAG_TELEPORTER2",
        "TAG_TELEPORTER3",
        "TAG_TELEPORTER4",
        "TAG_TELEPORTER5",
        "TAG_TELEPORTER6",
        "TAG_TELEPORTER7",
        "TAG_TELEPORTER8",
        "TAG_TELEPORTER9",  // the one in the teleporter room
        "TAG_CALENDAR_NAME_CLUE",
        "TAG_LOST_VENDOR",
        // Xibalba tablets:
        "TAG_XIBALBA_STORY1",
        "TAG_XIBALBA_STORY2",
        "TAG_XIBALBA_STORY3",
        "TAG_XIBALBA_STORY4",
        "TAG_XIBALBA_STORY5",
        "TAG_XIBALBA_LORDS1",
        "TAG_XIBALBA_LORDS2",
        "TAG_XIBALBA_LORDS3",
        "TAG_XIBALBA_LORDS4",
        "TAG_XIBALBA_LORDS5",
        "TAG_XIBALBA_LORDS6",
        "TAG_XIBALBA_LORDS7",
        "TAG_XIBALBA_CLUE",
        // Atlantis tablets:
        "TAG_ATLANTIS_TABLET1",
        "TAG_ATLANTIS_TABLET2",
        "TAG_ATLANTIS_TABLET3",
        "TAG_ATLANTIS_TABLET4",
        "TAG_ATLANTIS_TABLET5",
        // Other:
        "TAG_8_BRIDGE_ROOM",
        "TAG_GUARDIAN_CAIMAN1",
        "TAG_GUARDIAN_CAIMAN2",
        "TAG_GUARDIAN_CAIMAN3",
        "TAG_FIRESTONE_FORGE",
        "TAG_MARS_BOSS_BREAKABLE_FLOOR",
        "TAG_MARS_ROBOT_PUZZLE",
        "TAG_BOSS_9_ROOM",
        // misc (not tags that will be placed, but used for tile-object types):
        "TAG_PUSHABLE_BLOCK",
        "TAG_DOOR_VERTICAL",
        "TAG_DOOR_HORIZONTAL",
        "TAG_DOOR_BOSS",
        "TAG_POWER_STONE",
        "TAG_CALENDAR_TABLET",
        "TAG_CALENDAR_SOCKET",
        "TAG_HALF_POWER_STONE",
        "TAG_CALENDAR_STONE_CENTER",
        "TAG_MAYA_PUZZLE_TABLET",
        "TAG_TELEPORTER_ATLANTIS_TO_MOON",
        "TAG_PUZZLEBOX_MARS",
        "TAG_PUZZLEBOX_MOON",
        "TAG_CHARYBDIS_EYE",
        "TAG_SCYLLA_EYE",
        "TAG_COIN",
        "TAG_CORN",
        "TAG_STONES",
        "TAG_DARTS",
        "TAG_SPEARS",
        "TAG_BATTERY",
        "TAG_XIBALBA_BOSS_TABLET",
        "TAG_XIBALBA_BOSS_GRAVE",
        "TAG_GOLDEN_KEY",
        "TAG_SKULL_CHARM",
        "TAG_MAYA_CODEX",
        "TAG_POSEIDON_LEVER",
        "TAG_POSEIDON_BOSS_DISPLAY",
        "TAG_ASTRONOMY_TABLET1",
        "TAG_ASTRONOMY_TABLET2",
        "TAG_WORLD_TELEPORTER",
        "TAG_GUARDIAN_CAIMAN_TABLET",
        "TAG_FIRESTONE_FORGE_TABLET",
        "TAG_FIRESTONE_FORGE_PUZZLE",
        "TAG_PHASE_SHIFTER",
        // npcs:
        "TAG_NPC_SHOPKEEPER",
        "TAG_NPC_SHOP",
        "TAG_DYNAMITE",
        "TAG_NPC_SHOPKEEPER2",
        "TAG_NPC_ELAINE",
        // enemies: (important to keep ONLY enemies after this point, as the code assumes this)
        "TAG_ENEMY_CARNIVORE_PLANT",
        "TAG_ENEMY_BEE_HIVE",
        "TAG_ENEMY_ANT_COLONY",
        "TAG_ENEMY_ANT_COLONY2",
        "TAG_ENEMY_IMP_GENERATOR",
        "TAG_ENEMY_IMP_GENERATOR2",
        "TAG_ENEMY_FIREBALL_GENERATOR",
        "TAG_ENEMY_LAVA_GENERATOR",
        "TAG_ENEMY_STONE_OWL",
        "TAG_ENEMY_SENTINEL",
        "TAG_ENEMY_UFO",
        "TAG_ENEMY_MARS_WALKER_RIGHT",
        "TAG_ENEMY_MARS_WALKER_LEFT",
        "TAG_ENEMY_MOON_LARGE_MUSHROOM",
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
    
    
    public static void generateAssemblerEnum(String path) throws Exception
    {
        FileWriter fw = new FileWriter(path);
        
        for(int i = 0;i<tags.length;i++) {
            if (tags[i].equals("TAG_PUSHABLE_BLOCK")) {
                fw.write("; tags above can ONLY appear once in the whole game\n");
                fw.write("N_UNIQUE_TAGS: equ " + i + "\n");
                fw.write("; tags below can appear multiple times (and do not have state, they are reset every time you enter in a room):\n");
            }
            fw.write(tags[i] + ": equ " + i + "\n");
        }
        fw.write("\n");
        fw.close();        
    }
    
    
    public static void main(String args[]) throws Exception
    {
        generateAssemblerEnum("src/constants-tags.asm");
    }
}
