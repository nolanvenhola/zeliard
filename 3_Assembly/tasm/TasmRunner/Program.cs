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
        // Patch TLINK-generated MZ header to match the original Zeliard EXE.
        //
        // TLINK 2.01 produces slightly different header values than the linker
        // used to build the original zeliad.exe:
        //   - min_alloc / max_alloc: TLINK uses 0xFFFF for max; original used 0x0201
        //   - reloc_table_off: TLINK 2.01 puts it at 0x3E; original was 0x1E
        //   - reloc_count / last_page_bytes: minor version differences
        //
        // We fix min_alloc and max_alloc (straightforward patch).
        // reloc_table_off, reloc_count, and last_page_bytes are TLINK version
        // artifacts that cannot be corrected without rewriting the reloc table.
        try
        {
            var data = File.ReadAllBytes(exeFile);

            if (data.Length < 28 || data[0] != 'M' || data[1] != 'Z')
                return; // Not a valid MZ executable

            bool patched = false;

            // Fix min_alloc (offset 0x0A) — TLINK leaves this as code-size derived;
            // original zeliad.exe uses 0x0201 (513 paragraphs = stack 512 + 1)
            ushort minAlloc = BitConverter.ToUInt16(data, 0x0A);
            ushort maxAlloc = BitConverter.ToUInt16(data, 0x0C);
            const ushort targetAlloc = 0x0201;

            if (minAlloc != targetAlloc)
            {
                BitConverter.GetBytes(targetAlloc).CopyTo(data, 0x0A);
                patched = true;
            }
            if (maxAlloc != targetAlloc)
            {
                BitConverter.GetBytes(targetAlloc).CopyTo(data, 0x0C);
                patched = true;
            }

            if (patched)
            {
                File.WriteAllBytes(exeFile, data);
                Log($"  → Fixed MZ header: min/max alloc = 0x{targetAlloc:X4} ({targetAlloc} paragraphs)", logFile);
            }
        }
        catch (Exception ex)
        {
            Log($"  Warning: Could not fix MZ header: {ex.Message}", logFile);
        }
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
