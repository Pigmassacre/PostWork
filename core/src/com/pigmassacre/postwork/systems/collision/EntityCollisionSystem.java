package com.pigmassacre.postwork.systems.collision;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.badlogic.gdx.math.Intersector;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.collision.EntityCollisionComponent;
import com.pigmassacre.postwork.components.collision.LevelComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class EntityCollisionSystem extends IteratingSystem {

    public EntityCollisionSystem() {
        super(Family.all(PositionComponent.class, CollisionComponent.class, EntityCollisionComponent.class).get());
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

                    float collisionY = collision.rectangle.y;
                    float collisionHeight = collision.rectangle.height;

                    float otherCollisionY = otherCollision.rectangle.y;
                    float otherCollisionHeight = otherCollision.rectangle.height;

                    float detectAxisY = (collisionY + collisionHeight / 2f) - (otherCollisionY + otherCollisionHeight / 2f);

                    CollisionAxis collisionAxis = decipherCollisionAxis(detectAxisX, detectAxisY);
                    CollisionSide collisionSide = decipherCollisionSide(collisionAxis, detectAxisX, detectAxisY);
                    CollisionData collisionData = new CollisionData(entity, otherEntity, collisionAxis, collisionSide);

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

    protected CollisionSide decipherCollisionSide(CollisionAxis detectedAxis, float detectAxisX, double detectAxisY) {
        if (detectedAxis == CollisionAxis.X) {
            if (detectAxisX < 0) {
                return CollisionSide.LEFT;
            } else if (detectAxisX > 0) {
                return CollisionSide.RIGHT;
            }
        } else if (detectedAxis == CollisionAxis.Y) {
            if (detectAxisY < 0) {
                return CollisionSide.BOTTOM;
            } else if (detectAxisY > 0) {
                return CollisionSide.TOP;
            }
        }
        return CollisionSide.UNDECIDED;
    }

    public class CollisionData {
        public final Entity collidingEntity;
        public final Entity otherCollidingEntity;
        public final CollisionAxis collisionAxis;
        public final CollisionSide collisionSide;

        public CollisionData(Entity collidingEntity, Entity otherCollidingEntity, CollisionAxis collisionAxis, CollisionSide collisionSide) {
            this.collidingEntity = collidingEntity;
            this.otherCollidingEntity = otherCollidingEntity;
            this.collisionAxis = collisionAxis;
            this.collisionSide = collisionSide;
        }
    }

    public enum CollisionAxis {
        X, Y, UNDECIDED
    }

    public enum CollisionSide {
        LEFT, RIGHT, TOP, BOTTOM, UNDECIDED
    }

}
