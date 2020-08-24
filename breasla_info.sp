public int PanelHandler(Menu menu, MenuAction action, int param1, int param2){
	if(action==MenuAction_Cancel){
		delete menu;
	}
	else if(action== MenuAction_End){
		delete menu;
	}
}

public Action InfoGuild(int client, int args){
	if(args>=1){
		CPrintToChatEx(client, client, "[FACTIONS] sm_infob OR !infob");
		return Plugin_Handled;
	}
	if(IsValidClient(client)){
		if(g_bIsPlayerInGuild[client]){	
			//CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Factiunea ta are -> %d experienta, %d nivele!", exp[client], exp[client]/1000);
			Panel panel = new Panel();
			panel.SetTitle("Detalii FACTIUNE");
			panel.DrawText("");
			if(g_bHasBonus1[client]){
				panel.DrawText("Bonus Tag: ACTIVAT");
			}
			else{
				panel.DrawText("Bonus Tag: LA NIVELUL 5");
			}
			if(g_bHasBonus2[client]){
				panel.DrawText("Bonus Transfer: ACTIVAT");
			}
			else{
				panel.DrawText("Bonus Transfer: LA NIVELUL 10");
			}
			if(g_bHasBonus3[client]){
				panel.DrawText("Bonus Credite/Kill: ACTIVAT");
			}
			else{
				panel.DrawText("Bonus Credite/Kill: LA NIVELUL 20");
			}
			if(g_bHasBonus4[client]){
				panel.DrawText("Bonus Double-Jump: ACTIVAT");
			}
			else{
				panel.DrawText("Bonus Double-Jump: LA NIVELUL 50");
			}
			panel.DrawItem("Inchide");
			panel.Send(client, PanelHandler, 15);
		}
		else{
			CPrintToChatEx(client, client, "{green}[FACTIONS] {default}Nu esti intr-o FACTIUNE!");
		}
	}
	return Plugin_Handled;
}