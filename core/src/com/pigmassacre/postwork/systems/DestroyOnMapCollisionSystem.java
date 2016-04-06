package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.pigmassacre.postwork.components.PlayerOwnedComponent;
import com.pigmassacre.postwork.components.collision.DamageOnCollisionComponent;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.collision.CollisionSystem;
import com.pigmassacre.postwork.systems.supersystems.HandleCollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DestroyOnMapCollisionSystem extends HandleCollisionSystem {

    @Override
    protected void handleMapCollision(int message, Entity entity) {
        if (Mappers.destroyMapCollision.get(entity) != null) {
            Gdx.app.log("Ech", "" + entity);
            GameManager.getGame().engine.removeEntity(entity);
        }
    }

}
