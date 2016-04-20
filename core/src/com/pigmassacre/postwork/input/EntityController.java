package com.pigmassacre.postwork.input;

import com.badlogic.ashley.core.Entity;

/**
 * Created by pigmassacre on 2016-04-20.
 */
public class EntityController {

    private Entity controlledEntity;

    public Entity getControlledEntity() {
        return controlledEntity;
    }

    public void setControlledEntity(Entity controlledEntity) {
        this.controlledEntity = controlledEntity;
    }

}
