Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
{Attempts to maintain outfits assigned by the OutfitShuffler Main Script.}
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
;Imported Properties from ESP

Float NPCVersionToSet = 9.1
Import OutfitShuffler
Import LL_FourPlay
Import Game
Import Utility
Import MCM
Import Math

Actor Property PlayerRef Auto Const

ActorValue Property OSMaintTime Auto
ActorValue Property OSMaintWait Auto
ActorValue Property OSNPCVersion Auto

Formlist Property OSFactionsToIgnore Auto
Formlist Property OSGoodOutfits Auto Const
Formlist Property OSRestrictedFurniture Auto

Formlist Property OSActorRaces Auto
Formlist Property OSAllItems Auto
FormList Property OSSkins Auto
Formlist Property OSWeaponsList Auto
FormList Property XXSafeItems Auto
FormList Property XYSafeItems Auto

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

String[] Property OSNPCid Auto
String[] Property OSNPCdata Auto

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
String DebugHead="[Maintainer]"
String DebugHeadShort="[OSm]"

;Formlist, arrays from outfitshuffler
FormList OSListForms
String[] OSListStrings


;Arrays
ObjectReference[] kActorArray
int tid=5309
bool localhold

OutfitShuffler OS

Event OnInit()
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings
	Self.StartTimer(5.0,tID)
	localhold=false
EndEvent

Event OnTimer(int TimerID)
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings

	UpdateVars()
	
	If !NPC.Is3DLoaded() ||  OSSuspend.GetValueInt() == 1 || !CheckAAFSafe()
		Return
	EndIf
	Int CountLocal=CountNPCArmor()
	;dlog (NPC+NPC.GetLeveledActorBase().GetName()+" OnTimer()-ArmorItems="+CountLocal, 0, DebugHeadShort, DebugHead)
	If NPC.GetValue(OSMaintWait)==999||NPC.GetValue(OSMaintTime)==999||NPC.GetValue(OSNPCVersion)>OSVersion.GetValue()||CountLocal==0 || (NPC.GetValue(OSMaintWait)==1 && ((NPC.GetValue(OSMaintTime)+(OSLongTimer*OSShortTimer*0.00069))>GetCurrentGameTime())&&NPC.GetItemCount(OSDontChangeItem)==0)
		If NPC.GetValue(OSMaintWait)==999||NPC.GetValue(OSMaintTime)==999||NPC.GetValue(OSNPCVersion)>OSVersion.GetValue()
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is being changed soon.", 1, DebugHeadShort, DebugHead)
		endif
		;dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnTimer() ==> ResetNPC()", 0, DebugHeadShort, DebugHead)
		ResetNPC()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnTimer() ==> BuildOutfitFromParts() after ResetNPC()", 0, DebugHeadShort, DebugHead)
		NPC.SetValue(OSNPCVersion, OSVersion.GetValue())
		BuildOutfitFromParts()
		return
	else		
;		if NPC.GetValue(OSNPCVersion)!=0
;			NPC.SetValue(OSNPCVersion, OSVersion.GetValue())
;			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnTimer() OSNPCVersion="+NPC.GetValue(OSNPCVersion)+" Using OSListForms="+OSListForms.GetSize()+" formlists.", 0, DebugHeadShort, DebugHead)
;		endif
		
		If !CheckToRemoveSpell()||IsInRestrictedFurniture()
			NPC.RemoveInventoryEventFilter(None)
			While localhold
				Wait(0.1)
			endwhile
			localhold=true
			Int LoadItemsVal=LoadNPC()
			If LoadItemsVal==0
				BuildOutfitFromParts()
				return
			;Else
			;	dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnTimer()-Loaded "+LoadItemsVal+" items.", 0, DebugHeadShort, DebugHead)
			EndIf
			Debug.OpenUserLog(OSLogFile)
			NPC.AddInventoryEventFilter(None)
			NPC.SetValue(OSMaintTime, GetCurrentGameTime())
			NPC.SetValue(OSMaintWait,0)
			localhold=false
		endif
	endif		
	NPC.StartTimer(5.0,tID)
endevent

