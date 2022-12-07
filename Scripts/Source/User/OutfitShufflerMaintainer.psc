Scriptname OutfitShufflerMaintainer extends ActiveMagicEffect
;got higher than giraffe tits again. Came through and prettied the logging, and made it more consistent, with what I'm trying to achieve, with the main script.
int tid=867
Actor NPC
string OSLogName="OutfitShuffler"
Float ShortMult=2.0
Float ShortTime
Bool CheckAAFSafe
Keyword AAFBusyKeyword
FormList Property XXSafeItems auto
FormList Property XYSafeItems auto
Outfit Property ForceChangeOutfit auto
Keyword Property DontChange auto
Keyword Property OSAlwaysChange auto
Keyword Property OSWait Auto
Keyword Property OSMaintWait Auto Const
ActorValue Property OSMaintTime Auto
Keyword DDRendered
Keyword DDInventory
Bool UseDD
Float ScanRange
GlobalVariable Property OSSuspend Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnEffectStart(Actor akTarget, Actor akCaster)
	Utility.Wait(10.0)
	if ( akTarget == none || !akTarget.Is3DLoaded() )
        return
    endif
	NPC=akTarget
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	starttimer(ShortTime*ShortMult, tid)
endevent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
	Form akItem = akBaseObject
	If (akItem as Armor) && CheckAAFSafe()
		FormList SafeForm
		If NPC.GetLeveledActorBase().GetSex()==0
			SafeForm = XXSafeItems
		endif
		If NPC.GetLeveledActorBase().GetSex()==1
			SafeForm = XYSafeItems
		endif
		if SafeForm.HasForm(akItem as ObjectReference)
			NPC.EquipItem(akItem)
			return
		endif
		If !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference)
			NPC.equipitem(akItem)
			return
		endif
		if UseDD && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
			npc.equipitem(akItem)
			return
		endif
	endif
	RemoveInventoryEventFilter(None)
endEvent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
event OnTimer(int aiTimerID)
	if aiTimerID==tid
		Debug.OpenUserLog(OSLogName)
		ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General") as Float
		If !NPC.HasKeyword(OSWait) && OSSuspend.GetValueInt() == 0 && Game.GetPlayer().GetDistance(NPC)<ScanRange
			NPC.AddKeyword(OSMaintWait)
			Game.GetPlayer().GetDistance(NPC)<ScanRange
			;dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is doing an outfit check.")
			EveryDayImShufflin()
		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is in OSWait or OSSuspend="+OSSuspend.GetValueInt())
			Utility.Wait(15.00)
		endif
	endif
	AddInventoryEventFilter(None)
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General") as Float
	starttimer(ShortTime*ShortMult, tid)
endevent
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
	canceltimer(tid)
	If Game.IsPluginInstalled("Devious Devices.esm") && !UseDD && (DDRendered == None || DDInventory == None)
		DDRendered = Game.GetFormFromFile(0x004c5b, "Devious Devices.esm") as Keyword
		DDInventory = Game.GetFormFromFile(0x004c5c, "Devious Devices.esm") as Keyword
		if DDRendered && DDInventory
			UseDD = True
			;dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Using Devious Devices")
		endif
	endif
	if NPC.Is3DLoaded() && !NPC.IsDead() && !NPC.IsDeleted() && !NPC.IsDisabled() && !PowerArmorCheck()
		;dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Checking for Maintenance")
		AAFBusyKeyword = Game.GetFormFromFile(0x00915a, "AAF.esm") as Keyword
		If CheckAAFSafe(); So I'm working on 6.9, and realizing that changes back in 5.x somewhere added a pseudo-dependency for AAF at this script check. Added CheckAAFSafe function
			Int i=0
			Int ArmorItems
			Form[] InvItems = NPC.GetInventoryItems()
			FormList SafeForm
			If NPC.GetLeveledActorBase().GetSex()==0
				SafeForm = XXSafeItems
			endif
			If NPC.GetLeveledActorBase().GetSex()==1
				SafeForm = XYSafeItems
			endif
			While (i < InvItems.Length)
				Form akItem = InvItems[i]
				If (akItem as Armor)
					;dLog(1,NPC+" akItem="+akItem+" DDRendered="+akItem.HasKeyword(DDRendered)+" DDInventory="+akItem.HasKeyword(DDInventory)+" SafeItem="+SafeForm.HasForm(akItem as ObjectReference)+" IsEquipped="+NPC.IsEquipped(akItem))
					if 0<akItem.getformid() && akItem.getformid()<0x07000000
						dLog(1,NPC+akItem+" Is a DLC/Base Item")
						if !(MCM.GetModSettingBool("OutfitShuffler", "bAllowDLC:General") as Bool) && !NPC.HasKeyword(DontChange); So in 6.81, we're going to stop taking items away from NPCs with the DontChange keyword. I'm a derp for not realizing this was a problem in 6.7
							NPC.removeitem(akItem,-1)
						endif
					endif
					If !(akItem as Armor).HasKeyword(DDRendered) || !(akItem as Armor).HasKeyword(DDInventory) || !SafeForm.HasForm(akItem as ObjectReference)
						ArmorItems+=1
						NPC.equipitem(akItem)
						;dLog(1,NPC+""+akItem+" equipped")
					endif
					if SafeForm.HasForm(akItem as ObjectReference)
						dLog(1,NPC+""+akItem+" is in SafeItems")
						ArmorItems+=1
						NPC.EquipItem(akItem)
					endif
					if UseDD && ((akItem as Armor).HasKeyword(DDRendered)||(akItem as Armor).HasKeyword(DDInventory))
						if NPC.IsEquipped(akItem)
							WearingDD=True
							ArmorItems+=1
							dLog(1,NPC+" is wearing DD="+akItem+akItem.GetName())
						else
							WearingDD=True
							ArmorItems+=1
							npc.equipitem(akItem)
							dLog(1,NPC+" FORCE equipped DD="+akItem+akItem.GetName())
						endif
					endif
				;dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" has "+ArmorItems+" ArmorItems")
				endif
			i += 1
			EndWhile
