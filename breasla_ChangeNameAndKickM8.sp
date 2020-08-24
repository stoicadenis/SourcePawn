public Action ChangeName(int client, int args){
	if(args<1){
		CPrintToChat(client, "{green}[FACTIONS] {default}!nameb <NUME_NOU>");
		return Plugin_Handled;
	}
	if(IsValidClient(client))
	{
		if(!g_bIsPlayerOwner[client])
		{
			CPrintToChat(client, "{green}[FACTIONS] {default}Nu detii o FACTIUNE pentru ai putea schimba numele!");
			return Plugin_Handled;
		}
		else
		{
			char numeb[50];
			GetCmdArg(1, numeb, sizeof(numeb));
			if(args == 1)
			{
				char buffer[200];
				Format(buffer, sizeof(buffer), "SELECT * FROM guild WHERE name = '%s'", numeb);
				SQL_LockDatabase(db);
				DBResultSet query = SQL_Query(db,buffer);
				SQL_UnlockDatabase(db);
				if(SQL_FetchRow(query))
				{
					delete query;
					CPrintToChat(client, "{green}[FACTIONS] {default}Exista deja o FACTIUNE inregistat cu numele acesta!");
					return Plugin_Handled;
				}
				delete query;
				char steamid[22];
				GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
				Format(buffer, sizeof(buffer), "UPDATE guild SET name = '%s' WHERE steamid = '%s' ", numeb, steamid);
				SQL_TQuery(db, SQLErrorCheckCallback, buffer);
				CPrintToChat(client, "{green}[FACTIONS] {default}Numele FACTIUNII a fost actualizat cu succes!");
			}
		}
	}
	return Plugin_Handled;
}

public Action KickMate(int client, int args){
	if(args<1)
	{
		CPrintToChat(client, "{green}[FACTIONS] {default}!kickb ''STEAMID_JUCATOR''");
		return Plugin_Handled;
	}
	if(IsValidClient(client))
	{
		if(!g_bIsPlayerOwner[client])
		{
			CPrintToChat(client, "{green}[FACTIONS] Nu detii o FACTIUNE pentru a putea da afara un jucator!");
			return Plugin_Handled;
		}
		else
		{
			char steamid_jucator[22], buffer[200];
			GetCmdArg(1, steamid_jucator, sizeof(steamid_jucator));
			Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s' ", steamid_jucator);
			SQL_TQuery(db, SQL_KickMate, buffer, GetClientUserId(client));
		}
	}
	return Plugin_Handled;
}

public void SQL_KickMate(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL_KickMate error: %s", error);
		return;
	}
	int client = GetClientOfUserId(data);
	if(client == 0)
	{
		return;
	}
	if(SQL_FetchRow(hndl))
	{
		char numeb_jucator[30], steamid[22];
		SQL_FetchString(hndl, 1, steamid, sizeof(steamid));
		SQL_FetchString(hndl, 2, numeb_jucator, sizeof(numeb_jucator));
		if(StrContains(PlayerGuildTag[client], numeb_jucator))
		{
			char buffer[200];
			Format(buffer, sizeof(buffer), "DELETE FROM guild_players WHERE steamid_player = '%s'", steamid);
			SQL_TQuery(db, SQLErrorCheckCallback, buffer);
		}
		else
		{
			CPrintToChat(client, "{green}[FACTIONS] {default}Ai dat kick jucatorului din FACTIUNE!");
		}
	}
	
}