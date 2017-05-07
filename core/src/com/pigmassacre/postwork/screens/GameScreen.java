package com.pigmassacre.postwork.screens;

import com.badlogic.ashley.core.Entity;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.controllers.Controllers;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.utils.viewport.ExtendViewport;
import com.pigmassacre.postwork.PostWork;
import com.pigmassacre.postwork.input.ControllerInputAdapter;
import com.pigmassacre.postwork.input.PlayerInputAdapter;
import com.pigmassacre.postwork.managers.EntityCreator;
import com.pigmassacre.postwork.managers.GameManager;
import com.pigmassacre.postwork.systems.*;
import com.pigmassacre.postwork.systems.collision.*;
import com.pigmassacre.postwork.systems.ShootingSystem;
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
        viewport = new ExtendViewport(640, 320, camera);

        /* Main systems */
        game.engine.addSystem(new PreviousPositionSystem());
        //game.engine.addSystem(new PlayerControllerSystem());
        //game.engine.addSystem(new PlayerMovementSystem());
        game.engine.addSystem(new JoystickMovementSystem());
        //game.engine.addSystem(new JoystickCameraSystem(camera));
        game.engine.addSystem(new ShootingSystem());

        game.engine.addSystem(new HomingSystem());

        game.engine.addSystem(new AngleSystem());
        game.engine.addSystem(new PropelSystem());
        game.engine.addSystem(new AccelerationSystem());
        game.engine.addSystem(new DragSystem());
        game.engine.addSystem(new VelocitySystem());

        game.engine.addSystem(new EntityCollisionSystem());
        game.engine.addSystem(new LevelCollisionSystem());
        game.engine.addSystem(new StopMovementOnCollisionSystem());
        game.engine.addSystem(new DamageOnCollisionSystem());
        game.engine.addSystem(new DestroyOnMapCollisionSystem());

        game.engine.addSystem(new HealthSystem());

        game.engine.addSystem(new CameraSystem(camera));
        game.engine.addSystem(new RenderSystem(camera));
        //game.engine.addSystem(new DebugRenderSystem(camera));

        /* Entities */
        Entity player = EntityCreator.createPlayer(-1, -1, 10, 10);

        PlayerInputAdapter inputAdapter = new PlayerInputAdapter();
        inputAdapter.setControlledEntity(player);
        inputMultiplexer.addProcessor(inputAdapter);
        Gdx.input.setInputProcessor(inputMultiplexer);

        /*
        ControllerInputAdapter controllerInputAdapter = new ControllerInputAdapter();
        Controllers.addListener(controllerInputAdapter);
        controllerInputAdapter.setControlledEntity(player);
        */

        for (int i = 0; i < 10; i++) {
            EntityCreator.createHomingEnemy(MathUtils.random(-128, 128), MathUtils.random(-128, 128), 8f, 8f, player);
        }

        EntityCreator.createLevel();
    }

    @Override
    public void show() {
        super.show();
    }

    @Override
    public void render(float delta) {
        super.render(delta);
        game.engine.update(delta);
    }

    @Override
    public void resize(int width, int height) {
        super.resize(width, height);
    }

    @Override
    public void pause() {
        super.pause();
    }

    @Override
    public void resume() {
        super.resume();
    }

    @Override
    public void hide() {
        super.hide();
    }

    @Override
    public void dispose() {
        super.dispose();
    }

}
