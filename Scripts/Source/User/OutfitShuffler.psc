Scriptname OutfitShuffler extends Quest
{Handles INI Scanning, Radius Scanning, and Intitial Outfit Assignment to NPCs.}
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

Actor Property PlayerRef Auto Const

ActorValue Property OSMaintTime Auto
ActorValue Property OSBodyDone Auto
ActorValue Property OSMaintWait Auto
ActorValue Property NPCTimer Auto

Formlist Property FactionsToIgnore Auto
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const

Formlist Property OSActorRaces Auto
Formlist Property OSAllItems Auto
Formlist Property WeaponsList Auto
FormList Property XXSafeItems Auto
FormList Property XYSafeItems Auto

FormList Property OSXX auto;These FormLists will contain collections of formlists
Formlist Property OSXY auto

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

MiscObject Property OSDontChangeItem Auto Const
MiscObject Property OSAlwaysChangeItem Auto Const
MiscObject Property OSDontBodyGenItem Auto Const
MiscObject Property OSAlwaysBodyGenItem Auto Const
MiscObject Property OSDontScaleItem Auto Const
MiscObject Property OSAlwaysScaleItem Auto Const

Outfit Property EmptyOutfit Auto Const
Outfit Property ForceChangeOutfit Auto Const

Quest Property OutfitShufflerQuest Auto Const
Quest Property pMQ101 Auto Const mandatory

Spell Property ContainersSpell Auto Const
Spell Property Maintainer Auto Const

;Local variables
string OSLogName="OutfitShuffler"
int TimeID = 888
int MultCounter = 0
int RaceCounter


;Arrays
FormList[] PForm
String[] PString
Int[] PChance
ObjectReference[] kActorArray

;Imported Variables
FormList AAF_ActiveActors
ActorBase AAF_Doppelganger
Outfit AAF_EmptyOutfit
Keyword AAFBusyKeyword
Keyword DDRendered
Keyword DDInventory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnInit()
	dlog(2,"OutfitShuffler Installed")
	CancelTimer(TimeID)
	Debug.OpenUserLog(OSLogName)

;try to keep it AAF friendly, but not dependant...
	If Game.IsPluginInstalled("AAF.ESM") && (OSUseAAF.GetValueInt()==0)
		AAF_ActiveActors = Game.GetFormFromFile(0x0098f4, "AAF.esm") as FormList
		AAF_Doppelganger = Game.GetFormFromFile(0x0072E2, "AAF.esm") as ActorBase
		AAF_EmptyOutfit = Game.GetFormFromFile(0x02b47d, "AAF.esm") as Outfit
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword

		If !GoodOutfits.HasForm(AAF_EmptyOutfit)
			dlog(1,"Adding AAF_EmptyOutfit.")
			GoodOutfits.AddForm(AAF_EmptyOutfit)
		endif

	endif

	If !Game.IsPluginInstalled("AAF.ESM")
		OSUseAAF.SetValueInt(0)
		AAF_ActiveActors=None
		AAF_Doppelganger=None
		AAF_EmptyOutfit=None
		AAFBusyKeyword=None
		dlog(1,"No AAF.ESM")
	endif

	If AAFBusyKeyword != None
		OSUseAAF.SetValueInt(1)
	endif

