/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package music;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.DataLine;

/**
 *
 * @author santi
 */
public class MSXSongWavGenerator {

    static int instrumentVolumeProfiles[][] = {
        {12},   // square wave
        {12,11,10,10,9,9,8,8,7,7,6},     // Piano
        {6,8,12},    // wind
        {10,9,7,7,6,6,5,5,4,4,3},     // Piano soft
        {2,4,6,8},    // wind soft
        {12,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7},     // Piano + frequency vibration
//        {12,12,12,12,11,11,11,10,10,10,9,9,9,8,8,8,7,7,7,6,6,6,5,5,5,4,4,4,3,3,3,2,2,2,1,1,1,0},     // Piano + frequency vibration
        {12,11,9,8,7,6,5,4,3,2,1,0},     // Piano Staccato
        {3,6,8,10,11,12,12,12,12,12,11,11,11,10,10,10,8,8,6,6,4},    // wind fading
        {2,6,8,12,12,12,12,12,12,11,10,9,8,7,7,6,6,6,6,5,5,5,5,5,5,5,5,4,4,4,4,4,4,4,4,3}, // pad
        {12,10,8,6,8,8,6,4,2,0}, // fade
        {6,8,12,12,12,12,10,8,6,8,8,6,4,2,0}, // shortwind
        {6,9,14,14,13,13,12,12,11,10,9,8,7,6,5,4,4,3,6,10,8,6,5,4,3,2,2,2,4,8,6,5,4,3,2,2,2,2,2,1,1,1,1,0}, // shortwindecho
        {12,11,10,10,9,9,8,7},  // major arpeggio
        {12,11,10,10,9,9,8,7},  // minor arpeggio
//        {12,8,8,6,0,0,0},  // minor arpeggio
        {12,11,10,10,9,9,8,7},  // diminished arpeggio
        {2,2,3,3,4,4,5,5,6,6,7,7,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8,8,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,6,6,5,5,5,5,4,4,4,4,3,3,2,2,1},  // minor arpeggio fadein
        {4,6,8,10,11,11,11,10,10,9,9,8,8,7,7,6,6},    // slider
        {12,11,10,10,9,9,8,8,7,7,6},  // Piano offtune
        {12,11,10,10,9,9,8,8,7,7,6},  // snap bass
        {12,11,10,10,9,9,8,8,7,7,6},  // dirty bass
//        {12,8,8,6,0,0,0},  // repeating
        {10,8,6,4,0,0,0},  // repeating
        {12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11},     // LOADED
        };
    public static HashMap<String, PSGInstrument> loadedInstruments = new HashMap<>();
    
    
    static int bits = 16;
    static double sampleRate = 22050.0;
//    static int volume_multiplier = 728;
    static Random r = new Random();
    
