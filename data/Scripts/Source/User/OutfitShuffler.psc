Scriptname OutfitShuffler extends Quest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;6.25, emergency save. was 'cleaning,' and removed every asterisk (*) from the file...
;Hey Stupid,
;You can comment your code a little bit.
;6.25 release with diagnostic; excessive 'comment' at EOF. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
Spell Property Maintainer Auto Const
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initialize a few variables
string OSLogName="OutfitShuffler"
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
Bool modEnabled
Bool XXEnabled
Bool XYEnabled
Bool NPCUseScaling
float NPCMinScale
float NPCMaxScale
int LogLevel
bool ConsoleLogging = False
float Property ShortTime Auto
int Property LongMult Auto
float Property ScanRange Auto
Bool OneShot
Bool NPCGetHeadParts
Bool RandomBodyGen
Bool RescanOutfits
Bool UseAAF

FormList[] PForm
String[] PString
Int[] PChance

FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
Actor GameGetPlayer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnInit()
	dLog(2,"Installed ****************************************************************************************************************")
	int counter
	While counter < PForm.Length ; This feels agressive, but necessary. As long as it doesn't do it on every load, I'll be happy. ;Seems to work as fucking intended, somehow.
		PForm[counter].revert()
		counter += 1
	endwhile
	starttimer(ShortTime, ShortTimerID)
	GetMCMSettings()
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Catch timer events
;6.0 New Order in ontimer; get MCMSettings First
Event OnTimer(int aiTimerID)
	dLog(1,"In OnTimer()")
	GetMCMSettings()
;MCM should return modenabled=0 on fresh install
	if modEnabled
		If CountParts()<1
			RescanOutfitsINI()
		endif
	else
		dLog(1,"++++ NOT ENABLED, NOT SCANNING OUTFITS YET ++++")
	endif
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			if modEnabled
				dLog(1,"To TimerTrap()   "+MultCounter+"/"+LongMult)
				TimerTrap()
			else
				dLog(1,"++++ NOT ENABLED ++++")
			endif
		endif
	endif
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function TimerTrap()
	CancelTimer(ShortTimerID)
	Debug.OpenUserLog(OSLogName)
	GetMCMSettings()
	GameGetPlayer = Game.GetPlayer()
;try to keep it AAF friendly, but not dependant...
	UseAAF = False
	If Game.IsPluginInstalled("AAF.ESM")
		dLog(1,"Updating AAF Forms")
		AAF_ActiveActors = Game.GetFormFromFile(0x0098f4, "AAF.esm") as FormList
		AAF_Doppelganger = Game.GetFormFromFile(0x0072E2, "AAF.esm") as ActorBase
		AAF_EmptyOutfit = Game.GetFormFromFile(0x02b47d, "AAF.esm") as Outfit
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If !GoodOutfits.HasForm(AAF_EmptyOutfit)
			dLog(1,"Adding AAF_EmptyOutfit.")
			GoodOutfits.AddForm(AAF_EmptyOutfit)
		endif
		If AAFBusyKeyword != None
			UseAAF = True
		endif
	endif
	if MultCounter > LongMult-1
		MultCounter = 1
		ScanNPCs(True)
	else
		MultCounter += 1
		ScanNPCs(False)
	endif
	StartTimer(ShortTime, ShortTimerID)
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function ScanNPCs(bool Force=False)
	dLog(1,None+" in ScanNPCs()")
	If CountParts()>0
		int racecounter = 0
		While racecounter < OSActorRaces.GetSize()
			int i = 0
			ObjectReference[] kActorArray = GameGetPlayer.FindAllReferencesWithKeyword(OSActorRaces.GetAt(racecounter), ScanRange)
			while i < kActorArray.Length
				dlog(1,None+" Scanning NPCs... "+percentInt(i,kActorArray.length))
				Actor NPC = kActorArray[i] as Actor
				if CheckEligibility(NPC)
					dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Is Wearing "+NPC.GetLeveledActorBase().Getoutfit())
					if Force
						dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is being forced")
						SetSettlerOutfit(NPC)
					endif
					if !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
						dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" needs an outfit")
						SetSettlerOutfit(NPC)
					else
						dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in a good outfit")
					endif
				endif
				i += 1
			endwhile
			RaceCounter += 1
		endwhile
	else
		dLog(2,"NO PARTS IN LISTS")
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int Function CountParts()
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	;dLog(1,"=============================== "+OutfitPartsAdder+" items in outfit parts lists.")
	return OutfitPartsAdder
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function SetSettlerOutfit(Actor NPC)
	dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" In SetSettlerOutfit()")
	NPC.RemoveSpell(Maintainer)
	UnEquipItems(NPC)
	NPC.SetOutfit(EmptyOutfit2,false)
	NPC.SetOutfit(EmptyOutfit,false)
	SetOutfitFromParts(NPC)
	NPC.AddSpell(Maintainer)
	if OneShot
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Is getting DontChange from OneShot=True")
		NPC.AddKeyword(DontChange)
	endif
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function SetOutfitFromParts(Actor NPC)

	dLog(1,"In SetOutfitParts(). Setting from "+CountParts()+" parts in lists")
