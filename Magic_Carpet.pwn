//https://youtu.be/bly8gLhjAY8
//============================ Includes =======================================//
#include <a_samp>
#include <sscanf2>
#include <zcmd>
#include <foreach>
//============================== Defines ======================================//
#define SCM 	 	SendClientMessage
#define SCMToAll 	SendClientMessageToAll
//============================ Varaibles ======================================//
new MAGIC_CARPET[MAX_PLAYERS];
new MC[MAX_PLAYERS];
new Float:GX, Float:GY, Float:GZ;
new Float:CFP[MAX_PLAYERS][3];
new INVITED_PLAYERID[MAX_PLAYERS];
new PLAYER_MC_ID[MAX_PLAYERS];
new MC_COUNT;
new OBJECT_ID = 19129;

public OnFilterScriptInit()
{
    MC_COUNT = 0;
	print("\n--------------------------------------");
	print(" MAGIC_CARPET LOADED");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
    MC_COUNT = 0;
	return 1;
}

//=============================== CommanDs =====================================//
CMD:mchelp(playerid)
{
	SCM(playerid,-1,"============== MAGIC CARPET =============");
	SCM(playerid,-1,"/mc to enable & disable magic card.");
	SCM(playerid,-1,"/mmc to move magic card.");
	SCM(playerid,-1,"/mch to set magic card height.");
	SCM(playerid,-1,"/mcs to set the speed of magic carpet.");
	SCM(playerid,-1,"/imc to invite some to magic carpet.");
	SCM(playerid,-1,"/lmc to leave magic carpet carpet.");
	SCM(playerid,-1,"============== MAGIC CARPET =============");
	return 1;
}

CMD:mc(playerid)
{
	switch(MAGIC_CARPET[playerid])
	{
		case 0:
		{
		    GetPlayerPos(playerid, GX, GY, GZ);
		    MC[playerid] = CreateObject(OBJECT_ID, GX, GY, GZ-0.97, 0, 0, 4);
			MC_COUNT++;
			PLAYER_MC_ID[playerid] = MC_COUNT;
		    SetPlayerPos(playerid, GX, GY, GZ+42);
			SetObjectPos(MC[playerid], GX, GY, GZ+40);
	     	SCM(playerid,-1, "You've successfully Enabled magic carpet! Use /mc to disable it.");
			SCM(playerid,-1, "Press Esc and chose Position on map to set the destination of your Magic Carpet.");
			SCM(playerid,-1, "Use /mmc cmd to start the magic carpet.");
	  		TogglePlayerControllable(playerid, 0);
		    MAGIC_CARPET[playerid] = 1;
		}
		case 1:
		{
			TogglePlayerControllable(playerid, 1);
	        DestroyObject(MC[playerid]);
	        MC_COUNT--;
	        PLAYER_MC_ID[playerid] = -1;
	     	SCM(playerid,-1, "You've successfully Disabled magic carpet! Use /mc to enable it.");
			MAGIC_CARPET[playerid] = 0;
		}
	}
	PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
	return 1;
}

CMD:mo(playerid,params[])
{
	new string[128],ID;
	if(sscanf(params,"i",ID))return SCM(playerid,-1,"use /mo [Object ID]");
	OBJECT_ID = ID;
	format(string,sizeof(string),"You successfully Updated object id to %d",OBJECT_ID);
	SCM(playerid,-1,string);
	SCM(playerid,-1, "Please use /mc command again to update the object Thanks.");
	return 1;
}

CMD:smc(playerid)
{
	if(!MAGIC_CARPET[playerid])return SCM(playerid,-1,"You don't have magic carpet at moment.");
	StopObject(MC[playerid]);
	SCM(playerid,-1,"You've successfully stop the Magic Carpet.");
	return 1;
}

CMD:mmc(playerid)
{
	if(!MAGIC_CARPET[playerid])return SCM(playerid,-1,"You don't have magic carpet at moment.");
	if( CFP[playerid][0] == 0.0 && CFP[playerid][1] == 0.0  && CFP[playerid][2]  == 0.0 )return SCM(playerid,-1,"You need to select postion on map.");
	MoveObject(MC[playerid], CFP[playerid][0], CFP[playerid][1], CFP[playerid][2], 5.00);
	TogglePlayerControllable(playerid, 1);
	foreach(Player,i)
	{
		if(i != playerid && PLAYER_MC_ID[i] == PLAYER_MC_ID[playerid] && INVITED_PLAYERID[i])
		{
			TogglePlayerControllable(i, 1);
		}
	}
	SCM(playerid,-1,"You've successfully move the Magic Carpet.");
	return 1;
}

