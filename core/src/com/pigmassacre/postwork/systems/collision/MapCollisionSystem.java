package com.pigmassacre.postwork.systems.collision;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.ai.msg.MessageManager;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.collision.MapComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.input.MessageTypes;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class MapCollisionSystem extends IteratingSystem {

    private Family mapFamily;

    public MapCollisionSystem() {
        super(Family.all(PositionComponent.class, CollisionComponent.class).get());
        mapFamily = Family.all(MapComponent.class).get();
    }

    @Override
    public void processEntity(Entity entity, float deltaTime) {
        final PositionComponent position = Mappers.position.get(entity);
        final CollisionComponent collision = Mappers.collision.get(entity);

        collision.rectangle.x = position.x;
        collision.rectangle.y = position.y;

        ImmutableArray<Entity> mapEntities = getEngine().getEntitiesFor(mapFamily);

        for (Entity mapEntity : mapEntities) {
            final MapComponent map = Mappers.map.get(mapEntity);

            if (collision.rectangle.x < map.rectangle.x) {
                collision.rectangle.x = map.rectangle.x;
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_X, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_LEFT, entity);
            } else if (collision.rectangle.x + collision.rectangle.width > map.rectangle.x + map.rectangle.width) {
                collision.rectangle.x = map.rectangle.x + map.rectangle.width - collision.rectangle.width;
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_X, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_RIGHT, entity);
            }
            position.x = collision.rectangle.x;

            if (collision.rectangle.y < map.rectangle.y) {
                collision.rectangle.y = map.rectangle.y;
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_Y, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_DOWN, entity);
            } else if (collision.rectangle.y + collision.rectangle.height > map.rectangle.y + map.rectangle.height) {
                collision.rectangle.y = map.rectangle.y + map.rectangle.height - collision.rectangle.height;
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_Y, entity);
                MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION_UP, entity);
            }
            position.y = collision.rectangle.y;

            MessageManager.getInstance().dispatchMessage(MessageTypes.MAP_COLLISION, entity);
        }
    }

}
