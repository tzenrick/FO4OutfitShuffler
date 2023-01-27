Scriptname OutfitShuffler extends Quest
{Handles INI Scanning, Radius Scanning, and Initial Outfit Assignment to NPCs.}

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
Formlist Property OSRestrictedFurniture auto

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
bool ResetNPCs
string Property OSLogName auto const
String MasterINI = "OutfitShuffler.ini"
String INIpath = "OutfitShuffler\\" 
string Property OSData Auto const
string Property DebugLogString Auto
int TimeID = 888
int MultCounter = 0
int RaceCounter
int CountActors
int CountedParts
String ActorsList
Spell EBCC_DirtTier01
Spell EBCC_DirtTier02
Spell EBCC_DirtTier03

;Arrays
FormList[] Property PForm auto
String[] Property PString auto
Int[] Property PChance auto
String[] Property PluginsName auto
String[] Property LightPluginsName auto
ObjectReference[] kActorArray
ObjectReference[] ActorInArray
ObjectReference[] ActorOutArray

;Imported Variables
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
int dummyval

Event OnInit()
	if OSSuspend.GetValueInt()>0
		return
	endif
	Debug.OpenUserLog(OSLogName)
	Self.CancelTimer(TimeID)
	OSSuspend.SetValueInt(0)
	OSAllItems.Revert()
	PlayerRef.RemoveSpell(ContainersSpell)
