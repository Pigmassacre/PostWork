package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class PreviousPositionSystem extends IteratingSystem {

    public PreviousPositionSystem() {
        super(Family.all(PositionComponent.class, PlayerControllerComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        position.previousX = position.x;
        position.previousY = position.y;
    }

}