;Prefixing for males
	String NPCSex
	If NPC.GetLeveledActorBase().GetSex()==0
		NPCSex="XY"
	endif
;Prefixing for females
	If NPC.GetLeveledActorBase().GetSex()==1
		NPCSex="XX"
	endif
	dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" NPCSex="+NPCSex)
	If RandomBodyGen
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" will do BodyGen.RegenerateMorphs")
		BodyGen.RegenerateMorphs(NPC, true)
	endif
	If NPCUseScaling
		float NPCNewScale
		if NPCMinscale >= NPCMaxScale
			NPCNewScale=NPCMinScale
		else
			NPCNewScale = Utility.RandomFloat(NPCMinScale, NPCMaxScale)
		endif
		NPC.SetScale(NPCNewScale)
	endif
	If Utility.RandomInt(1,99)<PChance[PString.Find(NPCSex+"FullBody")] && PForm[PString.Find(NPCSex+"FullBody")].GetSize()>0
		Form RandomItem = PForm[PString.Find(NPCSex+"FullBody")].GetAt(Utility.RandomInt(0,PForm[PString.Find(NPCSex+"FullBody")].GetSize()))
		NPC.EquipItem(RandomItem)
		dLog(1,NPC+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
	else
		Int Counter=1
		While counter < PForm.Length
			If LL_FourPlay.StringFind(PString[Counter], NPCSex) == 0 && LL_FourPlay.StringFind(PString[Counter], "FullBody") == -1
				;dLog(1,NPC+"PString[Counter]="+PString[Counter]+" LL_FourPlay.StringFind(PString[Counter], NPCSex)="+LL_FourPlay.StringFind(PString[Counter], NPCSex))
				If PChance[Counter]>1 && PForm[Counter].GetSize()>0 && Utility.RandomInt(1,99)<PChance[counter]
					Form RandomItem = PForm[counter].GetAt(Utility.RandomInt(0,PForm[Counter].GetSize())) as Form
					If RandomItem != None
						dLog(1,NPC+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
						NPC.EquipItem(RandomItem)
					endif
				endif
			endif
		counter += 1
		endwhile
	endif
	
	
	If Utility.RandomInt(1,99)<PChance[PString.Find("WeaponsList")] && PForm[PString.Find("WeaponsList")].GetSize()>0
			Form RandomItem = PForm[PString.Find("WeaponsList")].GetAt(Utility.RandomInt(0,PForm[PString.Find("WeaponsList")].GetSize()))
			NPC.EquipItem(RandomItem)
			dLog(1,NPC+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
		endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bool Function CheckEligibility(Actor NPC)
	dLog(1,NPC+" NAME="+NPC.GetLeveledActorBase().GetName()+" is in CheckEligibility()")
;Not changing anyone with DontChange keyword
	If NPC.HasKeyword(DontChange)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" has DontChange keyword")
		return False
	endif
;Check for Armor Racks
	if LL_FourPlay.StringFind(NPC.GetLeveledActorBase().GetName(), "Armor Rack") != -1
		If NPC.HasKeyword(AlwaysChange)
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is NAMED 'Armor Rack', and is tagged AlwaysChange, so I guess that's an override?")
			return True
		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is NAMED 'Armor Rack' and wont be changed")
			return False
		endif
	endif
;Check for Wilma, by name. Probably quicker than GetFormFromFile on every check.	
	if LL_FourPlay.StringFind(NPC.GetLeveledActorBase().GetName(), "Wilma's Wigs") != -1 ; No touch. She has a ton of wigs in her inventory and gets all twitchy when she gets changed.
		If NPC.HasKeyword(AlwaysChange)
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is NAMED 'Wilma's Wigs', and is tagged AlwaysChange, so I guess that's an override? Be warned. This is a bad idea.")
			return True
		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is NAMED 'Wilma's Wigs' and won't be changed")
			return False
		endif
	endif
;check if MALE is disabled	
	If (NPC.GetLeveledActorBase().GetSex()==0&&!XYEnabled)
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+"'s Gender (Male) is Disabled")
		return False
	endif
;check if FEMALE is disabled
	If (NPC.GetLeveledActorBase().GetSex()==1&&!XXEnabled)
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+"'s Gender (Female) is Disabled")
		return False
	endif
