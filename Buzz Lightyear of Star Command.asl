state("buzz") {}

init
{
	vars.initialized = false;

	var patterns = new List<dynamic>();
	var Pattern = new Func<int, string, dynamic>((offset, pattern) =>
	{
		dynamic p = new ExpandoObject(); patterns.Add(p);
		p.offset = offset; p.pattern = pattern;
		return p;
	});

	var gameVars = new List<dynamic>();
	var GameVar = new Action<Type, string, int, string>((type, name, offset, pattern) =>
	{
		var v = Pattern(offset, pattern); gameVars.Add(v);
		v.name = name; v.type = type;
	});

	var loads = new List<dynamic>();
	var Load = new Action<bool, string, int, int, string>((increment, name, overwrite, offset, pattern) =>
	{
		var l = Pattern(offset, pattern); loads.Add(l);
		l.increment = increment; l.name = name; l.overwrite = overwrite;
	});

	// Game variables
	GameVar(typeof(short), "bossHealth"       , 6, "83 C4 28 0F BF 05 ?? ?? ?? ?? C1 E0 0C"   );
	GameVar(typeof(short), "enterOrLeaveLevel", 5, "74 11 66 39 1D ?? ?? ?? ?? 75 08"         );
	GameVar(typeof(int  ), "level"            , 1, "A1 ?? ?? ?? ?? 83 EC 1C 83 F8 0F"         );
	GameVar(typeof(short), "levelDone"        , 5, "6A 3F 66 C7 05 ?? ?? ?? ?? 01 00 66 C7 05");
	GameVar(typeof(int  ), "titleResult"      , 5, "83 E0 09 40 A3 ?? ?? ?? ??"               );

	// Load removal
	Load(true , "LoadLevel: after PlayFmv"   , 5, 10, "83 C4 08 56 57 E8 ?? ?? ?? ?? A1 ?? ?? ?? ??");
	Load(false, "Leave LoadLevel"            , 5, 10, "68 ?? ?? ?? ?? E8 ?? ?? ?? ?? 83 C4 10 8B C5");
	Load(true , "Enter InitLevelPlay (US/UK)", 5,  0, "A1 ?? ?? ?? ?? 81 EC 10 01 00 00 53 55 56"   );
	Load(true , "Enter InitLevelPlay (PT-BR)", 5,  1, "55 8B EC 83 E4 F8 81 EC 0C 01 00 00"         );
	Load(false, "Leave InitLevelPlay"        , 5,  4, "8B 4C 24 ?? 68 ?? ?? ?? ?? 89 0D"            );
	Load(true , "Enter PlayFmv"              , 6,  0, "8B 7C 24 10 85 FF 74 0A"                     );
	Load(false, "Leave PlayFmv (1)"          , 5,  0, "83 C4 04 5F 5D C3"                           );
	Load(false, "Leave PlayFmv (2)"          , 5,  3, "5F 5D C3 ?? ?? ?? 5D C3"                     );
	Load(false, "Start FMV playback"         , 6,  0, "8B 2D ?? ?? ?? ?? 83 C4 24"                  );
	Load(true , "Leave ReleaseFmv"           , 5,  9, "FF 52 08 56 E8 ?? ?? ?? ?? 83 C4 04 5E C3"   );

	var ptrToInjectedCode = Pattern(0, "?? ?? ?? ?? 74 65 72 20 61");

	// Find addresses of byte patterns
	var mainModule = modules.First();
	var scanner = new SignatureScanner(game, mainModule.BaseAddress, mainModule.ModuleMemorySize);
	foreach (var p in patterns)
		p.addr = scanner.Scan(new SigScanTarget(p.offset, p.pattern));

	// Create memory watchers for game variables
	foreach (var v in gameVars)
	{
		if (v.addr == IntPtr.Zero)
		{
			print("Cannot determine address of \"" + v.name + "\".");
			return;
		}
		var addr = memory.ReadPointer((IntPtr)v.addr);
		var watcherType = typeof(MemoryWatcher<>).MakeGenericType(v.type);
		var watcher = Activator.CreateInstance(watcherType, addr);
		(vars as IDictionary<string, object>)[v.name] = watcher;
	}

	// Remove the absent one of the two "Enter InitLevelPlay" patterns
	if (loads.RemoveAll(l => l.name.StartsWith("Enter InitLevelPlay ") && l.addr == IntPtr.Zero) != 1)
	{
		print("Cannot determine address of InitLevelPlay.");
		return;
	}

	if (ptrToInjectedCode.addr == IntPtr.Zero)
	{
		print("Cannot determine whether load removal code was already injected.");
		return;
	}
	var injectAddr = memory.ReadPointer((IntPtr)ptrToInjectedCode.addr);

	// Inject load detection variable and code if not done yet
	if (injectAddr.ToInt32() == 0x6E697270)
	{
		// Allocate memory for load variable and code
		injectAddr = memory.AllocateMemory(4 + loads.Count * 11 + loads.Sum(l => l.overwrite));
		if (injectAddr == IntPtr.Zero)
		{
			print("AllocateMemory failed");
			return;
		}
		var ms = new MemoryStream(); var bw = new BinaryWriter(ms);
		// Int32 load variable
		bw.Write(0);
		// Code
		foreach (var l in loads)
		{
			l.jmpTarget = injectAddr + (int)ms.Length;
			// Increment/decrement load variable
			bw.Write(new byte[] { 0xFF, (byte)(l.increment ? 0x05 : 0x0D) });
			bw.Write(injectAddr.ToInt32());
			// Restore overwritten instructions
			bw.Write(memory.ReadBytes((IntPtr)l.addr, (int)l.overwrite));
			// Return (jmp)
			bw.Write((byte)0xE9);
			bw.Write(l.addr.ToInt32() + l.overwrite - injectAddr.ToInt32() - (int)ms.Length - 4);
		}

		// Write to game process
		memory.WriteBytes(injectAddr, ms.ToArray());
		memory.WriteValue((IntPtr)ptrToInjectedCode.addr, injectAddr.ToInt32());

		// Jump to injected code
		foreach (var l in loads)
			memory.WriteJumpInstruction((IntPtr)l.addr, (IntPtr)l.jmpTarget);
	}

	vars.isLoading = new MemoryWatcher<int>(injectAddr);

	vars.initialized = true;
}

update
{
	if (!vars.initialized) return false;
}

start
{
	var titleResult = vars.titleResult;
	if (!vars.titleResult.Update(game)) return false;
	return titleResult.Current == 2 && titleResult.Old == 0;
}

split
{
	var level = vars.level; level.Update(game);
	if (level.Current == 14)
	{
		var bossHealth = vars.bossHealth;
		if (level.Old != level.Current) bossHealth.Reset();
		bossHealth.Update(game);
		return bossHealth.Current <= 0 && bossHealth.Old > 0;
	}
	else
	{
		var enterOrLeave = vars.enterOrLeaveLevel; enterOrLeave.Update(game);
		if (enterOrLeave.Current == 0 || enterOrLeave.Old != 0) return false;
		var levelDone = vars.levelDone; levelDone.Update(game);
		return levelDone.Current == 1;
	}
}

isLoading
{
	var isLoading = vars.isLoading; isLoading.Update(game);
	return isLoading.Current > 0;
}
