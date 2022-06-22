Scriptname OutfitShuffler extends Quest
;****************************************************************************************************************
;Imported Properties from ESP
Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory
Outfit Property EmptyOutfit Auto Const
Outfit Property EmptyOutfit2 Auto Const
Formlist Property ActorRaces Auto
Formlist Property FactionsToIgnore Auto
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const
Formlist Property WeaponsList Auto
Formlist Property Hair Auto
Formlist Property LongHair Auto
Formlist Property FullBody Auto
Formlist Property Shoes Auto
Formlist Property ArmAddon Auto
Formlist Property Jacket Auto
Formlist Property Top Auto
Formlist Property Legs Auto
Formlist Property Bottom Auto
Formlist Property TorsoArmor Auto
Formlist Property LeftArmArmor Auto
Formlist Property RightArmArmor Auto
Formlist Property LeftLegArmor Auto
Formlist Property RightLegArmor Auto
Formlist Property Earrings Auto
Formlist Property Glasses Auto
Formlist Property Beard Auto
Formlist Property Neck Auto
Formlist Property Ring Auto
Formlist Property Backpack Auto
Formlist Property Belt Auto
Formlist Property Shoulder Auto
Formlist Property Back Auto
Formlist Property Front Auto
Formlist Property Accessory Auto
FormList Property SafeItems Auto
Keyword Property DontChange Auto Const
float Property ShortTime Auto
int Property LongMult Auto
float Property ScanRange Auto
bool Property Logging Auto
;****************************************************************************************************************
;Initialize a few variables
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
Bool modEnabled
Bool DressTheDead
Bool RescanOutfits
Bool UseAAF
FormList[] PForm
String[] PString
Int[] PChance
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
;****************************************************************************************************************
;****************************************************************************************************************
;****************************************************************************************************************
Event OnInit()
	dlog("OutfitShuffler Installed")
	debug.notification("[OutfitShuffler] Installed")
	CountParts()
	starttimer(ShortTime, ShortTimerID)
	GetMCMSettings()
EndEvent
;****************************************************************************************************************
;Catch timer events
Event OnTimer(int aiTimerID)
	dlog("In OnTimer()")
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	If OutfitPartsAdder<1
		RescanOutfitsINI()
	endif
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			if modEnabled
				dlog("Timer:"+MultCounter+"/"+LongMult)
				TimerTrap()
			endif
		endif
	endif
EndEvent
;****************************************************************************************************************
;****************************************************************************************************************
;****************************************************************************************************************
Function TimerTrap()
	CancelTimer(ShortTimerID)
	dlog("In TimerTrap()")
	GetMCMSettings()
	AAF_ActiveActors = Game.GetFormFromFile(0x0098f4, "AAF.esm") as FormList
	AAF_Doppelganger = Game.GetFormFromFile(0x0072E2, "AAF.esm") as ActorBase
	AAF_EmptyOutfit = Game.GetFormFromFile(0x02b47d, "AAF.esm") as Outfit
	if AAF_EmptyOutfit != None
		If !GoodOutfits.HasForm(AAF_EmptyOutfit)
			dlog("Adding AAF_EmptyOutfit.")
			GoodOutfits.AddForm(AAF_EmptyOutfit)
		endif
	endif
	If AAFBusyKeyword == None
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
	endif
	If AAFBusyKeyword != None
		UseAAF = True
	endif
	bool Force = False
	if MultCounter > LongMult-1
		Force = True
		debug.notification("[OutfitShuffler] Changing All Outfits...")
		MultCounter = 1
	else
		MultCounter += 1
	endif
	ScanNPCs(Force)
	StartTimer(ShortTime, ShortTimerID)
