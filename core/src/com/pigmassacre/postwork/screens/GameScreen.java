package com.pigmassacre.postwork.screens;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.input.PlayerInputAdapter;
import com.pigmassacre.postwork.systems.*;

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
        game.engine.addSystem(new PreviousPositionSystem());
        game.engine.addSystem(new PlayerControllerSystem());
        game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());
        game.engine.addSystem(new VelocitySystem());
        game.engine.addSystem(new CollisionSystem());
        game.engine.addSystem(new CollisionHandlingSystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());
        game.engine.addSystem(new RenderSystem(camera));
        //game.engine.addSystem(new DebugSystem());

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        /* Entities */
        createPlayer();
        createEnemy();
    }

    private void createPlayer() {
        player = game.engine.createEntity();
        player.add(game.engine.createComponent(PositionComponent.class));
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        player.add(visual);
        player.add(game.engine.createComponent(PlayerControllerComponent.class));
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(1f, 1f);
        player.add(collision);
        player.add(game.engine.createComponent(StopMovementOnCollisionComponent.class));
        player.add(game.engine.createComponent(AccelerationComponent.class));
        player.add(game.engine.createComponent(DragComponent.class));
        player.add(game.engine.createComponent(VelocityComponent.class));
        game.engine.addEntity(player);
    }

    private void createEnemy() {
        Entity enemy = game.engine.createEntity();
        PositionComponent position = game.engine.createComponent(PositionComponent.class);
        position.x = 3;
        position.y = 0;
        enemy.add(position);
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 2, 2);
        enemy.add(visual);
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(2f, 2f);
        collision.movable = false;
        enemy.add(collision);
        game.engine.addEntity(enemy);
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
