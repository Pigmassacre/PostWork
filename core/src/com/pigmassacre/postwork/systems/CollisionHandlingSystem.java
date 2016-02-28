package com.pigmassacre.postwork.systems;

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

import java.util.Comparator;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class CollisionHandlingSystem extends MessageHandlingSystem {

    public CollisionHandlingSystem() {
        super(new Comparator<Telegram>() {
            @Override
            public int compare(Telegram o1, Telegram o2) {
                CollisionSystem.CollisionData o1Data = ((CollisionSystem.CollisionData) o1.extraInfo);
                CollisionSystem.CollisionData o2Data = ((CollisionSystem.CollisionData) o2.extraInfo);
                if (o1Data.collisionAxis == CollisionSystem.CollisionAxis.X) {
                    if (o2Data.collisionAxis == CollisionSystem.CollisionAxis.Y) {
                        return -1;
                    }
                } else {
                    if (o2Data.collisionAxis == CollisionSystem.CollisionAxis.X) {
                        return 1;
                    }
                }
                return 0;
            }
        });
        MessageManager.getInstance().addListeners(this,
                MessageTypes.COLLISION_X,
                MessageTypes.COLLISION_Y);
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
            case MessageTypes.COLLISION_Y:
                if (Intersector.overlaps(collision.rectangle, otherCollision.rectangle)) {
                    /* Calculate the actual deltaY */
                    float deltaY = 0f;
                    if (collisionData.collisionSide == CollisionSystem.CollisionSide.BOTTOM) {
                        deltaY = otherCollision.rectangle.y - (collision.rectangle.y + collision.rectangle.height);
                    } else if (collisionData.collisionSide == CollisionSystem.CollisionSide.TOP) {
                        deltaY = (otherCollision.rectangle.y + otherCollision.rectangle.height) - collision.rectangle.y;
                    }

                    Gdx.app.log("CollisionHandling", "Moving Y by: " + deltaY);
                    position.y += deltaY;
                    collision.rectangle.y = position.y;
                }
                break;
        }
    }

}
