package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.gdx.Gdx;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DebugSystem extends EntitySystem {

    @Override
    public void update(float deltaTime) {
        for (Entity entity : getEngine().getEntities()) {
            processEntity(entity, deltaTime);
        }
    }

    protected void processEntity(Entity entity, float deltaTime) {
        PositionComponent position = Mappers.position.get(entity);
        Gdx.app.log("Debug", entity.toString() + ": Position: " + position.x + ", " + position.y);
    }

}
