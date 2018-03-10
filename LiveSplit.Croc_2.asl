state("Croc2", "US")
{
	int CurTribe            : 0xA8C44;
	int CurLevel            : 0xA8C48;
	int CurMap              : 0xA8C4C;
	int CurType             : 0xA8C50;
	int InGameState         : 0xB7880;
	int IsCheatMenuOpen     : 0xB788C;
	int NewMainState        : 0xB7930;
	int IsNewMainStateValid : 0xB7934;
	int MainState           : 0xB793C;
	int DFCrystal5IP        : 0x223D10;
}

state("Croc2", "EU")
{
	int CurTribe            : 0xA9C44;
	int CurLevel            : 0xA9C48;
	int CurMap              : 0xA9C4C;
	int CurType             : 0xA9C50;
	int InGameState         : 0xBEA70;
	int IsCheatMenuOpen     : 0xBEA7C;
	int NewMainState        : 0xBEB20;
	int IsNewMainStateValid : 0xBEB24;
	int MainState           : 0xBEB2C;
	int DFCrystal5IP        : 0x22AF00;
}

startup
{
	settings.Add("StartAfterSaveSlotChosen", true,
		"Save slot start");
	settings.Add("StartOnFirstLevel", false,
		"IL start");
	settings.Add("StartOnHubCheat", false,
		"IW start");
	settings.Add("SplitOnGoldenGobbo", false,
		"100% splits");
	settings.Add("SplitOnMapChange", false,
		"Split on map change");

	// Returns true iff the current map ID changed
	vars.HasMapIDChanged = new Func<dynamic, dynamic, bool>((state1, state2) =>
		state1.CurTribe != state2.CurTribe || state1.CurLevel != state2.CurLevel ||
		state1.CurMap != state2.CurMap || state1.CurType != state2.CurType);

	// Returns true iff map is "Swap Meet Pete's General Store"
	vars.IsShopMap = new Func<dynamic, bool>(state =>
		state.CurTribe >= 1 && state.CurTribe <= 4 &&
		state.CurLevel == 1 && state.CurMap == 4 && state.CurType == 0);
}

init
{
	var firstModule = modules.First();
	var baseAddr = firstModule.BaseAddress;
	int addrScriptMgr;
	switch (firstModule.ModuleMemorySize)
	{
		case 0x23A000:
			version = "US";
			addrScriptMgr = 0xB78BC;
			vars.AddrSaveSlots      = baseAddr + 0x2040C0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2220FC;
			vars.DFCrystal5FinalIP  = 0x1741C8;
			break;
		case 0x242000:
			version = "EU";
			addrScriptMgr = 0xBEAAC;
			vars.AddrSaveSlots      = baseAddr + 0x20B2B0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2292EC;
			vars.DFCrystal5FinalIP  = 0x174210;
			break;
		default:
			return;
	}

	vars.ScriptCodeStart = new DeepPointer(addrScriptMgr, 0x1C);
}

update
{
	return version != "";
}

start
{
	const int MainState_ChooseSaveSlot =  2;
	const int MainState_Running        = 11;
	const int MainState_LevelSelect    = 18;

	// Start when main state is in transition from
	// "level select" or "save slot selection" to "running"
	if (settings["StartAfterSaveSlotChosen"] && (
		current.MainState == MainState_ChooseSaveSlot ||
		current.MainState == MainState_LevelSelect) &&
		current.IsNewMainStateValid != 0 &&
		current.NewMainState == MainState_Running)
	{
		return true;
	}

	// The following start condition checks assume the game is running
	// and the current map is an ingame tribe and not a cutscene
	if (current.MainState != MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5 || current.CurType == 3)
	{
		return false;
	}

	if (settings["StartOnFirstLevel"] && (
		// New map loaded
		old.InGameState != current.InGameState ||
		vars.HasMapIDChanged(old, current)) &&
		current.InGameState == 0 && (
		// Current map is a non-village map of Dante's World
		// or a non-village level of the Gobbo tribes
		current.CurTribe == 5 ?
			current.CurMap > 1 :
			(current.CurType != 0 || current.CurLevel > 1)))
	{
		return true;
	}

	if (settings["StartOnHubCheat"] &&
		// Cheat menu is open while loading a new map
		current.IsCheatMenuOpen != 0 && current.InGameState == 7)
	{
		return true;
	}
}

split
{
	// Cancel if main state is not "running" or
	// current tribe is not an ingame tribe
	const int MainState_Running = 11;
	if (current.MainState != MainState_Running ||
		current.CurTribe < 1 || current.CurTribe > 5)
	{
		((IDictionary<string, object>)current).Remove("ProgressList");
		return false;
	}

	// Read progress list
	const int SaveSlotSize = 0x2000;
	var addrSaveSlot = vars.AddrSaveSlots +
		memory.ReadValue<int>((IntPtr)vars.AddrCurSaveSlotIdx) * SaveSlotSize;
	const int ProgressListSize = 0xf0;
	current.ProgressList = memory.ReadBytes(
		(IntPtr)addrSaveSlot + 0x2d0, ProgressListSize);

	// Cancel if old progress list is not available
	if (!((IDictionary<string, object>)old).ContainsKey("ProgressList")) return false;

	// "Dante's Final Fight": Split when last crystal is placed
	if (current.CurTribe == 4 && current.CurLevel == 2 &&
		current.CurMap == 1 && current.CurType == 1)
	{
		if (old.DFCrystal5IP != current.DFCrystal5IP && current.DFCrystal5IP ==
			vars.ScriptCodeStart.Deref<int>(game) + vars.DFCrystal5FinalIP)
		{
			return true;
		}
	}
	// Other levels: check whether progress has changed
	else
	{
		for (int tribe = 1; tribe <= 5; ++tribe)
		for (int level = 1; level <= 7; ++level)
		for (int type  = 0; type  <= 3; ++type)
		{
			// Index into progress list
			int i = tribe * 40 + level * 4 + type;

			// Skip unchanged entries
			if (old.ProgressList[i] == current.ProgressList[i]) continue;

			// Split on any progress change for certain levels
			if (
				// Dante's Secret World
				tribe == 5 ||
				// Boss level or secret level
				type != 0 ||
				// "Bride of the Dungeon of Defright" or "Goo Man Chu's Tower"
				(tribe == 4 && (level == 5 || level == 6)))
			{
				return true;
			}

			// Check for main objective and possibly Golden Gobbo
			int checkFlags = settings["SplitOnGoldenGobbo"] ? 5 : 1;
			int currentFlags = current.ProgressList[i] & checkFlags;
			// Split if all flags are set now and were not set previously
			if (currentFlags == checkFlags &&
				currentFlags != (old.ProgressList[i] & checkFlags))
			{
				return true;
			}
		}
	}

	// Split on map change (except when changing from or to shop map)
	if (settings["SplitOnMapChange"] && vars.HasMapIDChanged(old, current) &&
		!vars.IsShopMap(old) && !vars.IsShopMap(current))
	{
		return true;
	}
}

isLoading
{
	const int MainState_Running = 11;
	return current.MainState == MainState_Running && current.InGameState == 7;
}
