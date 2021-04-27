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

static Handle g_SDKCallResetMap;
static Handle g_SDKCallDropCurrencyPack;
static Handle g_SDKCallReviveMarkerCreate;
static Handle g_SDKCallRemoveImmediate;
static Handle g_SDKCallGetBaseEntity;
static Handle g_SDKCallShouldSwitchTeams;
static Handle g_SDKCallGetNextRespawnWave;

void SDKCalls_Initialize(GameData gamedata)
{
	g_SDKCallResetMap = PrepSDKCall_ResetMap(gamedata);
	g_SDKCallDropCurrencyPack = PrepSDKCall_DropCurrencyPack(gamedata);
	g_SDKCallReviveMarkerCreate = PrepSDKCall_ReviveMarkerCreate(gamedata);
	g_SDKCallRemoveImmediate = PrepSDKCall_RemoveImmediate(gamedata);
	g_SDKCallGetBaseEntity = PrepSDKCall_GetBaseEntity(gamedata);
	g_SDKCallShouldSwitchTeams = PrepSDKCall_ShouldSwitchTeams(gamedata);
	g_SDKCallGetNextRespawnWave = PrepSDKCall_GetNextRespawnWave(gamedata);
}

Handle PrepSDKCall_ResetMap(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CPopulationManager::ResetMap");
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CPopulationManager::ResetMap");
	
	return call;
}

Handle PrepSDKCall_DropCurrencyPack(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFPlayer::DropCurrencyPack");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_ByValue);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CTFPlayer::DropCurrencyPack");
	
	return call;
}

Handle PrepSDKCall_ReviveMarkerCreate(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFReviveMarker::Create");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CTFReviveMarker::Create");
	
	return call;
}

Handle PrepSDKCall_RemoveImmediate(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "UTIL_RemoveImmediate");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: UTIL_RemoveImmediate");
	
	return call;
}

Handle PrepSDKCall_GetBaseEntity(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseEntity::GetBaseEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CBaseEntity::GetBaseEntity");
	
	return call;
}

Handle PrepSDKCall_ShouldSwitchTeams(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CTFGameRules::ShouldSwitchTeams");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CTFGameRules::ShouldSwitchTeams");
	
	return call;
}

Handle PrepSDKCall_GetNextRespawnWave(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_GameRules);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CTFGameRules::GetNextRespawnWave");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_ByValue);
	
	Handle call = EndPrepSDKCall();
	if (!call)
		LogMessage("Failed to create SDK call: CTFGameRules::GetNextRespawnWave");
	
	return call;
}

void SDKCall_ResetMap(int populator)
{
	if (g_SDKCallResetMap)
		SDKCall(g_SDKCallResetMap, populator);
}

void SDKCall_DropCurrencyPack(int client, CurrencyRewards size = TF_CURRENCY_PACK_SMALL, int amount = 0, bool forceDistribute = false, int moneyMaker = -1)
{
	if (g_SDKCallDropCurrencyPack)
		SDKCall(g_SDKCallDropCurrencyPack, client, size, amount, forceDistribute, moneyMaker);
}

int SDKCall_ReviveMarkerCreate(int owner)
{
	if (g_SDKCallReviveMarkerCreate)
		return SDKCall(g_SDKCallReviveMarkerCreate, owner);
	
	return -1;
}

void SDKCall_RemoveImmediate(int entity)
{
	if (g_SDKCallRemoveImmediate)
		SDKCall(g_SDKCallRemoveImmediate, entity);
}

int SDKCall_GetBaseEntity(Address address)
{
	if (g_SDKCallGetBaseEntity)
		return SDKCall(g_SDKCallGetBaseEntity, address);
	
	return -1;
}

bool SDKCall_ShouldSwitchTeams()
{
	if (g_SDKCallShouldSwitchTeams)
		return SDKCall(g_SDKCallShouldSwitchTeams);
	
	return false;
}

float SDKCall_GetNextRespawnWave(int team, int player)
{
	if (g_SDKCallGetNextRespawnWave)
		return SDKCall(g_SDKCallGetNextRespawnWave, team, player);
	
	return 0.0;
}
