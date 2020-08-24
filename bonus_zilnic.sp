#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <shop>

#pragma newdecls required

Database db;
ConVar g_hDailyEnable;
ConVar g_hDailyCredits;
ConVar g_hDailyBonus;
ConVar g_hDailyMax;
ConVar g_hDailyReset;
ConVar g_hDailyInterval;
char CurrentDate[20];
int ConnectTime[MAXPLAYERS+1];

public Plugin myinfo = {
	name = "[Shop] Bonus zilnic",
	author = "Pizant",
	description = "Bonus zilnic in credite",
	version="1.0"
};

public void OnPluginStart(){
	CreateConVar("sm_bonus_zilnic_versiune", "1.0", "Versiunea Pluginului", FCVAR_DONTRECORD | FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_SPONLY);
	g_hDailyEnable= CreateConVar("sm_bonus_credite_enable", "1", "Activezi bonusul zilnic? 0 = NU / 1 = DA", 0, true, 0.0, true, 1.0);
	g_hDailyCredits= CreateConVar("sm_bonus_credite_suma","500", "Suma de credite pe care o primesti", 0, true, 0.0);
	g_hDailyBonus= CreateConVar("sm_bonus_credite_bonus", "500", "Bonus credite minim pentru conectare in fiecare zi", 0, true, 0.0);
	g_hDailyMax= CreateConVar("sm_bonus_credite_max", "2000", "Bonus credite maxim pentru conectare in fiecare zi", 0, true, 0.0);
	g_hDailyReset= CreateConVar("sm_bonus_credite_reset", "7", "Numarul de zile cand se reseteaza singur", 0, true, 0.0);
	g_hDailyInterval= CreateConVar("sm_bonus_credite_interval", "0", "Numarul de minute dupa care sa se activeze bonusul / 0 = Imediat");
	AutoExecConfig(true, "bonus_zilnic");
	
	RegConsoleCmd("sm_bonus", Cmd_Bonus);
	RegConsoleCmd("sm_gratis", Cmd_Bonus);
	RegConsoleCmd("sm_free", Cmd_Bonus);
	RegConsoleCmd("sm_moka", Cmd_Bonus);
	RegConsoleCmd("sm_bonuszilnic", Cmd_Bonus);
	InitializeDB();
}

public void OnClientConnected(int client){
	ConnectTime[client]=GetTime();
}

public void OnClientDisconnect(int client){
	ConnectTime[client]=0;
}

public void InitializeDB(){
	char Error[255];
	db= SQL_Connect("bonuszilnic", true, Error, sizeof(Error));
	SQL_SetCharset(db, "utf8");
	if(db == INVALID_HANDLE){
		SetFailState(Error);
	}
	char createTableQuery[4096];
	Format(createTableQuery, sizeof(createTableQuery), 
		"CREATE TABLE IF NOT EXISTS `players` ( \
  		`steam_id` varchar(22) NOT NULL, \
  		`last_connect` int(12) NOT NULL, \
  		`suma_bonus` int(12), \
  		 UNIQUE KEY `steam_id` (`steam_id`)  \
  		 ) ENGINE = MyISAM COLLATE=utf8_general_ci;"
		);
	SQL_TQuery(db, SQLErrorCheckCallback, createTableQuery);
}

public Action Cmd_Bonus(int client, int args){
	if(!GetConVarBool(g_hDailyEnable)) return Plugin_Handled;
	if(!IsValidClient(client)) return Plugin_Handled;
	if(GetConVarInt(g_hDailyInterval)>0){
		int TimeTillNow = 0;
		TimeTillNow= RoundToFloor(float((GetTime() - ConnectTime[client])/60));
		if(TimeTillNow < GetConVarInt(g_hDailyInterval)){
			CPrintToChatEx(client, client, "Mai ai de asteptat %d pana sa poti accesa bonusul!", GetConVarInt(g_hDailyInterval) - TimeTillNow);
		    return Plugin_Handled;
		}
	}
	FormatTime(CurrentDate, sizeof(CurrentDate), "%Y%m%d");
	char steamid[32];
	if(GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))){
		char buffer[200];
		Format(buffer, sizeof(buffer), "SELECT * FROM players WHERE steam_id = '%s'", steamid);
		SQL_LockDatabase(db);
		Handle query = SQL_Query(db, buffer);
		int id= SQL_GetRowCount(query);
		SQL_UnlockDatabase(db);
		if(id == 0){
			delete query;
			GiveCredits(client, true);
		}
		else {
			delete query;
			GiveCredits(client, false);
		}
	}
	else LogError("Nu se poate lua SteamID-ul!");
	
	return Plugin_Handled;
}