;Keep it DD friendly, but not dependant...
	If OSUseDD.GetValueInt()==0 && Game.IsPluginInstalled("Devious Devices.esm")
		dlog(1,"Attempting to use Devious Devices")
		DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
		dlog(1,"DDRendered Keyword="+DDRendered)
		DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
		dlog(1,"DDInventory Keyword="+DDInventory)

		if DDRendered && DDInventory
			OSUseDD.SetValueInt(1)
			dlog(1,"UseDD Bool="+OSUseDD.GetValueInt())
		endif

	endif

	if !Game.IsPluginInstalled("Devious Devices.esm")
		DDRendered=None
		DDInventory=None
		OSUseDD.SetValueInt(0)
		dlog(1,"No Devious Devices.ESM")
	endif
	
	starttimer((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Catch timer events
;6.0 New Order in ontimer; get MCMSettings First
Event OnTimer(int aiTimerID)
	if (MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==1)
		If CountParts()<1 && !pMQ101.IsRunning()
			RescanOutfitsINI()
		endif
		OSSuspend.SetValueInt(0)
	else
		dLog(1,"++++ NOT ENABLED, NOT SCANNING OUTFITS YET ++++")
		PlayerRef.RemoveSpell(ContainersSpell)
		OSSuspend.SetValueInt(1)
	endif
	If pMQ101.IsRunning()
		utility.wait(Utility.RandomFloat(0.5,2.0))
		return
	else
		if aiTimerID == TimeID
			if (MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==1)
				RegisterForPlayerTeleport()
				dLog(1,"To TimerTrap()   "+(MultCounter+1)+"/"+(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)+" ***")
				If !PlayerRef.HasSpell(ContainersSpell) && (MCM.GetModSettingBool("OutfitShuffler", "bUseContainers:General") as Bool==1)
					PlayerRef.AddSpell(ContainersSpell)
					dlog(2,"Added Spell "+ContainersSpell+" to "+PlayerRef)
				endif
				If !(MCM.GetModSettingBool("OutfitShuffler", "bUseContainers:General") as Bool==1)
					PlayerRef.RemoveSpell(ContainersSpell)
					dlog(2,"Removed Spell "+ContainersSpell+" from "+PlayerRef)
				endif
				float TimerStart=Utility.GetCurrentRealTime()
				TimerTrap()
				dlog(1,"TimerTrap("+MultCounter+") run in "+(Utility.GetCurrentRealTime()-TimerStart)+" seconds")
			else
				UnRegisterForPlayerTeleport()
				PlayerRef.RemoveSpell(ContainersSpell)
				dlog(2,"Removed Spell "+ContainersSpell+" from "+PlayerRef)
				dLog(1,"++++ NOT ENABLED ++++")
			endif
		endif
	endif
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function TimerTrap()
	CancelTimer(TimeID)
	If MultCounter>(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)
		MultCounter=0
		ScanNPCs(True)
	else
		MultCounter+=1
		ScanNPCs(false)
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function ScanNPCs(bool Force=False)
	if OSSuspend.GetValueInt() == 0 && CountParts()>1
		RaceCounter = 0
		While RaceCounter < OSActorRaces.GetSize()
			int iActorArray = 0
			if OSActorRaces.GetAt(RaceCounter) != None
				kActorArray = PlayerRef.FindAllReferencesWithKeyword(OSActorRaces.GetAt(RaceCounter), (MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float))
				while iActorArray < kActorArray.Length && OSSuspend.GetValueInt() == 0
					
					Actor NPC = kActorArray[iActorArray] as Actor
					;dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is being checked...")
					If NPC != PlayerRef
						int MaintTimer=(NPC.GetValue(OSMaintTime) as Int)+((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as int)*(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General")) as Int)
						NPC.RemoveSpell(Maintainer)
						if CheckEligibility(NPC)
							if (((Utility.GetCurrentRealTime()as Int)>MaintTimer) || ((Utility.GetCurrentRealTime() as Int)>NPC.GetValue(OSMaintTime)))&&NPC.GetItemCount(OSDontChangeItem)
								utility.wait(utility.randomint(1,3))
								dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is doing Spell Reset")
								NPC.AddSpell(Maintainer)
							endif
							string ddlog="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"   ********OSMaintWait="+NPC.Getvalue(OSMaintWait)
							if (MaintTimer<(Utility.GetCurrentRealTime() as Int))
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"   *******OSMaintTime+="+MaintTimer
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"   ********CurrentTime="+Utility.GetCurrentRealTime()
								NPC.SetValue(OSMaintWait,1)
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" needs an outfit"
								dlog(1,ddlog)
								;SetOutfitFromParts(NPC)
								Var[] params = new Var[1]
								params[0] = NPC
								Self.CallFunction("SetOutfitFromParts",params)
							elseIf !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"   *************Outfit="+NPC.GetLeveledActorBase().Getoutfit()+NPC.GetLeveledActorBase().Getoutfit().GetName()
								NPC.SetValue(OSMaintWait,1)
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" needs an outfit"
								dlog(1,ddlog)
								;SetOutfitFromParts(NPC)
								Var[] params = new Var[1]
								params[0] = NPC
								Self.CallFunction("SetOutfitFromParts",params)
							elseif Force
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"   **************Force="+NPC.Getvalue(OSMaintWait)
								NPC.SetValue(OSMaintWait,1)
								ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" needs an outfit"
								dlog(1,ddlog)
								;SetOutfitFromParts(NPC)
								Var[] params = new Var[1]
								params[0] = NPC
								Self.CallFunction("SetOutfitFromParts",params)
							endif
						endif
						If NPC.GetLeveledActorBase().Getoutfit()==ForceChangeOutfit
							NPC.SetValue(OSMaintWait,1)
							dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" has ForceChangeOutfit")
							;SetOutfitFromParts(NPC)
							Var[] params = new Var[1]
							params[0] = NPC
							Self.CallFunction("SetOutfitFromParts",params)
						endif
					endif
					
				iActorArray+=1
				endwhile
			endif
		RaceCounter += 1
		endwhile
	endif
	StartTimer((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
int Function CountParts(Bool Speak=False)
	Int OutfitPartsCounter
	Int OutfitPartsAdder
	While OutfitPartsCounter < PForm.Length
		OutfitPartsAdder=OutfitPartsAdder+PForm[OutfitPartsCounter].GetSize()
		OutfitPartsCounter += 1
	endwhile
	If Speak
		dLog(1,"=== "+OutfitPartsAdder+" items in outfit parts lists. "+OSAllItems.GetSize()+ " in OSAllItems")
	endif
	return OutfitPartsAdder
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddDontChangeItem()
	PlayerRef.additem(OSDontChangeItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddAlwaysChangeItem()
	PlayerRef.additem(OSAlwaysChangeItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddDontBodyGenItem()
	PlayerRef.additem(OSDontBodyGenItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddAlwaysBodyGenItem()
	PlayerRef.additem(OSAlwaysBodyGenItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddDontScaleItem()
	PlayerRef.additem(OSDontScaleItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function AddAlwaysScaleItem()
	PlayerRef.additem(OSAlwaysScaleItem,25)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function SetOutfitFromParts(Actor NPC)
	NPC.SetValue(NPCTimer,Utility.GetCurrentRealTime())
	FormList SafeForm
	String NPCSex
	
	If NPC.GetLeveledActorBase().GetSex()==0
		SafeForm = XYSafeItems
		NPCSex="XY"
	endif
	
	If NPC.GetLeveledActorBase().GetSex()==1
		SafeForm = XXSafeItems
		NPCSex="XX"
	endif
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Calling UnequipItems() from SetOutfitFromParts()")
	UnequipItems(NPC)
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Returning to SetOutfitFromParts() from UnequipItems()")
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting Outfit Assignment")

;Do NewScale
	If ((MCM.GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool==True) && !(NPC.GetValue(OSBodyDone)==1))||NPC.GetItemCount(OSAlwaysScaleItem)>0
		float NPCNewScale = 1.0
		if (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float) >= (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float)
			NPCNewScale=(MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float)
		else
			NPCNewScale = Utility.RandomFloat((MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float), (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float))
		endif
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" will do NewScale="+NPCNewScale)
		NPC.SetScale(NPCNewScale)
	endif

;Do BodyGen
	If ((MCM.GetModSettingBool("OutfitShuffler", "bRandomBodyGen:General") as Bool==True) && !(NPC.GetValue(OSBodyDone)==1))||NPC.GetItemCount(OSAlwaysBodyGenItem)>0
		BodyGen.RegenerateMorphs(NPC, true)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is doing BodyGen")
		if (MCM.GetModSettingBool("OutfitShuffler", "bBodygenOneShot:General") as Bool==True)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is getting OSBodyDone from BodyGenOneShot=True")
			NPC.SetValue(OSBodyDone,1)
		endif
	endif

;Assign Items and Equip
	If Utility.RandomInt(1,99)<PChance[PString.Find(NPCSex+"FullBody")] && PForm[PString.Find(NPCSex+"FullBody")].GetSize()>0
		Form RandomItem = PForm[PString.Find(NPCSex+"FullBody")].GetAt(Utility.RandomInt(0,PForm[PString.Find(NPCSex+"FullBody")].GetSize()))
		NPC.EquipItem(RandomItem)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
	else
		Int Counter=1
		While counter < PForm.Length
			If (LL_FourPlay.StringFind(PString[Counter], NPCSex) == 0) && (LL_FourPlay.StringFind(PString[Counter], "FullBody") == -1) && PChance[Counter]>1 && PForm[Counter].GetSize()>0 && Utility.RandomInt(1,99)<PChance[counter]
				Form RandomItem = PForm[counter].GetAt(Utility.RandomInt(0,PForm[Counter].GetSize())) as Form
				If RandomItem != None
					dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
					NPC.EquipItem(RandomItem)
				endif
			endif
		counter += 1
		endwhile
	endif
	
;assign weapon
	If Utility.RandomInt(1,99)<PChance[PString.Find("WeaponsList")] && PForm[PString.Find("WeaponsList")].GetSize()>0
		Form RandomItem = None
		While RandomItem as Weapon == None
			RandomItem = PForm[PString.Find("WeaponsList")].GetAt(Utility.RandomInt(0,PForm[PString.Find("WeaponsList")].GetSize()))
		endwhile
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+"("+NPCSex+") got "+RandomItem+" "+RandomItem.GetName())
		NPC.EquipItem(RandomItem)
	endif

	utility.wait(utility.RandomFloat(0.5,2.0))
;Clean up the mess
	Form[] InvItems = NPC.GetInventoryItems()
	Bool WearingDD
	int i
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting Base/DLC Items Removal")
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		If (akItem as Armor) && (!OSAllItems.HasForm(akItem as ObjectReference) || !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference)) && (0<akItem.getformid() && akItem.getformid()<0x07000000) && !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
			NPC.removeitem(akItem,-1)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" removed")
		endif
	i += 1
	EndWhile
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Finished Base/DLC Items Removal")

	InvItems = NPC.GetInventoryItems()
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting Regular Items Equipping")
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		If (akItem as Armor) && akItem.getformid()>0x06FFFFFF && (!(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference))
			NPC.equipitem(akItem)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" equipped")
		endif
	i += 1
	endwhile
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Finished Regular Items Equipping")

	InvItems = NPC.GetInventoryItems()
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting SafeItems Equipping")
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
		if SafeForm.HasForm(akItem as ObjectReference)
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" is in SafeItems")
			NPC.EquipItem(akItem)
			endif
	i += 1
	endwhile
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Finished SafeItems Equipping")

	InvItems = NPC.GetInventoryItems()
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting Devious Devices Equipping")
	i=0
	While (i < InvItems.Length)
		Form akItem = InvItems[i] as Armor
		if akItem!=None
			if (OSUseDD.GetValueInt()>0) &&\
			(akItem.HasKeyword(DDRendered)||\
			(akItem.HasKeyword(DDInventory)))
				if NPC.IsEquipped(akItem)
					WearingDD=True
							dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" is wearing DD="+akItem+akItem.GetName())
				else
					WearingDD=True
							npc.equipitem(akItem)
					dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" FORCE equipped DD="+akItem+akItem.GetName())
				endif
			endif
		endif
		i += 1
	endwhile
	
	if WearingDD && NPC.GetItemCount(OSDontChangeItem)==0
		NPC.AddItem(OSDontChangeItem,1,true)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" DontChange added because of DD.")
	endif
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Finished Devious Devices Equipping")
	Utility.Wait(Utility.RandomFloat(0.5,2.0))
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Starting Removing Extra Items")
	i=0

	InvItems = NPC.GetInventoryItems()
	While (i < InvItems.Length) && NPC.GetItemCount(OSDontChangeItem)==0
		Form akItem = InvItems[i]
		If (akItem as Armor)
			if !NPC.IsEquipped(akItem)
					dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed conflict item "+akItem+akItem.GetName())
				NPC.RemoveItem(akItem, -1)
			endif
		endif
	i += 1
	EndWhile

	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Finished Removing Extra Items")
	
	Utility.Wait(Utility.RandomFloat(0.5,2.0))

	InvItems = NPC.GetInventoryItems()
	i=0
	int ArmorItems
	While (i < InvItems.Length)
		Form akItem = InvItems[i]
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Item="+akItem+akitem.getname()+" IsEquipped="+NPC.IsEquipped(akItem))
			If (akItem as Armor)!=None && NPC.IsEquipped(akItem)
				ArmorItems+=1
			endif
		i += 1
	EndWhile	

	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" has "+ArmorItems+" ArmorItems. NoNudes="+(MCM.GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool))

	if NPC.GetItemCount(OSDontChangeItem)==0 && ArmorItems==0 && (MCM.GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" not enough armor in inventory("+ArmorItems+"), resetting outfit.")
		NPC.SetOutfit(ForceChangeOutfit)
		NPC.SetValue(OSMaintWait,0)
		return
	endif

	if (MCM.GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) && NPC.GetItemCount(OSDontChangeItem)<1
		NPC.AddItem(OSDontChangeItem,1)
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Added OSDontChangeItem")
	endif
	dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" completed outfit assignment in "+(Utility.GetCurrentRealTime()-NPC.GetValue(NPCTimer))+" seconds")

	NPC.SetOutfit(ForceChangeOutfit,false)
	NPC.SetOutfit(EmptyOutfit)
	NPC.SetValue(OSMaintTime,Utility.GetCurrentRealTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.AddSpell(Maintainer)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bool Function CheckEligibility(Actor NPC)

	If NPC.IsDisabled()|| NPC.IsDeleted()||NPC.IsChild()||NPC.IsDead()
		return false
	endif

;Check for Armor Racks
	if LL_FourPlay.StringFind(NPC.GetLeveledActorBase().GetName(), "Armor Rack") != -1
		return False
	endif

;Check for Wilma, by name. Probably quicker than GetFormFromFile on every check.	
	if LL_FourPlay.StringFind(NPC.GetLeveledActorBase().GetName(), "Wilma's Wigs") != -1 ; No touch. She has a ton of wigs in her inventory and gets all twitchy when she gets changed.
		return False
	endif

;Not changing anyone with DontChange keyword
;	if (NPC.GetValue(OSMaintTime)+(MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float)*(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int))<Utility.GetCurrentRealTime()
;		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" OSMaintTime<GetCurrentRealTime and shouldn't be. Overriding OSDontChangeItem")
;		return true
;	else

	if NPC.GetValue(OSMaintTime)==0 && NPC.GetValue(OSMaintWait)==0
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" OSMaintTime==0 and shouldn't. Overriding OSDontChangeItem")
		NPC.SetOutfit(ForceChangeOutfit)
		return true
	endif

	If NPC.GetValue(OSMaintWait)==1
		return False
	endif

	If (NPC.GetItemCount(OSDontChangeItem)>0)
		return False
	endif