endFunction
;****************************************************************************************************************
function ScanNPCs(bool Force=False)
	dlog("In ScanNPCs()")
	CountParts()
	int racecounter = 0
	While racecounter < ActorRaces.GetSize()
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(ActorRaces.GetAt(racecounter), ScanRange)
		while i < kActorArray.Length
			Actor NPC = kActorArray[i] as Actor
			if CheckEligibility(NPC)
				if Force
					dlog(i+"/"+kActorArray.length+""+NPC+NPC.GetLeveledActorBase().GetName()+":is being forced")
					SetSettlerOutfit(NPC)
				endif
				if !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					dlog(i+"/"+kActorArray.length+""+NPC+NPC.GetLeveledActorBase().GetName()+":needs an outfit")
					SetSettlerOutfit(NPC)
				endif
			else
				if GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					dlog(i+"/"+kActorArray.length+""+NPC+NPC.GetLeveledActorBase().GetName()+":is wearing a good outfit")
					ReEquipItems(NPC)	
				endif
			endif
			i += 1
		endwhile
		RaceCounter += 1
	endwhile
endFunction
;****************************************************************************************************************
Function CountParts()
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	dlog("=============================== "+OutfitPartsAdder+" items in outfit parts lists.")
endfunction
;****************************************************************************************************************
Function SetSettlerOutfit(Actor NPC)
	dlog("In SetSettlerOutfit()")
	if CheckEligibility(NPC)
		dlog(NPC+" is being sent to UnequipItems")
		UnEquipItems(NPC)
		dlog(NPC+" Setting outfit "+EmptyOutfit)
		NPC.SetOutfit(EmptyOutfit2,false)
		NPC.SetOutfit(EmptyOutfit,false)
		SetOutfitFromParts(NPC)
	endif
EndFunction
;****************************************************************************************************************
Function SetOutfitFromParts(Actor NPC)
	dlog("In SetOutfitParts()")
	If Utility.RandomInt(1,99)<PChance[PString.Find("FullBody")] && PForm[PString.Find("FullBody")].GetSize()>0
		NPC.Equipitem(PForm[PString.Find("FullBody")].GetAt(Utility.RandomInt(0,PForm[PString.Find("FullBody")].GetSize())))
	else
		Int Counter=1
		While counter < PForm.Length
			If PChance[Counter]>1
				If PForm[Counter].GetSize()>0
					If Utility.RandomInt(1,99)<PChance[counter]
						Form RandomItem = PForm[counter].GetAt(Utility.RandomInt(0,PForm[Counter].GetSize())) as Form
						If RandomItem != None
							NPC.Equipitem(RandomItem)
;								int SafeCounter = 0
;								While SafeCounter<SafeItems.GetSize()
;									dlog("Scanning for SafeItems "+(Safecounter+1)+"/"+SafeItems.GetSize()+"    ===SI    "+SafeItems.GetAt(SafeCounter)+" "+SafeItems.GetAt(SafeCounter).GetName()+"    ===RI    "+RandomItem+RandomItem.GetName())
;									If NPC.IsEquipped(Safeitems.GetAt(SafeCounter))
;										dlog(NPC+" Comparing "+RandomItem+" to "+SafeItems.GetAt(SafeCounter))
;										if !OverwriteSafeItems(SafeItems.GetAt(SafeCounter) as Armor, RandomItem as Armor)
;											NPC.Equipitem(RandomItem)
;											;Dlog(RandomItem+" Would have Unequipped "+SafeItems.GetAt(SafeCounter))
;										endif
;									endif
;								SafeCounter += 1
;								Endwhile
						endif
					endif
				endif
			endif
		counter += 1
		endwhile
	endif
	If NPC.IsDead()
		NPC.AddKeyword(DontChange)
	endif
