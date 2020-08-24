#pragma semicolon 1

#include <sourcemod>
#include <shop>
#include <multicolors>

#pragma newdecls required

ConVar STEAM1;
ConVar STEAM2;

public Plugin myinfo = 
{
	name = "Giveaway Credits Shop",
	author = "Pizant",
	description = "Gives Credits To All Players Who Plays",
	version = "1.0"
};

public void OnPluginStart()
{
	STEAM1 = CreateConVar("steam1_bet", "STEAMID", "SteamID-ul nr.1");
	STEAM2 = CreateConVar("steam2_bet", "STEAMID", "SteamID-ul nr.2");
	AutoExecConfig(true, "GiveawayCredits");
	RegConsoleCmd("sm_giveaway", Cmd_Giveaway);
}

public Action Cmd_Giveaway(int client, int args)
{
	if(args == 1)
	{
		char steam1[24], steam2[24], steamid1[24], steamid2[24];
		GetClientAuthId(client, AuthId_Steam2, steamid1, sizeof(steamid1));
		GetClientAuthId(client, AuthId_Steam2, steamid2, sizeof(steamid2));
		GetConVarString(STEAM1, steam1, sizeof(steam1));
		GetConVarString(STEAM2, steam2, sizeof(steam2));
		if(GetUserFlagBits(client) == ADMFLAG_ROOT || StrEqual(steam1, steamid1) || StrEqual(steam2, steamid2))
		{
			char s[10];
			int sum;
			GetCmdArg(1, s, sizeof(s));
			sum = StringToInt(s);
			if(sum <= 10000)
				for(int i = 0; i < MaxClients; i++)
				{
					if(IsValidClient(i))
					{
						Shop_GiveClientCredits(i, sum);
						CPrintToChat(i, "{default}[{green} BETIVII {default}] Ai primit cadou {red}%d credite{default} de la eveniment. Iti multumim ca esti alaturi de noi!", sum);
					}
						
				}
		}
	}
	return Plugin_Handled;
}

stock bool IsValidClient(int client){
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	if(IsFakeClient(client)) return false;
	return IsClientInGame(client);
}