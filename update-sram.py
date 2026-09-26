import sys
from pathlib import Path

def update_sram(rom_path: str, sram_path: str):
    rom_file = Path(rom_path)
    sram_file = Path(sram_path)

    if not rom_file.exists():
        raise FileNotFoundError(f"ROM file not found: {rom_file}")
    if not sram_file.exists():
        raise FileNotFoundError(f"SRAM file not found: {sram_file}")

    # Read binary contents
    rom_data = rom_file.read_bytes()
    sram_data = bytearray(sram_file.read_bytes())

    # Verify input sizes
    if len(rom_data) < 31*16*1024:
        raise ValueError(
            f"ROM file is too small! Expected at least 491,520 bytes, got {len(rom_data)} bytes."
        )
    if len(sram_data) < 8388608:
        print(
            f"Warning: SRAM file size ({len(sram_data)} bytes) is smaller than the typical 8MB."
        )

    # Apply byte replacement strategy:
    # 1. Bytes 0 - 393,216: ROM
    sram_data[0:393216] = rom_data[0:393216]

    # 2. Bytes 393,216 - 458,752: Maintained from SRAM (no action needed)

    # 3. Bytes 458,752 - end: ROM
    sram_data[458752:31*16*1024] = rom_data[458752:31*16*1024]

    # 4. Bytes 491,520 onwards: Maintained from SRAM (no action needed)

    # Write updated contents back to the SRAM file
    sram_file.write_bytes(sram_data)
    print(f"Successfully updated '{sram_file}'!")

if __name__ == "__main__":
    # Change these filenames if necessary
    ROM_FILENAME = "xspelunker2.rom"
    SRAM_FILENAME = "/Users/santi/.openMSX/persistent/roms/xspelunker2.rom/xspelunker2.rom.SRAM"

    try:
        update_sram(ROM_FILENAME, SRAM_FILENAME)
    except Exception as e:
        print(f"Error: {e}")
