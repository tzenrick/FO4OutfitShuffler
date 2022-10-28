Scriptname OutfitShuffler extends Quest
;****************************************************************************************************************
;Hey Stupid,
;You can comment your code a little bit.
;****************************************************************************************************************
;Imported Properties from ESP
Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory

Outfit Property EmptyOutfit Auto Const
Outfit Property EmptyOutfit2 Auto Const

Formlist Property OSActorRaces Auto
Formlist Property FactionsToIgnore Auto
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const
Formlist Property WeaponsList Auto

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
FormList Property XXSafeItems Auto
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
FormList Property XYSafeItems Auto
Formlist Property XYShoes Auto
Formlist Property XYShoulder Auto
Formlist Property XYTop Auto
Formlist Property XYTorsoArmor Auto


Keyword Property DontChange Auto Const
Keyword Property AlwaysChange Auto Const
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
Bool XXEnabled
Bool XYEnabled
Bool RescanOutfits
Bool UseAAF

FormList[] PForm
String[] PString
Int[] PChance

FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
Spell Maintainer
;****************************************************************************************************************
;****************************************************************************************************************
;****************************************************************************************************************
Event OnInit()
	dlog("OutfitShuffler Installed")
	debug.notification("[OutfitShuffler] Installed")
	starttimer(ShortTime, ShortTimerID)
	GetMCMSettings()
EndEvent
;****************************************************************************************************************
;Catch timer events
;6.0 New Order in ontimer; get MCMSettings First
Event OnTimer(int aiTimerID)
	dlog("In OnTimer()")
	GetMCMSettings()
;MCM should return modenabled=0 on fresh install
	if modEnabled
		If CountParts()<1
			RescanOutfitsINI()
		endif
	else
		dlog("++++ NOT ENABLED, NOT SCANNING OUTFITS YET ++++")
	endif
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			if modEnabled
				dlog("Timer:"+MultCounter+"/"+LongMult)
				TimerTrap()
			else
				dlog("++++ NOT ENABLED ++++")
			endif
		endif
	endif
EndEvent
;****************************************************************************************************************
Function TimerTrap()
	CancelTimer(ShortTimerID)
	dlog("In TimerTrap()")
	GetMCMSettings()
	AAF_ActiveActors = Game.GetFormFromFile(0x0098f4, "AAF.esm") as FormList
	AAF_Doppelganger = Game.GetFormFromFile(0x0072E2, "AAF.esm") as ActorBase
	AAF_EmptyOutfit = Game.GetFormFromFile(0x02b47d, "AAF.esm") as Outfit
	If Maintainer==None
		Maintainer=Game.GetFormFromFile(0x827,"OutfitShuffler.esl") as Spell
	endif
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
	While racecounter < OSActorRaces.GetSize()
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(OSActorRaces.GetAt(racecounter), ScanRange)
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
			endif
			i += 1
		endwhile
		RaceCounter += 1
	endwhile
endFunction
;****************************************************************************************************************
int Function CountParts()
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	dlog("=============================== "+OutfitPartsAdder+" items in outfit parts lists.")
	return OutfitPartsAdder
endfunction
;****************************************************************************************************************
Function SetSettlerOutfit(Actor NPC)
	dlog("In SetSettlerOutfit()")
	UnEquipItems(NPC)
	NPC.SetOutfit(EmptyOutfit2,false)
	NPC.SetOutfit(EmptyOutfit,false)
	SetOutfitFromParts(NPC)
	If !NPC.HasSpell(Maintainer)
		NPC.AddSpell(Maintainer)
	endif
EndFunction
;****************************************************************************************************************
Function SetOutfitFromParts(Actor NPC)

	dlog("In SetOutfitParts()")
;Prefixing for males
	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0
		NPCSex="XY"
	endif
