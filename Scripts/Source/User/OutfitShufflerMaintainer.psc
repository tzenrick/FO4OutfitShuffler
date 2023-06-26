Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
{Attempts to maintain outfits assigned by the OutfitShuffler Main Script.}
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
;Imported Properties from ESP

Float NPCVersionToSet = 9.0
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

Formlist Property OSFactionsToIgnore Auto
Formlist Property OSGoodOutfits Auto Const
Formlist Property OSRestrictedFurniture Auto

Formlist Property OSActorRaces Auto
Formlist Property OSAllItems Auto
Formlist Property OSWeaponsList Auto
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
GlobalVariable Property OSVersion auto

MiscObject Property OSDontChangeItem Auto Const
MiscObject Property OSAlwaysChangeItem Auto Const
MiscObject Property OSDontBodyGenItem Auto Const
MiscObject Property OSAlwaysBodyGenItem Auto Const
MiscObject Property OSDontScaleItem Auto Const
MiscObject Property OSAlwaysScaleItem Auto Const

Outfit Property OSEmptyOutfit Auto Const

Quest Property OutfitShufflerQuest Auto Const
Quest Property MQ101WarNeverChanges Auto Const mandatory

Spell Property OSContainersSpell Auto Const
Spell Property OSMaintenanceSpell Auto Const
;MCMVars
Bool OSModEnabled
Bool OSXXEnabled
Bool OSXYEnabled
Bool OSNoNudes
Bool OSRandomBodyGen
Bool OSBodyGenOneShot
Bool OSOutfitOneShot
Bool OSNPCUseScaling
Bool OSAllowDLC
Float OSNPCMinScale
Float OSNPCMaxScale
Float OSScanningDistance
Int OSContainerLootChance
Int OSDeadBodyLootChance
Int OSLootItemsMax
Int OSShortTimer
Int OSLongTimer
Int OSChanceWeapons
;Local variables
Actor NPC

int MultCounter
int RaceCounter
string OSLogFile = "OutfitShuffler"
String MasterINI = "OutfitShuffler.ini"
String INIpath = "OutfitShuffler\\" 
string OSDataFile = "OutfitShuffler\\OSNPCData.ini"
String DebugHead="[Maintainer]"
String DebugHeadShort="[OSm]"

;Formlist, arrays from outfitshuffler
FormList OSListForms
String[] OSListStrings


;Arrays
ObjectReference[] kActorArray

int tid=5309
bool localhold

Event OnInit()
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings
	Self.StartTimer(5.0,tID)
	localhold=false
EndEvent

Bool Function CheckToRemoveSpell()
	Bool ReturnVal=False
	If PlayerRef.GetDistance(NPC)<GetModSettingFloat("OutfitShuffler", "iScanningDistance:General") as Float
		return False
	endif
	if GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==0
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:OS Not Enabled", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if NPC == PlayerRef
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is PlayerRef", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if NPC.IsDead()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is Dead", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if NPC.IsChild()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is Child", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if PowerArmorCheck(NPC)
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is in Power Armor", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if NPC.IsDeleted()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is Deleted", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	if NPC.IsDisabled()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is Disabled", 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif
	If IsPluginInstalled("AAF.esm")
		if NPC.GetLeveledActorBase()==GetFormFromFile(0x72e2, "AAF.esm")
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:is AAF Doppelganger", 0, DebugHeadShort, DebugHead)
			ReturnVal=True
		endif
	endif
	If NPC.GetValue(OSNPCVersion)!=OSVersion.GetValue()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell:OS Version Mismatch: OSNPCVersion="+NPC.GetValue(OSNPCVersion)+" OSVersion="+OSVersion.GetValue(), 0, DebugHeadShort, DebugHead)
		ReturnVal=True
	endif

	If ReturnVal
		ResetNPC()
	endif
	return ReturnVal
endfunction

