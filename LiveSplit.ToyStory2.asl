state("toy2", "English")
{
	uint level : 0x15a0e4;
}

state("toy2", "German")
{
	uint level : 0x15c824;
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case 0xa7f000: version = "English"; break;
		case 0xa81000: version = "German"; break;
	}
}

update { return version != ""; }

split { return current.level != old.level; }
