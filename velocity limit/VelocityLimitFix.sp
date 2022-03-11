#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo = 
{
	name = "Velocity Limit Fix",
	author = "Reg1oxeN",
	description = "",
	version = "1.0",
	url = ""
};

enum SendPropClass
{
	//SendProp__m_Type = 0x8,
	SendProp__m_nBits = 0xC,
	SendProp__m_fLowValue = 0x10,
	SendProp__m_fHighValue = 0x14,
	SendProp__m_fHighLowMul = 0x30,
	SendProp__m_Flags = 0x34,
};

public void OnPluginStart()
{
	ConVar convar = FindConVar("sv_sendtables");
	convar.AddChangeHook(SendHook);
	convar.BoolValue = true;
	
	Handle hConfig = LoadGameConfigFile("velocity-patch");
		
	if(hConfig == INVALID_HANDLE)
	{
		SetFailState("Load velocity-patch Config Failed");
	}
	
	if (!SendTablePatch(hConfig))
	{
		SetFailState("SendTable Patch Failed");
	}
	else if (!m_vecVelocityPatch(hConfig))
	{
		SetFailState("m_vecVelocity Patch Failed");
	}
	
	CloseHandle(hConfig);
}

public void SendHook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	convar.BoolValue = true;
}

public bool m_vecVelocityPatch(Handle hConfig)
{
	Address ServerClassInitAddr = GameConfGetAddress(hConfig, "ServerClassInit");
	Address m_vecVelocityAddr[3] = {Address_Null, ...};
	m_vecVelocityAddr[0] = view_as<Address>(GameConfGetOffset(hConfig, "m_vecVelocity[0]"));
	m_vecVelocityAddr[1] = view_as<Address>(GameConfGetOffset(hConfig, "m_vecVelocity[1]"));
	m_vecVelocityAddr[2] = view_as<Address>(GameConfGetOffset(hConfig, "m_vecVelocity[2]"));
	if (ServerClassInitAddr == Address_Null || m_vecVelocityAddr[0] == Address_Null || m_vecVelocityAddr[1] == Address_Null || m_vecVelocityAddr[2] == Address_Null)
	{
		return false;
	}
	
	for (int i = 0; i < sizeof(m_vecVelocityAddr); i++)
	{
		m_vecVelocityAddr[i] = view_as<Address>(LoadFromAddress(ServerClassInitAddr + m_vecVelocityAddr[i], NumberType_Int32));
	}
	
	for (int i = 0; i < sizeof(m_vecVelocityAddr); i++)
	{
		SendPropPatch(m_vecVelocityAddr[i]);
	}
	return true;
}


public void SendPropPatch(Address sendprop)
{
	StoreToAddress(sendprop + view_as<Address>(SendProp__m_nBits), 0, NumberType_Int32);
	StoreToAddress(sendprop + view_as<Address>(SendProp__m_fLowValue), 0, NumberType_Int32);
	StoreToAddress(sendprop + view_as<Address>(SendProp__m_fHighValue), 0x3F800000, NumberType_Int32);
	StoreToAddress(sendprop + view_as<Address>(SendProp__m_fHighLowMul), 0x4F800000, NumberType_Int32);
	StoreToAddress(sendprop + view_as<Address>(SendProp__m_Flags), 3076, NumberType_Int32);
}

public bool SendTablePatch(Handle hConfig)
{
	Address patchAddr = GameConfGetAddress(hConfig, "g_SendTableCRC");
	Address offsetAddr1 = view_as<Address>(GameConfGetOffset(hConfig, "g_SendTableCRCOffset_1"));
	Address offsetAddr2 = view_as<Address>(GameConfGetOffset(hConfig, "g_SendTableCRCOffset_2"));
	if (patchAddr == Address_Null || offsetAddr2 == Address_Null)
	{
		return false;
	}
	
	if (offsetAddr1 != Address_Null)
	{
		patchAddr += view_as<Address>(1);
		patchAddr = patchAddr + view_as<Address>(LoadFromAddress(patchAddr, NumberType_Int32)) + view_as<Address>(4);
	}
	patchAddr = view_as<Address>(LoadFromAddress(patchAddr + offsetAddr2, NumberType_Int32));
	StoreToAddress(patchAddr, 1337, NumberType_Int32);
	return true;
}