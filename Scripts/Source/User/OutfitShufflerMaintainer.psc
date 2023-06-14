Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
{Attempts to maintain outfits assigned by the OutfitShuffler Main Script.}
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
;Imported Properties from ESP

Float NPCVersionToSet = 8.5
Import OutfitShuffler
Import LL_FourPlay
Import Game
Import Utility
Import MCM
Import Math

Actor Property PlayerRef Auto Const

ActorValue Property OSMaintTime Auto
ActorValue Property OSBodyDone Auto
ActorValue Property OSMaintWait Auto
ActorValue Property OSNPCVersion Auto

Formlist Property FactionsToIgnore Auto
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const

Formlist Property OSActorRaces Auto
Formlist Property OSAllItems Auto
Formlist Property WeaponsList Auto
FormList Property XXSafeItems Auto
FormList Property XYSafeItems Auto
Formlist Property OSSkins auto

Formlist Property XXAccessory Auto
Formlist Property XXArmAddon Auto
Formlist Property XXBack Auto
Formlist Property XXBackpack Auto
Formlist Property XXBeard Auto
Formlist Property XXBelt Auto
Formlist Property XXBottom Auto
Formlist Property XXEarrings Auto
Formlist Property XXFront Auto
Formlist Property XXFullBody Auto
Formlist Property XXGlasses Auto
Formlist Property XXHair Auto
Formlist Property XXJacket Auto
Formlist Property XXLeftArmArmor Auto
Formlist Property XXLeftLegArmor Auto
Formlist Property XXLegs Auto
Formlist Property XXLongHair Auto
Formlist Property XXMouth Auto
Formlist Property XXNeck Auto
Formlist Property XXRightArmArmor Auto
Formlist Property XXRightLegArmor Auto
Formlist Property XXRing Auto
Formlist Property XXShoes Auto
Formlist Property XXShoulder Auto
Formlist Property XXTop Auto
Formlist Property XXTorsoArmor Auto

Formlist Property XYAccessory Auto
Formlist Property XYArmAddon Auto
Formlist Property XYBack Auto
Formlist Property XYBackpack Auto
Formlist Property XYBeard Auto
Formlist Property XYBelt Auto
Formlist Property XYBottom Auto
Formlist Property XYEarrings Auto
Formlist Property XYFront Auto
Formlist Property XYFullBody Auto
Formlist Property XYGlasses Auto
Formlist Property XYHair Auto
Formlist Property XYJacket Auto
Formlist Property XYLeftArmArmor Auto
Formlist Property XYLeftLegArmor Auto
Formlist Property XYLegs Auto
Formlist Property XYLongHair Auto
Formlist Property XYMouth Auto
Formlist Property XYNeck Auto
Formlist Property XYRightArmArmor Auto
Formlist Property XYRightLegArmor Auto
Formlist Property XYRing Auto
Formlist Property XYShoes Auto
Formlist Property XYShoulder Auto
Formlist Property XYTop Auto
Formlist Property XYTorsoArmor Auto

GlobalVariable Property OSSuspend Auto
GlobalVariable Property OSUseAAF Auto
GlobalVariable Property OSUseDD Auto
GlobalVariable Property OSVersion auto

MiscObject Property OSDontChangeItem Auto Const
MiscObject Property OSAlwaysChangeItem Auto Const
MiscObject Property OSDontBodyGenItem Auto Const
MiscObject Property OSAlwaysBodyGenItem Auto Const
MiscObject Property OSDontScaleItem Auto Const
MiscObject Property OSAlwaysScaleItem Auto Const

Outfit Property EmptyOutfit Auto Const

Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory

Spell Property ContainersSpell Auto Const
Spell Property Maintainer Auto Const

;Local variables
Actor NPC

int MultCounter
int RaceCounter
string OSLogName = "OutfitShuffler"
String MasterINI = "OutfitShuffler.ini"
String INIpath = "OutfitShuffler\\" 
string OSData = "OutfitShuffler\\OSNPCData.ini"
String DebugHead="[Maintainer]"
String DebugHeadShort="[OSm]"

;Imported Variables
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
Keyword DDRendered
Keyword DDInventory
Spell EBCC_DirtTier01
Spell EBCC_DirtTier02
Spell EBCC_DirtTier03

;Arrays
ObjectReference[] kActorArray

int tid=5309
bool localhold

Event OnInit()
	Self.StartTimer(1.0,tID)
	localhold=false
EndEvent

Event OnTimer(int TimerID)
	If NPC.GetValue(OSNPCVersion)!=OSVersion.GetValue()
		if NPC.HasSpell(Maintainer)
			NPC.RemoveSpell(Maintainer)
		endif
	endif
	If TimerID==tID
		While LocalHold
			wait(1.0)
		endwhile
		if ((GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==0) || NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled()) && PlayerRef.GetDistance(NPC)<(GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float) || NPC.GetLeveledActorBase()==AAF_Doppelganger
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell")
			NPC.RemoveSpell(Maintainer)
			return
		endif
		localhold=true
		NPC.RemoveInventoryEventFilter(None)

		Debug.OpenUserLog(OSLogName)

		if NPC.GetValue(OSMaintWait)==3
;			ScriptObject OSMain = GetFormFromFile(0x800,"OutfitShuffler.esl").CastAs("OutfitShufflerQuest")
			Var[] Temp=New Var[1]
			Temp[0]=NPC as Actor