;Not changing the player
	If NPC == GameGetPlayer
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is the Player")
		return False
	endif
;Deleted people don't need changed
	If NPC.IsDeleted()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is deleted")
		return False
	endif
;Disabled people don't need changed
	If NPC.IsDisabled()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is disabled")
		return False
	endif
;No touchy the power armor
	If PowerArmorCheck(NPC)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Talos II or Power Armor")
		return False
	endif
;Children don't need changed
	If NPC.IsChild()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is a child")
		return False
	endif
;Dead people don't need changed
	If NPC.IsDead()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is dead")
		return False
	endif
;did they/I move too far since the scan started?
	if GameGetPlayer.GetDistance(NPC) > ScanRange
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is now too far away")
		return False
	endif
;check against restricted factions
	If FactionsToIgnore.GetSize()
		Int i
		While i<FactionsToIgnore.GetSize()
			If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
				If !NPC.HasKeyword(AlwaysChange)
					dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Restricted Faction ("+(FactionsToIgnore.GetAt(i) as Faction)+") and WILL BE changed")
					return False
				else
					dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Restricted Faction ("+(FactionsToIgnore.GetAt(i) as Faction)+")")
				endif
			endif
		i += 1
		Endwhile
	endif
;check against AAF if enabled
	if UseAAF 
		if AAF_ActiveActors.HasForm(NPC)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is currently an AAF Actor")
			return false
		endif
		if NPC.HasKeyword(AAFBusyKeyword)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is flagged as BUSY by AAF")
			return false
		endif
		if NPC.GetActorBase() == AAF_Doppelganger
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is apparently an AAF DoppelGanger")
			return false
		endif
	endif
	
	dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is eligible to be changed")
	return true
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function UnEquipItems(Actor NPC)
	dLog(1,"In UnEquipItems()")
	Form[] InvItems = NPC.GetInventoryItems()
	int i=0

	If NPC.GetLeveledActorBase().GetSex()==0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If !XYSafeItems.HasForm(akItem) && ((akItem as Armor) || WeaponsList.HasForm(akItem))
				NPC.removeitem(akItem, -1)
				dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed "+akItem+akItem.GetName())
			endif
		i += 1
		EndWhile
	endif

	If NPC.GetLeveledActorBase().GetSex()==1
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If !XXSafeItems.HasForm(akItem) && ((akItem as Armor) || WeaponsList.HasForm(akItem))
				NPC.removeitem(akItem, -1)
				dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed "+akItem+akItem.GetName())
			endif
		i += 1
		EndWhile
	endif
	
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function GetMCMSettings()
	dLog(1,"Refreshing MCM Settings.")
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool
	XXEnabled = MCM.GetModSettingBool("OutfitShuffler", "bEnableXX:General") as Bool
	XYEnabled = MCM.GetModSettingBool("OutfitShuffler", "bEnableXY:General") as Bool
	OneShot = MCM.GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool
	NPCGetHeadParts = MCM.GetModSettingBool("OutfitShuffler", "bNPCGetHeadParts:General") as Bool ; Step 3 is everything in this file. I'm just working my way through.
	RandomBodyGen = MCM.GetModSettingBool("OutfitShuffler", "bRandomBodyGen:General") as Bool
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int
	LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as Int
	NPCUseScaling = MCM.GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool
	NPCMinScale = MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float
	NPCMaxScale = MCM.GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float
