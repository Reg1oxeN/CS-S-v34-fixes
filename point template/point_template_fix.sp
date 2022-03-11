#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo =
{
	name = "point_template entity fix",
	author = "Reg1oxeN",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	Handle hConfig = LoadGameConfigFile("point_template-fix");
	if(hConfig == INVALID_HANDLE)
	{
		SetFailState("Load point_template-fix Config Fail");
	}
	
	Address patchAddr = GameConfGetAddress(hConfig, "CPointTemplate_AllowNameFixup");
	CloseHandle(hConfig);
	
	if (patchAddr == Address_Null)
	{
		SetFailState("Read point_template-fix Config Fail");
	}
	
	StoreToAddress(patchAddr, 						0xB8, 	NumberType_Int8);
	StoreToAddress(patchAddr + view_as<Address>(1), 0x0, 	NumberType_Int32);
	StoreToAddress(patchAddr + view_as<Address>(5), 0xC3, 	NumberType_Int8);
	StoreToAddress(patchAddr + view_as<Address>(6), 0x0, 	NumberType_Int32);
}