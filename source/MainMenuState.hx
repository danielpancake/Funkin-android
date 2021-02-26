package;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState {
	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ["story mode", "freeplay"];
	var optionChosen:Bool = false;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music("freakyMenu"));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image("menuBG"));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image("menuDesat"));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		var tex = Paths.getSparrowAtlas("FNF_main_menu_assets");
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(0, 140 + (i * 200));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix("idle", optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix("selected", optionShit[i] + " white", 24);
			menuItem.animation.play("idle");
			menuItem.screenCenter(X);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
			menuItem.ID = i;

			menuItems.add(menuItem);
			FlxMouseEventManager.add(menuItem, onBoop, onBoopUp, onBoop, onBoopOut);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var spr = menuItems.getFirstAlive();
		camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!optionChosen) {
			super.update(elapsed);
			menuItems.forEach(function(sprite:FlxSprite) {
				sprite.screenCenter(X);
			});
		}
	}

	function onBoopUp(s:FlxSprite):Void {
		if (!optionChosen) {
			optionChosen = true;
			FlxG.sound.play(Paths.sound("confirmMenu"));
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

			menuItems.forEach(function(sprite:FlxSprite) {
				if (sprite != s) {
					FlxTween.tween(sprite, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) {
							sprite.kill();
						}
					});
				} else {
					FlxFlicker.flicker(sprite, 1, 0.06, false, false, function(flick:FlxFlicker) {
						switch (optionShit[sprite.ID]) {
							case 'story mode':
								FlxG.switchState(new StoryMenuState());

							case 'freeplay':
								FlxG.switchState(new FreeplayState());
						}
					});
				}
			});
		}
	}

	function onBoop(sprite:FlxSprite):Void {
		if (!optionChosen) {
			sprite.animation.play("selected");
			sprite.updateHitbox();
			camFollow.setPosition(sprite.getGraphicMidpoint().x, sprite.getGraphicMidpoint().y);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}
	}

	function onBoopOut(sprite:FlxSprite):Void {
		if (!optionChosen) {
			sprite.animation.play("idle");
			sprite.updateHitbox();
		}
	}
}