;Prefixing for females
	If NPC.GetLeveledActorBase().GetSex()==1
		NPCSex="XX"
	endif
	dlog(NPC+" NPCSex="+NPCSex)
	If Utility.RandomInt(1,99)<PChance[PString.Find(NPCSex+"FullBody")] && PForm[PString.Find(NPCSex+"FullBody")].GetSize()>0
		NPC.EquipItem(PForm[PString.Find(NPCSex+"FullBody")].GetAt(Utility.RandomInt(0,PForm[PString.Find(NPCSex+"FullBody")].GetSize())))
		;4.92 I realized that FullBody wasn't receiving anything from WeaponsList. We'll also make sure we do it with proper odds/chances.
	else
		Int Counter=1
		While counter < PForm.Length
			If LL_FourPlay.StringFind(PString[Counter], NPCSex) == 0 && LL_FourPlay.StringFind(PString[Counter], "FullBody") == -1
				dlog(NPC+"PString[Counter]="+PString[Counter]+" LL_FourPlay.StringFind(PString[Counter], NPCSex)="+LL_FourPlay.StringFind(PString[Counter], NPCSex))
				If PChance[Counter]>1 && PForm[Counter].GetSize()>0 && Utility.RandomInt(1,99)<PChance[counter]
					Form RandomItem = PForm[counter].GetAt(Utility.RandomInt(0,PForm[Counter].GetSize())) as Form
					If RandomItem != None
						dlog(NPC+" "+NPCSex+" got "+RandomItem+" "+RandomItem.GetName())
						NPC.EquipItem(RandomItem)
					endif
				endif
			endif
		counter += 1
		endwhile
	endif
	
	
	If Utility.RandomInt(1,99)<PChance[PString.Find("WeaponsList")] && PForm[PString.Find("WeaponsList")].GetSize()>0
			NPC.EquipItem(PForm[PString.Find("WeaponsList")].GetAt(Utility.RandomInt(0,PForm[PString.Find("WeaponsList")].GetSize())))
		endif
endfunction
;****************************************************************************************************************
Bool Function CheckEligibility(Actor NPC)
	dlog("In CheckEligibility() NPC="+NPC+" NAME="+NPC.GetLeveledActorBase().GetName())
	if LL_FourPlay.StringFind(NPC.GetLeveledActorBase().GetName(), "Armor Rack") != -1
		dlog(NPC+" is NAMED 'Armor Rack'")
		If NPC.HasKeyword(AlwaysChange)
			dlog(NPC+" is NAMED 'Armor Rack', and is tagged AlwaysChange, so I guess that's an override?")
			return True
		endif
		return False
	endif
	
	If (NPC.GetLeveledActorBase().GetSex()==0&&!XYEnabled)||(NPC.GetLeveledActorBase().GetSex()==1&&!XXEnabled)
		dlog(NPC+"'s Gender is Disabled")
		return False
	endif

	if (NPC == Game.GetPlayer()) || NPC.HasKeyword(DontChange) || NPC.IsDeleted() || NPC.IsDisabled() || NPC.IsInPowerArmor() || NPC.IsChild() || NPC.IsDead()
		dlog(NPC+"IsPlayer|Is DontChange|IsDeleted|IsDisabled|IsInPowerArmor|IsChild|IsDead|Sex="+NPC.GetLeveledActorBase().GetSex())
		return False
	endif

	if Game.GetPlayer().GetDistance(NPC) > ScanRange
		dlog(NPC+"Is now too far away")
		return False
	endif

	If FactionsToIgnore.GetSize()
		Int i
		While i<FactionsToIgnore.GetSize()
			If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				dlog(NPC+"Is in Restricted Faction")
				If !NPC.HasKeyword(AlwaysChange)
					dlog(NPC+"Is AlwaysChange")
					return False
				endif
			endif
		i += 1
		Endwhile
	endif

	if UseAAF && (AAF_ActiveActors.HasForm(NPC) || NPC.HasKeyword(AAFBusyKeyword) || ((NPC.GetActorBase() == AAF_Doppelganger)))
		return false
	endif
	
	dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is eligible to be changed")
	return true
endFunction
;****************************************************************************************************************
Function UnEquipItems(Actor NPC)
	dlog("In UnEquipItems()")
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0

	If NPC.GetLeveledActorBase().GetSex()==0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If !XYSafeItems.HasForm(akItem) && ((akItem as Armor) || WeaponsList.HasForm(akItem))
				NPC.removeitem(akItem, -1)
				dlog(NPC+" removed "+akItem)
			endif
		i += 1
		EndWhile
	endif

	If NPC.GetLeveledActorBase().GetSex()==1
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If !XXSafeItems.HasForm(akItem) && ((akItem as Armor) || WeaponsList.HasForm(akItem))
				NPC.removeitem(akItem, -1)
				dlog(NPC+" removed "+akItem)
			endif
		i += 1
		EndWhile
	endif
	
