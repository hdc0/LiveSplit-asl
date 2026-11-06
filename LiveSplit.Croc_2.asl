state("Croc2", "US") {
	int CrocX               : 0xA8C3C, 0x14, 0x28, 0x2c;
	int CrocY               : 0xA8C3C, 0x14, 0x28, 0x30;
	int CrocZ               : 0xA8C3C, 0x14, 0x28, 0x34;
	int CurTribe            : 0xA8C44;
	int CurLevel            : 0xA8C48;
	int CurMap              : 0xA8C4C;
	int CurType             : 0xA8C50;
	int InGameState         : 0xB7880;
	bool IsCheatMenuOpen    : 0xB788C;
	bool IsMapLoaded        : 0xB78C4;
	int NewMainState        : 0xB7930;
	int IsNewMainStateValid : 0xB7934;
	int MainState           : 0xB793C;
	int Inputs              : 0x12A590;
	int GemCounter          : 0x12AECC;
	int GobboCounter        : 0x12AEE0;
	int AllowReturnToHub    : 0x12AEFC;
	int CurSaveSlotIdx      : 0x2220FC;
}

state("Croc2", "EU") {
	int CrocX               : 0xA9C3C, 0x14, 0x28, 0x2c;
	int CrocY               : 0xA9C3C, 0x14, 0x28, 0x30;
	int CrocZ               : 0xA9C3C, 0x14, 0x28, 0x34;
	int CurTribe            : 0xA9C44;
	int CurLevel            : 0xA9C48;
	int CurMap              : 0xA9C4C;
	int CurType             : 0xA9C50;
	int InGameState         : 0xBEA70;
	bool IsCheatMenuOpen    : 0xBEA7C;
	bool IsMapLoaded        : 0xBEAB4;
	int NewMainState        : 0xBEB20;
	int IsNewMainStateValid : 0xBEB24;
	int MainState           : 0xBEB2C;
	int Inputs              : 0x131780;
	int GemCounter          : 0x1320BC;
	int GobboCounter        : 0x1320D0;
	int AllowReturnToHub    : 0x1320EC;
	int CurSaveSlotIdx      : 0x2292EC;
}

state("croc2", "HD-STEAM")
{
	// int CrocX               : 0xA8C3C, 0x14, 0x28, 0x2c;
	// int CrocY               : 0xA8C3C, 0x14, 0x28, 0x30;
	// int CrocZ               : 0xA8C3C, 0x14, 0x28, 0x34;
	int CurTribe            : 0xBC87D4;
	int CurLevel            : 0xBC87D8;
	int CurMap              : 0xBC87DC;
	int CurType             : 0xBC87E0;
	int InGameState         : 0xB90D30;
	bool IsCheatMenuOpen    : 0xB8E0F8;
		// OG (int):  menu closed = 0, open = 1
		// HD (int):  menu closed = 0, open = 0xFFFFFFFF (or, -1)
		// Switching this to a bool, so behaviour is the same between OG and HD
	bool IsMapLoaded        : 0xBCE790;
		// FIXME: candidate. need to verify. 0xBCE894 also looks promising
		// FIXME: seems to get triggered in a variety of transitions in roger.
		//			also gets briefly triggered at the start of the cossack iceblock final cutscene.
		//			how does OG compare? and do any other levels do that?
	int NewMainState        : 0xB90D3C;
	// int IsNewMainStateValid : 0xB7934;
		// FIXME: find this for save slot start, if you can
	int MainState           : 0xB5D5E8; 
	// int Inputs              : 0x12A590;
		// only used for the "Start on any input" option
		// browse memory around 0xBC4B54 for some candidates
	int GemCounter          : 0xBC4DAC;
	int GobboCounter        : 0xBC4C6C;
	// int AllowReturnToHub    : 0x12AEFC;
		// only used for wrong warp detection (which I don't think is even possible in HD?)
	int CurSaveSlotIdx      : 0xB4D5A8;
		// FIXME: do we use this for anything in HD? if not, then let's just comment it out
}

