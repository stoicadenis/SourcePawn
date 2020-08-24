#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

//Database db;
ConVar g_hClanEnable;
Handle ClanTimers[MAXPLAYERS+1];

public Plugin myinfo = {
	name = "Admin Clan Tag",
	author = "Pizant",
	description= "Pune un tag specific gradului pe care il are playerul",
	version="1.3"
};

public void OnPluginStart(){
	
	g_hClanEnable=CreateConVar("clantag_enable", "1", "Activezi sau nu pluginul de tags? 1 = DA / 0 = NU");
	AutoExecConfig(true, "ClanTag");
	HookEvent("player_spawn",Event_Tag, EventHookMode);
	//HookEvent("player_team", Event_Tag, EventHookMode);
	//InitializeDB();
}


public void OnClientDisconnect(int client){
	if(ClanTimers[client] != INVALID_HANDLE){
		KillTimer(ClanTimers[client]);
		ClanTimers[client]=INVALID_HANDLE;
	}
}
/*
public void OnClientPutInServer(int client){
	//HandleTag(client);

}

public void InitializeDB(){
	char Error[255];
	db= SQL_Connect("clantag",true, Error, sizeof(Error));
	SQL_SetCharset(db, "utf8");
	if(db == INVALID_HANDLE){
		SetFailState(Error);
	}
	char query[4096];
	Format(query, sizeof(query),
	"CREATE TABLE IF NOT EXISTS `clantag` (\
	`steam_id` varchar(22) NOT NULL, \
	`nume` varchar(32) NOT NULL, \
	`grad` varchar(16) NOT NULL, \
	UNIQUE KEY `steam_id` (`steam_id`) \
	) ENGINE = MyISAM COLLATE=utf8_general_ci;"
	);
	SQL_TQuery(db, SQLCheckErrorCallback, query);
}
*/

public Action Event_Tag(Handle event, const char[] name, bool dontBroadcast){
	if(!GetConVarBool(g_hClanEnable)) return Plugin_Handled;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(0<client){
		//HandleTag(client);
		if(IsClientValid(client)){
			ClanTimers[client]=CreateTimer(0.7, HandleTag, client);
		}
	}
	return Plugin_Handled;
}

public Action HandleTag(Handle timer, any client){
	//char nume[MAX_NAME_LENGTH], steamid[22], buffer[200];
	/*if(!IsFakeClient(client) && IsValidClient(client)){
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	GetClientName(client,nume, sizeof(nume));
	Format(buffer, sizeof(buffer), "SELECT * FROM clantag WHERE steam_id = '%s'", steamid);
	SQL_LockDatabase(db);
	Handle query = SQL_Query(db, buffer);
	int id = SQL_GetRowCount(query);
	SQL_UnlockDatabase(db);*/
	if(IsClientValid(client)){
		if(GetUserFlagBits(client) & ADMFLAG_ROOT){
		/*if(id==0){
			delete query;
			Format(buffer, sizeof(buffer), "INSERT IGNORE INTO clantag (steam_id, nume, grad) VALUES ('%s', '%s', '[OWNER]')", steamid, nume);
			SQL_TQuery(db, SQLCheckErrorCallback, buffer);

		}
		else {
			delete query;
			Format(buffer, sizeof(buffer), "UPDATE clantag SET grad = '[OWNER]' WHERE steam_id = '%s'", steamid);
			SQL_TQuery(db, SQLCheckErrorCallback, buffer);
		}*/
			CS_SetClientClanTag(client, "[OWNER]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM6){
			CS_SetClientClanTag(client, "[CO-OWNER]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM5){
			CS_SetClientClanTag(client, "[VETERAN]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM4){
			CS_SetClientClanTag(client, "[MODERATOR]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM3){
			CS_SetClientClanTag(client, "[ADMIN]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM2){
			CS_SetClientClanTag(client, "[HELPER]");
		}
		else if(GetUserFlagBits(client) & ADMFLAG_CUSTOM1){
			CS_SetClientClanTag(client, "[SLOT]");
		}
	}
	
	if(ClanTimers[client] != INVALID_HANDLE){
		KillTimer(ClanTimers[client]);
		ClanTimers[client]=INVALID_HANDLE;
	}
	//}
}
/*
public void SQLCheckErrorCallback(Handle owner, Handle hndl, const char[] error, any data){
	if(!StrEqual(error, "")){
		LogError(error);
	}
}
*/
stock bool IsClientValid(int client)
{
	return IsClientInGame(client) && IsClientAuthorized(client) && IsClientConnected(client);
}