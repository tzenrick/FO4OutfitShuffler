Scriptname OutfitShuffler extends Quest
{Handles INI Scanning, and Radius Scanning.}

Import LL_FourPlay
Import Game
Import Utility
Import MCM
Import Math

Actor Property PlayerRef Auto
 
ActorValue Property OSMaintTime Auto
ActorValue Property OSMaintWait Auto
ActorValue Property OSNPCVersion Auto


FormList Property OSActorRaces Auto
FormList Property OSAllItems Auto
FormList Property OSFactionsToIgnore Auto
FormList Property OSGoodOutfits Auto
FormList Property OSRestrictedFurniture Auto
FormList Property OSWeaponsList Auto

FormList Property XXAccessory Auto
FormList Property XXArmAddon Auto
FormList Property XXBack Auto
FormList Property XXBackpack Auto
FormList Property XXBeard Auto
FormList Property XXBelt Auto
FormList Property XXBottom Auto
FormList Property XXEarrings Auto
FormList Property XXFront Auto
FormList Property XXFullBody Auto
FormList Property XXGlasses Auto
FormList Property XXHair Auto
FormList Property XXJacket Auto
FormList Property XXLeftArmArmor Auto
FormList Property XXLeftLegArmor Auto
FormList Property XXLegs Auto
FormList Property XXLongHair Auto
FormList Property XXMouth Auto
FormList Property XXNeck Auto
FormList Property XXRightArmArmor Auto
FormList Property XXRightLegArmor Auto
FormList Property XXRing Auto
Formlist Property XXSafeItems Auto
FormList Property XXShoes Auto
FormList Property XXShoulder Auto
FormList Property XXTop Auto
FormList Property XXTorsoArmor Auto
FormList Property XYAccessory Auto
FormList Property XYArmAddon Auto
FormList Property XYBack Auto
FormList Property XYBackpack Auto
FormList Property XYBeard Auto
FormList Property XYBelt Auto
FormList Property XYBottom Auto
FormList Property XYEarrings Auto
FormList Property XYFront Auto
FormList Property XYFullBody Auto
FormList Property XYGlasses Auto
FormList Property XYHair Auto
FormList Property XYJacket Auto
FormList Property XYLeftArmArmor Auto
FormList Property XYLeftLegArmor Auto
FormList Property XYLegs Auto
FormList Property XYLongHair Auto
FormList Property XYMouth Auto
FormList Property XYNeck Auto
FormList Property XYRightArmArmor Auto
FormList Property XYRightLegArmor Auto
FormList Property XYRing Auto
Formlist Property XYSafeItems Auto
FormList Property XYShoes Auto
FormList Property XYShoulder Auto
FormList Property XYTop Auto
FormList Property XYTorsoArmor Auto
GlobalVariable Property OSSuspend Auto
GlobalVariable Property OSVersion Auto
MiscObject Property OSAlwaysBodyGenItem Auto 
MiscObject Property OSAlwaysChangeItem Auto
MiscObject Property OSAlwaysScaleItem Auto
MiscObject Property OSDontBodyGenItem Auto
MiscObject Property OSDontChangeItem Auto
MiscObject Property OSDontScaleItem Auto
Outfit Property OSEmptyOutfit Auto
Quest Property MQ101WarNeverChanges Auto
Quest Property OutfitShufflerQuest Auto
Spell Property OSContainersSpell Auto
Spell Property OSMaintenanceSpell Auto
String Property OSLogFile Auto

;Property Arrays
FormList Property OSListForms auto
String[] Property OSListStrings auto

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
Int OSChanceXXAccessory
Int OSChanceXXArmAddon
Int OSChanceXXBack
Int OSChanceXXBackpack
Int OSChanceXXBeard
Int OSChanceXXBelt
Int OSChanceXXBottom
Int OSChanceXXEarrings
Int OSChanceXXFront
Int OSChanceXXFullBody
Int OSChanceXXGlasses
Int OSChanceXXHair
Int OSChanceXXJacket
Int OSChanceXXLeftArmArmor
Int OSChanceXXLeftLegArmor
Int OSChanceXXLegs
Int OSChanceXXLongHair
Int OSChanceXXMouth
Int OSChanceXXNeck
Int OSChanceXXRightArmArmor
Int OSChanceXXRightLegArmor
Int OSChanceXXRing
Int OSChanceXXShoes
Int OSChanceXXShoulder
Int OSChanceXXTop
Int OSChanceXXTorsoArmor
Int OSChanceXYAccessory
Int OSChanceXYArmAddon
Int OSChanceXYBack
Int OSChanceXYBackpack
Int OSChanceXYBeard
Int OSChanceXYBelt
Int OSChanceXYBottom
Int OSChanceXYEarrings
Int OSChanceXYFront
Int OSChanceXYFullBody
Int OSChanceXYGlasses
Int OSChanceXYHair
Int OSChanceXYJacket
Int OSChanceXYLeftArmArmor
Int OSChanceXYLeftLegArmor
Int OSChanceXYLegs
Int OSChanceXYLongHair
Int OSChanceXYMouth
Int OSChanceXYNeck
Int OSChanceXYRightArmArmor
Int OSChanceXYRightLegArmor
Int OSChanceXYRing
Int OSChanceXYShoes
Int OSChanceXYShoulder
Int OSChanceXYTop
Int OSChanceXYTorsoArmor

