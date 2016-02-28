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
import com.pigmassacre.postwork.systems.collisionsystems.*;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class GameScreen extends AbstractScreen {

    Entity player;

    OrthographicCamera camera;

    public GameScreen(PostWork game) {
        super(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        /* Main systems */
        game.engine.addSystem(new PreviousPositionSystem());
        game.engine.addSystem(new PlayerControllerSystem());
        game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());

        game.engine.addSystem(new XCollisionSystem());
        game.engine.addSystem(new XCollisionHandlingSystem());
        game.engine.addSystem(new YCollisionSystem());
        game.engine.addSystem(new YCollisionHandlingSystem());

        game.engine.addSystem(new VelocitySystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());

        game.engine.addSystem(new CameraSystem(camera));
        game.engine.addSystem(new RenderSystem(camera));
        //game.engine.addSystem(new DebugSystem());

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        /* Entities */
        createPlayer(1, -1, 1, 3);
        createPlayer(-1, 2, 2, 1);
        for (int x = 0; x < 10; x++) {
            createEnemy(x - 10, 10, 1, 1);
            createEnemy(x - 10, -10, 1, 1);
        }

        for (int y = 0; y < 10; y++) {
            createEnemy(10, y - 10, 1, 1);
            createEnemy(-10, y - 10, 1, 1);
        }

        createEnemy(1, 0, 2, 5);
    }

    private void createPlayer(float x, float y, float width, float height) {
        player = game.engine.createEntity();
        PositionComponent position = game.engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        player.add(position);
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        visual.width = width;
        visual.height = height;
        player.add(visual);
        player.add(game.engine.createComponent(PlayerControllerComponent.class));
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        player.add(collision);
        player.add(game.engine.createComponent(StopMovementOnCollisionComponent.class));
        player.add(game.engine.createComponent(AccelerationComponent.class));
        player.add(game.engine.createComponent(DragComponent.class));
        player.add(game.engine.createComponent(VelocityComponent.class));
        player.add(game.engine.createComponent(CameraFocusComponent.class));
        game.engine.addEntity(player);
    }

    private void createEnemy(float x, float y, float width, float height) {
        Entity enemy = game.engine.createEntity();
        PositionComponent position = game.engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        enemy.add(position);
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 2, 2);
        visual.width = width;
        visual.height = height;
        enemy.add(visual);
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
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
