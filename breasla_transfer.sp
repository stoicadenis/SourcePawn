int suma_transfer[MAXPLAYERS+1], clientid;
bool g_bTargetGuild[MAXPLAYERS+1];

public Action TransferCredits(int client, int args){
	if(args < 2 || args >= 3){
		CPrintToChatEx(client, client, "sm_transfer <SUMA_CREDITE> <NUME_PLAYER>");
		return Plugin_Handled;
	}
	char nume[MAX_NAME_LENGTH], s[20];
	GetCmdArg(1, s, sizeof(s));
	GetCmdArg(2, nume, sizeof(nume));
	if(g_bIsPlayerInGuild[client] && g_bHasBonus2[client]){
		suma_transfer[client] = StringToInt(s);
		if(Shop_GetClientCredits(client)<suma_transfer[client]){
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu ai suficiente credite pentru a transfera!");
			return Plugin_Handled;
		}
		int target = FindTarget(client, nume, false);
		if(target!=-1){
			char steamid[22], buffer[200];
			GetClientAuthId(target, AuthId_Steam2, steamid, sizeof(steamid));
			clientid=client;
			Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s'", steamid);
			SQL_TQuery(db, SQL_Transfer, buffer, GetClientUserId(target));		
			if(g_bTargetGuild[target])
			{
				Shop_GiveClientCredits(target, suma_transfer[client]);
				Shop_TakeClientCredits(client, suma_transfer[client]);
				CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Ai trimis %d credite catre coechiperul tau!", suma_transfer[client]);
				CPrintToChatEx(target, target, "{green}[FACTIONS] {default}Ai primit %d credite de la coechiperul tau!", suma_transfer[client]);
				suma_transfer[client]=0;
				g_bTargetGuild[target]=false;
			}
			else
			{
				suma_transfer[client]=0;
				CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Jucatorul nu este in FACTIUNEA TA pentru a putea trasfera credite!");
			}
		}
		else {
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Jucatorul nu a fost gasit!");
			return Plugin_Handled;
		}
	}
	else{
		CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu esti intr-o FACTIUNE sau FACTIUNEA TA nu a ajuns la nivelul necesar pentru a transfera credite!");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public void SQL_Transfer(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL_Transfer error: %s", error);
		return;
	}
	int target = GetClientOfUserId(data);
	char numeb_target[30];
	if(SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, numeb_target, sizeof(numeb_target));
		if(StrContains(PlayerGuildTag[clientid], numeb_target))
		{
			g_bTargetGuild[target]=true;
		}		
	}
}