#include <sourcemod>
#include <smlib>
#define PLUGIN_VERSION "1.0"
#include <sdkhooks>
#define MAX_AMMO 100
#define AMMO_PER_CHARGE 20
#define START_AMMO 80

bool hasUsedGluonGun[MAXPLAYERS+1];
int playerAmmo[MAXPLAYERS+1];

int Clamp(int value, int min, int max) {
    if (value < min) {
        return min;
    } else if (value > max) {
        return max;
    } else {
        return value;
    }
}

public Plugin:myinfo =
{
        name = "Xen_Charger",
        author = "sil_el_mot",
        description = "chargeroverride",
        version = PLUGIN_VERSION,
        url = "http://www.sourcemod.net/"
};

public void OnPluginStart() {
    // Hook the custom event "weapon_gluon_fired"
    HookEvent("weapon_gluon_fired", Event_WeaponGluonFired);
    HookEvent("player_death", OnPlayerDeath);
}


// Der Event-Handler für den Tod eines Spielers.
public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Stellen Sie sicher, dass der Spielerindex gültig ist.
    if (client > 0 && IsClientInGame(client)) {
        // Setzen Sie die Munition zurück
        playerAmmo[client] = START_AMMO; // Angenommen, START_AMMO ist eine Konstante, die Sie definiert haben.
        // Setzen Sie auch hasUsedGluonGun zurück
        hasUsedGluonGun[client] = true;
    }
}

public Event_WeaponGluonFired(Handle:event, const char[] name, bool:dontBroadcast) {
    // Get the client who fired the gluon gun
    int client = GetEventInt(event, "owner");
    int ammoUsed = GetEventInt(event, "ammo_used");
    // Make sure the client index is valid and the client is connected
    if(client > 0 && client <= MaxClients && IsClientInGame(client)) {
        hasUsedGluonGun[client] = true;
        playerAmmo[client] = Clamp(playerAmmo[client] - ammoUsed,0,MAX_AMMO);
    }
}

public bool OnClientConnect(int client)
{
    // Setzen Sie den Status auf 'false' für den verbindenden Spieler
    hasUsedGluonGun[client] = true;
    playerAmmo[client] = START_AMMO;
    return true;

}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3])
{
//    CheckForGluonGunUse(client);
    decl Float:clientpos[3];
    GetClientAbsOrigin(client, clientpos);

    int ent = -1;
    float origin[3];

    do
    {
        ent = FindEntityByClassname(ent, "prop_hev_charger");
        if (ent == -1) break;  // Wenn keine weitere Entität gefunden wurde, brechen Sie ab

        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
        
        if (GetVectorDistance(clientpos, origin) < 100)
        {
     //       PrintToServer("am near HEV Charger");

            new armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
     //       PrintToServer("Armor: %i", armor);

            if (armor < 100)
            {
                CreateTimer(1.0, IncreaseArmor, client, TIMER_REPEAT);
            }
        }
    } while (ent != -1);

    // Reset ent for the next search
    ent = -1;

    // Überprüfen auf prop_radiation_charger
    do
    {
        ent = FindEntityByClassname(ent, "prop_radiation_charger");
        if (ent == -1) break;  // Wenn keine weitere Entität gefunden wurde, brechen Sie ab
        GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
        if (GetVectorDistance(clientpos, origin) < 183)
        {

            new armor = GetEntProp(client, Prop_Send, "m_ArmorValue");
            if (armor < 100)
            {
                CreateTimer(1.0, IncreaseArmor, client, TIMER_REPEAT);
            }
            char weaponClass[64];
            GetClientWeapon(client, weaponClass, sizeof(weaponClass));
            if(StrEqual(weaponClass, "weapon_gluon") && hasUsedGluonGun[client])
            {
                 
                 // Bis zu fünf Mal ausführen, um die Munition aufzuladen
                 int chargesNeeded = (MAX_AMMO - playerAmmo[client] + AMMO_PER_CHARGE - 1) / AMMO_PER_CHARGE; // Aufrunden auf die nächste ganze Zahl
//                 chargesNeeded = (chargesNeeded, 5); // Maximal 5 Ladungen erlauben

                 // Führen Sie den Befehl zum Aufladen für jede benötigte Ladung aus
                 for(int i = 0; i < chargesNeeded; i++)
                 {                 
                     // Befehl zum Hinzufügen von Energie-Munition für den Spieler
                     GivePlayerItem(client, "item_ammo_energy");
                     playerAmmo[client] = Clamp(playerAmmo[client] + AMMO_PER_CHARGE,0,MAX_AMMO);
                 }
                 hasUsedGluonGun[client] = false;
                 // Optional: Überprüfen, ob der Spieler tatsächlich Munition erhalten hat
                 // und entsprechende Benachrichtigung oder Aktion durchführen
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
//    PrintToServer("Armor erhöht auf: %i", armor);

    return Plugin_Continue;  // Expliziter Rückgabewert hinzugefügt
}

