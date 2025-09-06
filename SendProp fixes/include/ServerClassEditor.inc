#if defined _ServerClassEditor_included
	#endinput
#endif
#define _ServerClassEditor_included

#define SPROP_NOSCALE			(1<<2)	// For floating point, don't scale into range, just take value as is.

enum
{
	ServerClass__m_pNetworkName = 	0 * 4,
	ServerClass__m_pTable = 		1 * 4,
	ServerClass__m_pNext = 			2 * 4,
	ServerClass__m_ClassID = 		3 * 4,
	
	SendProp__m_Type = 			2 * 4,
	SendProp__m_nBits = 		3 * 4,
	SendProp__m_fLowValue = 	4 * 4,
	SendProp__m_fHighValue = 	5 * 4,
	SendProp__m_pVarName = 		11 * 4, //в стим версии смещение +1 индексов
	SendProp__m_fHighLowMul = 	12 * 4,
	SendProp__m_Flags = 		13 * 4,
	SendProp__m_pDataTable = 	16 * 4,
	SendProp__m_Offset = 		17 * 4,
	SendProp__Size = 			19 * 4,
	
	SendTable__m_pProps = 			0 * 4,
	SendTable__m_nProps = 			1 * 4,
	SendTable__m_pNetTableName =	2 * 4,
};

stock int ReadStringFromAddress(Address pBase, char[] szResult, int nLength)
{
	if (pBase == Address_Null)
	{
		szResult[0] = '\0';
		return 0;
	}
	
	int i;
	for (i = 0; i < nLength; i++)
	{
	    szResult[i] = view_as<char>(LoadFromAddress(pBase + view_as<Address>(i), NumberType_Int8));
	    if(szResult[i] == '\0')
	        break;
	}
	return i;
}

methodmap BasePointer
{
	public Address Get()
    {
    	return view_as<Address>(this);
    }
}

methodmap SendProp < BasePointer
{
	public int GetType()
	{
		return LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_Type), NumberType_Int32);
	}
	public int GetBits()
	{
		return LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_nBits), NumberType_Int32);
	}
	public float GetLowValue()
	{
		return view_as<float>(LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_fLowValue), NumberType_Int32));
	}
	public float GetHighValue()
	{
		return view_as<float>(LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_fHighValue), NumberType_Int32));
	}
	public int GetVarName(char[] szResult, int nLength)
	{
		Address m_VarName = view_as<Address>(LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_pVarName), NumberType_Int32));
		return ReadStringFromAddress(m_VarName, szResult, nLength);
	}
	public float GetHighLowMul()
	{
		return view_as<float>(LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_fHighLowMul), NumberType_Int32));
	}
	public int GetFlags()
	{
		return LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_Flags), NumberType_Int32);
	}
	public Address GetDataTable() //SendTable
	{
		return (!this) ? Address_Null : view_as<Address>(LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_pDataTable), NumberType_Int32));
	}
	public int GetOffset()
	{
		return LoadFromAddress(this.Get() + view_as<Address>(SendProp__m_Offset), NumberType_Int32);
	}
	
	public void SetBits(int value)
	{
		StoreToAddress(this.Get() + view_as<Address>(SendProp__m_nBits), value, NumberType_Int32);
	}
	public void SetLowValue(float value)
	{
		StoreToAddress(this.Get() + view_as<Address>(SendProp__m_fLowValue), view_as<int>(value), NumberType_Int32);
	}
	public void SetHighValue(float value)
	{
		StoreToAddress(this.Get() + view_as<Address>(SendProp__m_fHighValue), view_as<int>(value), NumberType_Int32);
	}
	public void SetHighLowMul(float value)
	{
		StoreToAddress(this.Get() + view_as<Address>(SendProp__m_fHighLowMul), view_as<int>(value), NumberType_Int32);
	}
	public void SetFlags(int value)
	{
		StoreToAddress(this.Get() + view_as<Address>(SendProp__m_Flags), value, NumberType_Int32);
	}
}

methodmap SendTable < BasePointer
{
	public SendProp GetProp(int nIndex)
	{
		return view_as<SendProp>(LoadFromAddress(this.Get() + view_as<Address>(SendTable__m_pProps), NumberType_Int32) + nIndex * view_as<int>(SendProp__Size));
	}
	public int GetNum()
	{
		return LoadFromAddress(this.Get() + view_as<Address>(SendTable__m_nProps), NumberType_Int32);
	}
	public int GetName(char[] szResult, int nLength)
	{
		Address m_VarName = view_as<Address>(LoadFromAddress(this.Get() + view_as<Address>(SendTable__m_pNetTableName), NumberType_Int32));
		return ReadStringFromAddress(m_VarName, szResult, nLength);
	}
	public SendProp FindProp(const char[] szSearchName)
	{
		char szNetworkName[64];
		int nFindLen = strlen(szSearchName);
		SendProp pProp;
		for (int i = 0; i < this.GetNum(); i++)
		{
			pProp = this.GetProp(i);
			if (pProp.GetVarName(szNetworkName, sizeof(szNetworkName)) == nFindLen &&
				strcmp(szSearchName, szNetworkName) == 0)
			{
				return pProp;
			}
		}
		
		return view_as<SendProp>(Address_Null);
	}
}

