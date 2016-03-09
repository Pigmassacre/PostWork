package com.pigmassacre.postwork.screens;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.controllers.Controllers;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.TextureRegion;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.input.ControllerInputAdapter;
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
        //game.engine.addSystem(new PlayerControllerSystem());
        //game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new JoystickMovementSystem());
        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());

        game.engine.addSystem(new VelocitySystem());
        game.engine.addSystem(new CollisionSystem());
        game.engine.addSystem(new MapCollisionSystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());

        game.engine.addSystem(new CameraSystem(camera));
        game.engine.addSystem(new RenderSystem(camera));
        //game.engine.addSystem(new DebugSystem());

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        ControllerInputAdapter controllerInputAdapter = new ControllerInputAdapter();
        Controllers.addListener(controllerInputAdapter);

        /* Entities */
        Entity player = createPlayer(-1, -1, 2, 2);
        createPlayer(5, 5, 4, 2);

        controllerInputAdapter.setControlledEntity(player);

        Entity map = game.engine.createEntity();
        MapComponent mapComponent = game.engine.createComponent(MapComponent.class);
        mapComponent.init(24, 24);
        map.add(mapComponent);
        game.engine.addEntity(map);
    }

    private Entity createPlayer(float x, float y, float width, float height) {
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
        player.add(game.engine.createComponent(JoystickControllerComponent.class));
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        player.add(collision);
        player.add(game.engine.createComponent(StopMovementOnCollisionComponent.class));
        player.add(game.engine.createComponent(AccelerationComponent.class));
        player.add(game.engine.createComponent(DragComponent.class));
        player.add(game.engine.createComponent(VelocityComponent.class));
        player.add(game.engine.createComponent(CameraFocusComponent.class));
        game.engine.addEntity(player);

        return player;
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
