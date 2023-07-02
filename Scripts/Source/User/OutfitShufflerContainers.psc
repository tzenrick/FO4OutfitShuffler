Scriptname OutfitShufflerContainers extends ActiveMagicEffect
{Attempts to manage random container loot, and dead body loot.}

import OutfitShuffler
import Game
import MCM
import Utility

GlobalVariable Property OSSuspend Auto
Formlist Property OSAllItems Auto
Actor Property PlayerRef Auto Const
ObjectReference MyOnlyContainer
FormList Property OSTempContainer Auto
FormList Property OSFactionsToIgnore auto
FormList Property OSActorRaces auto

String ContainerOutput

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If OSSuspend.GetValueInt()==0 && akSourceContainer!=MyOnlyContainer
		OSSuspend.SetValueInt(1)
		RemoveInventoryEventFilter(None)
		Bool BadContainer
		ContainerOutput = "\nOutfitShuffler Container Script has Broken"
		If IsPluginInstalled("ESPExplorerFO4.esp")
			if akSourceContainer==GetFormFromFile(0x1742,"ESPExplorerFO4.esp") as ObjectReference
				BadContainer=True
				ContainerOutput = "\nContainer="+akSourcecontainer+" and belongs to ESPExplorerFO4"
			endif
		endif
		if akSourceContainer
			If akSourceContainer.IsOwnedBy(PlayerRef)
				BadContainer=True
				ContainerOutput = "\nContainer="+akSourcecontainer+" and is owned by the player."
			endif
			ContainerOutput = "\nContainer="+akSourcecontainer
		endif
		Int RandomNumber=RandomInt(0,99)
;		dLog(string LogMe, Severity=0, String AltShort="", String AltLong="")
		Bool ContainerDo=((akSourceContainer && !BadContainer && OSTempContainer.GetSize()==0) && !(akSourceContainer == akSourceContainer as Actor) && (GetModSettingInt("OutfitShuffler", "iContainerLootChance:General") as Int>RandomNumber))		
		Bool NPCDo=((akSourceContainer == akSourceContainer as Actor) && (akSourceContainer as Actor).IsDead() && ((GetModSettingInt("OutfitShuffler", "iDeadBodyLootChance:General") as Int)>RandomNumber)) && CheckFaction(aksourceContainer as Actor) && CheckRace(aksourceContainer as Actor)
		ContainerOutput+="\nContainerDo="+ContainerDo+"\nNPCDo="+NPCDo+"\n"
		if ContainerDo || NPCDo
			MyOnlyContainer=akSourceContainer
			If OSAllItems.GetSize()>1
				ContainerOutput+="OSAllItems.GetSize()="+OSAllItems.GetSize()+" and iLootItemsMax="+GetModSettingInt("OutfitShuffler", "iLootItemsMax:General")+"\n"
				int i
				While i<RandomInt(1,GetModSettingInt("OutfitShuffler", "iLootItemsMax:General") as Int)
					Form TempItem=OSAllItems.GetAt(RandomInt(1,OSAllItems.GetSize()))
					OSTempContainer.AddForm(TempItem)
					MyOnlyContainer.AddItem(TempItem)
					i+=1
				endwhile
			endif
			ContainerOutput+="Container="+akSourceContainer+" received "+OSTempContainer.GetSize()+" items in it.\n"
			RegisterForDistanceGreaterThanEvent(PlayerRef, MyOnlyContainer, 1000.0)
		else
			ContainerOutput+="Container="+akSourceContainer+" didn't get any items.\n"
			Wait(RandomFloat(0.5,2.0))
		endif
		AddInventoryEventFilter(None)
		dLog(ContainerOutput+"\nGot a RandomNumber="+RandomNumber+"\niContainerLootChance="+GetModSettingInt("OutfitShuffler", "iContainerLootChance:General")+"\niDeadBodyLootChance="+GetModSettingInt("OutfitShuffler", "iDeadBodyLootChance:General") , 0,"[OSc]", "[.Container]")
		ContainerOutput=""
		OSSuspend.SetValueInt(0)
	endif
endEvent

Event OnDistanceGreaterThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
	int i=0
	While i<OSTempContainer.GetSize()
		Form TempItem=OSTempContainer.GetAt(i)
		MyOnlyContainer.RemoveItem(TempItem, 1)
		i+=1
	endwhile
	OSTempContainer.Revert()
	UnRegisterForDistanceEvents(PlayerRef, MyOnlyContainer)
endevent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	AddInventoryEventFilter(None)
EndEvent

Bool Function CheckFaction(Actor CheckFactionActor)
	If OSFactionsToIgnore.GetSize()>0
		Int FactionCounter
		While FactionCounter<OSFactionsToIgnore.GetSize()
			If CheckFactionActor.IsInFaction(OSFactionsToIgnore.GetAt(FactionCounter) as Faction)
				ContainerOutput+=CheckFactionActor+CheckFactionActor.GetLeveledActorBase().GetName()+" is in BAD Faction.\n"
				Return False
			endif
			FactionCounter+=1
		endwhile
	endif
	ContainerOutput+=CheckFactionActor+CheckFactionActor.GetLeveledActorBase().GetName()+" is in GOOD Faction.\n"
	return True
endfunction

Bool Function CheckRace(Actor CheckRaceActor)
	If OSActorRaces.GetSize()>0
		if CheckRaceActor.HasKeywordInFormList(OSActorRaces)
			ContainerOutput+=CheckRaceActor+CheckRaceActor.GetLeveledActorBase().GetName()+" is GOOD race.\n"
			return True
		endif
	endif
	ContainerOutput+=CheckRaceActor+CheckRaceActor.GetLeveledActorBase().GetName()+" is BAD race.\n"
	return False
endfunction