;check if MALE is disabled	
	If (NPC.GetLeveledActorBase().GetSex()==0&&(MCM.GetModSettingBool("OutfitShuffler", "bEnableXY:General") as Bool==0))
		return False
	endif

;check if FEMALE is disabled
	If (NPC.GetLeveledActorBase().GetSex()==1&&(MCM.GetModSettingBool("OutfitShuffler", "bEnableXX:General") as Bool==0))
		return False
	endif

;did they/I move too far since the scan started?
	if PlayerRef.GetDistance(NPC) > (MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float)
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
					return False
				endif

			endif

		i += 1
		Endwhile

	endif

;check against AAF if enabled
	if (OSUseAAF.GetValueInt()==1) 

		if AAF_ActiveActors.HasForm(NPC)
			return false
		endif

		if NPC.HasKeyword(AAFBusyKeyword)
			return false
		endif

		if NPC.GetActorBase() == AAF_Doppelganger
			return false
		endif

	endif
	
	return true
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function UnEquipItems(Actor NPC)
	if OSSuspend.GetValueInt()==1
		While OSSuspend.GetValueInt()==1
			utility.wait(utility.RandomFloat(0.5,2.0))
		endwhile
	else
		FormList SafeForm
		If NPC.GetLeveledActorBase().GetSex()==0
			SafeForm = XYSafeItems
		endif
		If NPC.GetLeveledActorBase().GetSex()==1
			SafeForm = XXSafeItems
		endif
		Form[] InvItems = NPC.GetInventoryItems()
		int i=0
		dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+"\n In UnEquipItems()")
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If ((OSUseDD.GetValueInt()==1) && (akItem.HasKeyword(DDRendered) || akItem.HasKeyword(DDInventory))) || SafeForm.HasForm(akItem)
				dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" NOT REMOVING "+akItem+akItem.GetName()+" UseDD="+OSUseDD.GetValueInt()+" DDRendered="+akItem.HasKeyword(DDRendered)+" DDInventory="+akItem.HasKeyword(DDInventory))
				if !NPC.IsEquipped(akItem)
					NPC.EquipItem(akItem)
				endif
			elseif (akItem as Armor) || WeaponsList.HasForm(akItem)
				NPC.removeitem(akItem, -1)
				dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed "+akItem+akItem.GetName())
			endif
		i += 1
		EndWhile	
	endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function GetOutfitChances()
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
;	dLog(1,"In ChangeNow()")
	GetOutfitChances()
	Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC != None
		dLog(1,NPC+""+NPC.GetLeveledActorBase().GetName()+" is in ChangeNow()")
		;SetOutfitFromParts(NPC); Gonna try this the fancy way.
		Var[] params = new Var[1]
		params[0] = NPC
		Self.CallFunction("SetOutfitFromParts",params)
		dLog(1,NPC+""+NPC.GetLeveledActorBase().GetName()+" finished ChangeNow()")
	endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; At some point, this entire section became a vanity project.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function DebugNPC()
