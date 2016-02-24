package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.math.Intersector;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class CollisionSystem extends IteratingSystem {

    public CollisionSystem() {
        super(Family.all(PositionComponent.class, CollisionComponent.class).get());
    }

    @Override
    public void update(float deltaTime) {
        super.update(deltaTime);
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
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
                    float deltaX = (collision.rectangle.x + collision.rectangle.width / 2f) - (otherCollision.rectangle.x + otherCollision.rectangle.width / 2f);
                    float deltaY = (collision.rectangle.y + collision.rectangle.height / 2f) - (otherCollision.rectangle.y + otherCollision.rectangle.height / 2f);

                    /* Try to decipher from which direction entity collided with otherEntity */
                    CollisionAxis collisionAxis = decipherCollisionAxis(deltaX, deltaY);
                    if (collisionAxis == CollisionAxis.UNDECIDED) {
                        /* If still undecided, use the previous positions of the entities to decide */
                        collisionAxis = decipherCollisionAxis(collision.rectangle.x - position.previousX, collision.rectangle.y - position.previousY);

                        /* If we still haven't been able to decide the axis, we simply leave it as undecided and let the receiver figure it out */
                    }

                    /* Compensate for errors caused by collisionAxis detection logic */
                    deltaX *= 2;
                    deltaY *= 2;

                    CollisionData collisionData = new CollisionData(entity, otherEntity, collisionAxis, deltaX, deltaY);

                    /* Dispatch messages */
                    if (collisionAxis == CollisionAxis.X) {
                        MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION_X, collisionData);
                    } else if (collisionAxis == CollisionAxis.Y) {
                        MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION_Y, collisionData);
                    }

                    MessageManager.getInstance().dispatchMessage(MessageTypes.COLLISION, collisionData);
                }
            }
        }
    }

    private CollisionAxis decipherCollisionAxis(float deltaX, float deltaY) {
        if (Math.abs(deltaX) > Math.abs(deltaY)) {
            return CollisionAxis.X;
        } else if (Math.abs(deltaY) > Math.abs(deltaX)) {
            return CollisionAxis.Y;
        }
        return CollisionAxis.UNDECIDED;
    }

    public class CollisionData {
        public final Entity collidingEntity;
        public final Entity otherCollidingEntity;
        public final CollisionAxis primaryCollisionAxis;
        public final float deltaX;
        public final float deltaY;

        public CollisionData(Entity collidingEntity, Entity otherCollidingEntity, CollisionAxis primaryCollisionAxis, float deltaX, float deltaY) {
            this.collidingEntity = collidingEntity;
            this.otherCollidingEntity = otherCollidingEntity;
            this.primaryCollisionAxis = primaryCollisionAxis;
            this.deltaX = deltaX;
            this.deltaY = deltaY;
        }
    }

    public enum CollisionAxis {
        X, Y, UNDECIDED
    }

}