;Setting OSVersion
	OSVersion.Setvalue(8.0)
	If dummyval>0
		return
	endif
	dlog(2,"OutfitShuffler "+OSVersion.GetValue()+" Installed")
	dlog(2,"OutfitShuffler Data="+OSData)
	dummyval+=1
	self.starttimer((GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
EndEvent

Event OnTimer(int aiTimerID)
;	dlog(2,"MQ101.IsRunning="+(pMQ101.IsRunning() as bool))
	If pMQ101.IsRunning()
		dlog(2,"++++ MQ101 IS RUNNING, NOT SCANNING OUTFITS YET ++++")
		wait(5.0)
		return
	endif
;	dlog(2,"OSEnabled="+GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool)
	if !(GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool)
;		dlog(2,"Not Enabled, exiting.")
		UnRegisterForPlayerTeleport()
		PlayerRef.RemoveSpell(ContainersSpell)
		Wait(5.0)
		return
	endif
	While OSSuspend.GetValueInt()>0
;		dlog(2,"Suspended, waiting...")
		Wait(5.0)
	endwhile

	if ResetNPCs
		fnResetStoredNPCs()
		ResetNPCs=false
	endif

;	dlog(2,"Counting Parts...")
	If CountedParts<1
		int tval=CountParts()
;		dlog(2,"CountParts()="+tval+" CountedParts="+CountedParts)
		If tval<1
			RescanOutfitsINI()
		endif
	endIf

;	dlog(2,"OnTimer() aiTimerID="+aiTimerID+" TimeID="+TimeID)
	if aiTimerID == TimeID
		RegisterForPlayerTeleport()
		If !PlayerRef.HasSpell(ContainersSpell) && GetModSettingBool("OutfitShuffler", "bUseContainers:General")
			PlayerRef.AddSpell(ContainersSpell)
			dlog(2,"Added Container Spell, "+ContainersSpell+", to "+PlayerRef)
		endif
		If !(GetModSettingBool("OutfitShuffler", "bUseContainers:General") as Bool==1) && PlayerRef.HasSpell(ContainersSpell)
			PlayerRef.RemoveSpell(ContainersSpell)
			dlog(2,"Removed Container Spell, "+ContainersSpell+", from "+PlayerRef)
		endif
		float TimerStart=GetCurrentRealTime()
		TimerTrap()
		if CountActors
			dlog(1,"TimerTrap("+MultCounter+") run in "+(GetCurrentRealTime()-TimerStart)+" seconds. "+CountActors+" NPCs changed.\nNPCs Processed:"+ActorsList+"\nTotal Plugins="+(PluginsName.Length+LightPluginsName.Length-2)+" Total OutfitParts="+CountParts())
			ActorsList=""
		endif
	endif
EndEvent

Function TimerTrap()
	CancelTimer(TimeID)
;	dlog(1,"TimerTrap("+MultCounter+") Started")
	If MultCounter>(GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)
		MultCounter=0
		ScanNPCs(True)
	else
		MultCounter+=1
		ScanNPCs(false)
	endif
	StartTimer((GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
endFunction

ObjectReference[] Function SelectionSort(ObjectReference[] ActorArray, Float[] distance, String Width)
	int iActorArrayCounter
	int i = 0
	int j
	int minIndex
	ObjectReference tempActor
	Float tempDistance
	while i < actorArray.Length - 1
		minIndex = i
		j = i + 1
		while j < actorArray.Length
			if distance[j] < distance[minIndex]
				minIndex = j
			endif
			
			j += 1
		endwhile
		if minIndex != i
			tempActor = actorArray[i]
			actorArray[i] = actorArray[minIndex]
			actorArray[minIndex] = tempActor
			
			tempDistance = distance[i]
			distance[i] = distance[minIndex]
			distance[minIndex] = tempDistance
		endif
		i += 1
	endwhile
	return ActorArray
endfunction

ObjectReference[] Function SortActors(ObjectReference[] actorInActorArray)
	int i
	ObjectReference[] Front = New ObjectReference[0]
	ObjectReference[] Front2 = New ObjectReference[0]
	Float[] FrontDistance = New Float[0]
	ObjectReference[] Wide = New ObjectReference[0]
	ObjectReference[] Wide2 = New ObjectReference[0]
	Float[] WideDistance = New Float[0]
	ObjectReference[] Rest = New ObjectReference[0]
	ObjectReference[] Rest2 = New ObjectReference[0]
	Float[] RestDistance = New Float[0]
	While i<ActorInActorArray.Length-1
		If -45<PlayerRef.GetHeadingAngle(ActorInActorArray[i]) && PlayerRef.GetHeadingAngle(ActorInActorArray[i])<45
			Front.Add(ActorInActorArray[i])
			FrontDistance.Add(PlayerRef.GetDistance(ActorInActorArray[i]))
		elseif -90<PlayerRef.GetHeadingAngle(ActorInActorArray[i]) && PlayerRef.GetHeadingAngle(ActorInActorArray[i])<90
			Wide.Add(ActorInActorArray[i])
			WideDistance.Add(PlayerRef.GetDistance(ActorInActorArray[i]))
		else
			Rest.Add(ActorInActorArray[i])
			RestDistance.Add(PlayerRef.GetDistance(ActorInActorArray[i]))
		endif
		i+=1
	endwhile
	Front2=SelectionSort(Front, FrontDistance, "Front")
	Wide2=SelectionSort(Wide, WideDistance, "Wide")
	Rest2=SelectionSort(Rest, RestDistance, "Rest")
	ObjectReference[] ActorOutActorArray  = New ObjectReference[0]
	i = 0
	while i < Front2.Length
		actorOutActorArray.Add(Front2[i])
		i+=1
	endWhile
	i = 0
	while i < Wide2.Length
		actorOutActorArray.Add(Wide2[i])
		i+=1
	endWhile
	i = 0
	while i < Rest2.Length
		actorOutActorArray.Add(Rest2[i])
		i+=1
	endWhile
	return ActorOutActorArray
endfunction

function ScanNPCs(bool Force=False)
	if OSSuspend.GetValueInt() == 0 && CountParts()>1
		CountActors = 0
		RaceCounter = 0
		ActorsList = ""
		ActorInArray=New ObjectReference[0]
		ActorOutArray=New ObjectReference[0]
		While RaceCounter < OSActorRaces.GetSize()
			int iActorArray = 0
			if OSActorRaces.GetAt(RaceCounter) != None
				kActorArray = PlayerRef.FindAllReferencesWithKeyword(OSActorRaces.GetAt(RaceCounter), (GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float))
				while iActorArray < kActorArray.Length && OSSuspend.GetValueInt() == 0
					ActorInArray.Add(kActorArray[iActorArray] as ObjectReference)
				iActorArray+=1
				endwhile
			endif
		RaceCounter += 1
		endwhile
		ActorOutArray = SortActors(ActorInArray) as Objectreference[]
		int iActorArray=0
		While iActorArray<ActorOutArray.Length
			Actor NPC=ActorOutArray[iActorArray] as Actor
			If NPC != PlayerRef
				if CheckEligibility(NPC, PreCheck=True, PostCheck=True)
					If CountNPCArmor(NPC)<2 && (GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
						CleanMe(NPC)
					endif
				endif
				if CheckEligibility(NPC)
					Var[] TempVal = New Var[0]
					TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()))
					CountActors += 1
					ActorsList += NPC.GetLeveledActorBase().GetName()+", "
					if TempVal!=None
						Var[] TempVal2=New Var[0]
						TempVal2=VarToVarArray(TempVal[0])
						if Tempval2.Length>0
							LoadNPC(NPC)
						endif
					else
						if (NPC.GetValue(OSMaintTime) + (GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int) * (GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float) * 0.00069) < (GetCurrentGameTime()) && NPC.GetItemCount(OSDontChangeItem) == 0
							NPC.SetValue(OSMaintWait,3)
							NPC.AddSpell(GetFormFromFile(0x827, "OutfitShuffler.esl") as Spell)
						elseIf !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit()) || (Force && NPC.GetItemCount(OSDontChangeItem)==0)
							NPC.SetValue(OSMaintWait,3)
							NPC.AddSpell(GetFormFromFile(0x827, "OutfitShuffler.esl") as Spell)
						else
							CleanMe(NPC)
						endif
					endif
				NPC.SetValue(OSMaintTime,GetCurrentGameTime())
				endif
			endif
		iActorArray+=1
		endwhile
	endif
endFunction

Function CleanMe(Actor NPC) Global
	EquipInOrder(NPC)
	Form[] InvItems = NPC.GetInventoryItems()
	int i
	Bool WearingDD=False
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if akItem!=None
			if IsDeviousDevice(akItem)
				if NPC.IsEquipped(akItem)
					WearingDD=True
				endif
			endif
		endif
		i += 1
	endwhile

	if WearingDD && NPC.GetItemCount(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject)==0
		NPC.AddItem(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject,1,true)
	endif
	i=0
	InvItems = NPC.GetInventoryItems()
	While (i < InvItems.Length) && NPC.GetItemCount(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject)==0
		Form akItem = InvItems[i]
		If (akItem as Armor)
			if !NPC.IsEquipped(akItem)
				NPC.RemoveItem(akItem, -1)
			endif
		endif
	i += 1
	EndWhile

	if NPC.GetItemCount(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject)==0 && CountNPCArmor(NPC)<2 && (GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
		ResetNPC(NPC)
		BuildOutfitFromParts(NPC)
	endif

	if (WearingDD && NPC.GetItemCount(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject)==0)||(GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==True) && NPC.GetItemCount(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject)==0
		NPC.AddItem(GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject,1,true)
		NPC.RemoveItem((GetFormFromFile(0x84a, "OutfitShuffler.esl") as MiscObject),-1)
	endif
Endfunction

Function EquipInOrder(Actor NPCv) Global
	Form[] InvItems = NPCv.GetInventoryItems()
	int i
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		If (akItem as Armor)
			If akItem.getformid()<0x07000000 && !(GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
				if !((GetFormFromFile(0x84b, "OutfitShuffler.esl") as Formlist).HasForm(akItem as ObjectReference) || SafeForm(NPCv).HasForm(akItem as ObjectReference) || IsDeviousDevice(akItem))
				else
					NPCv.removeitem(akItem,-1)
				endif
			endif
		endif
	i += 1
	EndWhile

	InvItems = NPCv.GetInventoryItems()
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		If (akItem as Armor) && akItem.getformid()>0x06FFFFFF && !IsDeviousDevice(akItem) || SafeForm(NPCv).HasForm(akItem as ObjectReference)
			NPCv.equipitem(akItem)
		endif
	i += 1
	endwhile

	InvItems = NPCv.GetInventoryItems()
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		if SafeForm(NPCv).HasForm(akItem as ObjectReference)
			NPCv.EquipItem(akItem)
			endif
	i += 1
	endwhile

	InvItems = NPCv.GetInventoryItems()
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if akItem!=None
			if IsDeviousDevice(akItem)
				if !NPCv.IsEquipped(akItem)
					NPCv.equipitem(akItem)
				endif
			endif
		endif
		i += 1
	endwhile

	InvItems = NPCv.GetInventoryItems()
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if (akItem as Weapon)
			if !NPCv.IsEquipped(akItem)&&(GetFormFromFile(0x841, "OutfitShuffler.esl") as FormList).HasForm(akItem)
				NPCv.equipitem(akItem)
			endif
		endif
		i += 1
	endwhile
endfunction


Bool Function CheckEligibility(Actor NPC, Bool PreCheck=False, Bool PostCheck=False)
	;Lets try the script updater here...
	If IsInRestrictedFurniture(NPC)
		if PreCheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		If PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		return false
	endif

	If NPC.HasSpell(Maintainer) && NPC.GetValue(OSNPCVersion)!=OSVersion.GetValue() && !(NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled())
		if NPC.HasSpell(Maintainer)
			NPC.RemoveSpell(Maintainer)
		endif
		if !NPC.HasSpell(Maintainer)
			NPC.AddSpell(Maintainer)
		endif
	endif

	if (NPC.IsDisabled()||\
	NPC.IsDeleted()||\
	NPC.IsChild()||\
	NPC.IsDead()||\
	(NPC == PlayerRef )||\
	(NPC.GetLeveledActorBase().GetSex()==1&&(GetModSettingBool("OutfitShuffler", "bEnableXX:General") as Bool==0))||\
	(NPC.GetLeveledActorBase().GetSex()==0&&(GetModSettingBool("OutfitShuffler", "bEnableXY:General") as Bool==0))||\
	(StringFind(NPC.GetLeveledActorBase().GetName(), "Armor Rack") != -1)||\
	(StringFind(NPC.GetLeveledActorBase().GetName(), "Wilma's Wigs") != -1))
		if Precheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		If PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(Maintainer)
			NPC.RemoveSpell(Maintainer)
		endif
		return false
	endif

	if (PlayerRef.GetDistance(NPC)>(GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float))
		if Precheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		If PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		return false
	endif

;check against AAF if enabled
	if !CheckAAFSafe(NPC)
		If Precheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		If PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		return false
	endif

	if (NPC.GetValue(OSMaintTime)==0 && NPC.GetValue(OSMaintWait)==0)
		NPC.SetValue(OSMaintWait,3)
		return true
	endif

	If !Precheck
		If NPC.GetItemCount(OSAlwaysChangeItem)>0
			return True
		endif
	endif

	If (NPC.GetItemCount(OSDontChangeItem)>0)
		If Precheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		if PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		return False
	endif

	If NPC.GetValue(OSMaintWait)==1 && (NPC.GetValue(OSMaintTime)+(GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)*(GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float)*0.00069)>GetCurrentGameTime()
		return True
	endif

	If NPC.GetValue(OSMaintWait)==1
		If Precheck
			ActorInArray.Remove(ActorInArray.Find(NPC))
		endif
		if PostCheck
			ActorOutArray.Remove(ActorOutArray.Find(NPC))
		endif
		return False
	endif
;check against restricted factions
	If FactionsToIgnore.GetSize()
		Int i
		While i<FactionsToIgnore.GetSize()
			If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				If NPC.GetItemCount(OSAlwaysChangeItem)>0
					return True
				else
					If Precheck
						ActorInArray.Remove(ActorInArray.Find(NPC))
					endif
					if PostCheck
						ActorOutArray.Remove(ActorOutArray.Find(NPC))
					endif
					return False
				endif
			endif
		i += 1
		Endwhile
	endif
	return true
endFunction

Function UnEquipItems(Actor NPC) Global
	GlobalVariable Suspend=GetFormFromFile(0x847, "OutfitShuffler.esl") as GlobalVariable
	if Suspend.GetValueInt()==1
		While Suspend.GetValueInt()==1
			wait(0.1)
		endwhile
	else
		FormList fnWeaponsList = GetFormFromFile(0x841, "OutfitShuffler.esl") as FormList
		Form[] InvItems = NPC.GetInventoryItems()
		int i=0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If SafeForm(NPC).HasForm(akItem)
				if !NPC.IsEquipped(akItem)
					NPC.EquipItem(akItem)
				endif
			elseif IsDeviousDevice(akItem) 
				if !NPC.IsEquipped(akItem)
					NPC.EquipItem(akItem)
				endif
			elseif (akItem as Armor) || fnWeaponsList.HasForm(akItem)
				NPC.removeitem(akItem, -1)
			endif
		i += 1
		EndWhile
		CleanCaptive(NPC)
	endif
endfunction

Function GetOutfitChances()
;OutfitChances
	Int counter = 0
	While counter < PForm.Length
		PChance[counter]=GetModSettingInt("OutfitShuffler", "iChance"+PString[counter]+":General") as Int
		counter += 1
	endwhile
endfunction

Function OutfitHotkey()
	GetOutfitChances()
	MultCounter = (GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)
EndFunction

Function ChangeNow()
;	DebugLogString+="In ChangeNow()")
	GetOutfitChances()
	Actor NPC = LastCrossHairActor()
	If NPC != None
		dlog(2,NPC+""+NPC.GetLeveledActorBase().GetName()+" will be changed immediately")
		NPC.SetValue(OSMaintWait,1)
		UnequipItems(NPC)
		ResetNPC(NPC)
		NPC.SetValue(OSMaintWait,1)
		NPC.SetValue(OSMaintTime,GetCurrentGameTime())
		BuildOutfitFromParts(NPC)
	endif
endfunction

Function DebugNPC()
;FileOutput
	Actor NPC = LastCrossHairActor()
	If NPC
		Form[] InvItems = NPC.GetInventoryItems()
		int i=0
		String NPCSex
		If NPC.GetLeveledActorBase().GetSex()==0
			NPCSex="Male"
		endif
		If NPC.GetLeveledActorBase().GetSex()==1
			NPCSex="Female"
		endif
		string longinv="\n       INV: Equipped Items"
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
				Longinv += "\n       INV: IsEquipped="+NPC.IsEquipped(akitem)+akItem+akItem.GetName()
				If IsDeviousDevice(akItem)
					LongInv += " is a Devious Device"
				endif
			i += 1
		EndWhile
		longinv+="\n       INV: No More Equipped Items"
		float MaintTimer=NPC.GetValue(OSMaintTime)+(GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)*(GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float)*0.00069
		DebugLogString="\n   ***************DebugNPC()***************"
		DebugLogString+="\n   ***************Name:"+NPC+NPC.GetLeveledActorBase().GetName()
		DebugLogString+="\n   ****************Sex:"+NPCSex
		DebugLogString+="\n   ***************Race:"+NPC.GetLeveledActorBase().GetRace()
		DebugLogString+="\n   **DC/AC-DS/AS-DB/AB:"+(NPC.GetItemCount(OSDontChangeItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysChangeItem) as Bool)+"-"+(NPC.GetItemCount(OSDontScaleItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysScaleItem) as Bool)+"-"+(NPC.GetItemCount(OSDontBodyGenItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysBodyGenItem) as Bool)
		DebugLogString+="\n   *********OSBodyDone:"+NPC.GetValue(OSBodyDone) as Bool
		DebugLogString+="\n   **********IsDeleted:"+NPC.IsDeleted() as Bool
		DebugLogString+="\n   *********IsDisabled:"+NPC.IsDisabled() as Bool
		DebugLogString+="\n   ****PowerArmorCheck:"+PowerArmorCheck(NPC) as Bool
		DebugLogString+="\n   ************IsChild:"+NPC.IsChild() as Bool
		DebugLogString+="\n   *************IsDead:"+NPC.IsDead() as Bool
		DebugLogString+="\n   ***********Distance:"+NPC+PlayerRef.GetDistance(NPC) as Int
		DebugLogString+="\n   ****MaintainerSpell="+NPC.HasSpell(Maintainer) as Bool
		DebugLogString+="\n   ********OSMaintWait="+NPC.Getvalue(OSMaintWait) as Bool
		DebugLogString+="\n   *******OSMaintTime+="+NPC.GetValue(OSMaintTime)+"  MaintTimer="+MaintTimer
		DebugLogString+="\n   ********CurrentTime="+GetCurrentGameTime()
		DebugLogString+="\n   *************Outfit="+NPC.GetLeveledActorBase().Getoutfit()+NPC.GetLeveledActorBase().Getoutfit().GetName()
		DebugLogString+="\n"+longinv+"\n"
		If FactionsToIgnore.GetSize()
			i=0
			While i<FactionsToIgnore.GetSize()
				If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
					DebugLogString+="\n   ***FactionsToIgnore:"+NPC+" is in "+FactionsToIgnore.GetAt(i)
				endif
			i += 1
			Endwhile
		endif
		DebugLogString+="\n   ************Finish DebugNPC()***********"
		dlog(2,DebugLogString)
	endif
endfunction

Function DontChange()
	Actor NPC = LastCrossHairActor()
	If NPC != None
		If (NPC.GetItemCount(OSDontChangeItem)>0)
			NPC.RemoveItem(OSDontChangeItem,-1)
			NPC.AddItem(OSAlwaysChangeItem)
			dLog(2,NPC.GetLeveledActorBase().GetName()+" will ignore faction exclusions.")
			return
		endif
		If (NPC.GetItemCount(OSAlwaysChangeItem)>0)
			NPC.RemoveItem(OSAlwaysChangeItem,-1)
			dLog(2,NPC.GetLeveledActorBase().GetName()+" WILL be changed.")
			return
		endif
		NPC.AddItem(OSDontChangeItem,1,true)
		dLog(2,NPC.GetLeveledActorBase().GetName()+" WILL NOT be changed.")
	endif
EndFunction

Function MCMBodyGen()
	RandomBodyGen()
endFunction

Function RandomBodygen(Actor NPCv=None) Global
	MiscObject OSDCI=GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject;OSDontChangeItem
	MiscObject OSACI=GetFormFromFile(0x84a, "OutfitShuffler.esl") as MiscObject;OSAlwaysChangeItem
	MiscObject OSDBI=GetFormFromFile(0x852, "OutfitShuffler.esl") as MiscObject;OSDontBodyGenItem
	MiscObject OSABI=GetFormFromFile(0x853, "OutfitShuffler.esl") as MiscObject;OSAlwaysBodyGenItem
	MiscObject OSDSI=GetFormFromFile(0x854, "OutfitShuffler.esl") as MiscObject;OSDontScaleItem
	MiscObject OSASI=GetFormFromFile(0x855, "OutfitShuffler.esl") as MiscObject;OSAlwaysScaleItem
	String source="passed actor"
	If NPCv == None
		NPCv = LastCrossHairActor()
		source="crosshair actor"
	endif
	String bodyaction
	If NPCv != None
		If NPCv.GetItemCount(OSDBI)==0
			bodyaction += "Random BodyGen"
			BodyGen.RegenerateMorphs(NPCv, true)
		endif
		If NPCv.GetItemCount(OSDSI)<1 && ((GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool==1)||NPCv.GetItemCount(OSASI))
			float NPCNewScale
			if (GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float) >= (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float)
				NPCNewScale=(GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float)
			else
				NPCNewScale = RandomFloat((GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float), (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float))
			endif
			bodyaction += " Random Scale = "+NPCNewScale
			NPCv.SetScale(NPCNewScale)
		endif
	endif
	String Loggit="RandomBodyGen() "+source+" "+NPCv.GetLeveledActorBase().GetName()+" "+bodyaction
	dlog(1,Loggit)
endFunction

Function RescanOutfitsINI()
;Stop OSMaintainer script
	OSSuspend.SetvalueInt(1)
	float RescanTimer=GetCurrentRealTime()
	canceltimer(TimeID)
	dLog(2,"*** Stopping timers and rescanning outfit pieces ***")
;housekeeping
	BuildOutfitArray()
	GetPluginInfo()
	int AllSlotsCounter = 0
	int counter=0
;clear parts lists
	OSAllItems.Revert()
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
;Get Outfit INI Files
	Var[] ConfigOptions=GetCustomConfigOptions(MasterINI, "InputFiles")
	Var[] Keys=VarToVarArray(ConfigOptions[0])
	int j=0
	While j<Keys.Length
		int ConfigOptionsInt=GetCustomConfigOption_UInt32(MasterINI, "InputFiles", Keys[j]) as int
		if ConfigOptionsInt > 0
			dlog(2,"Scanning for new outfits...      "+j+"/"+keys.length)
			ScanINI(Keys[j])
		endif
	j += 1
	endwhile
;Get Races; Updated to Understand Hex
	ConfigOptions=GetCustomConfigOptions(MasterINI, "Races")
	if ConfigOptions.Length!=0
		Var[] RaceKeys=VarToVarArray(ConfigOptions[0])
		Var[] RaceValues=VarToVarArray(ConfigOptions[1])
		j=0
		OSActorRaces.Revert()
		int FormToAdd
		if RaceKeys.length>0
			While j<RaceKeys.Length
				if StringFind(RaceValues[j],"0x")>-1
					string[] FormToAddLeft=StringSplit(RaceValues[j],";")
					string[] FormToAddHex=StringSplit(FormToAddLeft[0],"x")
					FormToAdd=HexStringToInt("0x"+FormToAddHex[1]) as Int
				else
					FormToAdd=RaceValues[j] as int
				endif
				if FormToAdd > 0
					DebugLogString+=Game.GetFormFromFile(FormToAdd, RaceKeys[j])+" Added to Races"
					OSActorRaces.AddForm(Game.GetFormFromFile(FormToAdd,RaceKeys[j]))
				endif
			j += 1
			endwhile
		endif
	endif
;Get FactionsToIgnore; Updated to Understand Hex
	ConfigOptions=GetCustomConfigOptions(MasterINI, "FactionsToIgnores")
	if ConfigOptions.Length!=0
		Var[] FactionsToIgnoreKeys=VarToVarArray(ConfigOptions[0])
		Var[] FactionsToIgnoreValues=VarToVarArray(ConfigOptions[1])
		j=0
		FactionsToIgnore.Revert()
		int FormToAdd
		if FactionsToIgnoreKeys.Length>0
			While j<FactionsToIgnoreKeys.Length
				if StringFind(FactionsToIgnoreValues[j],"0x")>-1
					string[] FormToAddLeft=StringSplit(FactionsToIgnoreValues[j],";")
					string[] FormToAddHex=StringSplit(FormToAddLeft[0],"x")
					FormToAdd=HexStringToInt("0x"+FormToAddHex[1]) as Int
				else
					FormToAdd=FactionsToIgnoreValues[j] as int
				endif
				if FormToAdd > 0
					DebugLogString+=Game.GetFormFromFile(FormToAdd, FactionsToIgnoreKeys[j])+" Added to FactionsToIgnores"
					FactionsToIgnore.AddForm(Game.GetFormFromFile(FormToAdd,FactionsToIgnoreKeys[j]))
				endif
			j += 1
			endwhile
		endif
	endif
	dlog(1,DebugLogString)
	GetOutfitChances()
	dlog(2,"Outfit Scan completed in "+(GetCurrentRealTime()-RescanTimer)+" seconds.")
	OSSuspend.SetValueInt(0)
;restart the timer
	StartTimer((GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
endfunction

Function ScanINI(String INItoCheck)
	String INIFile=INIpath+INItoCheck
	int ScanINICounter
	If Game.IsPluginInstalled(StringSubstring(INIToCheck, 0, StringFind(INIToCheck, ".ini", 0))) || INIToCheck == "Weapons.ini"
		String[] ChildINISections=GetCustomConfigSections(INIFile) as String[]
		int ChildINISectionCounter=0
		int WholeINI
		String WholeINIDebug
		if ChildINISections.Length > 0
			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=VarToVarArray(ChildConfigOptions[0])
				WholeINI += ChildKeys.Length
				ChildINISectionCounter+=1
			endwhile
		endif
		ChildINISectionCounter=0
		if ChildINISections.Length > 0
			dlog(1,"ScanINI() Adding "+INIFile)
 			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=VarToVarArray(ChildConfigOptions[0])
				Var[] ChildValues=VarToVarArray(ChildConfigOptions[1])
				If ChildKeys.Length > 0
					int ChildKeysCounter=0
					While ChildKeysCounter < ChildKeys.Length
						string FormToAddString=ChildValues[ChildKeysCounter] as String
						int FormToAdd
						if StringFind(FormToAddString,"0x")>-1
							string[] FormToAddLeft=StringSplit(FormToAddString,";")
							string[] FormToAddHex=StringSplit(FormToAddLeft[0],"x")
							FormToAdd=HexStringToInt("0x"+FormToAddHex[1]) as Int
						else
							FormToAdd=ChildValues[ChildKeysCounter] as int
						endif
						if FormToAdd > 0
							If PString.Find(ChildINISections[ChildINISectionCounter]) > -1
								Form TempItem=Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter])
								PForm[PString.Find(ChildINISections[ChildINISectionCounter])].AddForm(TempItem)
								if TempItem!=None
									If  !IsDeviousDevice(TempItem)
										OSAllItems.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]))
									endif
								endif
								ScanINICounter+=1
							endIf
						endif
						ChildKeysCounter += 1
					endwhile
				endif
			ChildINISectionCounter += 1
			endwhile
		endif
	endif