;Internal Vars
Int TimerID=888
String MasterINI = "OutfitShuffler.ini"
String INIpath = "OutfitShuffler\\" 
int dummyval=0
Int OSLongCounter=0

Event OnInit()
	if DummyVal
		Return
	endif
	dummyval+=1
	UpdateVars()
	PlayerRef.DispelSpell(OSContainersSpell)
	PlayerRef.RemoveSpell(OSContainersSpell)
	OSSuspend.SetValueInt(0)
	OSVersion.SetValue(9.1)
	dlog("OutfitShufflier Version: "+OSVersion.GetValue())
	debug.notification("OutfitShuffler Initialized")
	Self.StartTimer(OSShortTimer, TimerID)
EndEvent

Event OnTimer(Int TiD)
	UpdateVars()
	RegisterForPlayerTeleport()
	If !MQ101WarNeverChanges.IsCompleted()
		UnRegisterForPlayerTeleport()
		Wait(15.0)
		dlog("MQ101WarNeverChanges is not completed, waiting 15 seconds")
	endif
	If !OSModEnabled
		UnRegisterForPlayerTeleport()
		Wait(15.0)
		dlog("Mod is not enabled, waiting 15 seconds")
	endif
	
	While OSSuspend.GetValueInt() > 0
		UnRegisterForPlayerTeleport()
		Wait(1)	
	endWhile
	
	;diag
	Wait(OSShortTimer)
	If OSAllItems.GetSize()<1
		RescanOutfitsINI()
	endif
	If !PlayerRef.HasSpell(OSContainersSpell)&&(OSContainerLootChance>0||OSDeadBodyLootChance>0)
		PlayerRef.AddSpell(OSContainersSpell)
		dlog("Player did not have OSContainersSpell, adding it")
	endif
	DummyVal=0
	TimerTrap()
endEvent

Function TimerTrap()
	UpdateVars()
		
	While OSSuspend.GetValueInt() > 0
		dlog("In TimerTrap() while Suspended")
		Wait(5)
	endWhile
	
	If OSLongCounter>OSLongTimer
		dlog("OSLongCounter("+OSLongCounter+") is greater than OSLongTimer("+OSLongTimer+"): resetting")
		OSLongCounter=0
	endif
	OSLongCounter+=1

	ScanNPCs()

	Self.StartTimer(OSShortTimer, TimerID)
EndFunction

