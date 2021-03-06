package ;
import aze.display.TileSprite;
import flash.display.Sprite;
import openfl.Assets;
/**
 * ...
 * @author Al
 */
class Player
{
	private static var player:Unit;
	
	public static var grabRange:Float = 100;
    private static var attackCharges:Int = 0;
    public static var playerWeapon:String = "fists";
    public static var strikeAreaX:Float;
    public static var strikeAreaY:Float;
    
	
	public static var highlightType:String = "none";
	public static var highlightedUnit:Unit;
	public static var highlightedCorpse:Corpse;
	private static var highlightSpriteDog:TileSprite;
	private static var highlightSpriteGun:TileSprite;
	private static var highlightSpriteHandman:TileSprite;
	private static var highlightUnitToSprite:Map<String,TileSprite> = new Map<String,TileSprite>();
	
	private static var bodySpriteBasic1:TileSprite;
	private static var bodySpriteBasic2:TileSprite;
	private static var bodySpriteBasic3:TileSprite;
    private static var bodySpriteDog1:TileSprite;
	private static var bodySpriteDog2:TileSprite;
	private static var bodySpriteDog3:TileSprite;    
    private static var bodySpriteGun1:TileSprite;
	private static var bodySpriteGun2:TileSprite;
	private static var bodySpriteGun3:TileSprite;    
    private static var bodySpriteHand1:TileSprite;
	private static var bodySpriteHand2:TileSprite;
	private static var bodySpriteHand3:TileSprite;
    
    public static var redHandSprite:TileSprite;
    public static var redHandTime:Int;
	
	public static function dropWeapon() {
        swapWeapon("fists");
	}
	
	public static function swapWeapon(next:String) {
        if ( next == "fists" ) {            
            player.dmg = Main.playerBaseDmg;
            player.ranged = false;
            player.spriteBody1 = bodySpriteBasic1;
            player.spriteBody2 = bodySpriteBasic2;
            player.spriteBody3 = bodySpriteBasic3;
            strikeAreaX = 100;
            strikeAreaY = 200;
        }
		if ( next == "dog" ) {
            attackCharges = 3;
            player.dmg = 10;
            player.ranged = false;
            strikeAreaX = 100;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteDog1;
            player.spriteBody2 = bodySpriteDog2;
            player.spriteBody3 = bodySpriteDog3;
        }        
        
		if ( next == "gun" ) {
            attackCharges = 5;
            player.dmg = 15;
            player.ranged = true;
            strikeAreaX = 100;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteGun1;
            player.spriteBody2 = bodySpriteGun2;
            player.spriteBody3 = bodySpriteGun3;
        }        
        
		if ( next == "hand" ) {
            attackCharges = 6;
            player.dmg = 20;
            player.ranged = false;
            strikeAreaX = 150;
            strikeAreaY = 200;
            player.spriteBody1 = bodySpriteHand1;
            player.spriteBody2 = bodySpriteHand2;
            player.spriteBody3 = bodySpriteHand3;
        }        
        var animState:Int = player.animState;
        player.animState = 0;
        player.setAnimTo(animState);
        playerWeapon = next;        
        player.positionSprites();
        if ( player.currentSprite != null ) {
            player.currentSprite.mirror = player.lastMirrorState;
        }
	}
    
    public static function useAttackCharge() {
        if ( playerWeapon == "fists" )  return;
        --attackCharges;
        if ( attackCharges <= 0 )   dropWeapon();
    }
    
    public static function redHandTick() {
        if ( redHandSprite.visible = true ) {
            redHandSprite.x = player.x + 60 * player.lastDirection;
            redHandSprite.y = player.y - 55;
            redHandSprite.mirror = player.lastDirection <= 0 ? 1 : 0;
            --redHandTime;
            if ( !player.onCharge() ) {
                if (( redHandTime > 20 ) && (playerWeapon == "fists")) {
                    if ( redHandTime > 25 ) {
                        player.setAnimTo(2);
                    } else {
                        player.setAnimTo(3);
                    }
                } else {
                    player.setAnimTo(1);
                }
            }
            redHandSprite.alpha = 0.5 + (0.5 * redHandTime / 30);
            if ( redHandTime <= 0 ) {
                redHandSprite.visible = false;                
            }
        }
    }
    
