package com.pigmassacre.postwork.screens;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.controllers.Controllers;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.input.ControllerInputAdapter;
import com.pigmassacre.postwork.input.PlayerInputAdapter;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.*;
import com.pigmassacre.postwork.systems.collision.*;
import com.pigmassacre.postwork.systems.ShootingSystem;
import com.pigmassacre.postwork.systems.joystick.JoystickCameraSystem;
import com.pigmassacre.postwork.systems.joystick.JoystickMovementSystem;

/**
 * Created by pigmassacre on 2016-01-13.
 */
public class GameScreen extends AbstractScreen {

    OrthographicCamera camera;

    public GameScreen(PostWork game) {
        super(game);

        GameManager.setGame(game);

        camera = new OrthographicCamera(Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

        /* Main systems */
        game.engine.addSystem(new PreviousPositionSystem());
        //game.engine.addSystem(new PlayerControllerSystem());
        //game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new JoystickMovementSystem());
        game.engine.addSystem(new JoystickCameraSystem(camera));
        game.engine.addSystem(new ShootingSystem());

        game.engine.addSystem(new HomingSystem());

        game.engine.addSystem(new AngleSystem());
        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());

        game.engine.addSystem(new VelocitySystem());
        game.engine.addSystem(new CollisionSystem());
        game.engine.addSystem(new MapCollisionSystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());
        game.engine.addSystem(new DamageOnCollisionSystem());

        game.engine.addSystem(new CameraSystem(camera));
        game.engine.addSystem(new RenderSystem(camera));
        game.engine.addSystem(new DebugRenderSystem(camera));

        inputMultiplexer.addProcessor(new PlayerInputAdapter());
        Gdx.input.setInputProcessor(inputMultiplexer);

        /* Entities */
        Entity player = EntityCreator.createPlayer(-1, -1, 2, 2);

        ControllerInputAdapter controllerInputAdapter = new ControllerInputAdapter();
        Controllers.addListener(controllerInputAdapter);
        controllerInputAdapter.setControlledEntity(player);

        EntityCreator.createHomingEnemy(200, 200, 3, 3, player);
        EntityCreator.createHomingEnemy(-200, 200, 3, 3, player);
        EntityCreator.createHomingEnemy(200, -200, 3, 3, player);
        EntityCreator.createHomingEnemy(-200, -200, 3, 3, player);

        EntityCreator.createMap();
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
