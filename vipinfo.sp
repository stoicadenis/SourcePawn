#include <sourcemod>

public Plugin:myinfo = {
	name="Vip Price Info",
	author="Pizant",
	description="Info about VIP Prices",
	version="1.0"
};

public void OnPluginStart(){
	RegConsoleCmd("sm_info",MENU_Info);
}

public int MenuHandler1(Menu menu, MenuAction action, int param1, int param2){
	if(action == MenuAction_Select){
		PrintToChat(param1, "Pentru a afla ce contine VIP-ul acceseaza acest link: \n>> https://bit.ly/2RwtshU <<" )
	}
	else if(action == MenuAction_Cancel){
		PrintToChat(param1, "Ai inchis meniul pentru preturile de la VIP!");
	}
}

public Action MENU_Info(int client, int args){
	Panel menu= new Panel();
	menu.SetTitle("$ Preturi VIP $");
	menu.DrawItem("VIP Level 1 ~ 5€");
	menu.DrawItem("VIP Level 2 ~ 10€");
	menu.DrawItem("VIP Level 3 ~ 20€");
	menu.DrawItem("VIP Level 4 ~ Va urma");
	
	menu.Send(client, MenuHandler1, 20);
	
	delete menu;
	
	return Plugin_Handled;
}