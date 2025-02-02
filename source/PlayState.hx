package;

import stageStuff.BackgroundGirls;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.FlxTrail;
import handlers.Files;
import flixel.math.FlxRect;
import handlers.Paths;
import stageStuff.BackgroundDancer;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import HealthIcon;
import handlers.ClientPrefs;
import NoteSplash;

using StringTools;

class PlayState extends MusicBeatState
{
	var inCutscene:Bool = false;
	var senpaiCutsceneDebug:Bool = true;

	public static var deathCounter:Int = 0;
	public static var songAccuracy:Float = 0;
	public var coolNoteFloat:Float = 0; 

	var perfectMode:Bool = false;
	public static var curLevel:String = 'Tutorial';
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var instance:PlayState = null;
	private var allNotes:Int = 0;
	private var vocalsFinished:Bool = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int =0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:stageStuff.BackgroundGirls;

	var talking:Bool = true;
	var songScore:Int = 0;
	var comboScore:Int = 0;
	var scoreTxt:FlxText;
	var comboTxt:FlxText;
	var missTxt:FlxText;
	var accuracyTxt:FlxText;
	var infoTxt:FlxText;
	public var ratingTxt:String;
	var songRating:FlxText;
	public var ratingColor:FlxColor;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Int = 6;

	override public function create()
	{
		recalculateAccuracy();

		if (Assets.exists(('assets/data/${SONG.song.toLowerCase()}/dialogue.txt'))) // Checks for a dialogue file
			dialogue = CoolUtil.loadText(Paths.txt('${SONG.song.toLowerCase()}/dialogue')); // Sets the dialogue to what's inside of "dialogue.txt"

		FlxG.mouse.visible = false;
		instance = this;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson(curLevel);

		Conductor.changeBPM(SONG.bpm);

		if (SONG.song.toLowerCase() == 'bopeebo' || SONG.song.toLowerCase() == 'fresh' || SONG.song.toLowerCase() == 'dadbattle' || SONG.song.toLowerCase() == 'tutorial')
		{
			curStage = 'stage';
			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/stages/week1/stageback.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('assets/images/stages/week1/stagefront.png');
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = true;
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.active = false;
			add(stageFront);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('assets/images/stages/week1/stagecurtains.png');
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = true;
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.active = false;
			add(stageCurtains);
		}

		if (SONG.song.toLowerCase() == 'spookeez' || SONG.song.toLowerCase() == 'south' || SONG.song.toLowerCase() == 'monster')
		{
			curStage = 'spooky';
			halloweenLevel = true;

			var hallowTex = FlxAtlasFrames.fromSparrow('assets/images/stages/week2/halloween_bg.png', 'assets/images/stages/week2/halloween_bg.xml');

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = hallowTex;
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = true;
			add(halloweenBG);

			isHalloween = true;
		}

		if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
		{
			curStage = 'philly';
	
			var bg:FlxSprite = new FlxSprite(-100).loadGraphic('assets/images/stages/week3/sky.png');
			bg.scrollFactor.set(0.1, 0.1);
			add(bg);
	
			var city:FlxSprite = new FlxSprite(-10).loadGraphic('assets/images/stages/week3/city.png');
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			add(city);
	
			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);
	
			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic('assets/images/stages/week3/win' + i + '.png');
				light.scrollFactor.set(0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = true;
				phillyCityLights.add(light);
			}
			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic('assets/images/stages/week3/behindTrain.png');
			add(streetBehind);
	
			phillyTrain = new FlxSprite(2000, 360).loadGraphic('assets/images/stages/week3/train.png');
			add(phillyTrain);
	
			trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
			FlxG.sound.list.add(trainSound);
	
			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic('assets/images/stages/week3/street.png');
			add(street);
		}

