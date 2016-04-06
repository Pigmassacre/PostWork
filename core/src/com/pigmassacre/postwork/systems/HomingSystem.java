package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class HomingSystem extends IteratingSystem {

    public HomingSystem() {
        super(Family.all(HomingComponent.class, AngleComponent.class).one(CollisionComponent.class, PositionComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final HomingComponent homing = Mappers.homing.get(entity);
        final AngleComponent angle = Mappers.angle.get(entity);
        CollisionComponent collision = Mappers.collision.get(entity);

        CollisionComponent targetCollision = Mappers.collision.get(homing.target);

        if (targetCollision == null) {
            ImmutableArray<Entity> newEntities = GameManager.getGame().engine.getEntitiesFor(Family.all(CollisionComponent.class).exclude(PlayerOwnedComponent.class).get());

            if (newEntities.size() > 0) {
                homing.target = newEntities.random();
                targetCollision = Mappers.collision.get(homing.target);
            } else {
                GameManager.getGame().engine.removeEntity(entity);
                return;
            }
        }

        Vector2 center = new Vector2();
        if (collision != null) {
            collision.rectangle.getCenter(center);
        } else {
            PositionComponent position = Mappers.position.get(entity);
            center.set(position.x, position.y);
        }

        Vector2 targetCenter = new Vector2();
        targetCollision.rectangle.getCenter(targetCenter);

        Vector2 delta = targetCenter.cpy().sub(center);
        angle.desiredAngle = MathUtils.atan2(delta.y, delta.x);
    }

}
