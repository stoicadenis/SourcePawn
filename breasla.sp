#define MAX_LENGTH_MENU 470
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <cstrike>
#include <multicolors>
#include <shop>
#include "breasla_functions.sp"
#include "breasla_meniu.sp"
#include "breasla_clan.sp"
#include "breasla_ExpDistributor.sp"
#include "breasla_ChangeNameAndKickM8.sp"
#include "breasla_credits.sp"
#include "breasla_info.sp"
#include "breasla_top.sp"
#include "breasla_transfer.sp"

#pragma newdecls required

ConVar g_hGuildEnable;


public Plugin myinfo = {
	name="FACTIONS",
	author="Pizant",
	description="Factiuni/ Bresle create de playeri cu beneficii",
	version="2.0"
	
};

public void OnPluginStart(){
	LoadTranslations("common.phrases");
	g_hGuildEnable=CreateConVar("sm_enableguild","1","0 - dezactivat / 1 - activat");
	AutoExecConfig(true, "breasla");
	
	RegConsoleCmd("sm_breasla", CreateGuild);
	RegConsoleCmd("sm_creeazabreasla", CreateGuild);
	RegConsoleCmd("sm_createguild", CreateGuild);
	RegConsoleCmd("sm_inviteguild", InviteGuild);
	RegConsoleCmd("sm_deleteguild", DeleteGuild);
	RegConsoleCmd("sm_leaveguild", LeaveGuild);
	RegConsoleCmd("sm_expguild", ExpGuild);
	RegConsoleCmd("sm_nameb", ChangeName);
	RegConsoleCmd("sm_kickb", KickMate);
	RegConsoleCmd("sm_infog", InfoGuild);
	RegConsoleCmd("sm_infob", InfoGuild);
	RegConsoleCmd("sm_topg", TopGuild);
	RegConsoleCmd("sm_topb", TopGuild);
	RegConsoleCmd("sm_topguild", TopGuild);
	RegConsoleCmd("sm_topbresle", TopGuild);
	RegConsoleCmd("sm_transfer", TransferCredits);
	InitializeDB();
	Menu_OnPluginStart();
	Clan_OnPluginStart();
	Credits_OnPluginStart();
}

public Action CreateGuild(int client, int args){
	if(!GetConVarBool(g_hGuildEnable)) return Plugin_Handled;
	if(!IsValidClient(client)) return Plugin_Handled;
	if(args<1){
		PrintToConsole(client, "sm_breasla <NUME_BREASLA>");
		return Plugin_Handled;
	}
	char name[20];
	GetCmdArg(1,name, sizeof(name));
	if(args == 1 && strlen(name)>=3){
		char buffer[200];
		char nume[MAX_NAME_LENGTH], steamid[30];
		GetClientName(client, nume, sizeof(nume));
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
		Format(buffer, sizeof(buffer), "SELECT * FROM guild WHERE name = '%s'", name);
		SQL_LockDatabase(db);
		DBResultSet query = SQL_Query(db, buffer);
		SQL_UnlockDatabase(db);
		if(SQL_FetchRow(query)){
			CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Exista deja o FACTIUNE inregistrata cu acest nume!");
			delete query;
			return Plugin_Handled;
		}
		delete query;
		if(g_bIsPlayerOwner[client]){
			CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Ai deja o FACTIUNE inregistrata pe acest STEAMID!");
			return Plugin_Handled;
		}
		if(g_bIsPlayerInGuild[client]){
			CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Te afli deja intr-o FACTIUNE!");
			return Plugin_Handled;
		}
		Shop_GiveClientItem(client, 113, 0);
		Shop_ToggleClientItem(client, 113);
		CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Ai creat cu succes FACTIUNEA {default}%s!", name);
		Format(buffer, sizeof(buffer), "INSERT IGNORE INTO guild (name, owner, steamid, bonus1, bonus2, bonus3, bonus4) VALUES ('%s', '%s', '%s', 0, 0, 0, 0)", name, nume, steamid);
		SQL_TQuery(db, SQLErrorCheckCallback, buffer);
		Format(buffer, sizeof(buffer), "INSERT IGNORE INTO guild_players (player, steamid_player, nume_guild) VALUES ('%s', '%s', '%s')", nume, steamid, name);
		SQL_TQuery(db, SQLErrorCheckCallback, buffer);
		Format(buffer, sizeof(buffer), "SELECT * FROM guild WHERE steamid = '%s'", steamid);
		SQL_TQuery(db, SQL_LoadPlayerGuild, buffer, GetClientUserId(client));
	}
	return Plugin_Handled;
}

public int Menu_Act(Menu menu, MenuAction action, int param1, int param2){
	if(action == MenuAction_End)
	{
		delete menu;
	}
	else if(action==MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param2,info,sizeof(info));
		if(StrEqual(info,"nu", false)){
			CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Ai refuzat sa intri in FACTIUNE!");
		}
		else{
			if(g_bIsPlayerInGuild[param1]){
				CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Detii sau esti deja membru intr-o FACTIUNE!");
			}
			else
			{
				char buffer[200], steamid[22], nume_player[50];
				CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Ai intrat in FACTIUNEA {green}%s", info);
				GetClientAuthId(param1, AuthId_Steam2, steamid, sizeof(steamid));
				GetClientName(param1, nume_player, sizeof(nume_player));
				Format(buffer, sizeof(buffer), "INSERT IGNORE INTO guild_players (player, steamid_player, nume_guild) VALUES ('%s', '%s', '%s')", nume_player, steamid, info);
				SQL_TQuery(db, SQLErrorCheckCallback, buffer);
				Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s'", steamid);
				SQL_TQuery(db, SQL_LoadPlayerGuild, buffer, GetClientUserId(param1));
				Shop_GiveClientItem(param1, 113, 0);
				Shop_ToggleClientItem(param1, 113);
			}
		}
	}
}

