package com.pigmassacre.postwork.managers;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.badlogic.gdx.utils.Array;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.components.collision.*;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-03-16.
 */
public class EntityCreator {

    private static Array<String> images = new Array<String>();

    static {
        images.add("froglet_enemy1.png");
        images.add("starball_enemy1.png");
        images.add("yellowcrab_enemy1.png");
    }

    public static Entity createPlayer(float x, float y, float width, float height) {
        Entity entity = createBasicMovingEntity(x, y, width, height);

        makePlayerControlled(entity);
        makeVisual(entity, width, height, "player_ship1.png");

        entity.add(GameManager.getGame().engine.createComponent(ShootingComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(CameraFocusComponent.class));

        GameManager.getGame().engine.addEntity(entity);

        return entity;
    }

    public static Entity createHomingEnemy(float x, float y, float width, float height, Entity homingTarget) {
        Entity entity = createBasicMovingEntity(x, y, width, height);

        makeVisual(entity, width, height, null);
        makeHoming(entity, homingTarget);
        Mappers.propel.get(entity).speed = 2f;

        GameManager.getGame().engine.addEntity(entity);

        return entity;
    }

    public static Entity createBullet(float x, float y, float width, float height) {
        Entity bullet = createBasicMovingEntity(x, y, width, height);

        makeVisual(bullet, width, height, null);

        bullet.add(GameManager.getGame().engine.createComponent(DamageOnCollisionComponent.class));
//        bullet.add(GameManager.getGame().engine.createComponent(DestroyOnMapCollisionComponent.class));

        GameManager.getGame().engine.addEntity(bullet);

        return bullet;
    }

    public static Entity createHomingBullet(float x, float y, float width, float height, Entity homingTarget) {
        Entity bullet = createBullet(x, y, width, height);
        makeHoming(bullet, homingTarget);
        return bullet;
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
        entity.add(GameManager.getGame().engine.createComponent(AngleComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(PropelComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(StopMovementOnCollisionComponent.class));

        return entity;
    }

    public static Entity makePlayerControlled(Entity entity) {
        entity.add(GameManager.getGame().engine.createComponent(PlayerOwnedComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(PlayerControllerComponent.class));
        entity.add(GameManager.getGame().engine.createComponent(JoystickControllerComponent.class));

        return entity;
    }

    public static Entity makeVisual(Entity entity, float width, float height, String image) {
        VisualComponent visual = GameManager.getGame().engine.createComponent(VisualComponent.class);
        final Texture texture = new Texture(Gdx.files.internal(image != null ? image : images.random()));
        visual.region = new TextureRegion(texture, texture.getWidth(), texture.getHeight());
        visual.width = width;
        visual.height = height;
        entity.add(visual);

        return entity;
    }

    public static Entity makeHoming(Entity entity, Entity homingTarget) {
        HomingComponent homing = GameManager.getGame().engine.createComponent(HomingComponent.class);
        homing.target = homingTarget;
        entity.add(homing);

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
