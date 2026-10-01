import flixel.FlxSprite;

import funkin.states.FNAFState;

var ext = 'stages/skeld/monotone/';
var vent:FlxSprite;
var ventHovering = false;
var ventHovering2 = false;

function onLoad()
{
	vent = new FlxSprite(2200, 750);
	vent.frames = Paths.getSparrowAtlas(ext + 'vent');
	vent.animation.addByPrefix('close', 'Vent Close', 24, false);
	vent.animation.addByPrefix('hover', 'Vent Close', 24, false);
	vent.animation.addByIndices('idle', 'Vent Close', [0], '', 24, true);
	vent.animation.play('idle');
	vent.scale.set(0.5, 0.5);
	vent.updateHitbox();
	vent.flipX = true;
	vent.setColorTransform(1, 1, 1, 1, -50, -50, -50, 0);
	game.stage.add(vent);
	
	vent2 = new FlxSprite(0, ClientPrefs.downScroll ? 0 : 600);
	vent2.frames = Paths.getSparrowAtlas(ext + 'vent');
	vent2.animation.addByPrefix('close', 'Vent Close', 24, false);
	vent2.animation.addByPrefix('hover', 'Vent Close', 24, false);
	vent2.animation.addByIndices('idle', 'Vent Close', [0], '', 24, true);
	vent2.animation.play('idle');
	vent2.scale.set(0.2, 0.2);
	vent2.updateHitbox();
	vent2.flipX = true;
	vent2.setColorTransform(1, 1, 1, 1, -50, -50, -50, 0);
	vent2.camera = camOther;
	vent2.visible = true;
    add(vent2);
}

function onEvent(n, v1, v2)
{
	switch (n)
	{
		case 'Legacy': // handle all of this shit boy im lowkey editing the events in the chart editor AND visual studio
			if (v1 == 'red' || v1 == 'green' || v1 == 'monotone' || v1 == 'black')
			{
			    vent.visible = vent2.visible = (v1 == 'red' || v1 == 'monotone');
			}
	}
}
function onUpdate(elapsed:Float)
{
	/* var isHoveringVent = vent.overlapsPoint(FlxG.mouse.getWorldPosition());
	if (isHoveringVent != ventHovering && !Controls.instance.mobileC)
	{
		ventHovering = isHoveringVent;
		if (ventHovering) vent.animation.play('hover');
		else vent.animation.play('idle');
	}
	if (ventHovering && FlxG.mouse.justPressed && vent.visible && !Controls.instance.mobileC)
	{
		FlxG.switchState(new FNAFState());
	} */
	
	var isHoveringVent2 = TouchUtil.overlaps(vent2);
	if (isHoveringVent2 != ventHovering2) 
	{
	    ventHovering2 = isHoveringVent2;
	    if (ventHovering2) 
	    {
	        vent.animation.play('hover');
	        vent2.animation.play('hover');
	    }
		else
		{
		    vent.animation.play('idle');
		    vent2.animation.play('idle');
		}
	}
	
	if (ventHovering2 && TouchUtil.justPressed && vent2.visible)
	{
		FlxG.switchState(new FNAFState());
	}
}