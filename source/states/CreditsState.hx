package states;

import config.Configure;
import flixel.FlxSprite;
import flixel.ui.FlxVirtualPad.FlxDPadMode;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.UiHelpers;

class CreditsState extends FlxUIState {

    var _allCreditElements:Array<FlxSprite>;

    var _btnMainMenu:FlxButton;

    var _txtCreditsTitle:FlxText;
    var _txtThankYou:FlxText;
    var _txtBestCombo:FlxText;
    var _txtRole:Array<FlxText>;
    var _txtCreator:Array<FlxText>;

    var scrollSpeed:Float = 66;

    override public function create():Void {
        super.create();
        bgColor = FlxColor.TRANSPARENT;


        var bgImage = new FlxSprite(AssetPaths.creditsSplash__png);
        bgImage.width = FlxG.width;
        bgImage.height = FlxG.height;
        add(bgImage);

        // Button

        _btnMainMenu = UiHelpers.CreateMenuButton("Main Menu", clickMainMenu);
        _btnMainMenu.setPosition(FlxG.width - _btnMainMenu.width, FlxG.height - _btnMainMenu.height);
        _btnMainMenu.updateHitbox();
        add(_btnMainMenu);

        // Credits

        _allCreditElements = new Array<FlxSprite>();

        _txtCreditsTitle = new FlxText();
        _txtThankYou = new FlxText();
        _txtBestCombo = new FlxText();
        _txtRole = new Array<FlxText>();
        _txtCreator = new Array<FlxText>();

        _txtCreditsTitle.size = 40;
        _txtCreditsTitle.alignment = FlxTextAlign.CENTER;
        _txtCreditsTitle.text = "Credits";
        _txtCreditsTitle.setPosition(FlxG.width/2 - _txtCreditsTitle.width/2, FlxG.height/2);
        add(_txtCreditsTitle);
        _allCreditElements.push(_txtCreditsTitle);

        for (entry in Configure.getCredits()) {
            AddSectionToCreditsTextArrays(entry.sectionName, entry.names, _txtRole, _txtCreator);
        }

        var creditsTextVerticalOffset = FlxG.height;

        for (flxText in _txtRole) {
            flxText.setPosition(0, creditsTextVerticalOffset);
            creditsTextVerticalOffset += 25;
        }

        creditsTextVerticalOffset = FlxG.height;
        creditsTextVerticalOffset += 25;

        for (flxText in _txtCreator) {
            flxText.setPosition(FlxG.width - flxText.width, creditsTextVerticalOffset);
            creditsTextVerticalOffset += 25;
        }

        var flStudioLogo = new FlxSprite();
        flStudioLogo.loadGraphic(AssetPaths.FLStudioLogo__png);
        flStudioLogo.scale.set(.25, .25);
        flStudioLogo.updateHitbox();
        flStudioLogo.setPosition(-35, creditsTextVerticalOffset);
        add(flStudioLogo);
        _allCreditElements.push(flStudioLogo);

        var fmodLogo = new FlxSprite();
        fmodLogo.loadGraphic(AssetPaths.FmodLogoWhite__png);
        fmodLogo.scale.set(.4, .4);
        fmodLogo.updateHitbox();
        fmodLogo.setPosition(5, creditsTextVerticalOffset + flStudioLogo.height);
        add(fmodLogo);
        _allCreditElements.push(fmodLogo);

        var haxeFlixelLogo = new FlxSprite();
        haxeFlixelLogo.loadGraphic(AssetPaths.HaxeFlixelLogo__png);
        haxeFlixelLogo.scale.set(.5, .5);
        haxeFlixelLogo.updateHitbox();
        haxeFlixelLogo.setPosition(fmodLogo.width + 40, creditsTextVerticalOffset + flStudioLogo.height + 10);
        add(haxeFlixelLogo);
        _allCreditElements.push(haxeFlixelLogo);

        _txtThankYou.size = 40;
        _txtThankYou.alignment = FlxTextAlign.CENTER;
        _txtThankYou.text = "Thank you!";
        _txtThankYou.setPosition(FlxG.width/2 - _txtThankYou.width/2, haxeFlixelLogo.y + haxeFlixelLogo.height + FlxG.height / 2);
        add(_txtThankYou);
        _allCreditElements.push(_txtThankYou);

        if (Statics.MaxCombo > 0) {
            _txtBestCombo.size = 40;
            _txtBestCombo.alignment = FlxTextAlign.CENTER;
            _txtBestCombo.text = "BEST COMBO: " + Statics.MaxCombo;
            _txtBestCombo.setPosition(FlxG.width/2 - _txtBestCombo.width/2, _txtThankYou.y + _txtThankYou.height + 24);
            add(_txtBestCombo);
            _allCreditElements.push(_txtBestCombo);
        }
    }

    private function AddSectionToCreditsTextArrays(role:String, creators:Array<String>, finalRoleArray:Array<FlxText>, finalCreatorsArray:Array<FlxText>) {
        var roleText = new FlxText();
        roleText.size = 15;
        roleText.fieldWidth = Std.int(FlxG.width / 0.67);
        roleText.text = role;
        add(roleText);
        finalRoleArray.push(roleText);
        _allCreditElements.push(roleText);

        if (finalCreatorsArray.length != 0) {
            finalCreatorsArray.push(new FlxText());
        }

        for(creator in creators){
            // Make an offset entry for the roles array
            finalRoleArray.push(new FlxText());

            var creatorText = new FlxText();
            creatorText.autoSize = false;
            creatorText.size = 15;
            creatorText.alignment = FlxTextAlign.RIGHT;
            creatorText.fieldWidth = Std.int(FlxG.width / 0.67);
            creatorText.text = creator;
            add(creatorText);
            finalCreatorsArray.push(creatorText);
            _allCreditElements.push(creatorText);
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Stop scrolling when "Thank You" text is in the center of the screen
        if (_txtThankYou.y + _txtThankYou.height/2 < FlxG.height/2){
            return;
        }

        for(element in _allCreditElements) {
            if (FlxG.keys.pressed.SPACE || FlxG.mouse.pressed){
                element.y -= scrollSpeed * 4 * elapsed;
            } else {
                element.y -= scrollSpeed * elapsed;
            }
        }
    }

    function clickMainMenu():Void {
        FmodFlxUtilities.TransitionToState(new MainMenuState());
    }
}