startup {
	// Start
	settings.Add("RequireUnusedBossWarps", true,
		"Do not start if any boss warp has already been used");
	settings.Add("SaveSlotStart", true,
		"Save slot start");
		settings.SetToolTip("SaveSlotStart",
			"Starts timer on creating a new save file");
	settings.Add("InputStart", false,
		"Start on any input");
		settings.SetToolTip("InputStart",
			"Useful for testing / timing things");
	settings.Add("ILstart", false,
		"IL start");
		settings.SetToolTip("ILstart",
			"Starts timer on map change when you enter a level");
	settings.Add("OTSstart", false,
		"OTS start");
		settings.SetToolTip("OTSstart",
			"Starts timer on map change when you enter hub" +
			"\n\n(note: used to record times for the Overworld Times Sheet)" +
			"\n(note: secret is currently disabled, as its OTS isn't set up yet)");
		settings.Add("OTSstart_SMP", false,
			"Also start on SMP entry", "OTSstart");
	settings.Add("IWstart", false,
		"IW start");
		settings.SetToolTip("IWstart",
			"Starts timer on map change when you exit SMP to hub" +
			"\n\n(note: using the cheat menu to warp is equivalent)" +
			"\n(fun fact: WW, SQ, GOA, (and sometimes DA) are not equivalent;" +
			"\nthey give a different hub spawn!)");

	// Split
	settings.Add("SplitOnMapChange", true,
		"IL/OTS end split");
		settings.SetToolTip("SplitOnMapChange",
			"Splits timer on any relevant map change to end an IL or OTS run" +
			"\n\nThis can also be used in fullgame runs, to chain multiple IL and OTS segments together!" +
			"\n(\"IL style splits\")");
		settings.Add("SplitOnMapChange_literal", false,
			"Split on literally any map change", "SplitOnMapChange");
	settings.Add("SplitOnObjectiveCompletion", false,
		"Split on objective completion");
		settings.SetToolTip("SplitOnObjectiveCompletion",
			"(note: you probably want to disable this if doing IL style splits)");
		settings.Add("SplitOnSMPEntry", false,
			"IW end split", "SplitOnObjectiveCompletion");
			settings.SetToolTip("SplitOnSMPEntry",
				"Splits timer on map change into SMP" +
				"\n\n(note: this option is redundant if IL/OTS end split is enabled!)");
		settings.Add("SplitOnGoldenGobbo", false,
			"100% (require Golden Gobbo)", "SplitOnObjectiveCompletion");
		settings.Add("SplitOnDanteCrystals", false,
			"Split on collecting crystals in Dante's World", "SplitOnObjectiveCompletion");
	settings.Add("SplitOnGem", false,
		"Split on collecting gems");
		settings.SetToolTip("SplitOnGem",
			"(note: useful for IL runs)");
	settings.Add("BabiesSubsplits", false,
		"Babies Subsplits");
		for (int i = 1; i <= 30; i++)
		{
			settings.Add("BabiesSubsplits_" + i.ToString(), false,
			i.ToString() + " / 30", "BabiesSubsplits");
		}

	// Debug
	settings.Add("DebugOutput", false,
		"Debug output");
		settings.SetToolTip("DebugOutput",
		"Prints debug info in Dbgview.exe" +
		"\n\n(note: allows you to see which changes happened in the same ASL cycle)");
		settings.Add("DO_MapChanges", true,
		"Map changes", "DebugOutput");
		settings.Add("DO_WadB4GH", true,
		"WadB4GH changes", "DebugOutput");
		settings.Add("DO_PrevTribeSSX", true,
		"PrevTribeSSX changes", "DebugOutput");
		settings.Add("DO_MainState", true,
		"MainState changes", "DebugOutput");
		settings.Add("DO_NewMainState", true,
		"NewMainState changes", "DebugOutput");
		settings.Add("DO_IsNewMainStateValid", true,
		"IsNewMainStateValid changes", "DebugOutput");
		settings.Add("DO_InGameState", true,
		"InGameState changes", "DebugOutput");
		settings.Add("DO_IsCheatMenuOpen", true,
		"IsCheatMenuOpen changes", "DebugOutput");
		settings.Add("DO_AllowReturnToHub", true,
		"AllowReturnToHub changes", "DebugOutput");
		settings.Add("DO_IsMapLoaded", true,
		"IsMapLoaded changes", "DebugOutput");
		
	// Speed display
	// should probably move this to a Cheat Engine GUI or a separate asl script or something
	//      https://wiki.cheatengine.org/index.php?title=Tutorial:LuaFormGUI
	// SetTextComponent is taken from: https://github.com/zment4/DefyGravityASL
	vars.SetTextComponent = (Action<string, string, bool>)((id, text, create) => {
		dynamic textSetting = timer.Layout.Components
			.Where(x => x.GetType().Name == "TextComponent")
			.Select(x => (x as dynamic).Settings)
			.FirstOrDefault(x => (x as dynamic).Text1 == id);
			
		if (textSetting == null && create) 
		{
			var textComponentAssembly = Assembly.LoadFrom("Components\\LiveSplit.Text.dll");
			dynamic textComponent = Activator.CreateInstance(textComponentAssembly.GetType("LiveSplit.UI.Components.TextComponent"), timer);
			timer.Layout.LayoutComponents.Add(new LiveSplit.UI.Components.LayoutComponent("LiveSplit.Text.dll", textComponent as LiveSplit.UI.Components.IComponent));
			
			textSetting = textComponent.Settings;
			textSetting.Text1 = id;
		}
		
		if (textSetting != null)
			textSetting.Text2 = text;
	});
	settings.Add("SpeedDisplay", false,
		"Display Croc's speed in a LiveSplit text component");
		settings.SetToolTip("SpeedDisplay",
		"note 1: The text component is created automatically once Croc starts walking around" +
		"\n\nnote 2: Croc 2 runs at 30fps. This display catches most but NOT ALL of the frames" +
		"\n\nnote 3: Unfortunately, when Croc isn't moving the display just holds the last non-zero value");

	// Returns true iff the current map ID changed
	vars.HasMapIDChanged = new Func<dynamic, dynamic, bool>((state1, state2) =>
		state1.CurTribe != state2.CurTribe || state1.CurLevel != state2.CurLevel ||
		state1.CurMap != state2.CurMap || state1.CurType != state2.CurType);

	vars.AllDFCrystalsJustPlaced = new Func<Process, dynamic, bool>((Memory, Vars) =>
	{
		// In "Dante's Final Fight", we cannot simply monitor the objective
		// completion flag to detect the split, as there is an unacceptable
		// delay between the placement of the final crystal and the flag being set.
		// Instead, we take advantage of the unique occurrence of a specific
		// short byte pattern within this map's ASL bytecode.
		// Once a crystal is successfully placed, its program counter remains
		// indefinitely at the memory address where this byte pattern is located.
		// For split detection, we therefore iterate over all strats and count
		// how many of them currently have their program counter pointing to
		// this byte pattern. Once this count reaches 5, we trigger the split.

		bool allCrystalsPlaced = false;
		int crystalStratsAtFinalPC = 0;
		var expectedBytes = new byte[] {
			0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x28 };
		IntPtr strat;
		if (!Vars.PtrToFirstStrat.DerefOffsets(Memory, out strat))
			return false;
		for
		(
			;
			strat != IntPtr.Zero;
			strat = Memory.ReadPointer(strat + (int)Vars.OffsetOfPtrToNextStrat)
		)
		{
			var pc = Memory.ReadPointer(strat + (int)Vars.OffsetOfStratPCField);
			if (pc == IntPtr.Zero)
				continue;
			var bytesAtPC = Memory.ReadBytes(pc, expectedBytes.Length);
			if (bytesAtPC == null)
				continue;
			int byteIdx;
			for (byteIdx = 0; byteIdx < bytesAtPC.Length; ++byteIdx)
			{
				if (bytesAtPC[byteIdx] != expectedBytes[byteIdx])
					break;
			}
			if (byteIdx < bytesAtPC.Length)
				continue;
			if (++crystalStratsAtFinalPC == 5)
			{
				allCrystalsPlaced = true;
				break;
			}
		}

		object wereAllCrystalsPlaced;
		((IDictionary<string, object>)Vars).TryGetValue(
			"AllDFCrystalsPlaced", out wereAllCrystalsPlaced);
		Vars.AllDFCrystalsPlaced = allCrystalsPlaced;

		return allCrystalsPlaced &&
			(wereAllCrystalsPlaced == null || !(bool)wereAllCrystalsPlaced);
	});

	// Returns true iff map has specified map ID
	vars.IsThisMap = new Func<dynamic, int, int, int, int, bool>(
		(state, tribe, level, map, type) =>
		state.CurTribe == tribe && state.CurLevel == level &&
		state.CurMap == map && state.CurType == type);
		
	// Returns true iff map is a gobbo hub map
	vars.IsGobboHub = new Func<dynamic, bool>(state =>
		state.CurTribe >= 1 && state.CurTribe <= 4 &&
		state.CurLevel == 1 && state.CurMap == 1 && state.CurType == 0);

	// Returns true iff map is "Swap Meet Pete's General Store"
	vars.IsShopMap = new Func<dynamic, bool>(state =>
		state.CurTribe >= 1 && state.CurTribe <= 4 &&
		state.CurLevel == 1 && state.CurMap == 4 && state.CurType == 0);
		
	// Returns true iff a wrong warp is being performed
	vars.IsWrongWarp = new Func<dynamic, dynamic, bool>((oldState, curState) =>
		// old map is not hub map - can't use functions in functions :(
		!(oldState.CurTribe >= 1 && oldState.CurTribe <= 4 &&
		oldState.CurLevel == 1 && oldState.CurMap == 1 && oldState.CurType == 0) &&
		// new map is hub map
		curState.CurTribe >= 1 && curState.CurTribe <= 4 &&
		curState.CurLevel == 1 && curState.CurMap == 1 && curState.CurType == 0 &&
		// return to hub option enabled (usually set to 0 on door, but will stick if ww)
		curState.AllowReturnToHub == 1 &&
		// saveslot PrevTribe is already 0 (this is the main indicator)
		// (in fact, this might be what actually causes the wrong warp!)
		curState.PrevTribeSSX == 0);
}