CMD:mch(playerid,params[])
{
	new Height;
	if(!MAGIC_CARPET[playerid])return SCM(playerid,-1,"You don't have magic carpet at moment.");
	if(sscanf(params,"i",Height))return SCM(playerid,-1,"/mch [Height]");
	StopObject(MC[playerid]);
 	GetPlayerPos(playerid, GX, GY, GZ);
	TogglePlayerControllable(playerid, 0);
 	SetPlayerPos(playerid, GX, GY, GZ+Height);
	SetObjectPos(MC[playerid], GX, GY, GZ+Height);
	foreach(Player,i)
	{
		if(i != playerid && PLAYER_MC_ID[i] == PLAYER_MC_ID[playerid] && INVITED_PLAYERID[i])
		{
		 	GetPlayerPos(i, GX, GY, GZ);
			TogglePlayerControllable(i, 0);
		 	SetPlayerPos(i, GX, GY, GZ+Height);
		}
	}
	SCM(playerid,-1, "You've successfully set the magic carpet height! Use /mmc to move it.");
	return 1;
}

CMD:imc(playerid,params[])
{
	new ID;
	if(!MAGIC_CARPET[playerid])return SCM(playerid,-1,"You don't have magic carpet at moment.");
	if(sscanf(params,"i",ID))return SCM(playerid,-1,"/imc [playerid]");
	if(MAGIC_CARPET[ID])return SCM(playerid,-1,"that player already using magic carpet.");
	StopObject(MC[playerid]);
	GetPlayerPos(playerid, GX, GY, GZ);
	TogglePlayerControllable(ID, 0);
 	SetPlayerPos(ID, GX, GY, GZ+3);
	SCM(ID,-1, "You're successfully teleported to the Magic Carpet.");
	SCM(playerid,-1, "You're successfully teleported player to the Magic Carpet.");
    PLAYER_MC_ID[ID] = PLAYER_MC_ID[playerid];
	INVITED_PLAYERID[ID] = 1;
	SCM(playerid,-1, "To leave the magic Carpet use /lmc.");
	return 1;
}

CMD:lmc(playerid,params[])
{
    if(!INVITED_PLAYERID[playerid])return SCM(playerid,-1,"You're not invited to any magic carpet.");
	if(MAGIC_CARPET[playerid])return SCM(playerid,-1,"You're not allowed to leave magic carpet.");
	SpawnPlayer(playerid);
	INVITED_PLAYERID[playerid] = 0;
	PLAYER_MC_ID[playerid] = -1;
	MC_COUNT--;
	SCM(playerid,-1, "You're successfully left the Magic Carpet.");
	return 1;
}

CMD:mcs(playerid,params[])
{
	new speed;
	if(!MAGIC_CARPET[playerid])return SCM(playerid,-1,"You don't have magic carpet at moment.");
	if(sscanf(params,"i",speed))return SCM(playerid,-1,"/mcs [Speed]");
	if( 0 < speed > 21)return SCM(playerid,-1,"Speed must be in between 1 to 20");
	StopObject(MC[playerid]);
	MoveObject(MC[playerid], CFP[playerid][0], CFP[playerid][1], CFP[playerid][2], speed);
	SCM(playerid,-1, "You've successfully set the magic carpet speed! Use /mmc to move it.");
	return 1;
}

//===================================== Callbacks ==============================//
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(MAGIC_CARPET[playerid])
	{
		CFP[playerid][0] = fX , CFP[playerid][1] = fY , CFP[playerid][2] = fZ;
	 	SetPlayerRaceCheckpoint(playerid,1,CFP[playerid][0],CFP[playerid][1],CFP[playerid][2],0.0,0.0,0.0,10.0);
		SCM(playerid,-1, "You've successfully set the destination of magic carpet! Use /mmc to move it.");
	}
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(MAGIC_CARPET[playerid])
	{
		SCM(playerid,-1,"[Magic Carpet]: You're successfully reached at your selected destination.");
    	DisablePlayerRaceCheckpoint(playerid);
	}
    return 1;
}

public OnPlayerConnect(playerid)
{
    INVITED_PLAYERID[playerid] = 0;
	MAGIC_CARPET[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(MAGIC_CARPET[playerid])
	{
			foreach(Player,i)
			{
				if(i != playerid && PLAYER_MC_ID[i] == PLAYER_MC_ID[playerid] && INVITED_PLAYERID[i])
				{
					INVITED_PLAYERID[i] = 0;
					PLAYER_MC_ID[i] = -1;
				}
			}
	        DestroyObject(MC[playerid]);
			MAGIC_CARPET[playerid] = 0;
			MC_COUNT--;
	}
	return 1;
}