;			OSMain.CallGlobalFunction("BuildOutfitFromParts",Temp)
			CallGlobalFunction("OutfitShuffler", "RandomBodyGen", Temp)
			CallGlobalFunction("OutfitShuffler", "BuildOutfitFromParts", Temp)
		endif

		Bool LoadNotShuffle
		Var[] TempVal = New Var[0]
		TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()))
		dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" Checking for NPC Data.")
		if TempVal!=None
			Var[] TempVal2=New Var[0]
			TempVal2=VarToVarArray(TempVal[0])
			if Tempval2.Length>1
;				dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" Loading NPC Data")
				LoadNotShuffle=True
				LoadNPC(NPC)
				NPC.AddInventoryEventFilter(None)
				NPC.SetValue(OSMaintTime, GetCurrentGameTime())
				NPC.SetValue(OSMaintWait,0)
				localhold=false
				NPC.StartTimer(5.0,tID)
				Return
			endif
		endif
;8.2:  moved furniture check to after LoadNPC() so that NPCs in furniture will be maintained, but not changed.
		if IsInRestrictedFurniture(NPC)
			return
		endif

		If NPC.GetValue(OSMaintWait)==1 && (NPC.GetValue(OSMaintTime)+(GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)*(GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float)*0.00069)>GetCurrentGameTime()
			NPC.SetValue(OSMaintWait,0)
		else
			While !NPC.Is3DLoaded() || NPC.GetValue(OSMaintWait)>0 || OSSuspend.GetValueInt() == 1 || !CheckAAFSafe(NPC);|| NPC.GetFurnitureReference()!=None 
				Wait(1.0)
			endwhile
			dlog(1,"OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" is being maintained")
			EveryDayImShufflin()
		endif
		NPC.AddInventoryEventFilter(None)
		NPC.SetValue(OSMaintTime, GetCurrentGameTime())
		NPC.SetValue(OSMaintWait,0)
		localhold=false
		NPC.StartTimer(5.0,tID)
	endif
endevent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	if NPC
		NPC.SetValue(OSNPCVersion, NPCVersionToSet)
		NPC.StartTimer(5.0,tID)
	endif
endevent

Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	if IsInRestrictedFurniture(NPC)
		return
			endif
	if (akBaseObject!=None||akReference!=None)&&NPC!=None
		if NPC.GetValue(OSMaintWait)==0 && CheckAAFSafe(NPC) && !PowerArmorCheck(NPC) && OSSuspend.GetValueInt()==0
			NPC.SetValue(OSMaintWait,1)
			CleanCaptive(NPC)
			NPC.RemoveInventoryEventFilter(None)
			Form akItem = akBaseObject
			If (akItem as Armor)
				If akItem.getformid()<0x07000000 && !(GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
					if OSAllItems.HasForm(akItem as ObjectReference) || SafeForm(NPC).HasForm(akItem as ObjectReference) || IsDeviousDevice(akItem)
						NPC.equipitem(akItem)
						if GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 3
							dlog(1,"OnItemUnequipped()-RecognizedItems "+NPC+NPC.GetLeveledActorBase().GetName()+" is equipping "+akItem+akItem.GetName())
						endif
						return
					else
						NPC.removeitem(akItem,-1)
						return
					endif
				endif
				If akItem.getformid()>0x06ffffff || (akItem.getformid()<0x07000000 && (GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)) || OSAllItems.HasForm(akItem as ObjectReference) || SafeForm(NPC).HasForm(akItem as ObjectReference)
					NPC.equipitem(akItem)
					if GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 3
						dlog(1,"OnItemUnequipped()-RegularItems "+NPC+NPC.GetLeveledActorBase().GetName()+" is equipping "+akItem+akItem.GetName())
					endif
					return
				endif
			endif
			if SafeForm(NPC).HasForm(akItem as ObjectReference)
				NPC.EquipItem(akItem)
				if GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 3
					dlog(1,"OnItemUnequipped()-SafeItems "+NPC+NPC.GetLeveledActorBase().GetName()+" is equipping "+akItem+akItem.GetName())
				endif
				return
			endif
			if IsDeviousDevice(akItem)
				NPC.EquipItem(akItem)
				if GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 3
					dlog(1,"OnItemUnequipped()-DeviousItems "+NPC+NPC.GetLeveledActorBase().GetName()+" is equipping "+akItem+akItem.GetName())
				endif
				return
			endif
			;SaveNPC(NPC)
			NPC.SetValue(OSMaintWait,0)
			NPC.AddInventoryEventFilter(None)
		endif
	endif
endEvent

Event OnDeath(Actor Killer)
	ResetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()), None, None)
	NPC.RemoveSpell(Maintainer)
endEvent

Function EveryDayImShufflin()
	if IsInRestrictedFurniture(NPC)
		return
	endif
	NPC.SetValue(OSMaintWait,1)
	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck(NPC) && CheckAAFSafe(NPC)
;		dlog(1,"EveryDayImShufflin() "+NPC+""+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance.")
		EquipInOrder(NPC)
		if NPC.GetItemCount(OSDontChangeItem)>0 && CountNPCArmor(NPC)<2 && (GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
			NPC.RemoveItem(OSDontChangeItem, -1)
			NPC.SetValue(OSMaintTime, 0)
			return
		endif

		if (GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) && NPC.GetItemCount(OSDontChangeItem)<1 && NPC.GetItemCount(OSAlwaysChangeItem)<1
			NPC.AddItem(OSDontChangeItem,1)
		endif

	endif

	;SaveNPC(NPC)
	NPC.SetValue(OSMaintTime, GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.AddInventoryEventFilter(None)
endfunction