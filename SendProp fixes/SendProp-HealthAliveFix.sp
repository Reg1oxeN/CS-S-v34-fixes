#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <ServerClassEditor>

public Plugin myinfo = 
{
	name = "SendProp HealthAliveFix",
	author = "Reg1oxeN",
	description = "",
	version = "1.0",
	url = "https://github.com/Reg1oxeN/CS-S-v34-fixes"
};

public void OnPluginStart()
{
	g_hServerClassEditor.Init();
	DoPatch();
}

void DoPatch()
{
	SendTable pPlayerTable = g_hServerClassEditor.Find("CBasePlayer").GetSendTable();
	if (!pPlayerTable)
		SetFailState("SendTable CBasePlayer not found.");
	
	SendProp m_iHealth = pPlayerTable.FindProp("m_iHealth");
	if (!m_iHealth)
		SetFailState("SendProp m_iHealth not found.");
	
	m_iHealth.SetBits(17);	
}