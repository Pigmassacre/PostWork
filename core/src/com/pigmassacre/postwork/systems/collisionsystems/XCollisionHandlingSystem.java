package com.pigmassacre.postwork.systems.collisionsystems;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.ai.msg.Telegram;
import com.badlogic.gdx.math.Intersector;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.collisionsystems.CollisionSystem;
import com.pigmassacre.postwork.systems.supersystems.MessageHandlingSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class XCollisionHandlingSystem extends MessageHandlingSystem {

    public XCollisionHandlingSystem() {
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION_X);
        setProcessing(false);
    }

    @Override
    protected void processMessage(Telegram message, float deltaTime) {
        CollisionSystem.CollisionData collisionData = ((CollisionSystem.CollisionData) message.extraInfo);

        /* We assume that these components exist on a colliding entity because logic and reasons */
        PositionComponent position = Mappers.position.get(collisionData.collidingEntity);
        CollisionComponent collision = Mappers.collision.get(collisionData.collidingEntity);
        CollisionComponent otherCollision = Mappers.collision.get(collisionData.otherCollidingEntity);

        if (!collision.movable) {
            return;
        }

        switch (message.message) {
            case MessageTypes.COLLISION_X:
                if (Intersector.overlaps(collision.rectangle, otherCollision.rectangle)) {
                    /* Calculate the actual deltaX */
                    float deltaX = 0f;
                    if (collisionData.collisionSide == CollisionSystem.CollisionSide.LEFT) {
                        deltaX = otherCollision.rectangle.x - (collision.rectangle.x + collision.rectangle.width);
                    } else if (collisionData.collisionSide == CollisionSystem.CollisionSide.RIGHT) {
                        deltaX = (otherCollision.rectangle.x + otherCollision.rectangle.width) - collision.rectangle.x;
                    }

                    Gdx.app.log("CollisionHandling", "Moving X by: " + deltaX);
                    position.x += deltaX;
                    collision.rectangle.x = position.x;
                }
                break;
        }
    }

}