Function BuildOutfitArray()
	OSNPCData.Clear()
	OSNPCid.Clear()
	dlog("Building Outfit Array",1)
	OSSuspend.SetValueInt(1)
	float RescanTimer=GetCurrentRealTime()
	UpdateVars()
	OSAllItems.Revert()
	OSListForms.Revert()
	OSListStrings.Clear()
	OSListForms.AddForm(XXAccessory)
	OSListStrings.Add("XXAccessory")
	OSListForms.AddForm(XXArmAddon)
	OSListStrings.Add("XXArmAddon")
	OSListForms.AddForm(XXBack)
	OSListStrings.Add("XXBack")
	OSListForms.AddForm(XXBackpack)
	OSListStrings.Add("XXBackpack")
	OSListForms.AddForm(XXBeard)
	OSListStrings.Add("XXBeard")
	OSListForms.AddForm(XXBelt)
	OSListStrings.Add("XXBelt")
	OSListForms.AddForm(XXBottom)
	OSListStrings.Add("XXBottom")
	OSListForms.AddForm(XXEarrings)
	OSListStrings.Add("XXEarrings")
	OSListForms.AddForm(XXFront)
	OSListStrings.Add("XXFront")
	OSListForms.AddForm(XXFullBody)
	OSListStrings.Add("XXFullBody")
	OSListForms.AddForm(XXGlasses)
	OSListStrings.Add("XXGlasses")
	OSListForms.AddForm(XXHair)
	OSListStrings.Add("XXHair")
	OSListForms.AddForm(XXJacket)
	OSListStrings.Add("XXJacket")
	OSListForms.AddForm(XXLeftArmArmor)
	OSListStrings.Add("XXLeftArmArmor")
	OSListForms.AddForm(XXLeftLegArmor)
	OSListStrings.Add("XXLeftLegArmor")
	OSListForms.AddForm(XXLegs)
	OSListStrings.Add("XXLegs")
	OSListForms.AddForm(XXLongHair)
	OSListStrings.Add("XXLongHair")
	OSListForms.AddForm(XXMouth)
	OSListStrings.Add("XXMouth")
	OSListForms.AddForm(XXNeck)
	OSListStrings.Add("XXNeck")
	OSListForms.AddForm(XXRightArmArmor)
	OSListStrings.Add("XXRightArmArmor")
	OSListForms.AddForm(XXRightLegArmor)
	OSListStrings.Add("XXRightLegArmor")
	OSListForms.AddForm(XXRing)
	OSListStrings.Add("XXRing")
	OSListForms.AddForm(XXSafeItems)
	OSListStrings.Add("XXSafeItems")
	OSListForms.AddForm(XXShoes)
	OSListStrings.Add("XXShoes")
	OSListForms.AddForm(XXShoulder)
	OSListStrings.Add("XXShoulder")
	OSListForms.AddForm(XXTop)
	OSListStrings.Add("XXTop")
	OSListForms.AddForm(XXTorsoArmor)
	OSListStrings.Add("XXTorsoArmor")
	OSListForms.AddForm(XYAccessory)
	OSListStrings.Add("XYAccessory")
	OSListForms.AddForm(XYArmAddon)
	OSListStrings.Add("XYArmAddon")
	OSListForms.AddForm(XYBack)
	OSListStrings.Add("XYBack")
	OSListForms.AddForm(XYBackpack)
	OSListStrings.Add("XYBackpack")
	OSListForms.AddForm(XYBeard)
	OSListStrings.Add("XYBeard")
	OSListForms.AddForm(XYBelt)
	OSListStrings.Add("XYBelt")
	OSListForms.AddForm(XYBottom)
	OSListStrings.Add("XYBottom")
	OSListForms.AddForm(XYEarrings)
	OSListStrings.Add("XYEarrings")
	OSListForms.AddForm(XYFront)
	OSListStrings.Add("XYFront")
	OSListForms.AddForm(XYFullBody)
	OSListStrings.Add("XYFullBody")
	OSListForms.AddForm(XYGlasses)
	OSListStrings.Add("XYGlasses")
	OSListForms.AddForm(XYHair)
	OSListStrings.Add("XYHair")
	OSListForms.AddForm(XYJacket)
	OSListStrings.Add("XYJacket")
	OSListForms.AddForm(XYLeftArmArmor)
	OSListStrings.Add("XYLeftArmArmor")
	OSListForms.AddForm(XYLeftLegArmor)
	OSListStrings.Add("XYLeftLegArmor")
	OSListForms.AddForm(XYLegs)
	OSListStrings.Add("XYLegs")
	OSListForms.AddForm(XYLongHair)
	OSListStrings.Add("XYLongHair")
	OSListForms.AddForm(XYMouth)
	OSListStrings.Add("XYMouth")
	OSListForms.AddForm(XYNeck)
	OSListStrings.Add("XYNeck")
	OSListForms.AddForm(XYRightArmArmor)
	OSListStrings.Add("XYRightArmArmor")
	OSListForms.AddForm(XYRightLegArmor)
	OSListStrings.Add("XYRightLegArmor")
	OSListForms.AddForm(XYRing)
	OSListStrings.Add("XYRing")
	OSListForms.AddForm(XYSafeItems)
	OSListStrings.Add("XYSafeItems")
	OSListForms.AddForm(XYShoes)
	OSListStrings.Add("XYShoes")
	OSListForms.AddForm(XYShoulder)
	OSListStrings.Add("XYShoulder")
	OSListForms.AddForm(XYTop)
	OSListStrings.Add("XYTop")
	OSListForms.AddForm(XYTorsoArmor)
	OSListStrings.Add("XYTorsoArmor")
	OSListForms.AddForm(OSWeaponsList)
	OSListStrings.Add("WeaponsList")
	OSListForms.AddForm(OSRestrictedFurniture)
	OSListStrings.Add("OSRestrictedFurniture")
	int i=0
	while i<OSListForms.GetSize()
		(OSListForms.GetAt(i) as FormList).Revert()
		i+=1
	endwhile
	OSSuspend.SetValueInt(0)
	dlog("Outfit Array built in "+(GetCurrentRealTime()-RescanTimer)+" seconds.",1)