Event OnTimer(int TimerID)
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings

	UpdateVars()
	if NPC.GetValue(OSNPCVersion)!=0
		NPC.SetValue(OSNPCVersion, OSVersion.GetValue())
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+"OnInit() OSNPCVersion="+NPC.GetValue(OSNPCVersion)+" Using OSListForms="+OSListForms.GetSize()+" formlists.", 0, DebugHeadShort, DebugHead)
	endif
		
	

	If CheckToRemoveSpell()||IsInRestrictedFurniture()
		Return
	endif
	If TimerID==tID
		NPC.RemoveInventoryEventFilter(None)
		While localhold
			Wait(0.1)
		endwhile
		localhold=true
		Debug.OpenUserLog(OSLogFile)
		
		EquipInOrder()
		If NPC.GetValue(OSMaintWait)==999
			dlog("OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" OSMaintWait=999", 0, DebugHeadShort, DebugHead)
			BuildOutfitFromParts()
		elseif !LoadNPC()
			dlog("OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" has no OSNPCData", 0, DebugHeadShort, DebugHead)
			BuildOutfitFromParts()
		else
			dlog("OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" Loaded from OSNPCData", 0, DebugHeadShort, DebugHead)
			NPC.SetValue(OSMaintTime, GetCurrentGameTime())
			NPC.SetValue(OSMaintWait,0)
		endif

		If NPC.GetValue(OSMaintWait)==1 && (NPC.GetValue(OSMaintTime)+(OSLongTimer*OSShortTimer*0.00069))>GetCurrentGameTime()
			NPC.SetValue(OSMaintWait,0)
		else
			While !NPC.Is3DLoaded() || NPC.GetValue(OSMaintWait)>0 || OSSuspend.GetValueInt() == 1 || !CheckAAFSafe();|| NPC.GetFurnitureReference()!=None 
				Wait(1.0)
			endwhile
			dlog("OnTimer()"+NPC+NPC.GetLeveledActorBase().GetName()+" is being maintained", 0, DebugHeadShort, DebugHead)
			EveryDayImShufflin()
		endif

		NPC.AddInventoryEventFilter(None)
		NPC.SetValue(OSMaintTime, GetCurrentGameTime())
		NPC.SetValue(OSMaintWait,0)
		localhold=false
		NPC.StartTimer(5.0,tID)
	endif
endevent

Function RandomBodygen()
	UpdateVars()
	If OSBodyGenOneShot
		dlog("RandomBodygen()"+NPC+NPC.GetLeveledActorBase().GetName()+" OSBodyGenOneShot=True:Add OSDontBodyGenItem", 0, DebugHeadShort, DebugHead)
		NPC.AddItem(OSDontBodyGenItem,1)
	endif
	BodyGen.RegenerateMorphs(NPC, true)
endFunction

Function RandomBodyScale()
	UpdateVars()
	If OSBodyGenOneShot
		dlog("RandomBodyScale()"+NPC+NPC.GetLeveledActorBase().GetName()+" OSBodyGenOneShot=True:Add OSDontScaleItem", 0, DebugHeadShort, DebugHead)
		NPC.AddItem(OSDontScaleItem,1)
	endif
	Float NPCNewScale=1.0
	if OSNPCMinScale >= OSNPCMaxScale
		NPCNewScale=OSNPCMinScale
	else
		NPCNewScale = RandomFloat(OSNPCMinScale, OSNPCMaxScale)
	endif
	dlog("RandomBodyScale()"+NPC+NPC.GetLeveledActorBase().GetName()+" NewScale="+NPCNewScale, 0, DebugHeadShort, DebugHead)
	NPC.SetScale(NPCNewScale)
endfunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	if NPC
		NPC.SetValue(OSNPCVersion, NPCVersionToSet)
		NPC.StartTimer(5.0,tID)
		dlog("OnEffectStart()"+NPC+NPC.GetLeveledActorBase().GetName()+" ensuring maintenancetimer is running.", 0, DebugHeadShort, DebugHead)
	endif
endevent

Event OnEffectFinish(Actor NPCv, Actor Nobody)
	NPC.RemoveItem(OSAlwaysBodyGenItem, -1)
	NPC.RemoveItem(OSAlwaysChangeItem, -1)
	NPC.RemoveItem(OSAlwaysScaleItem, -1)
	NPC.AddItem(OSDontBodyGenItem,1)
	NPC.AddItem(OSDontChangeItem,1)
	NPC.AddItem(OSDontScaleItem,1)
	dlog("OnEffectFinish()"+NPCv+NPCv.GetLeveledActorBase().GetName()+" is going into suspended animation...", 0, DebugHeadShort, DebugHead)
endEvent

Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	if NPC.GetValue(OSMaintWait)>0 || OSSuspend.GetValueInt()>0 || NPC==None || IsInRestrictedFurniture() || akBaseObject!=None || akReference!=None || !CheckAAFSafe() && PowerArmorCheck(NPC)
		return
	endif
	NPC.RemoveInventoryEventFilter(None)
	NPC.SetValue(OSMaintWait,1)
	Form akItem = akBaseObject
	If (akItem as Armor)
		If akItem.getformid()<0x07000000 && !(GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
			if OSAllItems.HasForm(akItem as ObjectReference) || SafeForm().HasForm(akItem as ObjectReference) || IsDeviousDevice(akItem)
				NPC.equipitem(akItem)
				return
			else
				NPC.removeitem(akItem,-1)
				return
			endif
		endif
		If akItem.getformid()>0x06ffffff || (akItem.getformid()<0x07000000 && (GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)) || OSAllItems.HasForm(akItem as ObjectReference) || SafeForm().HasForm(akItem as ObjectReference)
			NPC.equipitem(akItem)
			return
		endif
	endif
	if SafeForm().HasForm(akItem as ObjectReference)
		NPC.EquipItem(akItem)
		return
	endif
	if IsDeviousDevice(akItem)
		NPC.EquipItem(akItem)
		return
	endif
	;SaveNPC()
	NPC.SetValue(OSMaintWait,0)
	NPC.AddInventoryEventFilter(None)
endEvent

Event OnDeath(Actor Killer)
	ResetNPC()
	NPC.RemoveSpell(OSMaintenanceSpell)
endEvent

Function BuildOutfitFromParts()
	NPC.SetValue(OSMaintWait,1)
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings	
	UpdateVars()

	dLog(NPC.GetLeveledActorBase().GetName()+" is being maintained",0,DebugHeadShort,DebugHead)
	
	If IsPluginInstalled("Commonwealth Captives.esp")
		If NPC.HasSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp"))
			dLog("Removing Commonwealth Captives Dirt",0,DebugHeadShort,DebugHead)
			NPC.RemoveSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp"))
			dLog("Removing Commonwealth Captives Dirt",0,DebugHeadShort,DebugHead)
			NPC.RemoveSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp"))
			dLog("Removing Commonwealth Captives Dirt",0,DebugHeadShort,DebugHead)
			NPC.RemoveSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp") as Spell)
		endif
	endif		

	RandomBodyGen()
	RandomBodyScale()
	dLog(NPC.GetLeveledActorBase().GetName()+" RandomBodyGen() and RandomBodyScale() complete",0,DebugHeadShort,DebugHead)

	If NPC.GetLeveledActorBase().GetOutfit()!=OSEmptyOutfit
		dLog(NPC.GetLeveledActorBase().GetName()+" Setting OSEmptyOutfit and removing Armor items",0,DebugHeadShort,DebugHead)
		NPC.SetOutfit(OSEmptyOutfit)
		Form[] InvItems = NPC.GetInventoryItems()
		Int i=0
		While i<InvItems.Length
			Form Item = InvItems[i] as Armor
			if Item!=None
				NPC.RemoveItem(Item, -1)
			endif
			i+=1
		endwhile
	else
		dLog(NPC.GetLeveledActorBase().GetName()+" already has OSEmptyOutfit",0,DebugHeadShort,DebugHead)
	endif

	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		NPCSex="XY"
		dLog(NPC.GetLeveledActorBase().GetName()+" is male",0,DebugHeadShort,DebugHead)
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		NPCSex="XX"
		dLog(NPC.GetLeveledActorBase().GetName()+" is female",0,DebugHeadShort,DebugHead)
	endif



;Assign Items and Equip
	Int FullBodyIndex=OSListStrings.Find(NPCSex+"FullBody")
	Form FullBodyForm=OSListForms.GetAt(FullBodyIndex)
	Int FullBodyChance=GetModSettingInt("OutfitShuffler", "iChance"+NPCSex+"FullBody:General")
	dLog(NPC.GetLeveledActorBase().GetName()+" FullBodyForm="+FullBodyForm+" FullBodyIndex="+FullBodyIndex+" Chance="+FullBodyChance,0,DebugHeadShort,DebugHead)
	Int FullBodyRandomChance=RandomInt(1,99)
	If FullBodyRandomChance< FullBodyChance
		if  (FullBodyForm as FormList).GetSize()>0
			Form RandomItem
			While RandomItem==None
				RandomItem = (FullBodyForm as FormList).GetAt(RandomInt(0,(FullBodyForm as FormList).GetSize()))
			endwhile
			if RandomItem!=None
				If RandomItem as Armor
					if !IsOverwritingExisting(NPC, RandomItem as Armor)
						NPC.EquipItem(RandomItem)
					;else
					;	dLog(NPC.GetLeveledActorBase().GetName()+" "+NPCSex+"FullBody is overwriting existing item: SlotMask="+RandomItem.GetSlotMask(),0,DebugHeadShort,DebugHead)
					endif
				;else
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+NPCSex+"FullBody is not an Armor",0,DebugHeadShort,DebugHead)
				endif
			;else
			;	dLog(NPC.GetLeveledActorBase().GetName()+" "+NPCSex+"FullBody=NONE",0,DebugHeadShort,DebugHead)
			endif
		;else
		;	dLog(NPC.GetLeveledActorBase().GetName()+" "+NPCSex+"FullBody is empty",0,DebugHeadShort,DebugHead)
		endif
	else
		dLog(NPC.GetLeveledActorBase().GetName()+" checking for "+NPCSex+"FullBody CHANCE "+FullBodyRandomChance+"!>"+FullBodyChance+" failed, assigning individual items from "+OSListforms.GetSize()+" lists",0,DebugHeadShort,DebugHead)
		int Counter=0
		While counter < OSListForms.GetSize()
			Form WorkForm=OSListForms.GetAt(Counter)
			String WorkString=OSListStrings[Counter]
			Int WorkChance=GetModSettingInt("OutfitShuffler", "iChance"+WorkString+":General")
			;dlog(NPC+NPC.GetLeveledActorBase().GetName()+" checking "+WorkString+" chances="+WorkChance,0,DebugHeadShort,DebugHead)
			int SpareInt=StringFind(WorkString, NPCSex+"FullBody") + StringFind(WorkString, "OSRestricted") + StringFind(WorkString, "Disabled") + StringFind(WorkString, "SafeItems")
			If SpareInt>0
				;If (StringFind(WorkString, "FullBody"))>0
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" NOT using "+NPCSex+"FullBody Item.",0,DebugHeadShort,DebugHead)
				;endif
				;If (StringFind(WorkString, "Restricted"))>0
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" NOT using Restricted Item.",0,DebugHeadShort,DebugHead)
				;endif
				;If (StringFind(WorkString, "Disabled"))>0
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" NOT using Disabled Item.",0,DebugHeadShort,DebugHead)
				;endif
				;If (StringFind(WorkString, "SafeItems"))>0
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" NOT using SafeItems Item.",0,DebugHeadShort,DebugHead)
				;endif
				SpareInt += 1
				SpareInt -= 1
			else
				If (StringFind(WorkString, NPCSex)>-1)
					If (WorkForm as FormList).GetSize()>0
						Int RandomChance=RandomInt(1,99)
						WorkChance=GetModSettingInt("OutfitShuffler", "iChance"+WorkString+":General")
						If RandomChance<WorkChance
							Form RandomItem = (WorkForm as FormList).GetAt(RandomInt(0,(WorkForm as FormList).GetSize()))
							dLog(NPC.GetLeveledActorBase().GetName()+" got item "+RandomItem+RandomItem.GetName(),0,DebugHeadShort,DebugHead)
							if RandomItem!=None && (RandomItem as Armor)
								if !IsOverwritingExisting(NPC, RandomItem as Armor)
									dLog(NPC.GetLeveledActorBase().GetName()+" assigning item "+RandomItem+RandomItem.GetName(),0,DebugHeadShort,DebugHead)
									NPC.EquipItem(RandomItem)
								;else
									;dLog(NPC.GetLeveledActorBase().GetName()+" "+RandomItem+RandomItem.GetName()+" is overwriting existing item: SlotMask="+RandomItem.GetSlotMask()+".",0,DebugHeadShort,DebugHead)
								endif
							;else
							;	dLog(NPC.GetLeveledActorBase().GetName()+" "+RandomItem+RandomItem.GetName()+" is NOT an Armor.",0,DebugHeadShort,DebugHead)
							endif
						;else
						;	dLog(NPC.GetLeveledActorBase().GetName()+" (iChance"+WorkString+":General) CHANCE "+RandomChance+"!>"+WorkChance+" failed.",0,DebugHeadShort,DebugHead)
						endif
					;else
					;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" is empty.",0,DebugHeadShort,DebugHead)
					endif
				;else
				;	dLog(NPC.GetLeveledActorBase().GetName()+" "+WorkString+" is NOT "+NPCSex+".",0,DebugHeadShort,DebugHead)
				endif
			endif
		counter += 1
		endwhile
	endif
