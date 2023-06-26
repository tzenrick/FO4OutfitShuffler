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

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	If OSSuspend.GetValueInt()==0 && akSourceContainer!=MyOnlyContainer
		OSSuspend.SetValueInt(1)
		RemoveInventoryEventFilter(None)
		Bool BadContainer
		String ContainerOutput = "OutfitShuffler Container Script has Broken"
		If IsPluginInstalled("ESPExplorerFO4.esp")
			if akSourceContainer==GetFormFromFile(0x1742,"ESPExplorerFO4.esp") as ObjectReference
				BadContainer=True
				ContainerOutput = "Container="+akSourcecontainer+" and belongs to ESPExplorerFO4"
			endif
		endif
		if akSourceContainer
			If akSourceContainer.IsOwnedBy(PlayerRef)
				BadContainer=True
				ContainerOutput = "Container="+akSourcecontainer+" and is owned by the player."
			endif
			ContainerOutput = "Container="+akSourcecontainer
		endif
		Int RandomNumber=RandomInt(0,99)
;		dLog(string LogMe, Severity=0, String AltShort="", String AltLong="")
		if (((akSourceContainer && !BadContainer && OSTempContainer.GetSize()==0) \
		&& !(akSourceContainer == akSourceContainer as Actor)\
		&& (GetModSettingInt("OutfitShuffler", "iContainerLootChance:General") as Int>RandomNumber)))\
		||\
		((akSourceContainer == akSourceContainer as Actor)\
		&&(akSourceContainer as Actor).IsDead()\
		&&((GetModSettingInt("OutfitShuffler", "iDeadBodyLootChance:General") as Int)>RandomNumber))
			MyOnlyContainer=akSourceContainer
			If OSAllItems.GetSize()>1
				int i
				While i<RandomInt(1,GetModSettingInt("OutfitShuffler", "iLootItemsMax:General") as Int)
					Form TempItem=OSAllItems.GetAt(RandomInt(1,OSAllItems.GetSize()))
					OSTempContainer.AddForm(TempItem)
					MyOnlyContainer.AddItem(TempItem)
					i+=1
				endwhile
			endif
			RegisterForDistanceGreaterThanEvent(PlayerRef, MyOnlyContainer, 1000.0)
		else
			Wait(RandomFloat(0.5,2.0))
		endif
		AddInventoryEventFilter(None)
		;dLog(ContainerOutput+"\nGot a RandomNumber="+RandomNumber+"\niContainerLootChance="+GetModSettingInt("OutfitShuffler", "iContainerLootChance:General")+"\niDeadBodyLootChance="+GetModSettingInt("OutfitShuffler", "iDeadBodyLootChance:General") , 1,"[OSc]", "[.Container]")
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