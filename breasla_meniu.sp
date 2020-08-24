ConVar g_cMenuEnable;
bool g_MsjJucator[MAXPLAYERS+1];
int ClientChoice[MAXPLAYERS+1];

void Menu_OnPluginStart()
{
	g_cMenuEnable=CreateConVar("bs_menuenable", "1", "0 - Dezactivat / 1 - Activat");
	AutoExecConfig(true, "Breasla_Menu");
	RegConsoleCmd("sm_menub", MenuBreasla);
}

public void OnMapStart()
{
	int i;
	for(i=1;i<=MaxClients;i=i+1){
		g_MsjJucator[i]=false;
		ClientChoice[i]=0;
		g_bIsPlayerInGuild[i]=false;
		g_bIsPlayerOwner[i]=false;
		g_bHasBonus1[i]=false;
		g_bHasBonus2[i]=false;
		g_bHasBonus3[i]=false;
		g_bHasBonus4[i]=false;
	} 
}

public Action OnClientSayCommand(int client, const char []command, const char []sArgs)
{ 
	if(client > 0 && client <= MaxClients)
	{
		if(g_MsjJucator[client])
		{
			char buffer[200];
			if(ClientChoice[client]==1)
			{
				Format(buffer, sizeof(buffer), "sm_createguild %s", sArgs);
				ClientCommand(client, buffer);
			}
			else if(ClientChoice[client]==2)
			{
				int suma = StringToInt(sArgs);
				Format(buffer, sizeof(buffer), "sm_expguild %d", suma);
				ClientCommand(client, buffer);
			}
			else if(ClientChoice[client]==3)
			{
				Format(buffer, sizeof(buffer), "sm_inviteguild %s", sArgs);
				ClientCommand(client, buffer);
			}
			else if(ClientChoice[client]==4)
			{
				Format(buffer, sizeof(buffer), "sm_kickb \"%s\"", sArgs);
				ClientCommand(client, buffer);
			}
			else if(ClientChoice[client]==5)
			{
				Format(buffer, sizeof(buffer), "sm_nameb %s", sArgs);
				ClientCommand(client, buffer);
			}
			ClientChoice[client]=0;
			g_MsjJucator[client]=false;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public int Menu_Handler1(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_End) delete menu;
	else if(action == MenuAction_Select)
	{
		char info[200];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual("1", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Introdu in chat numele FACTIUNII");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=1;
		}
		else
		{
			ClientCommand(param1,"sm_topb");
		}
	}
	return 0;
}

public int Menu_Handler2(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_End) delete menu;
	else if(action == MenuAction_Select)
	{
		char info[200];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual("1", info))
		{
			ClientCommand(param1, "sm_infob");
		}
		else if(StrEqual("2", info))
		{
			ClientCommand(param1, "sm_topb");
		}
		else if(StrEqual("3", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Scrie suma pe care vrei sa o introduci:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=2;
		}
		else if(StrEqual("4", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Scrie numele jucatorului pe care doresti sa-l inviti:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=3;
		}
		else if(StrEqual("5", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Scrie STEAMID-ul jucatorului pe care doresti sa-l dai afara:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=4;
		}
		else if(StrEqual("6", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Introdu noul nume al breslei:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=5;
		}
		else if(StrEqual("7", info))
		{
			ClientCommand(param1, "sm_deleteguild");
		}
	}
	return 0;
}

public int Menu_Handler3(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_End) CloseHandle(menu);
	else if(action == MenuAction_Select)
	{
		char info[200];
		menu.GetItem(param2, info, sizeof(info));
		if(StrEqual("1", info))
		{
			ClientCommand(param1, "sm_infob");
		}
		else if(StrEqual("2", info))
		{
			ClientCommand(param1, "sm_topb");
		}
		else if(StrEqual("3", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Scrie suma pe care vrei sa o introduci:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=2;
		}
		else if(StrEqual("4", info))
		{
			CPrintToChat(param1, "{green}[FACTIONS] {default}Scrie numele jucatorului pe care doresti sa-l inviti:");
			g_MsjJucator[param1]=true;
			ClientChoice[param1]=3;
		}
		else if(StrEqual("5", info))
		{
			ClientCommand(param1, "sm_leaveguild");
		}
	}
	return 0;
}

public Action MenuBreasla(int client, int args)
{
	if(!GetConVarBool(g_cMenuEnable)) return Plugin_Handled;
	if(args<1)
	{
		if(!g_bIsPlayerInGuild[client])
		{
			Menu menu1 = new Menu(Menu_Handler1);
			menu1.AddItem("1","Creeaza o FACTIUNE");
			menu1.AddItem("2","Top FACTIUNI");
			menu1.Display(client, 15);
		}
		else if(g_bIsPlayerOwner[client])
		{
			Menu menu2 = new Menu(Menu_Handler2);
			menu2.AddItem("1", "Informatii");
			menu2.AddItem("2", "Top FACTIUNI");
			menu2.AddItem("3", "Introdu EXP");
			menu2.AddItem("4", "Invita un player");
			menu2.AddItem("5", "Da afara un jucator");	
			menu2.AddItem("6", "Schimba numele factiunii");
			menu2.AddItem("7", "Sterge FACTIUNEA");
			menu2.Display(client, 15);
		}
		else
		{
			Menu menu3 = new Menu(Menu_Handler3);
			menu3.AddItem("1", "Informatii");
			menu3.AddItem("2", "Top FACTIUNI");
			menu3.AddItem("3", "Introdu EXP");
			menu3.AddItem("4", "Invita un player");
			menu3.AddItem("5", "Paraseste factiunea");
			menu3.Display(client, 15);
		}
	}
	return Plugin_Handled;
}

