#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo = 
{
	name = "Health Limit Fix",
	author = "Reg1oxeN",
	description = "",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	ConVar convar = FindConVar("sv_sendtables");
	convar.AddChangeHook(SendHook);
	convar.BoolValue = true;
	
	Handle hConfig = LoadGameConfigFile("health-patch");
		
	if(hConfig == INVALID_HANDLE)
		SetFailState("Load health-patch Config Fail");
		
	Address patchAddr[2] = {Address_Null, ...};
	patchAddr[0] = GameConfGetAddress(hConfig, "m_iHealth");
	patchAddr[1] = GameConfGetAddress(hConfig, "g_SendTableCRC");
	Address offsetAddr1 = view_as<Address>(GameConfGetOffset(hConfig, "m_iHealthOffset_1"));
	Address offsetAddr2 = view_as<Address>(GameConfGetOffset(hConfig, "m_iHealthOffset_2"));
	Address offsetAddr3 = view_as<Address>(GameConfGetOffset(hConfig, "g_SendTableCRCOffset_1"));
	Address offsetAddr4 = view_as<Address>(GameConfGetOffset(hConfig, "g_SendTableCRCOffset_2"));
	
	CloseHandle(hConfig);
	
	if (patchAddr[0] == Address_Null || patchAddr[1] == Address_Null ||
		offsetAddr1 == Address_Null || offsetAddr2 == Address_Null || offsetAddr4 == Address_Null)
	{
		SetFailState("Read health-patch Config Fail");
	}
		
	patchAddr[0] += offsetAddr1;
	patchAddr[0] = view_as<Address>(LoadFromAddress(patchAddr[0], NumberType_Int32)) + offsetAddr2;
	
	if (offsetAddr3 != Address_Null)
	{
		patchAddr[1] += view_as<Address>(1);
		patchAddr[1] = patchAddr[1] + view_as<Address>(LoadFromAddress(patchAddr[1], NumberType_Int32)) + view_as<Address>(4);
	}
	patchAddr[1] = view_as<Address>(LoadFromAddress(patchAddr[1] + offsetAddr4, NumberType_Int32));
	
	StoreToAddress(patchAddr[0], 17, NumberType_Int8);
	StoreToAddress(patchAddr[1], 1337, NumberType_Int32);
}

public void SendHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	convar.BoolValue = true;
}