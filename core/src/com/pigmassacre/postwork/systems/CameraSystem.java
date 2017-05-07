package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.CameraFocusComponent;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class CameraSystem extends EntitySystem {

    private static final float minimumXSpace = 64f;
    private static final float minimumYSpace = 64f;
    private ImmutableArray<Entity> entities;
    private OrthographicCamera camera;
    private Family family;

    public CameraSystem(OrthographicCamera camera) {
        family = Family.all(PositionComponent.class, CollisionComponent.class, CameraFocusComponent.class).get();
        this.camera = camera;
    }

    @Override
    public void addedToEngine (Engine engine) {
        entities = engine.getEntitiesFor(family);
    }

    @Override
    public void removedFromEngine (Engine engine) {
        entities = null;
    }

    @Override
    public void update(float deltaTime) {
        PositionComponent position;
        CollisionComponent collision;

        float minX = Float.POSITIVE_INFINITY;
        float minY = Float.POSITIVE_INFINITY;
        float maxX = Float.NEGATIVE_INFINITY;
        float maxY = Float.NEGATIVE_INFINITY;

        for (int i = 0; i < entities.size(); i++) {
            Entity entity = entities.get(i);

            position = Mappers.position.get(entity);
            collision = Mappers.collision.get(entity);

            if (position.x < minX) minX = position.x;
            if (position.y < minY) minY = position.y;
            if (position.x + collision.rectangle.width > maxX) maxX = position.x + collision.rectangle.width;
            if (position.y + collision.rectangle.height > maxY) maxY = position.y + collision.rectangle.height;
        }

        minX -= minimumXSpace;
        minY -= minimumYSpace;
        maxX += minimumXSpace;
        maxY += minimumYSpace;

        float width = maxX - minX;
        float height = maxY - minY;

        camera.position.set(minX + (width / 2f), minY + (height / 2f), 0);

        float xZoom = MathUtils.clamp(width / camera.viewportWidth, 1f, 16f);
        float yZoom = MathUtils.clamp(height / camera.viewportHeight, 1f, 16f);

        final float newZoom = MathUtils.clamp(Math.max(xZoom, yZoom), 1f / 32f, 32f);
        //camera.zoom = MathUtils.lerp(camera.zoom, newZoom, deltaTime * 3f);
        camera.zoom = 1f;

        camera.update();
    }
}
