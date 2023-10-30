#include <sourcemod>

#define PLUGIN_VERSION "1.0"


public Plugin:myinfo = 
{
	name = "LastMap",
	author = "sil_el_mot",
	description = "Last Map on Server",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};

public OnMapStart()
{
    decl String:mapname[128];
    GetCurrentMap(mapname, sizeof(mapname));
    PrintToServer("Mapname: %s", mapname);
    new Handle:mapfile = OpenFile("cfg/lastmap.cfg", "w");
    WriteFileLine(mapfile, "map %s",mapname);
    CloseHandle(mapfile)
}

