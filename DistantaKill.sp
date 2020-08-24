#include <sdkhooks>
#include <sdktools_engine>
public Plugin:myinfo =
{
	name = "Distanta Kill",
	author = "Pizant",
	description = "Afiseaza distanta de la care ai fost omorat",
	version = "1.0"
}

#define UNIT_MEASURE		0

#if UNIT_MEASURE
#define ADJUSTMENT	UNIT_MEASURE
#else
#tryinclude <smlib/math>
#if defined _smlib_math_included
#define ADJUSTMENT	GAMEUNITS_TO_METERS
#else
#define ADJUSTMENT	0.01905
#endif
#endif
new Float:fP[MAXPLAYERS+1][3];
public OnPluginStart() HookEvent("player_death",	PD);

public OnClientPostAdminCheck(C) SDKHook(C, SDKHook_OnTakeDamage,	DP);

public DP(V, K, I, Float:D, T, W, const Float:F[3], const Float:P[3])
{
	fP[V][0] = P[0];
	fP[V][1] = P[1];
	fP[V][2] = P[2];
}

public PD(Handle:E, String:N[], bool:B)
{
	decl a;
	if((a=GetClientOfUserId(GetEventInt(E,"attacker"))))
	{
		decl v;
		if((v=GetClientOfUserId(GetEventInt(E,"userid"))) !=a)
		{
			GetClientEyePosition(a, fP[a]);
			decl Float:d;
			PrintToChat(a, "\x01[\x04BETIVII\x01] Uciderea s-a facut de la o \x05distanta \x01de \x04%.2f metri\x01.", d=GetVectorDistance(fP[a],fP[v])*ADJUSTMENT);
			PrintToChat(v, "\x01[\x04BETIVII\x01] Uciderea s-a facut de la o \x05distanta \x01de \x04%.2f metri\x01.", d);
		}
	}
} 
