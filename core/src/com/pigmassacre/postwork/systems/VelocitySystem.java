package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.systems.collisionsystems.XCollisionHandlingSystem;
import com.pigmassacre.postwork.systems.collisionsystems.XCollisionSystem;
import com.pigmassacre.postwork.systems.collisionsystems.YCollisionHandlingSystem;
import com.pigmassacre.postwork.systems.collisionsystems.YCollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class VelocitySystem extends IteratingSystem {

    XCollisionSystem xCollisionSystem;
    YCollisionSystem yCollisionSystem;
    XCollisionHandlingSystem xCollisionHandlingSystem;
    YCollisionHandlingSystem yCollisionHandlingSystem;

    @Override
    public void addedToEngine(Engine engine) {
        super.addedToEngine(engine);
        xCollisionSystem = engine.getSystem(XCollisionSystem.class);
        yCollisionSystem = engine.getSystem(YCollisionSystem.class);
        xCollisionHandlingSystem = engine.getSystem(XCollisionHandlingSystem.class);
        yCollisionHandlingSystem = engine.getSystem(YCollisionHandlingSystem.class);
    }

    public VelocitySystem() {
        super(Family.all(VelocityComponent.class, PositionComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        final VelocityComponent velocity = Mappers.velocity.get(entity);
        position.x += velocity.velocity.x;
        xCollisionSystem.processEntity(entity, deltaTime);
        xCollisionHandlingSystem.update(deltaTime);
        position.y += velocity.velocity.y;
        yCollisionSystem.processEntity(entity, deltaTime);
        yCollisionHandlingSystem.update(deltaTime);
    }

}
