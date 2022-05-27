Scriptname OutfitShuffler extends Quest
;=================================================================================================================
;Imported Properties from ESP
Quest Property pMQ101 Auto Const mandatory
Keyword Property actorTypeHuman Auto Const
Keyword Property actorTypeGhoul Auto Const
Keyword Property AAFActorBusy Auto Const
Formlist Property GoodOutfits Auto Const
Formlist Property NewOutfits Auto Const
ActorBase Property DummyActor Auto Const
float Property ShortTime Auto
int Property LongMult Auto
float Property ScanRange Auto
bool Property ChangeFollowers Auto
bool Property ChangeFollowersOnShort Auto
float Property WaitTime Auto
;=================================================================================================================
;Initialize a few variables
int ShortTimerID = 888
int MultCounter = 0
int MQ101EarlyStage = 30
Bool modEnabled = True
Actor[] playerFollowers
ActorBase DoppelGanger
;=================================================================================================================
;Setup logging and start Short and Long timers
Event OnInit()
	DoppelGanger = Game.GetFormFromFile(0x72e2,"aaf.esm") as ActorBase
	GetMCMSettings()
	starttimer(ShortTime, ShortTimerID)
EndEvent
;=================================================================================================================
;Catch timer events
Event OnTimer(int aiTimerID)
	If pMQ101.IsRunning() && pMQ101.GetStage() < MQ101EarlyStage
		starttimer(ShortTime, ShortTimerID)
	else
		if aiTimerID == ShortTimerID
			GetMCMSettings()
			if modEnabled
				TimerTrap()
			endif
		endif
	endif
EndEvent

Function TimerTrap()
	playerFollowers = Game.GetPlayerFollowers( )
		if MultCounter > LongMult-1
			canceltimer(ShortTimerID)
			ForceNPCs(actorTypeHuman)
			ForceNPCs(actorTypeGhoul)
			starttimer(ShortTime, ShortTimerID)
			MultCounter = 0
		else
			canceltimer(ShortTimerID)
			ScanNPCs(actorTypeHuman)
			ScanNPCs(actorTypeGhoul)
			starttimer(ShortTime, ShortTimerID)
			MultCounter += 1
		endif
	debug.notification(MultCounter+"/"+LongMult)
endFunction
;=================================================================================================================
function ScanNPCs(Keyword WhichType)
	int i = 0
	ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(WhichType, ScanRange)
	while i < kActorArray.Length
		Actor NPC = kActorArray[i] as Actor
		if !GoodOutfits.HasForm(NPC.GetLeveledActorBase().Getoutfit())
			SetSettlerOutfit(NPC)
		endif
		i += 1
	endwhile
endFunction
;=================================================================================================================
function ForceNPCs(Keyword WhichType)
	int i = 0
	ObjectReference[] kActorArray = Game.GetPlayer().FindAllReferencesWithKeyword(WhichType, ScanRange)
	while i < kActorArray.Length
		Actor NPC = kActorArray[i] as Actor
			SetSettlerOutfit(NPC)
		i += 1
	endwhile
endFunction
;=================================================================================================================
;CheckIfFollower(NPC) returns True for non-followers. Returns Property ChangeFollowers/ChangeFollowersOnShort for followers. 
Bool Function CheckIfFollower(Actor CheckNPC)
int index = 0
while (index < playerFollowers.Length)
	If CheckNPC == playerFollowers[index]
		if MultCounter > LongMult-1
			return ChangeFollowersOnShort
		else
			return ChangeFollowers
		endif
	endIf
	index += 1
endWhile
return true
endFunction
;=================================================================================================================
Function SetSettlerOutfit(Actor NPC)
	If !NPC.IsDead() && !NPC.IsDeleted() && !NPC.HasKeyword(AAFActorBusy) && !NPC.IsChild() && NPC != Game.GetPlayer() && !NPC.IsTalking() && NPC.GetLeveledActorBase().GetSex() == 1 && NPC.IsEnabled() && CheckIfFollower(NPC)
		if Game.GetPlayer().GetDistance(NPC) < ScanRange
			NPCSetOutfit(NPC)
			Return
		endif
	endif
EndFunction
;=================================================================================================================
Function NPCSetOutfit(Actor NPCtoSet)
    Outfit OutfitToSet = NewOutfits.GetAt(Utility.RandomInt(0,NewOutfits.GetSize()-1)) as Outfit
    ObjectReference furnitureRef = NPCtoSet.GetFurnitureReference()
    NPCtoSet.setoutfit(OutfitToSet,false)
    Form[] InvItems = NPCtoSet.GetInventoryItems()
    Int i = 0
    While (i < InvItems.Length)
        Form akItem = InvItems[i]
        If (akItem as Armor) || (akItem as Weapon)
            NPCtoSet.unequipitem(akItem)
            ;NPCtoSet.removeitem(akItem, 9999)
        EndIf
        i += 1
    EndWhile
    Actor Dummy=NPCtoSet.PlaceActorAtMe(DummyActor)
    Dummy.Disable()
    Dummy.setoutfit(OutfitToSet,false)
    Utility.Wait(WaitTime)
    InvItems = Dummy.GetInventoryItems()
    i = 0
    While (i < InvItems.Length)
        Form akItem = InvItems[i]
        If (akItem as Armor) || (akItem as Weapon)
            NPCtoSet.equipitem(akItem)
        EndIf
        i += 1
    EndWhile
    Dummy.Delete()
    If furnitureRef
        NPCtoSet.SnapIntoInteraction(furnitureRef)
    EndIf
endfunction
;=================================================================================================================
Function GetMCMSettings()
	modEnabled = MCM.GetModSettingBool("OutfitShuffler", "bIsEnabled:General")
	ChangeFollowers = MCM.GetModSettingBool("OutfitShuffler", "bChangeFollowers:General")
	ChangeFollowersOnShort = MCM.GetModSettingBool("OutfitShuffler", "bChangeFollowersOnShort:General")
	ScanRange = MCM.GetModSettingFloat("OutfitShuffler", "fScanRange:General")
	WaitTime = MCM.GetModSettingFloat("OutfitShuffler", "fWaitTime:General")
	ShortTime = MCM.GetModSettingFloat("OutfitShuffler", "fShortTime:General")
	LongMult = MCM.GetModSettingInt("OutfitShuffler", "iLongMult:General")
endfunction

Function dNotify(String dText)
	debug.notification(dText)
endFunction
