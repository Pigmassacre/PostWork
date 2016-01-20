package com.pigmassacre.postwork.screens;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.components.PlayerControlledComponent;
import com.pigmassacre.postwork.components.PositionComponent;
import com.pigmassacre.postwork.components.VisualComponent;
import com.pigmassacre.postwork.input.PlayerInputAdapter;
import com.pigmassacre.postwork.systems.DebugSystem;
import com.pigmassacre.postwork.systems.TurnHandlerSystem;
import com.pigmassacre.postwork.systems.subsystems.MovementSystem;
import com.pigmassacre.postwork.systems.RenderSystem;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class GameScreen extends AbstractScreen {

    Entity player;

    OrthographicCamera camera;

    public GameScreen(PostWork game) {
        super(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
        camera.zoom = 1/32f;

        /* Main systems */
        game.engine.addSystem(new TurnHandlerSystem());
        game.engine.addSystem(new RenderSystem(camera));
        //game.engine.addSystem(new DebugSystem());

        /* Subsystems */
        game.engine.addSystem(new MovementSystem());

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        /* Entities */
        player = new Entity();
        player.add(new PositionComponent());
        VisualComponent visual = new VisualComponent();
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        player.add(visual);
        player.add(new PlayerControlledComponent());
        game.engine.addEntity(player);
    }

    @Override
    public void show() {

    }

    @Override
    public void render(float delta) {
        game.engine.update(delta);
    }

    @Override
    public void resize(int width, int height) {

    }

    @Override
    public void pause() {

    }

    @Override
    public void resume() {

    }

    @Override
    public void hide() {

    }

    @Override
    public void dispose() {

    }

}
