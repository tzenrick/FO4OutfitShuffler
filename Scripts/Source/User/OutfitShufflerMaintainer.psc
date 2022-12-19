Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
{Attempts to maintain outfits assigned by the OutfitShuffler Main Script.}
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
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
Actor NPC

int MultCounter
int RaceCounter
string OSLogName="OutfitShuffler"

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

Spell EBCC_DirtTier01
Spell EBCC_DirtTier02
Spell EBCC_DirtTier03

int tid=5309
bool localhold
String ddlog

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnInit()
	StartTimer(1.0,tID)
	localhold=false
EndEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnTimer(int TimerID)
	If TimerID==tID
		if (MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==0) || NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled()
			dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Removing Maintenance Spell")
			NPC.RemoveSpell(Maintainer)
			return
		endif
		RemoveInventoryEventFilter(None)
		Int Escape
		While LocalHold
			utility.wait(0.1)
			escape+=1
		endwhile
		localhold=true
		Debug.OpenUserLog(OSLogName)

		If OSUseAAF.GetValue()==1 && AAFBusyKeyword == None
			AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		endif

		If OSUseDD.GetValue()==1 && (DDRendered == None || DDInventory == None)
			DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
			DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
		endif
		
		if EBCC_DirtTier01==None
			If Game.IsPluginInstalled("Commonwealth Captives.esp")
				ddlog+="\nCommonwealth Captives.esp found"
				EBCC_DirtTier01=Game.GetFormFromFile(0x03d0,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier01
				EBCC_DirtTier02=Game.GetFormFromFile(0x03d1,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier02
				EBCC_DirtTier03=Game.GetFormFromFile(0x03d2,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier03
				If NPC.HasSpell(EBCC_DirtTier01)||\
				NPC.HasSpell(EBCC_DirtTier02)||\
				NPC.HasSpell(EBCC_DirtTier03)
					NPC.RemoveSpell(EBCC_DirtTier01)
					NPC.RemoveSpell(EBCC_DirtTier02)
					NPC.RemoveSpell(EBCC_DirtTier03)
				endif
			endif
		endif
		
		
		ddlog="\n"+NPC+NPC.GetLeveledActorBase().GetName()+"\nMaintenance Was held for "+escape+" cycles.\nNPC.Is3DLoaded="+NPC.Is3DLoaded()+"\nOSMaintWait="+NPC.GetValue(OSMaintWait)+"\nOSMaintTime Offset="+(Utility.GetCurrentRealTime()-NPC.GetValue(OSMaintTime))+"\nOSSuspend="+OSSuspend.GetValueInt()+"\nIn Furniture>"+NPC.GetFurnitureReference()+"<>"+NPC.GetFurnitureReference()+"<"
		if ( NPC == none || !NPC.Is3DLoaded() ) || NPC.GetValue(OSMaintWait)==1 || OSSuspend.GetValueInt() == 1 || NPC.GetFurnitureReference()!=None || NPC.HasKeyword(AAFBusyKeyword)
			Utility.Wait(Utility.RandomFloat(0.5,2.0))
		else
			ddlog+="\n"+NPC+"\nOSUSeAAF="+OSUseAAF.GetValue()+"\nOSUSeDD="+OSUSeDD.GetValue()+"\nDistance from PlayerRef="+PlayerRef.GetDistance(NPC)
			If PlayerRef.GetDistance(NPC)<(MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float)
				NPC.SetValue(OSMaintWait,1)
				EveryDayImShufflin()
			endif
		endif
		AddInventoryEventFilter(None)
		Utility.Wait(Utility.RandomFloat(0.5,2.0))
		;dlog(1,ddlog)
		localhold=false
	endif
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	StartTimer(1.0,tID)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	if akBaseObject!=None||akReference!=None
		if NPC.GetValue(OSMaintWait)==0 && CheckAAFSafe(True) && !PowerArmorCheck(True) && OSSuspend.GetValueInt()==0 && !NPC.HasKeyword(AAFBusyKeyword)
			NPC.SetValue(OSMaintWait,1)
			RemoveInventoryEventFilter(None)
			Form akItem = akBaseObject
			If (akItem as Armor)
				FormList SafeForm
				If NPC.GetLeveledActorBase().GetSex()==0
					SafeForm = XXSafeItems
				endif
				If NPC.GetLeveledActorBase().GetSex()==1
					SafeForm = XYSafeItems
				endif
				If !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference)
					ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped="+akItem
					NPC.equipitem(akItem)
					dlog(1,ddlog)
					return
				endif
				if SafeForm.HasForm(akItem as ObjectReference)
					ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped SafeItem="+akItem
					NPC.EquipItem(akItem)
					dlog(1,ddlog)
					return
				endif
				if (OSUseDD.GetValueInt()>0) && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
					ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped DD="+akItem
					NPC.EquipItem(akItem)
					dlog(1,ddlog)
					return
				endif
			endif
			dlog(1,ddlog)
			NPC.SetValue(OSMaintWait,0)
			AddInventoryEventFilter(None)
		endif
	endif
endEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectFinish (Actor akTarget, Actor akCaster)
	
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function EveryDayImShufflin()

	Bool WearingDD
	NPC.SetValue(OSMaintWait,1)

	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck() && CheckAAFSafe()
		ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance"
		NPC.SetValue(NPCTimer,Utility.GetCurrentRealTime())
		FormList SafeForm

		If NPC.GetLeveledActorBase().GetSex()==0
			SafeForm = XYSafeItems
		endif

		If NPC.GetLeveledActorBase().GetSex()==1
			SafeForm = XXSafeItems
		endif

		Int i=0
		Int ArmorItems
		Form[] InvItems = NPC.GetInventoryItems()
		
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Starting Base/DLC Items Removal"
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				If (!OSAllItems.HasForm(akItem as ObjectReference) ||\
				!(akItem as Armor).HasKeyword(DDRendered) ||\
				!(akItem as Armor).HasKeyword(DDInventory) ||\
				!SafeForm.HasForm(akItem as ObjectReference)) &&\
				(0<akItem.getformid() && akItem.getformid()<0x07000000) &&\
				!(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
					NPC.removeitem(akItem,-1)
					ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" removed"
				endif
			endif
		i += 1
		EndWhile
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Finished Base/DLC Items Removal"

		InvItems = NPC.GetInventoryItems()
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Starting Regular Items Equipping"
		i=0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If (akItem as Armor)
				If (akItem as Armor) && akItem.getformid()>0x06FFFFFF && (!(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference))
					ArmorItems+=1
					NPC.equipitem(akItem)
					ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" equipped"
				endif
			endif
		i += 1
		endwhile
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Finished Regular Items Equipping"

		InvItems = NPC.GetInventoryItems()
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Starting SafeItems Equipping"
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			if SafeForm.HasForm(akItem as ObjectReference)
				ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" is in SafeItems"
				ArmorItems+=1
				NPC.EquipItem(akItem)
				endif
		i += 1
		endwhile
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Finished SafeItems Equipping"

		InvItems = NPC.GetInventoryItems()
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Starting Devious Devices Equipping"
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if (OSUseDD.GetValueInt()>0) && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
					if NPC.IsEquipped(akItem)
						WearingDD=True
						ArmorItems+=1
						ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" is wearing DD="+akItem+akItem.GetName()
					else
						WearingDD=True
						ArmorItems+=1
						npc.equipitem(akItem)
						ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" FORCE equipped DD="+akItem+akItem.GetName()
					endif
				endif
			endif
		i += 1
		endwhile
		
		if WearingDD && NPC.GetItemCount(OSDontChangeItem)==0 && NPC.GetItemCount(OSAlwaysChangeItem)==0
			NPC.AddItem(OSDontChangeItem,1,true)
			ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" DontChange added because of DD."
		endif
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Finished Devious Devices Equipping"
		Utility.Wait(Utility.RandomFloat(0.5,2.0))
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Removing Extra Items"
		i=0
		InvItems = None
		InvItems = NPC.GetInventoryItems()
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if !NPC.IsEquipped(akItem)
					ArmorItems+=1
					ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" removed conflict item "+akItem+akItem.GetName()
					NPC.RemoveItem(akItem, -1)
				endif
			endif
		i += 1
		EndWhile

		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Finished Removing Extra Items"
		
		Utility.Wait(Utility.RandomFloat(0.5,2.0))

		InvItems = NPC.GetInventoryItems()
		i=0
		ArmorItems=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)!=None && NPC.IsEquipped(akItem)
					ArmorItems+=1
				endif
			i += 1
		EndWhile	
		ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" has "+ArmorItems+" ArmorItems"

		if NPC.GetItemCount(OSDontChangeItem)==0 && ArmorItems==0 && (MCM.GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
			ddLog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" not enough armor in inventory("+ArmorItems+"), resetting outfit."
			NPC.SetOutfit(ForceChangeOutfit)
			NPC.SetValue(OSMaintWait,0)
			dlog(1,ddlog)
			return
		endif

		if (MCM.GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) && NPC.GetItemCount(OSDontChangeItem)<1 && NPC.GetItemCount(OSAlwaysChangeItem)==0
			NPC.AddItem(OSDontChangeItem,1)
			ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" Added OSDontChangeItem"
		endif

	endif

	NPC.SetValue(OSMaintTime, Utility.GetCurrentRealTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.SetOutfit(EmptyOutfit)

	ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" OSMaintTime Set To="+NPC.GetValue(OSMaintTime)
	ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+" completed outfit maintenance in "+(Utility.GetCurrentRealTime()-NPC.GetValue(NPCTimer))+" seconds"
	
	dlog(1,ddlog)

	AddInventoryEventFilter(None)

endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool Function PowerArmorCheck(Bool Silent=false)
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
Bool Function CheckAAFSafe(Bool Silent=False)

	If OSUseAAF.GetValue()==1 && AAFBusyKeyword == None
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
	endif

	if AAFBusyKeyword && !NPC.HasKeyword(AAFBusyKeyword)
		;dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" NOT AAFBusy OSUseAAF="+OSUseAAF.GetValue())
		Return True
	endif

	if AAFBusyKeyword == None
		;dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" No AAF Installed OSUseAAF="+OSUseAAF.GetValue())
		Return True
	endif
	if !Silent
		dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is apparently AAFBusy OSUseAAF="+OSUseAAF.GetValue())
	endif
	Return False

endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.

	If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int>0

		Debug.OpenUserLog(OSLogName)
	
		If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int > 0
			debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
		endif

		If dLogLevel > 1
			debug.Notification("[OSm] "+LogMe)
		endif

		If MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int == 2 || dLogLevel == 2
			LL_FourPlay.PrintConsole("[OSm] "+LogMe)
		endif
	
	endif
	ddlog=""
endFunction