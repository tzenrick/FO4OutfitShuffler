Scriptname OutfitShuffler extends Quest
;=================================================================================================================
;Imported Properties from ESP
Quest Property pMQ101 Auto Const mandatory
Outfit Property EmptyOutfit Auto Const
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
int ChanceFullBody = 10
int ChanceShoes = 90
int ChanceTop = 90
int ChanceBottom = 90
int ChanceArmAddon = 10
int ChanceNeck = 90
int ChanceBelt = 10
int ChanceHair = 100
int ChanceGlasses = 50
int ChanceLegs = 10
int ChanceBack = 30
int ChanceFront = 50
int ChanceAccessory = 10
int ChanceWeaponsList = 100
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
;=================================================================================================================
;=================================================================================================================
;=================================================================================================================
Event OnInit()
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
	int racecounter = 0
	While racecounter < ActorRaces.GetSize()
		int i = 0
		ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(ActorRaces.GetAt(racecounter), ScanRange)
		while i < kActorArray.Length
			Actor NPC = kActorArray[i] as Actor
			if CheckEligibility(NPC)
				if Force
					dlog(i+"/"+kActorArray.length+":Forcing "+NPC.GetLeveledActorBase().GetName())
					SetSettlerOutfit(NPC)
				endif
				if !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					dlog(i+"/"+kActorArray.length+":Needs an outfit "+NPC.GetLeveledActorBase().GetName())
					SetSettlerOutfit(NPC)
				endif
				if GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
					dlog(i+"/"+kActorArray.length+":"+NPC.GetLeveledActorBase().GetName()+" is wearing a good outfit")
					Float TempVarf = MultCounter/10 as Float
					Int TempVari = MultCounter/10 as Int
					If TempVarf == TempVari
						dlog(i+"/"+kActorArray.length+":"+NPC.GetLeveledActorBase().GetName()+" is being refreshed")
						ReEquipItems(NPC)
					else
						dlog(i+"/"+kActorArray.length+":"+NPC.GetLeveledActorBase().GetName()+" is waiting to refresh")
					endIf
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
		UnEquipItems(NPC)
		dlog(NPC+" Setting outfit "+EmptyOutfit)
		NPC.SetOutfit(EmptyOutfit,false)
		NPC.AddKeyword(OSOutfit)
		SetOutfitFromParts(NPC)
	endif
