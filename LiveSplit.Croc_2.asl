state("Croc2", "US")
{
	bool IsMapLoaded        : 0xB78C4;
	int NewMainState        : 0xB7930;
	int IsNewMainStateValid : 0xB7934;
	int MainState           : 0xB793C;
}

state("Croc2", "EU")
{
	bool IsMapLoaded        : 0xBEAB4;
	int NewMainState        : 0xBEB20;
	int IsNewMainStateValid : 0xBEB24;
	int MainState           : 0xBEB2C;
}

init
{
	var firstModule = modules.First();
	var baseAddr = firstModule.BaseAddress;
	switch (firstModule.ModuleMemorySize)
	{
		case 0x23A000:
			version = "US";
			vars.AddrSaveSlots      = baseAddr + 0x2040C0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2220FC;
			break;
		case 0x242000:
			version = "EU";
			vars.AddrSaveSlots      = baseAddr + 0x20B2B0;
			vars.AddrCurSaveSlotIdx = baseAddr + 0x2292EC;
			break;
	}
}

update
{
	return version != "";
}

start
{
	// Start when main state is in transition from "save slot selection" to "running"
	const int MainState_ChooseSaveSlot =  2;
	const int MainState_Running        = 11;
	return
		current.MainState == MainState_ChooseSaveSlot &&
		current.IsNewMainStateValid != 0 &&
		current.NewMainState == MainState_Running;
}

split
{
	// Cancel if main state is not "running"
	const int MainState_Running = 11;
	if (current.MainState != MainState_Running) return false;

	// Read progress list
	const int SaveSlotSize = 0x2000;
	var addrSaveSlot = vars.AddrSaveSlots +
		memory.ReadValue<int>((IntPtr)vars.AddrCurSaveSlotIdx) * SaveSlotSize;
	current.ProgressList = memory.ReadBytes((IntPtr)addrSaveSlot + 0x2d0, 0xf0);

	// Cancel if old progress list is not available
	if (!((IDictionary<string, object>)old).ContainsKey("ProgressList")) return false;

	// Check whether progress has changed
	for (int tribe = 1; tribe <= 4; ++tribe)
	{
		// Level completed?
		for (int level = 2; level <= 7; ++level)
		{
			int index = (tribe * 10 + level) * 4;
			if ((old.ProgressList[index] & 1) != (current.ProgressList[index] & 1))
			{
				return true;
			}
		}
		// Boss defeated?
		for (int boss = 1; boss <= 2; ++boss)
		{
			int index = (tribe * 10 + boss) * 4 + 1;
			if ((old.ProgressList[index] & 1) != (current.ProgressList[index] & 1))
			{
				return true;
			}
		}
	}
}

isLoading
{
	return !current.IsMapLoaded;
}