init {
	var firstModule = modules.First();
	var baseAddr = firstModule.BaseAddress;
	int addrScriptMgr;

	// Detect game version
	switch (firstModule.ModuleMemorySize)
	{
		case 0x23A000:
			version = "US";
			vars.era = "OG";
			vars.AddrCurTribe       = baseAddr + 0xA8C44;
			vars.AddrCurLevel       = baseAddr + 0xA8C48;
			vars.AddrCurMap         = baseAddr + 0xA8C4C;
			vars.AddrCurType        = baseAddr + 0xA8C50;
			vars.AddrSaveSlots      = baseAddr + 0x2040C0;
			vars.AddrUsedBossWarps  = baseAddr + 0x222D50;
			vars.PtrToFirstStrat = new DeepPointer(baseAddr + 0xB78BC, 0x20);
			break;

		case 0x242000:
			version = "EU";
			vars.era = "OG";
			vars.AddrCurTribe       = baseAddr + 0xA9C44;
			vars.AddrCurLevel       = baseAddr + 0xA9C48;
			vars.AddrCurMap         = baseAddr + 0xA9C4C;
			vars.AddrCurType        = baseAddr + 0xA9C50;
			vars.AddrSaveSlots      = baseAddr + 0x20B2B0;
			vars.AddrUsedBossWarps  = baseAddr + 0x229F40;
			vars.PtrToFirstStrat = new DeepPointer(baseAddr + 0xBEAAC, 0x20);
			break;

		case 0xC80000:
			version = "HD-STEAM";
			vars.era = "HD";
			vars.AddrCurTribe       = baseAddr + 0xBC87D4;
			vars.AddrCurLevel       = baseAddr + 0xBC87D8;
			vars.AddrCurMap         = baseAddr + 0xBC87DC;
			vars.AddrCurType        = baseAddr + 0xBC87E0;
			vars.AddrSaveSlot       = baseAddr + 0xBA9878;
				// Your save data seems to be stored here; it gets saved to:
				// `\AppData\Roaming\Croc 2\saves\76561198041092660\game_X.sav`
				// where X is replaced with the save slot #
			// vars.AddrUsedBossWarps  = baseAddr + 0x222D50;
				// FIXME: surely this bug is fixed in HD?
			// FIXME: in addition to the traditional CurWAD addresses, we found these NewWAD addresses, which contain the WAD being loaded. as of writing, they are used for HD save slot start logic. think about if these could be useful for race condition prevention (or for other parts of the autosplitter). also, are they present in og?
			vars.AddrNewTribe       = baseAddr + 0xBA9B04;
			vars.AddrNewLevel       = baseAddr + 0xBA9B08;
			vars.AddrNewMap         = baseAddr + 0xBA9B0C;
			vars.AddrNewType        = baseAddr + 0xBA9B10;
			vars.PtrToFirstStrat = new DeepPointer(baseAddr + 0xBC7D20, 0);
			break;

		default:
			return;
	}

	// Set era dependent constants
	// FIXME: compare MainState behaviour with og
	// - timing of MainState changes, relative to wad ID etc (particularly Running)
	// - value of MainState in cutscene vs main gameplay vs title screen demos
	vars.OffsetOfStratPCField = game.Is64Bit() ? 0x000 : 0x00C;
	vars.OffsetOfPtrToNextStrat = game.Is64Bit() ? 0x008 : 0x000;
	switch ((string)vars.era)
	{
		case "OG":
			vars.ProgressListOffset = 0x2d0;

			vars.MainState_OpeningLogos   =  8;
			// vars.MainState_Logos2IntroCS doesn't appear to be a thing in og
			vars.MainState_Running        = 11;
			vars.MainState_IntroCS2MM     = 19;
			vars.MainState_MainMenu       = 16;
			vars.MainState_Demo           =  5;
			vars.MainState_Options        = 14; // Options screen (only the one on main menu, not in-game)
			// vars.MainState_Croc2pedia isn't a thing, ofc
			vars.MainState_LevelSelect    = 18; // This is the blue screen where you select a wad ID (only accessable through poking memory)
			vars.MainState_NGInitials     =  9; // New Game - entering initials
			vars.MainState_NGSaveSlot     =  2; // New Game - select save slot
			vars.MainState_LGSaveSlot     =  1; // Load Game - select save slot
			vars.MainState_ContinueYN     =  3; // "Continue? Yes / No" screen when you game over
			vars.MainState_GameOver       = 12; // "Game Over" screen (when you run out of lives and select "No" on the "Continue?" screen, or when you exit the game from the pause menu)
			vars.MainState_Credits		  =  4;
			// vars.MainState_Credits2Inca   = ??; // FIXME: see if this exists in OG
			vars.MainState_ExitGame       =  6;
			break;
		
		case "HD":
			vars.ProgressListOffset = 0x30C;

			vars.MainState_OpeningLogos   = 20;
			vars.MainState_Logos2IntroCS  =  1; // Transition from the intro Logos -> Intro CutScene where the scientist is taken by dante
			vars.MainState_Running        =  4; // Includes both active gameplay and cutscenes
				// Confirmed cutscenes:
				// Intro scientist cutscene (both when booting game, and as a main menu attract screen)
				// Cutscene on new save where Croc gets launched
				// FIXME: ...oh is it simply all cutscenes lol?
			vars.MainState_IntroCS2MM     = 15; // Transition from the scientist intro cutscene -> Main Menu
			vars.MainState_MainMenu       =  3;
			vars.MainState_Demo           =  5; // Demos that run as an attract screen on the main menu
			// vars.MainState_Options for HD is just on the main menu
			vars.MainState_Croc2pedia     = 18;
			// vars.MainState_LevelSelect    = 14; FIXME: is this still in HD? could be 14? see: https://tcrf.net/Croc_2_(Windows,_PlayStation)#Level_Select
			// vars.MainState_NGInitials |
			// vars.MainState_NGSaveSlot | for HD, this all takes place on the main menu
			// vars.MainState_LGSaveSlot |
			vars.MainState_ContinueYN     = 09;
			// vars.MainState_GameOver is not in HD; selecting no on ContinueYN takes you straight to main menu
			vars.MainState_Credits		  = 12;
			vars.MainState_Credits2Inca   = 16; // After you beat dante, the transition from the credits back into inca village
			// vars.MainState_ExitGame doesn't seem to be a thing; the game just quits
			break;

		default:
			return;
	}

	// Initialize variable for speed display
	vars.curMS = 0;
	
	// Set flag for initialization of custom current. variables (see comments there for info)
	vars.customCurrentVarsAreInitialized = false;
}