endfunction

Function RescanOutfitsINI()
	OSSuspend.SetvalueInt(1)
	BuildOutfitArray()
	float RescanTimer=GetCurrentRealTime()
	dLog("Rescanning outfit pieces",1)
	int AllSlotsCounter = 0
	int counter=0

;Get Outfit INI Files
	Var[] ConfigOptions=GetCustomConfigOptions(MasterINI, "InputFiles")
	Var[] Keys=VarToVarArray(ConfigOptions[0])
	int j=0
	While j<Keys.Length
		int ConfigOptionsInt=GetCustomConfigOption_UInt32(MasterINI, "InputFiles", Keys[j]) as int
		if ConfigOptionsInt > 0
			ScanINI(Keys[j])
		endif
	j += 1
	endwhile
	int FormListSize=OSListForms.GetSize()
	dlog("ScanINI() building parts chance array. "+FormListSize+" FormLists in FormList")
	counter=0
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
					Form TempForm=GetFormFromFile(FormToAdd,RaceKeys[j])
					dlog(TempForm+" Added to Races")
					OSActorRaces.AddForm(TempForm)
				endif
			j += 1
			endwhile
		endif
	endif
;Get OSFactionsToIgnore; Updated to Understand Hex
	ConfigOptions=GetCustomConfigOptions(MasterINI, "FactionsToIgnore")
	if ConfigOptions.Length>0
		Var[] OSFactionsToIgnoreKeys=VarToVarArray(ConfigOptions[0])
		Var[] OSFactionsToIgnoreValues=VarToVarArray(ConfigOptions[1])
		j=0
		OSFactionsToIgnore.Revert()
		int FormToAdd
		if OSFactionsToIgnoreKeys.Length>0
			While j<OSFactionsToIgnoreKeys.Length
				if StringFind(OSFactionsToIgnoreValues[j],"0x")>-1
					string[] FormToAddLeft=StringSplit(OSFactionsToIgnoreValues[j],";")
					string[] FormToAddHex=StringSplit(FormToAddLeft[0],"x")
					FormToAdd=HexStringToInt("0x"+FormToAddHex[1]) as Int
					dlog("FactionsToIgnores: hex "+FormToAdd)
				else
					FormToAdd=OSFactionsToIgnoreValues[j] as int
					dlog("FactionsToIgnores: int "+FormToAdd)
				endif
				Form TempForm=GetFormFromFile(FormToAdd,OSFactionsToIgnoreKeys[j])
				if TempForm != None
					dlog(TempForm+" Added to FactionsToIgnores")
					OSFactionsToIgnore.AddForm(TempForm)
				endif
			j += 1
			endwhile
		endif
	endif
	;ListPartCounts()
	dlog("Outfit Scan completed in "+(GetCurrentRealTime()-RescanTimer)+" seconds.",1)
	OSSuspend.SetValueInt(0)
endfunction

