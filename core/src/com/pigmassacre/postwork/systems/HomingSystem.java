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
        super(Family.all(HomingComponent.class, AngleComponent.class, AccelerationComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final HomingComponent homing = Mappers.homing.get(entity);
        final AngleComponent angle = Mappers.angle.get(entity);
        CollisionComponent collision = Mappers.collision.get(entity);
        AccelerationComponent acceleration = Mappers.acceleration.get(entity);

        angle.angle = keepWithinBounds(angle.angle);

        CollisionComponent targetCollision = Mappers.collision.get(homing.target);

        if (targetCollision == null) {
            Gdx.app.log("", "Target no longer exists");
            ImmutableArray<Entity> newEntities = GameManager.getGame().engine.getEntitiesFor(Family.all(CollisionComponent.class).exclude(PlayerOwnedComponent.class).get());

            if (newEntities.size() > 0) {
                Gdx.app.log("", "Updated target");
                homing.target = newEntities.random();
                targetCollision = Mappers.collision.get(homing.target);
            } else {
                Gdx.app.log("", "Couldnt get new target, killing self");
                GameManager.getGame().engine.removeEntity(entity);
                return;
            }
        }

        Vector2 center = new Vector2();
        collision.rectangle.getCenter(center);

        Vector2 targetCenter = new Vector2();
        targetCollision.rectangle.getCenter(targetCenter);

        Vector2 delta = targetCenter.cpy().sub(center);
        angle.angle = keepWithinBounds(MathUtils.atan2(delta.y, delta.x));

        acceleration.acceleration.x = MathUtils.cos(angle.angle) * homing.speed * deltaTime;
        acceleration.acceleration.y = MathUtils.sin(angle.angle) * homing.speed * deltaTime;
    }

    private float keepWithinBounds(float angle) {
        if (angle > MathUtils.PI) {
            return angle - MathUtils.PI;
        } else if (angle < -MathUtils.PI) {
            return angle + MathUtils.PI;
        }
        return angle;
    }

}