endFunction

Function BuildOutfitArray()
	dlog(2,"BuildOutfitArray() Starting")
	PForm = new FormList[0]
	PString = new String[0]
	PChance = new Int[0]
	PForm.Clear()
	PString.Clear()
	PChance.Clear()
	;0
	PString.Add("XXFullBody")
	PForm.Add(XXFullBody)
	PChance.Add(0)
	;1
	PString.Add("XXShoes")
	PForm.Add(XXShoes)
	PChance.Add(0)
	;2
	PString.Add("XXTop")
	PForm.Add(XXTop)
	PChance.Add(0)
	;3
	PString.Add("XXBottom")
	PForm.Add(XXBottom)
	PChance.Add(0)
	;4
	PString.Add("XXArmAddon")
	PForm.Add(XXArmAddon)
	PChance.Add(0)
	;5
	PString.Add("XXNeck")
	PForm.Add(XXNeck)
	PChance.Add(0)
	;6
	PString.Add("XXBelt")
	PForm.Add(XXBelt)
	PChance.Add(0)
	;7
	PString.Add("XXHair")
	PForm.Add(XXHair)
	PChance.Add(0)
	;8
	PString.Add("XXLongHair")
	PForm.Add(XXLongHair)
	PChance.Add(0)
	;9
	PString.Add("XXGlasses")
	PForm.Add(XXGlasses)
	PChance.Add(0)
	;10
	PString.Add("XXLegs")
	PForm.Add(XXLegs)
	PChance.Add(0)
	;11
	PString.Add("XXBack")
	PForm.Add(XXBack)
	PChance.Add(0)
	;12
	PString.Add("XXFront")
	PForm.Add(XXFront)
	PChance.Add(0)
	;13
	PString.Add("XXAccessory")
	PForm.Add(XXAccessory)
	PChance.Add(0)
	;14
	PString.Add("XXJacket")
	PForm.Add(XXJacket)
	PChance.Add(0)
	;15
	PString.Add("XXTorsoArmor")
	PForm.Add(XXTorsoArmor)
	PChance.Add(0)
	;16
	PString.Add("XXLeftArmArmor")
	PForm.Add(XXLeftArmArmor)
	PChance.Add(0)
	;17
	PString.Add("XXRightArmArmor")
	PForm.Add(XXRightArmArmor)
	PChance.Add(0)
	;18
	PString.Add("XXLeftLegArmor")
	PForm.Add(XXLeftLegArmor)
	PChance.Add(0)
	;19
	PString.Add("XXRightLegArmor")
	PForm.Add(XXRightLegArmor)
	PChance.Add(0)
	;20
	PString.Add("XXEarrings")
	PForm.Add(XXEarrings)
	PChance.Add(0)
	;21
	PString.Add("XXRing")
	PForm.Add(XXRing)
	PChance.Add(0)
	;22
	PString.Add("XXBackpack")
	PForm.Add(XXBackpack)
	PChance.Add(0)
	;23
	PString.Add("XXShoulder")
	PForm.Add(XXShoulder)
	PChance.Add(0)
	;24
	PString.Add("XXSafeItems")
	PForm.Add(XXSafeItems)
	PChance.Add(0)
	;25
	PString.Add("XXMouth")
	PForm.Add(XXMouth)
	PChance.Add(0)
	;males
	;26
	PString.Add("XYFullBody")
	PForm.Add(XYFullBody)
	PChance.Add(0)
	;27
	PString.Add("XYShoes")
	PForm.Add(XYShoes)
	PChance.Add(0)
	;28
	PString.Add("XYTop")
	PForm.Add(XYTop)
	PChance.Add(0)
	;29
	PString.Add("XYBottom")
	PForm.Add(XYBottom)
	PChance.Add(0)
	;30
	PString.Add("XYArmAddon")
	PForm.Add(XYArmAddon)
	PChance.Add(0)
	;31
	PString.Add("XYNeck")
	PForm.Add(XYNeck)
	PChance.Add(0)
	;32
	PString.Add("XYBelt")
	PForm.Add(XYBelt)
	PChance.Add(0)
	;33
	PString.Add("XYHair")
	PForm.Add(XYHair)
	PChance.Add(0)
	;34
	PString.Add("XYLongHair")
	PForm.Add(XYLongHair)
	PChance.Add(0)
	;35
	PString.Add("XYGlasses")
	PForm.Add(XYGlasses)
	PChance.Add(0)
	;36
	PString.Add("XYLegs")
	PForm.Add(XYLegs)
	PChance.Add(0)
	;37
	PString.Add("XYBack")
	PForm.Add(XYBack)
	PChance.Add(0)
	;38
	PString.Add("XYFront")
	PForm.Add(XYFront)
	PChance.Add(0)
	;39
	PString.Add("XYAccessory")
	PForm.Add(XYAccessory)
	PChance.Add(0)
	;40
	PString.Add("XYJacket")
	PForm.Add(XYJacket)
	PChance.Add(0)
	;41
	PString.Add("XYTorsoArmor")
	PForm.Add(XYTorsoArmor)
	PChance.Add(0)
	;42
	PString.Add("XYLeftArmArmor")
	PForm.Add(XYLeftArmArmor)
	PChance.Add(0)
	;43
	PString.Add("XYRightArmArmor")
	PForm.Add(XYRightArmArmor)
	PChance.Add(0)
	;44
	PString.Add("XYLeftLegArmor")
	PForm.Add(XYLeftLegArmor)
	PChance.Add(0)
	;45
	PString.Add("XYRightLegArmor")
	PForm.Add(XYRightLegArmor)
	PChance.Add(0)
	;46
	PString.Add("XYEarrings")
	PForm.Add(XYEarrings)
	PChance.Add(0)
	;47
	PString.Add("XYRing")
	PForm.Add(XYRing)
	PChance.Add(0)
	;48
	PString.Add("XYBackpack")
	PForm.Add(XYBackpack)
	PChance.Add(0)
	;49
	PString.Add("XYShoulder")
	PForm.Add(XYShoulder)
	PChance.Add(0)
	;50
	PString.Add("XYSafeItems")
	PForm.Add(XYSafeItems)
	PChance.Add(0)
	;51
	PString.Add("XYMouth")
	PForm.Add(XYMouth)
	PChance.Add(0)
	;52
	PString.Add("WeaponsList")
	PForm.Add(WeaponsList)
	PChance.Add(0)
	;53
	PString.Add("OSRestrictedFurniture")
	PForm.Add(OSRestrictedFurniture)
	PChance.Add(0)
	dlog(2,"BuildOutfitArray() complete.")