;OutfitChances
	Int counter = 0
	While counter < PForm.Length
		PChance[counter]=MCM.GetModSettingInt("OutfitShuffler", "iChance"+PString[counter]+":General") as Int
		counter += 1
	endwhile
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function ChangeNow()
	dLog(1,"In ChangeNow()")
	GetMCMSettings()
	Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC != None
		dLog(2,""+NPC.GetLeveledActorBase().GetName()+" will be changed from "+CountParts()+ " parts.")
		UnEquipItems(NPC)
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Setting outfit "+EmptyOutfit)
		NPC.SetOutfit(EmptyOutfit,false)
		SetOutfitFromParts(NPC)
	endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; At some point, this entire section became a vanity project.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function DebugNPC()
;FileOutput
	GetMCMSettings()
	Actor NPC = LL_FourPlay.LastCrossHairActor(); and then I forgot to move this after I mover the inventory up.
	If NPC
		Form[] InvItems = NPC.GetInventoryItems()
		int i=0
		string longinv
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
					Longinv += "\n   ****************INV: "+akItem+akItem.GetName()
			i += 1
		EndWhile
		dLog(2,"\n\n   ********************DebugNPC()"+"\n\n   ***************Name:"+NPC+NPC.GetLeveledActorBase().GetName()+"\n   ****************Sex:"+NPC+NPC.GetLeveledActorBase().GetSex()+"\n   ***************Race:"+NPC+NPC.GetLeveledActorBase().GetRace()+"\n   *********DontChange:"+NPC+NPC.HasKeyword(DontChange)+"\n   **********IsDeleted:"+NPC+NPC.IsDeleted()+"\n   *********IsDisabled:"+NPC+NPC.IsDisabled()+"\n   ****PowerArmorCheck:"+NPC+PowerArmorCheck(NPC)+"\n   ************IsChild:"+NPC+NPC.IsChild()+"\n   *************IsDead:"+NPC+NPC.IsDead()+"\n   ***********Distance:"+NPC+GameGetPlayer.GetDistance(NPC)+"\n"+longinv+"\n");;;;;; This whole contrivance, is vanity.
		If FactionsToIgnore.GetSize()
			i=0;I moved the inventory function above this, fixed the 'Int i' up there, but forgot to fix this line from 'Int i.' That tripped me up for about two minutes. Also corrected a minor type in dlog(.
			While i<FactionsToIgnore.GetSize()
				If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
					dLog(2,"   ***FactionsToIgnore:"+NPC+FactionsToIgnore.GetAt(i))
				endif
			i += 1
			Endwhile
		endif
	endif
endfunction

;FileOutput
;	dLog(1,"In ********************DebugNPC()")
;	GetMCMSettings()
;	Actor NPC = LL_FourPlay.LastCrossHairActor()
;	dLog(2,"   ***************Name:"+NPC+NPC.GetLeveledActorBase().GetName())
;	dLog(2,"   ****************Sex:"+NPC+NPC.GetLeveledActorBase().GetSex())
;	dLog(2,"   ***************Race:"+NPC+NPC.GetLeveledActorBase().GetRace())
;	dLog(2,"   *********DontChange:"+NPC+NPC.HasKeyword(DontChange))
;	dLog(2,"   **********IsDeleted"+NPC+NPC.IsDeleted())
;	dLog(2,"   *********IsDisabled:"+NPC+NPC.IsDisabled())
;	dLog(2,"   *****PowerArmorCheck:"+NPC+PowerArmorCheck(NPC))
;	dLog(2,"   ************IsChild:"+NPC+NPC.IsChild())
;	dLog(2,"   *************IsDead:"+NPC+NPC.IsDead())
;	dLog(2,"   ***********Distance:"+NPC+GameGetPlayer.GetDistance(NPC))
;	If FactionsToIgnore.GetSize()
;		Int i
;		While i<FactionsToIgnore.GetSize()
;			If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
;				dLog(2,"   ***FactionsToIgnore:"+NPC+FactionsToIgnore.GetAt(i))
;			endif
;		i += 1
;		Endwhile
;	endif
;	Form[] InvItems = NPC.GetInventoryItems()
;	int i=0
;	While (i < InvItems.Length)
;	Form akItem = InvItems[i]
;			dLog(2,"   ********************INV: "+akItem+akItem.GetName())
;	i += 1
;	EndWhile

;***********************************************************************
Function OutfitHotkey()
	GetMCMSettings()
	MultCounter = LongMult
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function DontChange()
	dLog(1,"In DontChange()")
	GetMCMSettings()
	Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC != None
		If NPC.HasKeyword(DontChange)
			NPC.RemoveKeyword(DontChange)
			NPC.AddKeyword(AlwaysChange)
			dLog(2,NPC.GetLeveledActorBase().GetName()+" will ignore faction exclusions. NPC.RemoveKeyword(DontChange) AddKeyword(AlwaysChange)")
			return
		endif
		If NPC.HasKeyword(AlwaysChange)
			NPC.RemoveKeyword(AlwaysChange)
			dLog(2,NPC.GetLeveledActorBase().GetName()+" WILL be changed. RemoveKeyword(AlwaysChange)")
			return
		endif
		NPC.AddKeyword(DontChange)
		dLog(2,NPC.GetLeveledActorBase().GetName()+" WILL NOT be changed. AddKeyword(DontChange)")
	endif
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function RandomBodygen()
Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC != None
		dlog(2,""+NPC+NPC.GetLeveledActorBase().GetName()+" will do BodyGen.RegenerateMorphs")
		BodyGen.RegenerateMorphs(NPC, true)
		If NPCUseScaling
			float NPCNewScale
			if NPCMinscale >= NPCMaxScale
				NPCNewScale=NPCMinScale
			else
				NPCNewScale = Utility.RandomFloat(NPCMinScale, NPCMaxScale)
			endif
			dlog(2,NPC+"Setting Scale to '"+NPCNewScale+"'")
			NPC.SetScale(NPCNewScale)
		endif
		dLog(1,NPC+"Scale and BodyGen updated")
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function NPCGetHeadParts();Is a leftover function, attached to a hotkey. I'm gonna keep it for a bit.
	if !ConsoleLogging
		ConsoleLogging=True
		dlog(2,"ConsoleLogging Enabled")
	else 
		ConsoleLogging=False
		dlog(2,"ConsoleLogging Disabled")
	endif
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function RescanOutfitsINI()
	String MasterINI = "OutfitShuffler.ini"
	canceltimer(ShortTimerID)
	dLog(2,"******* Stopping timers and rescanning outfit pieces *******")

;housekeeping
	BuildOutfitArray()
	GetMCMSettings()

	int AllSlotsCounter = 0
	int counter=0

;clear parts lists
	While counter < PForm.Length
		dLog(3,PercentInt(counter, PForm.Length)+" Reverting =>"+PString[Counter]+"<==  "+PForm[counter]+" Chance="+PChance[counter]+" Count="+PForm[counter].GetSize())
		PForm[counter].revert()
		counter += 1
	endwhile
	
;Get Outfit INI Files
	Var[] ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "InputFiles")
	Var[] Keys=Utility.VarToVarArray(ConfigOptions[0])
	int j=0
	While j<Keys.Length
		int ConfigOptionsInt=LL_FourPlay.GetCustomConfigOption_UInt32(MasterINI, "InputFiles", Keys[j]) as int
		if ConfigOptionsInt > 0
			dlog(4,"Scanning for new outfits...      "+PercentInt(j, keys.length));j+"/"+keys.length)
			ScanINI(Keys[j])
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
			dLog(3,Game.GetFormFromFile(ConfigOptionsInt, RaceKeys[j])+" Added to Races")
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
			dLog(3,Game.GetFormFromFile(ConfigOptionsInt, FactionsToIgnoreKeys[j])+" Added to FactionsToIgnore")
			FactionsToIgnore.AddForm(Game.GetFormFromFile(ConfigOptionsInt, FactionsToIgnoreKeys[j]))
		endif
	j += 1
	endwhile
	
	dLog(4,"Rescanning NPCs after update")