;assign weapon
	int WeaponChance = GetModSettingInt("OutfitShuffler", "iChanceWeapons:General")
	int WeaponListSize=(OSListForms.GetAt(OSListStrings.Find("OSWeaponsList")) as FormList).GetSize()
	Int WeaponRandomChance=RandomInt(1,99)
	dLog(NPC.GetLeveledActorBase().GetName()+" trying to assign Weapon: WeaponChance="+WeaponChance+" WeaponListSize="+WeaponListSize+" Using RandomNumber="+WeaponRandomChance,0,DebugHeadShort,DebugHead)
	If WeaponListSize>0
		dLog(NPC.GetLeveledActorBase().GetName()+" has weapons to assign.",0,DebugHeadShort,DebugHead)
		If  WeaponChance > WeaponRandomChance
			dLog(NPC.GetLeveledActorBase().GetName()+" (iChanceWeapons:General) CHANCE "+WeaponRandomChance+"!>"+WeaponChance+" succeeded.",0,DebugHeadShort,DebugHead)
			Form RandomItem = None
			While (RandomItem as Weapon)== None
				RandomItem = OSWeaponsList.GetAt(RandomInt(0,OSWeaponsList.GetSize()))
				dlog(NPC.GetLeveledActorBase().GetName()+" Trying to get weapon "+RandomItem+RandomItem.GetName(),0,DebugHeadShort,DebugHead)
			endwhile
			dlog(NPC.GetLeveledActorBase().GetName()+" Equipping weapon "+RandomItem+RandomItem.GetName()+" and ammo "+(RandomItem as Weapon).GetAmmo().GetName()+"*1000\n",0,DebugHeadShort,DebugHead)
			NPC.EquipItem(RandomItem)
			NPC.RemoveItem((RandomItem as Weapon).GetAmmo(),-1)
			NPC.EquipItem((RandomItem as Weapon).GetAmmo(), 1000)
		else
			dLog(NPC.GetLeveledActorBase().GetName()+" (iChanceWeapons:General) CHANCE "+WeaponRandomChance+"<"+WeaponChance+" failed.",0,DebugHeadShort,DebugHead)
		endIf
	else
		dLog(NPC.GetLeveledActorBase().GetName()+" has no weapons to assign.",0,DebugHeadShort,DebugHead)
	endif
	
	int TempArmorCount = CountNPCArmor()
	dLog(NPC.GetLeveledActorBase().GetName()+" has "+TempArmorCount+" Armor items.",0,DebugHeadShort,DebugHead)
	if NPC.GetItemCount(OSDontChangeItem)>0 && TempArmorCount && OSNoNudes
		dLog(NPC.GetLeveledActorBase().GetName()+" has "+NPC.GetItemCount(OSDontChangeItem)+" "+OSDontChangeItem.GetName()+" and is nude while not allowed to be. Sending to ResetNPC().",0,DebugHeadShort,DebugHead)
		ResetNPC()
		return
	endif
	
	if OSOutfitOneShot && NPC.GetItemCount(OSDontChangeItem)<1
		dLog(NPC.GetLeveledActorBase().GetName()+" doesn't have "+OSDontChangeItem.GetName()+" and is getting it.",0,DebugHeadShort,DebugHead)
		NPC.AddItem(OSDontChangeItem,1)
	endif

	dlog("BuildOutfitFromParts()"+NPC+NPC.GetLeveledActorBase().GetName()+"-Saving NPC Data",0,DebugHeadShort,DebugHead)
	SaveNPC()	
	
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
endfunction

