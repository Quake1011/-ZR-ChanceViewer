#include <zombiereloaded>

Handle g_hTimer;
char sMode[12];

public Plugin myinfo = 
{ 
	name = "[ZR] ChanceViewer", 
	author = "Palonez", 
	description = "Output common chance of infection", 
	version = "1.0.0.1", 
	url = "https://github.com/Quake1011" 
};

public void OnPluginStart()
{
	HookEvent("round_start", EventRoundStart, EventHookMode_Post);
}

public void EventRoundStart(Event hEvent, const char[] sEvent, bool bdb)
{
	GetConVarString(FindConVar("zr_infect_mzombie_mode"), sMode, sizeof(sMode));
	if(!(StrEqual(sMode, "absolute", true) && GetActivePlayers() >= GetConVarInt(FindConVar("zr_infect_mzombie_ratio")))) return;
	
	g_hTimer = CreateTimer(1.0, Counter, _, TIMER_REPEAT);
	CreateTimer(GetConVarFloat(FindConVar("zr_infect_spawntime_max"))+float(GetConVarInt(FindConVar("mp_freezetime"))), Delete);	
}

public Action Counter(Handle hTimer)
{
	int iActives = GetActivePlayers(), ratio = GetConVarInt(FindConVar("zr_infect_mzombie_ratio"));
	float fChance;
	
	GetConVarString(FindConVar("zr_infect_mzombie_mode"), sMode, sizeof(sMode));
	
	if(StrEqual(sMode, "absolute", true)) fChance = float(ratio/iActives);
	else if(StrEqual(sMode, "dynamic", true)) fChance = float(1/ratio);
	
	SetHudTextParams(0.4, 0.4, 1.0, 255, 255, 255, 255);
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i))
			ShowHudText(i, -1, "A chance to become a zombie: %.3f", fChance);
			
	return Plugin_Continue;
}

public Action Delete(Handle hTimer)
{
	KillTMR(g_hTimer);
	return Plugin_Continue;
}

public void ZR_OnClientInfected(int client, int attacker, bool motherinfect, bool respawnoverride, bool respawn)
{
	if(motherinfect)
	{
		KillTMR(g_hTimer);
		return;
	}
}

stock int GetActivePlayers()
{
	int k = 0;
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && GetClientTeam(i) > 1 && IsPlayerAlive(i)) k++
		
	return k;
}

stock void KillTMR(Handle xHandle)
{
	if(xHandle != INVALID_HANDLE)
	{
		KillTimer(xHandle);
		xHandle = null;
	}
}
