ConVar g_cCreditsEnable;
ConVar g_Suma;

void Credits_OnPluginStart(){
	g_cCreditsEnable=CreateConVar("sm_creditsguild", "1", "Dezactivezi sau nu pluginul de taguri? 0 - DA / 1 - NU");
	g_Suma=CreateConVar("sm_creditsbonus", "5", "Suma de credite oferite bonus pentru kill / DEFAULT: 5");
	AutoExecConfig(true, "CreditsGuild");
	HookEvent("player_death", EventKill);
}

public Action EventKill(Handle event, const char[] name, bool dontBroadcast){
	if(!GetConVarBool(g_cCreditsEnable)) return Plugin_Stop;
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(IsValidClient(client)){
		if(g_bIsPlayerInGuild[client] && g_bHasBonus3[client]){
			Shop_GiveClientCredits(client, GetConVarInt(g_Suma));
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Ai primit %d credite pentru kill!", GetConVarInt(g_Suma));
		}
	}
	return Plugin_Continue;
}