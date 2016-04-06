package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.DragComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DragSystem extends IteratingSystem {

    private static final float DRAG_FACTOR = 0.985f;

    public DragSystem() {
        super(Family.all(VelocityComponent.class, DragComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        velocity.velocity.x *= DRAG_FACTOR;
        velocity.velocity.y *= DRAG_FACTOR;
    }

}
