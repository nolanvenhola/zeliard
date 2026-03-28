using System.Diagnostics;
using System.Text;

namespace TasmRunner;

class Program
{
    static int Main(string[] args)
    {
        Console.WriteLine("=== TASM Runner for DOSBox ===");
        Console.WriteLine();

        if (args.Length == 0 || args.Contains("--help") || args.Contains("-h"))
        {
            ShowHelp();
            return 0;
        }

        try
        {
            var config = ParseArguments(args);
            var logFile = CreateLogFile(config.LogDir);

            Log($"Starting TASM assembly at {DateTime.Now}", logFile);
            Log($"Input file: {config.AsmFile}", logFile);

            var result = RunTasmInDosBox(config, logFile);

            Log($"Assembly completed with exit code: {result}", logFile);
            Console.WriteLine($"\nLog saved to: {logFile}");

            return result;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"ERROR: {ex.Message}");
            return 1;
        }
    }

    static void ShowHelp()
    {
        Console.WriteLine("Usage: TasmRunner <asmfile> [options]");
        Console.WriteLine();
        Console.WriteLine("Arguments:");
        Console.WriteLine("  <asmfile>              Path to .asm file to assemble");
        Console.WriteLine();
        Console.WriteLine("Options:");
        Console.WriteLine("  --dosbox <path>        Path to DOSBox executable (default: ./dosbox/dosbox.exe - bundled)");
        Console.WriteLine("  --tasm <path>          Path to TASM directory (default: ./tool - bundled)");
        Console.WriteLine("  --output <path>        Output directory for .obj/.lst files (default: same as .asm)");
        Console.WriteLine("  --logdir <path>        Directory for log files (default: ./logs)");
        Console.WriteLine("  --tasm-args <args>     Additional TASM arguments (default: /l)");
        Console.WriteLine("  --tlink-args <args>    TLINK arguments (default: /c /x)");
        Console.WriteLine("  --link                 Link after assembly (default: true)");
        Console.WriteLine("  --no-link              Skip linking step");
        Console.WriteLine("  --keep-conf            Keep temporary DOSBox config file");
        Console.WriteLine("  --bin                  Strip MZ header after linking; output raw .bin instead of .exe");
        Console.WriteLine();
        Console.WriteLine("Examples:");
        Console.WriteLine("  TasmRunner test.asm");
        Console.WriteLine("  TasmRunner test.asm --output ./build --tasm-args \"/zi /l /m\"");
        Console.WriteLine("  TasmRunner test.asm --dosbox \"C:\\DOSBox-X\\dosbox-x.exe\"");
    }

    static Config ParseArguments(string[] args)
    {
        var config = new Config
        {
            AsmFile = args[0],
            DosBoxPath = "./dosbox/dosbox.exe", // DOSBox bundled with executable
            TasmPath = "./tool/tasm201", // TASM 2.01 by default (use ./tool/tasm5 for TASM 5.x)
            OutputDir = null,
            LogDir = "./logs",
            TasmArgs = "/l",
            TlinkArgs = "/c /x",
            Link = true, // Link by default
            KeepConf = false
        };

        if (!File.Exists(config.AsmFile))
            throw new Exception($"ASM file not found: {config.AsmFile}");

        for (int i = 1; i < args.Length; i++)
        {
            switch (args[i].ToLower())
            {
                case "--dosbox":
                    config.DosBoxPath = args[++i];
                    break;
                case "--tasm":
                    config.TasmPath = args[++i];
                    break;
                case "--output":
                    config.OutputDir = args[++i];
                    break;
                case "--logdir":
                    config.LogDir = args[++i];
                    break;
                case "--tasm-args":
                    config.TasmArgs = args[++i];
                    break;
                case "--tlink-args":
                    config.TlinkArgs = args[++i];
                    break;
                case "--link":
                    config.Link = true;
                    break;
                case "--no-link":
                    config.Link = false;
                    break;
                case "--keep-conf":
                    config.KeepConf = true;
                    break;
                case "--bin":
                    config.OutputBin = true;
                    break;
            }
        }

        // Default output dir to same location as asm file
        config.OutputDir ??= Path.GetDirectoryName(Path.GetFullPath(config.AsmFile)) ?? ".";

        // Resolve TASM path relative to executable location
        if (!Path.IsPathRooted(config.TasmPath))
        {
            var exeDir = AppContext.BaseDirectory;
            config.TasmPath = Path.GetFullPath(Path.Combine(exeDir, config.TasmPath));
        }

        // Resolve DOSBox path relative to executable location
        if (!Path.IsPathRooted(config.DosBoxPath))
        {
            var exeDir = AppContext.BaseDirectory;
            config.DosBoxPath = Path.GetFullPath(Path.Combine(exeDir, config.DosBoxPath));
        }

        return config;
    }

    static string CreateLogFile(string logDir)
    {
        Directory.CreateDirectory(logDir);
        var timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        var logFile = Path.Combine(logDir, $"tasm_{timestamp}.log");
        return logFile;
    }

    static void Log(string message, string logFile)
    {
        Console.WriteLine(message);
        File.AppendAllText(logFile, message + Environment.NewLine);
    }

    static int RunTasmInDosBox(Config config, string logFile)
    {
        // Convert Windows paths to DOSBox mount format
        var asmFullPath = Path.GetFullPath(config.AsmFile);
        var asmDir = Path.GetDirectoryName(asmFullPath) ?? ".";
        var asmFile = Path.GetFileName(asmFullPath);
        var outputDir = Path.GetFullPath(config.OutputDir ?? ".");

        // Create temporary DOSBox config
        var confFile = CreateDosBoxConf(config, asmDir, asmFile, outputDir);

        try
        {
            Log($"Generated DOSBox config: {confFile}", logFile);
            Log($"Running DOSBox...", logFile);
            Log("", logFile);

            // Run DOSBox
            var startInfo = new ProcessStartInfo
            {
                FileName = config.DosBoxPath,
                Arguments = $"-conf \"{confFile}\" -noconsole -exit",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            var output = new StringBuilder();
            var process = new Process { StartInfo = startInfo };

            process.OutputDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log(e.Data, logFile);
                    output.AppendLine(e.Data);
                }
            };

            process.ErrorDataReceived += (sender, e) =>
            {
                if (e.Data != null)
                {
                    Log($"[ERROR] {e.Data}", logFile);
                    output.AppendLine(e.Data);
                }
            };

            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();

            Log("", logFile);
            Log($"DOSBox exited with code: {process.ExitCode}", logFile);

            // Read TASM output from redirected log file
            var baseName = Path.GetFileNameWithoutExtension(asmFile);
            var tasmLogFile = Path.Combine(asmDir, $"tasm_output_{baseName}.txt");
            if (File.Exists(tasmLogFile))
            {
                Log("", logFile);
                Log("=== TASM Output ===", logFile);
                var tasmOutput = File.ReadAllText(tasmLogFile);
                Log(tasmOutput.TrimEnd(), logFile);
                Log("=== End TASM Output ===", logFile);
                Log("", logFile);

                // Clean up TASM log file
                try { File.Delete(tasmLogFile); } catch { }
            }

            // Check if output files were created
            var objFile = Path.Combine(outputDir, baseName + ".obj");
            var lstFile = Path.Combine(outputDir, baseName + ".lst");
            var exeFile = Path.Combine(outputDir, baseName + ".exe");
            var comFile = Path.Combine(outputDir, baseName + ".com");

            if (File.Exists(objFile))
            {
                Log($"✓ Created: {objFile}", logFile);
            }
            else
            {
                Log($"✗ Not found: {objFile}", logFile);
            }

            if (File.Exists(lstFile))
            {
                Log($"✓ Created: {lstFile}", logFile);
            }

            // Check for linked executable if linking was enabled
            if (config.Link)
            {
                if (File.Exists(exeFile))
                {
                    if (config.OutputBin)
                    {
                        // Strip MZ header: save raw code section as .bin, delete .exe
                        var binFile = Path.Combine(outputDir, baseName + ".bin");
                        ExtractBin(exeFile, binFile, logFile);
                        File.Delete(exeFile);
                    }
                    else
                    {
                        Log($"✓ Created: {exeFile}", logFile);
                        // Fix MZ header memory allocation for Sourcer-generated ASM files
                        FixMZHeader(exeFile, logFile);
                    }
                }
                else if (File.Exists(comFile))
                {
                    Log($"✓ Created: {comFile}", logFile);
                }
                else
                {
                    Log($"✗ Not found: {baseName}.exe or {baseName}.com", logFile);
                }
            }

            // Return 0 if obj file was created (and exe/com/bin if linking), 1 otherwise
            bool success = File.Exists(objFile);
            if (config.Link)
            {
                var binFile = Path.Combine(outputDir, baseName + ".bin");
                success = success && (File.Exists(exeFile) || File.Exists(comFile) || File.Exists(binFile));
            }
            return success ? 0 : 1;
        }
        finally
        {
            if (!config.KeepConf && File.Exists(confFile))
            {
                File.Delete(confFile);
                Log($"Deleted temporary config: {confFile}", logFile);
            }
        }
    }

    static string CreateDosBoxConf(Config config, string asmDir, string asmFile, string outputDir)
    {
        var confFile = Path.Combine(Path.GetTempPath(), $"dosbox_tasm_{Guid.NewGuid():N}.conf");
        var baseName = Path.GetFileNameWithoutExtension(asmFile);

        var sb = new StringBuilder();
        sb.AppendLine("[autoexec]");
        sb.AppendLine("@echo off");
        sb.AppendLine();
        sb.AppendLine("rem Mount TASM directory");
        sb.AppendLine($"mount t \"{config.TasmPath}\"");
        sb.AppendLine();
        sb.AppendLine("rem Mount working directory");
        sb.AppendLine($"mount w \"{asmDir}\"");
        sb.AppendLine();

        if (asmDir != outputDir)
        {
            sb.AppendLine("rem Mount output directory");
            sb.AppendLine($"mount o \"{outputDir}\"");
            sb.AppendLine();
        }

        sb.AppendLine("rem Add TASM to PATH");
        sb.AppendLine("set PATH=T:\\");
        sb.AppendLine();
        sb.AppendLine("rem Go to working directory");
        sb.AppendLine("w:");
        sb.AppendLine();
        sb.AppendLine("rem Run TASM");
        sb.AppendLine($"echo Assembling {asmFile}...");

        // Redirect TASM output to a log file so we can capture it
        var tasmLogFile = Path.Combine(asmDir, $"tasm_output_{baseName}.txt");

        if (asmDir != outputDir)
        {
            // Output to different directory
            sb.AppendLine($"tasm {config.TasmArgs} {asmFile}, o:\\{baseName}.obj, o:\\{baseName}.lst > \"{Path.GetFileName(tasmLogFile)}\"");
        }
        else
        {
            // Output to same directory
            sb.AppendLine($"tasm {config.TasmArgs} {asmFile} > \"{Path.GetFileName(tasmLogFile)}\"");
        }

        sb.AppendLine();
        sb.AppendLine("if errorlevel 1 goto error");
        sb.AppendLine("echo Assembly successful!");

        // Add linking step if requested
        if (config.Link)
        {
            sb.AppendLine();
            sb.AppendLine("rem Run TLINK");
            sb.AppendLine($"echo Linking {baseName}.obj...");

            if (asmDir != outputDir)
            {
                // Link from output directory
                sb.AppendLine($"tlink {config.TlinkArgs} o:\\{baseName}.obj, o:\\{baseName}.exe >> \"{Path.GetFileName(tasmLogFile)}\"");
            }
            else
            {
                // Link in same directory
                sb.AppendLine($"tlink {config.TlinkArgs} {baseName}.obj, {baseName}.exe >> \"{Path.GetFileName(tasmLogFile)}\"");
            }

            sb.AppendLine("if errorlevel 1 goto linkerror");
            sb.AppendLine("echo Linking successful!");
        }

        sb.AppendLine("goto end");
        sb.AppendLine();
        sb.AppendLine(":error");
        sb.AppendLine("echo Assembly failed!");
        sb.AppendLine("goto end");
        sb.AppendLine();

        if (config.Link)
        {
            sb.AppendLine(":linkerror");
            sb.AppendLine("echo Linking failed!");
            sb.AppendLine("goto end");
            sb.AppendLine();
        }

        sb.AppendLine(":end");
        sb.AppendLine("exit");

        File.WriteAllText(confFile, sb.ToString());
        return confFile;
    }

    static void ExtractBin(string exeFile, string binFile, string logFile)
    {
        // Strip the MZ header from a TLINK-produced EXE and write the raw code section
        // as a .bin file. Used for game.bin and driver .bin files which are loaded
        // directly into memory segments by zeliad.exe with no header.
        try
        {
            var data = File.ReadAllBytes(exeFile);
            if (data.Length < 28 || data[0] != 'M' || data[1] != 'Z')
                throw new Exception("Not a valid MZ executable");

            ushort headerParas = BitConverter.ToUInt16(data, 8);
            int headerBytes = headerParas * 16;
            var code = data[headerBytes..];

            File.WriteAllBytes(binFile, code);
            Log($"✓ Created: {binFile} ({code.Length} bytes, stripped {headerBytes}B MZ header)", logFile);
        }
        catch (Exception ex)
        {
            Log($"✗ ExtractBin failed: {ex.Message}", logFile);
        }
    }

    static void FixMZHeader(string exeFile, string logFile)
    {
        // Patch TLINK 2.01-generated MZ header to match the original Zeliard linker format.
        //
        // TLINK 2.01 differences vs the original linker used to build zeliad.exe:
        //   - Inserts a 32-byte extended header before the reloc table (reloc_table_off 0x1E->0x3E)
        //   - Omits one relocation entry (offset 0x08C6)
        //   - Adds 6 trailing zero padding bytes to the code section
        //   - Different checksum value
        //   - min_alloc / max_alloc: TLINK uses 0xFFFF; original used 0x0201
        //
        // For zeliad.exe: fully rewrite to match original format (byte-perfect).
        // For all other EXEs: fix only min_alloc / max_alloc.
        try
        {
            var data = File.ReadAllBytes(exeFile);

            if (data.Length < 28 || data[0] != 'M' || data[1] != 'Z')
                return;

            var baseName = Path.GetFileNameWithoutExtension(exeFile).ToLower();

            if (baseName == "zeliad")
            {
                PatchZeliadExe(data, exeFile, logFile);
                return;
            }

            // Generic fix: min_alloc / max_alloc only
            bool patched = false;
            ushort minAlloc = BitConverter.ToUInt16(data, 0x0A);
            ushort maxAlloc = BitConverter.ToUInt16(data, 0x0C);
            const ushort targetAlloc = 0x0201;

            if (minAlloc != targetAlloc) { BitConverter.GetBytes(targetAlloc).CopyTo(data, 0x0A); patched = true; }
            if (maxAlloc != targetAlloc) { BitConverter.GetBytes(targetAlloc).CopyTo(data, 0x0C); patched = true; }

            if (patched)
            {
                File.WriteAllBytes(exeFile, data);
                Log($"  Fixed MZ header: min/max alloc = 0x{targetAlloc:X4}", logFile);
            }
        }
        catch (Exception ex)
        {
            Log($"  Warning: Could not fix MZ header: {ex.Message}", logFile);
        }
    }

    static void PatchZeliadExe(byte[] tlink_data, string exeFile, string logFile)
    {
        // Full structural rewrite: TLINK 2.01 zeliad.exe -> original linker format.
        //
        // TLINK 2.01 output (3056 bytes):
        //   [0x00-0x1D]  MZ fixed header (reloc_table_off=0x3E, reloc_count=5)
        //   [0x1E-0x3D]  32-byte TLINK extended header (not in original)
        //   [0x3E-0x51]  Relocation table: 5 entries * 4 bytes
        //   [0x52-0x1FF] Zero padding
        //   [0x200-0x9EF] Code (2544 bytes = 2538 useful + 6 trailing zeros)
        //
        // Target (3050 bytes, original linker format):
        //   [0x00-0x1D]  MZ fixed header (reloc_table_off=0x1E, reloc_count=6)
        //   [0x1E-0x35]  Relocation table: 6 entries * 4 bytes
        //   [0x36-0x1FF] Zero padding
        //   [0x200-0x9E9] Code (2538 bytes)
        //
        // Header field values from original zeliad.exe:
        //   last_page_bytes = 0x01EA (490)  page_count = 6
        //   reloc_count = 6                 reloc_table_off = 0x1E
        //   checksum = 0x11AC               min_alloc = max_alloc = 0x0201
        //
        // Original reloc entries (offset, segment):
        //   (0x000C,0) (0x036B,0) (0x08C6,0) (0x08CA,0) (0x08CE,0) (0x08D2,0)

        const int HDR_SIZE   = 0x200;  // 512 bytes
        const int CODE_SIZE  = 2538;   // original code without trailing zeros
        const int TOTAL_SIZE = HDR_SIZE + CODE_SIZE; // 3050

        var result = new byte[TOTAL_SIZE];

        // --- Copy code section (skip trailing 6 zero bytes) ---
        if (tlink_data.Length < HDR_SIZE + CODE_SIZE)
        {
            Log("  Warning: zeliad.exe too small to patch", logFile);
            return;
        }
        Array.Copy(tlink_data, HDR_SIZE, result, HDR_SIZE, CODE_SIZE);

        // --- Build header ---
        // Copy base MZ fields from TLINK output (already has correct SS/SP/CS/IP etc.)
        Array.Copy(tlink_data, 0, result, 0, Math.Min(tlink_data.Length, HDR_SIZE));

        // Fix variable fields to match original linker
        ushort lastPage   = 490;    // 3050 % 512
        ushort pageCount  = 6;      // ceil(3050 / 512)
        ushort relocCount = 6;
        ushort relocOff   = 0x1E;
        // checksum: orig stores 0x11 at 0x12 and 0xAC at 0x13 -> LE word = 0xAC11
        ushort checksum   = 0xAC11;
        ushort allocVal   = 0x0201;

        BitConverter.GetBytes(lastPage ).CopyTo(result, 0x02);
        BitConverter.GetBytes(pageCount).CopyTo(result, 0x04);
        BitConverter.GetBytes(relocCount).CopyTo(result, 0x06);
        BitConverter.GetBytes(allocVal ).CopyTo(result, 0x0A);
        BitConverter.GetBytes(allocVal ).CopyTo(result, 0x0C);
        BitConverter.GetBytes(checksum ).CopyTo(result, 0x12);
        BitConverter.GetBytes(relocOff ).CopyTo(result, 0x18);
        result[0x1A] = 0; result[0x1B] = 0; // overlay = 0
        result[0x1C] = 1; result[0x1D] = 0; // matches original (e_res1)

        // --- Write relocation table at 0x1E ---
        // Original entries in order: (0x000C,0) (0x036B,0) (0x08C6,0) (0x08CA,0) (0x08CE,0) (0x08D2,0)
        var relocs = new (ushort off, ushort seg)[]
        {
            (0x000C, 0), (0x036B, 0), (0x08C6, 0), (0x08CA, 0), (0x08CE, 0), (0x08D2, 0)
        };
        for (int i = 0; i < relocs.Length; i++)
        {
            int pos = 0x1E + i * 4;
            BitConverter.GetBytes(relocs[i].off).CopyTo(result, pos);
            BitConverter.GetBytes(relocs[i].seg).CopyTo(result, pos + 2);
        }

        // Zero out everything after the reloc table to end of header
        // (clears TLINK extended header data copied earlier)
        int relocTableEnd = 0x1E + relocs.Length * 4; // = 0x36
        Array.Clear(result, relocTableEnd, HDR_SIZE - relocTableEnd);

        File.WriteAllBytes(exeFile, result);
        Log($"  Patched zeliad.exe: {tlink_data.Length} bytes -> {TOTAL_SIZE} bytes (original linker format)", logFile);
    }

    class Config
    {
        public string AsmFile { get; set; } = "";
        public string DosBoxPath { get; set; } = "";
        public string TasmPath { get; set; } = "";
        public string? OutputDir { get; set; }
        public string LogDir { get; set; } = "";
        public string TasmArgs { get; set; } = "";
        public string TlinkArgs { get; set; } = "";
        public bool Link { get; set; }
        public bool KeepConf { get; set; }
        public bool OutputBin { get; set; }
    }
}
