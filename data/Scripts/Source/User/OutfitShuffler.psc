Scriptname OutfitShuffler extends Quest
;=================================================================================================================
;Imported Properties from ESP
Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory
Outfit Property EmptyOutfit Auto Const
Outfit Property EmptyOutfit2 Auto Const
Formlist Property ActorRaces Auto Const
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const
Formlist Property AllBodySlots Auto Const
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
Keyword Property OSOutfit Auto Const
Keyword Property OSItem Auto Const
float Property ShortTime Auto
int Property LongMult Auto
float Property ScanRange Auto
bool Property Logging Auto
;=================================================================================================================
;Initialize a few variables
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
Bool modEnabled
Bool RescanOutfits
Bool UpdateMCM
Bool UseAAF
int ChanceFullBody
int ChanceShoes
int ChanceTop
int ChanceBottom
int ChanceArmAddon
int ChanceNeck
int ChanceBelt
int ChanceHair
int ChanceGlasses
int ChanceLegs
int ChanceBack
int ChanceFront
int ChanceAccessory
int ChanceWeaponsList
int INIsToScan
FormList[] PForm
String[] PString
Int[] PChance
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Event OnInit()
	BuildOutfitStructArray()
	dlog("OutfitShuffler Installed")
	debug.notification("[OutfitShuffler] Installed")
	starttimer(ShortTime, ShortTimerID)
	GetMCMSettings()
EndEvent
;=================================================================================================================
;Catch timer events
Event OnTimer(int aiTimerID)
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
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Function TimerTrap()
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
	RegisterForExternalEvent("OnMCMSettingChange|OutfitShuffler", "OnMCMSettingChange")
	If UpdateMCM
		Debug.Notification("[OutfitShuffler] MCM Settings Changed")
		dLog("MCM Settings Changed")
		GetMCMSettings()
	endif
	bool Force = False
	if MultCounter > LongMult-1
		GetMCMSettings()
		Force = True
		debug.notification("[OutfitShuffler] Changing All Outfits...")
		MultCounter = 1
	else
		MultCounter += 1
	endif
	canceltimer(ShortTimerID)
	ScanNPCs(Force)
	starttimer(ShortTime, ShortTimerID)
endFunction
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
function ScanNPCs(bool Force=False)
	Int OutfitPartsCounter
	While OutfitPartsCounter < PForm.Length
		If PForm[OutfitPartsCounter].GetSize() > -1 
			dLog("============================================= "+PString[OutfitPartsCounter]+".FormList has "+PForm[OutfitPartsCounter].GetSize() +" items")
		endif
		OutfitPartsCounter += 1
	endwhile
	int racecounter = 0
	While racecounter < ActorRaces.GetSize()
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(ActorRaces.GetAt(racecounter), ScanRange)
		while i < kActorArray.Length
			Actor NPC = kActorArray[i] as Actor
			if CheckEligibility(NPC)
				if Force
					dlog(i+"/"+kActorArray.length+NPC.GetLeveledActorBase().GetName()+":is being forced")
					Var[] params = new Var[1]
						params[0] = NPC as Actor
					(self as ScriptObject).CallFunctionNoWait("SetSettlerOutfit",params)
					;SetSettlerOutfit(NPC)
				endif
				if !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					dlog(i+"/"+kActorArray.length+NPC.GetLeveledActorBase().GetName()+":needs an outfit")
					Var[] params = new Var[1]
						params[0] = NPC as Actor
					(self as ScriptObject).CallFunctionNoWait("SetSettlerOutfit",params)
					;SetSettlerOutfit(NPC)
				endif
				if GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					int AAL=kActorArray.length
					dlog(i+"/"+AAL+":"+NPC.GetLeveledActorBase().GetName()+":is wearing a good outfit")
					Var[] params = new Var[3]
						params[0] = NPC as Actor
						params[1] = i as Int
						params[2] = AAL as Int
						(self as ScriptObject).CallFunctionNoWait("ReEquipItems", params)
					;ReEquipItems(NPC, i, AAL)
				endIf
			endif
			i += 1
		endwhile
		RaceCounter += 1
	endwhile	
endFunction
;=================================================================================================================
Function SetSettlerOutfit(Actor NPC)
	if CheckEligibility(NPC)
		dlog(NPC+" is being sent to UnequipItems")
		UnEquipItems(NPC)
		dlog(NPC+" Setting outfit "+EmptyOutfit)
		NPC.SetOutfit(EmptyOutfit2,false)
		NPC.SetOutfit(EmptyOutfit,false)
		NPC.AddKeyword(OSOutfit)
		SetOutfitFromParts(NPC)
	endif