update {
	// ==== Race condition detection + correction ====
	//
	// This is done first thing in the cycle, to prevent corrupt map IDs from leaking in
	//
	// description of the issue we are solving:
	// https://discord.com/channels/313375426112389123/408694062862958592/880900162250211338
	
	// == Manually read the map ID again (currentPlusAlpha) ==
	// We will use it to verify LiveSplit's read (current)
	int currentPlusAlphaCurTribe = memory.ReadValue<int>((IntPtr)vars.AddrCurTribe);
	int currentPlusAlphaCurLevel = memory.ReadValue<int>((IntPtr)vars.AddrCurLevel);
	int currentPlusAlphaCurMap   = memory.ReadValue<int>((IntPtr)vars.AddrCurMap);
	int currentPlusAlphaCurType  = memory.ReadValue<int>((IntPtr)vars.AddrCurType);
	
	// == Race condition detection ==
	// current is a race condition read iff old != current != currentPlusAlpha, assuming:
	// 1. the game is able progress between current and currentPlusAlpha
	// 2. LiveSplit is polling fast enough that you can't legitimately traverse through 3 different maps lol
	//
	// Here is a diagram of all possible scenarios:
	//
	// o = old, c = current, a = currentPlusAlpha
	// ------------ time ----------->
	//
	// And for example let's say:
	// old map ID = 0, 0, 5, 0 (4 ints)
	// new map ID = 4, 1, 1, 0
	//
	// Haven't hit the new map yet. o == c == a == 0, 0, 5, 0 (the old map ID)
	//  o   c a
	// old map  |  new map
	//
	// currentPlusAlpha got a race condition read, so it is a mixture of the old and new ID,
	// for example like 0, 0, 1, 0. But current is still valid (0, 0, 5, 0), and that's all that matters
	//    o   c a
	// old map  |  new map
	//
	// currentPlusAlpha read the next map (4, 1, 1, 0). who cares.
	//     o   c a
	// old map  |  new map
	//
	// !!! current got a race condition read !!!
	// this is the only situation where o != c != a, so that's how we can tell
	//      o   c a
	// old map  |  new map
	//
	// This is a standard map change! o and c are squarely in the old and new maps
	//        o   c a
	// old map  |  new map
	//
	// This is not possible, because o is just c from last cycle,
	// and we will clean any race conditions out of c
	//          o   c a
	// old map  |  new map
	if (vars.HasMapIDChanged(old, current) &&
		!vars.IsThisMap(current,
			currentPlusAlphaCurTribe,
			currentPlusAlphaCurLevel,
			currentPlusAlphaCurMap,
			currentPlusAlphaCurType))
	{
		print("****************** RACE CONDITION DETECTED **********************\n" +
			old.CurTribe             + ", " + old.CurLevel             + ", " +
			old.CurMap               + ", " + old.CurType              + " old.CurWad\n" + 
			current.CurTribe         + ", " + current.CurLevel         + ", " +
			current.CurMap           + ", " + current.CurType          + " current.CurWad\n" + 
			currentPlusAlphaCurTribe + ", " + currentPlusAlphaCurLevel + ", " +
			currentPlusAlphaCurMap   + ", " + currentPlusAlphaCurType  + " currentPlusAlphaCurWad\n" +
			"******* OVERWRITING current.CurWad WITH currentPlusAlphaCurWad *******");
		
		// == Race condition correction ==
		//
		// Historically, up until now when the race condition occurred:
		// we split on the first map change (old map -> race condition),
		// then blocked the double split from the immediately following map change (race condition -> new map)
		//
		// So instead of overwriting current with old (thus delaying the map change / split until next cycle),
		// let's overwrite it with currentPlusAlpha (so we split right away like we historically have,
		// while still correcting the corrupt data!)
		current.CurTribe = currentPlusAlphaCurTribe;
		current.CurLevel = currentPlusAlphaCurLevel;
		current.CurMap = currentPlusAlphaCurMap;
		current.CurType = currentPlusAlphaCurType;
	}
	// == misc notes ==
	//
	// I've assumed that the game slowly writes the 4 map ID ints one by one,
	// then LiveSplit suddenly comes in and reads memory while the game has its pants down.
	// BUT, it's possible it could be the other way around? as in: 
	// LiveSplit slowly reads the 4 addresses one by one, then the game suddenly writes memory in the middle of that.
	// If that's the case, the race condition could potentially be solved simply by
	// reading the map ID in LiveSplit as a single 4 int block...
	//
	// Also, it's possible that "race condition" isn't the right terminology for what's happening here,
	// but at this point we've been calling it that for years *shrug*
	//
	// An easy place to test is at the entrance of Masher;
	// Just put a rubber band on your controller to hold analog stick right + pause,
	// and you will go hub -> cutscene -> masher -> hub in a loop.
	// But still it will probably take ~5 minutes to get it even once...
	//
	// ==== (end race condition detection + correction) ====
	
	// Initialization of custom current. variables
	//
	// Unfortunately this can't simply be initialized in `startup` or `init`,
	// because when livesplit detects the EU version, the old/current variables get wiped.
	if (!vars.customCurrentVarsAreInitialized)
	{
		// Initialize PrevTribeSSX
		// Currently it's just used for detecting wrong warps
		old.PrevTribeSSX = -1;
		current.PrevTribeSSX = -1;
		
		// Initialize WadB4GH (Wad Before GOA or Hub)
		// WadB4GH is used for detecting re-entry for wrong warp, or if you GOA'd in the hub.
		old.TribeB4GH = -1;
		old.LevelB4GH = -1;
		old.MapB4GH   = -1;
		old.TypeB4GH  = -1;
		current.TribeB4GH = -1;
		current.LevelB4GH = -1;
		current.MapB4GH   = -1;
		current.TypeB4GH  = -1;
		
		vars.customCurrentVarsAreInitialized = true;
	}
	
	// FIXME; temp workaround
	if (version == "HD-STEAM")
	{
		// print("FIXME: skipping updating addrSaveSlot / PrevTribeSSX");
	}
	else
	{
		// Update addrSaveSlot
		const int SaveSlotSize = 0x2000;
		vars.AddrSaveSlot = vars.AddrSaveSlots + (current.CurSaveSlotIdx * SaveSlotSize);
		
		// Update PrevTribeSSX
		const int offsetPrevTribeSSX = 0x2B4;
		var addrPrevTribeSSX = vars.AddrSaveSlot + offsetPrevTribeSSX;
		current.PrevTribeSSX = memory.ReadValue<int>((IntPtr)addrPrevTribeSSX);
	}
	
	// Update WadB4GH
	if (vars.HasMapIDChanged(old, current) &&
		(
			// now on GOA screen
			vars.IsThisMap(current, 0, 0, 2, 3) ||
			// or hub (but not if we were already on GOA screen)
			(vars.IsGobboHub(current) && !vars.IsThisMap(old, 0, 0, 2, 3)))
		)
	{
		current.TribeB4GH = old.CurTribe;
		current.LevelB4GH = old.CurLevel;
		current.MapB4GH = old.CurMap;
		current.TypeB4GH = old.CurType;
	}
	
	// Speed display
	if (settings["SpeedDisplay"])
	{
		// Calculate number of in game frames since the last livesplit cycle
		// (there is probably some variable built into in livesplit we can replace oldMS/curMS with...)
		vars.oldMS = vars.curMS;
		vars.curMS = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
		vars.ingameframes = (vars.curMS - vars.oldMS)/1000.0 / (1.0/30.0);
		
		// (units per frame)
		// Only looks at Croc's distance on the XZ plane (ignores vertical movement)
		vars.upf2D = Math.Sqrt(
				Math.Pow(current.CrocX-old.CrocX, 2.0) +
				Math.Pow(current.CrocZ-old.CrocZ, 2.0));
		
		// Includes vertical movement (full 3D movement)
		vars.upf3D = Math.Sqrt(
				Math.Pow(current.CrocX-old.CrocX, 2.0) +
				Math.Pow(current.CrocZ-old.CrocZ, 2.0) +
				Math.Pow(current.CrocY-old.CrocY, 2.0));
		
		// We are oversampling (livesplit is ~60fps while the game is 30fps).
		// If we sample the game again before it is on the next frame, then croc's position will not have changed,
		// so we can toss out any results where upf3D == 0 (no movement).
		//
		// (an unfortunate side effect of this is that even if croc is legitimately not moving, the display will hold the last non-zero value...)
		//
		// Conversely, if it has been any more than the length of 1 game frame since the last livesplit cycle,
		// then we *could* have 2 or more frames of Croc movement in our result,
		// so we require it has been less than 1 in game frame since the last cycle
		if (vars.upf3D != 0 &&	vars.ingameframes < 1.0)
		{
			// print("units per frame 2D: " + vars.upf2D.ToString() +
			// 	"\nunits per frame 3D: " + vars.upf3D.ToString());
			vars.SetTextComponent("UPF (2D)", vars.upf2D.ToString("0.0000"), true);
			vars.SetTextComponent("UPF (3D)", vars.upf3D.ToString("0.0000"), true);
		}
	}	
	
	// Debug output
	if (settings["DebugOutput"])
	{
		string debugText = "";
		
		// Map changes
		if (settings["DO_MapChanges"] &&
			vars.HasMapIDChanged(old, current))
		{
			debugText += "\n┃Tribe: " + old.CurTribe.ToString() +
				        " -> " + current.CurTribe.ToString() +
				          " (" + currentPlusAlphaCurTribe.ToString() +
				")\n┃Level: " + old.CurLevel.ToString() +
				        " -> " + current.CurLevel.ToString() +
				          " (" + currentPlusAlphaCurLevel.ToString() +
				")\n┃Map:   " + old.CurMap.ToString() +
				        " -> " + current.CurMap.ToString() +
				          " (" + currentPlusAlphaCurMap.ToString() +
				")\n┃Type:  " + old.CurType.ToString() +
				        " -> " + current.CurType.ToString() +
				          " (" + currentPlusAlphaCurType.ToString() + ")";
		}

		// // NewWad changes
		// // FIXME: temporary
		// if (settings["DO_MapChanges"] && vars.era == "HD" && 
		// 	(old.NewTribe != current.NewTribe ||
		// 	old.NewLevel != current.NewLevel ||
		// 	old.NewMap != current.NewMap ||
		// 	old.NewType != current.NewType))
		// {
		// 	debugText += "\n┃NewTribe: " + old.NewTribe.ToString() +
		// 		           " -> " + current.NewTribe.ToString() +
		// 		"\n┃NewLevel: " + old.NewLevel.ToString() +
		// 		           " -> " + current.NewLevel.ToString() +
		// 		"\n┃NewMap:   " + old.NewMap.ToString() +
		// 		           " -> " + current.NewMap.ToString() +
		// 		"\n┃NewType:  " + old.NewType.ToString() +
		// 		           " -> " + current.NewType.ToString();
		// }
		
		// WadB4GH changes
		if (settings["DO_WadB4GH"] &&
			(old.TribeB4GH != current.TribeB4GH ||
			old.LevelB4GH != current.LevelB4GH ||
			old.MapB4GH != current.MapB4GH ||
			old.TypeB4GH != current.TypeB4GH))
		{
			debugText += "\n┃TribeB4GH: " + old.TribeB4GH.ToString() +
				           " -> " + current.TribeB4GH.ToString() +
				"\n┃LevelB4GH: " + old.LevelB4GH.ToString() +
				           " -> " + current.LevelB4GH.ToString() +
				"\n┃MapB4GH:   " + old.MapB4GH.ToString() +
				           " -> " + current.MapB4GH.ToString() +
				"\n┃TypeB4GH:  " + old.TypeB4GH.ToString() +
				           " -> " + current.TypeB4GH.ToString();
		}
		
		// PrevTribeSSX changes
		// FIXME: how to handle this for HD? does PrevTribeSSX even exist in HD?
		if (settings["DO_PrevTribeSSX"] &&
			old.PrevTribeSSX != current.PrevTribeSSX)
		{
			debugText += "\n┃PrevTribeSSX: " + old.PrevTribeSSX.ToString() +
				" -> " + current.PrevTribeSSX.ToString();
		}
		
		// MainState changes
		if (settings["DO_MainState"] &&
			old.MainState != current.MainState)
		{
			debugText += "\n┃MainState: " + old.MainState.ToString() +
				" -> " + current.MainState.ToString();
		}
		
		// NewMainState changes
		if (settings["DO_NewMainState"] &&
			old.NewMainState != current.NewMainState)
		{
			debugText += "\n┃NewMainState: " + old.NewMainState.ToString() +
				" -> " + current.NewMainState.ToString();
		}
		
		// IsNewMainStateValid changes
		// FIXME: temporarily only for OG, cos i dont know the hd address yet
		if (settings["DO_IsNewMainStateValid"] && vars.era == "OG" &&
			old.IsNewMainStateValid != current.IsNewMainStateValid)
		{
			debugText += "\n┃IsNewMainStateValid: " + old.IsNewMainStateValid.ToString() +
				" -> " + current.IsNewMainStateValid.ToString();
		}
		
		// InGameState changes
		if (settings["DO_InGameState"] &&
			old.InGameState != current.InGameState)
		{
			debugText += "\n┃InGameState: " + old.InGameState.ToString() +
				" -> " + current.InGameState.ToString();
		}
		
		// IsCheatMenuOpen changes
		if (settings["DO_IsCheatMenuOpen"] &&
			old.IsCheatMenuOpen != current.IsCheatMenuOpen)
		{
			debugText += "\n┃IsCheatMenuOpen: " + old.IsCheatMenuOpen.ToString() +
				" -> " + current.IsCheatMenuOpen.ToString();
		}
		
		// AllowReturnToHub changes
		if (settings["DO_AllowReturnToHub"] &&
			vars.era == "OG" && // FIXME: how to handle this option for HD?
			old.AllowReturnToHub != current.AllowReturnToHub)
		{
			debugText += "\n┃AllowReturnToHub: " + old.AllowReturnToHub.ToString() +
				" -> " + current.AllowReturnToHub.ToString();
		}
		
		// IsMapLoaded changes
		if (settings["DO_IsMapLoaded"] &&
			old.IsMapLoaded != current.IsMapLoaded)
		{
			debugText += "\n┃IsMapLoaded: " + old.IsMapLoaded.ToString() +
				" -> " + current.IsMapLoaded.ToString();
		}
		
		// Print output
		if (debugText != "")
		{
			print("┏━━━━━━ " + vars.era.ToString() + " ━━━━━━━┓" +
				debugText +
				"\n┗━━━━━━━━━━━━━━━┛");
		}
	}
	
	return version != "";
}