    public static function redHandOn() {
        redHandSprite.visible = true;
        redHandTime = 30;
        redHandTick();        
        var soundfx1 = Assets.getSound("audio/grab.wav");
        soundfx1.play();
    }
	
	public static function attemptGrab():Bool {
        redHandOn();
		if (( highlightType == "unit" ) && (player.distanceXBetween(highlightedUnit) <= grabRange)) {
			if ( grabbable(highlightedUnit) ) {                                
				if ( highlightedUnit.unitType == "dog" ) {
					highlightedUnit.removeFromGame();
					swapWeapon("dog");
					return true;
				}
                if ( highlightedUnit.unitType == "gun" ) {
					highlightedUnit.destroyBody();
					swapWeapon("gun");
					return true;
				}
                if ( highlightedUnit.unitType == "handman" ) {
					highlightedUnit.destroyBody();
					swapWeapon("hand");
					return true;
				}
			}
		}
        if (( highlightType == "corpse" ) && (player.distanceOuterTo(highlightedCorpse.x, highlightedCorpse.y) - highlightedCorpse.sizeX / 2 <= grabRange)) {            
			if ( grabbableCorpse(highlightedCorpse) ) {                
                if ( highlightedCorpse.sourceUnittype== "gun" ) {
					highlightedCorpse.removeBodyPart();
					swapWeapon("gun");
					return true;
				}
			}
		}
		return false;
	}
	
	private static function grabbable(unit:Unit):Bool {
        if ( unit.noBody )  return false;
		if (unit.unitType == "dog")	return (playerWeapon=="fists");
		if (unit.unitType == "gun")	return (unit.hp/unit.hpMax < 0.75);
		if (unit.unitType == "handman")	return (unit.hp/unit.hpMax < 0.5);
		return false;
	}
    
    private static function grabbableCorpse(corpse:Corpse):Bool {
        if ( corpse.noBody )  return false;
		if (corpse.sourceUnittype == "gun")	return true;
		if (corpse.sourceUnittype == "handman")	return true;
		return false;
	}
	
	public static function updateGrabHighlight() {
		for ( enemy in Main.enemies ) {
			if (grabbable(enemy))  {
				if ( player.distanceXBetween(enemy) < grabRange ) {
					if(!sameHighlight(enemy))	highlightRemove();
					highlightUnit(enemy);
					return;
				}
				if ( player.distanceXBetween(enemy) < grabRange * 3 ) {
					if(!sameHighlight(enemy))	highlightRemove();
					highlightUnit(enemy);
					return;
				}
			}
		}
        for ( corpse in Main.corpses ) {
            if ( grabbableCorpse(corpse) ) {
                if ( player.distanceOuterTo(corpse.x, corpse.y) - corpse.sizeX/2 < grabRange) {
					if(!sameHighlightCorpse(corpse))	highlightRemove();
					highlightCorpse(corpse);
					return;
				}
				if ( player.distanceOuterTo(corpse.x, corpse.y) - corpse.sizeX/2 < grabRange * 3) {
					if(!sameHighlightCorpse(corpse))	highlightRemove();
					highlightCorpse(corpse);
					return;
				}
            }
        }
		highlightRemove();
	}
	