EndFunction
;=================================================================================================================
Function SetOutfitFromParts(Actor NPC)
	If Utility.RandomInt(1,99)<ChanceFullBody && FullBody.GetSize()>0
		NPC.Equipitem(FullBody.GetAt(Utility.RandomInt(0,FullBody.GetSize())))
	else
		Int Counter=1
		While counter < PForm.Length
			If PChance[Counter]>1
				If PForm[Counter].GetSize()>0
					If Utility.RandomInt(1,99)<PChance[counter]
						Form RandomItem = PForm[counter].GetAt(Utility.RandomInt(0,PForm[Counter].GetSize())) as Form
						NPC.Equipitem(RandomItem)
						dlog(NPC+NPC.GetLeveledActorBase().GetName()+" received "+RandomItem+" from "+PString[Counter]+".FormList")
					else 
						dlog(NPC+NPC.GetLeveledActorBase().GetName()+" received NO ITEM from "+PString[Counter]+".FormList")
					endif
				else
					dlog(PString[counter]+".FormList has ZERO items")
				endif
			Else
				dlog(PString[counter]+".FormList has ZERO chance")
			endif
		counter += 1
		endwhile
	endif
endfunction
;=================================================================================================================
Bool Function CheckEligibility(Actor NPC)
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
	If NPC.IsDead()
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is DEAD")
		return False
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
	if Game.GetPlayer().GetDistance(NPC) > ScanRange
		dlog(NPC+NPC.GetLeveledActorBase().GetName()+" is TOO FAR")
		return False
	Endif
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
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Function EquipItems(Actor NPC)
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
		If (akItem as Armor)
			NPC.equipitem(akItem)
			dlog(NPC+" Now Wearing "+akItem.getname())
		EndIf
	i += 1
	EndWhile
endfunction
;=================================================================================================================
Function ReEquipItems(Actor NPC, int p, int AAL)
	dlog(p+"/"+AAL+":"+NPC+NPC.GetLeveledActorBase().GetName()+" is being refreshed")
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
;=================================================================================================================
Function UnEquipItems(Actor NPC)
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
		dlog(NPC+" has "+akItem.getname())
		If SafeItems.HasForm(akItem)
			dlog(NPC+" NOT REMOVING "+akitem+akItem.getname()+":IS TAGGED SAFE")
		else
			If (akItem as Armor)
				NPC.removeitem(akItem, -1)
				dlog(NPC+" removing "+akitem+akItem.getname())
			EndIf
		endif
	i += 1
	EndWhile
endfunction
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Function MCMUpdate()
	dlog("MCMUpdate:RescanOutfits="+RescanOutfits)
	If RescanOutfits == True
		RescanOutfits=False
		MCM.SetModSettingBool("OutfitShuffler", "bRescanOutfits:General", RescanOutfits)
		RescanOutfitsINI()
	endif
	if modEnabled
			StartTimer(ShortTime, ShortTimerID)
		else
			CancelTimer(ShortTimerID)
	endif
endfunction
;=================================================================================================================
Function OnMCMSettingChange(string modName, string id)
	UpdateMCM = True
	MCM.RefreshMenu()
endFunction
;=================================================================================================================
Function GetMCMSettings()
	UpdateMCM=False
	CancelTimer(ShortTimerID)
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int
	Logging = MCM.GetModSettingBool("OutfitShuffler", "bLogging:General") as Bool
	RescanOutfits = MCM.GetModSettingBool("OutfitShuffler", "bRescanOutfits:General") as Bool
	dlog("GetMCMSettings:IsEnabled="+modEnabled)
	dlog("GetMCMSettings:ScanRange="+ScanRange)
	dlog("GetMCMSettings:Logging="+Logging)
	dlog("GetMCMSettings:ShortTime="+ShortTime)
	dlog("GetMCMSettings:LongMult="+LongMult)
	dlog("GetMCMSettings:RescanOutfits="+RescanOutfits)
;OutfitChances
	Int counter = 0
	While counter < PForm.Length
		PChance[counter]=MCM.GetModSettingInt("OutfitShuffler", "iChance"+PString[counter]+":General") as Int
		dlog("MCMGetModSetting(iChance"+PString[counter]+")="+PChance[counter])
		counter += 1
	endwhile
	MCMUpdate()
