package com.pigmassacre.postwork.systems.joystick;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class JoystickCameraSystem extends IteratingSystem {

    private static final float FACTOR = 0.1f;
    private final OrthographicCamera camera;

    public JoystickCameraSystem(final OrthographicCamera camera) {
        super(Family.all(JoystickControllerComponent.class).get());
        this.camera = camera;
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final JoystickControllerComponent joystick = Mappers.joystickController.get(entity);

        if (joystick.axes[2] > 0f) {
            camera.viewportWidth *= 1f + joystick.axes[2] * FACTOR;
            camera.viewportHeight *= 1f + joystick.axes[2] * FACTOR;
        }

        if (joystick.axes[5] > 0f) {
            camera.viewportWidth *= 1f + -joystick.axes[5] * FACTOR;
            camera.viewportHeight *= 1f + -joystick.axes[5] * FACTOR;
        }
    }

}