		if (SONG.song.toLowerCase() == 'satin panties' || SONG.song.toLowerCase() == 'high' || SONG.song.toLowerCase() == 'milf')
		{
			curStage = 'limo';
			defaultCamZoom = 0.9;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('stages/week4/limoSunset'));
			skyBG.scrollFactor.set(0.1, 0.1);
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = Paths.getSparrowAtlas('stages/week4/bgLimo');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('stages/week4/limoOverlay'));
			overlayShit.alpha = 0.5;

			limo = new FlxSprite(-120, 550);
			limo.frames = Paths.getSparrowAtlas('stages/week4/limoDrive');
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = true;

			fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('stages/week4/fastCarLol'));
		}

		if (SONG.song.toLowerCase() == 'cocoa' || SONG.song.toLowerCase() == 'eggnog')
		{
			curStage = 'mall';

			defaultCamZoom = 0.80;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic('assets/images/stages/week5/bgWalls.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week5/upperBop.png', 'assets/images/stages/week5/upperBop.xml');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.antialiasing = true;
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic('assets/images/stages/week5/bgEscalator.png');
			bgEscalator.antialiasing = true;
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.active = false;
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic('assets/images/stages/week5/christmasTree.png');
			tree.antialiasing = true;
			tree.scrollFactor.set(0.40, 0.40);
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week5/bottomBop.png', 'assets/images/stages/week5/bottomBop.xml');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.antialiasing = true;
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic('assets/images/stages/week5/fgSnow.png');
			fgSnow.active = false;
			fgSnow.antialiasing = true;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week5/santa.png', 'assets/images/stages/week5/santa.xml');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = true;
			add(santa);
		}

		if (SONG.song.toLowerCase() == 'winter horrorland')
		{
			curStage = 'mallEvil';

			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic('assets/images/stages/week5/evilBG.png');
			bg.antialiasing = true;
			bg.scrollFactor.set(0.2, 0.2);
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic('assets/images/stages/week5/evilTree.png');
			evilTree.antialiasing = true;
			evilTree.scrollFactor.set(0.2, 0.2);
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic("assets/images/stages/week5/evilSnow.png");
			evilSnow.antialiasing = true;
			add(evilSnow);
		}

		if (SONG.song.toLowerCase() == 'senpai' || SONG.song.toLowerCase() == 'roses')
		{
			curStage = 'school';
	
			// defaultCamZoom = 0.9;
	
			var bgSky = new FlxSprite().loadGraphic('assets/images/stages/week6/weebSky.png');
			bgSky.scrollFactor.set(0.1, 0.1);
			add(bgSky);
	
			var repositionShit = -200;
	
			var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic('assets/images/stages/week6/weebSchool.png');
			bgSchool.scrollFactor.set(0.6, 0.90);
			add(bgSchool);
	
			var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic('assets/images/stages/week6/weebStreet.png');
			bgStreet.scrollFactor.set(0.95, 0.95);
			add(bgStreet);
	
			var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic('assets/images/stages/week6/weebTreesBack.png');
			fgTrees.scrollFactor.set(0.9, 0.9);
			add(fgTrees);
	
			var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
			var treetex = FlxAtlasFrames.fromSpriteSheetPacker('assets/images/stages/week6/weebTrees.png', 'assets/images/stages/week6/weebTrees.txt');
			bgTrees.frames = treetex;
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			add(bgTrees);
	
			var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
			treeLeaves.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week6/petals.png', 'assets/images/stages/week6/petals.xml');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			add(treeLeaves);
	
			var widShit = Std.int(bgSky.width * 6);
	
			bgSky.setGraphicSize(widShit);
			bgSchool.setGraphicSize(widShit);
			bgStreet.setGraphicSize(widShit);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			treeLeaves.setGraphicSize(widShit);
	
			fgTrees.updateHitbox();
			bgSky.updateHitbox();
			bgSchool.updateHitbox();
			bgStreet.updateHitbox();
			bgTrees.updateHitbox();
			treeLeaves.updateHitbox();
	
			bgGirls = new stageStuff.BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);
	
			if (SONG.song.toLowerCase() == 'roses')
			{
				bgGirls.getScared();
			}
	
			bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
			bgGirls.updateHitbox();
			add(bgGirls);
		}
		if (SONG.song.toLowerCase() == 'thorns')
		{
			curStage = 'schoolEvil';
	
			var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
			var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
	
			var posX = 400;
			var posY = 200;
	
			var bg:FlxSprite = new FlxSprite(posX, posY);
			bg.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week6/animatedEvilSchool.png', 'assets/images/stages/week6/animatedEvilSchool.xml');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
		}

		gf = new Character(400, 130, SONG.player3);
		gf.scrollFactor.set(0.95, 0.95);
		if (SONG.song.toLowerCase() == 'winter horrorland')
			gf.alpha = 0;
		add(gf);
			
		if (curStage == 'limo')
			add(limo);

		dad = new Character(100, 100, SONG.player2);
		add(dad);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case 'senpai' | 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		add(boyfriend);

		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);		
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		startingSong = true;
		
		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		//FlxG.camera.zoom = 1.05;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/ui/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.hpColor, boyfriend.hpColor); //0xFFFF0000, 0xFF66FF33);
		add(healthBar);
		
		infoTxt = new FlxText(healthBarBG.x + healthBarBG.width - 675, healthBarBG.y + 45, 0, "", 20);
		infoTxt.setFormat("assets/fonts/vcr.ttf", 22, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//infoTxt.screenCenter();
		infoTxt.antialiasing = false;
		infoTxt.scrollFactor.set();

		missTxt = new FlxText(healthBarBG.x + healthBarBG.width - 600, healthBarBG.y + 45, 0, "", 20);
		missTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.scrollFactor.set();

		accuracyTxt = new FlxText(healthBarBG.x + healthBarBG.width - 600, healthBarBG.y + 45, 0, "", 20);
		accuracyTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 600, healthBarBG.y + 45, 0, "", 20);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		missTxt = new FlxText(healthBarBG.x + healthBarBG.width - 600, healthBarBG.y + 45, 0, "", 20);
		missTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];

		if (isStoryMode)
			{
				switch (curSong.toLowerCase())
				{
					case "winter horrorland":
						var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
						add(blackScreen);
						blackScreen.scrollFactor.set();
						camHUD.visible = false;
	
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							remove(blackScreen);
							FlxG.sound.play(Paths.sound('Lights_Turn_On'));
							camFollow.y = -2050;
							camFollow.x += 200;
							FlxG.camera.focusOn(camFollow.getPosition());
							FlxG.camera.zoom = 1.5;
	
							new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								camHUD.visible = true;
								remove(blackScreen);
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
									ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween)
									{
										startCountdown();
									}
								});
							});
						});
				}
				if (curSong.toLowerCase() != 'winter horrorland')
					startCountdown();
			}
		else
			startCountdown();

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.1;

		add(grpNoteSplashes);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		doof.cameras = [camHUD];
		infoTxt.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];

		var engineWatermark = new FlxText(5, FlxG.height - 18, 0, "", 12);
		engineWatermark.scrollFactor.set();
		engineWatermark.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWatermark.cameras = [camHUD];
		engineWatermark.text = "Mega Engine v0.5b";

		var songWatermark = new FlxText(5, FlxG.height - 34, 0, "", 12);
		songWatermark.scrollFactor.set();
		songWatermark.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songWatermark.cameras = [camHUD];
		songWatermark.text = 'Song: ' + '${curSong}';

		var deathWatermark = new FlxText(5, FlxG.height - 50, 0, "", 12);
		deathWatermark.scrollFactor.set();
		deathWatermark.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		deathWatermark.cameras = [camHUD];
		if (ClientPrefs.getOption('naughtiness') == true)
			deathWatermark.text = 'Blueballed: ' + '${deathCounter}';
		else
			deathWatermark.text = 'Deaths: ' + '${deathCounter}';

		if (ClientPrefs.getOption('MegaEngineWatermarks') == true)
			add(engineWatermark);
			add(songWatermark);
			add(deathWatermark);

		if (ClientPrefs.getOption('showInfoText')){
			add(infoTxt);
		}

		function dialogueIntro(?dialogueBox:DialogueBox):Void
			{
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				add(black);
			
				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					black.alpha -= 0.15;
			
					if (black.alpha > 0)
					{
						tmr.reset(0.1);
					}
					else
					{
						if (dialogueBox != null)
						{
							inCutscene = true;
							{
								add(dialogueBox);
							}
						}
						else
							startCountdown();
			
						remove(black);
					}
				});
			}

		super.create();
	}

	function dialogueIntro(?dialogueBox:DialogueBox):Void
		{
			add(dialogueBox);
		}
	
	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);

		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
			}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		var swagCounter:Int = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready.png', "set.png", "go.png"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel.png',
				'weeb/pixelUI/set-pixel.png',
				'weeb/pixelUI/date-pixel.png'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
						FlxG.sound.play('assets/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/ui/' + pixelShitPart1 + 'ready' + pixelShitPart2 + '.png');
					ready.scrollFactor.set();
					ready.screenCenter();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/ui/' + pixelShitPart1 + 'set' + pixelShitPart2 + '.png');
					set.scrollFactor.set();
					set.screenCenter();
					add(set);

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/ui/' + pixelShitPart1 + 'go' + pixelShitPart2 + '.png');
					go.scrollFactor.set();
					go.screenCenter();
					add(go);

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}		
			swagCounter += 1;
		}, 5);
		//FlxG.camera.zoom = defaultCamZoom;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		startingSong = false;
		FlxG.sound.playMusic("assets/songs/" + SONG.song.toLowerCase() + "/Inst" + TitleState.soundExt, 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
		{	
			var songData = SONG;
			Conductor.changeBPM(songData.bpm);
	
			curSong = songData.song;
	
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded("assets/songs/" + SONG.song.toLowerCase() + "/Voices" + TitleState.soundExt);
			else
				vocals = new FlxSound();
	
			FlxG.sound.list.add(vocals);

			vocals.onComplete = function()
				{
					vocalsFinished = true;
				};

			notes = new FlxTypedGroup<Note>();
			add(notes);
	
			var noteData:Array<SwagSection>;
	
			noteData = songData.notes;
	
			var daBeats:Int = 0;
			for (section in noteData)
			{
				var coolSection:Int = Std.int(section.lengthInSteps / 4);
	
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);
	
					var gottaHitNote:Bool = section.mustHitSection;
	
					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
	
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
	
						sustainNote.mustPress = gottaHitNote;
	
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
					}
	
					swagNote.mustPress = gottaHitNote;
	
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
					}
				}
				daBeats += 1;
			}	
			unspawnNotes.sort(sortByShit);
	
			generatedMusic = true;
		}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'stage', 'spooky', 'philly', 'limo', 'mall', 'mallEvil':
					var arrTex = FlxAtlasFrames.fromSparrow('assets/images/ui/NOTE_assets.png', 'assets/images/ui/NOTE_assets.xml');
					babyArrow.frames = arrTex;
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					babyArrow.antialiasing = true;

					if (player == 1)
					{
						playerStrums.add(babyArrow);
					}

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}

				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic('assets/images/ui/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.play();
				Conductor.songPosition = FlxG.sound.music.time;
				vocals.time = Conductor.songPosition;
				vocals.play();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
		{
			if (_exiting)
				return;
	
			vocals.pause();
			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
	
			if (vocalsFinished)
				return;
	
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

		override public function update(elapsed:Float)
		{
			if (FlxG.keys.justPressed.NUMLOCK){
				endSong();}

			recalculateAccuracy();
			FlxG.stage.frameRate = ClientPrefs.getOption('gameFrameRate');
			super.update(elapsed);
		
			var ratingArray:Array<Dynamic> = [
				[99.95, "[S++]", 0xFFFFD700],
				[99.5, "[S+]", 0xFF8D3D8D],
				[99, "[S]", 0xFF00FFFF],
				[95, "[A+]", 0xFF31CD31],
				[90, "[A]", 0xFF00FF00],
				[85, "[B+]", 0xFFFBC898],
				[80, "[B]", 0xFFFF8000],
				[75, "[C+]", 0xFFFA5D5D],
				[70, "[C]", 0xFFFFFFFF],
				[0, "[D]", 0xFFFFFFFF],
			];
			
			for (thing in ratingArray) {
				if (songAccuracy >= thing[0]) {
				ratingTxt = thing[1];
				ratingColor = thing[2];
				break;
				}
			}

			infoTxt.text = "Score: " + songScore + " || " + "Accuracy: " + songAccuracy + "% " +  ratingTxt + " || " + "Combo: " + comboScore + " || " + "Misses: " + misses;

			comboScore = combo;

			if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}

			if (FlxG.keys.justPressed.SEVEN)
			{
				FlxG.switchState(new ChartingState());
			}

			if (FlxG.keys.justPressed.NINE)
				{
					if (iconP1.animation.curAnim.name == 'bf-old')
						iconP1.animation.play(SONG.player1);
					else
						iconP1.animation.play('bf-old');
				}

				switch (curStage)
				{
					case 'philly':
						if (trainMoving)
						{
							trainFrameTiming += elapsed;
		
							if (trainFrameTiming >= 1 / 24)
							{
								updateTrainPos();
								trainFrameTiming = 0;
							}
						}
				}

				iconP1.scale.set(FlxMath.lerp(iconP1.scale.x, 1, elapsed * 9), FlxMath.lerp(iconP1.scale.y, 1, elapsed * 9));
				iconP2.scale.set(FlxMath.lerp(iconP2.scale.x, 1, elapsed * 9), FlxMath.lerp(iconP2.scale.y, 1, elapsed * 9));
				
				iconP1.updateHitbox();
				iconP2.updateHitbox();
		
				var iconOffset:Int = 26;
		
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		
				if (health > 2)
					health = 2;
		
				if (healthBar.percent < 20)
					iconP1.animation.curAnim.curFrame = 1;
				else
					iconP1.animation.curAnim.curFrame = 0;
		
				if (healthBar.percent > 80)
					iconP2.animation.curAnim.curFrame = 1;
				else
					iconP2.animation.curAnim.curFrame = 0;

			#if debug
			if (FlxG.keys.justPressed.EIGHT)
				FlxG.switchState(new AnimationDebug(SONG.player2));
			#end

			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += FlxG.elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}
				}
			}

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				{
					vocals.volume = 1;

					
				switch (dad.curCharacter)
				{
					case 'dad', 'spooky', 'monster', 'pico', 'parents-christmas', 'monster-christmas':
						camFollow.setPosition(dad.getMidpoint().x + 200, dad.getMidpoint().y - 100);
					case 'mom', 'mom-car':
						camFollow.y = (dad.getMidpoint().y - 50);
						//camFollow.setPosition(dad.getMidpoint().x + 200);
						camFollow.x = (dad.getMidpoint().x + 100);
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x + 10;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x + 10;
					case 'spirit':
						camFollow.y = dad.getMidpoint().y - 100;
						camFollow.x = dad.getMidpoint().x;						
				}

					if (SONG.song.toLowerCase() == 'tutorial')
					{
						tweenCamIn();
					}
				}

				if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				{
					camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

					switch (curStage)
					{
						case 'school':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - 250;
					}

					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				}
			}

			if (camZooming)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			}

			FlxG.watch.addQuick("beatShit", totalBeats);

			if (curSong == 'Fresh')
			{
				switch (totalBeats)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
					case 163:
				}
			}
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			if (health <= 0)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;
				
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}

			if (unspawnNotes[0] != null)
			{
				if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
				{
					var dunceNote:Note = unspawnNotes[0];
					notes.add(dunceNote);

					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
				}
			}

			if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
	
						daNote.clipRect = swagRect;
					}
					
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
							if (SONG.needsVoices)
								vocals.volume = 1;

						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									altAnim = '-alt';
							}

						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

					if (daNote.y < -daNote.height)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							health -= 0.045;
							vocals.volume = 0;
							misses += 1;
							allNotes++;
							combo = 0;
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}

			keyShit();
	}

	function endSong():Void
	{
		deathCounter = 0;
		canPause = false;

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
	
						FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
					}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
	
			var rating:FlxSprite = new FlxSprite();
			var score:Int = 350;
			var ratingMod:Float = 1;
	
			var daRating:String = "sick";
			var isSick:Bool = true;
	
			if (noteDiff > Conductor.safeZoneOffset * 0.9)
			{
				daRating = 'shit';
				score = 50;
				ratingMod = 0;
				isSick = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			{
				daRating = 'bad';
				score = 100;
				ratingMod = 0.4;
				isSick = false;
			}
			else if (noteDiff > Conductor.safeZoneOffset * 0.275)
			{
				daRating = 'good';
				score = 200;
				ratingMod = 0.75;
				isSick = false;
			}

			if (isSick)
				{
					var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
					noteSplash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
					// new NoteSplash(note.x, daNote.y, daNote.noteData);
					if (ClientPrefs.getOption('notesplashes') == true)
						grpNoteSplashes.add(noteSplash);
				}
			coolNoteFloat += ratingMod;

			songScore += score;

			var pixelShitPart1:String = '';
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
				{
					pixelShitPart1 = 'pixelUI/';
					pixelShitPart2 = '-pixel';
				}

			rating.loadGraphic('assets/images/ui/' + pixelShitPart1 + daRating + pixelShitPart2 + ".png");
			if (ClientPrefs.getOption('ratingColors') == true)
				rating.color = ratingColor;


			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
				
			var comboSpr = new FlxSprite().loadGraphic('assets/images/ui/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
				rating.antialiasing = false;	
			if (ClientPrefs.getOption('ratingColors') == true)
				comboSpr.color = ratingColor;

			comboSpr.screenCenter();
			comboSpr.x = coolText.x;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			if (ClientPrefs.getOption('ratingOnCam') == false)
				comboSpr.scrollFactor.set(1, 1);
			if (ClientPrefs.getOption('ratingOnCam') == true)
				comboSpr.scrollFactor.set(0, 0);			
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			add(rating);
	
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;

			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
			if (ClientPrefs.getOption('comboSplash')){	
				if (combo > 9) 
					add(comboSpr);
			}

			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			if (ClientPrefs.getOption('ratingOnCam') == false)
				rating.scrollFactor.set(1, 1);
			if (ClientPrefs.getOption('ratingOnCam') == true)
				rating.scrollFactor.set(0, 0);	

			var seperatedScore:Array<Int> = [];
	
			seperatedScore.push(Math.floor(combo / 100));
			seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
			seperatedScore.push(combo % 10);
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/ui/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + '.png');
				if (ClientPrefs.getOption('ratingColors') == true)
					numScore.color = ratingColor;
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;
				
				if (ClientPrefs.getOption('ratingOnCam') == false)
					numScore.scrollFactor.set(1, 1);
				if (ClientPrefs.getOption('ratingOnCam') == true)
					numScore.scrollFactor.set(0, 0);	

				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (curStage.startsWith('school')){
					comboSpr.scale.set(4.25, 4.25);
					comboSpr.antialiasing = false;
					rating.scale.set(4.6, 4.6);
					rating.antialiasing = false;
					numScore.scale.set(4.7, 4.7);
					numScore.antialiasing = false;}

				else if (!curStage.startsWith('school')){
					comboSpr.scale.set(0.6, 0.6);
					comboSpr.antialiasing = true;
					rating.scale.set(0.7, 0.7);
					rating.antialiasing = true;
					numScore.scale.set(0.6, 0.6);
					numScore.antialiasing = true;
				}

				if (SONG.song.toLowerCase() == 'satin panties' || SONG.song.toLowerCase() == 'high' || SONG.song.toLowerCase() == 'milf'){
					new FlxTimer().start(0.3);
						comboSpr.acceleration.x = 1250;
						rating.acceleration.x = 1250;
						numScore.acceleration.x = 1250;
				}

				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
	
			coolText.text = Std.string(seperatedScore);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});
	
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
	
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
		}

		private function keyShit():Void
			{
				// HOLDING
				var up = controls.UP;
				var right = controls.RIGHT;
				var down = controls.DOWN;
				var left = controls.LEFT;
		
				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;
		
				var upR = controls.UP_R;
				var rightR = controls.RIGHT_R;
				var downR = controls.DOWN_R;
				var leftR = controls.LEFT_R;
		
				var heldControlArray:Array<Bool> = [left, down, up, right];
				var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		
				if (heldControlArray.indexOf(true) != -1 && generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && heldControlArray[daNote.noteData])
						{
							goodNoteHit(daNote);
						}
					});
				};
		
				if (controlArray.indexOf(true) != -1 && generatedMusic) {
					boyfriend.holdTimer = 0;
		
					var pressedNotes:Array<Note> = [];
					var noteDatas:Array<Int> = [];
					var epicNotes:Array<Note> = [];
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (noteDatas.indexOf(daNote.noteData) != -1)
							{
								for (i in 0...pressedNotes.length)
								{
									var note:Note = pressedNotes[i];
									if (note.noteData == daNote.noteData && Math.abs(daNote.strumTime - note.strumTime) < 10)
									{
										epicNotes.push(daNote);
										break;
									} else if (note.noteData == daNote.noteData && note.strumTime > daNote.strumTime){
										pressedNotes.remove(note);
										pressedNotes.push(daNote);
										break;
									}
								}
							}else{
								pressedNotes.push(daNote);
								noteDatas.push(daNote.noteData);
							}
						}
					});
					for (i in 0...epicNotes.length) {
						var note:Note = epicNotes[i];
						note.kill();
						notes.remove(note);
						note.destroy();
					}
		
					if (pressedNotes.length > 0)
						pressedNotes.sort(sortByShit);
		
					if (perfectMode){
						goodNoteHit(pressedNotes[0]);
					}else if (pressedNotes.length > 0){
						for (i in 0...controlArray.length) {
							if (controlArray[i] && noteDatas.indexOf(i) == -1) {
								badNoteCheck();
							}
						}
						for (i in 0...pressedNotes.length) {
							var note:Note = pressedNotes[i];
							if (controlArray[note.noteData]) {
								goodNoteHit(note);
							}
						}
					}else{
						badNoteCheck(); //turn this back to BadNoteHit if no work
					}
				};
		
				if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet && heldControlArray.indexOf(true) == -1)
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.playAnim('idle');
					}
				}
		
				playerStrums.forEach(function(spr:FlxSprite)
					{
						switch (spr.ID)
						{
							case 0:
								if (leftP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (leftR)
									spr.animation.play('static');
							case 1:
								if (downP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (downR)
									spr.animation.play('static');
							case 2:
								if (upP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (upR)
									spr.animation.play('static');
							case 3:
								if (rightP && spr.animation.curAnim.name != 'confirm')
									spr.animation.play('pressed');
								if (rightR)
									spr.animation.play('static');
						}

						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
							
					});
			}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.035;
			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));

			boyfriend.stunned = true;

			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
			}
			misses += 1;
		}
	}

	function badNoteCheck() {
		if (ClientPrefs.getOption('ghostTapping'))
			return;
		
		var pressedIndex:Int = [
			controls.LEFT,
			controls.UP,
			controls.DOWN,
			controls.RIGHT
		].indexOf(true);
		if (pressedIndex != -1)
			noteMiss(pressedIndex); // totally not ripped from Test Engine
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
			badNoteCheck();
	}

	function goodNoteHit(note:Note):Void
	{
			if (!note.isSustainNote) {
				combo += 1;
				allNotes++;
				popUpScore(note.strumTime, note);
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData) {
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite) {
				if (Math.abs(note.noteData) == spr.ID) {
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 10
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 10))
		{
			resyncVocals();
		}

		if (generatedMusic)
		{
			//if (ClientPrefs.getOption('downscroll') == false)
				notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			//else
				//notes.sort(FlxSort.byY, FlxSort.ASCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (camZooming && FlxG.camera.zoom < 1.35 && totalBeats % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

		if (totalBeats % gfSpeed == 0)
		{
			if (gfCanDance == true)
				gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.playAnim('idle');

		if (totalBeats % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);

			if (SONG.song == 'Tutorial' && dad.curCharacter == 'gf')
			{
				gf.playAnim('cheer', true);
			}
		}

		switch (curStage)
		{
			case "philly":
				if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}

			case 'limo':
				if (SONG.song.toLowerCase() == 'satin panties' || SONG.song.toLowerCase() == 'high' || SONG.song.toLowerCase() == 'milf')
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}
	
				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

				case 'school':
					bgGirls.dance();
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
		{
			if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
			{
				trainMoving = true;
				if (!trainSound.playing)
					trainSound.play(true);
			}
		}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
		{
			if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
			{
				if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
					gfCanDance = false;
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
			}
		}

	function trainReset():Void
		{
			if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
			{
				gf.playAnim('hairFall');
				phillyTrain.x = FlxG.width + 200;
				trainMoving = false;
				trainCars = 8;
				trainFinishing = false;
				startedMoving = false;
				var timer:FlxTimer = new FlxTimer().start(0.46, resetGFAnim);
			}
		}
	var gfCanDance = true;

	function resetGFAnim(timer:FlxTimer):Void
		{
			if (SONG.song.toLowerCase() == 'pico' || SONG.song.toLowerCase() == 'philly nice' || SONG.song.toLowerCase() == 'blammed')
			{
				gfCanDance = true;
			}
		}
		
	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (SONG.song.toLowerCase() == 'satin panties' || SONG.song.toLowerCase() == 'high' || SONG.song.toLowerCase() == 'milf')
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}
	
	function fastCarDrive()
	{
		if (SONG.song.toLowerCase() == 'satin panties' || SONG.song.toLowerCase() == 'high' || SONG.song.toLowerCase() == 'milf')
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
		
			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
		{
			var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
	
			var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
			red.scrollFactor.set();
	
			var senpaiEvil:FlxSprite = new FlxSprite();
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/stages/week6/senpaiCrazy.png', 'assets/images/stages/week6/senpaiCrazy.xml');
			senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
			senpaiEvil.scrollFactor.set();
			senpaiEvil.updateHitbox();
			senpaiEvil.screenCenter();
	
			if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
			{
				remove(black);
	
				if (SONG.song.toLowerCase() == 'thorns')
				{
					add(red);
				}
			}
	
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
	
				if (black.alpha > 0)
				{
					tmr.reset(0.3);
				}
				else
				{
					if (dialogueBox != null)
					{
						inCutscene = true;
	
						if (SONG.song.toLowerCase() == 'thorns')
						{
							add(senpaiEvil);
							senpaiEvil.alpha = 0;
							new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
							{
								senpaiEvil.alpha += 0.15;
								if (senpaiEvil.alpha < 1)
								{
									swagTimer.reset();
								}
								else
								{
									senpaiEvil.animation.play('idle');
									FlxG.sound.play('assets/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
									{
										remove(senpaiEvil);
										remove(red);
										FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
										{
											add(dialogueBox);
										}, true);
									});
									new FlxTimer().start(3.2, function(deadTime:FlxTimer)
									{
										FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
									});
								}
							});
						}
						else
						{
							add(dialogueBox);
						}
					}
					else
						startCountdown();
	
					senpaiCutsceneDebug = false;
					remove(black);
				}
			});
		}

	function recalculateAccuracy(miss:Bool = false) // Thank you Mackery
	{
        if (miss)
            coolNoteFloat -= 1;
    
        //to make sure we don't divide by 0
        if (allNotes == 0)
            songAccuracy = 100;
        else
            songAccuracy = FlxMath.roundDecimal(Math.max(0, coolNoteFloat / allNotes * 100), 2);
	}
}