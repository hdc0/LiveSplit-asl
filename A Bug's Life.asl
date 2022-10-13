// LiveSplit auto splitter for A Bug's Life (PC)

state("bugs") {}

init
{
	(vars as IDictionary<string, object>).Clear();
	vars.Initialized = false;

	var mainModule = modules.First();
	var scanner = new SignatureScanner(game, mainModule.BaseAddress, mainModule.ModuleMemorySize);

	var findVariables = new Func<bool>(() =>
	{
		var variables = new dynamic[,]
		{
			{ typeof(int  ), "MainMenuSelection", 3, "33 C9 A1 ?? ?? ?? ?? 3D 00 80 FF FF"    }, // 4DE09C
			{ typeof(short), "LevelDone"        , 3, "66 83 3D ?? ?? ?? ?? 02 75 0B"          }, // 59A5B0
			{ typeof(int  ), "EnterLevel"       , 7, "BE 17 00 00 00 39 3D ?? ?? ?? ?? 74 0C" }  // 5A9234
		};

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
				return false;
			}

			var varAddr = memory.ReadPointer(addr);
			print(string.Format("Variable \"{0}\" is stored at 0x{1:X}.", name, varAddr.ToInt32()));
			var watcherType = typeof(MemoryWatcher<>).MakeGenericType(varType);
			var watcher = Activator.CreateInstance(watcherType, varAddr);
			(vars as IDictionary<string, object>).Add(name, watcher);
			watcher.Update(game);
		}

		return true;
	});

	var initLoadDetection = new Func<bool>(() =>
	{
		// Determine memory address to store load variable

		var isLoadingAddr = scanner.Scan(new SigScanTarget(18,
			"41 63 63 65 73 73 20 69 73 20 64 65 6E 69 65 64 2E 00 ?? ?? ?? ?? 00 00 " +
			"4E 6F 20 65 72 72 6F 72 2E 00"
		));

		vars.IsLoading = new MemoryWatcher<int>(isLoadingAddr);
		vars.IsLoading.Current = 0;
		vars.IsLoading.Enabled = (isLoadingAddr != IntPtr.Zero);

		if (isLoadingAddr == IntPtr.Zero)
		{
			print("Cannot find address to store load variable.");
			return false;
		}

		print(string.Format("Load detection variable will be stored at 0x{0:X}.", isLoadingAddr.ToInt32()));

		// Inject load detection code

		var hooks = new dynamic[,]
		{
			{  0, "81 EC A0 00 00 00"                                                               , 6, true  }, // 0x4129A0 Enter PlayAnim
			{ 20, "0F 85 ?? ?? 00 00 E8 ?? ?? ?? ?? E8 ?? ?? ?? ?? ?? ?? ?? ?? 81 C4 A0 00 00 00 C3", 6, false }, // 0x412CB4 Leave PlayAnim 1
			{ 20, "?? E8 ?? ?? ?? ?? E8 ?? ?? ?? ?? E8 ?? ?? ?? ?? ?? ?? ?? ?? 81 C4 A0 00 00 00 C3", 6, false }, // 0x412DEE Leave PlayAnim 2
			{  0, "53 8B 5C 24 0C 56 57 85"                                                         , 5, true  }, // 0x4132E0 Enter PlayFmv
			{  0, "A1 ?? ?? ?? ?? 85 C0 75 0D"                                                      , 5, false }, // 0x41335A PlayFmv: after ClearLoadScreen call
			{  0, "83 EC 08 53 56 57 68"                                                            , 5, false }, // 0x42E150 Enter ClearLoadScreen
			{  0, "5E 5B 83 C4 08"                                                                  , 5, true  }, // 0x42E2EE Leave ClearLoadScreen
			{  0, "8B 6C 24 14 83 F8 08"                                                            , 7, true  }, // 0x42E609 LoadLevel: after PlayFmv call
			{  9, "15 E8 ?? ?? ?? ?? 83 C4 04 8B C6 5F 5E 5D 5B C3"                                 , 5, false }, // 0x42EA1F Leave LoadLevel 1
			{  9, "50 E8 ?? ?? ?? ?? 83 C4 04 8B C6 5F 5E 5D 5B C3"                                 , 5, false }, // 0x42EA31 Leave LoadLevel 2
			{  0, "81 EC 8C 00 00 00 53 8B"                                                         , 6, true  }, // 0x4671D0 Enter InitLevelPlay
			{  7, "89 0D ?? ?? ?? ?? 5B 81 C4 8C 00 00 00"                                          , 6, false }, // 0x4679DE Leave InitLevelPlay
			{  0, "FF ?? 1C 8B F8"                                                                  , 5, false }, // 0x49BDAA PlayAMMMStream: start playback
			{  0, "53 ?? FF ?? 1C"                                                                  , 5, true  }  // 0x49BDF0 PlayAMMMStream: stop playback
		};

		for (int i = 0; i < hooks.GetLength(0); ++i)
		{
			var signatureOffset  = hooks[i, 0];
			var signature        = hooks[i, 1];
			int overwrittenBytes = hooks[i, 2];
			var increment        = hooks[i, 3];

			// Find address
			var hookAddr = scanner.Scan(new SigScanTarget(signatureOffset, signature));
			if (hookAddr == IntPtr.Zero)
			{
				print(string.Format("Cannot find load detection signature {0}.", i));
				break;
			}
			print(string.Format("Load detection signature {0} found at 0x{1:X}.", i, hookAddr.ToInt32()));

			/*
			inc/dec <load variable>
			jmp     <LiveSplit detour gate>
			*/
			var code = new byte[] { 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0xE9, 0x00, 0x00, 0x00, 0x00 };

			// Allocate memory for code
			var codeAddr = memory.AllocateMemory(code.Length);
			if (codeAddr == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();

			// Adjust code and inject it
			code[1] = (byte)(increment ? 0x05 : 0x0D);
			BitConverter.GetBytes(isLoadingAddr.ToInt32()).CopyTo(code, 2);
			var gateAddr = memory.WriteDetour(hookAddr, overwrittenBytes, codeAddr);
			BitConverter.GetBytes(gateAddr.ToInt32() - codeAddr.ToInt32() - 11).CopyTo(code, 7);
			if (!memory.WriteBytes(codeAddr, code)) throw new System.ComponentModel.Win32Exception();
		}

		return true;
	});

	if (!findVariables()) return;
	initLoadDetection();

	vars.Initialized = true;
}

update
{
	return vars.Initialized;
}

start
{
	var menuSel = vars.MainMenuSelection; menuSel.Update(game);
	var enterLevel = vars.EnterLevel; enterLevel.Update(game);
	return (
		enterLevel.Old == 0 && enterLevel.Current != 0 &&
		Array.IndexOf(new[] {
				128, 199, 241,  43, 125, 168, 225,  51,
				107, 149, 217,   3,  42, 121, 161, 210
			}, menuSel.Current) != -1
	);
}

split
{
	var levelDone = vars.LevelDone; levelDone.Update(game);
	return levelDone.Old == 0 && levelDone.Current == 1;
}

isLoading
{
	var isLoading = vars.IsLoading; isLoading.Update(game);
	return isLoading.Current > 0;
}