Function ScanINI(String INItoCheck)	
	String INIFile=INIpath+INItoCheck
	int ScanINICounter
	If Game.IsPluginInstalled(StringSubstring(INIToCheck, 0, StringFind(INIToCheck, ".ini", 0))) || INIToCheck == "Weapons.ini"
		String[] ChildINISections=GetCustomConfigSections(INIFile) as String[]
		int ChildINISectionCounter=0
		int WholeINI
		if ChildINISections.Length > 0
			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=VarToVarArray(ChildConfigOptions[0])
				WholeINI += ChildKeys.Length
				ChildINISectionCounter+=1
			endwhile
		endif
		ChildINISectionCounter=0
		if (ChildINISections.Length > 0)
			Int ProgressCounter=0
			dlog("ScanINI() Adding "+INIFile,1)
 			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=VarToVarArray(ChildConfigOptions[0])
				Var[] ChildValues=VarToVarArray(ChildConfigOptions[1])
				
				If (ChildKeys.Length > 0)  && (StringFind(ChildINISections[ChildINISectionCounter],"Disabled")==-1)
					int ChildKeysCounter=0
					While ChildKeysCounter < ChildKeys.Length
						string FormToAdd=ChildValues[ChildKeysCounter] as String
						Int FormValue=0
						If StringFind(FormToAdd, "x", 0)>0
							FormToAdd=StringSubstring(FormToAdd,2)
							FormValue=HexStringToInt(FormToAdd)
						elseif ChildValues[ChildKeysCounter] as int > 0
							FormValue=(ChildValues[ChildKeysCounter] as int)
						endif
						Int SectionIndex=OSListStrings.Find(ChildINISections[ChildINISectionCounter])
				
						If SectionIndex > -1
							Form TempItem=Game.GetFormFromFile(FormValue,ChildKeys[ChildKeysCounter])
							FormList TempList=OSListForms.GetAt(SectionIndex) as FormList
							if TempItem!=None && TempList!=OSRestrictedFurniture
								TempList.AddForm(TempItem)
								If OSAllItems.Find(TempItem)==-1
									OSAllItems.AddForm(TempItem)
								endif
								ProgressCounter+=1
								Float ProgressPercentage=(ProgressCounter*100 as Float)/(WholeINI as Float)
								Int ProgressPercentageRounded=ProgressPercentage as int
								If ProgressPercentageRounded%10==0&&WholeINI>50
									debug.notification("[OS]"+INIFile+" "+ProgressPercentageRounded+"% complete")
								endif
							endif
							ScanINICounter+=1
						endIf
						ChildKeysCounter += 1
					endwhile
				
				endif
			ChildINISectionCounter += 1
			endwhile
		endif
	endif
endFunction

Event OnPlayerTeleport()
	dlog("OnPlayerTeleport() Clearing kActorArray, ActorInArray, ActorOutArray and RaceCounter")
	kActorArray=None
	ActorInArray=None
	ActorOutArray=None
	RaceCounter=999999
EndEvent

int RaceCounter
int CountActors
String ActorsList
ObjectReference[] kActorArray
ObjectReference[] ActorInArray
ObjectReference[] ActorOutArray

function ScanNPCs()
	UpdateVars()
	While OSSuspend.GetValueInt() > 0
		dlog("In ScanNPCs() while Suspended")
		Wait(5)
	endWhile

	CountActors = 0
	RaceCounter = 0
	ActorsList = ""
	ActorInArray=New ObjectReference[0]
	ActorOutArray=New ObjectReference[0]
	While RaceCounter < OSActorRaces.GetSize()
		int iActorArray = 0
		if OSActorRaces.GetAt(RaceCounter) != None
			kActorArray = PlayerRef.FindAllReferencesWithKeyword(OSActorRaces.GetAt(RaceCounter),OSScanningDistance)
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
		If CheckEligibility(NPC)
			;dlog("ScanNPCs()-Adding Maintenance Spell to "+(iActorArray)+"/"+ActorOutArray.Length+" "+NPC+NPC.GetLeveledActorBase().GetName())
			CountActors += 1
			ActorsList += "("+iActorArray+")"+NPC.GetLeveledActorBase().GetName()+", "
			NPC.SetValue(OSMaintWait,0)
			NPC.SetValue(OSMaintTime,GetCurrentGameTime())
			If !NPC.HasSpell(OSMaintenanceSpell)
				NPC.AddSpell(OSMaintenanceSpell)
			endif
		endif
	iActorArray+=1
	endwhile
	;iActorArray=0
	String LogTemp="Total Outfit Items="+OSAllItems.GetSize()+" ======== ScanNPCs()-Processed "+CountActors+" Actors: "+ActorsList+" ======== OSNPCid Records: "+OSNPCid.Length+"\n"
	;While iActorArray<OSNPCid.Length
	;	LogTemp+=(GetForm(HexStringToInt(OSNPCid[iActorArray])) as Actor).GetLeveledActorBase().GetName()+" NPCid="+OSNPCid[iActorArray]+" NPCdata="+OSNPCdata[iActorArray]+"\n"
	;	iActorArray+=1
	;endwhile
	dlog(LogTemp)
endFunction

bool Function IsInRestrictedFurniture(Actor NPC)
	If NPC.GetFurnitureReference()!=None
		if OSRestrictedFurniture.HasForm(NPC.GetFurnitureReference().GetBaseObject())
			return true
		endif
	endif
	return false
endfunction