endfunction
;****************************************************************************************************************
Function GetMCMSettings()
	dlog("Refreshing MCM Settings.")
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	XXEnabled = MCM.GetModSettingBool("OutfitShuffler", "bEnableXX:General") as Bool
	XYEnabled = MCM.GetModSettingBool("OutfitShuffler", "bEnableXY:General") as Bool
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
Function DebugNPC()
;FileOutput
	dlog("In ******************************************************************DebugNPC()")
	GetMCMSettings()
	Actor ScannedActor = LL_FourPlay.LastCrossHairActor()
	dlog("   *************************************************************Name:"+ScannedActor+ScannedActor.GetLeveledActorBase().GetName())
	dlog("   **************************************************************Sex:"+ScannedActor+ScannedActor.GetLeveledActorBase().GetSex())
	dlog("   *******************************************************DontChange:"+ScannedActor+ScannedActor.HasKeyword(DontChange))
	dlog("   ********************************************************IsDeleted"+ScannedActor+ScannedActor.IsDeleted())
	dlog("   *******************************************************IsDisabled:"+ScannedActor+ScannedActor.IsDisabled())
	dlog("   ***************************************************IsInPowerArmor:"+ScannedActor+ScannedActor.IsInPowerArmor())
	dlog("   **********************************************************IsChild:"+ScannedActor+ScannedActor.IsChild())
	dlog("   ***********************************************************IsDead:"+ScannedActor+ScannedActor.IsDead())
	dlog("   *********************************************************Distance:"+ScannedActor+Game.GetPlayer().GetDistance(ScannedActor))
	If FactionsToIgnore.GetSize()
		Int i
		While i<FactionsToIgnore.GetSize()
			If ScannedActor.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				dlog("   *************************************************FactionsToIgnore:"+ScannedActor+FactionsToIgnore.GetAt(i))
			endif
		i += 1
		Endwhile
	endif
	Form[] InvItems = ScannedActor.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
			dlog("   ******************************************************************INV: "+akItem+akItem.GetName())
	i += 1
	EndWhile
;ScreenOutput
	Debug.Notification("[OutfitShuffler]********************Name:"+ScannedActor+ScannedActor.GetLeveledActorBase().GetName())
	Debug.Notification("[OutfitShuffler]*********************Sex:"+ScannedActor+ScannedActor.GetLeveledActorBase().GetSex())
	Debug.Notification("[OutfitShuffler]**************DontChange:"+ScannedActor+ScannedActor.HasKeyword(DontChange))
	Debug.Notification("[OutfitShuffler]***************IsDeleted"+ScannedActor+ScannedActor.IsDeleted())
	Debug.Notification("[OutfitShuffler]**************IsDisabled:"+ScannedActor+ScannedActor.IsDisabled())
	Debug.Notification("[OutfitShuffler]**********IsInPowerArmor:"+ScannedActor+ScannedActor.IsInPowerArmor())
	Debug.Notification("[OutfitShuffler]*****************IsChild:"+ScannedActor+ScannedActor.IsChild())
	Debug.Notification("[OutfitShuffler]******************IsDead:"+ScannedActor+ScannedActor.IsDead())
	Debug.Notification("[OutfitShuffler]****************Distance:"+ScannedActor+Game.GetPlayer().GetDistance(ScannedActor))
	If FactionsToIgnore.GetSize()
		i=0
		While i<FactionsToIgnore.GetSize()
			If ScannedActor.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				Debug.Notification("[OutfitShuffler]********FactionsToIgnore:"+ScannedActor+FactionsToIgnore.GetAt(i))
			endif
		i += 1
		Endwhile
	endif
	i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
			Debug.Notification("[OutfitShuffler]*************************INV: "+akItem+akItem.GetName())
	i += 1
	EndWhile
endfunction
;***********************************************************************
Function OutfitHotkey()
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
			ScannedActor.AddKeyword(AlwaysChange)
			debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" will ignore faction exclusions.")
			dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their AlwaysChange keyword Added, and will ignore faction exclusions.")
			return
		endif
		If ScannedActor.HasKeyword(AlwaysChange)
			ScannedActor.RemoveKeyword(AlwaysChange)
			debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" WILL be changed.")
			dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their AlwaysChange keyword Removed, and WILL be changed.")
			return
		endif
		ScannedActor.AddKeyword(DontChange)
		debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" WILL NOT be changed.")
		dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their DontChange keyword Added, and WILL NOT be changed.")
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
	String MasterINI = "OutfitShuffler.ini"
	int INIMasters=1
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
	OSActorRaces.Revert()
	While j<RaceKeys.Length
		int ConfigOptionsInt=RaceValues[j] as int
		if ConfigOptionsInt > 0
			dlog("******* "+Game.GetFormFromFile(ConfigOptionsInt, RaceKeys[j])+" Added to OSActorRaces *******")
			Debug.Notification("[OutfitShuffler] Adding "+Game.GetFormFromFile(ConfigOptionsInt, RaceKeys[j])+" to Races")
			OSActorRaces.AddForm(Game.GetFormFromFile(ConfigOptionsInt,RaceKeys[j]))
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

endfunction
