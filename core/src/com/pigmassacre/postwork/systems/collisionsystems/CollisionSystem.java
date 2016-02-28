package com.pigmassacre.postwork.systems.collisionsystems;

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
                    float collisionFactorX = 1f;
                    float collisionFactorY = 1f;

                    float collisionX = collision.rectangle.x;
                    float collisionY = collision.rectangle.y;
                    float collisionWidth = collision.rectangle.width;
                    float collisionHeight = collision.rectangle.height;

                    float otherCollisionX = otherCollision.rectangle.x;
                    float otherCollisionY = otherCollision.rectangle.y;
                    float otherCollisionWidth = otherCollision.rectangle.width;
                    float otherCollisionHeight = otherCollision.rectangle.height;

                    float v = collisionWidth - otherCollisionWidth;
                    float h = collisionHeight - otherCollisionHeight;

                    if (v + h > 0) {
                        if (collision.rectangle.width < collision.rectangle.height) {
                            collisionFactorX = collisionHeight / collisionWidth;
                        } else if (collision.rectangle.width > collision.rectangle.height) {
                            collisionFactorY = collisionWidth / collisionHeight;
                        }
                    } else {
                        if (otherCollision.rectangle.width < otherCollision.rectangle.height) {
                            collisionFactorX = otherCollisionHeight / otherCollisionWidth;
                        } else if (otherCollision.rectangle.width > otherCollision.rectangle.height) {
                            collisionFactorY = otherCollisionWidth / otherCollisionHeight;
                        }
                    }

                    collisionX *= collisionFactorX;
                    collisionY *= collisionFactorY;
                    collisionWidth *= collisionFactorX;
                    collisionHeight *= collisionFactorY;

                    otherCollisionX *= collisionFactorX;
                    otherCollisionY *= collisionFactorY;
                    otherCollisionWidth *= collisionFactorX;
                    otherCollisionHeight *= collisionFactorY;

                    float detectAxisX = (collisionX + collisionWidth / 2f) - (otherCollisionX + otherCollisionWidth / 2f);
                    float detectAxisY = (collisionY + collisionHeight / 2f) - (otherCollisionY + otherCollisionHeight / 2f);

                    /* Try to decipher from which direction entity collided with otherEntity */
                    CollisionAxis collisionAxis = decipherCollisionAxis(detectAxisX, detectAxisY);
                    if (collisionAxis == CollisionAxis.UNDECIDED) {
                        /* If still undecided, use the previous positions of the entities to decide */
                        collisionAxis = decipherCollisionAxis(collision.rectangle.x - position.previousX, collision.rectangle.y - position.previousY);

                        /* If we still haven't been able to decide the axis, we simply leave it as undecided and let the receiver figure it out */
                    }

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

    protected CollisionAxis decipherCollisionAxis(float deltaX, float deltaY) {
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