	public static function highlightPosUpdate() {
		if ( highlightType == "unit" ) {
			if (true || ( highlightedUnit.unitType == "dog" ) || (highlightedUnit.unitType == "gun") || (highlightedUnit.unitType == "handman")) {
				highlightUnitToSprite.get(highlightedUnit.unitType).x = highlightedUnit.currentSprite.x;
				highlightUnitToSprite.get(highlightedUnit.unitType).y = highlightedUnit.currentSprite.y;
				highlightUnitToSprite.get(highlightedUnit.unitType).mirror = highlightedUnit.currentSprite.mirror;
				highlightUnitToSprite.get(highlightedUnit.unitType).alpha = (1 - player.distanceXBetween(highlightedUnit) / (3*grabRange));
			}
		}
        if ( highlightType == "corpse" ) {
            highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).x = highlightedCorpse.x;
            highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).y = highlightedCorpse.y;
            highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).mirror = highlightedCorpse.getMirror();
            highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).alpha = (1 - (player.distanceOuterTo(highlightedCorpse.x, highlightedCorpse.y) - highlightedCorpse.sizeX/2) / (3*grabRange));
        }
	}
	
	private static function highlightRemove() {
		if ( highlightType == "unit" ) {
			highlightUnitToSprite.get(highlightedUnit.unitType).visible = false;
			//if ( highlightedUnit.unitType == "dog" ) {
				//highlightSpriteDog.visible = false;
			//}
			highlightType = "none";
			highlightedUnit = null;
		}
        if ( highlightType == "corpse" ) {
            highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).visible = false;
            highlightType = "none";
            highlightedCorpse = null;
        }
	}
	
	private static function highlightUnit(unit:Unit) {
		if (!sameHighlight(unit)) {
			highlightType = "unit";
			highlightedUnit = unit;
			highlightUnitToSprite.get(highlightedUnit.unitType).visible = true;
		}
		highlightPosUpdate();
	}
	
    private static function highlightCorpse(corpse:Corpse) {
		if (!sameHighlightCorpse(corpse)) {
			highlightType = "corpse";
			highlightedCorpse = corpse;
			highlightUnitToSprite.get(highlightedCorpse.sourceUnittype).visible = true;
		}
		highlightPosUpdate();
	}
    
	private static function sameHighlight(unit:Unit) {
		return (( highlightType == "unit" ) && (highlightedUnit == unit));
	}
    
    private static function sameHighlightCorpse(corpse:Corpse) {
		return (( highlightType == "corpse" ) && (highlightedCorpse == corpse));
	}
   
    private static function registerSprite(sprite:TileSprite) {
        Main.layer.addChild(sprite);
        sprite.visible = false;
    }
	
	public static function init() {
		player = Main.player;
		bodySpriteBasic1 = new TileSprite(Main.layer, "herobasic1");
		bodySpriteBasic2 = new TileSprite(Main.layer, "herobasic2");
		bodySpriteBasic3 = new TileSprite(Main.layer, "herobasic3");
		
		
		highlightSpriteDog = new TileSprite(Main.layer, "evildoglight");
		highlightSpriteDog.visible = false;
		Main.layer.addChildAt(highlightSpriteDog, 0);
		highlightUnitToSprite.set("dog", highlightSpriteDog);
		highlightSpriteGun = new TileSprite(Main.layer, "evilgunlight");
		highlightSpriteGun.visible = false;
		Main.layer.addChildAt(highlightSpriteGun, 0);
		highlightUnitToSprite.set("gun", highlightSpriteGun);		
		highlightSpriteHandman = new TileSprite(Main.layer, "evilhandmanlight");
		highlightSpriteHandman.visible = false;
		Main.layer.addChildAt(highlightSpriteHandman, 0);
		highlightUnitToSprite.set("handman", highlightSpriteHandman);
        
        redHandSprite = new TileSprite(Main.layer, "redhand");
        registerSprite(redHandSprite);
	}
    
    public static function initWeapons() {        
        bodySpriteDog1 = new TileSprite(Main.layer, "herodog1");
        registerSprite(bodySpriteDog1);
        bodySpriteDog2 = new TileSprite(Main.layer, "herodog2");
        registerSprite(bodySpriteDog2);
        bodySpriteDog3 = new TileSprite(Main.layer, "herodog3");
        registerSprite(bodySpriteDog3);
        
        bodySpriteGun1 = new TileSprite(Main.layer, "herogun1");
        registerSprite(bodySpriteGun1);
        bodySpriteGun2 = new TileSprite(Main.layer, "herogun2");
        registerSprite(bodySpriteGun2);
        bodySpriteGun3 = new TileSprite(Main.layer, "herogun3");
        registerSprite(bodySpriteGun3);
        
        bodySpriteHand1 = new TileSprite(Main.layer, "herohand1");
        registerSprite(bodySpriteHand1);
        bodySpriteHand2 = new TileSprite(Main.layer, "herohand2");
        registerSprite(bodySpriteHand2);
        bodySpriteHand3 = new TileSprite(Main.layer, "herohand3");
        registerSprite(bodySpriteHand3);
    }
	
}