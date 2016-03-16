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
import com.pigmassacre.postwork.systems.collision.*;
import com.pigmassacre.postwork.systems.joystick.JoystickCameraSystem;
import com.pigmassacre.postwork.systems.joystick.JoystickMovementSystem;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class GameScreen extends AbstractScreen {

    OrthographicCamera camera;

    public GameScreen(PostWork game) {
        super(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        /* Main systems */
        game.engine.addSystem(new PreviousPositionSystem());
        //game.engine.addSystem(new PlayerControllerSystem());
        //game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new JoystickMovementSystem());
        game.engine.addSystem(new JoystickCameraSystem(camera));

        game.engine.addSystem(new HomingSystem());

        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());

        game.engine.addSystem(new VelocitySystem());
        game.engine.addSystem(new CollisionSystem());
        game.engine.addSystem(new MapCollisionSystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());

        game.engine.addSystem(new CameraSystem(camera));
        game.engine.addSystem(new RenderSystem(camera));
        game.engine.addSystem(new DebugRenderSystem(camera));

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        /* Entities */
        Entity player = createPlayer(-1, -1, 2, 2);

        ControllerInputAdapter controllerInputAdapter = new ControllerInputAdapter();
        Controllers.addListener(controllerInputAdapter);
        controllerInputAdapter.setControlledEntity(player);

        createBullet(200, 200, 3, 3, player);
        createBullet(-200, 200, 3, 3, player);
        createBullet(200, -200, 3, 3, player);
        createBullet(-200, -200, 3, 3, player);

        createMap();
    }

    private Entity createPlayer(float x, float y, float width, float height) {
        Entity entity = game.engine.createEntity();
        PositionComponent position = game.engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        entity.add(position);
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        visual.width = width;
        visual.height = height;
        entity.add(visual);
        entity.add(game.engine.createComponent(PlayerControllerComponent.class));
        entity.add(game.engine.createComponent(JoystickControllerComponent.class));
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        entity.add(collision);
        entity.add(game.engine.createComponent(StopMovementOnCollisionComponent.class));
        entity.add(game.engine.createComponent(AccelerationComponent.class));
        entity.add(game.engine.createComponent(DragComponent.class));
        entity.add(game.engine.createComponent(VelocityComponent.class));
        entity.add(game.engine.createComponent(CameraFocusComponent.class));

        game.engine.addEntity(entity);

        return entity;
    }

    private Entity createBullet(float x, float y, float width, float height, Entity homingTarget) {
        Entity entity = game.engine.createEntity();
        PositionComponent position = game.engine.createComponent(PositionComponent.class);
        position.x = x;
        position.y = y;
        entity.add(position);
        VisualComponent visual = game.engine.createComponent(VisualComponent.class);
        visual.region = new TextureRegion(new Texture(Gdx.files.internal("badlogic.jpg")), 1, 1);
        visual.width = width;
        visual.height = height;
        entity.add(visual);
        CollisionComponent collision = game.engine.createComponent(CollisionComponent.class);
        collision.init(width, height);
        entity.add(collision);
        entity.add(game.engine.createComponent(StopMovementOnCollisionComponent.class));
        entity.add(game.engine.createComponent(AccelerationComponent.class));
        entity.add(game.engine.createComponent(DragComponent.class));
        entity.add(game.engine.createComponent(VelocityComponent.class));

        HomingComponent homing = game.engine.createComponent(HomingComponent.class);
        homing.target = homingTarget;
        entity.add(homing);
        entity.add(game.engine.createComponent(AngleComponent.class));

        game.engine.addEntity(entity);

        return entity;
    }

    private Entity createMap() {
        Entity map = game.engine.createEntity();
        MapComponent mapComponent = game.engine.createComponent(MapComponent.class);
        mapComponent.init(256, 256);
        mapComponent.rectangle.x = -128;
        mapComponent.rectangle.y = -128;
        map.add(mapComponent);
        game.engine.addEntity(map);

        return map;
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