Function RandomBodygen()
	UpdateVars()
	If OSBodyGenOneShot
		If BuildLog>""
			BuildLog+="RandomBodygen()-OSBodyGenOneShot=True:Add OSDontBodyGenItem\n"
		else
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OSBodyGenOneShot=True:Add OSDontBodyGenItem", 0, DebugHeadShort, DebugHead)
		endif
		If NPC.GetItemCount(OSDontBodyGenItem)==0
			NPC.AddItem(OSDontBodyGenItem,1)
		endif
	endif
	BodyGen.RegenerateMorphs(NPC, true)
endFunction

Function RandomBodyScale()
	UpdateVars()
	If OSBodyGenOneShot
		If BuildLog>""
			BuildLog+="OSBodyGenOneShot=True:Add OSDontScaleItem\n"
		else
			dlog("RandomBodyScale()"+NPC+NPC.GetLeveledActorBase().GetName()+" OSBodyGenOneShot=True:Add OSDontScaleItem", 0, DebugHeadShort, DebugHead)
		endif
		if NPC.GetItemCount(OSDontScaleItem)==0
			NPC.AddItem(OSDontScaleItem,1)
		endif
	endif
	Float NPCNewScale=1.0
	if OSNPCMinScale >= OSNPCMaxScale
		NPCNewScale=OSNPCMinScale
	else
		NPCNewScale = RandomFloat(OSNPCMinScale, OSNPCMaxScale)
	endif
	If BuildLog>""
			BuildLog+="RandomBodyScale()-NewScale="+NPCNewScale+"\n"
		else
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" RandomBodyScale()-NewScale="+NPCNewScale, 0, DebugHeadShort, DebugHead)
		endif
	NPC.SetScale(NPCNewScale)
endfunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	OS = GetFormFromFile(0x800, "OutfitShuffler.esl") as OutfitShuffler
	OSNPCid=OS.OSNPCid
	OSNPCData=OS.OSNPCData
	String NPCUser="NPC"+IntToHexString(NPC.GetLeveledActorBase().GetFormID())+NPC.GetLeveledActorBase().GetName()
	;dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnEffectStart()-Checking NPC="+NPCuser,0,DebugHeadShort,DebugHead)
	NPC.SetValue(OSMaintWait,1)
	Int NPCIndex=OSNPCid.Find(NPCUser)
	if NPC
		Int CountLocal=CountNPCArmor()
		NPC.SetValue(OSNPCVersion, NPCVersionToSet)
		NPC.StartTimer(5.0,tID)
		If (CountLocal>0 && !(CountLocal>30)) || NPCIndex>-1
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnEffectStart() ==> LoadNPC()  ArmorItems="+CountLocal, 0, DebugHeadShort, DebugHead)
			LoadNPC()
		else
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnEffectStart() ==> ResetNPC()  ArmorItems="+CountLocal, 0, DebugHeadShort, DebugHead)
			BuildOutfitFromParts()
			return
		endif
		;dlog("OnEffectStart()"+NPC+NPC.GetLeveledActorBase().GetName()+" ensuring maintenancetimer is running.", 0, DebugHeadShort, DebugHead)
	endif
	StartTimer(5.0,tID)
endevent

Event OnEffectFinish(Actor NPCv, Actor Nobody)
;	dlog(NPC+NPC.GetLeveledActorBase().GetName()+" OnEffectFinish()-ArmorItems="+CountNPCArmor(), 0, DebugHeadShort, DebugHead)
	CheckToRemoveSpell()
