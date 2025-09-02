#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <ServerClassEditor>

public Plugin myinfo = 
{
	name = "SendProp HealthDeadFix",
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
	SendTable pPlayerResourceTable = g_hServerClassEditor.Find("CPlayerResource").GetSendTable();
	if (!pPlayerResourceTable)
		SetFailState("SendTable CPlayerResource not found.");
	
	SendTable pHealthTable = view_as<SendTable>(pPlayerResourceTable.FindProp("m_iHealth").GetDataTable());
	if (!pHealthTable)
		SetFailState("SendProp m_iHealth not found.");
	
	SendProp pProp;
	for (int i = 0; i < pHealthTable.GetNum(); i++)
	{
		pProp = pHealthTable.GetProp(i);
		if (pProp)
		{
			pProp.SetBits(31);
		}
	}
}
