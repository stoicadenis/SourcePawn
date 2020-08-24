#pragma semicolon 1
#pragma newdecls required

#define VERSIUNE "1.0"
#define TAG "[BETIVII]"

#include <sourcemod>
#include <multicolors>
#include <geoip>
#include <shop>

Database db;
Handle g_MsjEnable = INVALID_HANDLE;
Handle WelcomeTimers[MAXPLAYERS+1];
char nume[MAX_NAME_LENGTH];
char steamid[22];
char tara[3];
char ip[22];
char mapacurenta[20];
 
public Plugin myinfo = {
	name = "Afisare conectare player",
	author = "Pizant",
	description = "Afiseaza cand un player se conecteaza pe server",
	version = VERSIUNE
};

public void OnPluginStart(){
	CreateConVar("msj_versiune", VERSIUNE, "Versiunea pluginului", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_MsjEnable= CreateConVar("sm_msjenable", "1", "Activezi pluginul de afisare a playerilor ce se conecteaza? 0 = NU / 1 = DA");
	AutoExecConfig(true, "connectmsj");
	//HookEvent("player_spawn", Event_Spawn);
	InitializeDB();	
}

public void OnMapStart(){
	GetCurrentMap(mapacurenta, sizeof(mapacurenta));
}

public void OnClientDisconnect(int client){
	if(WelcomeTimers[client] != null){
		KillTimer(WelcomeTimers[client]);
		WelcomeTimers[client]=null;
	}
	
}

public OnClientPutInServer(int client){
	int connect = GetConVarInt(g_MsjEnable);
	if(connect == 1){
	GetClientIP(client,ip, sizeof(ip));
	GetClientName(client, nume, sizeof(nume));
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GeoipCode2(ip, tara);
	  if(IsFakeClient(client)){
	  	return;
	    }
	    else{
	         CPrintToChatAll("{green}%s {default}%s ({green}%s{default}) a intrat pe server din {green}%s!", TAG, nume, steamid, tara);
	         WelcomeTimers[client]=CreateTimer(7.0, MesajPlayer, client);
            }
	}
	else {
		CloseHandle(g_MsjEnable);
	}
}

public void InitializeDB(){
	char Error[PLATFORM_MAX_PATH];
	db=SQL_Connect("shop", true, Error, sizeof(Error));
	if(db == INVALID_HANDLE){
		SetFailState(Error);
	}
}

public Action MesajPlayer(Handle timer, any client){
	GetClientIP(client,ip, sizeof(ip));
	GetClientName(client, nume, sizeof(nume));
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GeoipCode2(ip, tara);
	char buffer[200];
	Format(buffer, sizeof(buffer), "SELECT * FROM shop_players WHERE auth = '%s'", steamid);
	SQL_LockDatabase(db);
	DBResultSet query = SQL_Query(db, buffer);
	SQL_UnlockDatabase(db);
	SQL_FetchRow(query);
	int credite = SQL_FetchInt(query,3);
	delete query;
	CPrintToChat(client, "{default}Bine ai venit pe server, {green}%s!", nume);
	CPrintToChat(client, "{default}==========================================================");
	CPrintToChat(client, "{default}IP: {green}%s", ip);
	CPrintToChat(client, "{default}SteamID: {green}%s", steamid);
	CPrintToChat(client, "{default}Tara: {green}%s", tara);
	CPrintToChat(client, "{default}Current Map: {green}%s", mapacurenta);
	CPrintToChat(client, "{default}Credite: {green}%d", credite);
	CPrintToChat(client, "{default}==========================================================");
	CPrintToChat(client, "{green}Bafta la fraguri! Nu uita sa iti iei bonusul zilnic scriind {lime}!bonus");
	WelcomeTimers[client]=null;
}


