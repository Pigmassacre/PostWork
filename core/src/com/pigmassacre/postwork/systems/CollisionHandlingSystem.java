package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.math.Intersector;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.supersystems.MessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class CollisionHandlingSystem extends MessageHandlingSystem {

    public CollisionHandlingSystem() {
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION_X,
                MessageTypes.COLLISION_Y);
    }

    @Override
    protected void processMessage(Telegram message, float deltaTime) {
        CollisionSystem.CollisionData collisionData = ((CollisionSystem.CollisionData) message.extraInfo);

        PositionComponent position = Mappers.position.get(collisionData.collidingEntity);
        CollisionComponent collision = Mappers.collision.get(collisionData.collidingEntity);
        CollisionComponent otherCollision = Mappers.collision.get(collisionData.otherCollidingEntity);

        if (!collision.movable) {
            return;
        }

        switch (message.message) {
            case MessageTypes.COLLISION_X:
                Gdx.app.log("CollisionHandling", "Handling X: " + collisionData.deltaX);
                if (Intersector.overlaps(collision.rectangle, otherCollision.rectangle)) {
                    position.x += collisionData.deltaX;
                    collision.rectangle.x = position.x;
                }
                break;
            case MessageTypes.COLLISION_Y:
                Gdx.app.log("CollisionHandling", "Handling Y: " + collisionData.deltaY);
                if (Intersector.overlaps(collision.rectangle, otherCollision.rectangle)) {
                    position.y += collisionData.deltaY;
                    collision.rectangle.y = position.y;
                }
                break;
        }
    }

}
