package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class HomingSystem extends IteratingSystem {

    private static final float ANGLE_CORRECTION = 24f;

    public HomingSystem() {
        super(Family.all(HomingComponent.class, AngleComponent.class, VelocityComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final HomingComponent homing = Mappers.homing.get(entity);
        final AngleComponent angle = Mappers.angle.get(entity);
        CollisionComponent collision = Mappers.collision.get(entity);
        VelocityComponent velocity = Mappers.velocity.get(entity);

        angle.angle = keepWithinBounds(angle.angle);

        CollisionComponent targetCollision = Mappers.collision.get(homing.target);

        Vector2 center = new Vector2();
        collision.rectangle.getCenter(center);

        Vector2 targetCenter = new Vector2();
        targetCollision.rectangle.getCenter(targetCenter);

        Vector2 delta = targetCenter.cpy().sub(center);
        final float angleToTarget = MathUtils.atan2(delta.y, delta.x);

        final float relativeAngleToTarget = angleToTarget - angle.angle;

        angle.angle += keepWithinBounds(relativeAngleToTarget * ANGLE_CORRECTION * deltaTime);

        velocity.velocity.x += MathUtils.cos(angle.angle) * homing.speed * deltaTime;
        velocity.velocity.y += MathUtils.sin(angle.angle) * homing.speed * deltaTime;
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