endfunction
;****************************************************************************************************************
;bool Function OverwriteSafeItems(Armor OldItem, Armor NewItem)
;	dlog("In Bool OverwriteSafeItems()")
;	int slots = OldItem.GetSlotMask()
;	int counter=0
;	int[] OldItemOutVal = new Int[32]
;	While counter<32
;		int tempx = Math.LeftShift(slots, counter)
;		int tempy=1
;		if tempx>0xEFFFFFFF
;			tempy=0			
;		endif
;		OldItemOutVal[Counter]=TempY
;		counter += 1
;	endwhile
;	
;	slots = NewItem.GetSlotMask()
;	counter=0
;	int[] NewItemOutVal = new Int[32]
;	While counter<32
;		int tempx = Math.LeftShift(slots, counter)
;		int tempy=1
;		if tempx>0xEFFFFFFF
;			tempy=0			
;		endif
;		NewItemOutVal[Counter]=TempY
;		counter += 1
;	endwhile
;	
;Dlog(OldItem+":"+OldItemOutVal[0]+""+OldItemOutVal[1]+""+OldItemOutVal[2]+""+OldItemOutVal[3]+""+OldItemOutVal[4]+""+OldItemOutVal[5]+""+OldItemOutVal[6]+""+OldItemOutVal[7]+\
;	""+OldItemOutVal[8]+""+OldItemOutVal[9]+""+OldItemOutVal[10]+""+OldItemOutVal[11]+""+OldItemOutVal[12]+""+OldItemOutVal[13]+""+OldItemOutVal[14]+""+OldItemOutVal[15]+\
;	""+OldItemOutVal[16]+""+OldItemOutVal[17]+""+OldItemOutVal[18]+""+OldItemOutVal[19]+""+OldItemOutVal[20]+""+OldItemOutVal[21]+""+OldItemOutVal[22]+""+OldItemOutVal[23]+\
;	""+OldItemOutVal[24]+""+OldItemOutVal[25]+""+OldItemOutVal[26]+""+OldItemOutVal[27]+""+OldItemOutVal[28]+""+OldItemOutVal[29]+""+OldItemOutVal[30]+""+OldItemOutVal[31])
;
;	Dlog(NewItem+":"+NewItemOutVal[0]+""+NewItemOutVal[1]+""+NewItemOutVal[2]+""+NewItemOutVal[3]+""+NewItemOutVal[4]+""+NewItemOutVal[5]+""+NewItemOutVal[6]+""+NewItemOutVal[7]+\
;	""+NewItemOutVal[8]+""+NewItemOutVal[9]+""+NewItemOutVal[10]+""+NewItemOutVal[11]+""+NewItemOutVal[12]+""+NewItemOutVal[13]+""+NewItemOutVal[14]+""+NewItemOutVal[15]+\
;	""+NewItemOutVal[16]+""+NewItemOutVal[17]+""+NewItemOutVal[18]+""+NewItemOutVal[19]+""+NewItemOutVal[20]+""+NewItemOutVal[21]+""+NewItemOutVal[22]+""+NewItemOutVal[23]+\
;	""+NewItemOutVal[24]+""+NewItemOutVal[25]+""+NewItemOutVal[26]+""+NewItemOutVal[27]+""+NewItemOutVal[28]+""+NewItemOutVal[29]+""+NewItemOutVal[30]+""+NewItemOutVal[31])
;	
;	counter = 0
;	While Counter<32
;		if OldItemOutVal[Counter]>0 && (NewItemOutVal[Counter] == OldItemOutVal[Counter])
;			dlog("Bodyslot "+(counter+30)+" matches")
;			return false
;		endif
;	counter += 1
;	endwhile
;	dlog("No bodyslot matches")
;	return true
;endfunction
;****************************************************************************************************************
Bool Function CheckEligibility(Actor NPC)
	dlog("In CheckEligibility()")
	int index = 0
	If NPC == Game.GetPlayer()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is the PLAYER")
		return False
	endif
	if NPC.HasKeyword(DontChange)
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is TAGGED DontChange")
		return False
	endif
		if NPC.GetLeveledActorBase().GetSex() != 1
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is NOT FEMALE")
		return False
	endif
	If !DressTheDead
		If NPC.IsDead()
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is DEAD")
			return False
		endif
	endif
	if NPC.IsDeleted()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is DELETED")
		return False
	endif
	if NPC.IsChild()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is a CHILD")
		return False
	endif
	if NPC.IsDisabled()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is DISABLED")
		return False
	endif
	If NPC.IsInPowerArmor()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is IN POWER ARMOR")
		return False
	endif
	if Game.GetPlayer().GetDistance(NPC) > ScanRange
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is TOO FAR")
		return False
	Endif
	If FactionsToIgnore.GetSize()
		Int i
		While i<FactionsToIgnore.GetSize()
			If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is IN AN IGNORED FACTION "+FactionsToIgnore.GetAt(i).GetName())
				return False
			endif
		i += 1
		Endwhile
	endif
	If UseAAF
		if AAF_ActiveActors.HasForm(NPC)
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is AAF ACTOR")
			return false
		endif
		if NPC.HasKeyword(AAFBusyKeyword)
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is AAF BUSY")
			return false
		endif
		If NPC.GetActorBase() == AAF_Doppelganger
			dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is a DOPPELGANGER")
			return false
		endif
	endif
	return true
