package com.pigmassacre.postwork.utils;

import com.badlogic.ashley.core.ComponentMapper;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.collision.DamageOnCollisionComponent;
import com.pigmassacre.postwork.components.collision.MapComponent;
import com.pigmassacre.postwork.components.collision.StopMovementOnCollisionComponent;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class Mappers {
    public static final ComponentMapper<PositionComponent> position = ComponentMapper.getFor(PositionComponent.class);
    public static final ComponentMapper<PlayerControllerComponent> playerController = ComponentMapper.getFor(PlayerControllerComponent.class);
    public static final ComponentMapper<VelocityComponent> velocity = ComponentMapper.getFor(VelocityComponent.class);
    public static final ComponentMapper<AccelerationComponent> acceleration = ComponentMapper.getFor(AccelerationComponent.class);
    public static final ComponentMapper<VisualComponent> visual = ComponentMapper.getFor(VisualComponent.class);
    public static final ComponentMapper<CollisionComponent> collision = ComponentMapper.getFor(CollisionComponent.class);
    public static final ComponentMapper<MapComponent> map = ComponentMapper.getFor(MapComponent.class);
    public static final ComponentMapper<StopMovementOnCollisionComponent> stopMovement = ComponentMapper.getFor(StopMovementOnCollisionComponent.class);
    public static final ComponentMapper<DamageOnCollisionComponent> damageCollision = ComponentMapper.getFor(DamageOnCollisionComponent.class);
    public static final ComponentMapper<JoystickControllerComponent> joystickController = ComponentMapper.getFor(JoystickControllerComponent.class);
    public static final ComponentMapper<HomingComponent> homing = ComponentMapper.getFor(HomingComponent.class);
    public static final ComponentMapper<AngleComponent> angle = ComponentMapper.getFor(AngleComponent.class);
    public static final ComponentMapper<PropelComponent> propel = ComponentMapper.getFor(PropelComponent.class);
    public static final ComponentMapper<ShootingComponent> shooting = ComponentMapper.getFor(ShootingComponent.class);
    public static final ComponentMapper<PlayerOwnedComponent> playerOwned = ComponentMapper.getFor(PlayerOwnedComponent.class);
}
