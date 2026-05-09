# Dizzy Walk – Maze Simulation Game

A 2D maze navigation game built in **x86-32 Assembly Language** using the Kip Irvine library. Navigate a disoriented professor through a procedurally generated maze, collect treasures, avoid hazards, and reach home. Developed as a university capstone project for **Computer Organization and Assembly Language**.

## Project Overview

**Dizzy Walk** is an interactive console-based maze game where the player (or AI) controls a professor navigating a 100×150 cell world. The game features:

- **Procedurally generated maze** with thematic obstacles (buildings, walls, lakes)
- **Dynamic collectibles** including coins, keys, and hazard tiles
- **Dual control modes**: Random autonomous movement or real-time keyboard control
- **Flexible termination modes**: Endless adventure or fixed step limit
- **Real-time HUD** displaying wallet, steps, key status, position, and movement mode
- **Comprehensive adventure logging** to `adventure_log.txt` with full path history and pickup events
- **Performance-optimized rendering** with 70% I/O reduction via SetTextColor caching

**Team:** Sameer Ahmed (24I-2047, Team Lead) & Abdul Hannan (24I-2014)  
**Course:** Computer Organization and Assembly Language (COAL)  
**Language:** x86-32 Assembly (Microsoft MASM)

---

## Tech Stack

- **Language:** x86-32 Assembly (MASM .386 architecture)
- **Library:** Kip Irvine's Irvine32 library (console I/O, color, random numbers)
- **Platform:** Windows x86 (32-bit)
- **Build Tool:** Microsoft Visual C++ toolchain (via Visual Studio project files)
- **IDE:** Visual Studio 2022 (or compatible)

---

## Features

### Core Gameplay

- **Maze Generation**: Procedurally generated 100×150 grid with procedural placement of walls, buildings, lakes, coins, hazard tiles, keys, and destination
- **Navigation**: Cardinal direction movement (up, down, left, right) with boundary collision detection
- **Collectibles**:
  - 🪙 **Coins (C)**: Increment wallet, tracked in adventure log
  - 🔑 **Key (K)**: Required to win; can be lost on stumble hazard
  - 🏚️ **Destination (D)**: Win goal; requires key to succeed

### Hazards & Obstacles

