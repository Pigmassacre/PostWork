package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class AccelerationSystem extends IteratingSystem {

    public AccelerationSystem() {
        super(Family.all(VelocityComponent.class, AccelerationComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        final AccelerationComponent acceleration = Mappers.acceleration.get(entity);
        velocity.velocity.x += acceleration.acceleration.x;
        velocity.velocity.y += acceleration.acceleration.y;
    }

}