;	OS = GetFormFromFile(0x800, "OutfitShuffler.esl") as OutfitShuffler
;	OSNPCid=OS.OSNPCid
;	OSNPCData=OS.OSNPCData
;	String NPCUser="NPC"+IntToHexString(NPC.GetLeveledActorBase().GetFormID())+NPC.GetLeveledActorBase().GetName()
;	NPC.SetValue(OSMaintWait,1)
;	Int NPCIndex=OSNPCid.Find(NPCUser)
;	If NPCIndex>-1
;		OSNPCid.Remove(NPCIndex)
;		OSNPCData.Remove(NPCIndex)
;	endif
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
	if NPC.GetItemCount(OSAlwaysBodyGenItem)>0
		NPC.RemoveItem(OSAlwaysBodyGenItem, -1)
	endif
	if NPC.GetItemCount(OSAlwaysChangeItem)>0
		NPC.RemoveItem(OSAlwaysChangeItem, -1)
	endif
	if NPC.GetItemCount(OSAlwaysScaleItem)>0
		NPC.RemoveItem(OSAlwaysScaleItem, -1)
	endif
	if NPC.GetItemCount(OSDontBodyGenItem)>0
		NPC.RemoveItem(OSDontBodyGenItem, -1)
	endif
	if NPC.GetItemCount(OSDontChangeItem)>0
		NPC.RemoveItem(OSDontChangeItem, -1)
	endif
	if NPC.GetItemCount(OSDontScaleItem)>0
		NPC.RemoveItem(OSDontScaleItem, -1)
	endif
	CheckToRemoveSpell()
	If NPC.HasSpell(OSMaintenanceSpell)
		NPC.RemoveSpell(OSMaintenanceSpell)
	endif
endEvent

String BuildLog
Function BuildOutfitFromParts()
	NPC.SetValue(OSMaintWait,1)
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	OSListForms=OS.OSListForms
	OSListStrings=OS.OSListStrings	
	UpdateVars()

	BuildLog=NPC.GetLeveledActorBase().GetName()+" is having an outfit built."+"\n"
	
	If IsPluginInstalled("Commonwealth Captives.esp")
		If NPC.HasSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp"))
			BuildLog+=NPC.GetLeveledActorBase().GetName()+" Removing Commonwealth Captives Dirt"+"\n"
			NPC.RemoveSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp"))
			BuildLog+=NPC.GetLeveledActorBase().GetName()+" Removing Commonwealth Captives Dirt"+"\n"
			NPC.RemoveSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp"))
			BuildLog+=NPC.GetLeveledActorBase().GetName()+" Removing Commonwealth Captives Dirt"+"\n"
			NPC.RemoveSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp") as Spell)
		endif
	endif		

	RandomBodyGen()
	RandomBodyScale()
	BuildLog+=NPC.GetLeveledActorBase().GetName()+" RandomBodyGen() and RandomBodyScale() complete"+"\n"

	If NPC.GetLeveledActorBase().GetOutfit()!=OSEmptyOutfit
		BuildLog+=NPC.GetLeveledActorBase().GetName()+" Setting OSEmptyOutfit and removing Armor items"+"\n"
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
		BuildLog+=NPC.GetLeveledActorBase().GetName()+" Already has OSEmptyOutfit"+"\n"
	endif

	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		NPCSex="XY"
		BuildLog+=NPC.GetLeveledActorBase().GetName()+" is male"+"\n"
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		NPCSex="XX"
		BuildLog+=NPC.GetLeveledActorBase().GetName()+" is female"+"\n"
	endif



;Assign Items and Equip
	Int FullBodyIndex=OSListStrings.Find(NPCSex+"FullBody")
	Form FullBodyForm=OSListForms.GetAt(FullBodyIndex)
	Int FullBodyChance=GetModSettingInt("OutfitShuffler", "iChance"+NPCSex+"FullBody:General")
	BuildLog+=NPC.GetLeveledActorBase().GetName()+" FullBodyForm="+FullBodyForm+" FullBodyIndex="+FullBodyIndex+" Chance="+FullBodyChance+" "
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
						NPC.EquipItem(RandomItem as Armor)
						BuildLog+=" "+RandomItem+RandomItem.GetName()
					endif
				endif
			endif
		endif
	else
		BuildLog+=NPC.GetLeveledActorBase().GetName()+" Checking for "+NPCSex+"FullBody CHANCE "+FullBodyRandomChance+">"+FullBodyChance+" FAILED, assigning individual items from "+OSListforms.GetSize()+" lists: "
		int Counter=0
		While counter < OSListForms.GetSize()
			Form WorkForm=OSListForms.GetAt(Counter)
			String WorkString=OSListStrings[Counter]
			Int WorkChance=GetModSettingInt("OutfitShuffler", "iChance"+WorkString+":General")
			int SpareInt=StringFind(WorkString, NPCSex+"FullBody") + StringFind(WorkString, "OSRestricted") + StringFind(WorkString, "Disabled") + StringFind(WorkString, "SafeItems")
			If SpareInt>0
				SpareInt += 1
				SpareInt -= 1
			else
				If (StringFind(WorkString, NPCSex)>-1)
					If (WorkForm as FormList).GetSize()>0
						Int RandomChance=RandomInt(1,99)
						WorkChance=GetModSettingInt("OutfitShuffler", "iChance"+WorkString+":General")
						If RandomChance<WorkChance
							Form RandomItem = (WorkForm as FormList).GetAt(RandomInt(0,(WorkForm as FormList).GetSize()))
							if RandomItem!=None && (RandomItem as Armor)
								if !IsOverwritingExisting(NPC, RandomItem as Armor)
									NPC.EquipItem(RandomItem as Armor)
									BuildLog+=" "+RandomItem+RandomItem.GetName()
								endif
							endif
						endif
					endif
				endif
			endif
		counter += 1
		endwhile
	endif
