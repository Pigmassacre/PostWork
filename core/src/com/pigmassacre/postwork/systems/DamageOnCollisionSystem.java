package com.pigmassacre.postwork.systems;

import com.pigmassacre.postwork.components.HealthComponent;
import com.pigmassacre.postwork.components.PlayerOwnedComponent;
import com.pigmassacre.postwork.components.collision.DamageOnCollisionComponent;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.collision.CollisionSystem;
import com.pigmassacre.postwork.systems.supersystems.HandleCollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DamageOnCollisionSystem extends HandleCollisionSystem {

    @Override
    protected void handleCollision(int message, CollisionSystem.CollisionData data) {
        DamageOnCollisionComponent damage = Mappers.damageCollision.get(data.collidingEntity);

        if (damage != null) {
            PlayerOwnedComponent playerOwned = Mappers.playerOwned.get(data.collidingEntity);
            PlayerOwnedComponent playerOwnedOther = Mappers.playerOwned.get(data.otherCollidingEntity);
            if (playerOwned != null && playerOwnedOther == null) {
                HealthComponent otherHealth = Mappers.health.get(data.otherCollidingEntity);
                if (otherHealth != null) {
                    otherHealth.health -= damage.damage;
                }
            }
        }
    }

}