start {
	// Reset progress list
	((IDictionary<string, object>)current).Remove("ProgressList");

	// Do not start timer if any boss warp has already been used
	// FIXME: I'm ASSUMING this is fixed in HD. and if so, can we hide this from the autosplitter settings menu?
	if (vars.era == "OG" &&
		settings["RequireUnusedBossWarps"] &&
		memory.ReadValue<int>((IntPtr)vars.AddrUsedBossWarps) != 0)
	{
		return false;
	}

	// Start on new game
	if (settings["SaveSlotStart"])
	{
		switch ((string)vars.era)
		{
			case "OG":
				// When main state is in transition from new game save slot screen -> running
				if (current.MainState == vars.MainState_NGSaveSlot &&
					current.IsNewMainStateValid != 0 &&
					current.NewMainState == vars.MainState_Running)
				{
					return true;
				}
				break;

			case "HD":
				// MainState_NGSaveSlot doesn't exist in HD
				// (because the new game / load game screens were merged with the main menu)
				// So instead, we can check the new game cutscene is being loaded
				int NewTribe = memory.ReadValue<int>((IntPtr)vars.AddrNewTribe);
				int NewLevel = memory.ReadValue<int>((IntPtr)vars.AddrNewLevel);
				int NewMap   = memory.ReadValue<int>((IntPtr)vars.AddrNewMap);
				int NewType  = memory.ReadValue<int>((IntPtr)vars.AddrNewType);
				if (current.MainState == vars.MainState_MainMenu &&
					// current.IsNewMainStateValid != 0 &&
					current.NewMainState == vars.MainState_Running &&
					NewTribe == 1 && NewLevel == 1 && NewMap == 2 && NewType == 3)
				{
					return true;
				}
				break;

				// Have yet to find the HD address for IsNewMainStateValid. Would be nice to include it in the logic here to be safe (because, yeah, sometimes NewMainState gets stuck on invalid values while on the main menu). However, we seem fine without it.

			default:
				return false;
		}
	}

	// The following start condition checks assume the game is running
	// and the current map is an ingame tribe and not a cutscene
	if (current.MainState != vars.MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5 || current.CurType == 3)
	{
		return false;
	}
	
	// Start on any input
	// FIXME: get this working on HD
	if (settings["InputStart"] && vars.era == "OG" &&
		current.Inputs != old.Inputs)
	{
		return true;
	}

	// IL start
	if (settings["ILstart"] && 
		vars.HasMapIDChanged(old, current) &&
		// Current map is a non-village map of Dante's World
		// or a non-village level of the Gobbo tribes
		(current.CurTribe == 5 ?
			current.CurMap > 1 :
			(current.CurType != 0 || current.CurLevel > 1)))
	{
		return true;
	}
	
	// OTS start (on hub entry)
	if (settings["OTSstart"] &&
		// entering hub
		// (no secret village for now; its OTS isn't set up yet)
		!vars.IsGobboHub(old) && vars.IsGobboHub(current) &&
		// disallow starting on cheat menu warp
		// (technically a valid SMP->__ segment start, but more intrusive than useful)
		!current.IsCheatMenuOpen &&
		// disallow starting after the opening cutscene when you start a new game
		!vars.IsThisMap(old, 1, 1, 2, 3) &&
		// disallow starting after loading a save
		!vars.IsThisMap(old, 0, 0, 4, 3) && // OG (save slot screen)
		!vars.IsThisMap(old, 0, 0, 0, 3) && // HD (main menu)
		// disallow starting after GOA in gobbo hub or secret hub (invalid spawn)
		!(
			// was on GOA screen
			vars.IsThisMap(old, 0, 0, 2, 3) &&
			// map before GOA is equal to current map (which is already constrained to hub)
			current.TribeB4GH == current.CurTribe &&
			current.LevelB4GH == current.CurLevel &&
			current.MapB4GH == current.CurMap &&
			current.TypeB4GH == current.CurType
		) &&
		// disallow starting on doing a wrong warp (invalid spawn)
		!(vars.era == "OG" && vars.IsWrongWarp(old, current)))
	{
		return true;
	}
	
	// OTS start (on SMP entry)
	if (settings["OTSstart_SMP"] &&
		vars.HasMapIDChanged(old, current) && vars.IsShopMap(current))
	{
		return true;
	}

	// IW start
	if (settings["IWstart"] &&
		// advancing to a later village
		old.CurTribe < current.CurTribe &&
		// was in one of these places
		(
			// SMP
			vars.IsShopMap(old) ||
			// anywhere, as long as the cheat menu was used
			old.IsCheatMenuOpen
		) &&
		// now in one of these places
		(
			// hub of cossack, caveman, or inca
			(vars.IsGobboHub(current) && current.CurTribe != 1) ||
			// hub of secret sailor
			vars.IsThisMap(current, 5, 2, 1, 0)
		))
	{
		return true;
	}
}

