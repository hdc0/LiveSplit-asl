state("tarzan", "PC, US")
{
	int   ClaytonCountdown : 0x11C674;
	byte  ReachedUmbrella  : 0x11CDC5;
	short SaborDefeats     : 0x133BA0;
	byte  Level            : 0x133FE2;
	int   InGame           : 0x84604C;
}

state("tarzan", "PC, French")
{
	int   ClaytonCountdown : 0x10BEE4;
	byte  ReachedUmbrella  : 0x10C617;
	short SaborDefeats     : 0x123380;
	byte  Level            : 0x12381D;
	int   InGame           : 0x836DF4;
}

state("tarzan", "PC, Cast")
{
	int   ClaytonCountdown : 0x10BF24;
	byte  ReachedUmbrella  : 0x10C657;
	short SaborDefeats     : 0x1233C0;
	byte  Level            : 0x12385D;
	int   InGame           : 0x836E34;
}

state("tarzan", "PC, German")
{
	int   ClaytonCountdown : 0x10BEB4;
	byte  ReachedUmbrella  : 0x10C5E7;
	short SaborDefeats     : 0x123350;
	byte  Level            : 0x1237ED;
	int   InGame           : 0x836DC4;
}

state("tarzan", "PC, Italian")
{
	int   ClaytonCountdown : 0x10C0D4;
	byte  ReachedUmbrella  : 0x10C807;
	short SaborDefeats     : 0x123570;
	byte  Level            : 0x123A0D;
	int   InGame           : 0x836FE4;
}

state("tarzan", "PC, US, Patched")
{
	int   ClaytonCountdown : 0x1195F4;
	byte  ReachedUmbrella  : 0x119D45;
	short SaborDefeats     : 0x130B20;
	byte  Level            : 0x130F62;
	int   InGame           : 0x842FD4;
}

state("tarzan", "PC, UK, Patched")
{
	int   ClaytonCountdown : 0x108C64;
	byte  ReachedUmbrella  : 0x109397;
	short SaborDefeats     : 0x120100;
	byte  Level            : 0x12059D;
	int   InGame           : 0x833B74;
}

state("tarzan", "PC, Danish, Patched")
{
	int   ClaytonCountdown : 0x108DC4;
	byte  ReachedUmbrella  : 0x1094F7;
	short SaborDefeats     : 0x120260;
	byte  Level            : 0x1206FD;
	int   InGame           : 0x833CD4;
}

state("tarzan", "PC, Swedish, Patched")
{
	int   ClaytonCountdown : 0x108E94;
	byte  ReachedUmbrella  : 0x1095C7;
	short SaborDefeats     : 0x120330;
	byte  Level            : 0x1207CD;
	int   InGame           : 0x833DA4;
}

state("tarzan", "PC, German, Patched")
{
	int   ClaytonCountdown : 0x108E94;
	byte  ReachedUmbrella  : 0x1095C7;
	short SaborDefeats     : 0x120330;
	byte  Level            : 0x1207CD;
	int   InGame           : 0x833DA4;
}

state("tarzan", "PC, Norweg, Patched")
{
	int   ClaytonCountdown : 0x108F24;
	byte  ReachedUmbrella  : 0x109657;
	short SaborDefeats     : 0x1203C0;
	byte  Level            : 0x12085D;
	int   InGame           : 0x833E34;
}

state("tarzan", "PC, French, Patched")
{
	int   ClaytonCountdown : 0x108EC4;
	byte  ReachedUmbrella  : 0x1095F7;
	short SaborDefeats     : 0x120360;
	byte  Level            : 0x1207FD;
	int   InGame           : 0x833DD4;
}

state("tarzan", "PC, Finnish, Patched")
{
	int   ClaytonCountdown : 0x108EF4;
	byte  ReachedUmbrella  : 0x109627;
	short SaborDefeats     : 0x120390;
	byte  Level            : 0x12082D;
	int   InGame           : 0x833E04;
}

state("tarzan", "PC, Dutch, Patched")
{
	int   ClaytonCountdown : 0x108DC4;
	byte  ReachedUmbrella  : 0x1094F7;
	short SaborDefeats     : 0x120260;
	byte  Level            : 0x1206FD;
	int   InGame           : 0x833CD4;
}

state("tarzan", "PC, Cast, Patched")
{
	int   ClaytonCountdown : 0x108F04;
	byte  ReachedUmbrella  : 0x109637;
	short SaborDefeats     : 0x1203A0;
	byte  Level            : 0x12083D;
	int   InGame           : 0x833E14;
}

state("tarzan", "PC, Italian, Patched")
{
	int   ClaytonCountdown : 0x1090B4;
	byte  ReachedUmbrella  : 0x1097E7;
	short SaborDefeats     : 0x120550;
	byte  Level            : 0x1209ED;
	int   InGame           : 0x833FC4;
}

init
{
	var versions = new dynamic[,]
	{
		{ 0x374D3468, 0x0E8, "PC, US" },
		{ 0x38033A56, 0x0E8, "PC, French" },
		{ 0x3805AF46, 0x0E8, "PC, Cast" },
		{ 0x380EF2A5, 0x0E8, "PC, German" },
		{ 0x38102BC9, 0x0E8, "PC, Italian" },
		{ 0x38C4E96E, 0x100, "PC, US, Patched" },
		{ 0x38C7B9BE, 0x0F0, "PC, UK, Patched" },
		{ 0x38C7C7B7, 0x0F0, "PC, Danish, Patched" },
		{ 0x38C7CDFB, 0x0F0, "PC, Swedish, Patched" },
		{ 0x38C7CFD5, 0x0F0, "PC, German, Patched" },
		{ 0x38C7D1A8, 0x0F0, "PC, Norweg, Patched" },
		{ 0x38C7D39C, 0x0F0, "PC, French, Patched" },
		{ 0x38C7D926, 0x0F0, "PC, Finnish, Patched" },
		{ 0x38C7DCFE, 0x0F0, "PC, Dutch, Patched" },
		{ 0x38C7DED7, 0x0F0, "PC, Cast, Patched" },
		{ 0x38C7E219, 0x0F0, "PC, Italian, Patched" }
	};
	var baseAddr = modules.First().BaseAddress;
	for (int i = 0; i < versions.GetLength(0); ++i)
	{
		var timestamp = versions[i, 0];
		IntPtr posTimestamp = baseAddr + versions[i, 1];
		var name = versions[i, 2];
		if (memory.ReadValue<int>(posTimestamp) == timestamp)
		{
			version = name;
			break;
		}
	}
}

update
{
	return version != "";
}

start
{
	return current.InGame != 0;
}

split
{
	if (current.InGame == 0) return false;

	const int Level_Welcome = 1;
	const int Level_Sabor = 6;
	const int Level_Clayton = 13;

	if (current.Level == Level_Sabor)
	{
		return old.SaborDefeats != current.SaborDefeats && (current.SaborDefeats & 4) != 0;
	}
	else if (current.Level == Level_Clayton)
	{
		return old.ClaytonCountdown != current.ClaytonCountdown;
	}
	else if (current.Level >= Level_Welcome && current.Level < Level_Clayton)
	{
		return old.ReachedUmbrella != current.ReachedUmbrella && (current.ReachedUmbrella & 0x40) != 0;
	}
}
