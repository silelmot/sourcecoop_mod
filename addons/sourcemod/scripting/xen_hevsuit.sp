#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.0"
#define MAX_WEAPONS 10

public Plugin:myinfo =
{
        name = "Charger",
        author = "sil_el_mot",
        description = "chargeroverride",
        version = PLUGIN_VERSION,
        url = "http://www.sourcemod.net/"
};

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
    decl Float:clientpos[3];
    GetClientAbsOrigin(client, clientpos);

    int ent = -1;
    float origin[3];

    do
    {
        ent = FindEntityByClassname(ent, "prop_hev_charger");
        if (ent == -1) break;  // Break if no entities found

        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
        
        if (GetVectorDistance(clientpos, origin) < 100)
        {
            PrintToServer("am near HEV Charger");

            new armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
            PrintToServer("Armor: %i", armor);

            if (armor < 100)
            {
                PrintToServer("kleiner als 100");
                CreateTimer(1.0, IncreaseArmor, client, TIMER_REPEAT);
            }
        }
    } while (ent != -1);

    // Reset ent for the next search
    ent = -1;

    // test for prop_radiation_charger - Not tested yet, didnt found a radiation charger in maps
    do
    {
        ent = FindEntityByClassname(ent, "prop_radiation_charger");
        if (ent == -1) break;  // Break if no entities found
        PrintToServer("Radiationcharger near");

        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);

        if (GetVectorDistance(clientpos, origin) < 100)
        {
            PrintToServer("am near Radiation Charger");

            int weaponEntity;
            for (int i = 0; i < MAX_WEAPONS; i++) 
            {
                weaponEntity = GetPlayerWeaponSlot(client, i);
                char sClassname[64];
                GetEntityClassname(weaponEntity, sClassname, sizeof(sClassname));
                PrintToServer(sClassname);
                if (weaponEntity != -1 && StrEqual(sClassname, "weapon_gluon"))
                {
                    int currentAmmo = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
                    if (currentAmmo < GetEntProp(weaponEntity, Prop_Send, "m_iClip1_Max"))
                    {
                        PrintToServer("Recharging Gluon Gun");
                        CreateTimer(1.0, IncreaseGluonAmmo, client, TIMER_REPEAT);
                        break;  // break while loop , weapon found
                    }
                }
            }
        }
    }  while (ent != -1);


    return Plugin_Continue;
}

public Action IncreaseArmor(Handle:timer, any:client)
{
    if (!IsClientConnected(client))
    {
        KillTimer(timer);
        return Plugin_Stop;
    }

    new armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
    armor += 1;

    if (armor >= 100)
    {
        armor = 100;
        KillTimer(timer);
    }

    SetEntProp(client, Prop_Data, "m_ArmorValue", armor, 1);
    PrintToServer("Armor erhöht auf: %i", armor);

    return Plugin_Continue;  
}


public Action IncreaseGluonAmmo(Handle:timer, any:client)
{
    if (!IsClientConnected(client))
    {
        KillTimer(timer);
        return Plugin_Stop;
    }

    int weaponEntity = GetPlayerWeaponSlot(client, 1); 
    char sClassname[64];
    GetEntityClassname(weaponEntity, sClassname, sizeof(sClassname));
    if (weaponEntity != -1 && StrEqual(sClassname, "weapon_gluon"))
    {
        int currentAmmo = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
        int maxAmmo = GetEntProp(weaponEntity, Prop_Send, "m_iClip1_Max");
        currentAmmo += 1;

        if (currentAmmo >= maxAmmo)
        {
            currentAmmo = maxAmmo;
            KillTimer(timer);
        }

        SetEntProp(weaponEntity, Prop_Data, "m_iClip1", currentAmmo, 1);
        PrintToServer("Gluon Gun Ammo erhöht auf: %i", currentAmmo);
    }

    return Plugin_Continue;
}