endFunction
;****************************************************************************************************************

;****************************************************************************************************************
Function ReEquipItems(Actor NPC)
	dlog("In ReEquipItems()")
	dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is being refreshed")
	If NPC.GetLeveledActorBase().Getoutfit()==EmptyOutfit2
		NPC.SetOutfit(EmptyOutfit)
	else
		NPC.SetOutfit(EmptyOutfit2)
	endif
	int i=0
	Form[] InvItems = NPC.GetInventoryItems()
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
		If (akItem as Armor)
			NPC.equipitem(akItem)
			dlog(NPC+" re-equipping "+akItem.getname())
		EndIf
	i += 1
	EndWhile
endfunction
;****************************************************************************************************************
Function UnEquipItems(Actor NPC)
	dlog("In UnEquipItems()")
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
		If SafeItems.HasForm(akItem)
			dlog(NPC+" NOT REMOVING "+akitem+akItem.getname()+":IS TAGGED SAFE")
		else
			If (akItem as Armor)
				NPC.removeitem(akItem, -1)
				dlog(NPC+" removing "+akitem+akItem.getname())
			EndIf
			If WeaponsList.HasForm(akItem)
				NPC.removeitem(akItem, -1)
				dlog(NPC+" removing "+akitem+akItem.getname())
			EndIf
		endif
	i += 1
	EndWhile
endfunction
;****************************************************************************************************************
Function GetMCMSettings()
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	DressTheDead = MCM.GetModSettingBool("OutfitShuffler", "bDressTheDead:General") as Bool
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int
	Logging = MCM.GetModSettingBool("OutfitShuffler", "bLogging:General") as Bool
;OutfitChances
	Int counter = 0
	While counter < PForm.Length
		PChance[counter]=MCM.GetModSettingInt("OutfitShuffler", "iChance"+PString[counter]+":General") as Int
		counter += 1
	endwhile
endfunction
;****************************************************************************************************************
Function ChangeNow()
	dlog("In ChangeNow()")
	GetMCMSettings()
	Actor ScannedActor = LL_FourPlay.LastCrossHairActor()
	If ScannedActor != None
		Debug.Notification("[OutfitShuffler] "+ScannedActor.GetLeveledActorBase().GetName()+" will be changed NOW.")
		UnEquipItems(ScannedActor)
		dlog(ScannedActor+" Setting outfit "+EmptyOutfit)
		ScannedActor.SetOutfit(EmptyOutfit,false)
		SetOutfitFromParts(ScannedActor)
	endif
endfunction
;****************************************************************************************************************
Function OutfitHotkey()
	dlog("In OutfitHotkey()")
	GetMCMSettings()
	MultCounter = LongMult
EndFunction
;****************************************************************************************************************
Function DontChange()
	dlog("In DontChange()")
	GetMCMSettings()
	Actor ScannedActor = LL_FourPlay.LastCrossHairActor()
	If ScannedActor != None
		If ScannedActor.HasKeyword(DontChange)
			ScannedActor.RemoveKeyword(DontChange)
			debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" will be changed.")
			dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their DontChange keyword removed, and SHOULD be changed.")
		else
			ScannedActor.AddKeyword(DontChange)
			debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" will NOT be changed.")
			dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their DontChange keyword added, and SHOULD NOT be changed.")
		endif
	endif
EndFunction
;****************************************************************************************************************
Function dlog(string LogMe)
	If Logging
		debug.trace("[OutfitShuffler]"+LogMe)
	endif
