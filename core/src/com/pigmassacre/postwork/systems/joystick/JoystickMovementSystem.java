package com.pigmassacre.postwork.systems.joystick;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.AccelerationComponent;
import com.pigmassacre.postwork.components.AngleComponent;
import com.pigmassacre.postwork.components.JoystickControllerComponent;
import com.pigmassacre.postwork.components.PlayerControllerComponent;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class JoystickMovementSystem extends IteratingSystem {

    public JoystickMovementSystem() {
        super(Family.all(AccelerationComponent.class, JoystickControllerComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final JoystickControllerComponent joystick = Mappers.joystickController.get(entity);
        AngleComponent angle = Mappers.angle.get(entity);

        float y = -joystick.axes[1];
        float x = joystick.axes[0];
        if (Math.abs(y) > 0.1f || Math.abs(x) > 0.1f) {
            angle.angle = MathUtils.atan2(y, x);
        }
    }

}