    public static void generateWavFile(String fileName, int tempo, MSXSong song) throws Exception
    {
        List<Integer> buffer = generateBuffer(tempo, song);
        generateWavFile(fileName, buffer);                
    }
    
    
    public static List<Integer> generateBuffer(int tempo, MSXSong song) throws Exception
    {
        int zero = 0;
       
        int samplesPerMinorTick = (int)((1/50.0)*sampleRate);
        int samplesPerTick = tempo*samplesPerMinorTick;

        HashMap<String, List<Integer>> sfx_waves = new HashMap<>();
        
        sfx_waves.put("sfx_open_hihat", 
            MSXSFX.renderSFX(new String[] 
            {   "7", "#1c",
                "10", "#0a",
                "6" , "#01",  // noise frequency (highest possible freq: ~111.860 Hz)
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#06",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#38",
                "SFX_CMD_END"
            }, 22050.0)); 
        sfx_waves.put("sfx_short_hihat", 
            MSXSFX.renderSFX(new String[] 
            {   "7", "#1c",
                "10", "#08",
                "6" , "#01",  // noise frequency (highest possible freq: ~111.860 Hz)
                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
                "10", "#06",
                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
                "10", "#04",
                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#38",
                "SFX_CMD_END"
            }, 22050.0));         
        sfx_waves.put("sfx_pedal_hihat", MSXSFX.renderSFX(new String[] 
            {   "7", "#1c",
                "10", "#05",
                "6" , "#04",  // noise frequency (~27.9 Hz)
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "MUSIC_CMD_SKIP",
                "10", "#0b",
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#38",
                "SFX_CMD_END"
            }, 22050.0));        
        
        sfx_waves.put("sfx_drum_shorter_re", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#08",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#fa", "5" , "#02",        // C freq (RE)
                "MUSIC_CMD_SKIP",
                "4" , "#20", "5" , "#03",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "10", "#06",
                "4" , "#40", 
                "MUSIC_CMD_SKIP",
                "4" , "#60", 
                "MUSIC_CMD_SKIP",
                "10", "#04",
                "4" , "#80", 
                "MUSIC_CMD_SKIP",
                "4" , "#a0", 
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"            
            
//                "7", "#98",         // A: tone, B: tone, C: tone+noise
//                "10", "#0a",        // C volume
//                "6" , "#1f",        // noise freq
//                "4" , "#fa", "5" , "#02",        // C freq (RE)
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#08",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#06",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#04",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#00",
//                "7", "#b8",
//                "SFX_CMD_END"
            }, 22050.0));    
        
        sfx_waves.put("sfx_drum_short_re", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#0a",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#fa", "5" , "#02",        // C freq (RE)
                "MUSIC_CMD_SKIP",
                "4" , "#20", "5" , "#03",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "4" , "#40", 
                "MUSIC_CMD_SKIP",
                "4" , "#60", 
                "MUSIC_CMD_SKIP",
                "10", "#06",
                "4" , "#80", 
                "MUSIC_CMD_SKIP",
                "4" , "#a0", 
                "MUSIC_CMD_SKIP",
                "10", "#04",
                "4" , "#c0", 
                "MUSIC_CMD_SKIP",
                "4" , "#e0", 
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"            
            
//                "7", "#98",         // A: tone, B: tone, C: tone+noise
//                "10", "#0a",        // C volume
//                "6" , "#1f",        // noise freq
//                "4" , "#fa", "5" , "#02",        // C freq (RE)
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#08",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#06",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#04",
//                "MUSIC_CMD_SKIP",
//                "MUSIC_CMD_SKIP",
//                "10", "#00",
//                "7", "#b8",
//                "SFX_CMD_END"
            }, 22050.0));          
        
        sfx_waves.put("sfx_drum_shorter_c", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#0b",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#ae", "5" , "#06",        // C freq (C2): 6, 174
                "MUSIC_CMD_SKIP",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"
            }, 22050.0));   

        sfx_waves.put("sfx_drum_shorter_g", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#0b",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#75", "5" , "#04",        // C freq (G1)  4, 117
                "MUSIC_CMD_SKIP",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"
            }, 22050.0)); 
        
        sfx_waves.put("sfx_drum_shorter_g#", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#0b",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#35", "5" , "#04",        // C freq (G)  4, 53
                "MUSIC_CMD_SKIP",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#08",
                "MUSIC_CMD_SKIP",
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"
            }, 22050.0));    
        
        
        sfx_waves.put("sfx_drum_shorter_f#", MSXSFX.renderSFX(new String[] 
            {   
                "7", "#98",         // A: tone, B: tone, C: tone+noise
                "10", "#0b",        // C volume
                "6" , "#18",        // noise freq
                "4" , "#73", "5" , "#09",        // C freq (f#)  9, 115
                "MUSIC_CMD_SKIP",
//                "4" , "#20", "5" , "#03",
                "7", "#b8",
                "MUSIC_CMD_SKIP",
                "10", "#06",
                "4" , "#40", 
                "MUSIC_CMD_SKIP",
                "4" , "#60", 
                "MUSIC_CMD_SKIP",
                "10", "#04",
                "4" , "#80", 
                "MUSIC_CMD_SKIP",
                "4" , "#a0", 
                "MUSIC_CMD_SKIP",
                "10", "#00",
                "7", "#b8",
                "SFX_CMD_END"
            }, 22050.0));

