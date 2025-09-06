#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

//включите если потребуется фикс с помощью перехвата звуков
//#define SOUND_HOOK_VERSION

public Plugin myinfo =
{
	name = "Sound Fix",
	author = "Reg1oxeN",
	description = "",
	version = "1.0",
	url = "https://github.com/Reg1oxeN/CS-S-v34-fixes"
};

#if defined SOUND_HOOK_VERSION
	#define SOUND_NORMAL_CLIP_DIST	1000.0
	int g_iWeaponOwner[4096];
#endif

public void OnPluginStart()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{ 
			OnClientPutInServer(i);
		}
	}
#if defined SOUND_HOOK_VERSION
	AddNormalSoundHook(OnNormalSound);
#endif
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
#if defined SOUND_HOOK_VERSION
	SDKHook(client, SDKHook_WeaponDropPost, OnWeaponDropPost);
#endif
}

public void OnWeaponEquipPost(int client, int weapon)
{
	if (weapon > MaxClients && weapon < 4096)
	{
#if defined SOUND_HOOK_VERSION
		g_iWeaponOwner[weapon] = client;
#else
		TeleportEntity(weapon, {0.0, 0.0, 31.0}, NULL_VECTOR, NULL_VECTOR);
#endif
	}
}

#if defined SOUND_HOOK_VERSION
public void OnWeaponDropPost(int client, int weapon)
{
	if (weapon > MaxClients && weapon < 4096)
		g_iWeaponOwner[weapon] = 0;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (entity > MaxClients && entity < 4096)
		g_iWeaponOwner[entity] = 0;
}
public void OnEntityDestroyed(int entity)
{
	if (entity > MaxClients && entity < 4096)
		g_iWeaponOwner[entity] = 0;
}

bool IsStvClient(int client)
{
	return IsClientSourceTV(client) || (IsFakeClient(client) && IsClientObserver(client));
}

bool IsClientAudible(int client, float maxAudible, float origin[3])
{
	float result[3];
	GetClientEyePosition(client, result);
	SubtractVectors(result, origin, result);
	float distance = GetVectorLength(result);
	return (distance <= maxAudible);
}

void GetClientWorldSpaceCenter(int client, float origin[3])
{
	float mins[3], maxs[3];
	GetClientMins(client, mins);
	GetClientMaxs(client, maxs);
	GetClientAbsOrigin(client, origin);
	maxs[2] /= 2.0;
	mins[2] -= maxs[2];
	origin[2] += maxs[2];
}

public Action OnNormalSound(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	if (entity <= MaxClients || !IsValidEntity(entity))
		return Plugin_Continue;

	int iOwner = g_iWeaponOwner[entity];
	if (iOwner == 0)
		return Plugin_Continue;
	
	int client;
	int newTotal = 0;
	int newClients[MAXPLAYERS];
	bool bAddClient[MAXPLAYERS] = {false, ...};
	bAddClient[iOwner] = true;
	
	for (client = 0; client < numClients; client++)
	{
		bAddClient[clients[client]] = true;
	}
	
	float maxAudible = (2.0 * SOUND_NORMAL_CLIP_DIST) / SNDATTN_NORMAL/*attenuation*/;
	float soundOrigin[3]; GetClientWorldSpaceCenter(iOwner, soundOrigin);
	for (client = 1; client <= MaxClients; client++)
	{
		if (bAddClient[client] || !IsClientInGame(client))
			continue;
		
		if (IsStvClient(client) || IsClientAudible(client, maxAudible, soundOrigin))
		{
			newClients[newTotal++] = client;
		}
	}
	
	for (client = 0; client < newTotal; client++)
	{
		clients[numClients++] = newClients[client];
	}
	
	entity = iOwner;
	return Plugin_Changed;
}
#endif