endfunction

int Function CountParts()
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	CountedParts=OutfitPartsAdder
	return OutfitPartsAdder
endfunction

Function OSItemsAdd()
	PlayerRef.additem(OSDontChangeItem,25)
	PlayerRef.additem(OSAlwaysChangeItem,25)
	PlayerRef.additem(OSDontBodyGenItem,25)
	PlayerRef.additem(OSAlwaysBodyGenItem,25)
	PlayerRef.additem(OSDontScaleItem,25)
	PlayerRef.additem(OSAlwaysScaleItem,25)
endfunction

Function OSItemsRemove()
	PlayerRef.RemoveItem(OSDontChangeItem,-1)
	PlayerRef.RemoveItem(OSAlwaysChangeItem,-1)
	PlayerRef.RemoveItem(OSDontBodyGenItem,-1)
	PlayerRef.RemoveItem(OSAlwaysBodyGenItem,-1)
	PlayerRef.RemoveItem(OSDontScaleItem,-1)
	PlayerRef.RemoveItem(OSAlwaysScaleItem,-1)
endfunction

Function JustEndItAll()
	int counter=0
	OSAllItems.Revert()
	PlayerRef.RemoveSpell(ContainersSpell)
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
	debug.messagebox("This is irreversible, and you were warned./nSave, exit, load (With missing OutfitShuffler.esl), save, exit.\nReinstall or upgrade if desired.")
	OSSuspend.SetValueInt(1)
	OutfitShufflerQuest.Stop()