stock void GiveCredits(int client, bool PrimaData){
	char buffer[200];
	char steamid[32];
	if(GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid))){
		if(PrimaData){
			Shop_SetClientCredits(client, Shop_GetClientCredits(client) + GetConVarInt(g_hDailyCredits));
			CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green} Ai primit %d credite de bun venit! Te mai asteptam!", GetConVarInt(g_hDailyCredits));
			Format(buffer, sizeof(buffer), "INSERT IGNORE INTO players (steam_id, last_connect, suma_bonus) VALUES ('%s', %d, 1)", steamid, StringToInt(CurrentDate));
			SQL_TQuery(db, SQLErrorCheckCallback, buffer);
		}
		else {
			Format(buffer, sizeof(buffer), "SELECT * FROM players WHERE steam_id = '%s'", steamid);
			SQL_LockDatabase(db);
			DBResultSet query = SQL_Query(db, buffer);
			SQL_UnlockDatabase(db);
			SQL_FetchRow(query);
			int data2 = SQL_FetchInt(query, 1);
			int bonus = SQL_FetchInt(query, 2);
			delete query;
			int data1= StringToInt(CurrentDate);
			int resetareZi = GetConVarInt(g_hDailyReset);
			
			if(resetareZi > 0){
				resetareZi--;
			}
			
			if((data1-data2)==1){
				int TotalCredite= GetConVarInt(g_hDailyCredits) + (bonus * GetConVarInt(g_hDailyBonus));
				if(TotalCredite > GetConVarInt(g_hDailyMax)){
					TotalCredite= GetConVarInt(g_hDailyMax);
				}
				Shop_SetClientCredits(client, Shop_GetClientCredits(client) + TotalCredite);
				
				if(resetareZi != 0){
					if(bonus >= resetareZi){
						CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Ai primit %d credite!", TotalCredite);
						Format(buffer, sizeof(buffer), "UPDATE players SET last_connect = %i, suma_bonus = %i WHERE steam_id = '%s'", data1, 0, steamid);
						CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Bonus resetat automat dupa %d zile!", resetareZi+1);
					}
					else{
						CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Ai primit %d credite!", TotalCredite);
						Format(buffer, sizeof(buffer), "UPDATE players SET last_connect = %i, suma_bonus = %i WHERE steam_id = '%s'", data1, bonus+1, steamid);
						CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Multumim ca intri constant! Te mai asteptam pe server!");
					}
					SQL_TQuery(db, SQLErrorCheckCallback, buffer);
				}
			}
			    else if((data1-data2)==0){
				    CPrintToChatEx(client, client,"{default}[Bonus Zilnic] {green}Ai primit deja bonusul! Revino maine pentru a primi altul.");
			    }
			    else if((data1-data2)>1){
				    CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Bonusul s-a resetat pentru ca a trecut ceva timp de cand nu ai mai intrat!");
				    Shop_SetClientCredits(client, Shop_GetClientCredits(client) + GetConVarInt(g_hDailyCredits));
				    CPrintToChatEx(client, client, "{default}[Bonus Zilnic] {green}Ai primit %d credite!", GetConVarInt(g_hDailyCredits));
				    Format(buffer, sizeof(buffer), "UPDATE players SET last_connect = %i, suma_bonus = %i WHERE steam_id = '%s'", data1, 1, steamid);
				    SQL_TQuery(db, SQLErrorCheckCallback, buffer);
			    }
		}
	}
    else {
		LogError("Nu se poate lua SteamID-ul!");
	} 
}

stock bool IsValidClient(int client){
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}

public void SQLErrorCheckCallback(Handle owner, Handle hndl, const char[] error, any data){
	if(!StrEqual(error, "")){
		LogError(error);
	}
}

