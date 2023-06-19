#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo =
{
  name        = "Melee Pickup",
  author      = "BlackStar",
  description = "Allows picking up dropped danger zone weapons",
  version     = "1.0.0",
  url         = ""
};

public void OnPluginStart()
{
  for (int i = 1; i <= MaxClients; i++)
  {
    if (IsClientInGame(i))
    {
      AddHooksToClient(i);
    }
  }
}

public void OnClientPutInServer(int client)
{
  AddHooksToClient(client);
}

public void AddHooksToClient(int client)
{
  SDKHook(client, SDKHook_WeaponCanUse, Hook_WeaponCanUse);
}

public Action Hook_WeaponCanUse(int client, int weapon)
{
  char className[64];
  GetEntityClassname(weapon, className, sizeof(className));

  if (
      StrEqual(className, "weapon_melee") && !HasWeapon(client, "weapon_melee") || 
      StrEqual(className, "weapon_knife") && !HasWeapon(client, "weapon_knife")
    )
  {
    EquipPlayerWeapon(client, weapon);
    return Plugin_Changed;
  }

  return Plugin_Continue;
}

stock bool HasWeapon(int client, const char[] className)
{
  char currentClassName[64];
  int myWeaponsArraySize = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");

  for (int i = 0; i < myWeaponsArraySize; i++)
  {
    int entity = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);

    if (entity == -1)
      continue;

    GetEdictClassname(entity, currentClassName, sizeof(currentClassName));

    if (StrEqual(currentClassName, className))
      return true;
  }

  return false;
}

stock bool IsValidClient(int client, bool nobots = true)
{
  if (client <= 0 || client > MaxClients || !IsClientInGame(client) || (nobots && IsFakeClient(client)))
    return false;

  return true;
}