int Function CountNPCArmor()
	int ArmorItems = 0
	int index = 0
	int end = 43 const
	 
	while (index < end)
		Actor:WornItem wornItem = NPC.GetWornItem(index)
		If WornItem != None
			ArmorItems+=1
		endif
		index += 1
	EndWhile
	Return ArmorItems
endfunction

Function EveryDayImShufflin()
;	OutfitShuffler OS
;	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
;	FormList OSListForms=OS.OSListForms
;	String[] OSListStrings=OS.OSListStrings
	UpdateVars()
	dlog("EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" Starting", 0, DebugHeadShort, DebugHead)
	if IsInRestrictedFurniture()
		dlog("EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" IsInRestrictedFurniture()", 0, DebugHeadShort, DebugHead)
		return
	endif
	NPC.SetValue(OSMaintWait,1)
	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck(NPC) && CheckAAFSafe()
		dlog("EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance.", 0, DebugHeadShort, DebugHead)
		EquipInOrder()
		if NPC.GetItemCount(OSDontChangeItem)>0 && CountNPCArmor()<2 && OSNoNudes
			dlog("EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" OSDontChangeItem>0 && CountNPCArmor()<2 && OSNoNudes", 0, DebugHeadShort, DebugHead)
			ResetNPC()
			return
		endif

		if OSOutfitOneShot && NPC.GetItemCount(OSDontChangeItem)<1 && NPC.GetItemCount(OSAlwaysChangeItem)<1
			dlog("EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" OSOneShot adding OSDontChangeItem", 0, DebugHeadShort, DebugHead)
			NPC.AddItem(OSDontChangeItem,1)
		endif

	endif

	SaveNPC()
	NPC.SetValue(OSMaintTime, GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.AddInventoryEventFilter(None)
endfunction

Function EquipInOrder()
	String TempLog="\nEquipInOrder()=Start "+NPC+NPC.GetLeveledActorBase().GetName()+"\n"
	Form[] InvItems = NPC.GetInventoryItems()
	int i
	templog+="(OSAllItems||SafeForm()||IsDeviousDevice(akItem)\n"
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		If akItem!=None
			if OSAllItems.HasForm(akItem) || SafeForm().HasForm(akItem) || IsDeviousDevice(akItem)
				templog+="OSItem/Safe/DD Item "+akItem+akItem.GetName()+"\n"
			elseif akItem.getformid()<0x07000000 && !OSAllowDLC
				NPC.removeitem(akItem,-1)
				templog+="Removing Base/DLC "+akItem+akItem.GetName()+"\n"
			else
				templog+="NOT Base/DLC "+akItem+akItem.GetName()+"\n"
			endif
		endif
	i += 1
	EndWhile

	InvItems = NPC.GetInventoryItems()
	i=0
	templog+="akItem!=None && !(IsDeviousDevice(akItem)||SafeForm().HasForm(akItem))\n"
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		If akItem!=None && !(IsDeviousDevice(akItem)||SafeForm().HasForm(akItem))
			if NPC.IsEquipped(akItem)
				templog+="Already Wearing Regular Item "+akItem+akItem.GetName()+"\n"
			else;If !IsOverwritingExisting(NPC,akItem as Armor)
				NPC.equipitem(akItem)
				templog+="Add Regular Item "+akItem+akItem.GetName()+"\n"
			endif
		endif
	i += 1
	endwhile

	InvItems = NPC.GetInventoryItems()
	i=0
	templog+="akItem!=None && (SafeForm().HasForm(akItem))\n"
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if akItem!=None && (SafeForm().HasForm(akItem))
			if NPC.IsEquipped(akItem)
				templog+="Already Wearing Safe Item "+akItem+akItem.GetName()+"\n"
			else
				NPC.equipitem(akItem)
				templog+="Add SafeItem "+akItem+akItem.GetName()+"\n"
			endif
		endif
	i += 1
	endwhile

	InvItems = NPC.GetInventoryItems()
	i=0
	templog+="akItem!=None && IsDeviousDevice(akItem)\n"
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if akItem!=None
			if IsDeviousDevice(akItem)
				if !NPC.IsEquipped(akItem)
					NPC.equipitem(akItem)
					templog+="Add Devious Item "+akItem+akItem.GetName()+"\n"
				else
					templog+="Already Wearing Devious Item "+akItem+akItem.GetName()+"\n"
				endif
			endif
		endif
		i += 1
	endwhile

	InvItems = NPC.GetInventoryItems()
	i=0
	templog+="Making sure a weapon is equipped.\n"
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Weapon
		if akItem as Weapon
			if !NPC.IsEquipped(akItem)&&OSWeaponsList.HasForm(akItem)
				NPC.equipitem(akItem)
				if NPC.GetItemCount((akItem as Weapon).GetAmmo())>0
					NPC.RemoveItem((akItem as Weapon).GetAmmo() as Form, -1)
				endif
				NPC.AddItem((akItem as weapon).GetAmmo() as Form,1000)
				templog+="Add Weapon "+akItem+akItem.GetName()+" and "+(akItem as Weapon).GetAmmo().GetName()+"*1000\n"
			endif
		endif
		i += 1
	endwhile
	TempLog+="EquipInOrder()=End "+NPC+NPC.GetLeveledActorBase().GetName()+"\n"
	dlog(TempLog,0,DebugHeadShort,DebugHead)
endfunction

bool Function IsInRestrictedFurniture()
	If NPC.GetFurnitureReference()!=None
		if OSRestrictedFurniture.HasForm(NPC.GetFurnitureReference().GetBaseObject())
			return true
		endif
	endif
	return false
endfunction

bool Function IsOverwritingExisting(Actor NPCv, Armor testitem)
	if testitem.getSlotMask()==0x8
		;dlog("IsOverwritingExisting()"+NPC+NPC.GetLeveledActorBase().GetName()+"Skipping "+testitem+testitem.GetName()+"\n",0,DebugHeadShort,DebugHead)
		return false
	endif

	Form[] InvItems = NPCv.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		if testitem.getSlotMask()!=0x8
			If (testitem as armor) && LogicalAnd(akitem.GetSlotMask(), testitem.GetSlotMask())
				dlog("IsOverwritingExisting()"+NPC+NPC.GetLeveledActorBase().GetName()+testitem+" Overwrites existing item "+akItem+akItem.GetName()+"\n",0,DebugHeadShort,DebugHead)
				return true
			endif
		endif
	i += 1
	EndWhile
	;dlog("IsOverwritingExisting()"+NPC+NPC.GetLeveledActorBase().GetName()+testitem+" Does not overwrite existing item\n",0,DebugHeadShort,DebugHead)
	return false
endfunction

Bool Function CheckAAFSafe()
	If IsPluginInstalled("AAF.esm")
		if !NPC.HasKeyword(GetFormFromFile(0x00915a, "AAF.esm") as Keyword)
			Return True
		endif
	endif
	Return False
endfunction

FormList Function SafeForm()
	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		Return GetFormFromFile(0x80b, "OutfitShuffler.esl") as FormList
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		Return GetFormFromFile(0x82d, "OutfitShuffler.esl") as FormList
	endif
endfunction

Function SaveNPC()
	String LogTemp="SaveNPC()=Start "+NPC+NPC.GetLeveledActorBase().GetName()+"\n"
	int i=0
	Var[] NPCKey = New Var[0]
	Var[] NPCValue = New Var[0]
	i=0
	NPCKey.Add("Name")
	NPCValue.Add(NPC.GetLeveledActorBase().GetName())
	LogTemp+="Name="+NPC.GetLeveledActorBase().GetName()+"\n"
	i += 1
	Form[] InvItems = NPC.GetInventoryItems()
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		if akItem==Game.GetFormFromFile(akitem.GetFormID(), "OutfitShuffler.esl")
			NPCKey.Add(IntToHexString(akItem.GetFormID()))
			NPCValue.Add("OutfitShuffler.esl")
			LogTemp+="Saving OutfitShuffler.esl="+akItem+akItem.GetName()+"\n"
		endif
		If ((akItem as Armor)||(akItem as Weapon)) && !akitem.GetName()=="" && !OSSkins.HasForm(akItem)
			NPCKey.Add(IntToHexString(OriginalPluginID(akItem)))
			NPCValue.Add(OriginalPluginName(akItem))
			LogTemp+="Saving "+OriginalPluginName(akItem)+"="+akItem+akItem.GetName()+"\n"
		endif
		i += 1
	EndWhile
	dlog(LogTemp,0,DebugHeadShort,DebugHead)	
	bool retval=ResetCustomConfigOptions(OSDataFile, IntToHexString(NPC.GetFormID()), NPCKey as String[], NPCValue as String[])
endfunction

bool Function LoadNPC()
;diag
	String LogTemp="\nLoadNPC()=Start "+NPC+NPC.GetLeveledActorBase().GetName()+"\n"
	bool LoadNPCReturn=False
	NPC.SetValue(OSMaintWait,1)
	Var[] TempVal = New Var[0]
	Var[] NPCKey = New Var[0]
	Var[] NPCValue = New Var[0]
	TempVal = GetCustomConfigOptions(OSDataFile, IntToHexString(NPC.GetFormID()))
	if TempVal!=None || TempVal.Length>0
		NPCKey = VarToVarArray(TempVal[0])
		NPCValue = VarToVarArray(TempVal[1])
	endif
	int LogLevel
	If NPCKey.Length>0
	;	UnequipItems(NPC)
;Set outfit, weapon, and Misc items.
		Int i=0
		If NPC.GetLeveledActorBase().GetOutfit()!=OSEmptyOutfit
			NPC.SetOutfit(OSEmptyOutfit)
		endif
		int icount
		While i<NPCKey.Length && i>-1
			If NPCKey[i] as String=="Name" && NPC.GetLeveledActorBase().GetName()!=(NPCValue[i] as String)
				LogTemp+=NPC+NPC.GetLeveledActorBase().GetName()+" IS NOT "+NPCValue[i]+". Attempting reassignment.\n"
				i=-2
			elseif NPCKey[i] as String=="Name" && NPC.GetLeveledActorBase().GetName()==(NPCValue[i] as String)
				LogTemp+=NPC+NPC.GetLeveledActorBase().GetName()+" Matches "+NPCValue[i]+"\n"
			endif
			Form TempForm=GetFormFromFile(HexStringToInt(NPCKey[i]),NPCValue[i] as String)
			if (TempForm as Armor)
				NPC.EquipItem(TempForm)
				icount+=1
				LogTemp+="Equipping Armor>"+TempForm+TempForm.GetName()+"\n"
			endif
			if (TempForm as Weapon)
				NPC.equipitem(TempForm)
				LogTemp+="Equipping Weapon>"+TempForm+TempForm.GetName()+"\n"
				icount+=1
				if NPC.GetItemCount((TempForm as Weapon).GetAmmo())>0
					NPC.RemoveItem((TempForm as Weapon).GetAmmo() as Form, -1)
				endif
				NPC.AddItem((TempForm as Weapon).GetAmmo() as Form,1000)
			endif
			i+=1
		endwhile
		if i>1
			LogTemp+="Loaded "+icount+"/"+NPCKey.Length+" items from OSNPCData.ini\n"
			LoadNPCReturn=True
		endif
		if i<0
			LogTemp+="Nothing To Load.\n"
			LoadNPCReturn=False
		endif
	endif
	LogTemp+="\nLoadNPC()=End "+NPC+NPC.GetLeveledActorBase().GetName()
	dlog(LogTemp,0,DebugHeadShort,DebugHead)
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
	return LoadNPCReturn
endfunction

function ResetNPC()
	NPC.SetValue(OSMaintWait,1)
	If NPC.GetItemCount(OSDontChangeItem)>0
		NPC.RemoveItem(OSDontChangeItem,-1)
	endif
	If NPC.GetItemCount(OSAlwaysChangeItem)>0
		NPC.RemoveItem(OSAlwaysChangeItem,-1)
	endif
	If NPC.GetItemCount(OSDontBodyGenItem)>0
		NPC.RemoveItem(OSDontBodyGenItem,-1)
	endif
	If NPC.GetItemCount(OSAlwaysBodyGenItem)>0
		NPC.RemoveItem(OSAlwaysBodyGenItem,-1)
	endif
	If NPC.GetItemCount(OSDontScaleItem)>0
		NPC.RemoveItem(OSDontScaleItem,-1)
	endif
	If NPC.GetItemCount(OSAlwaysScaleItem)>0
		NPC.RemoveItem(OSAlwaysScaleItem,-1)
	endif
	DD:DD_Library DDLib
	Form[] InvItems = NPC.GetInventoryItems()
	int i
	if !NPC.IsDead()
		While (i < InvItems.Length)
			Form akItem = InvItems[i] as Armor
			if akItem!=None
				if IsDeviousDevice(akItem)
					DDLib.RemoveDevice(NPC, akItem as Armor, none, true, false)
				else
					NPC.RemoveItem(akItem, -1)
				endif
			endif
			i += 1
		endwhile
	endif
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,999)
	ResetCustomConfigOptions(OSDataFile,IntToHexString(NPC.GetFormID()),None, None)
endfunction

FormList Function SafeItems()
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		Return XYSafeItems
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		Return XXSafeItems
	endif
endfunction

Function UpdateVars()
	OSModEnabled=GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	OSOutfitOneShot=GetModSettingBool("OutfitShuffler", "bOutfitOneShot:General") as Bool
	OSNoNudes=GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool
	OSRandomBodyGen=GetModSettingBool("OutfitShuffler", "bRandomBodyGen:General") as Bool
	OSBodyGenOneShot=GetModSettingBool("OutfitShuffler", "bBodyGenOneShot:General") as Bool
	OSNPCUseScaling=GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool
	OSXXEnabled=GetModSettingBool("OutfitShuffler", "bEnableXX:General") as Bool
	OSXYEnabled=GetModSettingBool("OutfitShuffler", "bEnableXY:General") as Bool
	OSContainerLootChance=GetModSettingInt("OutfitShuffler", "iContainerLootChance:General") as Int
	OSDeadBodyLootChance=GetModSettingInt("OutfitShuffler", "iDeadBodyLootChance:General") as Int
	OSLootItemsMax=GetModSettingInt("OutfitShuffler", "iLootItemsMax:General") as Int
	OSNPCMinScale=GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float
	OSNPCMaxScale=GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float

	OSScanningDistance=GetModSettingInt("OutfitShuffler", "iScanningDistance:General") as Float
	OSShortTimer=GetModSettingInt("OutfitShuffler", "iShortTimer:General") as Int
	OSLongTimer=GetModSettingInt("OutfitShuffler", "iLongTimer:General") as Int
	OSChanceWeapons=GetModSettingInt("OutfitShuffler", "iChanceWeapons:General") as Int

	OSAllowDLC=GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool
EndFunction