endFunction

Function ResetStoredNPCs()
	ResetNPCs=True
endfunction

Function fnResetStoredNPCs()
	OSSuspend.SetValueInt(1)
	String[] TempVal = New String[0]
	TempVal = GetCustomConfigSections(OSData)
	If tempval!=None
		int i
		While i<TempVal.Length
			Actor NPC=GetForm(HexStringToInt(TempVal[i])) as Actor
			dlog(2,"ResetStoredNPCs() Resetting "+NPC+NPC.GetLeveledActorBase().GetName())
			ResetNPC(NPC)
			i += 1
		EndWhile
	endif
	OSSuspend.SetValueInt(0)
endfunction

function ResetNPC(Actor NPCv) Global
	String[] Dummy = New String[0]
	Dummy=None
	
	MiscObject OSDCI=GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject;OSDontChangeItem
	MiscObject OSACI=GetFormFromFile(0x84a, "OutfitShuffler.esl") as MiscObject;OSAlwaysChangeItem
	MiscObject OSDBI=GetFormFromFile(0x852, "OutfitShuffler.esl") as MiscObject;OSDontBodyGenItem
	MiscObject OSABI=GetFormFromFile(0x853, "OutfitShuffler.esl") as MiscObject;OSAlwaysBodyGenItem
	MiscObject OSDSI=GetFormFromFile(0x854, "OutfitShuffler.esl") as MiscObject;OSDontScaleItem
	MiscObject OSASI=GetFormFromFile(0x855, "OutfitShuffler.esl") as MiscObject;OSAlwaysScaleItem

	If NPCv.GetItemCount(OSACI)>0
		NPCv.RemoveItem(OSACI,-1)
	endif
	if NPCv.GetItemCount(OSDCI)>0
		NPCv.RemoveItem(OSDCI,-1)
	endif
	if NPCv.GetItemCount(OSABI)>0
		NPCv.RemoveItem(OSABI,-1)
	endif
	if NPCv.GetItemCount(OSDBI)>0
		NPCv.RemoveItem(OSDBI,-1)
	endif
	if NPCv.GetItemCount(OSASI)>0
		NPCv.RemoveItem(OSASI,-1)
	endif
	if NPCv.GetItemCount(OSDSI)>0
		NPCv.RemoveItem(OSDSI,-1)
	endif

	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String OSDataFile
	OSDataFile = OS.OSData as String

	ResetCustomConfigOptions(OSDataFile,IntToHexString(NPCv.GetFormID()),Dummy,Dummy)
