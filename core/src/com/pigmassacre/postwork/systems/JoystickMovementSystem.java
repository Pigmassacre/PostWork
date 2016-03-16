package com.pigmassacre.postwork.systems;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class JoystickMovementSystem extends IteratingSystem {

    private static final float FACTOR = 0.1f;

    public JoystickMovementSystem() {
        super(Family.all(AccelerationComponent.class, JoystickControllerComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final AccelerationComponent acceleration = Mappers.acceleration.get(entity);
        final JoystickControllerComponent joystick = Mappers.joystickController.get(entity);

        acceleration.acceleration.x = joystick.axes[0] * FACTOR;
        acceleration.acceleration.y = -joystick.axes[1] * FACTOR;
    }

}
