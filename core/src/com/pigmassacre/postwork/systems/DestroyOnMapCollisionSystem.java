package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.supersystems.HandleCollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DestroyOnMapCollisionSystem extends HandleCollisionSystem {

    @Override
    protected void handleLevelCollision(int message, Entity entity) {
        if (Mappers.destroyOnLevelCollision.get(entity) != null) {
            Gdx.app.log(getClass().getSimpleName(), "" + entity);
            GameManager.getGame().engine.removeEntity(entity);
        }
    }

}
