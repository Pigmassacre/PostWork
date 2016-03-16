package com.pigmassacre.postwork.managers;

import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.PooledEngine;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.components.*;

/**
 * Created by pigmassacre on 2016-03-16.
 */
public class EntityCreator {

    public static Entity createPlayer(PooledEngine engine, float x, float y, float width, float height) {
        Entity entity = engine.createEntity();
        PositionComponent position = engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        entity.add(position);
        VisualComponent visual = engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        visual.width = width;
        visual.height = height;
        entity.add(visual);
        entity.add(engine.createComponent(PlayerControllerComponent.class));
        entity.add(engine.createComponent(JoystickControllerComponent.class));
        CollisionComponent collision = engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        entity.add(collision);
        entity.add(engine.createComponent(StopMovementOnCollisionComponent.class));
        entity.add(engine.createComponent(AccelerationComponent.class));
        entity.add(engine.createComponent(DragComponent.class));
        entity.add(engine.createComponent(VelocityComponent.class));
        entity.add(engine.createComponent(CameraFocusComponent.class));

        engine.addEntity(entity);

        return entity;
    }

    public static Entity createBullet(PooledEngine engine, float x, float y, float width, float height, Entity homingTarget) {
        Entity entity = engine.createEntity();
        PositionComponent position = engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        entity.add(position);
        VisualComponent visual = engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        visual.width = width;
        visual.height = height;
        entity.add(visual);
        CollisionComponent collision = engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        entity.add(collision);
        entity.add(engine.createComponent(StopMovementOnCollisionComponent.class));
        entity.add(engine.createComponent(AccelerationComponent.class));
        entity.add(engine.createComponent(DragComponent.class));
        entity.add(engine.createComponent(VelocityComponent.class));

        HomingComponent homing = engine.createComponent(HomingComponent.class);
        homing.target = homingTarget;
        entity.add(homing);
        entity.add(engine.createComponent(AngleComponent.class));

        engine.addEntity(entity);

        return entity;
    }

    public static Entity createMap(PooledEngine engine) {
        Entity map = engine.createEntity();
        MapComponent mapComponent = engine.createComponent(MapComponent.class);
        mapComponent.init(256, 256);
        mapComponent.rectangle.x = -128;
        mapComponent.rectangle.y = -128;
        map.add(mapComponent);
        engine.addEntity(map);

        return map;
    }

}
