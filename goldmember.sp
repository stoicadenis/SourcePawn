#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <vip_core>
#include <multicolors>

public Plugin:myinfo = 
{
	name = "Goldmember",
	author = "Pizant",
	description = "DNS BENEFITS",
	version = "1.0"
};

bool b_IsGoldMember[MAXPLAYERS + 1]; 

ConVar g_hServerName;
ConVar g_hGoldEnable;

public void OnPluginStart()
{
	g_hServerName = CreateConVar("goldmember_servername", "betivii.1tap.ro", "Your server/community names that players must have in their nickname");
	g_hGoldEnable = CreateConVar("goldmember_enable", "1", "Activeaza sau nu pluginul? 0 - NU / 1 - DA");
	AutoExecConfig(true, "goldmember");
		
	HookEventEx("player_spawn", Event_Spawn);
}

public void OnMapStart(){
	for(int i=1;i<=MaxClients;i++){
		b_IsGoldMember[i]= false;
	}
}

public void OnClientDisconnect(int client){
	b_IsGoldMember[client]= false;
}

public void OnClientPutInServer(int client)
{
	char sName[MAX_NAME_LENGTH], g_sDNS[MAX_NAME_LENGTH];
	char grupa[20];
	
	GetConVarString(g_hServerName, g_sDNS, sizeof(g_sDNS));
	GetClientName(client, sName, MAX_NAME_LENGTH);
	
	if(StrContains(sName, g_sDNS, false) > -1)
		b_IsGoldMember[client] = true;
	if(b_IsGoldMember[client]){
		if(VIP_IsClientVIP(client)){
			VIP_GetClientVIPGroup(client, grupa, sizeof(grupa))
			if(StrContains(grupa,"vip", false)){
				CPrintToChat(client, " ");
			CPrintToChat(client, "{green}[BETIVII] {default}Ai {lime}Goldmember VIP {default}datorita DNS-ului din nume! Iti multumim ca esti alaturi de noi :)");
			CPrintToChat(client, "{green}Avantaje{default}: Speed, Tracers, Bhop, Tag si ChatTag ");
			CPrintToChat(client, " ");
				return;
			}
		}
		else{
			VIP_GiveClientVIP(0, client, 0, "Goldmember VIP", false);
			CPrintToChat(client, " ");
			CPrintToChat(client, "{green}[BETIVII] {default}Ai {lime}Goldmember VIP {default}datorita DNS-ului din nume! Iti multumim ca esti alaturi de noi :)");
			CPrintToChat(client, "{green}Avantaje{default}: Speed, Tracers, Bhop, Tag si ChatTag ");
			CPrintToChat(client, " ");
		}
	}
	else if(VIP_IsClientVIP(client)){
			VIP_GetClientVIPGroup(client, grupa, sizeof(grupa))
			if(StrEqual("Goldmember VIP", grupa)){
				VIP_RemoveClientVIP2(0, client, true, false);
			}
		}
}

public Action Event_Spawn(Event event, const char[] name, bool dontBroadcast){
	if(!GetConVarBool(g_hGoldEnable)){
		return Plugin_Stop;
	}
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	char sName[MAX_NAME_LENGTH], g_sDNS[MAX_NAME_LENGTH];
	char grupa[20];
	
	GetConVarString(g_hServerName, g_sDNS, sizeof(g_sDNS));
	GetClientName(client, sName, MAX_NAME_LENGTH);
	
	if(StrContains(sName, g_sDNS, false) > -1)
		b_IsGoldMember[client] = true;
	if(b_IsGoldMember[client]){
		if(VIP_IsClientVIP(client)){
			VIP_GetClientVIPGroup(client, grupa, sizeof(grupa))
			if(StrContains(grupa,"vip", false)){
				CPrintToChat(client, " ");
			CPrintToChat(client, "{green}[BETIVII] {default}Ai {lime}Goldmember VIP {default}datorita DNS-ului din nume! Iti multumim ca esti alaturi de noi :)");
			CPrintToChat(client, "{green}Avantaje{default}: Speed, Tracers, Bhop, Tag si ChatTag ");
			CPrintToChat(client, " ");
				return Plugin_Continue;
			}
		}
		else{
			VIP_GiveClientVIP(0, client, 0, "Goldmember VIP", false);
			CPrintToChat(client, " ");
			CPrintToChat(client, "{green}[BETIVII] {default}Ai {lime}Goldmember VIP {default}datorita DNS-ului din nume! Iti multumim ca esti alaturi de noi :)");
			CPrintToChat(client, "{green}Avantaje{default}: Speed, Tracers, Bhop, Tag si ChatTag ");
			CPrintToChat(client, " ");
		}
	}
	else if(VIP_IsClientVIP(client)){
			VIP_GetClientVIPGroup(client, grupa, sizeof(grupa))
			if(StrEqual("Goldmember VIP", grupa)){
				VIP_RemoveClientVIP2(0, client, true, false);
			}
		}
	return Plugin_Continue;
}

public void OnClientSettingsChanged(int client)
{
	char sName[MAX_NAME_LENGTH], g_sDNS[MAX_NAME_LENGTH];
	
	GetConVarString(g_hServerName, g_sDNS, sizeof(g_sDNS));
	GetClientName(client, sName, MAX_NAME_LENGTH);
	
	if(StrContains(sName, g_sDNS, false) > -1)
		b_IsGoldMember[client] = true;
}