- **Walls (#)**: Impassable terrain
- **Buildings (B)**: Large rectangular structures blocking movement
- **Lakes (~)**: Water terrain blocking access
- **Pits (X)**: Instant game over on contact
- **Stumble Tiles (S)**: 50% chance to lose collected key

### Control Modes

1. **Random Mode**: AI-driven autonomous movement with 2-second intervals between moves; can toggle to keyboard control mid-game
2. **Keyboard Mode**: WASD controls + M to switch modes + ESC to quit; instantaneous player input

### HUD & Display

- **Real-time Status Line**: Wallet | Steps | Key status | Position | Current mode
- **Legend Panel**: Color-coded tile reference (right side of screen)
- **Viewport Camera**: 25×60 cell viewport with scroll margin following the professor
- **Color Scheme**:
  - Yellow: Professor & coins
  - Light Blue: Lakes
  - White: Walls
  - Brown: Buildings
  - Light Red: Pits
  - Light Cyan: Keys
  - Light Green: Destination
  - Light Magenta: Stumble tiles
  - Dark Gray: Empty floor

### Game Flow

1. **Intro Screen**: Display ASCII art and welcome message
2. **Main Menu**: Start adventure, view help, or exit
3. **Setup**: Enter professor name (or use default "Dizzy Professor")
4. **Mode Selection**: Choose endless or fixed-step adventure
5. **Gameplay Loop**: 
   - Draw current maze view with HUD and legend
   - Process input (random or keyboard)
   - Apply movement rules and collision detection
   - Record path and pickups
   - Check win/lose/step-limit conditions
6. **Game Over Screen**: Display end reason, stats, and option to restart or exit
7. **Adventure Log**: Automatically saved after each session with path history and pickup summary

### Adventure Logging

Each game session generates an `adventure_log.txt` file containing:
- Professor name and game statistics (steps, wallet, key status)
- Reason for game termination
- Complete path history (step-by-step coordinates)
- Pickup summary (type, location, step number)
- Termination mode (endless vs. finite)

---

## How to Assemble and Run

### Prerequisites

- **Windows OS** (x86 or x86_64 with 32-bit support)
- **Visual Studio 2022** with C++ desktop development workload, or
- **MASM** (Microsoft Macro Assembler) and a 32-bit linker (ml.exe and link.exe)

### Build Instructions (Visual Studio)

1. **Open the project**:
   ```bash
   # Navigate to the project directory
   cd d:\PortfolioProjects\dizzy-walk-maze-simulation
   
   # Open in Visual Studio
   start coal_proj.vcxproj
   ```

2. **Build the project**:
   - In Visual Studio, press `Ctrl+Shift+B` or go to **Build → Build Solution**
   - The assembler will compile all .asm files and link them
   - Output binary: `coal_proj.exe` (in `Debug/` directory)

3. **Run the executable**:
   ```bash
   Debug\coal_proj.exe
   ```

### Build Instructions (Command Line with MASM)

If you have the MASM toolchain installed:

```bash
# Assemble individual files
ml.exe /c /Fo main.obj main.asm
ml.exe /c /Fo game_logic.obj game_logic.asm
ml.exe /c /Fo maze_data.obj maze_data.asm
ml.exe /c /Fo render.obj render.asm
ml.exe /c /Fo movement.obj movement.asm
ml.exe /c /Fo input.obj input.asm

# Link all object files
link.exe /subsystem:console main.obj game_logic.obj maze_data.obj render.obj movement.obj input.obj Irvine32.lib kernel32.lib user32.lib /out:coal_proj.exe

# Run
coal_proj.exe
```

---

## Project Structure

```
coal_proj/
├── main.asm              # Entry point, UI screens, game loop management
├── game_logic.asm        # Core game rules, collision detection, adventure logging
├── maze_data.asm         # Procedural maze generation algorithms
├── render.asm            # Rendering pipeline, camera, HUD, legend, tile coloring
├── movement.asm          # Character movement (WASD, random movement)
├── input.asm             # Keyboard input capture and mode toggling
├── constants.inc         # Global constants and extern declarations
├── maze_data.inc         # Maze generation macro definitions
├── game_logic.inc        # Game logic macro/function declarations
├── render.inc            # Render function declarations
├── movement.inc          # Movement function declarations
├── input.inc             # Input function declarations
├── GraphWin.inc          # Kip Irvine library graphics/window includes
├── adventure_log.txt     # Game session logs (generated at runtime)
├── coal_proj.vcxproj     # Visual Studio project file
└── README.md             # This file
```

---

## Role in Project

### Sameer Ahmed (Team Lead) – Core Engine & Architecture

**Responsibilities:**
- **Game Architecture & Loop Design**: Structured main game loop, state management, and mode switching (random vs. keyboard)
- **Maze Generation & Data Structure**: Designed 100×150 world grid with viewport camera; implemented procedural maze generation with thematic layouts (buildings, walls, lakes)
  - Procedures: `FillMaze`, `GenerateBorders`, `DrawBuilding`, `DrawLake`, `DrawHorizontalWall`, `DrawVerticalWall`, tile placement procedures
- **Core Game Logic & Collision Detection**: Implemented `ResolveMovement` - the central game rules engine handling:
  - Collision detection (walls, buildings, lakes)
  - Hazard mechanics (pits = instant loss, stumbles = 50% key loss)
  - Collectibles (coins, keys)
  - Win/lose conditions
- **Movement System**: Designed and implemented movement procedures (`MoveUp`, `MoveDown`, `MoveLeft`, `MoveRight`, `DoRandomMove`) with bounds checking
- **Rendering Pipeline & Camera System**: 
  - Viewport camera with scroll margin tracking (`UpdateCamera`)
  - Tile-to-color mapping (`PrintColoredCell`)
  - HUD display (`DrawHUD`) and legend panel (`DrawLegend`)
  - Performance optimization: Implemented `CachedSetTextColor` reducing console I/O by 70% (1500→450 calls/frame)
- **Path & Pickup Tracking**: Implemented recording system for professor's movement path and collectible events for adventure log generation
- **Performance Analysis & Optimization**: Identified SetTextColor as bottleneck, designed caching strategy achieving 40-50% overall speedup

**Key Procedures Authored:**
`InitMaze`, `ResolveMovement`, `UpdateCamera`, `PrintColoredCell`, `CachedSetTextColor`, `DrawMaze`, `FillMaze`, `GenerateBorders`, `DrawBuilding`, `DrawLake`, `DrawHorizontalWall`, `DrawVerticalWall`, `MoveUp`, `MoveDown`, `MoveLeft`, `MoveRight`, `DoRandomMove`, `RecordPathPoint`, `RecordPickup`

### Abdul Hannan (Team Member) – UI, Input, Documentation & Support

**Responsibilities:**
- **User Interface & Menu Design**: Designed all console UI screens (intro, main menu, help, professor setup, adventure type selection, game over) with ASCII art
- **Input Handling**: Implemented keyboard input capture (`HandleKeyboardInput`) for WASD movement, M mode toggle, and ESC quit
- **File I/O & Adventure Logging**: Implemented adventure log output system (`WriteAdventureLog`) with formatted session reports including stats, path history, and pickup summaries
- **Utility Functions**: String handling (`CopyString`), number-to-ASCII conversion (`UIntToAscii`), file I/O helpers (`WriteNullTerminatedToFile`, `WriteNewlineToFile`)
- **Documentation**: Procedure headers, inline code comments, and README

**Key Procedures Authored:**
`HandleKeyboardInput`, `CheckModeToggle`, `WriteAdventureLog`, `UIntToAscii`, `WriteNullTerminatedToFile`, `WriteNewlineToFile`, `CopyString`, all UI screen procedures (`ShowIntroScreen`, `ShowMainMenu`, `ShowHelpScreen`, `ShowProfessorSetup`, `ShowAdventureTypeSetup`, `ShowGameOverScreen`)

---

## Gameplay Instructions

### Main Menu
- **1**: Start a new adventure
- **2**: View help and controls
- **3**: Exit game

### Setup
- Enter a professor name (or press Enter for "Dizzy Professor")
- Choose adventure type: Endless or Fixed steps
- If fixed steps, enter the maximum step limit

### Controls (Keyboard Mode)
- **W/A/S/D**: Move up, left, down, right
- **M**: Toggle between random and keyboard mode
- **ESC**: Quit to main menu

### Random Mode
- Professor moves automatically every 2 seconds
- Press **M** to switch to keyboard control
- Press **ESC** to quit

### Objective
1. Collect the **key (K)** to unlock the destination
2. Navigate to the **destination (D)** tile
3. Reach home with the key to win
4. Avoid **pits (X)** and **stumble tiles (S)**
5. Collect **coins (C)** to increase wallet

### Game Over Conditions
- **Win**: Reached destination with the key
- **Lose (No Key)**: Reached destination without the key
- **Lose (Pit)**: Fell into a pit
- **Lose (Step Limit)**: Exceeded the maximum steps in finite mode

---

## Implementation Highlights

### Performance Optimization
The console's `SetTextColor` function was identified as a performance bottleneck, being called ~1500 times per frame. The solution implements a caching mechanism (`CachedSetTextColor`) that only calls the system function when the color changes, reducing calls to ~450 per frame—a **70% I/O reduction** achieving **40-50% overall speedup**.

### Modular Architecture
The codebase is organized into logical modules:
- **main.asm**: Game loop and UI orchestration
- **game_logic.asm**: Rules engine and state management
- **maze_data.asm**: Procedural content generation
- **render.asm**: Graphics pipeline and caching
- **movement.asm**: Character locomotion
- **input.asm**: Keyboard handling

### Robust State Management
The game tracks:
- Professor position, inventory (wallet, key), and step count
- Full path history for logging
- Pickup events with metadata
- Camera viewport position
- Game over state and termination reason

---

## Notes & Future Enhancements

- **Maze Variety**: The procedural generation creates thematic layouts with buildings and lakes; seed-based generation could enable custom maze creation
- **Difficulty Scaling**: Step limits provide variable challenge; hazard density could be adjustable
- **Multiplayer**: Could support multiple professors with shared maze via thread synchronization
- **Enhanced Logging**: Statistics tracking across sessions, leaderboards, or replay systems
- **Graphics**: Upgrade to DirectX or SDL for smoother rendering and animation

---

## Course Context

This project was developed as a capstone assignment for a **Computer Organization and Assembly Language** course, demonstrating:
- Low-level system programming in x86 assembly
- Memory management and data structure design
- Algorithm implementation (procedural generation, collision detection)
- Performance optimization techniques
- Software architecture and modular design
- File I/O and system integration

---

## Author Contact

- **Sameer Ahmed** (Team Lead)  
  GitHub: [https://github.com/sameer7075](https://github.com/sameer7075)

- **Abdul Hannan** (Team Member)  
  GitHub: [https://github.com/abdulhannan7]

---

## License

This project is provided as-is for educational purposes. See the course submission guidelines for licensing and reuse terms.

---

## Acknowledgments

- **Kip Irvine** – For the assembly language library and educational resources
- **Course Instructors** – For guidance and rubric framework
- **Microsoft MASM Documentation** – For assembler and linker reference

