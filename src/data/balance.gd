class_name Balance
## Every number worth tuning, in one place. Those marked "the original's" are
## the libGDX game's, turned from pixels per frame at 60 frames a second into
## pixels per second.

# --- flying ------------------------------------------------------------------
## The original's propel of 6 (360) and drag of 0.985 a frame (0.907) gave a top speed of
## about 397, and this keeps it, but with more grip: its floors are a lot busier.
const THRUST := 480.0
const DRAG := 1.2
## The original's: how fast the ship (and everything else) turns to where it wants to go.
const TURN := 16.0
## The original's stick had to be pushed this far before the ship turned.
const STICK_DEADZONE := 0.33
const SHIP_RADIUS := 3.5
const START_HULL := 4
const MAX_HULL := 6
const INVULNERABLE_AFTER_HIT := 1.4
const HIT_SHOVE_REACH := 60.0
const HIT_SHOVE := 240.0
## Speed lost on the way along a wall, a second (the original stopped dead on it only across).
const WALL_KNOCK := 40.0

# --- the guns ----------------------------------------------------------------
## The original's: a salvo every eighth of a second.
const SALVO_TIME := 0.125
## How many targets a salvo can go to; they take turns when there are more.
const SALVO_WIDTH := 2
const MISSILE_LIMIT := 360
## The original's propel of 14.
const MISSILE_THRUST := 840.0
const MISSILE_TURN := 16.0
const MISSILE_LIFE := 2.4
const MISSILE_KICK := 170.0
## How much of the ship's speed a missile leaves with.
const MISSILE_INHERIT := 0.5
## The original's damage.
const MISSILE_DAMAGE := 2.0
## Flat out, a missile hits this much harder than from a standstill.
const SPEED_DAMAGE := 0.75

# --- the SMASK ---------------------------------------------------------------
const CHARGE_TIME := 0.7
## Below this it's only a pause in the shooting, and nothing's let go.
const CHARGE_MIN := 0.22
## The original's: charging slows the ship to this.
const CHARGE_SPEED_LIMIT := 42.0
const CHARGE_BRAKE := 7.0
## The world slows down round a charge, to this, after a moment.
const CHARGE_SLOWMO := 0.55
const SMASK_SPEED_MIN := 460.0
const SMASK_SPEED_MAX := 880.0
const SMASK_TIME_MIN := 0.14
const SMASK_TIME_MAX := 0.30
const SMASK_DAMAGE_MIN := 12.0
const SMASK_DAMAGE_MAX := 44.0
const SMASK_RADIUS := 11.0
const SMASK_COOLDOWN := 0.65
## Invulnerable this much longer than the SMASK.
const SMASK_GRACE := 0.14
## Into a wall: a shock wave.
const WALL_SHOCK_RADIUS_MIN := 28.0
const WALL_SHOCK_RADIUS_MAX := 84.0
const WALL_SHOCK_DAMAGE_MIN := 8.0
const WALL_SHOCK_DAMAGE_MAX := 30.0
const WALL_BOUNCE := 0.65

# --- what you get ------------------------------------------------------------
const COMBO_TIME := 2.2
const COMBO_PER_STEP := 6
const MULTIPLIER_MAX := 16
const COIN_VALUE := 10
const COIN_REACH := 42.0
const COIN_PULL := 520.0
const COIN_LIFE := 7.0
const COFFEE_CHANCE := 0.012
## Hull at or under this and the coffee's more likely.
const COFFEE_LOW_HULL := 1
const COFFEE_LOW_CHANCE := 0.04
const CLEAR_BONUS := 1000
const QUICK_BONUS_TIME := 75.0
const QUICK_BONUS := 3000
const NO_HIT_BONUS := 2000

# --- bumpers and shrinking walls ---------------------------------------------
const BUMPER_RADIUS := 8.0
const BUMPER_KICK := 430.0
const SHRINK_SPEED := 3.0
const SHRINK_LIMIT := 0.6

# --- the graveyard shift, per hour past midnight --------------------------------
const GRAVEYARD_HP := 0.2
const GRAVEYARD_COUNT := 0.1

# --- how shots behave ----------------------------------------------------------
const SHOT_RADIUS := 2.0
const SHOT_LIFE := 7.0
const SPAWN_WARNING := 0.75
const SPAWN_MARGIN := 12.0
const SPAWN_AWAY_FROM_SHIP := 90.0
## Up to this many things are shoved apart per step, so they don't stack.
const SEPARATION := 90.0
