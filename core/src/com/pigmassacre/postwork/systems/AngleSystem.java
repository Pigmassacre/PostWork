package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Vector2;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.components.HomingComponent;
import com.pigmassacre.postwork.components.PlayerOwnedComponent;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class AngleSystem extends IteratingSystem {

    private static final float ANGLE_SPEED = 5f;

    public AngleSystem() {
        super(Family.all(AngleComponent.class, AccelerationComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final AngleComponent angle = Mappers.angle.get(entity);
        AccelerationComponent acceleration = Mappers.acceleration.get(entity);

        angle.angle = keepWithinBounds(angle.angle);
        acceleration.acceleration.x = MathUtils.cos(angle.angle) * ANGLE_SPEED * deltaTime;
        acceleration.acceleration.y = MathUtils.sin(angle.angle) * ANGLE_SPEED * deltaTime;
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
