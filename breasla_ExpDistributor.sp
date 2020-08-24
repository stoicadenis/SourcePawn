public Action ExpGuild(int client, int args){
	if(!IsValidClient(client)) return Plugin_Handled;
	if(args<1) return Plugin_Handled;
	char sum[PLATFORM_MAX_PATH];
	GetCmdArg(1, sum, sizeof(sum));
	if(args == 1){
		int suma=StringToInt(sum);
		if(!g_bIsPlayerInGuild[client]){
			CPrintToChatEx(client, client, "{green}[BREASLA] {default}Nu esti intr-o breasla pentru a depune EXP!");
			return Plugin_Handled;
		}
		if(suma<1){
			CPrintToChatEx(client, client, "{green}[BREASLA] {default}Introdu o suma valida pentru a depune EXP in breasla!");
			return Plugin_Handled;
		}
		if(Shop_GetClientCredits(client)<suma){
			CPrintToChatEx(client, client, "{green}[BREASLA] {default}Nu ai suficiente credite sa depui EXP in breasla!");
			return Plugin_Handled;
		}
		else
		{
			char buffer[200], steamid[22]; 
			GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
			Format(buffer, sizeof(buffer), "SELECT * FROM guild_players WHERE steamid_player = '%s'", steamid);
			SQL_TQuery(db, SQL_AddExp, buffer, suma);
		}	
	}
	return Plugin_Handled;
}

void UpdateLevel(){
	char buffer[200];
	Format(buffer, sizeof(buffer), "UPDATE guild SET bonus1 = 1 WHERE exp >= %d", 5000);
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
	Format(buffer, sizeof(buffer), "UPDATE guild SET bonus2 = 1 WHERE exp >= %d", 10000);
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
	Format(buffer, sizeof(buffer), "UPDATE guild SET bonus3 = 1 WHERE exp >= %d", 20000);
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
	Format(buffer, sizeof(buffer), "UPDATE guild SET bonus4 = 1 WHERE exp >= %d", 50000);
	SQL_TQuery(db, SQLErrorCheckCallback, buffer);
}

public void SQL_AddExp(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		LogError("SQL_AddExp returned error: %s", error); 
		return; 
	}
	int suma = data;
	char nume_guild[30];
	if(SQL_FetchRow(hndl))
	{
		char buffer[200];
		SQL_FetchString(hndl, 2, nume_guild, sizeof(nume_guild));
		Format(buffer, sizeof(buffer), "UPDATE guild SET exp = (exp + %d) WHERE name = '%s'", suma, nume_guild);
		SQL_TQuery(db, SQLErrorCheckCallback, buffer);
		UpdateLevel();
	}
}