endFunction
;****************************************************************************************************************
Function RescanOutfitsINI()
	canceltimer(ShortTimerID)
	dlog("In RescanOutfitsINI()")
	Debug.Notification("[OutfitShuffler] ******* Stopping timers and rescanning outfit pieces *******")
	BuildOutfitStructArray()
	GetMCMSettings()
	int AllSlotsCounter = 0
	int counter=0
	While counter < PForm.Length
		dlog("Reverting =>"+PString[Counter]+"<==  "+PForm[counter]+" Chance="+PChance[counter]+" Count="+PForm[counter].GetSize())
		PForm[counter].revert()
		counter += 1
	endwhile
	String MasterINI = "OutfitShuffler.ini"

;Get Outfit Pieces

	Int INILoads
	Var[] ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "InputFiles")
	Var[] Keys=Utility.VarToVarArray(ConfigOptions[0])
	int j=0
	While j<Keys.Length
		int ConfigOptionsInt=LL_FourPlay.GetCustomConfigOption_UInt32(MasterINI, "InputFiles", Keys[j]) as int
		if ConfigOptionsInt > 0
			dlog("******* "+LL_FourPlay.GetCustomConfigPath(MasterINI)+" sent "+Keys[j]+" to ScanINI() *******")
			ScanINI(Keys[j])
			INILoads += 1
		endif
	j += 1
	endwhile
	
;Get Races

	ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "Races")
	Var[] RaceKeys=Utility.VarToVarArray(ConfigOptions[0])
	Var[] RaceValues=Utility.VarToVarArray(ConfigOptions[1])
	j=0
	ActorRaces.Revert()
	While j<RaceKeys.Length
		int ConfigOptionsInt=RaceValues[j] as int
		if ConfigOptionsInt > 0
			dlog("******* "+Game.GetFormFromFile(ConfigOptionsInt, RaceKeys[j])+" Added to ActorRaces *******")
			Debug.Notification("[OutfitShuffler] Adding "+Game.GetFormFromFile(ConfigOptionsInt, RaceKeys[j])+" to Races")
			ActorRaces.AddForm(Game.GetFormFromFile(ConfigOptionsInt,RaceKeys[j]))
		endif
	j += 1
	endwhile
	
;Get FactionsToIgnore

	ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "FactionsToIgnore")
	Var[] FactionsToIgnoreKeys=Utility.VarToVarArray(ConfigOptions[0])
	Var[] FactionsToIgnoreValues=Utility.VarToVarArray(ConfigOptions[1])
	j=0
	FactionsToIgnore.Revert()
	While j<FactionsToIgnoreKeys.Length
		int ConfigOptionsInt=FactionsToIgnoreValues[j] as int
		if ConfigOptionsInt > 0
			dlog("******* "+Game.GetFormFromFile(ConfigOptionsInt, FactionsToIgnoreKeys[j])+" Added to FactionsToIgnore *******")
			Debug.Notification("[OutfitShuffler] Adding "+Game.GetFormFromFile(ConfigOptionsInt, FactionsToIgnoreKeys[j])+" to FactionsToIgnore")
			FactionsToIgnore.AddForm(Game.GetFormFromFile(ConfigOptionsInt, FactionsToIgnoreKeys[j]))
		endif
	j += 1
	endwhile

	
	Debug.Notification("[OutfitShuffler] Rescanning NPCs after update")
	dlog("Rescanning NPCs after update")
	GetMCMSettings()
	ScanNPCs(True)
	StartTimer(ShortTime, ShortTimerID)
endfunction
;****************************************************************************************************************
Function ScanINI(String INItoCheck)
	dlog("In ScanINI()")
	String INIpath = "OutfitShuffler\\" 
	String INIFile=INIpath+INItoCheck
	String[] ChildINISections=LL_FourPlay.GetCustomConfigSections(INIFile) as String[]
	int ChildINISectionCounter=0
	if ChildINISections.Length > 0
		While ChildINISectionCounter<ChildINISections.Length
			Var[] ChildConfigOptions=LL_FourPlay.GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
			Var[] ChildKeys=Utility.VarToVarArray(ChildConfigOptions[0])
			Var[] ChildValues=Utility.VarToVarArray(ChildConfigOptions[1])
			If ChildKeys.Length > 0
				int ChildKeysCounter=0
				While ChildKeysCounter < ChildKeys.Length
					int FormToAdd=ChildValues[ChildKeysCounter] as int
					If Game.IsPluginInstalled(ChildKeys[ChildKeysCounter])
						if FormToAdd > 0
							int OutfitPartsCounter = 0
							If PString.Find(ChildINISections[ChildINISectionCounter]) > -1
								PForm[PString.Find(ChildINISections[ChildINISectionCounter])].AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]))
								dlog(INItoCheck+" added "+Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]).GetName()+" from "+ChildKeys[ChildKeysCounter]+" to "+PString[PString.Find(ChildINISections[ChildINISectionCounter])]+PForm[PString.Find(ChildINISections[ChildINISectionCounter])])
							endIf
						endif
					endif
				ChildKeysCounter += 1
				endwhile
			endif
		ChildINISectionCounter += 1
		endwhile
	else
		dlog(INIFile+" does not contain any sections")
	endif