endfunction


Event OnPlayerTeleport()
	dlog(1,"OnPlayerTeleport() Clearing kActorArray, ActorInArray, ActorOutArray and RaceCounter")
	kActorArray=None
	ActorInArray=None
	ActorOutArray=None
	RaceCounter=999999
EndEvent

Function dLog(int dLogLevel,string LogMe, String AltShort="", String AltLong="") global; 6.25 Implementing Leveled Logging. Sloppily.
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String OS_LogName = OS.OSLogName as String
	String DLOGString = OS.DebugLogString as String
	If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int>0
		Debug.OpenUserLog(OS_LogName)
		If AltShort+AltLong==""
			AltLong="[..Shuffler]"
			AltShort="[OS]"
		endif
		If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
			debug.TraceUser(OS_LogName, AltLong+LogMe,1)
		endif
		If dLogLevel > 1
			debug.Notification(AltShort+LogMe)
		endif
		If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 2 || dLogLevel == 2
			PrintConsole(AltShort+LogMe)
		endif
	endif
	OS.DebugLogString=""
endFunction

Function SaveNPC(Actor NPCv) Global
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String OS_Data = OS.OSData as String
	FormList OS_Skins = OS.OSSkins as FormList
	String OS_LogName = OS.OSLogName as String

	int i=0
	Var[] NPCvKey = New Var[0]
	Var[] NPCvValue = New Var[0]
	i=0
	NPCvKey.Add("Name")
	NPCvValue.Add(NPCv.GetLeveledActorBase().GetName())
	Form[] InvItems = NPCv.GetInventoryItems()
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			if akItem==Game.GetFormFromFile(akitem.GetFormID(), "OutfitShuffler.esl")
				NPCvKey.Add(IntToHexString(akItem.GetFormID()))
				NPCvValue.Add("OutfitShuffler.esl")
			endif
		i += 1
	EndWhile		
	i=0
	InvItems = NPCv.GetInventoryItems()
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If ((akItem as Armor)||(akItem as Weapon)) && !akitem.GetName()=="" && !OS_Skins.HasForm(akItem)
				String[] PluginData = GetFileFromForm(akItem)
				NPCvKey.Add(PluginData[1])
				NPCvValue.Add(PluginData[0])
			endif
		i += 1
	EndWhile
	String LogMe="[.Shuffler] Saved "+NPCv+NPCv.GetLeveledActorBase().GetName()+" to "+OS_Data
	debug.TraceUser(OS_LogName, LogMe,1)
	bool retval=ResetCustomConfigOptions(OS_Data, IntToHexString(NPCv.GetFormID()), NPCvKey as String[], NPCvValue as String[])