EndFunction
;=================================================================================================================
Function SetOutfitFromParts(Actor NPC)
	If Utility.RandomInt(1,99)<ChanceFullBody
		NPC.EquipItem(FullBody.GetAt(Utility.RandomInt(0,FullBody.GetSize())) as Armor)
	else
		If Utility.RandomInt(1,99)<ChanceShoes
			NPC.EquipItem(Shoes.GetAt(Utility.RandomInt(0,Shoes.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceTop
			NPC.EquipItem(Top.GetAt(Utility.RandomInt(0,Top.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceBottom
			NPC.EquipItem(Bottom.GetAt(Utility.RandomInt(0,Bottom.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceArmAddon
			NPC.EquipItem(ArmAddon.GetAt(Utility.RandomInt(0,ArmAddon.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceNeck
			NPC.EquipItem(Neck.GetAt(Utility.RandomInt(0,Neck.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceBelt
			NPC.EquipItem(Belt.GetAt(Utility.RandomInt(0,Belt.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceHair
			NPC.EquipItem(Hair.GetAt(Utility.RandomInt(0,Hair.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceGlasses
			NPC.EquipItem(Glasses.GetAt(Utility.RandomInt(0,Glasses.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceLegs
			NPC.EquipItem(Legs.GetAt(Utility.RandomInt(0,Legs.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceBack
			NPC.EquipItem(Back.GetAt(Utility.RandomInt(0,Back.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceFront
			NPC.EquipItem(Front.GetAt(Utility.RandomInt(0,Front.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceAccessory
			NPC.EquipItem(Accessory.GetAt(Utility.RandomInt(0,Accessory.GetSize())) as Armor)
		endif
		If Utility.RandomInt(1,99)<ChanceWeaponsList
			NPC.EquipItem(WeaponsList.GetAt(Utility.RandomInt(0,WeaponsList.GetSize())) as Armor)
		endif
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
Function ReEquipItems(Actor NPC)
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0
	While (i < InvItems.Length)
	Form akItem = InvItems[i]
		If (akItem as Armor) && akitem.HasKeyword(OSItem)
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
		If (akItem as Armor)
			NPC.removeitem(akItem, -1)
			dlog(NPC+" removing "+akItem.getname())
		EndIf
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
	Debug.Notification("[OutfitShuffler] MCM Settings Changed")
	dLog("MCM Settings Changed")
	UpdateMCM = True
endFunction
;=================================================================================================================
Function GetMCMSettings()
	CancelTimer(ShortTimerID)
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int
	Logging = MCM.GetModSettingBool("OutfitShuffler", "bLogging:General") as Bool
	RescanOutfits = MCM.GetModSettingBool("OutfitShuffler", "bRescanOutfits:General") as Bool
;OutfitChances
	ChanceFullBody = MCM.GetModSettingInt("OutfitShuffler", "iChanceFullBody:General") as Int
	ChanceShoes = MCM.GetModSettingInt("OutfitShuffler", "iChanceShoes:General") as Int
	ChanceTop = MCM.GetModSettingInt("OutfitShuffler", "iChanceTop:General") as Int
	ChanceBottom = MCM.GetModSettingInt("OutfitShuffler", "iChanceBottom:General") as Int
	ChanceArmAddon = MCM.GetModSettingInt("OutfitShuffler", "iChanceArmAddon:General") as Int
	ChanceNeck = MCM.GetModSettingInt("OutfitShuffler", "iChanceNeck:General") as Int
	ChanceBelt = MCM.GetModSettingInt("OutfitShuffler", "iChanceBelt:General") as Int
	ChanceHair = MCM.GetModSettingInt("OutfitShuffler", "iChanceHair:General") as Int
	ChanceGlasses = MCM.GetModSettingInt("OutfitShuffler", "iChanceGlasses:General") as Int
	ChanceLegs = MCM.GetModSettingInt("OutfitShuffler", "iChanceLegs:General") as Int
	ChanceBack = MCM.GetModSettingInt("OutfitShuffler", "iChanceBack:General") as Int
	ChanceFront = MCM.GetModSettingInt("OutfitShuffler", "iChanceFront:General") as Int
	ChanceAccessory = MCM.GetModSettingInt("OutfitShuffler", "iChanceAccessory:General") as Int
	ChanceWeaponsList = MCM.GetModSettingInt("OutfitShuffler", "iChanceWeaponsList:General") as Int
;Logging
	dlog("MCMRaw.bIsEnabled:General="+MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General"))
	dlog("GetMCMSettings:IsEnabled="+modEnabled)
	dlog("GetMCMSettings:ScanRange="+ScanRange)
	dlog("GetMCMSettings:Logging="+Logging)
	dlog("GetMCMSettings:ShortTime="+ShortTime)
	dlog("GetMCMSettings:LongMult="+LongMult)
	dlog("GetMCMSettings:RescanOutfits="+RescanOutfits)
	dlog("MCMRaw.iChanceFullBody:General="+MCM.GetModSettingInt("OutfitShuffler", "iChanceFullBody:General"))
	dlog("ChanceFullBody="+ChanceFullBody + "  ChanceShoes="+ChanceShoes + "  ChanceTop="+ChanceTop + "  ChanceBottom="+ChanceBottom + "  ChanceArmAddon="+ChanceArmAddon + "  ChanceNeck="+ChanceNeck + "  ChanceBelt="+ChanceBelt + "  ChanceHair="+ChanceHair + "  ChanceGlasses="+ChanceGlasses + "  ChanceLegs="+ChanceLegs + "  ChanceBack="+ChanceBack + "  ChanceFront="+ChanceFront + "  ChanceAccessory="+ChanceAccessory + "  ChanceWeaponsList="+ChanceWeaponsList)
	MCMUpdate()
endfunction
;=================================================================================================================
Function OutfitHotkey() 
	MultCounter = LongMult
EndFunction
;=================================================================================================================
Function DontChange()
	Actor ScannedActor = LL_FourPlay.LastCrossHairActor()
	If ScannedActor.HasKeyword(DontChange)
		ScannedActor.RemoveKeyword(DontChange)
		debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" will be changed.")
		dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their DontChange keyword removed, and SHOULD be changed.")
	else
		ScannedActor.AddKeyword(DontChange)
		debug.notification("[OutfitShuffler]"+ScannedActor.GetLeveledActorBase().GetName()+" will NOT be changed.")
		dlog(ScannedActor.GetLeveledActorBase().GetName()+" has had their DontChange keyword added, and SHOULD NOT be changed.")
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
	Debug.Notification("[OutfitShuffler] Stopping timers and rescanning outfit pieces")
	CancelTimer(ShortTimerID)
	String MasterINI = "OutfitShuffler.ini"
	String[] INILoads = new String[0]
	String[] INISections=LL_FourPlay.GetCustomConfigSections(MasterINI) as String[]
	int i=0
	While i<INISections.Length
		Var[] ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, INISections[i])
		Var[] Keys=Utility.VarToVarArray(ConfigOptions[0])
		int j=0
		int INICounter=0
		While j<Keys.Length
			int ConfigOptionsInt=LL_FourPlay.GetCustomConfigOption_UInt32(MasterINI, INISections[i], Keys[j]) as int
			if ConfigOptionsInt > 0
				INILoads.Add(Keys[j] as String)
				INICounter += 1
			endif
		j += 1
		endwhile
	i += 1
	endwhile
	i=0
	While i<INILoads.Length
		Debug.Notification("[OutfitShuffler] Adding "+iniloads[i]+" to Formlists.")
		dlog("Passing "+iniloads[i]+" to ScanINI")
		ScanINI(INILoads[i])
	i += 1
	endwhile
	IterateLists()
	StartTimer(ShortTime, ShortTimerID)
endfunction
;=================================================================================================================
Function ScanINI(String INItoCheck)
	String INIpath = "OutfitShuffler\\" 
	String INIFile=INIpath+INItoCheck
	String[] ChildINISections=LL_FourPlay.GetCustomConfigSections(INIFile) as String[]
	int k=0
	if ChildINISections.Length != 0
		While k<ChildINISections.Length
			Var[] ChildConfigOptions=LL_FourPlay.GetCustomConfigOptions(INIFile, ChildINISections[k])
			Var[] ChildKeys=Utility.VarToVarArray(ChildConfigOptions[0])
			Var[] ChildValues=Utility.VarToVarArray(ChildConfigOptions[1])
			int l=0
			While l<ChildKeys.Length
				int FormToAdd=ChildValues[l] as int
				if FormToAdd > 0
					If ChildINISections[k]=="WeaponsList"
						WeaponsList.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Hair"
						Hair.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="LongHair"
						LongHair.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="FullBody"
						FullBody.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Shoes"
						Shoes.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="ArmAddon"
						ArmAddon.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Jacket"
						Jacket.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Top"
						Top.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Legs"
						Legs.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Bottom"
						Bottom.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="TorsoArmor"
						TorsoArmor.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="LeftArmArmor"
						LeftArmArmor.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="RightArmArmor"
						RightArmArmor.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="LeftLegArmor"
						LeftLegArmor.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="RightLegArmor"
						RightLegArmor.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Earrings"
						Earrings.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Glasses"
						Glasses.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Beard"
						Beard.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Neck"
						Neck.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Ring"
						Ring.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Backpack"
						Backpack.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Belt"
						Belt.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Shoulder"
						Shoulder.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Back"
						Back.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Front"
						Front.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
					If ChildINISections[k]=="Accessory"
						Accessory.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[l]))
					endif
				endif
			l += 1
			endwhile
		k += 1
		endwhile
	else
		dlog(INIFile+" does not contain any sections")
	endif
endFunction
;=================================================================================================================
Function IterateLists()
	If Logging
		Debug.Notification("[OutfitShuffler] Dumping Formlists to Log")
		dLog("====================Iterating Formlists==================")
		int IntCounter = 0
		dLog("=============================================WeaponsList")
		While IntCounter<WeaponsList.GetSize()
			dLog(WeaponsList.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Hair")
		While IntCounter<Hair.GetSize()
			dLog(Hair.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================LongHair")
		IntCounter=0
		While IntCounter<LongHair.GetSize()
			dLog(LongHair.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================FullBody")
		IntCounter=0
		While IntCounter<FullBody.GetSize()
			dLog(FullBody.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Shoes")
		IntCounter=0
		While IntCounter<Shoes.GetSize()
			dLog(Shoes.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================ArmAddon")
		IntCounter=0
		While IntCounter<ArmAddon.GetSize()
			dLog(ArmAddon.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Jacket")
		IntCounter=0
		While IntCounter<Jacket.GetSize()
			dLog(Jacket.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Top")
		IntCounter=0
		While IntCounter<Top.GetSize()
			dLog(Top.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Legs")
		IntCounter=0
		While IntCounter<Legs.GetSize()
			dLog(Legs.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Bottom")
		IntCounter=0
		While IntCounter<Bottom.GetSize()
			dLog(Bottom.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================TorsoArmor")
		IntCounter=0
		While IntCounter<TorsoArmor.GetSize()
			dLog(TorsoArmor.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================LeftArmArmor")
		IntCounter=0
		While IntCounter<LeftArmArmor.GetSize()
			dLog(LeftArmArmor.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================RightArmArmor")
		IntCounter=0
		While IntCounter<RightArmArmor.GetSize()
			dLog(RightArmArmor.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================LeftLegArmor")
		IntCounter=0
		While IntCounter<LeftLegArmor.GetSize()
			dLog(LeftLegArmor.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================RightLegArmor")
		IntCounter=0
		While IntCounter<RightLegArmor.GetSize()
			dLog(RightLegArmor.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Earrings")
		IntCounter=0
		While IntCounter<Earrings.GetSize()
			dLog(Earrings.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Glasses")
		IntCounter=0
		While IntCounter<Glasses.GetSize()
			dLog(Glasses.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Beard")
		IntCounter=0
		While IntCounter<Beard.GetSize()
			dLog(Beard.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Neck")
		IntCounter=0
		While IntCounter<Neck.GetSize()
			dLog(Neck.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Ring")
		IntCounter=0
		While IntCounter<Ring.GetSize()
			dLog(Ring.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Backpack")
		IntCounter=0
		While IntCounter<Backpack.GetSize()
			dLog(Backpack.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Belt")
		IntCounter=0
		While IntCounter<Belt.GetSize()
			dLog(Belt.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Shoulder")
		IntCounter=0
		While IntCounter<Shoulder.GetSize()
			dLog(Shoulder.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Back")
		IntCounter=0
		While IntCounter<Back.GetSize()
			dLog(Back.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Front")
		IntCounter=0
		While IntCounter<Front.GetSize()
			dLog(Front.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		dLog("=============================================Accessory")
		IntCounter=0
		While IntCounter<Accessory.GetSize()
			dLog(Accessory.GetAt(IntCounter).GetName())
		IntCounter += 1
		EndWhile
		Debug.Notification("[OutfitShuffler] Finished dumping formlists to log")
	endif
EndFunction