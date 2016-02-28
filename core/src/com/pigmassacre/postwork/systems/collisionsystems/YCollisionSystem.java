package com.pigmassacre.postwork.systems.collisionsystems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.math.Intersector;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.systems.collisionsystems.CollisionSystem;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class YCollisionSystem extends CollisionSystem {

    public YCollisionSystem() {
        setProcessing(false);
    }

    @Override
    public void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        final CollisionComponent collision = Mappers.collision.get(entity);

        collision.rectangle.x = position.x;
        collision.rectangle.y = position.y;

        ImmutableArray<Entity> entities = getEntities();
        for (Entity otherEntity : entities) {
            if (!entity.equals(otherEntity)) {
                final PositionComponent otherPosition = Mappers.position.get(otherEntity);
                final CollisionComponent otherCollision = Mappers.collision.get(otherEntity);

                otherCollision.rectangle.x = otherPosition.x;
                otherCollision.rectangle.y = otherPosition.y;

                if (Intersector.overlaps(collision.rectangle, otherCollision.rectangle)) {
                    /* Gather and calculate collision data */
                    float collisionY = collision.rectangle.y;
                    float collisionHeight = collision.rectangle.height;

                    float otherCollisionY = otherCollision.rectangle.y;
                    float otherCollisionHeight = otherCollision.rectangle.height;

                    float detectAxisY = (collisionY + collisionHeight / 2f) - (otherCollisionY + otherCollisionHeight / 2f);

                    CollisionSide collisionSide = decipherCollisionSide(CollisionAxis.Y, 0, detectAxisY);
                    CollisionData collisionData = new CollisionData(entity, otherEntity, CollisionAxis.Y, collisionSide);

                    /* Dispatch messages */
                    MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION_Y, collisionData);
                    MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION, collisionData);
                }
            }
        }
    }

}
