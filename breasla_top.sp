#define MAX_LENGTH_MENU 470

public Action TopGuild(int client, int args){
	if(args<1){
		char buffer[200];
		Format(buffer,sizeof(buffer),"SELECT * FROM guild ORDER BY exp DESC LIMIT 10");
		SQL_TQuery(db, SQL_ShowMenu, buffer, GetClientUserId(client));
		
	}
	return Plugin_Handled;
}

public int Menu_Handler(Menu menu, MenuAction action, int param1, int param2){
	if( action == MenuAction_Select ) 
	{
		delete menu;
	}
	else if(action == MenuAction_Cancel) 
	{
		delete menu;
	}
}

public void SQL_ShowMenu(Handle owner, Handle hndl, const char[] error, any data)
{
	if(owner == INVALID_HANDLE || hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL_ShowMenu error: %s", error);
		return;
	}
	int client = GetClientOfUserId(client);
	if(client == 0)
	{
		return;
	}
	Menu menu = CreateMenu(Menu_Handler);
	menu.SetTitle("Top 10 FACTIUNI");
	
	char name[MAX_NAME_LENGTH], textbuffer[200];
	char exp[8];
	if(SQL_HasResultSet(hndl)){
		while (SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, name, sizeof(name));
			SQL_FetchString(hndl, 3, exp, sizeof(exp));
			Format(textbuffer,sizeof(textbuffer), "%s - %d EXP", name, StringToInt(exp));
			menu.AddItem(name, textbuffer);
		}
	}
	else{
		menu.AddItem("empty", "TOP-ul este gol!");
	}
	menu.ExitButton = true;
	menu.ExitBackButton = false;
	menu.Display(client,MENU_TIME_FOREVER);
}

