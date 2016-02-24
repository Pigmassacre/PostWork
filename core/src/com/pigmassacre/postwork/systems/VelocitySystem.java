package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class VelocitySystem extends IteratingSystem {

    public VelocitySystem() {
        super(Family.all(VelocityComponent.class, PositionComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        position.x += velocity.velocity.x;
        position.y += velocity.velocity.y;
    }

}