endfunction

int Function getLow12Bits(Int i) global
    return RightShift(LeftShift(i,20),20)
EndFunction

int Function getLow24Bits(Int i) global
    return RightShift(LeftShift(i,8),8)
EndFunction

String[] Function GetFileFromForm(Form InputForm) global
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String[] Plugins_Name
	String[] LightPlugins_Name
	Plugins_Name = OS.PluginsName as String[]
	LightPlugins_Name = OS.LightPluginsName as String[]

	Int i
	Int Working = RightShift(LeftShift(InputForm.GetFormID(),8),8)
	If Plugins_Name.length<1
		GetPluginInfo()
	endif
	While i<Plugins_Name.length
		Form FoundForm=Game.GetFormFromFile(Working, Plugins_Name[i])
		If FoundForm!=None
			If FoundForm==InputForm
				String[] RetVal = New String[2]
				retval[0]=Plugins_Name[i]
				retval[1]=IntToHexString(GetLow24Bits(InputForm.GetFormID()))
				return retval
			endif
		endif
		i+=1
	Endwhile
	i=0
	while LightPlugins_Name.length>0 && i<LightPlugins_Name.length
		Form FoundForm=Game.GetFormFromFile(Working, LightPlugins_Name[i])
		If FoundForm!=None
			If FoundForm==InputForm
				String[] RetVal = New String[2]
				retval[0]=LightPlugins_Name[i]
				retval[1]=IntToHexString(getLow12Bits(InputForm.GetFormID()))
				return retval
			endif
		endif
		i+=1
	endwhile
	String[] RetVal = New String[2]
	retval[0]="ERROR"
	retval[1]=IntToHexString(InputForm.GetFormID())
	return retval
endfunction

Function GetPluginInfo() global
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	String[] Plugins_Name
	String[] LightPlugins_Name
	Plugins_Name = OS.PluginsName as String[]
	LightPlugins_Name = OS.LightPluginsName as String[]
	float timehack=GetCurrentRealTime()
	Var[] PluginInfo = New Var[0]
	Var[] LightPluginInfo = New Var[0]
	Plugins_Name=New String[0]
	LightPlugins_Name=New String[0]
	float PluginsStart=GetCurrentRealTime()
	PluginInfo = Game.GetInstalledPlugins() as Var[]
	LightPluginInfo = Game.GetInstalledLightPlugins() as Var[]
	int i=0
	While i<PluginInfo.Length
		String tempval=StringSubString(PluginInfo[i],StringFind(PluginInfo[i],"Name = ")+8)
		dlog(1, "PluginName="+StringSubString(tempval,0, StringFind(tempval,".es")+4),1)
		string FinalString=StringSubString(tempval,0, StringFind(tempval,".es")+4)
		OS.PluginsName.Add(FinalString)
		if timehack+3<GetCurrentRealTime()
			timehack=GetCurrentRealTime()
			debug.notification("GetPluginInfo() "+FinalString)
		endif
		i+=1
	endwhile
	i=0
	float LightPluginsStart=GetCurrentRealTime()
	While i<LightPluginInfo.Length
		String tempval=StringSubString(LightPluginInfo[i],StringFind(LightPluginInfo[i],"Name = ")+8)
		dlog(1, "LightPluginName="+StringSubString(tempval,0, StringFind(tempval,".es")+4),1)
		string FinalString=StringSubString(tempval,0, StringFind(tempval,".es")+4)
		OS.LightPluginsName.Add(FinalString)
		if timehack+3<GetCurrentRealTime()
			timehack=GetCurrentRealTime()
			debug.notification("GetPluginInfo() "+FinalString)
		endif
		i+=1
	endwhile
	dlog(1,"GetPluginInfo() Total Plugins="+OS.PluginsName.Length+" Total LightPlugins="+OS.LightPluginsName.Length+" Plugins Time="+(GetCurrentRealTime()-PluginsStart)+" LightPlugins Time="+(GetCurrentRealTime()-LightPluginsStart))
endfunction