public Action InviteGuild(int client, int args){
	if(!GetConVarBool(g_hGuildEnable)) return Plugin_Handled;
	if(!IsValidClient(client)) return Plugin_Handled;
	if(args<1){
		PrintToConsole(client, "sm_inviteguild <NUME_PLAYER>");
		return Plugin_Handled;
	}
	char name[MAX_NAME_LENGTH], buffer[200];
	GetCmdArg(1, name, sizeof(name));
	if(args==1){
		int target=FindTarget(client, name, true, false);
		if(target!=-1){
			if(g_bIsPlayerInGuild[target]){
				CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Jucatorul detine sau este deja membru intr-o FACTIUNE!");
				return Plugin_Handled;
			}
			char nume_b[MAX_NAME_LENGTH], steam_c[22];
			Menu menu = new Menu(Menu_Act);
			GetClientAuthId(client, AuthId_Steam2, steam_c, sizeof(steam_c));
			Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s'", steam_c);
			SQL_LockDatabase(db);
			DBResultSet query= SQL_Query(db, buffer);
			SQL_UnlockDatabase(db);
			if(SQL_FetchRow(query))
			{
				SQL_FetchString(query, 2, nume_b, sizeof(nume_b));
				delete query;
				menu.SetTitle("Intri in FACTIUNEA %s?", nume_b);
				menu.AddItem(nume_b, "DA");
				menu.AddItem("nu", "NU");
				menu.ExitButton=false;
				menu.Display(target, 20);
			}
			delete query;
		}
		else{
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu am putut gasii jucatorul!");
		}
	}
	return Plugin_Handled;
}

public int Menu_Del(Menu menu, MenuAction action, int param1, int param2){
	if(action == MenuAction_End){
		delete menu;
	}
	else if(action==MenuAction_Select){
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual(info,"nu")){
			CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Nu ai sters factiunea!");
		}
		else{
			char buffer[200], steamid[22];
			GetClientAuthId(param1, AuthId_Steam2, steamid, sizeof(steamid));
			CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Ai sters factiunea cu succes!");
			Format(buffer, sizeof(buffer), "SELECT * FROM guild WHERE steamid = '%s'", steamid);
			SQL_TQuery(db, SQL_DeleteGuild, buffer);
			g_bIsPlayerInGuild[param1]=false;
			g_bIsPlayerOwner[param1]=false;
			g_bHasBonus1[param1]=false;
			g_bHasBonus2[param1]=false;
			g_bHasBonus3[param1]=false;
			g_bHasBonus4[param1]=false;
		}
	}
}

public Action DeleteGuild(int client, int args){
	if(!GetConVarBool(g_hGuildEnable)) return Plugin_Handled;
	if(!IsValidClient(client)) return Plugin_Handled;
	if(args<1){
		if(g_bIsPlayerOwner[client]){
			Menu menu = new Menu(Menu_Del);
			menu.SetTitle("Sigur vrei sa stergi breasla?");
			menu.AddItem("da", "DA");
			menu.AddItem("nu", "NU");
			menu.ExitButton = false;
			menu.Display(client, 20);
		}
		else{
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu detii nici o FACTIUNE pentru a o putea sterge!");
		}
	}
	return Plugin_Handled;
}

public int Menu_Leave(Menu menu, MenuAction action, int param1, int param2){
	if(action == MenuAction_End)
	{
		delete menu;
	}
	else if(action==MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual(info,"nu"))
		{
			CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Nu ai iesit din FACTIUNE!");
		}
		else
		{
			char steamid[22];
			GetClientAuthId(param1, AuthId_Steam2, steamid, sizeof(steamid));
			if(g_bIsPlayerOwner[param1]){
				CPrintToChatEx(param1, param1, "{green}[FACTIONS] {default}Nu poti iesii din FACTIUNEA TA!");
			}
			else
			{
				CPrintToChat(param1, "{green}[FACTIONS] {default}Ai iesit din FACTIUNE!");
				char buffer[200];
				Format(buffer, sizeof(buffer), "DELETE FROM guild_players WHERE steamid_player = '%s'", steamid);
				SQL_TQuery(db, SQLErrorCheckCallback, buffer);
				g_bIsPlayerInGuild[param1]=false;
				g_bIsPlayerOwner[param1]=false;
				g_bHasBonus1[param1]=false;
				g_bHasBonus2[param1]=false;
				g_bHasBonus3[param1]=false;
				g_bHasBonus4[param1]=false;
			}
		}
	}
}

public Action LeaveGuild(int client, int args){
	if(!GetConVarBool(g_hGuildEnable)) return Plugin_Handled;
	if(!IsValidClient(client)) return Plugin_Handled;
	if(args<1){
		if(g_bIsPlayerInGuild[client]){
			Menu menu = new Menu(Menu_Leave);
			menu.SetTitle("Sigur vrei sa iesi din FACTIUNE?");
			menu.AddItem("da", "DA");
			menu.AddItem("nu", "NU");
			menu.ExitButton = false;
			menu.Display(client, 20);
		}
		else{
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu esti in nici o FACTIUNE pentru a iesi!");
		}
	}
	return Plugin_Handled;
}