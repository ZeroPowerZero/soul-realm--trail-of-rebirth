import wave, math, struct
import os, random

dest_dir = r"d:\GODOT PROJECTS\soul-realm--trail-of-rebirth\assets\new_audio"
os.makedirs(dest_dir, exist_ok=True)

def generate_spell_sound():
    f = wave.open(os.path.join(dest_dir, "spell_cast.wav"), "w")
    f.setnchannels(1)
    f.setsampwidth(2)
    f.setframerate(44100)
    for i in range(int(44100 * 1.5)): # 1.5 sec
        t = i / 44100.0
        # Multi-tone ethereal chime
        freq1 = 600 + (math.sin(t * 15) * 200)
        freq2 = 1200 + (math.cos(t * 20) * 300)
        freq3 = 2400
        
        v = (math.sin(2 * math.pi * freq1 * t) + 
             math.sin(2 * math.pi * freq2 * t) + 
             math.sin(2 * math.pi * freq3 * t)) / 3.0
        
        env = math.exp(-t * 2) # smooth decay
        # Add magic "shimmer" noise
        noise = random.uniform(-1, 1) * math.exp(-t * 4) * 0.2
        
        val = int((v + noise) * env * 24000)
        # Ensure clipping doesn't wrap
        val = max(-32768, min(32767, val))
        f.writeframesraw(struct.pack("<h", val))
    f.close()

def generate_click_sound():
    f = wave.open(os.path.join(dest_dir, "click.wav"), "w")
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(44100)
    for i in range(4410): # 0.1 sec
        t = i / 44100.0
        # A soft pleasant UI pop
        v = math.sin(2 * math.pi * 800 * t)
        env = math.exp(-t * 40)
        val = int(v * env * 20000)
        f.writeframesraw(struct.pack("<h", val))
    f.close()

def generate_epic_bgm():
    f = wave.open(os.path.join(dest_dir, "epic_bgm.wav"), "w")
    f.setnchannels(1); f.setsampwidth(2); f.setframerate(44100)
    
    bpm = 110
    # minor arpeggio sequence
    notes = [440.0 * (2**((i-9)/12)) for i in [0, 3, 7, 10, 12, 10, 7, 3, 5, 8, 12, 15, 12, 8, 5, 0]]
    bass_notes = [440.0 * (2**((i-33)/12)) for i in [0, 0, 0, 0, 5, 5, 5, 5]]
    
    length_frames = int(44100 * (60.0 / bpm) * 16) # 4 bars looping
    for i in range(length_frames):
        t = i / 44100.0
        beat = (t * bpm / 60.0) * 4 # 16th notes
        
        idx = int(beat) % len(notes)
        freq = notes[idx]
        b_freq = bass_notes[int(beat/8) % len(bass_notes)]
        
        # Envelopes
        env = math.exp(-(beat % 1) * 3)
        b_env = math.exp(-((beat/8) % 1) * 1.5)
        
        # Synth (Arp is a mix of square and sine)
        sq = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        si = math.sin(2 * math.pi * freq * t)
        v1 = (sq * 0.4 + si * 0.6) * env * 0.3
        
        # Bass is a sawtooth
        v2 = (2.0 * (b_freq * t - math.floor(0.5 + b_freq * t))) * b_env * 0.4
        
        val = int((v1 + v2) * 18000)
        val = max(-32768, min(32767, val))
        
        f.writeframesraw(struct.pack("<h", val))
    f.close()

generate_spell_sound()
generate_click_sound()
generate_epic_bgm()
print("Custom SFX and BGM generated successfully in assets/new_audio!")
