package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.pigmassacre.postwork.components.collision.CollisionComponent;
import com.pigmassacre.postwork.components.collision.MapComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class DebugRenderSystem extends IteratingSystem {

    private ShapeRenderer shapeRenderer;
    private OrthographicCamera camera;

    public DebugRenderSystem(OrthographicCamera camera) {
        super(Family.one(MapComponent.class, CollisionComponent.class).get());
        shapeRenderer = new ShapeRenderer();
        this.camera = camera;
    }

    @Override
    public void update(float deltaTime) {
        camera.update();

        shapeRenderer.begin(ShapeRenderer.ShapeType.Line);
        shapeRenderer.setProjectionMatrix(camera.combined);

        super.update(deltaTime);

        shapeRenderer.end();
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        CollisionComponent collision = Mappers.collision.get(entity);
        MapComponent map = Mappers.map.get(entity);

        if (collision != null) {
            shapeRenderer.rect(collision.rectangle.x, collision.rectangle.y, collision.rectangle.width, collision.rectangle.height);
        } else if (map != null) {
            shapeRenderer.rect(map.rectangle.x, map.rectangle.y, map.rectangle.width, map.rectangle.height);
        }
    }
}