;assign weapon
	int WeaponChance = GetModSettingInt("OutfitShuffler", "iChanceWeapons:General")
	int WeaponListSize=(OSListForms.GetAt(OSListStrings.Find("OSWeaponsList")) as FormList).GetSize()
	Int WeaponRandomChance=RandomInt(1,99)
	BuildLog+=" Trying to assign Weapon: WeaponChance="+WeaponChance+" WeaponListSize="+WeaponListSize+" Using RandomNumber="+WeaponRandomChance
	If WeaponListSize>0
		If  WeaponChance > WeaponRandomChance
			BuildLog+=" (iChanceWeapons:General) CHANCE "+WeaponRandomChance+"!>"+WeaponChance+" succeeded."
			Form RandomItem = None
			While (RandomItem as Weapon)== None
				RandomItem = OSWeaponsList.GetAt(RandomInt(0,OSWeaponsList.GetSize()))
			endwhile
			BuildLog+=" Equipping weapon "+RandomItem+RandomItem.GetName()+" and ammo "+(RandomItem as Weapon).GetAmmo().GetName()+"*1000 "
			NPC.EquipItem(RandomItem)
			NPC.RemoveItem((RandomItem as Weapon).GetAmmo(),-1)
			NPC.EquipItem((RandomItem as Weapon).GetAmmo(), 1000)
		else
			BuildLog+=" (iChanceWeapons:General) CHANCE "+WeaponRandomChance+"<"+WeaponChance+" failed."
		endIf
	else
		BuildLog+=" WeaponsListSize==0"
	endif
	int TempArmorCount = CountNPCArmor()
	BuildLog+=" ArmorItems="+TempArmorCount+"\n"
	if NPC.GetItemCount(OSDontChangeItem)>0 && TempArmorCount && OSNoNudes
		BuildLog+="\n"+NPC.GetLeveledActorBase().GetName()+" has "+NPC.GetItemCount(OSDontChangeItem)+" "+OSDontChangeItem.GetName()+" and is nude while not allowed to be. Sending to ResetNPC()."+"\n"
		ResetNPC()
		return
	endif
	
	if OSOutfitOneShot && NPC.GetItemCount(OSDontChangeItem)<1
		BuildLog+=" NEEDS "+OSDontChangeItem.GetName()+" and is getting it."+"\n"
		NPC.AddItem(OSDontChangeItem,1)
	endif
	
	NPC.GetLeveledActorBase().GetName()+" is done having an outfit built."+"\n"
	dlog(BuildLog,0,DebugHeadShort,DebugHead)
	BuildLog=""
	SaveNPC()
	NPC.StartTimer(5.0,tID)
	NPC.AddInventoryEventFilter(None)
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
endfunction