Bool Function CheckEligibility(Actor NPC)
	If NPC.GetValue(OSMaintWait)==999||NPC.GetValue(OSMaintTime)==999||NPC.GetValue(OSNPCVersion)>OSVersion.GetValue()
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		ResetNPC(NPC)
		NPC.AddSpell(OSMaintenanceSpell)
		return true
	endif
	If NPC.GetValue(OSMaintWait) > 0
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is already busy.")
		return false
	endif
	If IsInRestrictedFurniture(NPC)
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is in restricted furniture.")
		return false
	endif

	If NPC.HasSpell(OSMaintenanceSpell) && NPC.GetValue(OSNPCVersion)!=OSVersion.GetValue() && !(NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled());
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		NPC.AddSpell(OSMaintenanceSpell)
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		dlog(NPC.GetLeveledActorBase().GetName()+NPC+" has an outdated version of OS. Updating.")
		return false
	endif

	If NPC.IsDead()
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is dead.")
		return false
	endif

	If NPC.IsDisabled()
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is disabled.")
		return false
	endif

	if NPC.IsDeleted()
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is deleted.")
		return false
	endif

	if NPC.IsChild()
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is a child.")
		return false
	endif

	if NPC==PlayerRef
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog("Skipping Player")
		return false
	endif
	
	if (NPC.GetLeveledActorBase().GetSex()==1&&!OSXXEnabled)||(NPC.GetLeveledActorBase().GetSex()==0&&!OSXYEnabled)
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is disabled by gender.")
		return false
	endif

	if StringFind(NPC.GetLeveledActorBase().GetName(), "Armor Rack") != -1
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. Armor Rack.")
		return false
	endif
	
	if StringFind(NPC.GetLeveledActorBase().GetName(), "Wilma's Wigs") != -1
		NPC.Setvalue(OSMaintTime,0)
		NPC.Setvalue(OSMaintWait,0)
		if NPC.HasSpell(OSMaintenanceSpell)
			NPC.RemoveSpell(OSMaintenanceSpell)
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. Wilma's Wigs.")
		return false
	endif

	if PlayerRef.GetDistance(NPC)>OSScanningDistance
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. Out of range.")
		return false
	endif

;check against AAF if enabled
	If IsPluginInstalled("AAF.esm")
		if NPC.HasKeyword(GetFormFromFile(0x00915a, "AAF.esm") as Keyword);AAF_Actor
			;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. AAF Actor.")
			return false
		endif
	endif
		
	If NPC.GetItemCount(OSAlwaysChangeItem)>0
		If NPC.GetItemCount(OSDontChangeItem)>0
			NPC.RemoveItem(OSDontChangeItem,-1)
			;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is removing extraneous OSDontChangeItem.")
		endif
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is eligible for maintenance. OSAlwaysChangeItem.")
		return True
	endif

	If (NPC.GetItemCount(OSDontChangeItem)>0)
		;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. OSDontChangeItem.")
		return False
	endif

;check against restricted factions
	If OSFactionsToIgnore.GetSize()>0
		Int i
		While i<OSFactionsToIgnore.GetSize()
			If NPC.IsInFaction(OSFactionsToIgnore.GetAt(i) as Faction)
				;dlog(NPC.GetLeveledActorBase().GetName()+NPC+" is not eligible for maintenance. Restricted Faction.")
				return False
			endif
		i += 1
		Endwhile
	endif
;if we didn't catch anything, return true	
	return true
endFunction

ObjectReference[] Function SortByDistance(ObjectReference[] ActorArray, Float[] distance, String Width)
	int iActorArrayCounter
	int i = 0
	int j
	int minIndex
	ObjectReference tempActor
	Float tempDistance
	while i < actorArray.Length
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
	While i<ActorInActorArray.Length;9.0  While i<ActorInActorArray.Length-1
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
	Front2=SortByDistance(Front, FrontDistance, "Front")
	Wide2=SortByDistance(Wide, WideDistance, "Wide")
	Rest2=SortByDistance(Rest, RestDistance, "Rest")
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

Function ListPartCounts()
	int i
	while i<OSListForms.GetSize()
		dlog(OSListForms.GetAt(i)+"="+(OSListForms.GetAt(i) as FormList).GetSize()+" items",0)
		i+=1
	endwhile
	dlog("Total Outfit Items="+OSAllItems.GetSize())
endfunction

Function UpdateVars()
	OSLogFile = "OutfitShuffler"
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
endfunction