methodmap ServerClass < BasePointer
{
	public ServerClass GetNext()
	{
		return view_as<ServerClass>(LoadFromAddress(this.Get() + view_as<Address>(ServerClass__m_pNext), NumberType_Int32));
	}
	public int GetNetworkName(char[] szResult, int nLength)
	{
		Address m_pNetworkName = (!this) ? Address_Null : view_as<Address>(LoadFromAddress(this.Get() + view_as<Address>(ServerClass__m_pNetworkName), NumberType_Int32));
		return ReadStringFromAddress(m_pNetworkName, szResult, nLength);
	}
	public SendTable GetSendTable()
	{
		return view_as<SendTable>((!this) ? Address_Null : view_as<Address>(LoadFromAddress(this.Get() + view_as<Address>(ServerClass__m_pTable), NumberType_Int32)));
	}
	public int GetClassID()
	{
		return (!this) ? -1 : LoadFromAddress(this.Get() + view_as<Address>(ServerClass__m_ClassID), NumberType_Int32);
	}
}

enum struct ServerClassEditor
{
	ServerClass g_pServerClassHead;
	void Init()
	{
		Handle hConfig = LoadGameConfigFile("server-class-editor");
		if (hConfig == INVALID_HANDLE)
			SetFailState("Gamedata server-class-editor not found!");
		
		if (!this.InitServerClassHead(hConfig))
			SetFailState("Unable to locate g_pServerClassHead address.");
		
		if (!this.ChecksumPatch(hConfig))
			SetFailState("Failed checksum patch.");
		
		this.SetupSendTablesCvar();
		CloseHandle(hConfig);
	}
	
	bool InitServerClassHead(Handle hConfig)
	{
		this.g_pServerClassHead = this.FindServerClassHead(hConfig);
		if (!this.g_pServerClassHead)
			return false;
		
		this.g_pServerClassHead = view_as<ServerClass>(LoadFromAddress(view_as<Address>(this.g_pServerClassHead), NumberType_Int32));
		return this.g_pServerClassHead != view_as<ServerClass>(Address_Null);
	}
	ServerClass FindServerClassHead(Handle hConfig)
	{
		Address headAddr = GameConfGetAddress(hConfig, "g_pServerClassHead");
		int offsetAddr = GameConfGetOffset(hConfig, "g_pServerClassHeadOffset");
		
		if (headAddr != Address_Null && offsetAddr > 0)
			headAddr = view_as<Address>(LoadFromAddress(headAddr + view_as<Address>(offsetAddr), NumberType_Int32));
		
		return view_as<ServerClass>(headAddr);
	}
	ServerClass Find(const char[] szSearchName)
	{
		char szNetworkName[64];
		int nFindLen = strlen(szSearchName);
		for (ServerClass pCurrent = this.g_pServerClassHead; pCurrent != view_as<ServerClass>(Address_Null); pCurrent = pCurrent.GetNext() )
		{
			if (pCurrent.GetNetworkName(szNetworkName, sizeof(szNetworkName)) == nFindLen &&
				strcmp(szSearchName, szNetworkName) == 0)
			{
				return pCurrent;
			}
		}
		return view_as<ServerClass>(Address_Null);
	}
	
	void SetupSendTablesCvar()
	{
		ConVar sv_sendtables = FindConVar("sv_sendtables");
		sv_sendtables.BoolValue = true;
		sv_sendtables.SetBounds(ConVarBound_Lower, true, 1.0);
		sv_sendtables.SetBounds(ConVarBound_Upper, true, 1.0);
	}
	bool ChecksumPatch(Handle hConfig)
	{
		Address patchAddr = GameConfGetAddress(hConfig, "g_SendTableCRC");
		Address offsetAddr = view_as<Address>(GameConfGetOffset(hConfig, "g_SendTableCRCOffset"));
		
		if (patchAddr == Address_Null)
			return false;
			
		if (offsetAddr != Address_Null)
			patchAddr = view_as<Address>(LoadFromAddress(patchAddr + offsetAddr, NumberType_Int32));
		
		StoreToAddress(patchAddr, 1337, NumberType_Int32);
		return true;
	}
}

stock ServerClassEditor g_hServerClassEditor;