split {
	// Split on literally any map change
	if (settings["SplitOnMapChange_literal"] &&
		vars.HasMapIDChanged(old, current))
	{
		return true;
	}
	
	// Cancel if main state is not "running" or
	// current tribe is not an ingame tribe
	if (current.MainState != vars.MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5)
	{
		((IDictionary<string, object>)current).Remove("ProgressList");
		return false;
	}

	// Prevent IL/OTS end from being skipped when exiting via GOA
	// (is "old progress list" not available during this map change? which is why this must go up here?)
	if (settings["SplitOnMapChange"] &&
		vars.HasMapIDChanged(old, current) &&
		// was on GOA screen
		vars.IsThisMap(old, 0, 0, 2, 3) &&
		// disallow split after GOAing in gobbo hub or secret hub (invalid spawn)
		// FIXME: this might not be working properly in HD; I just got a split after GOA in caveman hub
		!(
			(
				vars.IsGobboHub(current) ||
				(current.CurTribe == 5 &&
				current.CurLevel >= 2 && current.CurLevel <= 4 &&
				current.CurMap == 1 &&
				current.CurType == 0)
			) &&
			// map before GOA is equal to current map (hub)
			current.TribeB4GH == current.CurTribe &&
			current.LevelB4GH == current.CurLevel &&
			current.MapB4GH == current.CurMap &&
			current.TypeB4GH == current.CurType
		))
	{
		return true;
	}
	
	// Prevent IL/OTS end from being skipped when exiting credits screen (ex: into Inca hub after beating Dante)
	// (the "old progress list" is not available when this map change happens)
	if (settings["SplitOnMapChange"] &&
		vars.HasMapIDChanged(old, current) &&
		// we came from the credits screen
		vars.IsThisMap(old, 0, 0, 5, 0))
	{
		return true;
	}
	
	// Read progress list
	const int ProgressListSize = 0xf0;
	vars.AddrProgressList = vars.AddrSaveSlot + vars.ProgressListOffset;
	current.ProgressList = memory.ReadBytes((IntPtr)vars.AddrProgressList, ProgressListSize);

	// Cancel if old progress list is not available
	if (!((IDictionary<string, object>)old).ContainsKey("ProgressList")) return false;

	// IL/OTS end
	if (settings["SplitOnMapChange"] &&
		vars.HasMapIDChanged(old, current) &&
		// disallow a split coming out of the main menu
		!vars.IsThisMap(old, 0, 0, 0, 3) &&
		// disallow the split after the opening cutscene when you start a new game
		!vars.IsThisMap(old, 1, 1, 2, 3) &&
		// disallow the split between dante and ending cutscene
		!(vars.IsThisMap(old, 4, 2, 1, 1) && vars.IsThisMap(current, 4, 2, 1, 3)) &&
		// disallow when changing maps within soveena, flytrap, and masher
		!(
			(current.CurTribe == 1 || current.CurTribe == 3) &&
			(current.CurLevel == 1 || current.CurLevel == 2) &&
			old.CurMap == 1 && current.CurMap == 2 &&
			current.CurType == 1
		) &&
		// disallow when re-entering for wrong warp
		// (not relevant for HD, cos you can only WW in OG (afaik...))
		!(vars.era == "OG" &&(
			// General case
			(
				vars.IsGobboHub(old) && !vars.IsGobboHub(current) &&
				old.TribeB4GH == current.CurTribe &&
				old.LevelB4GH == current.CurLevel &&
					// (allow the map to be different, so this works for levels like flytrap)
				old.TypeB4GH == current.CurType &&
				current.AllowReturnToHub == 1
			) ||
			// Masher (the only wrong warpable level with a cutscene)
			(
				// entered caveman hub from masher
				current.TribeB4GH == 3 &&
				current.LevelB4GH == 2 &&
					// (allow the map to be different, so this works for overworld or boss room)
				current.TypeB4GH == 1 &&
				// entering masher from caveman hub
				(
					// caveman hub -> masher cutscene
					(vars.IsThisMap(old, 3, 1, 1, 0) &&
					vars.IsThisMap(current, 3, 1, 1, 3)) ||
					// (caveman hub -> ) masher cutscene -> masher overworld
					(vars.IsThisMap(old, 3, 1, 1, 3) &&
					vars.IsThisMap(current, 3, 2, 1, 1))
				) &&
				// masher objective is complete
				current.ProgressList[129] % 2 == 1
			)
		)) &&
		// disallow when doing a wrong warp (invalid spawn)
		!(vars.era == "OG" && vars.IsWrongWarp(old, current)))
	{		
		return true;
	}

	// IW end
	// note that this is a suboption of objective style splits
	// (because it is redundant to use it with IL style splits)
	if (settings["SplitOnSMPEntry"] &&
		// was in hub, now in SMP
		vars.IsGobboHub(old) && vars.IsShopMap(current) &&
		// restrict to sailor through caveman
		// (inca ends on yellow dante crystal; secret ends on final egg)
		current.CurTribe >= 1 && current.CurTribe <= 3)
	{
		return true;
	}

	// Babies subsplits
	if (settings["BabiesSubsplits"] &&
		vars.IsThisMap(current, 4, 2, 1, 0) &&
		old.GobboCounter != current.GobboCounter &&
		settings["BabiesSubsplits_" + current.GobboCounter.ToString()])
	{
		return true;
	}
	
	// Split on collecting a gem (useful for IL runs)
	if (settings["SplitOnGem"] &&
		current.GemCounter == old.GemCounter+1)
	{
		return true;
	}

	// "Dante's Final Fight": Split when all crystals are placed
	if (vars.IsThisMap(current, 4, 2, 1, 1))
	{
		if (vars.AllDFCrystalsJustPlaced(memory, vars))
		{
			return true;
		}
	}
	
	// Split on final egg (for 100% / Max%)
	if (vars.IsThisMap(current, 5, 4, 1, 0))
	{
		const int SecretCavemanIdx = (5 * 40) + (4 * 4) + 0;
		int oldFlags = old.ProgressList[SecretCavemanIdx];
		int newFlags = current.ProgressList[SecretCavemanIdx];
		
		const int CrystalFlags = 0x1f;
		if ((oldFlags & ~CrystalFlags) != (newFlags & ~CrystalFlags))
		{
			return true;
		}
	}
	
	// Objective style splits
	if (settings["SplitOnObjectiveCompletion"] &&
		// (it may or may not be necessary to disable this for "Dante's Final Fight"?)
		!vars.IsThisMap(current, 4, 2, 1, 1))
	{
		for (int tribe = 1; tribe <= 5; ++tribe)
		for (int level = 1; level <= 7; ++level)
		for (int type  = 0; type  <= 3; ++type)
		{
			// Index into progress list
			int i = tribe * 40 + level * 4 + type;

			// Skip unchanged entries
			int oldFlags = old.ProgressList[i], newFlags = current.ProgressList[i];
			if (oldFlags == newFlags) continue;
			
			// Dante's World (Secret Village)
			if (tribe == 5)
			{
				const int CrystalFlags = 0x1f;
				
				// Split on both gems and eggs
				if (settings["SplitOnDanteCrystals"])
				{
					return true;
				}
				// Or only split on eggs
				else if ((oldFlags & ~CrystalFlags) != (newFlags & ~CrystalFlags))
				{
					return true;
				}
			}

			// Split on any progress change for certain levels
			else if (
				// Boss level or secret level (as in Jigsaw)
				type != 0 ||
				// "Bride of the Dungeon of Defright" or "Goo Man Chu's Tower"
				(tribe == 4 && (level == 5 || level == 6)))
			{
				return true;
			}
			
			// Other levels
			else
			{
				// Check for main objective and possibly Golden Gobbo
				int checkFlags = settings["SplitOnGoldenGobbo"] ? 5 : 1;
				int currentFlags = newFlags & checkFlags;
				// Split if all flags are set now and were not set previously
				if (currentFlags == checkFlags &&
					currentFlags != (oldFlags & checkFlags))
				{
					return true;
				}
			}
		}
	}
}

isLoading {
	// FIXME: check/compare HD vs OG
	// 	Particularly IsMapLoaded timing, and particularly GOA
	// FIXME: we might have been missing GOA loads cos mainstate != running? oops...
	// FIXME: is there any reason to enforce mainstate == running anyways?
	// 	if there is a load when doing SQ / GOA etc a load is still a load...?
	return current.MainState == vars.MainState_Running && (
		current.InGameState == 6 || current.InGameState == 7 ||
		!current.IsMapLoaded);
}
