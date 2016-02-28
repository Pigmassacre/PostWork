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
    protected void processEntity(Entity entity, float deltaTime) {
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
