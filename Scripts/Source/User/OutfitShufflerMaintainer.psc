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

;Arrays
FormList[] PForm
String[] PString
Int[] PChance
ObjectReference[] kActorArray
int tid=5309
bool localhold
String ddlog

Event OnInit()
	StartTimer(1.0,tID)
	localhold=false
EndEvent
Event OnTimer(int TimerID)
	If TimerID==tID
		canceltimer(tID)
		if ((MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General") as Bool==0) || NPC == PlayerRef || NPC.IsDead() || NPC.IsChild() || PowerArmorCheck(NPC) || NPC.IsDeleted() ||  NPC.IsDisabled()) && PlayerRef.GetDistance(NPC)<(MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float)
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
		ddlog+=NPC+NPC.GetLeveledActorBase().GetName()
		
		If OSUseAAF.GetValue()==1 && AAFBusyKeyword == None
			AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
			ddlog+="\nGot Keyword FromFile="+AAFBusyKeyword
		endif

		If OSUSeDD.GetValue()==1 && (DDRendered == None || DDInventory == None)
			DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
			DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
			ddlog+="\nDevious Devices.esm found"
			ddlog+="\nGot Keyword FromFile="+DDRendered
			ddlog+="\nGot Keyword FromFile="+DDInventory
		endif

		If Game.IsPluginInstalled("Commonwealth Captives.esp") && EBCC_DirtTier01==None
			ddlog+="\nCommonwealth Captives.esp found"
			EBCC_DirtTier01=Game.GetFormFromFile(0x0103d0,"Commonwealth Captives.esp") as Spell
			ddlog+="\nGot Spell FromFile="+EBCC_DirtTier01
			EBCC_DirtTier02=Game.GetFormFromFile(0x0103d1,"Commonwealth Captives.esp") as Spell
			ddlog+="\nGot Spell FromFile="+EBCC_DirtTier02
			EBCC_DirtTier03=Game.GetFormFromFile(0x0103d2,"Commonwealth Captives.esp") as Spell
			ddlog+="\nGot Spell FromFile="+EBCC_DirtTier03
			If NPC.HasSpell(EBCC_DirtTier01)||\
			NPC.HasSpell(EBCC_DirtTier02)||\
			NPC.HasSpell(EBCC_DirtTier03)
				NPC.RemoveSpell(EBCC_DirtTier01)
				NPC.RemoveSpell(EBCC_DirtTier02)
				NPC.RemoveSpell(EBCC_DirtTier03)
			endif
		endif		
		int escape2
		int MaintTimer=(NPC.GetValue(OSMaintTime) as Int)+((MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as int)*(MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General")) as Int)
		If NPC.GetValue(OSMaintWait)==1 && MaintTimer>Utility.GetCurrentRealTime()
			NPC.SetValue(OSMaintWait,0)
		else
			While ( NPC == none || !NPC.Is3DLoaded() ) || NPC.GetValue(OSMaintWait)>0 || OSSuspend.GetValueInt() == 1 || NPC.GetFurnitureReference()!=None || NPC.HasKeyword(AAFBusyKeyword)
				Utility.Wait(1.0)
				escape2+=1
			endwhile
			;ddlog="\nMaintenance Was held for "+escape+" cycles+"+(escape2)+" seconds.\nNPC.Is3DLoaded="+NPC.Is3DLoaded()+"\nOSMaintWait="+NPC.GetValue(OSMaintWait)+"\nOSMaintTime Offset="+(Utility.GetCurrentRealTime()-NPC.GetValue(OSMaintTime))+"\nOSSuspend="+OSSuspend.GetValueInt()+"\nIn Furniture>"+NPC.GetFurnitureReference()+"<>"+NPC.GetFurnitureReference()+"<"
			EveryDayImShufflin()
		endif
		AddInventoryEventFilter(None)
		dlog(1,ddlog)
		localhold=false
		StartTimer(1.0,tID)
	endif
endevent
Event OnEffectStart(Actor akTarget, Actor akCaster)
	NPC=akTarget
	StartTimer(1.0,tID)
endevent
Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	if akBaseObject!=None||akReference!=None
		if NPC.GetValue(OSMaintWait)==0 && CheckAAFSafe(True) && !PowerArmorCheck(True) && OSSuspend.GetValueInt()==0 && !NPC.HasKeyword(AAFBusyKeyword)
			If OSUseAAF.GetValue()==1 && AAFBusyKeyword == None
				AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
				ddlog+="\nGot Keyword FromFile="+AAFBusyKeyword
			endif

			If OSUSeDD.GetValue()==1 && (DDRendered == None || DDInventory == None)
				DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
				DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
				ddlog+="\nDevious Devices.esm found"
				ddlog+="\nGot Keyword FromFile="+DDRendered
				ddlog+="\nGot Keyword FromFile="+DDInventory
			endif

			If Game.IsPluginInstalled("Commonwealth Captives.esp") && EBCC_DirtTier01==None
				ddlog+="\nCommonwealth Captives.esp found"
				EBCC_DirtTier01=Game.GetFormFromFile(0x0103d0,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier01
				EBCC_DirtTier02=Game.GetFormFromFile(0x0103d1,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier02
				EBCC_DirtTier03=Game.GetFormFromFile(0x0103d2,"Commonwealth Captives.esp") as Spell
				ddlog+="\nGot Spell FromFile="+EBCC_DirtTier03
				If NPC.HasSpell(EBCC_DirtTier01)||\
				NPC.HasSpell(EBCC_DirtTier02)||\
				NPC.HasSpell(EBCC_DirtTier03)
					NPC.RemoveSpell(EBCC_DirtTier01)
					NPC.RemoveSpell(EBCC_DirtTier02)
					NPC.RemoveSpell(EBCC_DirtTier03)
				endif
			endif		

			NPC.SetValue(OSMaintWait,1)
			RemoveInventoryEventFilter(None)
			Form akItem = akBaseObject
			ddlog=""
			If (akItem as Armor)
				FormList SafeForm
				If NPC.GetLeveledActorBase().GetSex()==0
					SafeForm = XXSafeItems
				endif
				If NPC.GetLeveledActorBase().GetSex()==1
					SafeForm = XYSafeItems
				endif
				If (akItem as Armor)
					If akItem.getformid()<0x07000000 && !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
						if OSAllItems.HasForm(akItem as ObjectReference) || SafeForm.HasForm(akItem as ObjectReference) || (OSUseDD.GetValue()>0 && ((akItem as Armor).HasKeyword(DDRendered) || (akItem as Armor).HasKeyword(DDInventory)))
							ddlog+="OnItemUnequipped() "+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped="+akItem
							NPC.equipitem(akItem)
							dlog(1,ddlog)
							return
						else
							NPC.removeitem(akItem,-1)
							ddlog+="OnItemUnequipped() "+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" Base/DLC removed"
							dlog(1,ddlog)
							return
						endif
					endif
					If akItem.getformid()>0x06ffffff || (akItem.getformid()<0x07000000 && (MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)) || OSAllItems.HasForm(akItem as ObjectReference) || SafeForm.HasForm(akItem as ObjectReference)
						ddlog+="OnItemUnequipped() "+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped="+akItem
						NPC.equipitem(akItem)
						dlog(1,ddlog)
						return
					endif
				endif
				If !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference)
				endif
				if SafeForm.HasForm(akItem as ObjectReference)
					ddlog+="OnItemUnequipped() "+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped SafeItem="+akItem
					NPC.EquipItem(akItem)
					dlog(1,ddlog)
					return
				endif
				if (OSUSeDD.GetValue()>0) && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
					ddlog+="OnItemUnequipped() "+NPC+NPC.GetLeveledActorBase().GetName()+" Reequipped DD="+akItem
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
Event OnEffectFinish (Actor akTarget, Actor akCaster)
	
endevent
Function EveryDayImShufflin()

	Bool WearingDD
	NPC.SetValue(OSMaintWait,1)

	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck() && CheckAAFSafe()
		ddLog="EveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance"
		NPC.SetValue(NPCTimer,Utility.GetCurrentRealTime())
		FormList SafeForm

		If NPC.GetLeveledActorBase().GetSex()==0
			SafeForm = XYSafeItems
			;ddlog+="\nSafeForm Male="+XYSafeItems+SafeForm
		endif

		If NPC.GetLeveledActorBase().GetSex()==1
			SafeForm = XXSafeItems
			;ddlog+="\nSafeForm Female="+XXSafeItems+SafeForm
		endif
		
		Int i=0
		Form[] InvItems = NPC.GetInventoryItems()
		
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			;ddlog+="\nEveryDayImShufflin()\nItem="+(akItem as Armor)+(akItem as Armor).GetName()+akItem.getformid()+"<117440512="+(akItem.getformid()<0x07000000 as Bool)+"\nOSAllItems.HasForm="+(OSAllItems.HasForm(akItem as ObjectReference) as Bool)+"\nItem.HasKeyword(DDRendered)="+((akItem as Armor).HasKeyword(DDRendered) as Bool)+"\nItem.HasKeyword(DDInventory)="+((akItem as Armor).HasKeyword(DDInventory) as Bool)
			If (akItem as Armor)
				If akItem.getformid()<0x07000000 && !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool)
					if !(OSAllItems.HasForm(akItem as ObjectReference) || SafeForm.HasForm(akItem as ObjectReference) || (OSUseDD.GetValue()>0 && ((akItem as Armor).HasKeyword(DDRendered) || (akItem as Armor).HasKeyword(DDInventory))))
						ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" OSAllItem, SafeItem, or DD in maintenance"
					else
						NPC.removeitem(akItem,-1)
						ddlog+="\n"+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" Base/DLC removed by maintenance"
					endif
				endif
			endif
		i += 1
		EndWhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
		Form akItem = InvItems[i]
			If (akItem as Armor)
				If (akItem as Armor) && ((OSUseDD.GetValue()>0 && !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory)) || !SafeForm.HasForm(akItem as ObjectReference))
					NPC.equipitem(akItem)
					ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" equipped by maintenance"
				endif
			endif
		i += 1
		endwhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			if SafeForm.HasForm(akItem as ObjectReference)
				ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+akItem.GetName()+" is in SafeItems by maintenance"
				NPC.EquipItem(akItem)
				endif
		i += 1
		endwhile

		InvItems = NPC.GetInventoryItems()
		i=0
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if (OSUSeDD.GetValue()>0) && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
					if NPC.IsEquipped(akItem)
						WearingDD=True
						ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" is wearing DD="+akItem+akItem.GetName()+" in maintenance"
					else
						WearingDD=True
						npc.equipitem(akItem)
						ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+""+akItem+" FORCE equipped DD="+akItem+akItem.GetName()+" by maintenance"
					endif
				endif
			endif
		i += 1
		endwhile
		
		if WearingDD && NPC.GetItemCount(OSDontChangeItem)==0 && NPC.GetItemCount(OSAlwaysChangeItem)==0
			NPC.AddItem(OSDontChangeItem,1,true)
			ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" DontChange added because of DD in maintenance."
		endif
		Utility.Wait(Utility.RandomFloat(0.5,2.0))
		i=0
		InvItems = None
		InvItems = NPC.GetInventoryItems()
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
			If (akItem as Armor)
				if !NPC.IsEquipped(akItem)
					ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" removed conflict item "+akItem+akItem.GetName()+" by maintenance"
					NPC.RemoveItem(akItem, -1)
				endif
			endif
		i += 1
		EndWhile
	
		Utility.Wait(Utility.RandomFloat(0.5,2.0))

		InvItems = NPC.GetInventoryItems()
		i=0
		Int ArmorItems
		While (i < InvItems.Length)
			Form akItem = InvItems[i]
				If (akItem as Armor)!=None && NPC.IsEquipped(akItem)
					ArmorItems+=1
				endif
			i += 1
		EndWhile	
		ddlog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" has "+ArmorItems+" ArmorItems in maintenance"
		if NPC.GetItemCount(OSDontChangeItem)==0 && ArmorItems<1 && (MCM.GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool)
			ddLog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" not enough armor in inventory("+ArmorItems+"), resetting outfit. OSMaintWait=2, OSMaintTime=0"
			;NPC.SetOutfit(ForceChangeOutfit)
			NPC.RemoveItem(OSDontChangeItem, -1)
			NPC.SetValue(OSMaintWait,2)
			NPC.SetValue(OSMaintTime, 0)
			dlog(1,ddlog)
			return
		endif

		if (MCM.GetModSettingBool("OutfitShuffler", "bOneShot:General") as Bool==1) && NPC.GetItemCount(OSDontChangeItem)<1 && NPC.GetItemCount(OSAlwaysChangeItem)==0
			NPC.AddItem(OSDontChangeItem,1)
			ddlog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" Added OSDontChangeItem in maintenance"
		endif

	endif

	NPC.SetValue(OSMaintTime, Utility.GetCurrentRealTime())
	NPC.SetValue(OSMaintWait,0)
	NPC.SetOutfit(EmptyOutfit)

	ddlog+="\nEveryDayImShufflin() "+NPC+NPC.GetLeveledActorBase().GetName()+" OSMaintTime Set To="+NPC.GetValue(OSMaintTime)+". Completed outfit maintenance in "+(Utility.GetCurrentRealTime()-NPC.GetValue(NPCTimer))+" seconds."

	AddInventoryEventFilter(None)

endfunction
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