/*
        // step 1, get the song duration:
        int l1 = song.channelLength(0);
        int l2 = song.channelLength(1);
        int l3 = song.channelLength(2);
        int l = Math.max(l1, Math.max(l2, l3));
        
        // assuming that we run the MSX interrupt at 50Hz:
        int durationInSamples = l*samplesPerTick;
        System.out.println("Song duration: " + durationInSamples + " (" + (durationInSamples/sampleRate) + " seconds)");
        int[] buffer = new int[durationInSamples];
  */
        List<Integer> buffer = new ArrayList<>();  // since we don't know how long the song will be!

        // play the song to fill the buffer:
        int instruments[] = new int[MSXSong.N_CHANNELS];
        String instrument_name[] = new String[MSXSong.N_CHANNELS];
        int instrument_timer[] = new int[MSXSong.N_CHANNELS];  // index of the volume table
        int instrument_timer2[] = new int[MSXSong.N_CHANNELS];  // keeps increasing even after reaching the end of the volume table
        int notes[] = new int[MSXSong.N_CHANNELS];
        int channel_volume[] = {15, 15, 15};
        int volume[] = new int[MSXSong.N_CHANNELS];  // volume of the instrument (will be combined with "channel_volume" for final volume)
        int index[] = new int[MSXSong.N_CHANNELS];
        int sliderstate[] = new int[MSXSong.N_CHANNELS];
        int channelTime[] = new int[MSXSong.N_CHANNELS];
        boolean noise[] = new boolean[MSXSong.N_CHANNELS];
        boolean tone[] =  new boolean[MSXSong.N_CHANNELS];
        int noisePeriod = 1;
        String SFX = null;
        int SFX_timer = 0;
        int currentTime = 0;
        int transpose = 0;
        List<int[]> repeatStack = new ArrayList<>();
        
        for(int i = 0;i<MSXSong.N_CHANNELS;i++) {
            instruments[i] = MSXNote.INSTRUMENT_SQUARE_WAVE;
            instrument_timer[i] = 0;
            instrument_timer2[i] = 0;
            notes[i] = 0;
            volume[i] = 0;
            index[i] = 0;
            channelTime[i] = 0;
            noise[i] = false;
            tone[i] = false;
        }
        currentTime = 0;       
        while(true) {
            boolean done = true;
            boolean advanceTime = true;
            if (currentTime == song.loopBackTime) {
                System.out.println("Loop back time in samples: " + currentTime*samplesPerTick);
            }
            for(int i = 0;i<MSXSong.N_CHANNELS;i++) {
                if (index[i]<song.channels[i].size()) {
                    done = false;
                    if (currentTime >= channelTime[i]) {
                        // channel note:
                        MSXNote note = song.channels[i].get(index[i]);
                        index[i]++;
                        
                        if (note.absoluteNote==-1) {
                            // silence:
                            instruments[i] = MSXNote.INSTRUMENT_SQUARE_WAVE;
                            volume[i] = 0;
                            channelTime[i] += note.duration;
                            tone[i] = false;
                            noise[i] = false;
                        } else if (note.absoluteNote == MSXNote.SFX) {
                            // play SFX:
                            SFX = note.sfx;
                            SFX_timer = 0;
                            instruments[i] = MSXNote.INSTRUMENT_SQUARE_WAVE;
                            volume[i] = 0;
                            channelTime[i] += note.duration;
                        } else if (note.absoluteNote == MSXNote.START_REPEAT) {
                            // we push the # of repeats, and the current indexes of the channels:
                            repeatStack.add(new int[]{note.volume, index[0], index[1], index[2]});
                            System.out.println("Started repeat with repeats: " + note.volume + " ("+index[0]+", "+index[1]+", "+index[2]+")");
                        } else if (note.absoluteNote == MSXNote.END_REPEAT) {
                            int tmp[] = repeatStack.get(repeatStack.size()-1);
                            tmp[0]--;
                            if (tmp[0]<=0) {
                                repeatStack.remove(tmp);
                            } else {
                                index[0] = tmp[1];
                                index[1] = tmp[2];
                                index[2] = tmp[3];
                            }
                        } else if (note.absoluteNote == MSXNote.CLEAR_TRANSPOSE) {
                            transpose = 0;
                        } else if (note.absoluteNote == MSXNote.TRANSPOSE_UP) {
                            transpose ++;
                        } else if (note.absoluteNote == MSXNote.SET_VOLUME) {
                            channel_volume[i] = note.volume;
                        } else {
//                            System.out.println("play note in channel " + i + " at " + currentTime + " with duration " + note.duration);
                            instruments[i] = note.instrument;
                            instrument_name[i] = note.loadedInstrument;
                            instrument_timer[i] = 0;
                            instrument_timer2[i] = 0;
                            notes[i] = note.absoluteNote + transpose;
                            volume[i] = 15;
                            channelTime[i] += note.duration;
                            tone[i] = true;
                        }
                        
                        // we restart the "i" loop each time we find a note (channel 1 has priority)
                        advanceTime = false;
                        break;
                    }
                } else {
                    if (currentTime < channelTime[i]) done = false;
                }
            }
            if (done) break;
            if (advanceTime) {
                // fill the buffer with the current state:
                int startSample = currentTime * samplesPerTick;
                
                for(int channel = 0;channel<MSXSong.N_CHANNELS;channel++) {
//                for(int channel = 0;channel<1;channel++) {
                    int instrument = instruments[channel];
                    int period = MSXNote.PSGNotePeriod(notes[channel]);
                    if (channel_volume[channel] > 0) {
                        for(int j = 0;j<tempo;j++) {
//                            if (channel == 2) System.out.println("" + j);
                            if (instrument == MSXNote.INSTRUMENT_MAJOR_ARPEGGIO) {
                                // arpeggiate the note:
                                int t = instrument_timer2[channel] % 4;
                                int arpeggioTable[] = {0, 7, 4, 7};
//                                int arpeggioTable[] = {0, 2, 4, 2};  // experimental
                                period = MSXNote.PSGNotePeriod(notes[channel] + arpeggioTable[t]);
                            } else if (instrument == MSXNote.INSTRUMENT_MINOR_ARPEGGIO ||
                                       instrument == MSXNote.INSTRUMENT_MINOR_ARPEGGIO_FADEIN) {
                                // arpeggiate the note:
                                int t = instrument_timer2[channel] % 4;
//                                int arpeggioTable[] = {0, 3, 7, 3};
                                int arpeggioTable[] = {0, 7, 3, 7};
                                period = MSXNote.PSGNotePeriod(notes[channel] + arpeggioTable[t]);
                            } else if (instrument == MSXNote.INSTRUMENT_DIMINISHED_ARPEGGIO) {
                                // arpeggiate the note:
                                int t = instrument_timer2[channel] % 4;
                                int arpeggioTable[] = {0, 6, 3, 6};
                                period = MSXNote.PSGNotePeriod(notes[channel] + arpeggioTable[t]);
                            }
                            if (instrument == MSXNote.INSTRUMENT_SLIDER) {
                                // move slowly to the desired period:
                                int desired = MSXNote.PSGNotePeriod(notes[channel]);
                                period = (2 * desired + sliderstate[channel]) / 3;
//                                System.out.println("slider: " + period + "\t" + sliderstate[channel] + "\t" + desired);
                            }
                            sliderstate[channel] = period;
                            if (instrument == MSXNote.INSTRUMENT_PIANO_OFFTUNE) {
                                period = MSXNote.PSGNotePeriod(notes[channel]) + 3;
                            }
                            // instrument envelope:
                            if (instrument == MSXNote.INSTRUMENT_LOADED) {
                                // Loaded instrument:
                                PSGInstrument psgi = loadedInstruments.get(instrument_name[channel]);
                                int instrument_index = instrument_timer[channel] / (psgi.speed + 1);
                                while(instrument_index >= psgi.volume.size()) {
                                    instrument_index += psgi.repeat;
                                }
                                volume[channel] = psgi.volume.get(instrument_index);
                                instrument_timer[channel]++;
                            } else {
                                if (instrument == MSXNote.INSTRUMENT_SNAP_BASS) {
                                    if (instrument_timer[channel] == 0) {
                                        noise[channel] = true;
                                        tone[channel] = false;
                                        noisePeriod = 1;
                                    } else {
                                        noise[channel] = false;
                                        tone[channel] = true;
                                    }
                                }
                                if (instrument == MSXNote.INSTRUMENT_DIRTY_BASS) {
//                                    System.out.println("dirty bass " + j + ", " + instrument_timer[channel]);
                                    if (instrument_timer2[channel] % 2 != 0) {
                                        noise[channel] = true;
                                        tone[channel] = false;
                                        noisePeriod = 16;
                                    } else {
                                        noise[channel] = false;
                                        tone[channel] = true;
                                    }
                                }                                 
                                if (instrument == MSXNote.INSTRUMENT_PIANO_FREQUENCY_VIBRATION) {
//                                    period = MSXNote.PSGNotePeriod(notes[channel] + 12*((currentTime*tempo+j)%2));
                                    int vibratoTable[] = {0,1,1,2,2,2,1,1,
                                                          0,-1,-1,-2,-2,-2,-1,-1};  // period 16
//                                    int vibratoTable[] = {0,0,0,1,1,1,1,1,
//                                                          0,0,0,-1,-1,-1,-1,-1};  // period 16
                                    period = MSXNote.PSGNotePeriod(notes[channel] + vibratoTable[(currentTime*tempo+j)%16]);
//                                    int vibratoTable[] = {0,0,1,1, 1,2,2,2, 2,2,2,2, 2,1,1,1,
//                                                          0,0,-1,-1, -1,-2,-2,-2, -2,-2,-2,-2, -2,-1,-1,-1};
//                                    period = MSXNote.PSGNotePeriod(notes[channel] + vibratoTable[(currentTime*tempo+j)%32]);
                                }
                                if (instrumentVolumeProfiles[instrument].length > instrument_timer[channel]) {
                                    volume[channel] = instrumentVolumeProfiles[instrument][instrument_timer[channel]];
                                    instrument_timer[channel]++;
                                    if (instrument == MSXNote.INSTRUMENT_REPEATING) {
                                        instrument_timer[channel] = instrument_timer[channel] % 6;
//                                        System.out.println("repeating: " + instrument_timer[channel]);
                                    }
                                }
                            }
                            
                            instrument_timer2[channel]++;
                            
                            // Generate the wave for this channel:
                            double factor = MSXNote.PSG_Master_Frequency/sampleRate;
                            int adjusted_volume = volume[channel] - (15 - channel_volume[channel]);
                            if (adjusted_volume < 0) adjusted_volume = 0;
                            boolean val = r.nextBoolean();
                            int lastCycle = -1;
//                            System.out.println("" + noise[channel] + ", " + tone[channel]);
//                            System.out.println("channel " + channel + ", volume: " + adjusted_volume);
                            for(int k = 0;k<samplesPerMinorTick;k++) {
                                int position = startSample + j*samplesPerMinorTick + k;
                                int position_corrected = (int)(position * factor);
                                int offset = position_corrected % period;
                                int v = 0;
                                int cycle = position_corrected / noisePeriod;
                                if (noise[channel]) {
                                    if (cycle > lastCycle) val = r.nextBoolean();
                                    if (val) {
                                        v += volumeToSample(Math.max(0, adjusted_volume - 1));
                                    } else {
                                        v -= volumeToSample(Math.max(0, adjusted_volume - 1));
                                    }
                                }
                                
                                if (tone[channel]) {
                                    if (offset < period/2) {
                                        v += volumeToSample(adjusted_volume);
                                    } else {
                                        v -= volumeToSample(adjusted_volume);
                                    }
                                }
                                while(buffer.size()<=position) buffer.add(zero);
                                buffer.set(position, buffer.get(position) + v);
                                lastCycle = cycle;
                            }
                        }
                    }
                }
                for(int j = 0;j<tempo;j++) {
                    if (SFX != null) {
                        List<Integer> sfx_wave = sfx_waves.get(SFX.toLowerCase());
                        if (sfx_wave == null) {
                            throw new Exception("Unknown SFX: " + SFX);                            
                        } else {
                            int start = SFX_timer * samplesPerMinorTick;
                            if (start >= sfx_wave.size()) {
                                SFX = null;
                                SFX_timer = 0;
                            } else {
                                for(int k = 0;k<samplesPerMinorTick;k++) {
                                    int position = startSample + j*samplesPerMinorTick + k;
                                    while(buffer.size()<=position) buffer.add(zero);
                                    buffer.set(position, buffer.get(position) + sfx_wave.get(start + k));
                                }
                                SFX_timer++;
                            }
                        }
                    }
                }
                
                currentTime++;
            }
        }               
        System.out.println("Song duration: " + buffer.size() + " (" + (buffer.size()/sampleRate) + " seconds)");
        return buffer;
    }    
    
    
    public static int volumeToSample(int volume)
    {
        return (int)(8192 / Math.pow(Math.sqrt(2),15-volume));
    }
    

    public static void generateWavFile(String fileName, List<Integer> buffer) throws Exception    
    {
        // generate the wave file:
        final byte[] byteBuffer = new byte[buffer.size() * 2];
        int bufferIndex = 0;
        for (int i = 0; i < byteBuffer.length; i++) {
            int x = buffer.get(bufferIndex++);
            byteBuffer[i] = (byte) x;
            i++;
            byteBuffer[i] = (byte) (x >>> 8);
        }
        File out = new File(fileName);
        boolean bigEndian = false;
        boolean signed = true;
        int n_channels = 1;
        AudioFormat format;
        format = new AudioFormat((float)sampleRate, bits, n_channels, signed, bigEndian);
        ByteArrayInputStream bais = new ByteArrayInputStream(byteBuffer);
        AudioInputStream audioInputStream;
        audioInputStream = new AudioInputStream(bais, format, buffer.size());
        AudioSystem.write(audioInputStream, AudioFileFormat.Type.WAVE, out);
        audioInputStream.close();     
    }
    
    
    public static void playBuffer(List<Integer> buffer) throws Exception    
    {
        playBuffer(buffer, 1);
    }
            
    public static void playBuffer(List<Integer> buffer, int repetitions) throws Exception    
    {
        // generate the wave file:
        final byte[] byteBuffer = new byte[buffer.size() * 2];
        int bufferIndex = 0;
        for (int i = 0; i < byteBuffer.length; i++) {
            int x = buffer.get(bufferIndex++);
            byteBuffer[i] = (byte) x;
            i++;
            byteBuffer[i] = (byte) (x >>> 8);
        }
        boolean bigEndian = false;
        boolean signed = true;
        int n_channels = 1;
        AudioFormat format;
        format = new AudioFormat((float)sampleRate, bits, n_channels, signed, bigEndian);
        ByteArrayInputStream bais = new ByteArrayInputStream(byteBuffer);
        AudioInputStream audioInputStream;
        audioInputStream = new AudioInputStream(bais, format, buffer.size());
        
        DataLine.Info info = new DataLine.Info(Clip.class, format);
        Clip clip = (Clip) AudioSystem.getLine(info);
        clip.open(audioInputStream);
        for(int i = 0;i<repetitions;i++) {
            clip.setFramePosition(0);
            clip.start();   
            try{
                Thread.sleep(50);
                while(clip.isRunning()) {
                    Thread.sleep(1);
                }
            }catch(Exception e) {
            }
        }
    }    
}
