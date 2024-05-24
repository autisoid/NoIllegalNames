CScheduledFunction@ g_lpfnChecker = null;

void PluginInit() {
    g_Module.ScriptInfo.SetAuthor("xWhitey");
    g_Module.ScriptInfo.SetContactInfo("tyabus @ Discord");
    
    g_Hooks.RegisterHook(Hooks::Player::ClientConnected, @HOOKED_ClientConnected);
    if (g_lpfnChecker is null) //guaranteed to be true
        @g_lpfnChecker = g_Scheduler.SetInterval("Checker", 1.5f);
}

void MapInit() {
    if (g_lpfnChecker !is null && !g_lpfnChecker.HasBeenRemoved())
        g_Scheduler.RemoveTimer(g_lpfnChecker);
    @g_lpfnChecker = g_Scheduler.SetInterval("Checker", 1.5f);
}

void Checker() {
    for (int idx = 1; idx <= g_Engine.maxClients; idx++) {
        CBasePlayer@ pVictim = g_PlayerFuncs.FindPlayerByIndex(idx);
        if (pVictim is null or !pVictim.IsConnected()) continue;
        
        KeyValueBuffer@ pInfo = g_EngineFuncs.GetInfoKeyBuffer(pVictim.edict());
        string szName = pInfo.GetValue("name");
        
        bool bInvalid = false;
        
        for (uint j = 0; j < szName.Length(); j++) {
            if (szName[j] > 127) {
                bInvalid = true;
                break;
            }
        }
        
        if (bInvalid) {
            pInfo.SetValue("name", "New Player");
            if (pVictim.IsConnected())
                g_PlayerFuncs.SayText(pVictim, "We've detected that you're using an illegal name so we automatically changed it to \"New Player\".\n");
        }
    }
}

HookReturnCode HOOKED_ClientConnected(edict_t@ _ThePlayer, const string& in _PlayerName, const string& in _IPAddress, bool& out _bDisallowJoin, string& out _RejectReason) {
    KeyValueBuffer@ pInfo = g_EngineFuncs.GetInfoKeyBuffer(_ThePlayer);
    string szName = pInfo.GetValue("name");
    
    bool bInvalid = false;
    
    for (uint idx = 0; idx < szName.Length(); idx++) {
        if (szName[idx] > 127) {
            bInvalid = true;
            break;
        }
    }
    
    if (bInvalid) {
        pInfo.SetValue("name", "New Player");
    }
    
    return HOOK_CONTINUE;
}