endFunction
;****************************************************************************************************************
Function JustEndItAll()
	int counter=0
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
	debug.messagebox("This is irreversible, and you were warned. Save, exit, load (With missing OutfitShuffler.esl), save, exit. Reinstall or upgrade if desired.")
	OutfitShufflerQuest.Stop()
endFunction
;****************************************************************************************************************
Function BuildOutfitStructArray()
	PForm = new FormList[0]
	PString = new String[0]
	PChance = new Int[0]

	PForm.Clear()
	PString.Clear()
	PChance.Clear()
	
	PString.Add("FullBody")
	PForm.Add(FullBody)
	PChance.Add(0)
	;0
	PString.Add("Shoes")
	PForm.Add(Shoes)
	PChance.Add(0)
	;1
	PString.Add("Top")
	PForm.Add(Top)
	PChance.Add(0)
	;2
	PString.Add("Bottom")
	PForm.Add(Bottom)
	PChance.Add(0)
	;3
	PString.Add("ArmAddon")
	PForm.Add(ArmAddon)
	PChance.Add(0)
	;4
	PString.Add("Neck")
	PForm.Add(Neck)
	PChance.Add(0)
	;5
	PString.Add("Belt")
	PForm.Add(Belt)
	PChance.Add(0)
	;6
	PString.Add("Hair")
	PForm.Add(Hair)
	PChance.Add(0)
	;7
	PString.Add("LongHair")
	PForm.Add(LongHair)
	PChance.Add(0)
	;8
	PString.Add("Glasses")
	PForm.Add(Glasses)
	PChance.Add(0)
	;9
	PString.Add("Legs")
	PForm.Add(Legs)
	PChance.Add(0)
	;10
	PString.Add("Back")
	PForm.Add(Back)
	PChance.Add(0)
	;11
	PString.Add("Front")
	PForm.Add(Front)
	PChance.Add(0)
	;12
	PString.Add("Accessory")
	PForm.Add(Accessory)
	PChance.Add(0)
	;13
	PString.Add("Jacket")
	PForm.Add(Jacket)
	PChance.Add(0)
	;14
	PString.Add("TorsoArmor")
	PForm.Add(TorsoArmor)
	PChance.Add(0)
	;15
	PString.Add("LeftArmArmor")
	PForm.Add(LeftArmArmor)
	PChance.Add(0)
	;16
	PString.Add("RightArmArmor")
	PForm.Add(RightArmArmor)
	PChance.Add(0)
	;17
	PString.Add("LeftLegArmor")
	PForm.Add(LeftLegArmor)
	PChance.Add(0)
	;18
	PString.Add("RightLegArmor")
	PForm.Add(RightLegArmor)
	PChance.Add(0)
	;19
	PString.Add("Earrings")
	PForm.Add(Earrings)
	PChance.Add(0)
	;20
	PString.Add("Ring")
	PForm.Add(Ring)
	PChance.Add(0)
	;21
	PString.Add("Backpack")
	PForm.Add(Backpack)
	PChance.Add(0)
	;22
	PString.Add("Shoulder")
	PForm.Add(Shoulder)
	PChance.Add(0)
	;23
	PString.Add("WeaponsList")
	PForm.Add(WeaponsList)
	PChance.Add(0)
	;24
	PString.Add("SafeItems")
	PForm.Add(SafeItems)
	PChance.Add(0)
endfunction