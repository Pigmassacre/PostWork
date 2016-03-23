package com.pigmassacre.postwork.managers;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.collision.DamageOnCollisionComponent;
import com.pigmassacre.postwork.components.collision.MapComponent;
import com.pigmassacre.postwork.components.collision.StopMovementOnCollisionComponent;

/**
 * Created by pigmassacre on 2016-03-16.
 */
public class EntityCreator {

    public static Entity createPlayer(float x, float y, float width, float height) {
        Entity entity = createBasicMovingEntity(x, y, width, height);

        makePlayerControlled(entity);
        makeVisual(entity, width, height);

        entity.add(GameManager.getGame().engine.createComponent(ShootingComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(CameraFocusComponent.class));

        GameManager.getGame().engine.addEntity(entity);

        return entity;
    }

    public static Entity createHomingEnemy(float x, float y, float width, float height, Entity homingTarget) {
        Entity entity = createBasicMovingEntity(x, y, width, height);

        makeVisual(entity, width, height);
        makeHoming(entity, homingTarget);

        GameManager.getGame().engine.addEntity(entity);

        return entity;
    }

    public static Entity createBullet(float x, float y, float width, float height, Entity homingTarget) {
        Entity entity = createBasicMovingEntity(x, y, width, height);

        makeVisual(entity, width, height);
        makeHoming(entity, homingTarget);

        entity.add(GameManager.getGame().engine.createComponent(DamageOnCollisionComponent.class));

        GameManager.getGame().engine.addEntity(entity);

        return entity;
    }

    public static Entity createBasicMovingEntity(float x, float y, float width, float height) {
        Entity entity = GameManager.getGame().engine.createEntity();
        PositionComponent position = GameManager.getGame().engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        entity.add(position);
        CollisionComponent collision = GameManager.getGame().engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        entity.add(collision);
        entity.add(GameManager.getGame().engine.createComponent(AccelerationComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(DragComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(VelocityComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(StopMovementOnCollisionComponent.class));

        return entity;
    }

    public static Entity makePlayerControlled(Entity entity) {
        entity.add(GameManager.getGame().engine.createComponent(PlayerOwnedComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(PlayerControllerComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(JoystickControllerComponent.class));

        return entity;
    }

    public static Entity makeVisual(Entity entity, float width, float height) {
        VisualComponent visual = GameManager.getGame().engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("froglet_enemy1.png")), 8, 8);
        visual.width = width;
        visual.height = height;
        entity.add(visual);

        return entity;
    }

    public static Entity makeHoming(Entity entity, Entity homingTarget) {
        HomingComponent homing = GameManager.getGame().engine.createComponent(HomingComponent.class);
        homing.target = homingTarget;
        entity.add(homing);
        entity.add(GameManager.getGame().engine.createComponent(AngleComponent.class));

        return entity;
    }

    public static Entity createMap() {
        Entity map = GameManager.getGame().engine.createEntity();
        MapComponent mapComponent = GameManager.getGame().engine.createComponent(MapComponent.class);
        mapComponent.init(256, 256);
        mapComponent.rectangle.x = -128;
        mapComponent.rectangle.y = -128;
        map.add(mapComponent);
        GameManager.getGame().engine.addEntity(map);

        return map;
    }

}