int Function CountNPCArmor()
	int ArmorItems = 0
	int index = 0
	Form[] InvItems = NPC.GetInventoryItems()
	While (index < InvItems.Length)
		Form akItem = InvItems[index]
		if (akItem as Armor)
			ArmorItems += 1
		endif
		index += 1
	endwhile
	Return ArmorItems
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
		if (testitem.getSlotMask()!=0x8)||!OSSkins.HasForm(akitem)
			If (testitem as armor) && LogicalAnd(akitem.GetSlotMask(), testitem.GetSlotMask())
				If BuildLog>""
					BuildLog+=" IsOverwritingExisting()"+NPC+NPC.GetLeveledActorBase().GetName()+testitem+" Overwrites existing item "+akItem+akItem.GetName()
				else
					dlog("IsOverwritingExisting()"+NPC+NPC.GetLeveledActorBase().GetName()+testitem+" Overwrites existing item "+akItem+akItem.GetName()+"\n",0,DebugHeadShort,DebugHead)
				endif
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
	OS = GetFormFromFile(0x800, "OutfitShuffler.esl") as OutfitShuffler
	OSNPCid=OS.OSNPCid
	OSNPCData=OS.OSNPCData
	String NPCUser="NPC"+IntToHexString(NPC.GetLeveledActorBase().GetFormID())+NPC.GetLeveledActorBase().GetName()
	String LogTemp="SaveNPC()=Start ==>"+NPCuser+" "
	NPC.SetValue(OSMaintWait,1)
	Int NPCIndex=OSNPCid.Find(NPCUser)
	If NPCIndex>-1
		OSNPCid.Remove(NPCIndex)
		OSNPCData.Remove(NPCIndex)
		LogTemp+="Removing old data, "
	endif
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	string[] InvItemsString
	String BackupString=""
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		If ((akItem as Armor) || (akItem as Weapon) || OriginalPluginName(akItem)=="OutfitShuffler.esl") && !OSSkins.HasForm(akItem)
			InvItemsString.Add(IntToHexString(akItem.GetFormID()))
			BackupString+=IntToHexString(akItem.GetFormID())+","
		endIf
		i += 1
	EndWhile
	OSNPCid.Add(NPCUser)
	String TempVar=StringJoin(StringSplit(BackupString,","))
	OSNPCData.Add(TempVar)
	;dlog(TempVar+"<==>"+LogTemp+"<==",0,DebugHeadShort,DebugHead)	
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,0)
endfunction

int Function LoadNPC()
	OS = GetFormFromFile(0x800, "OutfitShuffler.esl") as OutfitShuffler
	OSNPCid=OS.OSNPCid
	OSNPCData=OS.OSNPCData
	String NPCUser="NPC"+IntToHexString(NPC.GetLeveledActorBase().GetFormID())+NPC.GetLeveledActorBase().GetName()
	String LogTemp="LoadNPC()=Start ==>"+NPCUser+" "
	Int NPCIndex=OSNPCid.Find(NPCUser)
	int LoadNPCReturn=0
	NPC.SetValue(OSMaintWait,1)
	If NPCIndex>-1
		String[] InvItemsString=StringSplit(OSNPCData[NPCIndex],",")
		int i=0
		While (i < InvItemsString.Length)
			Form akItem = GetForm(HexStringToInt(InvItemsString[i]))
			If akItem!=None
				If !NPC.IsEquipped(akItem)
					NPC.equipitem(akItem)
				endif
				LogTemp+=akItem
				LoadNPCReturn+=1
			endif
			i += 1
		EndWhile
	endif	
	LogTemp+=" InputData: OSNPCid="+OSNPCid[NPCindex]+" OSNPCData="+OSNPCData[NPCindex]
	;dlog(LogTemp+" <==",0,DebugHeadShort,DebugHead)
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

	OS = GetFormFromFile(0x800, "OutfitShuffler.esl") as OutfitShuffler
	OSNPCid=OS.OSNPCid
	OSNPCData=OS.OSNPCData
	String NPCUser="NPC"+IntToHexString(NPC.GetLeveledActorBase().GetFormID())+NPC.GetLeveledActorBase().GetName()
	dlog("Resetting ==>"+NPC+"<>"+NPCuser+"<==",0,DebugHeadShort,DebugHead)
	NPC.SetValue(OSMaintWait,1)
	Int NPCIndex=OSNPCid.Find(NPCUser)
	If NPCIndex>-1
		OSNPCid.Remove(NPCIndex)
		OSNPCData.Remove(NPCIndex)
	endif
	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,1)
endfunction

FormList Function SafeItems()
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		Return XYSafeItems
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		Return XXSafeItems
	endif
endfunction

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