Function DisplayVars()
	UpdateVars()
	dlog("OSModEnabled: " + OSModEnabled)
	dlog("OSXXEnabled: " + OSXXEnabled)
	dlog("OSXYEnabled: " + OSXYEnabled)
	dlog("OSOutfitOneShot: " + OSOutfitOneShot)
	dlog("OSBodyGenOneShot: " + OSBodyGenOneShot)
	dlog("OSNoNudes: " + OSNoNudes)
	dlog("OSRandomBodyGen: " + OSRandomBodyGen)
	dlog("OSBodyGenOneShot: " + OSBodyGenOneShot)
	dlog("OSNPCUseScaling: " + OSNPCUseScaling)
	dlog("OSAllowDLC: " + OSAllowDLC)
	dlog("OSNPCMinScale: " + OSNPCMinScale)
	dlog("OSNPCMaxScale: " + OSNPCMaxScale)
	dlog("OSContainerLootChance: " + OSContainerLootChance)
	dlog("OSDeadBodyLootChance: " + OSDeadBodyLootChance)
	dlog("OSLootItemsMax: " + OSLootItemsMax)
	dlog("OSScanningDistance: " + OSScanningDistance)
	dlog("OSShortTimer: " + OSShortTimer)
	dlog("OSLongTimer: " + OSLongTimer)
	dlog("OSChanceWeapons: " + OSChanceWeapons)
endfunction
	
Bool Function IsActorAAFBusy(Actor NPC) global
	Keyword AAFBusyKeyword
	If IsPluginInstalled("AAF.esm")
		AAFBusyKeyword = GetFormFromFile(0x00915a, "AAF.esm") as Keyword
	elseif AAFBusyKeyword && !NPC.HasKeyword(AAFBusyKeyword)
		Return True
	elseif AAFBusyKeyword == None
		Return True
	endif
	Return False
endfunction

bool Function IsDeviousDevice(Form akItem) global
	If IsPluginInstalled("Devious Devices.esm")
		if akItem.HasKeyword(GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword)||akItem.HasKeyword(GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword)
			return true
		endif
	endif
	return False
endfunction

FormList Function SafeItems(Actor NPC)
	If NPC.GetLeveledActorBase().GetSex()==0;MaleXY
		Return XYSafeItems
	endif
	If NPC.GetLeveledActorBase().GetSex()==1;FemaleXX
		Return XXSafeItems
	endif
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

function ResetNPC(Actor NPC)
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
	NPC.UnequipAll()
	DD:DD_Library DDLib
	Form[] InvItems = NPC.GetInventoryItems()
	int i
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

	NPC.SetValue(OSMaintTime,GetCurrentGameTime())
	NPC.SetValue(OSMaintWait,999)
endfunction

bool Function PowerArmorCheck(Actor NPC) Global
	if NPC.IsInPowerArmor()
		return True
	endif
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

function SpawnCaptive()
	if IsPluginInstalled("Commonwealth Captives.esp")
		ScriptObject CCMain = GetFormFromFile(0x2ecb,"Commonwealth Captives.esp") as ScriptObject
		Var[] Temp=New Var[1]
		Temp[0]=PlayerRef as Actor
		CCMain.CallFunction("CreateCaptive", Temp)
		dlog("Placing Commonwealth Captives captive",1)
	else
		Form TempCaptive = Game.GetPlayer().PlaceAtMe(GetFormFromFile(0x14CEA9,"Fallout4.esm"),1)
		dlog("Placing random female settler ["+TempCaptive.GetFormID()+"]",1)
	endif
endfunction

Function dLog(string LogMe, Int Severity=0, String AltShort="", String AltLong="") global
	String OS_LogName = "OutfitShuffler"
	If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int>0
		Debug.OpenUserLog(OS_LogName)
		If AltShort+AltLong==""
			AltLong="[..Shuffler]"
			AltShort="[OS]"
		endif
		If GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
			debug.TraceUser(OS_LogName, AltLong+LogMe,Severity)
		endif
	endif
	If Severity > 0
		debug.Notification(AltShort+LogMe)
		PrintConsole(AltShort+LogMe)
	endif
endfunction

