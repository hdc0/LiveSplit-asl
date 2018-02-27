state("Croc2", "US")
{
	int CurTribe            : 0xA8C44;
	int CurLevel            : 0xA8C48;
	int CurMap              : 0xA8C4C;
	int CurType             : 0xA8C50;
	int InGameState         : 0xB7880;
	int IsCheatMenuOpen     : 0xB788C;
	bool IsMapLoaded        : 0xB78C4;
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
	bool IsMapLoaded        : 0xBEAB4;
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
	settings.Add("SplitOnMapChange", false,
		"Split on map change");

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

	if (settings["StartOnFirstLevel"] &&
		// New map loaded
		old.InGameState != 0 && current.InGameState == 0 && (
		// Current map is a non-village map of Dante's World
		// or a non-village level of the Gobbo tribes
		current.CurTribe == 5 ? current.CurMap > 1 : current.CurLevel > 1))
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
		for (int i = 0; i < ProgressListSize; ++i)
		{
			// Skip village levels
			if (i % 40 == 4) continue;

			byte ignoreFlags = 0;
			// Ignore "wheel collected" flags of
			// "Find the Wheels in the Jungle!" and
			// "Find the Wheels in the Mine!"
			if (i == 128 || i == 132) ignoreFlags = 0x30;
			// Ignore "race entered" flag of "Race Day at Goldrock"
			if (i == 136) ignoreFlags = 0x40;

			// Split if any non-ignored flags have changed
			if (((old.ProgressList[i] ^ current.ProgressList[i]) &
				~ignoreFlags) != 0)
			{
				return true;
			}
		}
	}

	// Split on map change (except when changing from or to shop map)
	if (settings["SplitOnMapChange"] && (
		old.CurTribe != current.CurTribe ||
		old.CurLevel != current.CurLevel ||
		old.CurMap   != current.CurMap   ||
		old.CurType  != current.CurType) &&
		!vars.IsShopMap(old) && !vars.IsShopMap(current))
	{
		return true;
	}
}

isLoading
{
	return !current.IsMapLoaded;
}
