import os
import struct

def extract_zeliard_resources(directory_file="directory.txt"):
    archives = {}

    for i in range(1, 4):
        os.makedirs(str(i), exist_ok=True)

    try:
        with open(directory_file, 'r') as f:
            for line in f:
                # 1. Clean the line: remove whitespace and any trailing periods
                clean_line = line.strip()
                if not clean_line:
                    continue

                # 2. Split by comma and clean up each piece
                parts = [p.strip() for p in clean_line.split(',')]

                # Check if we have enough parts (archive, id, name)
                if len(parts) < 3:
                    continue

                archive_idx = int(parts[0])
                # int(x, 0) automatically handles both '1' and '0x28'
                file_id = int(parts[1], 0) 
                # Remove the single quotes from the filename
                filename = parts[2].strip("'")

                archive_num = archive_idx + 1
                output_path = os.path.join(str(archive_num), filename)

                if archive_num not in archives:
                    lower_name = f"zelres{archive_num}.sar"
                    upper_name = f"ZELRES{archive_num}.SAR"
                    
                    if os.path.exists(lower_name):
                        archives[archive_num] = open(lower_name, 'rb')
                    elif os.path.exists(upper_name):
                        archives[archive_num] = open(upper_name, 'rb')
                    else:
                        print(f"Error: Could not find {lower_name} or {upper_name}")
                        continue
                archive = archives[archive_num]

                # --- Extraction Logic ---
                info_offset = (file_id - 1) * 4
                archive.seek(info_offset)
                data_offset = struct.unpack('<I', archive.read(4))[0]

                archive.seek(data_offset)
                file_length = struct.unpack('<I', archive.read(4))[0]

                archive.seek(data_offset + 4)
                file_content = archive.read(file_length)

                with open(output_path, 'wb') as out_f:
                    out_f.write(file_content)

                print(f"Extracted {filename} to /{archive_num}")

    finally:
        for a in archives.values():
            a.close()

if __name__ == "__main__":
    extract_zeliard_resources()