Function DebugNPC(String NPCString="")
	Actor NPC
	if NPCString==""
		NPC=GetForm(HexStringToInt(NPCString)) as Actor
	else
		NPC = LastCrossHairActor()
	endif
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
		float MaintTimer=OSLongTimer*OSShortTimer*0.00069
		String DebugLogString="\n   ***************DebugNPC()***************"
		DebugLogString+="\n   ***************Name:"+NPC+NPC.GetLeveledActorBase().GetName()
		DebugLogString+="\n   ****************Sex:"+NPCSex
		DebugLogString+="\n   ***************Race:"+NPC.GetLeveledActorBase().GetRace()
		DebugLogString+="\n   **DC/AC-DS/AS-DB/AB:"+(NPC.GetItemCount(OSDontChangeItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysChangeItem) as Bool)+"-"+(NPC.GetItemCount(OSDontScaleItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysScaleItem) as Bool)+"-"+(NPC.GetItemCount(OSDontBodyGenItem) as Bool)+"/"+(NPC.GetItemCount(OSAlwaysBodyGenItem) as Bool)
		DebugLogString+="\n   **********IsDeleted:"+NPC.IsDeleted() as Bool
		DebugLogString+="\n   *********IsDisabled:"+NPC.IsDisabled() as Bool
		DebugLogString+="\n   ****PowerArmorCheck:"+PowerArmorCheck(NPC) as Bool
		DebugLogString+="\n   ************IsChild:"+NPC.IsChild() as Bool
		DebugLogString+="\n   *************IsDead:"+NPC.IsDead() as Bool
		DebugLogString+="\n   ***********Distance:"+NPC+PlayerRef.GetDistance(NPC) as Int
		DebugLogString+="\n   ****OSMaintenanceSpellSpell="+NPC.HasSpell(OSMaintenanceSpell) as Bool
		DebugLogString+="\n   ********OSMaintWait="+NPC.Getvalue(OSMaintWait) as Bool
		DebugLogString+="\n   *******OSMaintTime+="+NPC.GetValue(OSMaintTime)+"  MaintTimer="+MaintTimer
		DebugLogString+="\n   ********CurrentTime="+GetCurrentGameTime()
		DebugLogString+="\n   *************Outfit="+NPC.GetLeveledActorBase().Getoutfit()+NPC.GetLeveledActorBase().Getoutfit().GetName()
		DebugLogString+="\n"+longinv+"\n"
		If OSFactionsToIgnore.GetSize()
			i=0
			While i<OSFactionsToIgnore.GetSize()
				If NPC.IsInFaction(OSFactionsToIgnore.GetAt(i) as Faction)
					DebugLogString+="\n   ***OSFactionsToIgnore:"+NPC+" is in "+OSFactionsToIgnore.GetAt(i)
				endif
			i += 1
			Endwhile
		endif
		DebugLogString+="\n   ************Finish DebugNPC()***********"
		dlog(DebugLogString,1)
	endif
endfunction

Function ChangeNow()
;	DebugLogString+="In ChangeNow()")
	UpdateVars()
	Actor NPC = LastCrossHairActor()
	If NPC != None
		dlog(NPC+""+NPC.GetLeveledActorBase().GetName()+"'s OUTFIT will be changed ASAP!",1)
		NPC.SetValue(OSMaintWait, 999)
		NPC.SetValue(OSMaintTime, 999)
		NPC.SetValue(OSNPCVersion, 999)
	endif
endfunction

Function DontChange()
	Actor NPC = LastCrossHairActor()
	If NPC != None
		If (NPC.GetItemCount(OSDontChangeItem)>0)
			NPC.RemoveItem(OSDontChangeItem,-1)
			NPC.AddItem(OSAlwaysChangeItem)
			dLog(NPC.GetLeveledActorBase().GetName()+" will ignore faction exclusions.",1)
			return
		endif
		If (NPC.GetItemCount(OSAlwaysChangeItem)>0)
			NPC.RemoveItem(OSAlwaysChangeItem,-1)
			dLog(NPC.GetLeveledActorBase().GetName()+" WILL be changed.",1)
			return
		endif
		NPC.AddItem(OSDontChangeItem,1,true)
		dLog(NPC.GetLeveledActorBase().GetName()+" WILL NOT be changed.",1)
	endif
EndFunction

Function MCMBodyGen()
	Actor NPC = LastCrossHairActor()
	If NPC != None
		dlog(NPC+""+NPC.GetLeveledActorBase().GetName()+"'s BODY will be changed immediately",1)
		BodyGen.RegenerateMorphs(NPC, true)
		float NPCNewScale
		if (GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float) >= (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float)
			NPCNewScale=(GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float)
		else
			NPCNewScale = RandomFloat((GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float), (GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float))
		endif
		If OSBodyGenOneShot==1&&NPC.GetItemCount(OSAlwaysBodyGenItem)==0
			NPC.AddItem(OSDontBodyGenItem,1,true)	
		endif
		NPC.SetScale(NPCNewScale)
	endif
endFunction