;cleanup, Step 2:Now remove whatever is left
			if WearingDD && !NPC.HasKeyword(DontChange)
				NPC.AddKeyword(DontChange)
				dLog(1,NPC+" DontChange added because of DD.")
			endif

			
			if NPC.HasKeyword(OSWait)
				dLog(1,NPC+" got OSWait! Bailing out before cleanup!")
				return
			endif

			;dlog(1,NPC+NPC.GetLeveledActorBase().GetName()+" Waiting to cleanup... "+ShortTime*5+" seconds.")
			Utility.Wait(ShortTime*5)
			i=0
			InvItems = None
			InvItems = NPC.GetInventoryItems()
			While (i < InvItems.Length) && !NPC.HasKeyword(DontChange)
				Form akItem = InvItems[i]
				If (akItem as Armor)
					if !NPC.IsEquipped(akItem)
						dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" removed conflict item "+akItem+akItem.GetName())
						NPC.RemoveItem(akItem, -1)
					endif
				endif
			i += 1
			EndWhile

			if NPC.HasKeyword(OSWait)
				dLog(1,NPC+" got OSWait! Bailing out before final count with >"+ArmorItems+"<")
				return
			endif

			if !DontChange && ArmorItems < 1 && (MCM.GetModSettingBool("OutfitShuffler", "bNoNudes:General") as Bool);assume we're naked, and force over to OutfitShuffler.SetSettlerOutfit, unless we're DontChange.
				dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" not enough armor in inventory("+ArmorItems+"), resetting outfit.")
				NPC.SetOutfit(ForceChangeOutfit)
				NPC.SetOutfit(ForceChangeOutfit,true)
				return
			endif

		else
			dLog(1,NPC+NPC.GetLeveledActorBase().GetName()+" is AAFBusy")
			Utility.Wait(5.0)
		endif
	endif
	NPC.SetValue(OSMaintTime, Utility.GetCurrentRealTime())
	NPC.RemoveKeyword(OSMaintWait)
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bool Function PowerArmorCheck()
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
Bool Function CheckAAFSafe()
	if AAFBusyKeyword && !NPC.HasKeyword(AAFBusyKeyword)
		Return True
	endif
	if AAFBusyKeyword == None
		Return True
	endif
	Return False
endfunction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function dLog(int dLogLevel,string LogMe); 6.25 Implementing Leveled Logging. Sloppily.
	Bool NoisyConsole = MCM.GetModSettingBool("OutfitShuffler", "bNoisyConsole:General") as Bool
	Int LogLevel = MCM.GetModSettingInt("OutfitShuffler", "iLogLevel:General") as int
;File Output
	If LogLevel == 0 && dLogLevel == 1
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
	endif
;File and Notification
	If LogLevel == 0 && dLogLevel == 2
		;debug.TraceUser(OSLogName, "[..Shuffler]"+LogMe)
		debug.Notification("[OSm] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 0 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
	endif
;Higher Priority File and Notification
	If LogLevel == 0 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1);LogLevel=0, but dLogLevel is elevated.
		debug.Notification("[OSm] "+LogMe)
	endif
;File Output
	If LogLevel == 1 && dLogLevel == 1
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe)
	endif
;File and Notification
	If LogLevel == 1 && dLogLevel == 2
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe)
		debug.Notification("[OSm] "+LogMe)
	endif
;Higher Priority File Output
	If LogLevel == 1 && dLogLevel == 3
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
	endif
;Higher Priority File and Notification
	If LogLevel == 1 && dLogLevel == 4
		debug.TraceUser(OSLogName, "[Maintainer]"+LogMe,1)
		debug.Notification("[OSm] "+LogMe)
	endif
;Noisy Console
	If NoisyConsole
		LL_FourPlay.PrintConsole("[OSm] "+LogMe)
	endif
endFunction