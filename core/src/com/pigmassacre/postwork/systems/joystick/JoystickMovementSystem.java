package com.pigmassacre.postwork.systems.joystick;

import com.badlogic.ashley.core.Entity;
import com.badlogic.ashley.core.Family;
import com.badlogic.ashley.systems.IteratingSystem;
import com.badlogic.gdx.math.MathUtils;
import com.pigmassacre.postwork.components.*;
import com.pigmassacre.postwork.utils.Mappers;

/**
 * Created by pigmassacre on 2016-01-20.
 */
public class JoystickMovementSystem extends IteratingSystem {

    private static float MIN_JOYSTICK_LIMIT_FOR_MOVEMENT = 0.2f;

    public JoystickMovementSystem() {
        super(Family.all(AccelerationComponent.class, JoystickControllerComponent.class).get());
    }

    @Override
    protected void processEntity(Entity entity, float deltaTime) {
        final JoystickControllerComponent joystick = Mappers.joystickController.get(entity);
        AngleComponent angle = Mappers.angle.get(entity);
        PropelComponent propel = Mappers.propel.get(entity);

        float y = -joystick.axes[1];
        float x = joystick.axes[0];
        float absY = Math.abs(y);
        float absX = Math.abs(x);

        if (absY > MIN_JOYSTICK_LIMIT_FOR_MOVEMENT || absX > MIN_JOYSTICK_LIMIT_FOR_MOVEMENT) {
            angle.angle = MathUtils.atan2(y, x);
            propel.speed = Math.max(absY, absX) * 3f;
        } else {
            propel.speed = 0f;
        }


    }

}
