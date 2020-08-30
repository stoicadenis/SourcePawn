public Action TopGuild(int client, int args){
	if(args<1){
		char buffer[200];
		Format(buffer,sizeof(buffer),"SELECT * FROM guild ORDER BY exp DESC LIMIT 10");
		SQL_LockDatabase(db);
		DBResultSet query = SQL_Query(db, buffer);
		SQL_UnlockDatabase(db);
		Menu menu = CreateMenu(Menu_Handler);
		menu.SetTitle("Top 10 BRESLE");
		
		char name[MAX_NAME_LENGTH], textbuffer[200];
		char exp[8];
		if(SQL_HasResultSet(query)){
			while (SQL_FetchRow(query))
			{
				SQL_FetchString(query, 0, name, sizeof(name));
				SQL_FetchString(query, 3, exp, sizeof(exp));
				Format(textbuffer,sizeof(textbuffer), "%s - %d EXP", name,StringToInt(exp));
				menu.AddItem(name, textbuffer);
			}
		}
		else{
			menu.AddItem("empty", "TOPul este gol!");
		}
		delete query;
		menu.ExitButton = true;
		menu.ExitBackButton = false;
		menu.Display(client,MENU_TIME_FOREVER);
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

