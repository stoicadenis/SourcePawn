Database db;
Handle ClanGuildCookie;

bool IsClanEnabled[MAXPLAYERS + 1];
bool g_bIsPlayerInGuild[MAXPLAYERS + 1];
bool g_bIsPlayerOwner[MAXPLAYERS + 1];
bool g_bHasBonus1[MAXPLAYERS + 1];
bool g_bHasBonus2[MAXPLAYERS + 1];
bool g_bHasBonus3[MAXPLAYERS + 1];
bool g_bHasBonus4[MAXPLAYERS + 1];

char PlayerGuildTag[MAXPLAYERS+1][PLATFORM_MAX_PATH];

public void InitializeDB(){
	char Error[255];
	db= SQL_Connect("breasla", true, Error, sizeof(Error));
	if(db == INVALID_HANDLE){
		SetFailState(Error);
	}
	SQL_SetCharset(db, "utf8");
	char createTableQuery[4096];
	Format(createTableQuery, sizeof(createTableQuery),
		"CREATE TABLE IF NOT EXISTS `guild` ( \
		`name` varchar(22) NOT NULL, \
		`owner` varchar(50) NOT NULL, \
		`steamid` varchar(22) NOT NULL, \
		`exp` int(12) NOT NULL, \
		`bonus1` int(2), \
		`bonus2` int(2), \
		`bonus3` int(2), \
		`bonus4` int(2), \
		UNIQUE KEY `name` (`name`),  \
		UNIQUE KEY `steamid` (`steamid`)  \
	) ENGINE = MyISAM COLLATE=utf8_general_ci;"
	);
	SQL_TQuery(db, SQLErrorCheckCallback, createTableQuery);
	Format(createTableQuery, sizeof(createTableQuery),
		"CREATE TABLE IF NOT EXISTS `guild_players` ( \
		`player` varchar(50) NOT NULL, \
		`steamid_player` varchar(22) NOT NULL, \
		`nume_guild` varchar(22) NOT NULL, \
		UNIQUE KEY `steamid_player` (`steamid_player`)  \
	) ENGINE = MyISAM COLLATE=utf8_general_ci;"
	);
	SQL_TQuery(db, SQLErrorCheckCallback, createTableQuery);
}

public void OnClientPutInServer(int client)
{
	// Clan breasla
	IsClanEnabled[client]=true;
	char buffer[200];
	GetClientCookie(client, ClanGuildCookie, buffer, sizeof(buffer));
	if(StrEqual(buffer, "0"))
	{
		IsClanEnabled[client]=false;
	}
	
	// loading jucator breasla
	if(!IsFakeClient(client))
	{
		char steamid[22];
		GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
		Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s'", steamid);	
		SQL_TQuery(db, SQL_LoadPlayerGuild, buffer, GetClientUserId(client));
		if(!g_bIsPlayerInGuild[client])
		{
			Shop_RemoveClientItem(client, 113);
		}
		else
		{
			Shop_GiveClientItem(client, 113, 0);
			Shop_ToggleClientItem(client, 113);
		}
	}	
}

public void SQLErrorCheckCallback(Handle owner, Handle hndl, const char[] error, any data){
	if(!StrEqual(error, "")){
		LogError(error);
	}
}

public void SQL_ContinueLoadGuild(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		LogError("SQL_ContinueLoadGuild returned error: %s", error); 
		return; 
	}
	
	int client = GetClientOfUserId(data);
	char steamid[22], steamid2[22];
	GetClientAuthId(client, AuthId_Steam2, steamid2, sizeof(steamid2));
	if (client == 0)
	{
		return;
	}
	if(SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, steamid, sizeof(steamid));
		if(StrEqual(steamid, steamid2, false)) g_bIsPlayerOwner[client] = true;
		if(SQL_FetchInt(hndl, 4) == 1) g_bHasBonus1[client] = true;
		if(SQL_FetchInt(hndl, 5) == 1) g_bHasBonus2[client] = true;
		if(SQL_FetchInt(hndl, 6) == 1) g_bHasBonus3[client] = true;
		if(SQL_FetchInt(hndl, 7) == 1) g_bHasBonus4[client] = true;
	}
}

public void SQL_LoadPlayerGuild(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		LogError("SQL_LoadPlayerGuild returned error: %s", error); 
		return; 
	}
	
	int client = GetClientOfUserId(data), nume_col;
	char nume[30], buffer[200];
	if (client == 0)
	{
		return;
	}
	if(SQL_FetchRow(hndl))
	{
		g_bIsPlayerInGuild[client] = true;
		SQL_FieldNameToNum(hndl, "nume_guild", nume_col);
		SQL_FetchString(hndl, nume_col, nume, sizeof(nume));
		StrCopy(PlayerGuildTag[client], sizeof(PlayerGuildTag), nume);
		//StrCat(PlayerGuildTag[client], sizeof(PlayerGuildTag), "☆");
		Format(buffer, sizeof(buffer), "SELECT * FROM guild WHERE name = '%s'", nume);
		SQL_TQuery(db, SQL_ContinueLoadGuild, buffer, GetClientUserId(client));
	}
}

public void SQL_DeleteGuild(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		LogError("SQL_AddInGuild returned error: %s", error); 
		return; 
	}
	char nume_fact[30], buffer[200];
	if(SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, nume_fact, sizeof(nume_fact));
		Format(buffer, sizeof(buffer), "DELETE FROM guild_players WHERE nume_guild = '%s'", nume_fact);
		SQL_TQuery(db, SQLErrorCheckCallback, buffer);
	}
	Format(buffer, sizeof(buffer), "DELETE FROM guild WHERE name = '%s'", nume_fact);
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
}

stock bool IsValidClient(int client)
{
	if(client <= 0) return false;
	if(client > MaxClients) return false;
	if(IsFakeClient(client)) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}