endfunction
;=================================================================================================================
Function ChangeNow()
	MCMUpdate()
	Actor ScannedActor = LL_FourPlay.LastCrossHairActor()
	If ScannedActor != None
		Debug.Notification("[OutfitShuffler] "+ScannedActor.GetLeveledActorBase().GetName()+" will be changed NOW.")
		UnEquipItems(ScannedActor)
		dlog(ScannedActor+" Setting outfit "+EmptyOutfit)
		ScannedActor.SetOutfit(EmptyOutfit,false)
		ScannedActor.AddKeyword(OSOutfit)
		SetOutfitFromParts(ScannedActor)
	endif
endfunction
;=================================================================================================================
Function OutfitHotkey()
	MCMUpdate()
	MultCounter = LongMult
EndFunction
;=================================================================================================================
Function DontChange()
	MCMUpdate()
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
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Function dlog(string LogMe)
	If Logging
		debug.trace("[OutfitShuffler]"+LogMe)
	endif
endFunction
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Function RescanOutfitsINI()
	int AllSlotsCounter = 0
	int counter=0
	While counter < PForm.Length
		dlog("Reverting =>"+PString[Counter]+"<==  "+PForm[counter]+" Chance="+PChance[counter]+" Count="+PForm[counter].GetSize())
		PForm[counter].revert()
		counter += 1
	endwhile
	
	Debug.Notification("[OutfitShuffler] _-_-_-_-_-_-_-_-_-_-_-_-_- Stopping timers and rescanning outfit pieces _-_-_-_-_-_-_-_-_-_-_-_-_-")
	CancelTimer(ShortTimerID)
	String MasterINI = "OutfitShuffler.ini"
	Int INILoads
	String[] INISections=LL_FourPlay.GetCustomConfigSections(MasterINI) as String[]
	int i=0
	INIsToScan=0
	While i<INISections.Length
		Var[] ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, INISections[i])
		Var[] Keys=Utility.VarToVarArray(ConfigOptions[0])
		int j=0
		While j<Keys.Length
			int ConfigOptionsInt=LL_FourPlay.GetCustomConfigOption_UInt32(MasterINI, INISections[i], Keys[j]) as int
			if ConfigOptionsInt > 0
				dlog("_-_-_-_-_-_-_-_-_-_-_-_-_- "+LL_FourPlay.GetCustomConfigPath(MasterINI)+" sent "+Keys[j]+" to ScanINI() _-_-_-_-_-_-_-_-_-_-_-_-_-")
				Var[] params = new Var[1]
					params[0] = Keys[j] as String
				(self as ScriptObject).CallFunctionNoWait("ScanINI",params)
				INILoads += 1
			endif
		j += 1
		endwhile
	i += 1
	endwhile
	While INIsToScan < INILoads
		dlog("_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-INIsToScan "+INIsToScan+"/"+INILoads+"INILoads  _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-")
		Utility.Wait(0.2)
	Endwhile
	dlog("_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-INIsToScan "+INIsToScan+"/"+INILoads+"INILoads  _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-")
	IterateLists()
	Debug.Notification("[OutfitShuffler] Rescanning NPCs after update")
	dlog("Rescanning NPCs after update")
	GetMCMSettings()
	ScanNPCs(True)
	StartTimer(ShortTime, ShortTimerID)
endfunction
;=================================================================================================================
Function ScanINI(String INItoCheck)
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
	INIsToScan += 1
endFunction
;=================================================================================================================
Function IterateLists()
	Debug.Notification("[OutfitShuffler] Dumping Formlists to Log")
	dLog("====================Iterating Formlists==================")
		int OutfitPartsCounter=0
		While OutfitPartsCounter < PForm.Length
			int IntOutfitPartsCounter = 0
			dLog("============================================= "+PString[OutfitPartsCounter])
			While IntOutfitPartsCounter < PForm[OutfitPartsCounter].GetSize()
				dLog(PForm[OutfitPartsCounter].GetAt(IntOutfitPartsCounter).GetName())
				IntOutfitPartsCounter += 1
			EndWhile
			OutfitPartsCounter += 1
		endwhile
	Debug.Notification("[OutfitShuffler] Finished dumping formlists to log")
EndFunction

Function JustEndItAll()
	int counter=0
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
	debug.messagebox("This is irreversible, and you were warned. Save, reload, save, exit. Reinstall or upgrade.")
	OutfitShufflerQuest.Stop()
endFunction

Function BuildOutfitStructArray()
	PForm = new FormList[0]
	PString = new String[0]
	PChance = new Int[0]
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