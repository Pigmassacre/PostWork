package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VisualComponent;
import com.pigmassacre.postwork.utils.HSL;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class RenderSystem extends IteratingSystem {

    private SpriteBatch batch;
    private OrthographicCamera camera;

    private HSL bgColor = new HSL();

    public RenderSystem(OrthographicCamera camera) {
        super(Family.all(PositionComponent.class, VisualComponent.class).get());
        batch = new SpriteBatch();
        this.camera = camera;

        bgColor.l = 0.3f;
        bgColor.s = 0.2f;
    }

    @Override
    public void update(float deltaTime) {
        bgColor.h += 0.1f * deltaTime;
        if (bgColor.h > 1f) {
            bgColor.h -= 1f;
        }

        Color color = bgColor.toRGB();
        Gdx.gl.glClearColor(color.r, color.g, color.b, color.a);
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
        AngleComponent angle = Mappers.angle.get(entity);

        float drawAngle = 0f;
        if (angle != null) {
            drawAngle = angle.angle - MathUtils.PI / 2f;
        }

        batch.draw(visual.region,
                position.x,
                position.y,
                visual.width / 2f,
                visual.height / 2f,
                visual.width,
                visual.height,
                1f,
                1f,
                drawAngle * 180 / MathUtils.PI);
    }
}
