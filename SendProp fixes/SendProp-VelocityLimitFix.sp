#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <ServerClassEditor>

public Plugin myinfo = 
{
	name = "SendProp VelocityLimitFix",
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
	
	SendTable pLocalData = view_as<SendTable>(pPlayerTable.FindProp("localdata").GetDataTable());
	if (!pLocalData)
		SetFailState("SendTable CBasePlayer.localdata not found.");
	
	SendProp m_vecVelocity[3];
	m_vecVelocity[0] = pLocalData.FindProp("m_vecVelocity[0]");
	m_vecVelocity[1] = pLocalData.FindProp("m_vecVelocity[1]");
	m_vecVelocity[2] = pLocalData.FindProp("m_vecVelocity[2]");
	
	if (!m_vecVelocity[0] || !m_vecVelocity[1] || !m_vecVelocity[2])
		SetFailState("SendProp LocalDataTable m_vecVelocity not found.");
	
	SendProp m_vecVelocityProp;
	for (int i = 0; i < 3; i++)
	{
		m_vecVelocityProp = m_vecVelocity[i];
		m_vecVelocityProp.SetFlags(m_vecVelocityProp.GetFlags() | SPROP_NOSCALE);
		m_vecVelocityProp.SetBits(0);
		m_vecVelocityProp.SetLowValue(0.0);
		m_vecVelocityProp.SetHighValue(1.0);
		m_vecVelocityProp.SetHighLowMul(0.0);
	}
}