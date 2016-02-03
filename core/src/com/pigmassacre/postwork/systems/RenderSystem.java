package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VisualComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class RenderSystem extends IteratingSystem {

    private SpriteBatch batch;
    private OrthographicCamera camera;

    public RenderSystem(OrthographicCamera camera) {
        super(Family.all(PositionComponent.class, VisualComponent.class).get());
        batch = new SpriteBatch();
        this.camera = camera;
    }

    @Override
    public void update(float deltaTime) {
        Gdx.gl.glClearColor(0, 0.2f, 0.2f, 1);
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

        camera.update();

        batch.begin();
        batch.setProjectionMatrix(camera.combined);

        super.update(deltaTime);

        batch.end();
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        PositionComponent position = Mappers.position.get(entity);
        VisualComponent visual = Mappers.visual.get(entity);

        batch.draw(visual.region, position.x, position.y);
    }
}
