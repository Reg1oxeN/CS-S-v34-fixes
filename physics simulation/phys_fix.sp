#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo = 
{
	name = "pFix Physics Simulation",
	author = "Reg1oxeN",
	description = "",
	version = "1.1",
	url = ""
};

#define DEFAULT_TICK_INTERVAL	(0.015)	
#define TICK_MULTIPLIER	(1.0)	
/**
 * вообще по-умолчанию у валвов тикрейт физики в 2 раза выше, чем тикрейт сервера.
 * ставьте TICK_MULTIPLIER 2.0 только чтобы соответствовать этим нормам, но я не увидел в этом смысла.
 */

bool Patched = false;
Address patchAddr = Address_Null;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max){
	int current_tickrate = RoundToZero(1.0 / GetTickInterval());
	int phys_tickrate = RoundToZero(1.0 / DEFAULT_TICK_INTERVAL / TICK_MULTIPLIER);
	if (phys_tickrate >= current_tickrate)
	{
		Format(error, err_max, "The server is running lower %i tickrate", current_tickrate + 1);
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	Handle hConfig = LoadGameConfigFile("phys-patch");
		
	if(hConfig == INVALID_HANDLE)
		SetFailState("Load phys-patch Config Fail");
		
	patchAddr = GameConfGetAddress(hConfig, "CPhysicsHook::LevelInitPreEntity");
	Address offsetAddr = view_as<Address>(GameConfGetOffset(hConfig, "SetSimulationTimestepOffset"));
	
	CloseHandle(hConfig);
	
	if (patchAddr == Address_Null || offsetAddr == Address_Null)
		SetFailState("Read phys-patch Config Fail");
		
	patchAddr += offsetAddr;
		
	Patch_Physics();
}


public void OnPluginEnd()
{
	UnPatch_Physics();	
}

public void Patch_Physics()
{
	float TICK_INTERVAL = view_as<float>(LoadFromAddress(patchAddr, NumberType_Int32));
	if (TICK_INTERVAL != DEFAULT_TICK_INTERVAL)
		SetFailState("Read PhysTickRate Fail [%f]", TICK_INTERVAL);
	else
	{
		float TickInterval = GetTickInterval() / TICK_MULTIPLIER;
		if (TickInterval < TICK_INTERVAL)
		{
			StoreToAddress(patchAddr, view_as<int>(TickInterval), NumberType_Int32);
			Patched = true;
		}
	}
}

public void UnPatch_Physics()
{
	if (Patched)
	{
		StoreToAddress(patchAddr, view_as<int>(DEFAULT_TICK_INTERVAL), NumberType_Int32);
		Patched = false;
	}
}
