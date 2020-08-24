#pragma semicolon 1
#pragma newdecls required

#define CHAT_P "[BETIVII]"
#define VS_PLUGIN "1.0"

#include <sourcemod>
#include <multicolors>
#include <sdktools>

Database db;
ConVar g_hOreEnable;
char g_Error[PLATFORM_MAX_PATH];
char g_Querry[PLATFORM_MAX_PATH];
char g_sSteamId[MAXPLAYERS+1][PLATFORM_MAX_PATH];

Handle ClientTimer[MAXPLAYERS+1];
int Minute[MAXPLAYERS+1];

public Plugin myinfo = {
	name = "Ore Jucate",
	author = "Pizant",
	description = "Contorizeaza si afiseaza timpul petrecut pe server",
	version = VS_PLUGIN
};

public void OnPluginStart(){
	CreateConVar("plugin_ore_versiune", VS_PLUGIN, "Versiunea Pluginului");
	g_hOreEnable=CreateConVar("plugin_ore_enable", "1", "Pornesti pluginul de ore? 0 = NU / 1 = DA");
	AutoExecConfig(true, "ore");
	RegConsoleCmd("sm_ore", Cmd_Ore, "Afiseaza cat timp ai petrecut pe server");
	RegConsoleCmd("sm_ora", Cmd_Ore, "Afiseaza cat timp ai petrecut pe server");
	RegConsoleCmd("sm_hours", Cmd_Ore, "Afiseaza cat timp ai petrecut pe server");
	RegConsoleCmd("sm_played", Cmd_Ore, "Afiseaza cat timp ai petrecut pe server");
	RegAdminCmd("sm_cauta", Cmd_OreAdmin, ADMFLAG_SLAY, "Afiseaza cat timp a petrecut un anumit player pe server");
    InitializeDB();
}

public void OnClientPutInServer(int client){
	if(IsValidClient(client)){
		if(!GetClientAuthId(client, AuthId_Engine, g_sSteamId[client], sizeof(g_sSteamId), true)){
			return;
		}
		
		Format(g_Querry, sizeof(g_Querry), "SELECT minute FROM ore where steam_id = '%s' LIMIT 1", g_sSteamId[client]);
		SQL_TQuery(db, DatePlayer, g_Querry, client);
	}
	
	ClientTimer[client]=(CreateTimer(60.0, TimerAdd, client, TIMER_REPEAT));
}

public void OnClientDisconnect(int client){
	if(ClientTimer[client] != null){
		CloseHandle(ClientTimer[client]);
		ClientTimer[client]=null;
	    Timp(client);
	    
	}
}

public void InitializeDB(){
	db=SQL_Connect("ore", true, g_Error, sizeof(g_Error));
	SQL_SetCharset(db, "utf8");
	if(db == INVALID_HANDLE){
		SetFailState(g_Error);
	}
	char tabelq[4096];
	Format(tabelq, sizeof(tabelq),
	"CREATE TABLE IF NOT EXISTS `ore` ( \
	`steam_id` VARCHAR(22) NOT NULL, \
	`minute` INT(12) DEFAULT 0, \
	PRIMARY KEY `steam_id` (`steam_id`) \
	) ENGINE= MyISAM COLLATE=utf8_general_ci;"
	);
	SQL_TQuery(db, SQLCheckErrorCallback, tabelq);
}

void DatePlayer(Handle db, Handle pQuery, char[] Error, any Data){
	static int Id, RowsCount;
	
	RowsCount=0;
	Id=view_as<int>(Data);
	
	if (strlen(Error) > 0) 
        LogError("SQL_TQuery() @ DatePlayer() reported: %s", Error); 

    else if (IsValidClient(Id)) 
    { 
         
        if (SQL_HasResultSet(pQuery)) 
            RowsCount = SQL_HasResultSet(pQuery) ? SQL_GetRowCount(pQuery) : 0; 

        switch (RowsCount) 
        { 
            case 0: 
            { 
                FormatEx (g_Querry, sizeof (g_Querry), "INSERT INTO `ore`(`steam_id`) VALUES ('%s')", g_sSteamId[Id]); 
                SQL_Query (db, g_Querry); 
            } 

            default: 
            { 
                SQL_FetchRow (pQuery); 

                Minute[Id] = SQL_FetchInt (pQuery, 0); 
            } 
        } 
        CloseHandle(db); 
    } 
}

public Action TimerAdd(Handle timer, int client){
	if(IsClientConnected(client) && IsClientInGame(client) && !IsClientObserver(client)){
		Minute[client]++;
		Timp(client);
	}
}

public Action Cmd_Ore(int client, int args){
	static char TimpTotal[PLATFORM_MAX_PATH];
	Format(g_Querry, sizeof(g_Querry), "SELECT minute FROM ore WHERE steam_id = '%s' LIMIT 1", g_sSteamId[client]);
	SQL_TQuery(db, DatePlayer, g_Querry, client);
	
	Pizant_GetTimeStringMinutes(Minute[client],TimpTotal, sizeof(TimpTotal));
	CPrintToChatEx(client, client, "{green}%s {default}Ai petrecut pe server: {green} %s", CHAT_P, TimpTotal);
	return Plugin_Handled;
}

public Action Cmd_OreAdmin(int client, int args){
	if(args<1){
		CPrintToChatEx(client, client, "{default}%s {green}Usage: sm_cauta <nume>", CHAT_P);
	}
	char nume[64];
	
	GetCmdArg(1,nume, sizeof(nume));
	
	int target= FindTarget(client, nume, true, false);
	if(target != -1){
	static char TimpTotal[PLATFORM_MAX_PATH];
	
	Format(g_Querry, sizeof(g_Querry), "SELECT minute FROM ore WHERE steam_id = '%s'", g_sSteamId[client]);
	SQL_TQuery(db, DatePlayer, g_Querry, target);
	
	Pizant_GetTimeStringMinutes(Minute[client],TimpTotal, sizeof(TimpTotal));
	CPrintToChatEx(client, client, "{green}%s {default}Acest player a jucat: {green}%s", CHAT_P, TimpTotal);
	}
	else {
		CPrintToChatEx(client, client, "{green}%s {default}Playerul nu a fost gasit!");
	}
	return Plugin_Handled;
}

void Timp(int client){
	Format(g_Querry, sizeof(g_Querry), "UPDATE ore SET minute = '%d' WHERE steam_id = '%s'", Minute[client], g_sSteamId[client]);
	SQL_Query(db,g_Querry);
}

int Pizant_GetTimeStringMinutes(int Mins, char[] Output, int Size) 
{ 
    static int m_Hours, m_Mins; 

    m_Hours = 0; 
    m_Mins = Pizant_AbsInt(Mins); 

    if (m_Mins == 0) 
        return FormatEx(Output, Size, "0 minute"); 

    while (m_Mins >= 60) 
    { 
        m_Hours++; 

        m_Mins -= 60; 
    } 

    if (m_Hours > 0) 
    { 
        if (m_Mins > 0) 
            return FormatEx(Output, Size, "%d ore %d minute", m_Hours, m_Mins); 

        return FormatEx(Output, Size, "%d ore", m_Hours); 
    } 

    return FormatEx(Output, Size, "%d minute", m_Mins); 
} 

int Pizant_AbsInt(int Value = 0) 
{ 
    return Value >= 0 ? Value : -Value; 
} 

public void SQLCheckErrorCallback(Handle owner, Handle hndl, char[] Error, any data){
	if(!StrEqual(Error, "")){
		LogError(Error);
	}
}

bool IsValidClient(int client){
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || IsFakeClient(client)){
		return false;
	}
	return true;
}
