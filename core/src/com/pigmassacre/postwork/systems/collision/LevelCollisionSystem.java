package com.pigmassacre.postwork.systems.collision;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.collision.LevelCollisionComponent;
import com.pigmassacre.postwork.components.collision.LevelComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class LevelCollisionSystem extends IteratingSystem {

    private Family levelFamily;

    public LevelCollisionSystem() {
        super(Family.all(PositionComponent.class, CollisionComponent.class, LevelCollisionComponent.class).get());
        levelFamily = Family.all(LevelComponent.class).get();
    }

    @Override
    public void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        final CollisionComponent collision = Mappers.collision.get(entity);

        collision.rectangle.x = position.x;
        collision.rectangle.y = position.y;

        ImmutableArray<Entity> levelEntities = getEngine().getEntitiesFor(levelFamily);

        boolean collided = false;
        for (Entity levelEntity : levelEntities) {
            final LevelComponent level = Mappers.level.get(levelEntity);

            if (collision.rectangle.x < level.rectangle.x) {
                collided = true;
                collision.rectangle.x = level.rectangle.x;
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_X, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_LEFT, entity);
            } else if (collision.rectangle.x + collision.rectangle.width > level.rectangle.x + level.rectangle.width) {
                collided = true;
                collision.rectangle.x = level.rectangle.x + level.rectangle.width - collision.rectangle.width;
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_X, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_RIGHT, entity);
            }
            position.x = collision.rectangle.x;

            if (collision.rectangle.y < level.rectangle.y) {
                collided = true;
                collision.rectangle.y = level.rectangle.y;
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_Y, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_DOWN, entity);
            } else if (collision.rectangle.y + collision.rectangle.height > level.rectangle.y + level.rectangle.height) {
                collided = true;
                collision.rectangle.y = level.rectangle.y + level.rectangle.height - collision.rectangle.height;
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_Y, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION_UP, entity);
            }
            position.y = collision.rectangle.y;

            if (collided) {
                MessageManager.getInstance().dispatchMessage(MessageTypes.LEVEL_COLLISION, entity);
            }
        }
    }

}