;Recheck MCM for outfit piece chances
	GetMCMSettings()

;rescan the NPCs
	ScanNPCs(True)
	
;restart the timer
	StartTimer(ShortTime, ShortTimerID)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function ScanINI(String INItoCheck)
	String INIpath = "OutfitShuffler\\" 
	String INIFile=INIpath+INItoCheck
	If Game.IsPluginInstalled(LL_FourPlay.StringSubstring(INIToCheck, 0, LL_FourPlay.StringFind(INIToCheck, ".ini", 0))) || INIToCheck == "Weapons.ini"
		String[] ChildINISections=LL_FourPlay.GetCustomConfigSections(INIFile) as String[]
		int ChildINISectionCounter=0
		if ChildINISections.Length > 0
			dlog(3, PercentInt(ChildINISectionCounter, ChildINISections.Length)+" Adding section ["+PString[PString.Find(ChildINISections[ChildINISectionCounter])]+"] from "+INIFile)
 			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=LL_FourPlay.GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=Utility.VarToVarArray(ChildConfigOptions[0])
				Var[] ChildValues=Utility.VarToVarArray(ChildConfigOptions[1])
				If ChildKeys.Length > 0
					int ChildKeysCounter=0
					While ChildKeysCounter < ChildKeys.Length
						int FormToAdd=ChildValues[ChildKeysCounter] as int
						if FormToAdd > 0
							int OutfitPartsCounter = 0
							If PString.Find(ChildINISections[ChildINISectionCounter]) > -1
								PForm[PString.Find(ChildINISections[ChildINISectionCounter])].AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]))
								dLog(1,INItoCheck+" "+PercentInt(ChildKeysCounter, ChildKeys.Length)+" added "+Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]).GetName()+" from "+ChildKeys[ChildKeysCounter]+" to "+PString[PString.Find(ChildINISections[ChildINISectionCounter])]+PForm[PString.Find(ChildINISections[ChildINISectionCounter])])
							endIf
						endif
						ChildKeysCounter += 1
					endwhile
				endif
			ChildINISectionCounter += 1
			endwhile
		else
			dLog(2,INIFile+" does not contain any sections")
		endif
	else
		dlog(2,LL_FourPlay.StringSubstring(INIToCheck, 0, LL_FourPlay.StringFind(INIToCheck, ".ini", 0))+" is not installed")
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.
;File Output
	If LogLevel == 0 && dLogLevel == 1
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
	endif
