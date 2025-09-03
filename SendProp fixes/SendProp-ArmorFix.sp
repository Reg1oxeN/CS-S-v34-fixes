#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <ServerClassEditor>

public Plugin myinfo = 
{
	name = "SendProp ArmorFix",
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
	SendTable pPlayerTable = g_hServerClassEditor.Find("CCSPlayer").GetSendTable();
	if (!pPlayerTable)
		SetFailState("SendTable CCSPlayer not found.");
	
	SendProp m_ArmorValue = pPlayerTable.FindProp("m_ArmorValue");
	if (!m_ArmorValue)
		SetFailState("SendProp m_ArmorValue not found.");
	
	m_ArmorValue.SetBits(17);
}