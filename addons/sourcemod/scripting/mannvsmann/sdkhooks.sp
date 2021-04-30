/*
 * Copyright (C) 2021  Mikusch
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

void SDKHooks_HookClient(int client)
{
	SDKHook(client, SDKHook_PostThink, Client_PostThink);
	SDKHook(client, SDKHook_OnTakeDamageAlive, Client_OnTakeDamageAlive);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, Client_OnTakeDamageAlivePost);
}

void SDKHooks_OnEntityCreated(int entity, const char[] classname)
{
	if (strcmp(classname, "entity_revive_marker") == 0)
	{
		SDKHook(entity, SDKHook_SetTransmit, ReviveMarker_SetTransmit);
	}
	else if (strncmp(classname, "item_currencypack", 17) == 0)
	{
		SDKHook(entity, SDKHook_SpawnPost, CurrencyPack_SpawnPost);
		SDKHook(entity, SDKHook_Touch, CurrencyPack_Touch);
		SDKHook(entity, SDKHook_TouchPost, CurrencyPack_TouchPost);
	}
	else if (strcmp(classname, "obj_attachment_sapper") == 0)
	{
		SDKHook(entity, SDKHook_Spawn, Sapper_Spawn);
		SDKHook(entity, SDKHook_SpawnPost, Sapper_SpawnPost);
	}
	else if (strcmp(classname, "func_respawnroom") == 0)
	{
		SDKHook(entity, SDKHook_Touch, RespawnRoom_Touch);
	}
}

public void Client_PostThink(int client)
{
	TFTeam team = TF2_GetClientTeam(client);
	if (team > TFTeam_Spectator)
	{
		SetHudTextParams(0.85, 0.1, 0.1, 122, 196, 55, 255, _, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, g_HudSync, "$%d ($%d)", MvMPlayer(client).Currency, MvMTeam(team).WorldCredits);
	}
}

public Action Client_OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Required to make blast resistance work
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
	
	char classname[32];
	if (weapon != -1 && GetEntityClassname(weapon, classname, sizeof(classname)))
	{
		//Change the damage of the Gas Passer "Explode On Ignite" upgrade
		if (strcmp(classname, "tf_weapon_jar_gas") == 0 && damagetype & DMG_SLASH)
		{
			damagetype |= DMG_BLAST; //Makes Blast Resistance useful
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

public Action Client_OnTakeDamageAlivePost(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, 
	float damageForce[3], float damagePosition[3], int damagecustom)
{
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
}

public Action ReviveMarker_SetTransmit(int marker, int client)
{
	//Only transmit revive markers to our own team and spectators
	if (TF2_GetClientTeam(client) != TFTeam_Spectator && TF2_GetTeam(marker) != TF2_GetClientTeam(client))
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public void CurrencyPack_SpawnPost(int currencypack)
{
	//Add the currency value to the world money
	if (!GetEntProp(currencypack, Prop_Send, "m_bDistributed"))
	{
		TFTeam team = TF2_GetTeam(currencypack);
		MvMTeam(team).WorldCredits += GetEntData(currencypack, g_OffsetCurrencyPackAmount);
	}
	
	SetEdictFlags(currencypack, (GetEdictFlags(currencypack) & ~FL_EDICT_ALWAYS));
	SDKHook(currencypack, SDKHook_SetTransmit, CurrencyPack_SetTransmit);
}

public Action CurrencyPack_SetTransmit(int currencypack, int client)
{
	//Only transmit currency packs to our own team and spectators
	if (TF2_GetClientTeam(client) != TFTeam_Spectator && TF2_GetTeam(currencypack) != TF2_GetClientTeam(client))
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public Action CurrencyPack_Touch(int currencypack, int touchPlayer)
{
	//Enable Mann vs. Machine for CCurrencyPack::MyTouch so the currency is distributed
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
}

public Action CurrencyPack_TouchPost(int currencypack, int touchPlayer)
{
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
}

public void Sapper_Spawn(int sapper)
{
	//Prevents repeat placement of sappers on players
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
}

public void Sapper_SpawnPost(int sapper)
{
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
}

public Action RespawnRoom_Touch(int respawnroom, int other)
{
	//Players get uber while they leave their spawn so they don't drop their cash where enemies can't pick it up
	if (!GetEntProp(respawnroom, Prop_Data, "m_bDisabled") && IsValidClient(other) && TF2_GetTeam(respawnroom) == TF2_GetClientTeam(other))
	{
		TF2_AddCondition(other, TFCond_Ubercharged, 0.5);
		TF2_AddCondition(other, TFCond_UberchargedHidden, 0.5);
		TF2_AddCondition(other, TFCond_UberchargeFading, 0.5);
	}
}
