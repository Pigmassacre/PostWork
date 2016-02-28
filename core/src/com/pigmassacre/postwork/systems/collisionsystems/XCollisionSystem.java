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
public class XCollisionSystem extends CollisionSystem {

    public XCollisionSystem() {
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
                    float collisionX = collision.rectangle.x;
                    float collisionWidth = collision.rectangle.width;

                    float otherCollisionX = otherCollision.rectangle.x;
                    float otherCollisionWidth = otherCollision.rectangle.width;

                    float detectAxisX = (collisionX + collisionWidth / 2f) - (otherCollisionX + otherCollisionWidth / 2f);

                    CollisionSide collisionSide = decipherCollisionSide(CollisionAxis.X, detectAxisX, 0);
                    CollisionData collisionData = new CollisionData(entity, otherEntity, CollisionAxis.X, collisionSide);

                    /* Dispatch messages */
                    MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION_X, collisionData);
                    MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION, collisionData);
                }
            }
        }
    }

}