;FileOutput
	Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC
		Form[] InvItems = NPC.GetInventoryItems()
		int i=0
		string longinv
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
				Longinv += "\n       INV: IsEquipped="+NPC.IsEquipped(akitem)+akItem+akItem.GetName()
				If akItem.HasKeyword(DDRendered) || akItem.HasKeyword(DDInventory)
					LongInv += " is a Devious Device"
				endif
			i += 1
		EndWhile
		int MaintTimer=(NPC.GetValue(OSMaintTime) as Int)+((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as int)*(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General")) as Int)
		String ddlog="\n   ***************DebugNPC()***************"
		ddlog+="\n   ***************Name:"+NPC+NPC.GetLeveledActorBase().GetName()
		ddlog+="\n   ****************Sex:"+NPC+NPC.GetLeveledActorBase().GetSex()
		ddlog+="\n   ***************Race:"+NPC+NPC.GetLeveledActorBase().GetRace()
		ddlog+="\n   *********DontChange:"+NPC+NPC.GetItemCount(OSDontChangeItem)
		ddlog+="\n   *********OSBodyDone:"+NPC+NPC.GetValue(OSBodyDone)
		ddlog+="\n   ********OSMaintWait:"+NPC+NPC.GetValue(OSMaintWait)
		ddlog+="\n   ********OSMaintTime:"+NPC+NPC.GetValue(OSMaintTime)
		ddlog+="\n   **********IsDeleted:"+NPC+NPC.IsDeleted()
		ddlog+="\n   *********IsDisabled:"+NPC+NPC.IsDisabled()
		ddlog+="\n   ****PowerArmorCheck:"+NPC+PowerArmorCheck(NPC)
		ddlog+="\n   ************IsChild:"+NPC+NPC.IsChild()
		ddlog+="\n   *************IsDead:"+NPC+NPC.IsDead()
		ddlog+="\n   ***********Distance:"+NPC+PlayerRef.GetDistance(NPC)
		ddlog+="\n   *******OSMaintTime+="+MaintTimer
		ddlog+="\n   ********CurrentTime="+Utility.GetCurrentRealTime()
		ddlog+="\n   ********OSMaintWait="+NPC.Getvalue(OSMaintWait)
		ddlog+="\n   *************Outfit="+NPC.GetLeveledActorBase().Getoutfit()+NPC.GetLeveledActorBase().Getoutfit().GetName()
		ddlog+="\n   ***********FCOutfit="+ForceChangeOutfit
		ddlog+="\n"+longinv+"\n"
		If FactionsToIgnore.GetSize()
			i=0
			While i<FactionsToIgnore.GetSize()
				If NPC.IsInFaction(FactionsToIgnore.GetAt(i) as Faction)
					ddlog+="\n   ***FactionsToIgnore:"+NPC+FactionsToIgnore.GetAt(i)
				endif
			i += 1
			Endwhile
		endif
		ddlog="\n   ************Finish DebugNPC()***********"
		dlog(1,ddlog)
	endif
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function OutfitHotkey()
	GetOutfitChances()
	MultCounter = (MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General") as Int)
EndFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function DontChange()
	Actor NPC = LL_FourPlay.LastCrossHairActor()
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function RandomBodygen()
Actor NPC = LL_FourPlay.LastCrossHairActor()
	If NPC != None
		dlog(2," will do BodyGen.RegenerateMorphs")
		If NPC.GetItemCount(OSDontBodyGenItem)==0
			BodyGen.RegenerateMorphs(NPC, true)
		endif
		If (MCM.GetModSettingBool("OutfitShuffler", "bNPCUseScaling:General") as Bool==1)||NPC.GetItemCount(OSAlwaysScaleItem)
			float NPCNewScale
			if (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float) >= (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float)
				NPCNewScale=(MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float)
			else
				NPCNewScale = Utility.RandomFloat((MCM.GetModSettingFloat("OutfitShuffler", "fNPCMinScale:General") as Float), (MCM.GetModSettingFloat("OutfitShuffler", "fNPCMaxScale:General") as Float))
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
Function RescanOutfitsINI()
;Stop OSMaintainer script
	OSSuspend.SetvalueInt(1)
	float RescanTimer=Utility.GetCurrentRealTime()
	If Game.IsPluginInstalled("Devious Devices.esm") && !(OSUseDD.GetValueInt()==1)
		;dlog(1,"Attempting to use Devious Devices")
		DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
		;dlog(1,"DDRendered Keyword="+DDRendered)
		DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
		;dlog(1,"DDInventory Keyword="+DDInventory)
		if DDRendered && DDInventory
			OSUseDD.SetValueInt(1)
		endif
	endif
	String MasterINI = "OutfitShuffler.ini"
	canceltimer(TimeID)
	dLog(2,"*** Stopping timers and rescanning outfit pieces ***")

;housekeeping
	BuildOutfitArray()

	int AllSlotsCounter = 0
	int counter=0

;clear parts lists
	OSAllItems.Revert()
	While counter < PForm.Length
		dLog(1," Reverting =>"+PString[Counter]+"<==  "+PForm[counter]+" Chance="+PChance[counter]+" Count="+PForm[counter].GetSize()+PercentString(counter, PForm.Length))
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
			dlog(2,"Scanning for new outfits...      "+PercentString(j, keys.length));j+"/"+keys.length)
			ScanINI(Keys[j])
		endif
	j += 1
	endwhile

;Get Races; Updated to Understand Hex
	ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "Races")
	if ConfigOptions.Length!=0
		Var[] RaceKeys=Utility.VarToVarArray(ConfigOptions[0])
		Var[] RaceValues=Utility.VarToVarArray(ConfigOptions[1])
		j=0
		OSActorRaces.Revert()
		int FormToAdd
		if RaceKeys.length>0
			While j<RaceKeys.Length
				if LL_FourPlay.StringFind(RaceValues[j],"0x")>-1
					string[] FormToAddLeft=LL_FourPlay.StringSplit(RaceValues[j],";")
					string[] FormToAddHex=LL_FourPlay.StringSplit(FormToAddLeft[0],"x")
					FormToAdd=LL_FourPlay.HexStringToInt("0x"+FormToAddHex[1]) as Int
				else
					FormToAdd=RaceValues[j] as int
				endif
				if FormToAdd > 0
					dLog(1,Game.GetFormFromFile(FormToAdd, RaceKeys[j])+" Added to Races")
					OSActorRaces.AddForm(Game.GetFormFromFile(FormToAdd,RaceKeys[j]))
				endif
			j += 1
			endwhile
		endif
	endif

;Get FactionsToIgnore; Updated to Understand Hex
	ConfigOptions=LL_FourPlay.GetCustomConfigOptions(MasterINI, "FactionsToIgnores")
	if ConfigOptions.Length!=0
		Var[] FactionsToIgnoreKeys=Utility.VarToVarArray(ConfigOptions[0])
		Var[] FactionsToIgnoreValues=Utility.VarToVarArray(ConfigOptions[1])
		j=0
		FactionsToIgnore.Revert()
		int FormToAdd
		if FactionsToIgnoreKeys.Length>0
			While j<FactionsToIgnoreKeys.Length
				if LL_FourPlay.StringFind(FactionsToIgnoreValues[j],"0x")>-1
					string[] FormToAddLeft=LL_FourPlay.StringSplit(FactionsToIgnoreValues[j],";")
					string[] FormToAddHex=LL_FourPlay.StringSplit(FormToAddLeft[0],"x")
					FormToAdd=LL_FourPlay.HexStringToInt("0x"+FormToAddHex[1]) as Int
				else
					FormToAdd=FactionsToIgnoreValues[j] as int
				endif
				if FormToAdd > 0
					dLog(1,Game.GetFormFromFile(FormToAdd, FactionsToIgnoreKeys[j])+" Added to FactionsToIgnores")
					FactionsToIgnore.AddForm(Game.GetFormFromFile(FormToAdd,FactionsToIgnoreKeys[j]))
				endif
			j += 1
			endwhile
		endif
	endif
	
;restart OSMaintainer
	GetOutfitChances()
	dlog(2,"Outfit Scan completed in "+(Utility.GetCurrentRealTime()-RescanTimer)+" seconds.")
	OSSuspend.SetValueInt(0)
	
;restart the timer
	StartTimer((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float), TimeID)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function ScanINI(String INItoCheck)
	String INIpath = "OutfitShuffler\\" 
	String INIFile=INIpath+INItoCheck
	int ScanINICounter
	If Game.IsPluginInstalled(LL_FourPlay.StringSubstring(INIToCheck, 0, LL_FourPlay.StringFind(INIToCheck, ".ini", 0))) || INIToCheck == "Weapons.ini"
		String[] ChildINISections=LL_FourPlay.GetCustomConfigSections(INIFile) as String[]
		int ChildINISectionCounter=0
		int WholeINI
		String WholeINIDebug
		if ChildINISections.Length > 0
			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=LL_FourPlay.GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=Utility.VarToVarArray(ChildConfigOptions[0])
				WholeINI += ChildKeys.Length
				ChildINISectionCounter+=1
			endwhile
		endif
		ChildINISectionCounter=0
		if ChildINISections.Length > 0
			dLog(1, "Adding "+INIFile)
 			While ChildINISectionCounter<ChildINISections.Length
				Var[] ChildConfigOptions=LL_FourPlay.GetCustomConfigOptions(INIFile, ChildINISections[ChildINISectionCounter])
				Var[] ChildKeys=Utility.VarToVarArray(ChildConfigOptions[0])
				Var[] ChildValues=Utility.VarToVarArray(ChildConfigOptions[1])
				If ChildKeys.Length > 0
					int ChildKeysCounter=0
					While ChildKeysCounter < ChildKeys.Length
						string FormToAddString=ChildValues[ChildKeysCounter] as String
						int FormToAdd
						if LL_FourPlay.StringFind(FormToAddString,"0x")>-1
							string[] FormToAddLeft=LL_FourPlay.StringSplit(FormToAddString,";")
							string[] FormToAddHex=LL_FourPlay.StringSplit(FormToAddLeft[0],"x")
							;dlog(1,"Hex=0x"+FormToAddHex[1])
							FormToAdd=LL_FourPlay.HexStringToInt("0x"+FormToAddHex[1]) as Int
							;dlog(1,"FormToAdd="+LL_FourPlay.HexStringToInt(FormToAddHex[1]))
						else
							FormToAdd=ChildValues[ChildKeysCounter] as int
						endif
						if FormToAdd > 0
							If PString.Find(ChildINISections[ChildINISectionCounter]) > -1
								Form TempItem=Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter])
								PForm[PString.Find(ChildINISections[ChildINISectionCounter])].AddForm(TempItem)
								if TempItem!=None
									If  !((OSUseDD.GetValueInt()==1) &&\
									(TempItem.HasKeyword(DDRendered) ||\
									TempItem.HasKeyword(DDInventory)))
										OSAllItems.AddForm(Game.GetFormFromFile(FormToAdd,ChildKeys[ChildKeysCounter]))
									endif
								endif
								ScanINICounter+=1
								dLog(1,INItoCheck+" "+TempItem+"==>"+PString[PString.Find(ChildINISections[ChildINISectionCounter])]+" "+PercentString(ScanINICounter, WholeINI))
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
	Int LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int

	If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
		debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe,1)
	endif

	If dLogLevel > 1
		debug.Notification("[OS] "+LogMe)
	endif

	If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 2 || dLogLevel == 2
		LL_FourPlay.PrintConsole("[OS] "+LogMe)
	endif
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function JustEndItAll()
	int counter=0
	OSAllItems.Revert()
	While counter < PForm.Length
		PForm[counter].revert()
		counter += 1
	endwhile
	debug.messagebox("This is irreversible, and you were warned./nSave, exit, load (With missing OutfitShuffler.esl), save, exit.\nReinstall or upgrade if desired.")
	OSSuspend.SetValueInt(1)
	OutfitShufflerQuest.Stop()
endFunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool Function PowerArmorCheck(Actor NPC)
	if NPC.IsInPowerArmor()
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Power Armor")
		return True
	endif
	if Game.IsPluginInstalled("PowerArmorLite.esp")
		if NPC.IsEquipped(Game.GetFormFromFile(0xf9c,"PowerArmorLite.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x1806,"PowerArmorLite.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x18a7,"PowerArmorLite.esp"))
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Talos II Armor")
			return True
		endif
	endif
	if Game.IsPluginInstalled("PowerArmorLiteReplacer.esp")
		if NPC.IsEquipped(Game.GetFormFromFile(0x806,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x807,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x808,"PowerArmorLiteReplacer.esp")) || NPC.IsEquipped(Game.GetFormFromFile(0x80a,"PowerArmorLiteReplacer.esp"))
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in Talos II Armor")
			return True
		endif
	endif
	return false
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
String Function PercentString(Int Part, Int Whole)
	String PercentString = " -- "+((((Part*100)/Whole) as Int) as String)+" percent complete"
	Return PercentString
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnPlayerTeleport()
	kActorArray=None
	RaceCounter=999999
EndEvent
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