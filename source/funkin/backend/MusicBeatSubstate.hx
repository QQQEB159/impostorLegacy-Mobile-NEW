package funkin.backend;

import flixel.FlxSubState;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

import funkin.input.Controls;
import funkin.scripts.*;

import insanity.custom.InsanityType;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	public function new()
	{
		instance = this;
		super();
	}
	
	public var curSection:Int = 0;
	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	
	public var curSectionStep:Int = 0;
	public var nextSectionStep:Int = 0;
	
	public var curDecSection:Float = 0;
	public var curDecStep:Float = 0;
	public var curDecBeat:Float = 0;
	
	private var controls(get, never):Controls;
	
	inline function get_controls():Controls return Controls.instance;
	
	public var scripted:Bool = false;
	public var scriptName:String = '';
	public var scriptPrefix:String = 'substates';
	public var scriptGroup:ScriptGroup = new ScriptGroup();
	
	public function initStateScript(?scriptName:String, callOnLoad:Bool = true):Bool
	{
		if (scriptName == null)
		{
			final stateName = InsanityType.getClassName(InsanityType.getClass(this)).split('.').pop();
			scriptName = stateName ?? '???';
		}
		
		scriptGroup.scriptShareables.set('parent', this);
		
		this.scriptName = scriptName;
		
		final scriptFile = FunkinScript.getPath('scripts/$scriptPrefix/$scriptName');
		if (scriptGroup.exists(scriptFile)) return true;
		
		if (FunkinAssets.exists(scriptFile))
		{
			var _script = FunkinScript.fromFile(scriptFile, scriptName, scriptGroup.scriptShareables);
			if (_script.__garbage)
			{
				_script = FlxDestroyUtil.destroy(_script);
				return false;
			}
			
			scriptGroup.parent = this;
			
			Logger.log('script [$scriptName] initialized', NOTICE);
			
			scriptGroup.addScript(_script);
			scripted = true;
		}
		
		if (callOnLoad) scriptGroup.call('onLoad', []);
		
		return scripted;
	}
	
	inline function isHardcodedState()
	{
		final ret:Null<Any> = scriptGroup?.call('customMenu');
		
		return (#if (target.static) !(ret is Bool) || #end ret != true);
	}
	
	public function refreshZ(?group:FlxTypedGroup<FlxBasic>)
	{
		group ??= FlxG.state;
		group.sort(SortUtil.sortByZ, flixel.util.FlxSort.ASCENDING);
	}
	
	public var touchPad:TouchPad;
	public var touchPadCam:FlxCamera;
	public var mobileControls:IMobileControls;
	public var mobileControlsCam:FlxCamera;

	public function addTouchPad(DPad:String, Action:String)
	{
		touchPad = new TouchPad(DPad, Action);
		add(touchPad);
	}

	public function removeTouchPad()
	{
		if (touchPad != null)
		{
			remove(touchPad);
			touchPad = FlxDestroyUtil.destroy(touchPad);
		}

		if(touchPadCam != null)
		{
			FlxG.cameras.remove(touchPadCam);
			touchPadCam = FlxDestroyUtil.destroy(touchPadCam);
		}
	}

	public function addMobileControls(defaultDrawTarget:Bool = false):Void
	{
		var extraMode = MobileData.extraActions.get(ClientPrefs.extraButtons);

		switch (MobileData.mode)
		{
			case 0: // RIGHT_FULL
				mobileControls = new TouchPad('RIGHT_FULL', 'NONE', extraMode);
			case 1: // LEFT_FULL
				mobileControls = new TouchPad('LEFT_FULL', 'NONE', extraMode);
			case 2: // CUSTOM
				mobileControls = MobileData.getTouchPadCustom(new TouchPad('RIGHT_FULL', 'NONE', extraMode));
			case 3: // HITBOX
				mobileControls = new Hitbox(extraMode);
		}

		mobileControlsCam = new FlxCamera();
		mobileControlsCam.bgColor.alpha = 0;
		FlxG.cameras.add(mobileControlsCam, defaultDrawTarget);

		mobileControls.instance.cameras = [mobileControlsCam];
		mobileControls.instance.visible = false;
		add(mobileControls.instance);
	}

	public function removeMobileControls()
	{
		if (mobileControls != null)
		{
			remove(mobileControls.instance);
			mobileControls.instance = FlxDestroyUtil.destroy(mobileControls.instance);
			mobileControls = null;
		}

		if (mobileControlsCam != null)
		{
			FlxG.cameras.remove(mobileControlsCam);
			mobileControlsCam = FlxDestroyUtil.destroy(mobileControlsCam);
		}
	}

	public function addTouchPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (touchPad != null)
		{
			touchPadCam = new FlxCamera();
			touchPadCam.bgColor.alpha = 0;
			FlxG.cameras.add(touchPadCam, defaultDrawTarget);
			touchPad.cameras = [touchPadCam];
		}
	}
	
	override function update(elapsed:Float)
	{
		final oldStep:Int = curStep;
		
		curDecSection = Conductor.getSection(Conductor.songPosition - ClientPrefs.noteOffset);
		updateCurStep();
		updateBeat();
		
		if (curStep > oldStep)
		{
			for (step in oldStep...curStep)
			{
				curBeat = Math.floor((curStep = (step + 1)) / 4);
				
				if (curStep >= 0)
				{
					stepHit();
					
					if (curStep % 4 == 0) beatHit();
				}
				
				updateSection();
			}
		}
		else if (curStep < oldStep)
		{
			updateSection(true);
		}
		
		scriptGroup.call('onUpdate', [elapsed]);
		
		super.update(elapsed);
	}
	
	inline function updateSection(rollback:Bool = false):Void
	{
		final lastSection:Int = curSection;
		
		if (rollback)
		{
			curSection = Math.floor(curDecSection);
			updateSectionStep();
			
			if (curSection != lastSection && curSection >= 0) sectionHit();
		}
		else
		{
			while (curStep >= nextSectionStep)
			{
				curSection ++;
				curSectionStep = nextSectionStep;
				nextSectionStep += (getBeatsOnSection() * 4);
				
				if (curSection >= 0) sectionHit();
			}
		}
	}
	
	inline function updateSectionStep():Void
	{
		curSectionStep = Math.round(Conductor.getStep(Conductor.sectionToSeconds(curSection)));
		nextSectionStep = Math.round(Conductor.getStep(Conductor.sectionToSeconds(curSection + 1)));
	}
	
	inline function updateBeat():Void curBeat = Math.floor(curDecBeat = (curDecStep / 4));
	
	inline function updateCurStep():Void curStep = Math.floor(curDecStep = Conductor.getStep(Conductor.songPosition - ClientPrefs.noteOffset));
	
	public inline function getBeatsOnSection():Int return (PlayState.SONG?.notes[curSection]?.sectionBeats ?? 4);
	
	public function stepHit():Void
	{
		scriptGroup.call('onStepHit', [curStep]);
	}
	
	public function beatHit():Void
	{
		scriptGroup.call('onBeatHit', [curBeat]);
	}
	
	public function sectionHit()
	{
		scriptGroup.call('onSectionHit', [curSection]);
	}
	
	override function destroy()
	{
		scriptGroup.call('onDestroy', []);
		
		scriptGroup = FlxDestroyUtil.destroy(scriptGroup);
		
		removeTouchPad();
		removeMobileControls();
		
		super.destroy();
	}
}
