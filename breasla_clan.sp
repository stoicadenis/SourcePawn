ConVar g_cClanEnable;

Handle ClanTimers[MAXPLAYERS+1];

void Clan_OnPluginStart()
{
	ClanGuildCookie = RegClientCookie("ClanGuild", "ClanGuild", CookieAccess_Protected);
	g_cClanEnable=CreateConVar("sm_clanguildenable", "1", "Dezactivezi sau nu pluginul de taguri? 0 - DA / 1 - NU");
	AutoExecConfig(true, "GuildClanTag");
	HookEvent("player_spawn", EventSpawn);
	
	RegConsoleCmd("sm_tagb", Cmd_Tag);
}

public void OnClientDisconnect(int client){
	if(ClanTimers[client] != INVALID_HANDLE){
		KillTimer(ClanTimers[client]);
		ClanTimers[client]=INVALID_HANDLE;
	}
	g_bIsPlayerInGuild[client]=false;
	g_bIsPlayerOwner[client]=false;
	g_bHasBonus1[client]=false;
	g_bHasBonus2[client]=false;
	g_bHasBonus3[client]=false;
	g_bHasBonus4[client]=false;
}

public Action EventSpawn(Handle event, const char[] name, bool dontBroadcast){
	if(!GetConVarBool(g_cClanEnable)) return Plugin_Stop;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsClanEnabled[client]) return Plugin_Handled;
	if(IsValidClient(client)){
		if(g_bIsPlayerInGuild[client] && g_bHasBonus1[client]){
			ClanTimers[client] = CreateTimer(2.0, HandleTag, client);
		}
	}	
	return Plugin_Handled;
}

public Action HandleTag(Handle timer, any client){
	if(IsValidClient(client)){
		CS_SetClientClanTag(client, PlayerGuildTag[client]);
		if(ClanTimers[client] != INVALID_HANDLE){
			KillTimer(ClanTimers[client]);
			ClanTimers[client]=INVALID_HANDLE;
		}
	}
}

public Action Cmd_Tag(int client, int args)
{
	if(args > 0) return Plugin_Handled;
	if(IsClanEnabled[client])
	{
		CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Tagul factiunii este OPRIT!");
		IsClanEnabled[client]=false;
		SetClientCookie(client, ClanGuildCookie, "0");
	}
	else
	{
		CPrintToChatEx(client, client, "{default}[FACTIONS] {green} Tagul factiunii este ACTIVAT!");
		IsClanEnabled[client]=true;
		SetClientCookie(client, ClanGuildCookie, "1");
	}
	return Plugin_Handled;
}