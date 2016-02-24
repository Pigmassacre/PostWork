package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.pigmassacre.postwork.components.StopMovementOnCollisionComponent;
import com.pigmassacre.postwork.components.VelocityComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.supersystems.MessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class StopMovementOnCollisionSystem extends MessageHandlingSystem {

    public StopMovementOnCollisionSystem() {
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION_X,
                MessageTypes.COLLISION_Y);
    }

    @Override
    protected void processMessage(Telegram message, float deltaTime) {
        CollisionSystem.CollisionData collisionData = ((CollisionSystem.CollisionData) message.extraInfo);

        stopMovement(message, collisionData.collidingEntity);
        stopMovement(message, collisionData.otherCollidingEntity);
    }

    private void stopMovement(Telegram message, Entity entity) {
        StopMovementOnCollisionComponent stopMovement = Mappers.stopMovement.get(entity);
        VelocityComponent velocity = Mappers.velocity.get(entity);

        if (stopMovement != null && velocity != null) {
            switch (message.message) {
                case MessageTypes.COLLISION_X:
                    velocity.velocity.x = 0f;
                    break;
                case MessageTypes.COLLISION_Y:
                    velocity.velocity.y = 0f;
                    break;
            }
        }
    }

}