;File and Notification
	If LogLevel == 0 && dLogLevel == 2
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
		debug.Notification("[OS] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 0 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
	endif
;Higher Priority File and Notification
	If LogLevel == 0 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
		debug.Notification("[OS] "+LogMe)
	endif
;File Output
	If LogLevel == 1 && dLogLevel == 1
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
	endif
;File and Notification
	If LogLevel == 1 && dLogLevel == 2
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
		debug.Notification("[OS] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 1 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe,1)
	endif
;Higher Priority File and Notification
	If LogLevel == 1 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe,1)
		debug.Notification("[OS] "+LogMe)
	endif
;Just a notification
	If LogLevel == 0 && dLogLevel == 2
		debug.Notification("[OS] "+LogMe)
	endif
;Noisy Console
	If ConsoleLogging
		LL_FourPlay.PrintConsole("[OS] "+LogMe)
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function JustEndItAll()
	int counter=0
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
	debug.messagebox("This is irreversible, and you were warned. Save, exit, load (With missing OutfitShuffler.esl), save, exit. Reinstall or upgrade if desired.")
	OutfitShufflerQuest.Stop()
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool Function PowerArmorCheck(Actor NPC)
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is being checked for PowerArmor")
	if ((Game.IsPluginInstalled("PowerArmorLite.esp")) && NPC.IsEquipped(Game.GetFormFromFile(0xf9c,"PowerArmorLite.esp"))) || NPC.IsInPowerArmor()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Power Armor")
		return True
	endif
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is NOT in Power Armor or Talos II Armor")
	return false
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
String Function PercentInt(Int Part, Int Whole)
	String PercentString = (((Part*100)/Whole) as Int)+"%" as String
	Return PercentString
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int Function BodyCount()
	int CountedBodies
	int racecounter = 0
	While racecounter < OSActorRaces.GetSize()
		ObjectReference[] kActorArray = GameGetPlayer.FindAllReferencesWithKeyword(OSActorRaces.GetAt(racecounter), ScanRange)
		countedbodies += kActorArray.Length
		RaceCounter += 1
	endwhile
	return countedbodies
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function BuildOutfitArray()
	
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







; Fallout 4\Data\MCM\Config\OutfitShuffler\config.json notes. Had to remove comments. Broke Keybinds. 6.25 rel with diagnostic pre-release cleanup.
;	{
;      "id": "RandomBodyGen",;This function was complete was complete, before Step 0, of NPCGetHeadParts. This is Unreleased 6.24.
;      "desc": "This changes to a random BodyGen setting, but leaves the outfit the same.",
;	  "action": {
;			"type": "CallFunction",
;			"form": "OutfitShuffler.esl|0800",
;			"function": "RandomBodyGen",
;			"params": []
;	  }	
;    },
;		{
;      "id": "NPCGetHeadParts",;Very High. Edible. First try in game since starting this function. Incorrect id GetHeadParts. Is this actually Step 0 of this function? I've just decideded this is '6.25 rel with diagnostic', and will probably be released, for 6.24+ features, inc RandomBodyGen and Hotkey.
;     "desc": "This prints and logs HeadParts from targeted NPC." 
;	  "action": {
;			"type": "CallFunction",
;			"form": "OutfitShuffler.esl|0800",
;			"function": "NPCGetGeadParts", ;I couldn't just call it GetHeadParts. I'm betting that would break something. This is Step 1. Step 0 info: I got it right, here.
;			"params": []
;	  }	
;    }
;This will now be the third try, in-game. Unable to set hotkeys. then I commented the RandomBodyGen code, and broke the previously working hotkey. TIL.
;There was originally a double-backslash style comment block, that even when prefixed ';' on ever line, the last backslash broke the compiler. Papyrus Compiler Version 2.8.0.4 for Fallout 4. 6.25 rel with diagnostic pre-release cleanup, in-game test 4.
; keybinds.json "desc": "This prints and logs HeadParts from targeted NPC."    <== See, I forgot the comma. 6.25 rel with diagnostic pre-release cleanup, in-game test 5.

