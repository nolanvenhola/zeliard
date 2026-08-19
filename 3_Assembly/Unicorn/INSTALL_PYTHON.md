# Python + pip Installation for Windows

**Issue**: Python installed but pip is missing

---

## Option 1: Reinstall Python (Recommended - 5 minutes)

### Download Python
1. Go to https://www.python.org/downloads/windows/
2. Download **Python 3.12.x** (latest stable)
3. Run the installer

### CRITICAL Installation Steps
✅ **Check "Add python.exe to PATH"**
✅ **Check "Install pip"** (under "Optional Features")
✅ **Check "Add Python to environment variables"**

### Click "Customize installation" if needed to ensure pip is selected

### Verify After Install
```powershell
python --version
# Should show: Python 3.12.x

pip --version
# Should show: pip 24.x
```

---

## Option 2: Install pip Manually (If Python already installed)

### Method A: Using ensurepip (2 minutes)
```powershell
python -m ensurepip --upgrade
python -m pip --version
```

### Method B: Download get-pip.py (3 minutes)
```powershell
# Download pip installer
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

# Install pip
python get-pip.py

# Verify
pip --version
```

---

## After pip is Installed

```powershell
# Install Unicorn Engine
pip install unicorn-engine

# Test it works
python -c "from unicorn import *; print('Ready!')"

# Run extraction
cd c:\Projects\Zeliard\Tools
python extract_constants.py
```

---

## Alternative: Use Python from Microsoft Store

1. Open Microsoft Store
2. Search "Python 3.12"
3. Click Install (includes pip automatically)
4. Restart terminal
5. Run `python --version` and `pip --version`

This is often the easiest option on Windows!

---

## Skip Python Entirely?

If Python installation is problematic, we can:

**Plan B**: Continue C/WebAssembly development without extraction
- Current physics constants are tuned and playable
- ~90% accurate to DOS behavior
- Can extract constants later when needed

**Recommended**: Install Python from Microsoft Store (easiest), but if it's taking too long, continue with Phase 4 (Combat) and come back to this later.