bool Function PowerArmorCheck(Actor NPC) Global
	if NPC.IsInPowerArmor()
		return True
	endif
	;because i hate myself, maximize compatibility, without creating a dependancy.
	if IsPluginInstalled("PowerArmorLite.esp")
		if NPC.IsEquipped(GetFormFromFile(0xf9c,"PowerArmorLite.esp")) || NPC.IsEquipped(GetFormFromFile(0x1806,"PowerArmorLite.esp")) || NPC.IsEquipped(GetFormFromFile(0x18a7,"PowerArmorLite.esp"))
			return True
		endif
	endif
	if IsPluginInstalled("PowerArmorLiteReplacer.esp")
		if NPC.IsEquipped(GetFormFromFile(0x806,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(GetFormFromFile(0x807,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(GetFormFromFile(0x808,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(GetFormFromFile(0x80a,"PowerArmorLiteReplacer.esp"))
			return True
		endif
	endif
	return false
endfunction


Bool Function CheckAAFSafe(Actor NPC) Global
	Keyword fnAAFBusyKeyword
	If IsPluginInstalled("AAF.esm")
		fnAAFBusyKeyword = GetFormFromFile(0x00915a, "AAF.esm") as Keyword
	endif
	if fnAAFBusyKeyword && !NPC.HasKeyword(fnAAFBusyKeyword)
		Return True
	endif
	if fnAAFBusyKeyword == None
		Return True
	endif
	Return False
endfunction

bool Function IsDeviousDevice(Form akItem) Global
	If IsPluginInstalled("Devious Devices.esm")
		if akItem.HasKeyword(GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword)||akItem.HasKeyword(GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword)
			return true
		endif
	endif
	return False
endfunction

Function CleanCaptive(Actor NPC) Global
	If IsPluginInstalled("Commonwealth Captives.esp")
		If NPC.HasSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp"))
			NPC.RemoveSpell(GetFormFromFile(0x0103d0,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp"))
			NPC.RemoveSpell(GetFormFromFile(0x0103d1,"Commonwealth Captives.esp") as Spell)
		endif
		If NPC.HasSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp"))
			NPC.RemoveSpell(GetFormFromFile(0x0103d2,"Commonwealth Captives.esp") as Spell)
		endif
	endif		
endFunction

int Function CountNPCArmor(Actor NPC) Global
	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	Formlist Skins=OS.OSSkins
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	int ArmorItems
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If (akItem as Armor)!=None && NPC.IsEquipped(akItem) && !Skins.HasForm(akItem)
				ArmorItems+=1
			endif
		i += 1
	EndWhile
	Return ArmorItems
endfunction

FormList Function SafeForm(Actor NPC) Global
	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		NPCSex="XY"
		Return GetFormFromFile(0x80b, "OutfitShuffler.esl") as FormList
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		NPCSex="XX"
		Return GetFormFromFile(0x82e, "OutfitShuffler.esl") as FormList
	endif
endfunction

Function BuildOutfitFromParts(Actor NPC) Global
	
	;Run a Cleanup, first
	UnequipItems(NPC)
	Outfit EO=GetFormFromFile(0x81f, "OutfitShuffler.esl") as Outfit
	Spell MSpell=GetFormFromFile(0x827, "OutfitShuffler.esl") as Spell
	ActorValue OSMT=GetFormFromFile(0x842, "OutfitShuffler.esl") as ActorValue
	ActorValue OSMW=GetFormFromFile(0x849, "OutfitShuffler.esl") as ActorValue
	ActorValue OSNPCV=GetFormFromFile(0x85b, "OutfitShuffler.esl") as ActorValue
	MiscObject OSDCI=GetFormFromFile(0x843, "OutfitShuffler.esl") as MiscObject
	GlobalVariable OSV=GetFormFromFile(0x85c, "OutfitShuffler.esl") as GlobalVariable
	
;Alias-ish the main script, to pass PForm, PString, and PChance back and forth through the Global interface
	OutfitShuffler OS
	OS = GetFormFromFile(0x800,"OutfitShuffler.esl") as OutfitShuffler

	FormList[] OSPF
	String[] OSPS
	Int[] OSPC

	OSPF=OS.PForm
	OSPS=OS.PString
	OSPC=OS.PChance

	NPC.SetOutfit(EO)
	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		NPCSex="XY"
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		NPCSex="XX"
	endif
;Assign Items and Equip
	
	If RandomInt(1,99)<OSPC[OSPS.Find(NPCSex+"FullBody")] && OSPF[OSPS.Find(NPCSex+"FullBody")].GetSize()>0
		Form RandomItem
		While RandomItem==None
			RandomItem = OSPF[OSPS.Find(NPCSex+"FullBody")].GetAt(RandomInt(0,OSPF[OSPS.Find(NPCSex+"FullBody")].GetSize()))
		endwhile
		NPC.EquipItem(RandomItem)
	else
		Int Counter=1
		While counter < OSPF.Length
			If (StringFind(OSPS[Counter], NPCSex) == 0) && (StringFind(OSPS[Counter], "FullBody") == -1) && OSPC[Counter]>1 && OSPF[Counter].GetSize()>0 && RandomInt(1,99)<OSPC[counter]
				Form RandomItem = OSPF[counter].GetAt(RandomInt(0,OSPF[Counter].GetSize())) as Form
				If RandomItem != None
					NPC.EquipItem(RandomItem)
				endif
			endif
		counter += 1
		endwhile
	endif
;assign weapon
	If RandomInt(1,99)<OSPC[OSPS.Find("WeaponsList")] && OSPF[OSPS.Find("WeaponsList")].GetSize()>0
		Form RandomItem = None
		While RandomItem as Weapon == None
			RandomItem = OSPF[OSPS.Find("WeaponsList")].GetAt(RandomInt(0,OSPF[OSPS.Find("WeaponsList")].GetSize()))
		endwhile
		NPC.EquipItem(RandomItem)
	endif

	if NPC.GetItemCount(OSDCI)>0 \
	&& CountNPCArmor(NPC)<2 \
	&& (GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
		NPC.SetValue(OSMT,0)
		NPC.SetValue(OSMW,3)
		return
	endif
	if (GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) \
	&& NPC.GetItemCount(OSDCI)<1
		NPC.AddItem(OSDCI,1)
	endif
	
	NPC.SetValue(OSMT,GetCurrentGameTime())
	if !NPC.HasSpell(MSpell)
		NPC.SetValue(OSNPCV, OSV.GetValue())
		NPC.AddSpell(MSpell)
	endif
	SaveNPC(NPC)
	NPC.SetValue(OSMW,0)
endfunction

Function LoadNPC(Actor NPCv) Global

;	Var[] TempVal = New Var[0]
;	TempVal = GetCustomConfigOptions(OSData, IntToHexString(NPC.GetFormID()))
;	Var[] TempVal2=New Var[0]
;	TempVal2=VarToVarArray(TempVal[0])
;	if Tempval2.Length>0
;		LoadNPC(NPC)
;	
;	Var[] Function GetCustomConfigOptions(string fileName, string section) native global

	OutfitShuffler OS
	OS=GetFormFromFile(0x800, "outfitshuffler.esl") as OutfitShuffler
	Formlist XXSafe_Items = OS.XXSafeItems as Formlist
	Formlist XYSafe_Items = OS.XYSafeItems as Formlist
	Formlist OS_AllItems = OS.OSAllItems as Formlist
	Formlist Weapons_List = OS.WeaponsList as Formlist
	ActorValue OSMW = OS.OSMaintWait as ActorValue
	ActorValue OSMT = OS.OSMaintTime as ActorValue
	Outfit Empty_Outfit = OS.EmptyOutfit as Outfit
	String OSDataFile = OS.OSData as String
	NPCv.SetValue(OSMW,1)
	Var[] TempVal = New Var[0]
	Var[] NPCvKey = New Var[0]
	Var[] NPCvValue = New Var[0]
	TempVal = GetCustomConfigOptions(OSDataFile, IntToHexString(NPCv.GetFormID()))
	if TempVal!=None || TempVal.Length>0
		NPCvKey = VarToVarArray(TempVal[0])
		NPCvValue = VarToVarArray(TempVal[1])
	else
		NPCvKey.Add(0)
		NPCvValue.Add(0)
	endif

	If NPCvKey.Length>0
	;	UnequipItems(NPCv)
;Set outfit, weapon, and Misc items.
		Int i=0
		NPCv.SetOutfit(Empty_Outfit)
		While i<NPCvKey.Length
			if NPCvKey[i] as String=="Name"
				If NPCv.GetLeveledActorBase().GetName()!=NPCvValue[i] as String
					NPCv.GetLeveledActorBase().SetName(NPCvValue[i] as String)
				endif
				i+=1
			endif
			Form TempForm=GetFormFromFile(HexStringToInt(NPCvKey[i]),NPCvValue[i] as String)
			if TempForm!=None
				if !NPCv.IsEquipped(TempForm) &&(XYSafe_Items.HasForm(TempForm) || XXSafe_Items.HasForm(TempForm)||OS_AllItems.HasForm(TempForm)||Weapons_List.HasForm(TempForm)||IsDeviousDevice(TempForm))
					NPCv.EquipItem(TempForm)
				endif
			endif
			i+=1
		endwhile
	endif
	NPCv.SetValue(OSMT,GetCurrentGameTime())
	NPCv.SetValue(OSMW,0)
endfunction

bool Function IsInRestrictedFurniture(actor NPCv) global
	OutfitShuffler OS
	FormList RestrictedFurniture=GetFormFromFile(0x85f, "outfitshuffler.esl") as Formlist
	If NPCv.GetFurnitureReference()!=None
		if RestrictedFurniture.HasForm(NPCv.GetFurnitureReference().GetBaseObject())
			dlog(1,NPCv+NPCv.GetLeveledActorBase().GetName()+" is in restricted furniture "+NPCv.GetFurnitureReference().GetBaseObject().GetName())
			return false
		endif
	endif
endfunction