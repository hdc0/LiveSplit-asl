// LiveSplit auto splitter for Disney's Tarzan Action Game (PC)

state("tarzan") {}

init
{
	(vars as IDictionary<string, object>).Clear();
	vars.Initialized = false;

	var variables = new dynamic[,]
	{
		{ typeof(int  ), "ClaytonCountdown", 4, "89 7E 18 A1 ?? ?? ?? ?? 48"                      }, // US: 0x11C674
		{ typeof(byte ), "ReachedUmbrella" , 8, "66 C7 43 48 02 00 80 0D ?? ?? ?? ?? 40 83 C4 0C" }, // US: 0x11CDC5
		{ typeof(short), "SaborDefeats"    , 5, "D3 E2 66 09 15 ?? ?? ?? ?? 8A 4F 75"             }, // US: 0x133BA0
		{ typeof(byte ), "Level"           , 3, "8A 01 A2 ?? ?? ?? ?? 33 C9"                      }, // US: 0x133FE2
		{ typeof(int  ), "InGame"          , 3, "75 23 A1 ?? ?? ?? ?? 85 C0 74 1A"                }  // US: 0x84604C
	};

	var mainModule = modules.First();
	var scanner = new SignatureScanner(game, mainModule.BaseAddress, mainModule.ModuleMemorySize);
	vars.memoryWatcherList = new MemoryWatcherList();
	for (int i = 0; i < variables.GetLength(0); ++i)
	{
		var varType   = variables[i, 0];
		var name      = variables[i, 1];
		var offset    = variables[i, 2];
		var signature = variables[i, 3];

		var addr = scanner.Scan(new SigScanTarget(offset, signature));
		if (addr == IntPtr.Zero)
		{
			print(string.Format("Cannot determine address of variable \"{0}\".", name));
			return;
		}

		var varAddr = memory.ReadPointer(addr);
		print(string.Format("Variable \"{0}\" is stored at 0x{1:X}.", name, varAddr.ToInt32()));
		var watcherType = typeof(MemoryWatcher<>).MakeGenericType(varType);
		var watcher = Activator.CreateInstance(watcherType, varAddr);
		vars.memoryWatcherList.Add(watcher);
		(vars as IDictionary<string, object>).Add(name, watcher);
		watcher.Update(game);
	}

	vars.Initialized = true;
}

update
{
	if (!vars.Initialized)
		return false;
	vars.memoryWatcherList.UpdateAll(game);
}

start
{
	return vars.InGame.Current != 0;
}

split
{
	if (vars.InGame.Current == 0)
		return false;

	const int Level_Welcome = 1;
	const int Level_Sabor = 6;
	const int Level_Clayton = 13;

	var level = vars.Level.Current;
	if (level == Level_Sabor)
	{
		var sd = vars.SaborDefeats;
		return sd.Old != sd.Current && (sd.Current & 4) != 0;
	}
	else if (level == Level_Clayton)
	{
		var cc = vars.ClaytonCountdown;
		return cc.Old != cc.Current;
	}
	else if (level >= Level_Welcome && level < Level_Clayton)
	{
		var ru = vars.ReachedUmbrella;
		return ru.Old != ru.Current && (ru.Current & 0x40) != 0;
	}
}
