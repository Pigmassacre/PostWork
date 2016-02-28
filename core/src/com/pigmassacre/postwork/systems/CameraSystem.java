package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Engine;
import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.EntitySystem;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.ashley.utils.ImmutableArray;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.utils.Array;
import com.pigmassacre.postwork.components.CameraFocusComponent;
import com.pigmassacre.postwork.components.CollisionComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class CameraSystem extends EntitySystem {

    private static final float minimumXSpace = 16f;
    private static final float minimumYSpace = 16f;
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

        //if (minX < 0) minX = 0;
        //if (minY < 0) minY = 0;
        //if (maxX > 64f) maxX = 64f;
        //if (maxY > 64f) maxY = 64f;

        float width = maxX - minX;
        float height = maxY - minY;

        camera.position.set(minX + (width / 2f), minY + (height / 2f), 0);

        float xZoom = width / camera.viewportWidth;
        float yZoom = height / camera.viewportHeight;

        camera.zoom = MathUtils.clamp(Math.max(xZoom, yZoom), 1f/32f, Float.POSITIVE_INFINITY);//Math.min(Level.getMapWidth() / camera.viewportWidth, Level.getMapHeight() / camera.viewportHeight));

        float effectiveViewportWidth = camera.viewportWidth * camera.zoom;
        float effectiveViewportHeight = camera.viewportHeight * camera.zoom;

//        camera.position.x = MathUtils.clamp(camera.position.x, effectiveViewportWidth / 2f, maxX);//Level.getMapWidth() - effectiveViewportWidth / 2f);
//        camera.position.y = MathUtils.clamp(camera.position.y, effectiveViewportHeight / 2f, maxY);//Level.getMapHeight() - effectiveViewportHeight / 2f);

        camera.update();
    }
}
