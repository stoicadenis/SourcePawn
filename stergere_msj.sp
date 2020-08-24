#include <sourcemod>

public Plugin myinfo = 
{
    name = "Stergator mesaje inutile din chat 1", 
    author = "Pizant" 
};

public void OnPluginStart()
{
    HookEvent("player_team", PlayerTeam, EventHookMode_Pre);
    HookEvent("player_disconnect", Player_Disconnect);
}

public Action PlayerTeam(Handle event, const char[] name, bool dontBroadcast) 
{ 
    return Plugin_Handled; 
} 

public Action Player_Disconnect(Handle event, const char[] name, bool dontBroadcast){
	return Plugin_Handled;
}