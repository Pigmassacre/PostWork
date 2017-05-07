package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.pigmassacre.postwork.components.collision.StopMovementOnCollisionComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.supersystems.HandleCollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class StopMovementOnCollisionSystem extends HandleCollisionSystem {

    @Override
    protected void handleLevelCollision(int message, Entity entity) {
        StopMovementOnCollisionComponent stopMovement = Mappers.stopMovement.get(entity);
        VelocityComponent velocity = Mappers.velocity.get(entity);

        if (stopMovement != null && velocity != null) {
            switch (message) {
                case MessageTypes.LEVEL_COLLISION_X:
                    velocity.velocity.x = 0f;
                    break;
                case MessageTypes.LEVEL_COLLISION_Y:
                    velocity.velocity.y = 0f;
                    break;
            }
        }
    }

}
